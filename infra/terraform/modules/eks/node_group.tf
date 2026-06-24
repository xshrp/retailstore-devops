resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.app_name}-${var.environment}-ng"

  node_role_arn = var.labrole_arn

  subnet_ids = var.private_subnets

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  instance_types = [var.node_instance_type]

  labels = {
    environment = var.environment
  }

  depends_on = [
    aws_eks_cluster.this
  ]

  tags = {
    App         = var.app_name
    Environment = var.environment
  }
}