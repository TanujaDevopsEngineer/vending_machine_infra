variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "vpc_endpoint_id" {
  description = "ID of the VPC Endpoint for API Gateway"
  type        = string
}