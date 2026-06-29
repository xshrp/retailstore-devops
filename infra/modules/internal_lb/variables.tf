variable "app_name" {}
variable "environment" {}
variable "vpc_id" {}

variable "private_subnets" {
  type = list(string)
}

variable "services" {
  description = "NLB Services"
  type = map(object({
    container_port = number
    lb_port         = number
  }))
}