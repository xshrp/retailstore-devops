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

locals {
  init_sql_content = file("${path.module}/../../../init-db.sql")
}

module "app" {
  source = "../base_environment"

  app_name    = var.app_name
  environment = var.environment
  region      = var.region

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  init_sql_content = local.init_sql_content
}