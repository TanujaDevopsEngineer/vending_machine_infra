# Vending Machine Microservice Deployment Guide

## What’s This About?
This `README.md` is your go-to guide for getting the vending machine microservice up and running on AWS. It walks you through building, deploying, testing, and monitoring the whole setup. We’re using Terraform (version 1.3 or higher) for infrastructure as code, deploying in the `eu-west-2` region. The microservice has two public endpoints (`GET /beverages`, `POST /beverages`) and one private endpoint (`GET /ingredients`) locked down to a specific EC2 instance (`10.1.2.209`). The app’s containerized with Docker, stored in Amazon ECR, and runs on ECS Fargate for scalability. I’ve tried to make this as straightforward as possible, with all the commands you’ll need and some context on why we made certain choices.

## 1. How to Get This Thing Running

### Stuff You’ll Need
- **AWS CLI**: Set up with credentials for account `112736993507` and region `eu-west-2`. Double-check your `~/.aws/credentials` file.
- **Terraform**: Version 1.3 or later. Grab it from HashiCorp if you haven’t already.
- **Docker**: Installed and running to build and push the microservice image.
- **SSH Keys**: You’ll need `BastionKey.pem` and `APIGatewayServer.pem` to SSH into the bastion and private EC2.
- **Project Directory**: A folder with the Terraform configs and `Dockerfile`. I’ll call this `<project_directory>`—just swap in your actual path.

### Building the Docker Image
1. **Set Up the Dockerfile**:
   - In your `<project_directory>`, create (or use) the `Dockerfile` for the Node.js microservice. This one’s tailored for Node.js 16 and runs on port 3000.
   - Here’s the `Dockerfile`:
     ```dockerfile
     # Use official Node.js 16 as the base image
     FROM node:16

     # Set working directory
     WORKDIR /app

     # Copy package.json and package-lock.json
     COPY package*.json ./

     # Install dependencies
     RUN npm install

     # Copy the rest of the application code
     COPY . .

     # Build the application
     RUN npm run build

     # Expose port 3000
     EXPOSE 3000

     # Start the application
     CMD ["npm", "start"]
     ```

2. **Build the Image**:
   - Open a terminal and navigate to your project folder:
     ```cmd
     cd <project_directory>
     ```
   - Build the Docker image:
     ```cmd
     docker build -t vending-machine-microservice:latest .
     ```
   - If the build fails (e.g., missing `package.json`), make sure all app files are in `<project_directory>`.

### Pushing to Amazon ECR
1. **Create an ECR Repository**:
   - Run this AWS CLI command to set up a repo:
     ```cmd
     aws ecr create-repository --repository-name vending-machine-microservice --region eu-west-2
     ```
   - You’ll get a repository URI like `112736993507.dkr.ecr.eu-west-2.amazonaws.com/vending-machine-microservice`. Jot it down.

2. **Log Docker into ECR**:
   - Get an auth token for Docker:
     ```cmd
     aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 112736993507.dkr.ecr.eu-west-2.amazonaws.com
     ```

3. **Tag and Push the Image**:
   - Tag your image with the ECR URI:
     ```cmd
     docker tag vending-machine-microservice:latest 112736993507.dkr.ecr.eu-west-2.amazonaws.com/vending-machine-microservice:latest
     ```
   - Push it to ECR:
     ```cmd
     docker push 112736993507.dkr.ecr.eu-west-2.amazonaws.com/vending-machine-microservice:latest
     ```
   - This might take a minute depending on your connection.

### Deploying with Terraform
1. **Set Up the Terraform Backend**:
   - The Terraform setup uses an S3 bucket for state and a DynamoDB table for locking to avoid conflicts. Add this to a `backend.tf` file in `<project_directory>`:
     ```hcl
     terraform {
       backend "s3" {
         bucket         = "vending-machine-terraform-state"
         key            = "vending-machine/terraform.tfstate"
         region         = "eu-west-2"
         dynamodb_table = "vending-machine-terraform-locks"
       }
     }
     ```
   - If the S3 bucket or DynamoDB table doesn’t exist, create them:
     ```cmd
     aws s3api create-bucket --bucket vending-machine-terraform-state --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2
     aws dynamodb create-table --table-name vending-machine-terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --region eu-west-2
     ```

