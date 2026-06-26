output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnets" {
  description = "Public subnets"
  value       = module.networking.public_subnets
}

output "private_subnets" {
  description = "Private subnets"
  value       = module.networking.private_subnets
}

output "alb_dns" {
  description = "ALB DNS"
  value       = module.alb.alb_dns
}

output "internal_lb_dns" {
  description = "Internal LB DNS"
  value       = module.internal_lb.dns_name
}