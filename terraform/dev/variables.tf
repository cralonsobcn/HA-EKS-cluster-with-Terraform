## ( -- AWS Config -- )
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  sensitive   = false
  description = "Default AWS region to deploy resources"
}

## ( -- AWS Networking -- )
variable "vpc-name" { # TODO
  type = string
  default = "pipeline-tf-aws-vpc"
  description = "Name assigend to the VPC"
}

variable "vpc-cidr" {
  type = string
  default = "10.0.0.0/16"
  description = "CIDR block assigned to the VPC"
}

variable "subnet-a-cidr" {
  type = string
  default = "10.0.1.0/24"
  description = "CIDR block assigned to the subnet aws-vpc-subnet-a"
}

variable "subnet-b-cidr" {
  type = string
  default = "10.0.2.0/24"
  description = "CIDR block assigned to the subnet aws-vpc-subnet-b"  
}

variable "subnet-c-cidr" {
  type = string
  default = "10.0.3.0/24"
  description = "CIDR block assigned to the subnet aws-vpc-subnet-c" 
}

## ( -- AWS EKS -- )
variable "eks-cluster-name" {
  type = string
  default = "eks-cluster"
  description = "Name of the EKS Cluster Role"
}

variable "eks-nodeGroup-name" {
  type = string
  default = "eks-mig"
  description = "Name of the EKS Cluster Role"
}

## ( -- AWS CodePipeline -- )
## ( -- AWS ECR -- )
## ( -- AWS EKS -- )


