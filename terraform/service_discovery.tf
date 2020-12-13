resource "aws_service_discovery_private_dns_namespace" "redmine" {
  name        = "ecs.redmine.${terraform.workspace}"
  description = "Service discovery for redmine"
  vpc         = aws_default_vpc.default.id

}

resource "aws_service_discovery_service" "redmine" {
  name = "redmine"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.redmine.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
