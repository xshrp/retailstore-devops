output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnets" {
  value = module.networking.public_subnets
}

output "private_subnets" {
  value = module.networking.private_subnets
}

output "alb_dns" {
  value = module.alb.alb_dns
}

output "internal_lb_dns" {
  value = module.internal_lb.dns_name
}