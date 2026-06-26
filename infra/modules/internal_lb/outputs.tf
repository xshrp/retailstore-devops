output "dns_name" {
  description = "Internal LB DNS name"
  value       = aws_lb.internal.dns_name
}

output "target_group_arns" {
  description = "Internal target group ARNs"
  value = {
    for k, tg in aws_lb_target_group.this : k => tg.arn
  }
}