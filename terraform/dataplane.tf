# Elaborates the template that will be used by each worker node of the dataplane
resource "aws_launch_template" "dataplane-node-template" {
  name = "dataplane-node-template"
  description = "Template to be used when setting up a dataplane node"
  depends_on = [ aws_eks_cluster.eks-cluster, aws_vpc.aws-vpc-dataplane, aws_key_pair.dataplane-kp, aws_iam_instance_profile.node_instance_profile]

  image_id = data.aws_ssm_parameter.node_ami.value # AMAZON Linux 2023 x64
  
  instance_initiated_shutdown_behavior = "terminate"

  key_name = aws_key_pair.dataplane-kp.key_name # Maps the EC2 template with the key pair

  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.aws-vpc-dataplane-sc.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 30
      volume_type           = "gp2"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.node_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "dataplane-node-template"
    }
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record = true
  } 
  user_data = filebase64("${path.module}/userdata.sh")
}

# Creates the autoscaling group with the worker nodes that forms the dataplane
resource "aws_autoscaling_group" "dataplane-group" {
  depends_on = [ aws_launch_template.dataplane-node-template ]
  desired_capacity   = 3
  max_size           = 3
  min_size           = 2
  vpc_zone_identifier = [ aws_subnet.aws-vpc-dataplane-subnet-a.id, aws_subnet.aws-vpc-dataplane-subnet-b.id, aws_subnet.aws-vpc-dataplane-subnet-c.id]

  launch_template {
    id      = aws_launch_template.dataplane-node-template.id
    version = "$Latest"
  }
}

# Dataplane key pair. Pulls public key from the variable which in turn pulls it from env variable
resource "aws_key_pair" "dataplane-kp" {
  key_name   = "dataplane-kp"
  public_key = var.dataplane_public_key
}

# Outputs the arn of the role that will be used in the ConfigMap aws-auth-cm.yaml later
output "dataplane-role-arn" {
  depends_on = [ aws_iam_role.node_instance_role ]
  value = aws_iam_role.node_instance_role.arn
}