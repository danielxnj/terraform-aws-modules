locals {
  enabled                = module.this.enabled
  create_rest_api_policy = local.enabled && var.rest_api_policy != null
  # create_log_group       = local.enabled && var.logging_level != "OFF"
  # log_group_arn          = local.create_log_group ? module.cloudwatch_log_group.log_group_arn : null
  vpc_link_enabled = local.enabled && length(var.private_link_target_arns) > 0
}

resource "aws_api_gateway_rest_api" "this" {
  count = local.enabled ? 1 : 0

  name        = var.name
  description = var.description
  body        = try(var.body, null)
  tags        = var.tags

  endpoint_configuration {
    types = var.endpoint_type
  }
}

resource "aws_api_gateway_rest_api_policy" "this" {
  count       = local.create_rest_api_policy ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id

  policy = var.rest_api_policy
}

# module "cloudwatch_log_group" {
#   source  = "cloudposse/cloudwatch-logs/aws"
#   version = "0.6.5"

#   enabled              = local.create_log_group
#   iam_tags_enabled     = var.iam_tags_enabled
#   permissions_boundary = var.permissions_boundary

#   context = module.this.context
# }

resource "aws_api_gateway_deployment" "this" {
  for_each    = var.deployments
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  description = try(each.value.description, "")

  # triggers = {
  #   redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this[0].body))
  # }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "this" {
  # Create a flattened list of all stages in all deployments, accounting for deployments without stages
  for_each = { for idx, value in flatten([
    for deployment_id, deployment in var.deployments : [
      for stage_id, stage in try(deployment.stages, {}) : { # Use try to handle missing stages
        deployment_id = deployment_id
        stage_id      = stage_id
        stage         = stage
      }
    ]
  ]) : "${value.deployment_id}-${value.stage_id}" => value }

  deployment_id         = aws_api_gateway_deployment.this[each.value.deployment_id].id
  rest_api_id           = aws_api_gateway_rest_api.this[0].id
  stage_name            = each.value.stage_id
  xray_tracing_enabled  = each.value.stage.xray_tracing_enabled
  cache_cluster_enabled = each.value.stage.cache_cluster_enabled
  cache_cluster_size    = try(each.value.stage.cache_cluster_size, null)
  description           = try(each.value.stage.description, "")

  tags = try(each.value.stage.tags, {})

  variables = try(each.value.stage.variables, null)

  dynamic "access_log_settings" {
    for_each = try(each.value.stage.access_log_settings, [])

    content {
      destination_arn = access_log_settings.value.destination_arn
      format          = replace(access_log_settings.value.format, "\n", "")
    }
  }
}


# Set the logging, metrics and tracing levels for all methods
resource "aws_api_gateway_method_settings" "all" {
  for_each = local.enabled ? var.api_gateway_method_settings : {}

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  stage_name  = each.value.stage_name
  method_path = each.value.method_path

  settings {
    cache_data_encrypted                       = each.value.cache_data_encrypted
    cache_ttl_in_seconds                       = each.value.cache_ttl_in_seconds
    caching_enabled                            = each.value.caching_enabled
    data_trace_enabled                         = each.value.data_trace_enabled
    logging_level                              = each.value.logging_level
    metrics_enabled                            = each.value.metrics_enabled
    require_authorization_for_cache_control    = each.value.require_authorization_for_cache_control
    throttling_burst_limit                     = each.value.throttling_burst_limit
    throttling_rate_limit                      = each.value.throttling_rate_limit
    unauthorized_cache_control_header_strategy = each.value.unauthorized_cache_control_header_strategy
  }
}

# Root resource
resource "aws_api_gateway_resource" "depth_0" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 0 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = ""
  parent_id   = ""
}

# Depth 1 resources
resource "aws_api_gateway_resource" "depth_1" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 1 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_0[each.value.parent_path_part].id
}

# Depth 2 resources
resource "aws_api_gateway_resource" "depth_2" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 2 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_1[each.value.parent_path_part].id
}

