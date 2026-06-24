output "vpc_id" {
  value = module.app.vpc_id
}

output "public_subnets" {
  value = module.app.public_subnets
}

output "private_subnets" {
  value = module.app.private_subnets
}

output "alb_dns" {
  value = module.app.alb_dns
}