2. **Get to the Project Directory**:
   ```cmd
   cd <project_directory>
   ```

3. **Initialize Terraform**:
   - This pulls in providers and sets up the backend:
     ```cmd
     terraform init
     ```

4. **Plan the Deployment**:
   - Check what Terraform will do:
     ```cmd
     terraform plan -out=tfplan
     ```
   - Review the plan to make sure it’s creating the right resources (VPC, ALB, ECS, etc.).

5. **Apply the Configuration**:
   - Deploy everything:
     ```cmd
     terraform apply tfplan
     ```
   - Type `yes` when prompted. This sets up the VPC, ALB, ECS, API Gateway, EC2, and VPC endpoint.

### Testing the Setup
1. **Check Public /beverages Endpoints**:
   - **GET /beverages**:
     ```cmd
     curl http://vending-machine-alb-30496400.eu-west-2.elb.amazonaws.com/beverages
     ```
     - You should see JSON like `[{"name":"cola","quantity":50},...]`.
   - **POST /beverages**:
     ```cmd
     curl -X POST http://vending-machine-alb-30496400.eu-west-2.elb.amazonaws.com/beverages -d "{\"name\":\"Soda\"}" -H "Content-Type: application/json"
     ```
     - Expect a response like `{"status":"success"}`.

2. **Test Private /ingredients Endpoint**:
   - SSH into the private EC2 via the bastion:
     ```cmd
     ssh -i <path_to_keys>/BastionKey.pem -A ec2-user@<bastion_public_ip>
     ssh -i /home/ec2-user/APIGatewayServer.pem ec2-user@10.1.2.209
     ```
   - From the private EC2, run:
     ```bash
     curl https://y44achuz3l.execute-api.eu-west-2.amazonaws.com/prod/ingredients
     ```
     - You should get JSON like `[{"name":"sugar","quantity":100},...]`.

3. **Confirm /ingredients Is Locked Down**:
   - Try accessing via ALB:
     ```cmd
     curl http://vending-machine-alb-30496400.eu-west-2.elb.amazonaws.com/ingredients
     ```
     - Should return `Access Denied` (403).
   - Try via API Gateway:
     ```cmd
     curl https://y44achuz3l.execute-api.eu-west-2.amazonaws.com/prod/ingredients
     ```
     - Should return "Forbidden" or a similar error.

4. **Check CloudWatch Logs**:
   - For API Gateway logs:
     ```cmd
     aws logs describe-log-streams --log-group-name "/aws/apigateway/vending-machine-api" --region eu-west-2
     aws logs get-log-events --log-group-name "/aws/apigateway/vending-machine-api" --log-stream-name <stream_name> --region eu-west-2
     ```
   - For ECS logs:
     ```cmd
     aws logs describe-log-streams --log-group-name "/ecs/vending-machine" --region eu-west-2
     aws logs get-log-events --log-group-name "/ecs/vending-machine" --log-stream-name <stream_name> --region eu-west-2
     ```
   - Look for 200 responses or errors to debug issues.

5. **Verify Terraform State in S3**:
   - Check the state file:
     ```cmd
     aws s3 ls s3://vending-machine-terraform-state/vending-machine/terraform.tfstate
     ```
   - If you need to inspect it:
     ```cmd
     aws s3 cp s3://vending-machine-terraform-state/vending-machine/terraform.tfstate terraform.tfstate
     ```

6. **Check DynamoDB Locks**:
   - See if there are any active locks:
     ```cmd
     aws dynamodb scan --table-name vending-machine-terraform-locks --region eu-west-2
     ```
   - It should be empty after `terraform apply` finishes.

