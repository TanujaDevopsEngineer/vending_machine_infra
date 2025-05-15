variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}
variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}
variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}
variable "task_cpu" {
  description = "Task CPU"
  type        = string
}
variable "task_memory" {
  description = "Task memory"
  type        = string
}
variable "container_image" {
  description = "Container image"
  type        = string
}
variable "container_port" {
  description = "Container port"
  type        = number
}
variable "desired_count" {
  description = "Desired task count"
  type        = number
}
variable "alb_security_group_id" {
  description = "ALB security group ID"
  type        = string
}
variable "alb_target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}
variable "alb_arn" {
  description = "ALB ARN"
  type        = string
}