# Depth 3 resources
resource "aws_api_gateway_resource" "depth_3" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 3 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_2[each.value.parent_path_part].id
}

# Depth 4 resources
resource "aws_api_gateway_resource" "depth_4" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 4 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_3[each.value.parent_path_part].id
}

# Depth 5 resources
resource "aws_api_gateway_resource" "depth_5" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 5 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_4[each.value.parent_path_part].id
}

# Depth 6 resources
resource "aws_api_gateway_resource" "depth_6" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 6 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_5[each.value.parent_path_part].id
}

# Depth 7 resources
resource "aws_api_gateway_resource" "depth_7" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 7 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_6[each.value.parent_path_part].id
}

# Depth 8 resources
resource "aws_api_gateway_resource" "depth_8" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 8 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_7[each.value.parent_path_part].id
}

# Depth 9 resources
resource "aws_api_gateway_resource" "depth_9" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 9 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_8[each.value.parent_path_part].id
}

# Depth 10 resources
resource "aws_api_gateway_resource" "depth_10" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 10 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_9[each.value.parent_path_part].id
}

# Depth 11 resources
resource "aws_api_gateway_resource" "depth_11" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 11 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_10[each.value.parent_path_part].id
}

# Depth 12 resources
resource "aws_api_gateway_resource" "depth_12" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 12 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_11[each.value.parent_path_part].id
}

# Depth 13 resources
resource "aws_api_gateway_resource" "depth_13" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 13 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_12[each.value.parent_path_part].id
}

# Depth 14 resources
resource "aws_api_gateway_resource" "depth_14" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 14 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_13[each.value.parent_path_part].id
}

# Depth 15 resources
resource "aws_api_gateway_resource" "depth_15" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 15 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_14[each.value.parent_path_part].id
}

# Depth 16 resources
resource "aws_api_gateway_resource" "depth_16" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 16 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_15[each.value.parent_path_part].id
}

# Depth 17 resources
resource "aws_api_gateway_resource" "depth_17" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 17 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_16[each.value.parent_path_part].id
}

# Depth 18 resources
resource "aws_api_gateway_resource" "depth_18" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 18 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_17[each.value.parent_path_part].id
}

# Depth 19 resources
resource "aws_api_gateway_resource" "depth_19" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 19 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_18[each.value.parent_path_part].id
}

# Depth 20 resources
resource "aws_api_gateway_resource" "depth_20" {
  for_each    = local.enabled ? { for path, info in var.resources : path => info if info.depth == 20 } : {}
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_resource.depth_19[each.value.parent_path_part].id
}

locals {
  method_paths = merge([
    for path, info in var.resources : {
      for method, method_info in(info.methods != null ? info.methods : {}) : "${path}/${method}" => {
        path                 = path
        method               = method
        path_part            = info.path_part
        depth                = info.depth
        authorization        = method_info.authorization
        authorizer_id        = method_info.authorizer_id
        authorization_scopes = method_info.authorization_scopes
        api_key_required     = method_info.api_key_required
        operation_name       = method_info.operation_name
        request_models       = method_info.request_models
        request_validator_id = method_info.request_validator_id
        request_parameters   = method_info.request_parameters
      }
    }
  ]...)

  all_methods = { for k, v in local.method_paths : k => v }
}

resource "aws_api_gateway_method" "depth_0" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 0 } : {}

  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  resource_id          = aws_api_gateway_resource.depth_0[each.value.path].id
  http_method          = try(each.value.method, null)
  authorization        = try(each.value.authorization, null)
  authorizer_id        = try(each.value.authorizer_id, null)
  authorization_scopes = try(each.value.authorization_scopes, null)
  api_key_required     = try(each.value.api_key_required, null)
  operation_name       = try(each.value.operation_name, null)
  request_models       = try(each.value.request_models, null)
  request_validator_id = try(each.value.request_validator_id, null)
  request_parameters   = try(each.value.request_parameters, null)
}

