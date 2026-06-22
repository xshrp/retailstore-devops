provider "aws" {
  region = var.aws_region
}

data "aws_iam_role" "labrole" {
  name = "LabRole"
}

module "networking" {
  source = "../../modules/networking"

  app_name        = var.app_name
  environment     = var.environment

  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

module "ecr" {
  source = "../../modules/ecr"

  app_name    = var.app_name
  environment = var.environment

  service_names = [
    "catalog",
    "cart",
    "orders",
    "checkout",
    "ui",
    "admin"
  ]
}

module "eks" {
  source = "../../modules/eks"

  app_name    = var.app_name
  environment = var.environment

  public_subnets  = module.networking.public_subnets
  private_subnets = module.networking.private_subnets

  labrole_arn      = data.aws_iam_role.labrole.arn
  node_instance_type = var.node_instance_type
}