resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_1a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_1b" {
  availability_zone = "us-east-1b"
}

resource "aws_security_group" "redmine" {
  name        = "redmine-ecs-${terraform.workspace}"
  description = "Created by Terraform"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description     = "Allow submission tool access"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.submission_default_security_group_id, var.submission_prod_security_group_id]
  }

  ingress {
    description = "Access all from WHOI"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.whoi_ip]
  }

  ingress {
    description = "All ingress for self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = "true"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    ignore_changes = [ingress]
  }
}