### Keeping It Running
- Once deployed, the microservice runs on AWS. ECS tasks handle the app, with the ALB routing public traffic and API Gateway managing private `/ingredients` requests.
- Monitor ECS health:
  ```cmd
  aws ecs describe-services --cluster vending-machine-cluster --services vending-machine-cluster-service --region eu-west-2
  ```

## 2. The Architecture and Tech Stack

### How It’s Put Together
This is a cloud-native setup on AWS, built to be scalable and secure:
- **VPC**: We’ve got a Virtual Private Cloud (`vpc-0a9f35938b6a8e0a9`) with public subnets (`10.1.1.0/24`, `10.1.3.0/24`) and private subnets (`10.1.2.0/24`, `10.1.4.0/24`) across two AZs (`eu-west-2a`, `eu-west-2b`).
- **Public Layer**:
  - **ALB**: The Application Load Balancer (`vending-machine-alb`) handles public `/beverages` (GET/POST) and routes to ECS. It blocks `/ingredients` with a 403.
  - **ECS**: An ECS cluster (`vending-machine-cluster`) runs the microservice on Fargate in private subnets, using `/beverages` for health checks.
- **Private Layer**:
  - **API Gateway**: A private REST API (`y44achuz3l`) serves `/ingredients` (GET), only accessible from the private EC2 (`10.1.2.209`) via a VPC endpoint (`vpce-0a941144d58b84ceb`).
  - **Private EC2**: An EC2 instance (`i-04ca92236a84c3ba9`, IP `10.1.2.209`) in a private subnet hits the API Gateway.
  - **Bastion Host**: A public EC2 lets you SSH into the private EC2.
- **Networking**:
  - **VPC Endpoint**: Keeps EC2-to-API-Gateway traffic private.
  - **Security Groups**: Tight rules (e.g., `sg-006841e99e495a38e` for VPC endpoint, `sg-0f457bdc8a3746aa2` for EC2).
- **Logging**:
  - CloudWatch Logs (`/aws/apigateway/vending-machine-api`) for API Gateway and (`/ecs/vending-machine`) for ECS app logs.
- **State Management**:
  - S3 bucket (`vending-machine-terraform-state`) for Terraform state.
  - DynamoDB table (`vending-machine-terraform-locks`) for state locking.

#### Architecture Diagram
Here’s a rough sketch of how it all fits together:
```
+---------------------+          +---------------------+          +------------------+
|    Internet User    |  ---->   |   AWS ALB (Public)  |  ---->   |   ECS Service    |
| (Browser / Postman) |          | - vending-machine-alb|          | - vending-machine|
|                     |          | - HTTP (80)         |          | - Fargate        |
|                     |          | - /beverages (GET)  |          | - Private Subnets|
|                     |          | - /beverages (POST) |          | - 10.1.2.0/24    |
|                     |          | - Blocks /ingredients|         | - 10.1.4.0/24    |
+---------------------+          +---------------------+          +------------------+
                             |                                |
                             | Deny /ingredients (403)      | /beverages
                             |                                v
                             |                        +------------------+
                             |                        |  CloudWatch Logs |
                             |                        | - /ecs/vending-  |
                             |                        |   machine        |
                             |                        +------------------+
                             v
+---------------------+      |                        +------------------+
|   API Gateway       | <----+                        |  Private EC2     |
| - y44achuz3l       |      Deny Public Access       | - 10.1.2.209     |
| - Private REST API  |                               | - i-04ca92236a84 |
| - /ingredients (GET)|  ----> +-----------------+    | - Private Subnet |
| - VPC Endpoint      |        |  Bastion Host   |    | - 10.1.2.0/24    |
| - vpce-0a941144d58b| <----  |  (Public EC2)   |    +------------------+
| - HTTPS (443)       |        |  - SSH Access   |             |
+---------------------+        +-----------------+             | SSH via Bastion
                             |                                v
                             |                        +------------------+
                             |                        |  CloudWatch Logs |
                             |                        | - /aws/apigateway|
                             |                        |   /vending-machine|
                             |                        +------------------+
                             v
+---------------------+      |                        +------------------+
|   VPC               |      |                        |  S3 Backend      |
| - vpc-0a9f35938b6a8|      |                        | - Terraform State|
| - Public Subnets   |      |                        +------------------+
|   - 10.1.1.0/24    |      |                        +------------------+
|   - 10.1.3.0/24    |      |                        |  DynamoDB Table  |
| - Private Subnets  |      |                        | - State Lock     |
|   - 10.1.2.0/24    |      +----------------------->+------------------+
|   - 10.1.4.0/24    |
| - Security Groups  |
|   - sg-006841e99e4|
|   - sg-0f457bdc8a3|
+---------------------+
```

