resource "aws_ecr_repository" "d2rq" {
  name                 = "redmine_d2rq_${terraform.workspace}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "d2rq" {
  name              = "/ecs/redmine_d2rq_${terraform.workspace}"
  retention_in_days = "7"

}


resource "aws_ecs_task_definition" "d2rq" {
  family                = "redmine_d2rq_${terraform.workspace}"
  container_definitions = <<EOF
[
    {
        "name": "redmine_d2rq_container_${terraform.workspace}",
        "image": "${aws_ecr_repository.d2rq.repository_url}:latest",
        "memoryReservation": 256,
        "cpu": 512,
        "portMappings": [
            {
                "containerPort": 2020
            }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.d2rq.name}",
                "awslogs-region": "us-east-1",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "environment": [
            {
                "name": "REDMINE_DB_MYSQL",
                "value": "${aws_db_instance.redmine.address}"
            },
            {
                "name": "REDMINE_DB_PORT",
                "value": "${aws_db_instance.redmine.port}"
            },
            {
                "name": "REDMINE_DB_USERNAME",
                "value": "${aws_db_instance.redmine.username}"
            },
            {
                "name": "REDMINE_DB_PASSWORD",
                "value": "${aws_db_instance.redmine.password}"
            }
        ]
    }
]

EOF

  task_role_arn      = aws_iam_role.ecs_role.arn
  execution_role_arn = aws_iam_role.ecs_role.arn

  network_mode = "bridge"

  tags = {
    name = "latest"
  }

}

resource "aws_ecs_service" "d2rq" {
  name                 = "redmine_d2rq_${terraform.workspace}"
  launch_type          = "EC2"
  force_new_deployment = "true"
  cluster              = aws_ecs_cluster.redmine.id
  task_definition      = aws_ecs_task_definition.d2rq.arn
  desired_count        = 1
  depends_on           = [aws_iam_role_policy.rds_access_policy, aws_iam_role_policy.ecs_access_policy]

  load_balancer {
    target_group_arn = aws_alb_target_group.d2rq.id
    container_name   = "redmine_d2rq_container_${terraform.workspace}"
    container_port   = 2020
  }


  lifecycle {
    ignore_changes = [desired_count]
  }


}
