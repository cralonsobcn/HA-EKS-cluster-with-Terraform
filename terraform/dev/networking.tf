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
  map_public_ip_on_launch = false  # Ensures public IP assignme
  availability_zone = "us-east-1a"
  tags = {
    Name = "aws-vpc-dataplane-subnet-a"
  }
}

# Create regional subnet B
resource "aws_subnet" "aws-vpc-dataplane-subnet-b" {
  depends_on        = [aws_vpc.aws-vpc-dataplane]
  vpc_id            = aws_vpc.aws-vpc-dataplane.id
  cidr_block        = var.dataplane-subnet-b-cidr
  map_public_ip_on_launch = false  # Ensures public IP assignme
  availability_zone = "us-east-1b"
  tags = {
    Name = "aws-vpc-dataplane-subnet-b"
  }
}

# Create regional subnet C
resource "aws_subnet" "aws-vpc-dataplane-subnet-c" {
  depends_on        = [aws_vpc.aws-vpc-dataplane]
  vpc_id            = aws_vpc.aws-vpc-dataplane.id
  cidr_block        = var.dataplane-subnet-c-cidr
  map_public_ip_on_launch = false  # Ensures public IP assignment
  availability_zone = "us-east-1c"
  tags = {
    Name = "aws-vpc-dataplane-subnet-c"
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
# Create Ingress rule to everywhere
resource "aws_security_group_rule" "aws-vpc-dataplane-sc-ingress-all" {
  type              = "ingress"
  depends_on        = [aws_security_group.aws-vpc-dataplane-sc]
  description       = "Allows all connections from everywhere"
  from_port         = 0
  to_port           = 0    # semantically equivalent to all ports
  protocol          = "-1" # semantically equivalent to all protocols
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
  route {
    cidr_block = aws_default_vpc.aws-vpc-controlplane.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.controlplane-dataplane-peering.id
  }
  tags = {
    Name = "aws-vpc-dataplane-rt"
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

# Associates the default VPC with the EKS controlplane
resource "aws_default_vpc" "aws-vpc-controlplane" {
  tags = {
    Name = "Default VPC"
  }
}

# Associates the default subnet-a with the EKS controlplane
resource "aws_default_subnet" "aws-vpc-controlplane-subnet-a" {
  availability_zone = "us-east-1a"
  tags = {
    Name = "aws-vpc-controlplane-subnet-a"
  }
}

# Associates the default subnet-b with the EKS controlplane
resource "aws_default_subnet" "aws-vpc-controlplane-subnet-b" {
  availability_zone = "us-east-1b"
  tags = {
    Name = "aws-vpc-controlplane-subnet-b"
  }
}

# Associates the default subnet-c with the EKS controlplane
resource "aws_default_subnet" "aws-vpc-controlplane-subnet-c" {
  availability_zone = "us-east-1c"
  tags = {
    Name = "aws-vpc-controlplane-subnet-c"
  }
}

# Default IW attached to the Default VPC
data "aws_internet_gateway" "default_internet_gateway" {
  filter {
    name   = "attachment.vpc-id"
    values = [aws_default_vpc.aws-vpc-controlplane.id]
  }
}

# Sets the default route table 
resource "aws_default_route_table" "aws-vpc-controlplane-rt" {
  default_route_table_id = aws_default_vpc.aws-vpc-controlplane.default_route_table_id
  depends_on = [aws_default_vpc.aws-vpc-controlplane]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default_internet_gateway.id # Maps the default IGW
  }
  route {
    cidr_block = aws_default_vpc.aws-vpc-controlplane.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = aws_vpc.aws-vpc-dataplane.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.controlplane-dataplane-peering.id
  }
  tags = {
    Name = "Routing Table for aws-vpc-controlplane"
  }
}

# Associate the controlplane routing table with its subnet-a
resource "aws_route_table_association" "aws-vpc-controlplane-rt-association-a" {
  depends_on     = [aws_default_route_table.aws-vpc-controlplane-rt]
  subnet_id      = aws_default_subnet.aws-vpc-controlplane-subnet-a.id
  route_table_id = aws_default_route_table.aws-vpc-controlplane-rt.id
}

# Associate the controlplane routing table with its subnet-b
resource "aws_route_table_association" "aws-vpc-controlplane-rt-association-b" {
  depends_on     = [aws_default_route_table.aws-vpc-controlplane-rt]
  subnet_id      = aws_default_subnet.aws-vpc-controlplane-subnet-b.id
  route_table_id = aws_default_route_table.aws-vpc-controlplane-rt.id
}

# Associate the controlplane routing table with its subnet-b
resource "aws_route_table_association" "aws-vpc-controlplane-rt-association-c" {
  depends_on     = [aws_default_route_table.aws-vpc-controlplane-rt]
  subnet_id      = aws_default_subnet.aws-vpc-controlplane-subnet-c.id
  route_table_id = aws_default_route_table.aws-vpc-controlplane-rt.id
}

# Create security group to be attached to the controlplane VPC
resource "aws_default_security_group" "aws-vpc-controlplane-sc" {
  vpc_id      = aws_default_vpc.aws-vpc-controlplane.id
  tags = {
    Name = "aws-vpc-controlplane-sc"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## ( -- EKS VPC Peering -- )
resource "aws_vpc_peering_connection" "controlplane-dataplane-peering" {
  peer_owner_id = data.aws_caller_identity.account_id.account_id # Gets the AWS Account ID from variables.aws_caller_identity
  depends_on = [ aws_default_vpc.aws-vpc-controlplane, aws_vpc.aws-vpc-dataplane ]
  peer_vpc_id   = aws_vpc.aws-vpc-dataplane.id
  vpc_id        = aws_default_vpc.aws-vpc-controlplane.id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between the EKS Controlplane and the Dataplane"
  }
}
