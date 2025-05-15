
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3"

  backend "s3" {
    bucket         = "my-vending-machine-bucket-12345"
    key            = "terraform/state"
    region         = "eu-west-2"
    dynamodb_table = "terraform-lock"
  }
}
