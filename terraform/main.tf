provider "aws" { region = "us-east-1" }

terraform {
  backend "s3" {
    bucket = "starttech-terraform-state-bucket-tonye1"
    key    = "state.tfstate"
    region = "us-east-1"
  }
}

module "networking" { source = "./modules/networking" }
module "monitoring" { source = "./modules/monitoring" }

module "compute" {
  source          = "./modules/compute"
  vpc_id          = module.networking.vpc_id
  public_subnets  = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  docker_username = var.docker_username
  mongo_uri       = var.mongo_uri
}

module "storage" {
  source          = "./modules/storage"
  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnets
  ec2_sg_id       = module.compute.ec2_sg_id
}
