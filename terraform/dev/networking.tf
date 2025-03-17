## ( -- EKS Dataplane -- )

# Create a VPC
resource "aws_vpc" "aws-vpc-dataplane" {
  cidr_block                           = var.vpc-dataplane-cidr
  enable_dns_hostnames                 = true  # A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false.
  enable_dns_support                   = true  # A boolean flag to enable/disable DNS support in the VPC. Defaults to true.
  enable_network_address_usage_metrics = false # BILLING. Indicates whether Network Address Usage metrics are enabled for your VPC.
  tags = {
    Name = var.vpc-dataplane-name
  }
}

# Create regional subnet A
resource "aws_subnet" "aws-vpc-dataplane-subnet-a" {
  depends_on        = [aws_vpc.aws-vpc-dataplane]
  vpc_id            = aws_vpc.aws-vpc-dataplane.id
  cidr_block        = var.dataplane-subnet-a-cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = "aws-vpc-subnet-a"
  }
}

# Create regional subnet B
resource "aws_subnet" "aws-vpc-dataplane-subnet-b" {
  depends_on        = [aws_vpc.aws-vpc-dataplane]
  vpc_id            = aws_vpc.aws-vpc-dataplane.id
  cidr_block        = var.dataplane-subnet-b-cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = "aws-vpc-subnet-b"
  }
}

# Create regional subnet C
resource "aws_subnet" "aws-vpc-dataplane-subnet-c" {
  depends_on        = [aws_vpc.aws-vpc-dataplane]
  vpc_id            = aws_vpc.aws-vpc-dataplane.id
  cidr_block        = var.dataplane-subnet-c-cidr
  availability_zone = "us-east-1c"
  tags = {
    Name = "aws-vpc-subnet-c"
  }
}

# Create security group to be attached to the dataplane VPC
resource "aws_security_group" "aws-vpc-dataplane-sc" {
  name        = "aws-vpc-dataplane-sc"
  description = "Security group for aws-vpc"
  vpc_id      = aws_vpc.aws-vpc-dataplane.id
  tags = {
    Name = "aws-vpc-dataplane-sc"
  }
}

# Create HTTP Ingress rule
resource "aws_security_group_rule" "aws-vpc-dataplane-sc-ingress-http" {
  type              = "ingress"
  depends_on        = [aws_security_group.aws-vpc-dataplane-sc]
  description       = "Allows HTTP connections from everywhere"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-vpc-dataplane-sc.id
}

# Create HTTPS Ingress rule
resource "aws_security_group_rule" "aws-vpc-dataplane-sc-ingress-https" {
  type              = "ingress"
  depends_on        = [aws_security_group.aws-vpc-dataplane-sc]
  description       = "Allows HTTPS connections from everywhere"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-vpc-dataplane-sc.id
}

# Create SSH Ingress rule
resource "aws_security_group_rule" "aws-vpc-dataplane-sc-ingress-ssh" {
  type              = "ingress"
  depends_on        = [aws_security_group.aws-vpc-dataplane-sc]
  description       = "Allows SSH connections from everywhere"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-vpc-dataplane-sc.id
}

# Create MySQL Ingress rule
resource "aws_security_group_rule" "aws-vpc-dataplane-sc-ingress-mysql" {
  type              = "ingress"
  depends_on        = [aws_security_group.aws-vpc-dataplane-sc]
  description       = "Allows MySQL connections from everywhere"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-vpc-dataplane-sc.id
}

# Create Egress rule to everywhere
resource "aws_security_group_rule" "aws-vpc-dataplane-sc-egress-all" {
  type              = "egress"
  depends_on        = [aws_security_group.aws-vpc-dataplane-sc]
  description       = "Allows all connections from the VPC to the internet"
  from_port         = 0
  to_port           = 0    # semantically equivalent to all ports
  protocol          = "-1" # semantically equivalent to all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-vpc-dataplane-sc.id
}

# Create an Internet Gateway IGW to the route table and then attach the Route table to the VPC
resource "aws_internet_gateway" "aws-vpc-dataplane-gw" { # It's recommended to denote that the AWS Instance or Elastic IP depends on the Internet Gateway. For example:
  vpc_id     = aws_vpc.aws-vpc-dataplane.id
  depends_on = [aws_vpc.aws-vpc-dataplane]
  tags = {
    Name = "aws-vpc-dataplane-gw"
  }
}

# Create a Routing table and add the VPC CIDR + Internet Gateway Routes
resource "aws_route_table" "aws-vpc-dataplane-rt" {
  vpc_id     = aws_vpc.aws-vpc-dataplane.id
  depends_on = [aws_internet_gateway.aws-vpc-dataplane-gw]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-vpc-dataplane-gw.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    Name = "Routing Table for aws-vpc-dataplane"
  }
}

# Associate the routing table with aws-vpc-subnet-a
resource "aws_route_table_association" "aws-vpc-dataplane-rt-association-a" {
  depends_on     = [aws_route_table.aws-vpc-dataplane-rt]
  subnet_id      = aws_subnet.aws-vpc-dataplane-subnet-a.id
  route_table_id = aws_route_table.aws-vpc-dataplane-rt.id
}

# Associate the routing table with aws-vpc-subnet-b
resource "aws_route_table_association" "aws-vpc-dataplane-rt-association-b" {
  depends_on     = [aws_route_table.aws-vpc-dataplane-rt]
  subnet_id      = aws_subnet.aws-vpc-dataplane-subnet-b.id
  route_table_id = aws_route_table.aws-vpc-dataplane-rt.id
}

# Associate the routing table with aws-vpc-subnet-b
resource "aws_route_table_association" "aws-vpc-dataplane-rt-association-c" {
  depends_on     = [aws_route_table.aws-vpc-dataplane-rt]
  subnet_id      = aws_subnet.aws-vpc-dataplane-subnet-c.id
  route_table_id = aws_route_table.aws-vpc-dataplane-rt.id
}

## ( -- EKS Control Plane -- )

resource "aws_default_vpc" "aws-vpc-controlplane" {

  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "aws-vpc-controlplane-subnet-a" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-west-1a. Controlplane VPC"
  }
}

resource "aws_default_subnet" "aws-vpc-controlplane-subnet-b" {
  availability_zone = "us-east-1b"

  tags = {
    Name = "Default subnet for us-west-1b"
  }
}

# Create security group to be attached to the controlplane VPC
resource "aws_security_group" "aws-vpc-controlplane-sc" {
  name        = "aws-vpc-controlplane-sc"
  description = "Security group for aws-vpc-controlplane"
  vpc_id      = aws_default_vpc.aws-vpc-controlplane.id
  tags = {
    Name = "aws-vpc-controlplane-sc"
  }
}