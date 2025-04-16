terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90"
    }
  }

  backend "s3" {
    bucket = "cralonso-tf-eks-project"
    key    = "terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true # S3 State locking
  }
}

provider "aws" {
  region = var.aws_region
}