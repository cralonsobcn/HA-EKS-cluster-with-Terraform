resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.id
  node_group_name = var.eks-nodeGroup-name
  node_role_arn   = aws_iam_role.eks-nodeGroup-role.arn # TODO
  subnet_ids      = [aws_subnet.aws-vpc-subnet-a, aws_subnet.aws-vpc-subnet-b, aws_subnet.aws-vpc-subnet-c] 
  ami_type = "AL2_x86_64"
  disk_size = "2" # Disk size in GiB for worker nodes. Defaults to 50
  instance_types = "t2.micro"

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-nodeGroup-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-nodeGroup-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-nodeGroup-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name = var.eks-nodeGroup-name
  }
}