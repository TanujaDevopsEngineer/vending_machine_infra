variable "public_subnet_ids" {
  description = "IDs of public subnets"
  type        = list(string)
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "container_port" {
  description = "Container port"
  type        = number
}