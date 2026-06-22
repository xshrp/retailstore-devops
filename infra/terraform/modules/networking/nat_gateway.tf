resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.app_name}-${var.environment}-nat-eip"
    App         = var.app_name
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public[0].id

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name        = "${var.app_name}-${var.environment}-nat"
    App         = var.app_name
    Environment = var.environment
  }
}