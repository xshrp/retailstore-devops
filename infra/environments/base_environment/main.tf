module "networking" {
  source = "../networking"

  app_name    = var.app_name
  environment = var.environment
  region      = var.region

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "alb" {
  source = "../alb"

  app_name    = var.app_name
  environment = var.environment

  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnets
}

module "ecs" {
  source = "../ecs"

  app_name    = var.app_name
  environment = var.environment

  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnets

  alb_security_group_id = module.alb.alb_security_group_id
}

module "ecr" {
  source = "../ecr"

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

module "service_discovery" {
  source = "../service_discovery"

  app_name    = var.app_name
  environment = var.environment
  vpc_id      = module.networking.vpc_id

  services = [
    "db",
    "redis",
    "catalog",
    "carts",
    "orders",
    "checkout"
  ]
}

locals {
  ns = module.service_discovery.namespace_name

  # BD Init Loader
  db_init_command = "echo ${base64encode(var.init_sql_content)} | base64 -d > /docker-entrypoint-initdb.d/init.sql && exec docker-entrypoint.sh postgres"

  services = {

    db = {
      image  = "postgres:16"
      port   = 5432
      cpu    = 512
      memory = 1024

      environment = {
        POSTGRES_USER     = "retail_user"
        POSTGRES_PASSWORD = "retailpassword"
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
        RETAIL_CATALOG_PERSISTENCE_ENDPOINT = "db.${local.ns}:5432"
        RETAIL_CATALOG_PERSISTENCE_DB_NAME  = "catalogdb"
        RETAIL_CATALOG_PERSISTENCE_USER     = "retail_user"
        RETAIL_CATALOG_PERSISTENCE_PASSWORD = "retailpassword"
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
        CART_POSTGRES_HOST        = "db.${local.ns}"
        CART_POSTGRES_PORT        = "5432"
        CART_POSTGRES_DB          = "cartdb"
        CART_POSTGRES_USER        = "retail_user"
        CART_POSTGRES_PASSWORD    = "retailpassword"
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
        RETAIL_ORDERS_PERSISTENCE_ENDPOINT = "db.${local.ns}:5432"
        RETAIL_ORDERS_PERSISTENCE_NAME     = "orders"
        RETAIL_ORDERS_PERSISTENCE_USERNAME = "retail_user"
        RETAIL_ORDERS_PERSISTENCE_PASSWORD = "retailpassword"
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
        RETAIL_CHECKOUT_PERSISTENCE_REDIS_URL = "redis://redis.${local.ns}:6379"
        RETAIL_CHECKOUT_ENDPOINTS_ORDERS      = "http://orders.${local.ns}:8080"
      }

      public = false
    }

    ui = {
      image  = "${module.ecr.repository_urls["ui"]}:latest"
      port   = 8080
      cpu    = 512
      memory = 1024

      environment = {
        RETAIL_UI_ENDPOINTS_CATALOG  = "http://catalog.${local.ns}:8080"
        RETAIL_UI_ENDPOINTS_CARTS    = "http://carts.${local.ns}:8080"
        RETAIL_UI_ENDPOINTS_CHECKOUT = "http://checkout.${local.ns}:8080"
        RETAIL_UI_ENDPOINTS_ORDERS   = "http://orders.${local.ns}:8080"
      }

      public = true
    }

    admin = {
      image  = "${module.ecr.repository_urls["admin"]}:latest"
      port   = 8080
      cpu    = 512
      memory = 1024

      environment = {
        DB_HOST          = "db.${local.ns}"
        DB_PORT          = "5432"
        DB_USER          = "retail_user"
        DB_PASSWORD      = "retailpassword"
        ADMIN_USERNAME   = "admin"
        ADMIN_PASSWORD   = "admin"
        ADMIN_JWT_SECRET = "change-me-in-production"
      }

      public = true
    }
  }
}

module "ecs_services" {
  source = "../ecs_services"

  app_name    = var.app_name
  environment = var.environment

  cluster_name       = module.ecs.cluster_name
  public_subnets     = module.networking.public_subnets
  private_subnets    = module.networking.private_subnets
  security_group_id  = module.ecs.ecs_security_group

  target_groups = {
    ui    = module.alb.ui_tg_arn
    admin = module.alb.admin_tg_arn
  }

  service_discovery_arns = module.service_discovery.service_arns

  services = local.services

  depends_on = [module.ecr]
}
