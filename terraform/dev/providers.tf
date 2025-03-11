terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.90"
    }
  }
  backend "s3" {
    bucket = var.s3_state_backend
    key    = "path/to/my/key"
    region = var.region
  }
}

provider "aws" {
  region = var.aws_region
  secret_key = var.aws_secret_key 
  access_key = var.aws_access_key # Enables access to AWS --> S3 Bucket
}