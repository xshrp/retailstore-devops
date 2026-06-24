output "vpc_id" {
  description = "VPC ID"
  value       = module.app.vpc_id
}

output "public_subnets" {
  description = "Public subnets"
  value       = module.app.public_subnets
}

output "private_subnets" {
  description = "Private subnets"
  value       = module.app.private_subnets
}

output "alb_dns" {
  description = "ALB DNS"
  value       = module.app.alb_dns
}

output "internal_lb_dns" {
  description = "Internal LB DNS"
  value       = module.internal_lb.dns_name
}