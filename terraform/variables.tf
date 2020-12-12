variable "region" {
  default = "us-east-1"
}

variable "whoi_ip" {
  default = "128.128.0.0/16"
}

variable "rds_password" {
}

variable "submission_default_security_group_id" {}
variable "submission_prod_security_group_id" {}