resource "aws_api_gateway_method" "depth_1" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 1 } : {}

  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  resource_id          = aws_api_gateway_resource.depth_1[each.value.path].id
  http_method          = try(each.value.method, null)
  authorization        = try(each.value.authorization, null)
  authorizer_id        = try(each.value.authorizer_id, null)
  authorization_scopes = try(each.value.authorization_scopes, null)
  api_key_required     = try(each.value.api_key_required, null)
  operation_name       = try(each.value.operation_name, null)
  request_models       = try(each.value.request_models, null)
  request_validator_id = try(each.value.request_validator_id, null)
  request_parameters   = try(each.value.request_parameters, null)
}
resource "aws_api_gateway_method" "depth_2" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 2 } : {}

  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  resource_id          = aws_api_gateway_resource.depth_2[each.value.path].id
  http_method          = try(each.value.method, null)
  authorization        = try(each.value.authorization, null)
  authorizer_id        = try(each.value.authorizer_id, null)
  authorization_scopes = try(each.value.authorization_scopes, null)
  api_key_required     = try(each.value.api_key_required, null)
  operation_name       = try(each.value.operation_name, null)
  request_models       = try(each.value.request_models, null)
  request_validator_id = try(each.value.request_validator_id, null)
  request_parameters   = try(each.value.request_parameters, null)
}
resource "aws_api_gateway_method" "depth_3" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 3 } : {}

  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  resource_id          = aws_api_gateway_resource.depth_3[each.value.path].id
  http_method          = try(each.value.method, null)
  authorization        = try(each.value.authorization, null)
  authorizer_id        = try(each.value.authorizer_id, null)
  authorization_scopes = try(each.value.authorization_scopes, null)
  api_key_required     = try(each.value.api_key_required, null)
  operation_name       = try(each.value.operation_name, null)
  request_models       = try(each.value.request_models, null)
  request_validator_id = try(each.value.request_validator_id, null)
  request_parameters   = try(each.value.request_parameters, null)
}

resource "aws_api_gateway_method" "depth_4" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 4 } : {}

  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  resource_id          = aws_api_gateway_resource.depth_4[each.value.path].id
  http_method          = try(each.value.method, null)
  authorization        = try(each.value.authorization, null)
  authorizer_id        = try(each.value.authorizer_id, null)
  authorization_scopes = try(each.value.authorization_scopes, null)
  api_key_required     = try(each.value.api_key_required, null)
  operation_name       = try(each.value.operation_name, null)
  request_models       = try(each.value.request_models, null)
  request_validator_id = try(each.value.request_validator_id, null)
  request_parameters   = try(each.value.request_parameters, null)
}

resource "aws_api_gateway_method" "depth_5" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 5 } : {}

  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  resource_id          = aws_api_gateway_resource.depth_5[each.value.path].id
  http_method          = try(each.value.method, null)
  authorization        = try(each.value.authorization, null)
  authorizer_id        = try(each.value.authorizer_id, null)
  authorization_scopes = try(each.value.authorization_scopes, null)
  api_key_required     = try(each.value.api_key_required, null)
  operation_name       = try(each.value.operation_name, null)
  request_models       = try(each.value.request_models, null)
  request_validator_id = try(each.value.request_validator_id, null)
  request_parameters   = try(each.value.request_parameters, null)
}

resource "aws_api_gateway_method" "depth_6" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 6 } : {}

  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  resource_id          = aws_api_gateway_resource.depth_6[each.value.path].id
  http_method          = try(each.value.method, null)
  authorization        = try(each.value.authorization, null)
  authorizer_id        = try(each.value.authorizer_id, null)
  authorization_scopes = try(each.value.authorization_scopes, null)
  api_key_required     = try(each.value.api_key_required, null)
  operation_name       = try(each.value.operation_name, null)
  request_models       = try(each.value.request_models, null)
  request_validator_id = try(each.value.request_validator_id, null)
  request_parameters   = try(each.value.request_parameters, null)
}

