data "aws_iam_role" "labrole" {
  name = "LabRole"
}

data "aws_region" "current" {}