### Tech Stack
- **AWS Services**:
  - **VPC**: Keeps resources isolated with public/private subnets.
  - **ALB**: Routes public traffic like a champ.
  - **ECS (Fargate)**: Runs containers without server headaches.
  - **API Gateway**: Locks down private API access.
  - **EC2**: Hosts the private client and bastion.
  - **CloudWatch**: Logs everything for debugging.
  - **ECR**: Stores our Docker images.
  - **S3**: Holds Terraform state.
  - **DynamoDB**: Manages Terraform locks.
- **Terraform**: Defines infrastructure as code for repeatability.
- **Docker**: Containers ensure the app runs consistently.
- **HTTP/REST**: Standard for the API endpoints.

### Why It’s Solid
- **Scalability**: ECS auto-scales based on load, and ALB spreads traffic across AZs. API Gateway handles private requests smoothly.
- **High Availability**: Two AZs (`eu-west-2a`, `eu-west-2b`) keep things running if one goes down.
- **Security**: Private subnets, security groups, and IP policies lock things down. The VPC endpoint keeps private traffic off the public internet.

## 3. Why We Built It This Way

### Architecture Choices
- **Public vs. Private Endpoints**:
  - Made `/beverages` (GET/POST) public via ALB since it needs to be internet-accessible.
  - Locked `/ingredients` (GET) to the private EC2 (`10.1.2.209`) using API Gateway with an IP policy (`10.1.2.209/32`) for security.
- **VPC and Subnets**:
  - Split resources into public (ALB, bastion) and private (ECS, EC2) subnets for better isolation.
  - Used two AZs for redundancy.
- **ALB vs. API Gateway**:
  - Went with ALB for public endpoints because it’s simple and plays nice with ECS.
  - Chose API Gateway for `/ingredients` to leverage tight access controls and VPC endpoints.
- **ECS Fargate**:
  - Fargate means no server management and easy scaling.
  - Used `/beverages` for health checks since the app didn’t have a `/health` endpoint.
- **Docker and ECR**:
  - Docker keeps the app portable and consistent.
  - ECR’s a secure spot for images, tightly integrated with ECS.

### Tech Decisions
- **Terraform**:
  - IaC makes the setup reproducible. We used modules (`vpc`, `alb`, `ecs`, `ec2`, `api_gateway`) to keep things tidy.
  - S3 and DynamoDB backends prevent state conflicts.
- **AWS**:
  - It’s reliable, scalable, and widely used. `eu-west-2` was the specified region.
- **CloudWatch**:
  - Logs for API Gateway (`/aws/apigateway/vending-machine-api`) and ECS (`/ecs/vending-machine`) help track down issues like 403 errors.
- **Docker**:
  - Node.js 16 base image matches the app’s needs, with a build step for optimization.

### Troubleshooting Notes
- **403 Errors**:
  - Early on, `aws:SourceVpce` and `aws:SourceVpc` policies caused 403s, likely due to misconfigs or ALB rules.
  - Temporarily allowed all traffic (`"Allow" "*"`) to test, which pointed to ALB as the culprit.
