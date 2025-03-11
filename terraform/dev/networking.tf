resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr
  enable_dns_hostnames = true # A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false.
  enable_dns_support = true # A boolean flag to enable/disable DNS support in the VPC. Defaults to true.
  enable_network_address_usage_metrics = false # BILLING. Indicates whether Network Address Usage metrics are enabled for your VPC.
  tags = {
    name = var.vpc-name
  }
}

# Current best practice of the aws_vpc_security_group_egress_rule and aws_vpc_security_group_ingress_rule resources with one CIDR block per rule.
resource "aws_security_group" "name" {
  
}

resource "aws_eip" "elastic_ip" {
  
}