output "alb_dns" {
  value = aws_lb.this.dns_name
}

output "ui_tg_arn" {
  value = aws_lb_target_group.ui.arn
}

output "admin_tg_arn" {
  value = aws_lb_target_group.admin.arn
}