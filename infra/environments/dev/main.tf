module "network" {
  source = "../../modules/network"

  project_name = "production-pipeline"
  environment  = "dev"

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
  environment  = "dev"
}

module "alb" {
  source = "../../modules/alb"

  project_name      = "production-pipeline"
  environment       = "dev"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}