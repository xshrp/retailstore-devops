terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "networking" {
  source = "../../modules/networking"

  app_name    = var.app_name
  environment = var.environment
  region      = var.region

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "ecs" {
  source = "../../modules/ecs"

  app_name    = var.app_name
  environment = var.environment

  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnets
}

module "ecr" {
  source = "../../modules/ecr"

  app_name    = var.app_name
  environment = var.environment

  services = [
    "catalog",
    "carts",
    "orders",
    "checkout",
    "ui",
    "admin"
  ]
}

module "ecs_services" {
  source = "../../modules/ecs_services"

  app_name    = var.app_name
  environment = var.environment

  cluster_name        = module.ecs.cluster_name
  execution_role_arn  = module.ecs.execution_role_arn
  public_subnets  = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  security_group_id   = module.ecs.ecs_security_group

  depends_on = [module.ecr]

  target_groups = {
    ui    = module.alb.ui_tg_arn
    admin = module.alb.admin_tg_arn
  }

  services = {

    db = {
      image = "postgres:16"
      port  = 5432
      cpu    = 512
      memory = 1024

      environment = {
        POSTGRES_USER     = "retail_user"
        POSTGRES_PASSWORD = "retailpassword"
        POSTGRES_DB       = "orders"
      }

      public = false
    }

    redis = {
      image = "redis:7-alpine"
      port  = 6379
      cpu    = 256
      memory = 512

      environment = {}

      public = false
    }

    catalog = {
      image = "${module.ecr.repository_urls["catalog"]}:latest"
      port  = 8080
      cpu    = 512
      memory = 1024

      environment = {
        GIN_MODE = "release"
      }

      public = false
    }

    carts = {
      image = "${module.ecr.repository_urls["carts"]}:latest"
      port  = 8080
      cpu    = 512
      memory = 1024

      environment = {}

      public = false
    }

    orders = {
      image = "${module.ecr.repository_urls["orders"]}:latest"
      port  = 8080
      cpu    = 512
      memory = 1024

      environment = {}

      public = false
    }

    checkout = {
      image = "${module.ecr.repository_urls["checkout"]}:latest"
      port  = 8080
      cpu    = 512
      memory = 1024

      environment = {}

      public = false
    }

    ui = {
      image = "${module.ecr.repository_urls["ui"]}:latest"
      port  = 8080
      cpu    = 512
      memory = 1024

      environment = {}

      public = true
    }

    admin = {
      image = "${module.ecr.repository_urls["admin"]}:latest"
      port  = 8081
      cpu    = 512
      memory = 1024

      environment = {}

      public = true
    }
  }
}
module "alb" {
  source = "../../modules/alb"

  app_name    = var.app_name
  environment = var.environment

  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnets

  security_group_id = module.ecs.ecs_security_group
}