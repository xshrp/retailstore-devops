resource "aws_eks_cluster" "this" {
  name     = "${var.app_name}-${var.environment}-eks"
  role_arn = var.labrole_arn

  vpc_config {
    subnet_ids              = concat(var.private_subnets, var.public_subnets)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-eks"
    App         = var.app_name
    Environment = var.environment
  }
}