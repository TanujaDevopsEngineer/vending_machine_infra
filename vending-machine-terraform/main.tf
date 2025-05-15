module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones  = var.availability_zones
  region              = var.region
  ecs_security_group_id = module.ecs.ecs_security_group_id
}

module "ecs" {
  source                = "./modules/ecs"
  vpc_id                = module.vpc.vpc_id
  public_subnets        = module.vpc.public_subnets
  private_subnet_ids    = module.vpc.private_subnets
  cluster_name          = var.cluster_name
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  container_image       = var.container_image
  container_port        = var.container_port
  desired_count         = var.desired_count
  alb_security_group_id = module.alb.alb_security_group_id
  alb_target_group_arn  = module.alb.target_group_arn
  alb_arn               = module.alb.alb_arn
}

module "alb" {
  source             = "./modules/alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnets
  container_port     = var.container_port
}

module "api_gateway" {
  source          = "./modules/api_gateway"
  alb_dns_name    = module.alb.alb_dns_name
  region          = var.region
  container_port  = var.container_port
  vpc_endpoint_id = module.vpc.vpc_endpoint_id
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

module "ec2" {
  source             = "./modules/ec2"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
}