resource "aws_vpc" "aws-vpc" {
  cidr_block = var.vpc-cidr
  enable_dns_hostnames = true # A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false.
  enable_dns_support = true # A boolean flag to enable/disable DNS support in the VPC. Defaults to true.
  enable_network_address_usage_metrics = false # BILLING. Indicates whether Network Address Usage metrics are enabled for your VPC.
  tags = {
    Name = var.vpc-name
  }
}

# Current best practice of the aws_vpc_security_group_egress_rule and aws_vpc_security_group_ingress_rule resources with one CIDR block per rule.
resource "aws_security_group" "aws-vpc-sc" {
  name        = "allow HTTP"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.aws-vpc.id
}

resource "aws_security_group_rule" "aws-vpc-sc-ingress" {
  type              = "ingress"
  description = "Allows HTTP, HTTPS and SSH connections from the internet"
  from_port         = [80, 443, 22]
  to_port           = [80, 443, 22]
  protocol          = "tcp"
  cidr_blocks       = "0.0.0.0/0"
  security_group_id = aws_security_group.aws-vpc-sc.id
}

resource "aws_security_group_rule" "aws-vpc-sc-egress-http" {
  type              = "egress"
  description = "Allows all connections from the VPC to the internet"
  from_port         = "-1" # semantically equivalent to all ports
  to_port           = "-1" # semantically equivalent to all ports
  protocol          = "tcp"
  cidr_blocks       = "0.0.0.0/0"
  security_group_id = aws_security_group.aws-vpc-sc.id
}

resource "aws_eip" "elastic_ip" {

}