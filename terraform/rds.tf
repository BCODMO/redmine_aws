resource "aws_db_instance" "redmine" {
  identifier              = "redmine"
  deletion_protection     = true
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.micro"
  name                    = "redmine"
  username                = "admin"
  backup_retention_period = 10
  backup_window           = "07:00-07:30"
  password                = var.rds_password
  parameter_group_name    = "default.mysql5.7"
  vpc_security_group_ids  = [aws_security_group.redmine.id]
  skip_final_snapshot     = true

}
