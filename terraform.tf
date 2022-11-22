terraform {
  required_version = ">=0.12"
  backend "s3" {
    encrypt        = true
    bucket         = "sortlog-tf-1-11-2022"
    key            = "./sortlog-front/terraform.tfstate"
    region         = "ap-southeast-2"
    profile        = "default"
    dynamodb_table = "terraform-state-lock-sortlog"
  }
}

provider "aws" {
  region  = var.region
  # shared_credentials_files = "$HOME/.aws/credentials"
  # profile = var.aws_profile
}
