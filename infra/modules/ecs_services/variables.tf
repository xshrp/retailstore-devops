variable "app_name" {}
variable "environment" {}

variable "cluster_name" {}
variable "execution_role_arn" {}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "security_group_id" {}

variable "services" {
  type = map(object({
    image       = string
    port        = number
    cpu         = number
    memory      = number
    environment = map(string)

    public      = optional(bool, false)
  }))
}

variable "target_groups" {
  type = map(string)
  default = {}
}