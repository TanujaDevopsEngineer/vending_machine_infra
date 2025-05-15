variable "vpc_cidr" {
  default = "10.1.0.0/16" # Changed to avoid conflict
}

variable "public_subnet_cidrs" {
  default = ["10.1.1.0/24", "10.1.3.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.1.2.0/24", "10.1.4.0/24"]
}

variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "region" {
  default = "eu-west-2"
}

variable "cluster_name" {
  default = "vending-machine-cluster"
}

variable "task_cpu" {
  default = "512"
}

variable "task_memory" {
  default = "1024"
}

variable "container_image" {
  default = "112736993507.dkr.ecr.eu-west-2.amazonaws.com/vending-machine:latest"
}

variable "container_port" {
  default = 3000
}

variable "desired_count" {
  default = 2
}

variable "bucket_name" {
  default = "my-vending-machine-bucket-12345"
}