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
  source           = "../base_environment"

  app_name         = var.app_name
  environment      = var.environment
  region           = var.region

  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets

  init_sql_content = local.init_sql_content

  postgres_user    = var.postgres_user
  db_password      = var.db_password
  admin_username   = var.admin_username
  admin_password   = var.admin_password
  admin_jwt_secret = var.admin_jwt_secret

  alarm_email     = var.alarm_email      
  lambda_role_arn = var.lambda_role_arn  
  webhook_url     = var.webhook_url
}