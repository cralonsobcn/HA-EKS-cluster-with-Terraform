## ( -- AWS Config -- )
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  sensitive   = false
  description = "Default AWS region to deploy resources"
}

variable "aws_access_key" {
  type = string
  default = "" # TODO
  sensitive = true
  description = "Access Key to allow Terraform connect to AWS" 
}

variable "aws_secret_key" {
  type = string
  default = "" # TODO
  sensitive = true
  description = "Secret  Key to allow Terraform connect to AWS"
}

## ( -- Networking -- )
variable "vpc-name" {
    default = ""
    description = "Name assigend to the VPC"
}

variable "vpc-cidr" {
  default = "192.168.0.0/24"
  description = "CIDR block assigned to the VPC"
}

## ( -- AWS CodePipeline -- )
## ( -- AWS ECR -- )
## ( -- AWS EKS -- )
## ( -- AWS  -- )

