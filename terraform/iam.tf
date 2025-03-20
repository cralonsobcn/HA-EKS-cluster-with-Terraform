## ( -- IAM EKS Controlplane -- ) ##
resource "aws_iam_role" "eks-cluster-role" {
  name               = "eksClusterRole"
  assume_role_policy = data.aws_iam_policy_document.eks-cluster-policy-role.json # Retrieves the policy docuemnt
  tags = {
    Name = "eksClusterRole"
  }
}

resource "aws_iam_role_policy_attachment" "eks-cluster-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" # Retrives the specific EKS policy 
  role       = aws_iam_role.eks-cluster-role.name
}

data "aws_iam_policy_document" "eks-cluster-policy-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

## ( -- IAM EKS Dataplane -- )
resource "aws_iam_role" "node_instance_role" {
  name               = "eksWorkerNodeRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
  # path               = "/"
}

# Instance profile to associate above role with worker nodes
resource "aws_iam_instance_profile" "node_instance_profile" {
  name = "NodeInstanceProfile"
  path = "/"
  role = aws_iam_role.node_instance_role.id
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly, AmazonSSMManagedInstanceCore
resource "aws_iam_role_policy_attachment" "node_instance_role_EKSWNP" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_instance_role.name
}

resource "aws_iam_role_policy_attachment" "node_instance_role_EKSCNIP" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_instance_role.name
}

resource "aws_iam_role_policy_attachment" "node_instance_role_EKSCRRO" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_instance_role.name
}

resource "aws_iam_role_policy_attachment" "node_instance_role_SSMMIC" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node_instance_role.name
}