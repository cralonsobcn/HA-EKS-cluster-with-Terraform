# Create an AWS VPC for the project
resource "aws_vpc" "aws-vpc" {
  cidr_block = var.vpc-cidr
  enable_dns_hostnames = true # A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false.
  enable_dns_support = true # A boolean flag to enable/disable DNS support in the VPC. Defaults to true.
  enable_network_address_usage_metrics = false # BILLING. Indicates whether Network Address Usage metrics are enabled for your VPC.
  tags = {
    Name = var.vpc-name
  }
}

# Create regional subnet A
resource "aws_subnet" "aws-vpc-subnet-a" {
  depends_on = [ aws_vpc.aws-vpc ]
  vpc_id     = aws_vpc.aws-vpc.id
  cidr_block = var.subnet-a-cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = "aws-vpc-subnet-a"
  }
}

# Create regional subnet B
resource "aws_subnet" "aws-vpc-subnet-b" {
  depends_on = [ aws_vpc.aws-vpc ]
  vpc_id     = aws_vpc.aws-vpc.id
  cidr_block = var.subnet-b-cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = "aws-vpc-subnet-b"
  }
}

# Create regional subnet C
resource "aws_subnet" "aws-vpc-subnet-c" {
  depends_on = [ aws_vpc.aws-vpc ]
  vpc_id     = aws_vpc.aws-vpc.id
  cidr_block = var.subnet-c-cidr
  availability_zone = "us-east-1c"
  tags = {
    Name = "aws-vpc-subnet-c"
  }
}

# Create security group to be attached to the VPC
resource "aws_security_group" "aws-vpc-sc" {
  name        = "aws-vpc-sc"
  description = "Security group for aws-vpc"
  vpc_id      = aws_vpc.aws-vpc.id
  tags = {
    Name = "aws-vpc-sc"
  }
}

# Create HTTP Ingress rule
resource "aws_security_group_rule" "aws-vpc-sc-ingress-http" {
  type              = "ingress"
  description = "Allows HTTP connections from everywhere"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-vpc-sc.id
}

# Create HTTPS Ingress rule
resource "aws_security_group_rule" "aws-vpc-sc-ingress-https" {
  type              = "ingress"
  description = "Allows HTTPS connections from everywhere"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-vpc-sc.id
}

# Create SSH Ingress rule
resource "aws_security_group_rule" "aws-vpc-sc-ingress-ssh" {
  type              = "ingress"
  description = "Allows SSH connections from everywhere"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-vpc-sc.id
}

# Create MySQL Ingress rule
resource "aws_security_group_rule" "aws-vpc-sc-ingress-mysql" {
  type              = "ingress"
  description = "Allows MySQL connections from everywhere"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-vpc-sc.id
}

# Create Egress rule to everywhere
resource "aws_security_group_rule" "aws-vpc-sc-egress-all" {
  type              = "egress"
  description = "Allows all connections from the VPC to the internet"
  from_port         = 0
  to_port           = 0 # semantically equivalent to all ports
  protocol          = "-1" # semantically equivalent to all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-vpc-sc.id
}

# Create an Internet Gateway IGW to the route table and then attach the Route table to the VPC
resource "aws_internet_gateway" "aws-vpc-gw" { # It's recommended to denote that the AWS Instance or Elastic IP depends on the Internet Gateway. For example:
  vpc_id = aws_vpc.aws-vpc.id
  depends_on = [ aws_vpc.aws-vpc ]
  tags = {
    Name = "aws-vpc-gw"
  }
}

# Create a Routing table and add the VPC CIDR + Internet Gateway Routes
resource "aws_route_table" "aws-vpc-rt" {
  vpc_id = aws_vpc.aws-vpc.id
  depends_on = [ aws_internet_gateway.aws-vpc-gw ]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-vpc-gw.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    Name = "Routing Table for aws-vpc"
  }
}

# Associate the routing table with aws-vpc-subnet-a
resource "aws_route_table_association" "aws-vpc-rt-association-a" {
  depends_on = [ aws_route_table.aws-vpc-rt ]
  subnet_id      = aws_subnet.aws-vpc-subnet-a.id
  route_table_id = aws_route_table.aws-vpc-rt.id
}

# Associate the routing table with aws-vpc-subnet-b
resource "aws_route_table_association" "aws-vpc-rt-association-b" {
  depends_on = [ aws_route_table.aws-vpc-rt ]
  subnet_id      = aws_subnet.aws-vpc-subnet-b.id
  route_table_id = aws_route_table.aws-vpc-rt.id
}

# Associate the routing table with aws-vpc-subnet-b
resource "aws_route_table_association" "aws-vpc-rt-association-c" {
  depends_on = [ aws_route_table.aws-vpc-rt ]
  subnet_id      = aws_subnet.aws-vpc-subnet-c.id
  route_table_id = aws_route_table.aws-vpc-rt.id
}