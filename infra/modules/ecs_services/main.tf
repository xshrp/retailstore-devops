resource "aws_ecs_task_definition" "this" {
  for_each = var.services

  family                   = each.key
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = each.value.cpu
  memory = each.value.memory

  execution_role_arn = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name  = each.key
      image = each.value.image

      essential = true

      portMappings = [
        {
          containerPort = each.value.port
          protocol      = "tcp"
        }
      ]

      environment = [
        for k, v in each.value.environment :
        {
          name  = k
          value = v
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "this" {
  for_each = var.services

  name            = each.key
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.this[each.key].arn

  launch_type = "FARGATE"
  desired_count = 1

  network_configuration {
    subnets = (
      lookup(each.value, "public", false)
      ? var.public_subnets
      : var.private_subnets
    )
    security_groups = [var.security_group_id]

    assign_public_ip = lookup(each.value, "public", false)
  }

  dynamic "load_balancer" {
    for_each = lookup(each.value, "public", false) ? [1] : []

    content {
      target_group_arn = var.target_groups[each.key]
      container_name   = each.key
      container_port   = each.value.port
    }
  }
}