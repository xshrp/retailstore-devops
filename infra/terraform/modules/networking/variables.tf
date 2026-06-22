variable "app_name" {
  type        = string
  description = "Nombre de la app"
}

variable "environment" {
  type        = string
  description = "develop - test - prod"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block de la VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "Subnets publicas"
}

variable "private_subnets" {
  type        = list(string)
  description = "Subnets privadas"
}

variable "azs" {
  type        = list(string)
  description = "Zonas de disponibilidad"
}