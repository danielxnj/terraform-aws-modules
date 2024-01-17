resource "aws_lb_target_group" "this" {
  count = var.create ? 1 : 0

  name                 = var.name
  port                 = var.port
  protocol             = var.protocol
  vpc_id               = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay


  dynamic "health_check" {
    for_each = length(var.health_check) > 0 ? [var.health_check] : []

    content {
      enabled             = try(health_check.value.enabled, true)
      healthy_threshold   = try(health_check.value.healthy_threshold, null)
      interval            = try(health_check.value.interval, null)
      matcher             = try(health_check.value.matcher != "" ? health_check.value.matcher : null, null) 
      path                = try(health_check.value.path != "" ? health_check.value.path : null, null) 
      port                = try(health_check.value.port, null)
      protocol            = try(health_check.value.protocol, null)
      timeout             = try(health_check.value.timeout, null)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
    }
  }

  dynamic "stickiness" {
    for_each = length(var.stickiness) > 0 ? [var.stickiness] : []

    content {
      cookie_duration = try(stickiness.value.cookie_duration, null)
      enabled         = try(stickiness.value.enabled, true)
      type            = try(stickiness.value.type, null)
    }
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.create ? var.listener_rules : {}

  listener_arn = each.value.listener_arn
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

      dynamic "http_header" {
        for_each = try(condition.value.http_header, [])
        content {
          http_header_name  = http_header.value.http_header_name
          values            = http_header.value.values
        }
      }
    }
  }

  tags = try(each.value.tags, null)
}
