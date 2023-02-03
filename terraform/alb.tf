resource "aws_alb" "redmine" {
  name            = "redmine-${terraform.workspace}"
  subnets         = [aws_default_subnet.default_1a.id, aws_default_subnet.default_1b.id]
  security_groups = [aws_security_group.redmine.id]
}

resource "aws_alb_target_group" "redmine" {
  name        = "redmine-tgroup-${terraform.workspace}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.default.id
  target_type = "instance"
  health_check {
    timeout  = 120
    interval = 300
    # Support redirect for the login as healthy
    matcher = "200-299,302"

  }

}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "redmine" {
  load_balancer_arn = aws_alb.redmine.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn


  default_action {
    target_group_arn = aws_alb_target_group.redmine.id
    type             = "forward"
  }
}

resource "aws_alb" "redmine_internal" {
  name            = "redmine-internal-${terraform.workspace}"
  subnets         = [aws_default_subnet.default_1a.id, aws_default_subnet.default_1b.id]
  security_groups = [aws_security_group.redmine.id]
  internal        = true
}

resource "aws_alb_target_group" "redmine_internal" {
  name        = "redmine-internal-tgroup-${terraform.workspace}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.default.id
  target_type = "instance"
  health_check {
    timeout  = 120
    interval = 300
    # Support redirect for the login as healthy
    matcher = "200-299,302"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "redmine_internal" {
  load_balancer_arn = aws_alb.redmine_internal.id
  port              = "80"
  protocol          = "HTTP"


  default_action {
    target_group_arn = aws_alb_target_group.redmine_internal.id
    type             = "forward"
  }
}


resource "aws_alb" "d2rq" {
  name            = "redmine-d2rq-${terraform.workspace}"
  subnets         = [aws_default_subnet.default_1a.id, aws_default_subnet.default_1b.id]
  security_groups = [aws_security_group.redmine.id]
}

resource "aws_alb_target_group" "d2rq" {
  name        = "redmine-d2rq-tgroup-${terraform.workspace}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.default.id
  target_type = "instance"
  health_check {
    timeout  = 120
    interval = 300
    # Support redirect for the login as healthy
    matcher = "200-299,302"

  }

}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "d2rq" {
  load_balancer_arn = aws_alb.d2rq.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn


  default_action {
    target_group_arn = aws_alb_target_group.d2rq.id
    type             = "forward"
  }
}


# Must be imported in
resource "aws_acm_certificate" "cert" {
  domain_name       = "*.bco-dmo.org"
  validation_method = "NONE"
  options {
    certificate_transparency_logging_preference = "DISABLED"
  }
}



output "alb_web_dns" {
  value       = aws_alb.redmine.dns_name
  description = "The DNS of the web application load balancer"
}
