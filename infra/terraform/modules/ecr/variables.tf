variable "app_name" {
  type        = string
  description = "Nombre de la aplicacion"
}

variable "environment" {
  type        = string
  description = "develop - test - prod"
}

variable "service_names" {
  type        = list(string)
  description = "Lista de microservicios"
}