- **ALB Rules**:
  - Dropped `allow_ingredients_vpc` and `deny_ingredients` rules to test, then reinstated `deny_ingredients` to block public access, relying on API Gateway’s policy.
- **Policy Fix**:
  - Settled on an IP-based policy (`10.1.2.209/32`) for `/ingredients` to keep it secure yet functional.
- **Logging**:
  - Added `data_trace_enabled` to API Gateway’s `aws_api_gateway_method_settings` to get detailed logs, which helped sort out backend errors.
- **ECR**:
  - Made sure ECS pulls the latest image from ECR, checked via CloudWatch logs.

## 4. Key Configuration Details

### VPC
- **ID**: `vpc-0a9f35938b6a8e0a9`
- **Subnets**:
  - Public: `10.1.1.0/24` (`eu-west-2a`), `10.1.3.0/24` (`eu-west-2b`)
  - Private: `10.1.2.0/24` (`eu-west-2a`, `subnet-0f1b675c9fa495a1e`), `10.1.4.0/24` (`eu-west-2b`)
- **VPC Endpoint**: `vpce-0a941144d58b84ceb` for API Gateway, security group `sg-006841e99e495a38e`.

### ALB
- **Name**: `vending-machine-alb`
- **DNS**: `vending-machine-alb-30496400.eu-west-2.elb.amazonaws.com`
- **Security Group**: Allows HTTP (80) from `0.0.0.0/0`, `10.1.0.0/16`.
- **Listener Rule**: `deny_ingredients` (priority 100) blocks `/ingredients` with 403.
- **Target Group**: `vending-machine-tg`, health check on `/beverages`.

### ECS
- **Cluster**: `vending-machine-cluster`
- **Service**: `vending-machine-cluster-service`, runs 2 tasks on Fargate in private subnets.
- **Task Definition**: Uses Docker image from ECR (`112736993507.dkr.ecr.eu-west-2.amazonaws.com/vending-machine-microservice:latest`).
- **Logs**: `/ecs/vending-machine`.

### API Gateway
- **ID**: `y44achuz3l`
- **Endpoint**: `https://y44achuz3l.execute-api.eu-west-2.amazonaws.com/prod`
- **Policy**: Allows `GET /ingredients` only from `10.1.2.209/32`, denies others.
- **Integration**: HTTP proxy to ALB for `/ingredients`.
- **Logs**: `/aws/apigateway/vending-machine-api`, with access and execution logs (`INFO` level, `data_trace_enabled`).

### EC2
- **Private EC2**: `i-04ca92236a84c3ba9`, IP `10.1.2.209`, subnet `subnet-0f1b675c9fa495a1e`, security group `sg-0f457bdc8a3746aa2` (allows SSH from bastion, HTTPS to VPC).
- **Bastion**: Public EC2 for SSH access to private EC2.

### Security Groups
- **VPC Endpoint**: `sg-006841e99e495a38e`, allows HTTPS (443) from `10.1.2.0/24`, `10.1.4.0/24`.
- **Private EC2**: `sg-0f457bdc8a3746aa2`, allows SSH (22) from bastion, HTTPS (443) to `10.1.0.0/16`, all egress.
- **ALB**: Allows HTTP (80) from `0.0.0.0/0`, `10.1.0.0/16`, all egress.

### Terraform State Management
- **S3 Bucket**: `vending-machine-terraform-state`
- **DynamoDB Table**: `vending-machine-terraform-locks`
- **State File**: `vending-machine/terraform.tfstate`

### ECR
- **Repository**: `vending-machine-microservice`
- **URI**: `112736993507.dkr.ecr.eu-west-2.amazonaws.com/vending-machine-microservice`

## Wrapping Up
This setup gives you a solid, scalable microservice with public `/beverages` and private `/ingredients` endpoints. AWS services handle reliability, Terraform keeps the infra tidy, Docker ensures consistency, and CloudWatch lets you debug. 
