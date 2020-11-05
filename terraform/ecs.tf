resource "aws_ecs_cluster" "redmine" {
  name = "redmine-${terraform.workspace}"
}

resource "aws_iam_role_policy" "rds_access_policy" {
  name = "redmine_rds_access_policy_${terraform.workspace}"
  role = aws_iam_role.ecs_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "rds:*"
        ],
        "Effect": "Allow",
        "Resource": "${aws_db_instance.redmine.arn}"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "ecs_access_policy" {
  name = "redmine_ecs_access_policy_${terraform.workspace}"
  role = aws_iam_role.ecs_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
               "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role" "ecs_role" {
  name = "redmine_ecs_role_${terraform.workspace}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
