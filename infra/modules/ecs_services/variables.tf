variable "app_name" {}
variable "environment" {}

variable "cluster_name" {}

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

    public = optional(bool, false)

    # Init SQL Injection
    command     = optional(list(string), [])
    entry_point = optional(list(string), [])
  }))
}

variable "target_groups" {
  type    = map(string)
  default = {}
}

variable "service_discovery_arns" {
  type    = map(string)
  default = {}
}
