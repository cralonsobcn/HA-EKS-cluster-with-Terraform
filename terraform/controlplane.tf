resource "aws_eks_cluster" "eks-cluster" {
  name = var.eks-cluster-name
  
  # Disable EKS Auto Mode
  compute_config {
    enabled = false
  }
  kubernetes_network_config {
    elastic_load_balancing {
      enabled = false
    }
  }
  storage_config {
    block_storage {
      enabled = false
    }
  }

  # Sets access configuration to API and configMap
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = aws_iam_role.eks-cluster-role.arn
  version  = var.controlplane-kubernetes-version

  # Sets the subnets to be used by the EKS Controlplane
  vpc_config {
    subnet_ids = [aws_default_subnet.aws-vpc-controlplane-subnet-a.id, aws_default_subnet.aws-vpc-controlplane-subnet-b.id, aws_default_subnet.aws-vpc-controlplane-subnet-c.id]
    security_group_ids = [aws_default_security_group.aws-vpc-controlplane-sc.id]
  }

  # Deploy the EKS Controlplane only if the VPC and the cluster role are created 
  depends_on = [aws_iam_role.eks-cluster-role, aws_iam_role_policy_attachment.eks-cluster-role-AmazonEKSClusterPolicy, aws_default_vpc.aws-vpc-controlplane]

  tags = {
    Name = var.eks-cluster-name
  }
}

# aws eks update-kubeconfig --region region-code --name my-cluster