resource "aws_db_instance" "redmine" {
  identifier                = "redmine"
  allocated_storage         = 20
  storage_type              = "gp2"
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t3.micro"
  name                      = "redmine"
  username                  = "admin"
  password                  = var.rds_password
  parameter_group_name      = "default.mysql5.7"
    vpc_security_group_ids  = [aws_security_group.redmine.id]
  skip_final_snapshot       = true

}
