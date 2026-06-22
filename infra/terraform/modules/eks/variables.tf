variable "app_name" {
  type        = string
  description = "Nombre de la app"
}

variable "environment" {
  type        = string
  description = "develop - test - prod"
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "labrole_arn" {
  type        = string
  description = "ARN del rol LabRole"
}

variable "node_instance_type" {
  type        = string
  description = "Tipo de instancia para los nodos"
}