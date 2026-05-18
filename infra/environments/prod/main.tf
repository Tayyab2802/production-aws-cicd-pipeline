module "network" {
  source = "../../modules/network"

  project_name = "production-pipeline"
  environment  = "prod"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  availability_zones = [
    "eu-west-2a",
    "eu-west-2b"
  ]
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = "production-pipeline"
  environment  = "prod"
}

module "alb" {
  source = "../../modules/alb"

  project_name      = "production-pipeline"
  environment       = "prod"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}


module "ecs" {
  source = "../../modules/ecs"

  project_name          = "production-pipeline"
  environment           = "prod"
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn

  container_image = var.container_image
}