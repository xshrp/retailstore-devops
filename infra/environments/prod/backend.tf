terraform {
  backend "s3" {
    bucket = "devops-retail-gj-bucket-prod"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
