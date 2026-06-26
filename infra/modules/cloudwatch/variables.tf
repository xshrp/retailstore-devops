variable "app_name"    { type = string }
variable "environment" { type = string }
variable "aws_region"  { type = string }
variable "cluster_name" { type = string }
variable "alarm_email"  { type = string; default = "" }

variable "service_names" {
  description = "Lista de nombres de servicios ECS a monitorear"
  type        = list(string)
  default     = ["catalog", "carts", "orders", "checkout", "ui", "admin", "db", "redis"]
}

variable "alb_arn_suffix" {
  description = "Sufijo del ARN del ALB público"
  type        = string
}

variable "ui_tg_arn_suffix" {
  description = "Sufijo del ARN del target group de UI"
  type        = string
}

variable "admin_tg_arn_suffix" {
  description = "Sufijo del ARN del target group de Admin"
  type        = string
}

variable "cpu_threshold"             { type = number; default = 80 }
variable "memory_threshold"          { type = number; default = 80 }
variable "error_5xx_threshold"       { type = number; default = 10 }
variable "response_time_threshold"   { type = number; default = 2  }
variable "unhealthy_hosts_threshold" { type = number; default = 1  }