resource "aws_api_gateway_method" "depth_7" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 7 } : {}

  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  resource_id          = aws_api_gateway_resource.depth_7[each.value.path].id
  http_method          = try(each.value.method, null)
  authorization        = try(each.value.authorization, null)
  authorizer_id        = try(each.value.authorizer_id, null)
  authorization_scopes = try(each.value.authorization_scopes, null)
  api_key_required     = try(each.value.api_key_required, null)
  operation_name       = try(each.value.operation_name, null)
  request_models       = try(each.value.request_models, null)
  request_validator_id = try(each.value.request_validator_id, null)
  request_parameters   = try(each.value.request_parameters, null)
}

resource "aws_api_gateway_method" "depth_8" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 8 } : {}

  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  resource_id          = aws_api_gateway_resource.depth_8[each.value.path].id
  http_method          = try(each.value.method, null)
  authorization        = try(each.value.authorization, null)
  authorizer_id        = try(each.value.authorizer_id, null)
  authorization_scopes = try(each.value.authorization_scopes, null)
  api_key_required     = try(each.value.api_key_required, null)
  operation_name       = try(each.value.operation_name, null)
  request_models       = try(each.value.request_models, null)
  request_validator_id = try(each.value.request_validator_id, null)
  request_parameters   = try(each.value.request_parameters, null)
}

resource "aws_api_gateway_method" "depth_9" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 9 } : {}

  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  resource_id          = aws_api_gateway_resource.depth_9[each.value.path].id
  http_method          = try(each.value.method, null)
  authorization        = try(each.value.authorization, null)
  authorizer_id        = try(each.value.authorizer_id, null)
  authorization_scopes = try(each.value.authorization_scopes, null)
  api_key_required     = try(each.value.api_key_required, null)
  operation_name       = try(each.value.operation_name, null)
  request_models       = try(each.value.request_models, null)
  request_validator_id = try(each.value.request_validator_id, null)
  request_parameters   = try(each.value.request_parameters, null)
}

resource "aws_api_gateway_method" "depth_10" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 10 } : {}

  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  resource_id          = aws_api_gateway_resource.depth_10[each.value.path].id
  http_method          = try(each.value.method, null)
  authorization        = try(each.value.authorization, null)
  authorizer_id        = try(each.value.authorizer_id, null)
  authorization_scopes = try(each.value.authorization_scopes, null)
  api_key_required     = try(each.value.api_key_required, null)
  operation_name       = try(each.value.operation_name, null)
  request_models       = try(each.value.request_models, null)
  request_validator_id = try(each.value.request_validator_id, null)
  request_parameters   = try(each.value.request_parameters, null)
}


resource "aws_api_gateway_integration" "depth_0" {
  for_each = local.enabled ? { for path, info in local.all_methods : path => info if info.depth == 0 } : {}

  rest_api_id             = aws_api_gateway_rest_api.this[0].id
  resource_id             = aws_api_gateway_resource.depth_0[each.value.path].id
  http_method             = try(each.value.method, null)
  integration_http_method = try(each.value.integration_http_method, null)
  type                    = try(each.value.type, null)
  connection_type         = try(each.value.connection_type, null)
  connection_id           = try(each.value.connection_id, null)
  uri                     = try(each.value.uri, null)
  credentials             = try(each.value.credentials, null)
  request_templates       = try(each.value.request_templates, null)
  request_parameters      = try(each.value.request_parameters, null)
  passthrough_behavior    = try(each.value.passthrough_behavior, null)
  cache_key_parameters    = try(each.value.cache_key_parameters, null)
  cache_namespace         = try(each.value.cache_namespace, null)
  content_handling        = try(each.value.content_handling, null)
  timeout_milliseconds    = try(each.value.timeout_milliseconds, null)
  dynamic "tls_config" {
    for_each = try(each.value.tls_config, null)

    content {
      insecure_skip_verification = tls_config.value.insecure_skip_verification
    }
  }
}
