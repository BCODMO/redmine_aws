resource "aws_ecr_repository" "redmine" {
  name                 = "redmine_${terraform.workspace}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "redmine" {
  name              = "/ecs/redmine_${terraform.workspace}"
  retention_in_days = "7"

}


resource "aws_ecs_task_definition" "redmine" {
  family                = "redmine_${terraform.workspace}"
  container_definitions = <<EOF
[
    {
        "name": "redmine_container_${terraform.workspace}",
        "image": "${aws_ecr_repository.redmine.repository_url}:latest",
        "portMappings": [
            {
                "containerPort": 3000
            }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.redmine.name}",
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

  cpu    = "512"
  memory = "1024"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  tags = {
    name = "latest"
  }

}

resource "aws_ecs_service" "redmine" {
  name                 = "redmine_${terraform.workspace}"
  launch_type          = "FARGATE"
  force_new_deployment = "true"
  cluster              = aws_ecs_cluster.redmine.id
  task_definition      = aws_ecs_task_definition.redmine.arn
  desired_count        = 1
  depends_on           = [aws_iam_role_policy.rds_access_policy, aws_iam_role_policy.ecs_access_policy, aws_alb.redmine]

  network_configuration {
    subnets          = [aws_default_subnet.default_1a.id, aws_default_subnet.default_1b.id]
    security_groups  = [aws_security_group.redmine.id]
    assign_public_ip = "true"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.redmine.id
    container_name   = "redmine_container_${terraform.workspace}"
    container_port   = 3000
  }

  service_registries {
    registry_arn = aws_service_discovery_service.redmine.arn
  }



  lifecycle {
    ignore_changes = [desired_count]
  }

}

