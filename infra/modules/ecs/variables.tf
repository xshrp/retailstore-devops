variable "app_name" {

}

variable "environment" {

}

variable "vpc_id" {

}

variable "private_subnets" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}