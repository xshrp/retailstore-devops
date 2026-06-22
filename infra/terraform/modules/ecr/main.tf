resource "aws_ecr_repository" "repos" {
  for_each = toset(var.service_names)

  name = "${var.app_name}/${var.environment}/${each.key}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    App         = var.app_name
    Environment = var.environment
    Service     = each.key
  }
}