resource "aws_lb_listener_rule" "this" {
  for_each = var.create ? var.listener_rules : {}

  listener_arn = var.listener_arn
  priority     = each.value.priority

  action {
    target_group_arn = aws_lb_target_group.this[0].arn
    type             = "forward"
  }

  dynamic "condition" {
    for_each = length(each.value.conditions) > 0 ? each.value.conditions : []

    content {

      # Host Header condition
      dynamic "host_header" {
        for_each = try(condition.value.host_header, [])
        content {
          values = host_header.value.values
        }
      }

      # HTTP Request Method condition
      dynamic "http_request_method" {
        for_each = try(condition.value.http_request_method, [])
        content {
          values = http_request_method.value.values
        }
      }

      # Path Pattern condition
      dynamic "path_pattern" {
        for_each = try(condition.value.path_pattern, [])
        content {
          values = path_pattern.value.values
        }
      }

      # Query String condition
      dynamic "query_string" {
        for_each = try(condition.value.query_string, [])
        content {
          key   = query_string.value.key
          value = query_string.value.value
        }
      }

      # Source IP condition
      dynamic "source_ip" {
        for_each = try(condition.value.source_ip, [])
        content {
          values = source_ip.value.values
        }
      }
    }
  }

  tags = try(each.value.tags, null)
}
