resource "aws_lb_target_group" "this" {
  count = var.create ? 1 : 0

  name                 = var.target_group_name
  port                 = var.target_group_port
  protocol             = var.target_group_protocol
  vpc_id               = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay


  dynamic "health_check" {
    for_each = length(var.target_group_health_check) > 0 ? [var.target_group_health_check] : []

    content {
      enabled             = try(health_check.value.enabled, true)
      healthy_threshold   = try(health_check.value.healthy_threshold, null)
      interval            = try(health_check.value.interval, null)
      matcher             = try(health_check.value.matcher, null)
      path                = try(health_check.value.path, null)
      port                = try(health_check.value.port, null)
      protocol            = try(health_check.value.protocol, null)
      timeout             = try(health_check.value.timeout, null)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
    }
  }

  dynamic "stickiness" {
    for_each = length(var.target_group_stickiness) > 0 ? [var.target_group_stickiness] : []

    content {
      cookie_duration = try(stickiness.value.cookie_duration, null)
      enabled         = try(stickiness.value.enabled, true)
      type            = try(stickiness.value.type, null)
    }
  }

  tags = var.target_group_tags
}

resource "aws_lb_listener" "this" {
  count          = var.create && length(var.listener_rules) > 0 ? 1 : 0
  load_balancer_arn = var.load_balancer_arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  certificate_arn = var.listener_certificate_arn

  dynamic "default_action" {
    for_each = length(var.listener_default_action) > 0 ? [var.listener_default_action] : []

    content {
      order                = try(default_action.value.order, null)
      target_group_arn     = try(default_action.value.target_group_arn, null)
      type                 = try(default_action.value.type, null)
      dynamic "authenticate_cognito" {
        for_each = try(default_action.value.authenticate_cognito, [])
        content {
          authentication_request_extra_params = authenticate_cognito.value.authentication_request_extra_params
          on_unauthenticated_request          = authenticate_cognito.value.on_unauthenticated_request
          scope                               = authenticate_cognito.value.scope
          session_cookie_name                 = authenticate_cognito.value.session_cookie_name
          session_timeout                     = authenticate_cognito.value.session_timeout
          user_pool_arn                       = authenticate_cognito.value.user_pool_arn
          user_pool_client_id                 = authenticate_cognito.value.user_pool_client_id
          user_pool_domain                    = authenticate_cognito.value.user_pool_domain
        }
      }
      dynamic "authenticate_oidc" {
        for_each = try(default_action.value.authenticate_oidc, [])
        content {
          authentication_request_extra_params = authenticate_oidc.value.authentication_request_extra_params
          authorization_endpoint              = authenticate_oidc.value.authorization_endpoint
          client_id                           = authenticate_oidc.value.client_id
          client_secret                       = authenticate_oidc.value.client_secret
          issuer                              = authenticate_oidc.value.issuer
          on_unauthenticated_request          = authenticate_oidc.value.on_unauthenticated_request
          scope                               = authenticate_oidc.value.scope
          session_cookie_name                 = authenticate_oidc.value.session_cookie_name
          session_timeout                     = authenticate_oidc.value.session_timeout
          token_endpoint                      = authenticate_oidc.value.token_endpoint
          user_info_endpoint                  = authenticate_oidc.value.user_info_endpoint
        }
      }
      dynamic "fixed_response" {
        for_each = try(default_action.value.fixed_response, [])
        content {
          content_type = fixed_response.value.content_type
          message_body = fixed_response.value.message_body
          status_code  = fixed_response.value.status_code
        }
      }
      dynamic "forward" {
        for_each = try(default_action.value.forward, [])
        content {
          dynamic "target_group" {
            for_each = try(forward.value.target_group, [])
            content {
              arn = target_group.value.arn
              weight = target_group.value.weight
            }
          }

          dynamic "stickiness" {
            for_each = try(forward.value.stickiness, [])
            content {
              duration = stickiness.value.duration
              enabled  = stickiness.value.enabled
            }
          }
        }
      }
      dynamic "redirect" {
        for_each = try(default_action.value.redirect, [])
        content {
          host        = redirect.value.host
          path        = redirect.value.path
          port        = redirect.value.port
          protocol    = redirect.value.protocol
          query       = redirect.value.query
          status_code = redirect.value.status_code
        }
      }

    }
  }
  tags = var.listener_tags
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.create ? var.listener_rules : {}

  listener_arn = aws_lb_listener.this[0].arn
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
