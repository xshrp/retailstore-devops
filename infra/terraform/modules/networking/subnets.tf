resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.app_name}-${var.environment}-public-${count.index + 1}"
    App                      = var.app_name
    Environment              = var.environment
    Type                     = "public"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name                              = "${var.app_name}-${var.environment}-private-${count.index + 1}"
    App                               = var.app_name
    Environment                       = var.environment
    Type                              = "private"
    "kubernetes.io/role/internal-elb" = "1"
  }
}