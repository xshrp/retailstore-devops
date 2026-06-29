variable "app_name" {}
variable "environment" {}

variable "vpc_id" {}

variable "public_subnets" {
  type = list(string)
}