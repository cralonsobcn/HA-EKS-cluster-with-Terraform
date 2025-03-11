# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role#attribute-reference
resource "aws_iam_role" "eksClusterRole" {
  name               = var.eks-cluster-role-name
  assume_role_policy = data.aws_iam_policy_document.policy-role-eks.json
  tags = {
    Name = var.eks-cluster-role-name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment
resource "aws_iam_role_policy_attachment" "eksClusterRole_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksClusterRole.name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "policy-role-eks" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}