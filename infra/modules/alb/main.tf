resource "aws_lb" "this" {
  name               = "${var.app_name}-${var.environment}-alb"
  load_balancer_type = "application"
  internal           = false

  subnets         = var.public_subnets
  security_groups = [var.security_group_id]
}
resource "aws_lb_target_group" "ui" {
  name        = "${var.app_name}-${var.environment}-ui-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  target_type = "ip"
}
resource "aws_lb_target_group" "admin" {
  name        = "${var.app_name}-${var.environment}-admin-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  target_type = "ip"
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ui.arn
  }
}
resource "aws_lb_listener_rule" "admin" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/admin*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin.arn
  }
}