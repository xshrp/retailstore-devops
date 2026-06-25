resource "aws_lb" "internal" {
  name               = "${var.app_name}-${var.environment}-int-nlb"
  load_balancer_type = "network"
  internal           = true
  subnets            = var.private_subnets
}

resource "aws_lb_target_group" "this" {
  for_each = var.services

  name        = "${var.app_name}-${var.environment}-${each.key}-tg"
  port        = each.value.container_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "this" {
  for_each = var.services

  load_balancer_arn = aws_lb.internal.arn
  port              = each.value.lb_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }
}