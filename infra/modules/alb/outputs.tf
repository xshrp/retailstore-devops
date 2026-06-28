output "alb_dns" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "ui_tg_arn" {
  description = "UI target group ARN"
  value       = aws_lb_target_group.ui.arn
}

output "admin_tg_arn" {
  description = "Admin target group ARN"
  value       = aws_lb_target_group.admin.arn
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "alb_arn_suffix" {
  description = "Sufijo ARN del ALB para métricas CloudWatch"
  value       = aws_lb.this.arn_suffix
}

output "ui_tg_arn_suffix" {
  description = "Sufijo ARN del target group UI para métricas CloudWatch"
  value       = aws_lb_target_group.ui.arn_suffix
}

output "admin_tg_arn_suffix" {
  description = "Sufijo ARN del target group Admin para métricas CloudWatch"
  value       = aws_lb_target_group.admin.arn_suffix
}