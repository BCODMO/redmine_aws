data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "redmine-${terraform.workspace}-ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "redmine-${terraform.workspace}-ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_launch_template" "redmine" {
  name          = "redmine-${terraform.workspace}-launch-config"
  image_id      = "ami-00eb0dc604a8124fd"
  instance_type = "t2.micro"
  user_data     = base64encode("#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.redmine.name} >> /etc/ecs/ecs.config")
  network_interfaces {
    security_groups = [aws_security_group.redmine.id]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_agent.name
  }
}


resource "aws_autoscaling_group" "redmine" {
  name                = "redmine-${terraform.workspace}-asg"
  vpc_zone_identifier = [aws_default_subnet.default_1a.id, aws_default_subnet.default_1b.id]
  launch_template {
    id = aws_launch_template.redmine.id
    version = "$Latest"
  }

  desired_capacity          = 1
  min_size                  = 0
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
}

