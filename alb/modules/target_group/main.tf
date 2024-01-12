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
      matcher             = try(health_check.value.matcher, null)
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

