variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}
variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}
variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
}
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}
variable "region" {
  description = "AWS region"
  type        = string
}
variable "ecs_security_group_id" {
  description = "ECS security group ID"
  type        = string
}