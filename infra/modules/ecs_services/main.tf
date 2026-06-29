resource "aws_cloudwatch_log_group" "this" {
  for_each = var.services

  name              = "/ecs/${var.app_name}-${var.environment}/${each.key}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  for_each = var.services

  family                   = "${var.app_name}-${var.environment}-${each.key}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = each.value.cpu
  memory = each.value.memory

  execution_role_arn = data.aws_iam_role.labrole.arn
  task_role_arn      = data.aws_iam_role.labrole.arn

  container_definitions = jsonencode([
    merge(
      {
        name      = each.key
        image     = each.value.image
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

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = aws_cloudwatch_log_group.this[each.key].name
            "awslogs-region"        = data.aws_region.current.name
            "awslogs-stream-prefix" = each.key
          }
        }
      },
      length(each.value.command) > 0 ? { command = each.value.command } : {},
      length(each.value.entry_point) > 0 ? { entryPoint = each.value.entry_point } : {}
    )
  ])
}

resource "aws_ecs_service" "this" {
  for_each = var.services

  name            = each.key
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.this[each.key].arn

  launch_type   = "FARGATE"
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
    for_each = lookup(var.target_groups, each.key, null) != null ? [1] : []

    content {
      target_group_arn = var.target_groups[each.key]
      container_name    = each.key
      container_port    = each.value.port
    }
  }

  dynamic "load_balancer" {
    for_each = lookup(var.internal_target_groups, each.key, null) != null ? [1] : []

    content {
      target_group_arn = var.internal_target_groups[each.key]
      container_name    = each.key
      container_port    = each.value.port
    }
  }
}