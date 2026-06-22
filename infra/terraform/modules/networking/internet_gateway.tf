resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.app_name}-${var.environment}-igw"
    App         = var.app_name
    Environment = var.environment
  }
}