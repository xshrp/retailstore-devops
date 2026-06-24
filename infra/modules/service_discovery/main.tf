resource "aws_service_discovery_private_dns_namespace" "this" {
  name = "${var.app_name}-${var.environment}.local"
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "this" {
  for_each = toset(var.services)

  name = each.key

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
