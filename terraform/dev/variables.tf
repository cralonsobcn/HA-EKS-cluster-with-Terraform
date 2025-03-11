## ( -- AWS Config -- )
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  sensitive   = false
  description = "Default AWS region to deploy resources"
}

## ( -- Networking -- )
variable "vpc-name" { # TODO
    default = "pipeline-tf-aws-vpc"
    description = "Name assigend to the VPC"
}

variable "vpc-cidr" {
  default = "200.200.0.0/24"
  description = "CIDR block assigned to the VPC"
}

## ( -- AWS CodePipeline -- )
## ( -- AWS ECR -- )
## ( -- AWS EKS -- )
## ( -- AWS  -- )

