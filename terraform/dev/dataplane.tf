# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "dataplane-node-template" {
  name = "dataplane-node-template"
  description = "Template to be used when setting up a dataplane node"
  depends_on = [ aws_eks_cluster.eks-cluster, aws_vpc.aws-vpc-dataplane, aws_key_pair.dataplane-kp, aws_iam_instance_profile.node_instance_profile]
  image_id = var.dataplane-ami # AMAZON Linux 2023 x64

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

  user_data = filebase64("${path.module}/userdata.sh")
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
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

# Do not hardcode public key here
resource "aws_key_pair" "dataplane-kp" {
  key_name   = "dataplane-kp"
  public_key = ""
}