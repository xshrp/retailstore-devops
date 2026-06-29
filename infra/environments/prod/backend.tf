terraform {
  backend "s3" {
    bucket = "devops-retail-gj-bucket-TODO"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
