module "networking" {
  source = "../../modules/networking"

  app_name    = var.app_name
  environment = var.environment
  region      = var.region

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "alb" {
  source = "../../modules/alb"

  app_name    = var.app_name
  environment = var.environment

  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnets
}

module "ecs" {
  source = "../../modules/ecs"

  app_name    = var.app_name
  environment = var.environment

  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnets

  alb_security_group_id = module.alb.alb_security_group_id
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

module "internal_lb" {
  source = "../../modules/internal_lb"

  app_name    = var.app_name
  environment = var.environment
  vpc_id      = module.networking.vpc_id

  private_subnets = module.networking.private_subnets

  services = {
    db       = { container_port = 5432, lb_port = 5432 }
    redis    = { container_port = 6379, lb_port = 6379 }
    catalog  = { container_port = 8080, lb_port = 8081 }
    carts    = { container_port = 8080, lb_port = 8082 }
    orders   = { container_port = 8080, lb_port = 8083 }
    checkout = { container_port = 8080, lb_port = 8084 }
  }
}

locals {
  lb = module.internal_lb.dns_name

  # Cargador de Init SQL
  db_init_command = "echo ${base64encode(var.init_sql_content)} | base64 -d > /docker-entrypoint-initdb.d/init.sql && exec docker-entrypoint.sh postgres"

  services = {

    db = {
      image  = "postgres:16"
      port   = 5432
      cpu    = 512
      memory = 1024

      environment = {
        POSTGRES_USER     = var.postgres_user
        POSTGRES_PASSWORD = var.db_password
        POSTGRES_DB       = "orders"
      }

      entry_point = ["sh", "-c"]
      command     = [local.db_init_command]

      public = false
    }

    redis = {
      image  = "redis:7-alpine"
      port   = 6379
      cpu    = 256
      memory = 512

      environment = {}

      public = false
    }

    catalog = {
      image  = "${module.ecr.repository_urls["catalog"]}:latest"
      port   = 8080
      cpu    = 512
      memory = 1024

      environment = {
        GIN_MODE                            = "release"
        RETAIL_CATALOG_PERSISTENCE_PROVIDER = "postgres"
        RETAIL_CATALOG_PERSISTENCE_ENDPOINT = "${local.lb}:5432"
        RETAIL_CATALOG_PERSISTENCE_DB_NAME  = "catalogdb"
        RETAIL_CATALOG_PERSISTENCE_USER     = var.postgres_user
        RETAIL_CATALOG_PERSISTENCE_PASSWORD = var.db_password
      }

      public = false
    }

    carts = {
      image  = "${module.ecr.repository_urls["carts"]}:latest"
      port   = 8080
      cpu    = 512
      memory = 1024

      environment = {
        CART_PERSISTENCE_PROVIDER = "postgres"
        CART_POSTGRES_HOST        = local.lb
        CART_POSTGRES_PORT        = "5432"
        CART_POSTGRES_DB          = "cartdb"
        CART_POSTGRES_USER     = var.postgres_user
        CART_POSTGRES_PASSWORD = var.db_password
        PORT                      = "8080"
      }

      public = false
    }

    orders = {
      image  = "${module.ecr.repository_urls["orders"]}:latest"
      port   = 8080
      cpu    = 512
      memory = 1024

      environment = {
        GIN_MODE                           = "release"
        RETAIL_ORDERS_PERSISTENCE_ENDPOINT = "${local.lb}:5432"
        RETAIL_ORDERS_PERSISTENCE_NAME     = "orders"
        RETAIL_ORDERS_PERSISTENCE_USERNAME = var.postgres_user
        RETAIL_ORDERS_PERSISTENCE_PASSWORD = var.db_password
      }

      public = false
    }

    checkout = {
      image  = "${module.ecr.repository_urls["checkout"]}:latest"
      port   = 8080
      cpu    = 512
      memory = 1024

      environment = {
        RETAIL_CHECKOUT_PERSISTENCE_PROVIDER  = "redis"
        RETAIL_CHECKOUT_PERSISTENCE_REDIS_URL = "redis://${local.lb}:6379"
        RETAIL_CHECKOUT_ENDPOINTS_ORDERS      = "http://${local.lb}:8083"
      }

      public = false
    }

    ui = {
      image  = "${module.ecr.repository_urls["ui"]}:latest"
      port   = 8080
      cpu    = 512
      memory = 1024

      environment = {
        RETAIL_UI_ENDPOINTS_CATALOG  = "http://${local.lb}:8081"
        RETAIL_UI_ENDPOINTS_CARTS    = "http://${local.lb}:8082"
        RETAIL_UI_ENDPOINTS_CHECKOUT = "http://${local.lb}:8084"
        RETAIL_UI_ENDPOINTS_ORDERS   = "http://${local.lb}:8083"
      }

      public = true
    }

    admin = {
      image  = "${module.ecr.repository_urls["admin"]}:latest"
      port   = 8080
      cpu    = 512
      memory = 1024

      environment = {
        DB_HOST          = local.lb
        DB_PORT          = "5432"
        DB_USER          = var.postgres_user
        DB_PASSWORD      = var.db_password
        ADMIN_USERNAME   = var.admin_username
        ADMIN_PASSWORD   = var.admin_password
        ADMIN_JWT_SECRET = var.admin_jwt_secret
      }

      public = true
    }
  }
}

module "ecs_services" {
  source = "../../modules/ecs_services"

  app_name    = var.app_name
  environment = var.environment

  cluster_name      = module.ecs.cluster_name
  public_subnets    = module.networking.public_subnets
  private_subnets   = module.networking.private_subnets
  security_group_id = module.ecs.ecs_security_group

  target_groups = {
    ui    = module.alb.ui_tg_arn
    admin = module.alb.admin_tg_arn
  }

  internal_target_groups = module.internal_lb.target_group_arns

  services = local.services

  depends_on = [module.ecr, module.internal_lb]
}

module "cloudwatch" {
  source       = "../../modules/cloudwatch"
  app_name     = var.app_name
  environment  = var.environment
  aws_region   = var.region
  cluster_name = module.ecs.cluster_name
  alarm_email  = var.alarm_email

  service_names = ["catalog", "carts", "orders", "checkout", "ui", "admin", "db", "redis"]

  alb_arn_suffix      = module.alb.alb_arn_suffix
  ui_tg_arn_suffix    = module.alb.ui_tg_arn_suffix
  admin_tg_arn_suffix = module.alb.admin_tg_arn_suffix

  cpu_threshold             = 80
  memory_threshold          = 80
  error_5xx_threshold       = 10
  response_time_threshold   = 2
  unhealthy_hosts_threshold = 1

  lambda_role_arn = var.lambda_role_arn   
  webhook_url     = var.webhook_url       

  depends_on = [module.ecs_services]
}