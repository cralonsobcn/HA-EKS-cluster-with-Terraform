# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "dataplane-node-template" {
  name = "dataplane-node-template"
  description = "Template to be used when setting up a dataplane node"

  image_id = "AL2_x86_64"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

  placement {
    availability_zone = "us-west-2a"
  }

  vpc_security_group_ids = [aws_security_group.aws-vpc-dataplane-sc.id]

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
  desired_capacity   = 3
  max_size           = 3
  min_size           = 2
  vpc_zone_identifier = [ aws_subnet.aws-vpc-dataplane-subnet-a.id, aws_subnet.aws-vpc-dataplane-subnet-abid, aws_subnet.aws-vpc-dataplane-subnet-c.id]

  launch_template {
    id      = aws_launch_template.dataplane-node-template.id
    version = "$Latest"
  }
}