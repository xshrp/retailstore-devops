resource "aws_ecs_cluster" "this" {
  name = "${var.app_name}-${var.environment}"
}

resource "aws_security_group" "ecs" {
  name   = "${var.app_name}-${var.environment}-ecs-sg"
  vpc_id = var.vpc_id

  # UI
  ingress {
    from_port                = 8080
    to_port                  = 8080
    protocol                 = "tcp"
    security_groups  = [var.alb_security_group_id]
  }

  # ADMIN
  ingress {
    from_port                = 8081
    to_port                  = 8081
    protocol                 = "tcp"
    security_groups  = [var.alb_security_group_id]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}