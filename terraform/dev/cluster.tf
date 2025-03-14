resource "aws_eks_cluster" "eks-cluster" {
  name = var.eks-cluster-name

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  role_arn = aws_iam_role.eks-cluster-role.arn
  version  = "1.31"

  vpc_config {
    subnet_ids = [aws_subnet.aws-vpc-controlplane-subnet-a.id, aws_subnet.aws-vpc-controlplane-subnet-b.id]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [aws_iam_role_policy_attachment.eks-cluster-role-AmazonEKSClusterPolicy]

  tags = {
    Name = var.eks-cluster-name
  }
}