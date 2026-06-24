terraform {
  backend "s3" {
    bucket = "devops-retail-gj-bucket"
    key    = "test/terraform.tfstate"
    region = "us-east-1"
  }
}