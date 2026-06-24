terraform {
  backend "s3" {
    bucket = "devops-retail-gj-bucket"
    key    = "develop/terraform.tfstate"
    region = "us-east-1"
  }
}