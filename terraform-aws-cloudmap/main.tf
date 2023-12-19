resource "aws_service_discovery_private_dns_namespace" "this" {
  count = var.create_private_dns_namespace ? 1 : 0
  name  = var.namespace_name
  vpc   = data.aws_vpc.selected.id
  tags  = var.tags
}

resource "aws_service_discovery_service" "this" {
  for_each    = var.service_names
  name        = each.key
  description = each.value.description
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.this[0].id
    routing_policy = each.value.routing_policy
    dynamic "dns_records" {
      for_each = each.value.dns_records
      content {
        ttl  = dns_records.value.ttl
        type = dns_records.value.type
      }
    }
  }

  dynamic "health_check_config" {
    for_each = each.value.health_check_config
    content {
      type              = health_check_config.value.type
      resource_path     = health_check_config.value.resource_path
      failure_threshold = health_check_config.value.failure_threshold
    }
  }

  dynamic "health_check_custom_config" {
    for_each = each.value.health_check_custom_config
    content {
      failure_threshold = health_check_custom_config.value.failure_threshold
    }
  }

  tags = each.value.tags
}
