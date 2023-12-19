locals {
  byte_match_statement_rules = local.enabled && var.byte_match_statement_rules != null ? {
    for rule in flatten(var.byte_match_statement_rules) :
    format("%s-%s",
      lookup(rule, "name", null) != null ? rule.name : format("%s-byte-match-%d", module.this.id, rule.priority),
      rule.action,
    ) => rule
  } : {}

  geo_allowlist_statement_rules = local.enabled && var.geo_allowlist_statement_rules != null ? {
    for rule in flatten(var.geo_allowlist_statement_rules) :
    format("%s-%s",
      lookup(rule, "name", null) != null ? rule.name : format("%s-geo-allowlist-%d", module.this.id, rule.priority),
      "block",
    ) => rule
  } : {}

  geo_match_statement_rules = local.enabled && var.geo_match_statement_rules != null ? {
    for rule in flatten(var.geo_match_statement_rules) :
    format("%s-%s",
      lookup(rule, "name", null) != null ? rule.name : format("%s-geo-match-%d", module.this.id, rule.priority),
      rule.action,
    ) => rule
  } : {}

  ip_set_reference_statement_rules = local.enabled && var.ip_set_reference_statement_rules != null ? {
    for indx, rule in flatten(var.ip_set_reference_statement_rules) :
    format("%s-%s",
      lookup(rule, "name", null) != null ? rule.name : format("%s-ip-set-reference-%d", module.this.id, rule.priority),
      rule.action,
    ) => rule
  } : {}

  managed_rule_group_statement_rules = local.enabled && var.managed_rule_group_statement_rules != null ? {
    for rule in flatten(var.managed_rule_group_statement_rules) :
    lookup(rule, "name", null) != null ? rule.name : format("%s-managed-rule-group-%d", module.this.id, rule.priority) => rule
  } : {}

  rate_based_statement_rules = local.enabled && var.rate_based_statement_rules != null ? {
    for rule in flatten(var.rate_based_statement_rules) :
    format("%s-%s",
      lookup(rule, "name", null) != null ? rule.name : format("%s-rate-based-%d", module.this.id, rule.priority),
      rule.action,
    ) => rule
  } : {}

  rule_group_reference_statement_rules = local.enabled && var.rule_group_reference_statement_rules != null ? {
    for rule in flatten(var.rule_group_reference_statement_rules) :
    lookup(rule, "name", null) != null ? rule.name : format("%s-rule-group-reference-%d", module.this.id, rule.priority) => rule
  } : {}

  regex_pattern_set_reference_statement_rules = local.enabled && var.regex_pattern_set_reference_statement_rules != null ? {
    for rule in flatten(var.regex_pattern_set_reference_statement_rules) :
    format("%s-%s",
      lookup(rule, "name", null) != null ? rule.name : format("%s-regex-pattern-set-reference-%d", module.this.id, rule.priority),
      rule.action,
    ) => rule
  } : {}

  regex_match_statement_rules = local.enabled && var.regex_match_statement_rules != null ? {
    for rule in flatten(var.regex_match_statement_rules) :
    format("%s-%s",
      lookup(rule, "name", null) != null ? rule.name : format("%s-regex-match-statement-%d", module.this.id, rule.priority),
      rule.action,
    ) => rule
  } : {}

  size_constraint_statement_rules = local.enabled && var.size_constraint_statement_rules != null ? {
    for rule in flatten(var.size_constraint_statement_rules) :
    format("%s-%s",
      lookup(rule, "name", null) != null ? rule.name : format("%s-size-constraint-%d", module.this.id, rule.priority),
      rule.action,
    ) => rule
  } : {}

  sqli_match_statement_rules = local.enabled && var.sqli_match_statement_rules != null ? {
    for rule in flatten(var.sqli_match_statement_rules) :
    format("%s-%s",
      lookup(rule, "name", null) != null ? rule.name : format("%s-sqli-match-%d", module.this.id, rule.priority),
      rule.action,
    ) => rule
  } : {}

  xss_match_statement_rules = local.enabled && var.xss_match_statement_rules != null ? {
    for rule in flatten(var.xss_match_statement_rules) :
    format("%s-%s",
      lookup(rule, "name", null) != null ? rule.name : format("%s-xss-match-%d", module.this.id, rule.priority),
      rule.action,
    ) => rule
  } : {}
}

resource "aws_wafv2_web_acl" "default" {
  count = local.enabled ? 1 : 0

  name          = module.this.id
  description   = var.description
  scope         = var.scope
  token_domains = var.token_domains
  tags          = module.this.tags

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [true] : []
      content {}
    }

    dynamic "block" {
      for_each = var.default_action == "block" ? [true] : []
      content {
        dynamic "custom_response" {
          for_each = var.default_block_response
          content {
            custom_response_body_key = custom_response_body.value.key
            response_code            = custom_response_body.value.response_code
            dynamic "response_header" {
              for_each = lookup(custom_response_body.value, "response_header", null) != null ? [1] : []
              content {
                name  = custom_response_body.value.response_header.name
                value = custom_response_body.value.response_header.value
              }
            }
          }
        }
      }
    }
  }

  dynamic "visibility_config" {
    for_each = var.visibility_config
    content {
      cloudwatch_metrics_enabled = visibility_config.value.cloudwatch_metrics_enabled
      metric_name                = visibility_config.value.metric_name
      sampled_requests_enabled   = visibility_config.value.sampled_requests_enabled
    }
  }

  dynamic "custom_response_body" {
    for_each = var.custom_response_body
    content {
      key          = custom_response_body.value.key
      content      = custom_response_body.value.content
      content_type = custom_response_body.value.content_type
    }
  }

  dynamic "rule" {
    for_each = var.rules
    content {

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [true] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [true] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []

          content {}
        }
      }

      name     = rule.value.name
      priority = rule.value.priority

      dynamic "visibility_config" {
        for_each = lookup(rule.value, "visibility_config", null) != null ? rule.value.visibility_config : []

        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }

      dynamic "captcha_config" {
        for_each = lookup(rule.value, "captcha_config", null) != null ? rule.value.captcha_config : []

        content {
          immunity_time_property {
            immunity_time = captcha_config.value.immunity_time_property.immunity_time
          }
        }
      }

      dynamic "rule_label" {
        for_each = lookup(rule.value, "rule_label", null) != null ? ule.value.rule_label : []
        content {
          name = rule_label.value
        }
      }

      statement {
        dynamic "managed_rule_group_statement" {
          for_each = lookup(rule.value, "managed_rule_group_statement", null) != null ? rule.value.managed_rule_group_statement : []

          content {
            name        = managed_rule_group_statement.value.name
            vendor_name = managed_rule_group_statement.value.vendor_name
            version     = managed_rule_group_statement.value.version

            dynamic "rule_action_override" {
              for_each = lookup(managed_rule_group_statement.value, "rule_action_override", null) != null ? [1] : []
              content {
                name = managed_rule_group_statement.value.name
                action_to_use {
                  dynamic "allow" {
                    for_each = managed_rule_group_statement.value.action == "allow" ? [1] : []
                    content {
                      dynamic "custom_request_handling" {
                        for_each = lookup(managed_rule_group_statement.value, "custom_request_handling", null) != null ? [1] : []
                        content {
                          insert_header {
                            name  = managed_rule_group_statement.value.custom_request_handling.insert_header.name
                            value = managed_rule_group_statement.value.custom_request_handling.insert_header.value
                          }
                        }
                      }
                    }
                  }
                  dynamic "block" {
                    for_each = managed_rule_group_statement.value.action == "block" ? [1] : []
                    content {
                      dynamic "custom_response" {
                        for_each = lookup(managed_rule_group_statement.value, "custom_response", null) != null ? [1] : []
                        content {
                          response_code            = managed_rule_group_statement.value.custom_response.response_code
                          custom_response_body_key = lookup(managed_rule_group_statement.value.custom_response, "custom_response_body_key", null)
                          dynamic "response_header" {
                            for_each = lookup(managed_rule_group_statement.value.custom_response, "response_header", null) != null ? [1] : []
                            content {
                              name  = managed_rule_group_statement.value.custom_response.response_header.name
                              value = managed_rule_group_statement.value.custom_response.response_header.value
                            }
                          }
                        }
                      }
                    }
                  }
                  dynamic "count" {
                    for_each = managed_rule_group_statement.value.action == "count" ? [1] : []
                    content {
                      dynamic "custom_request_handling" {
                        for_each = lookup(managed_rule_group_statement.value, "custom_request_handling", null) != null ? [1] : []
                        content {
                          insert_header {
                            name  = managed_rule_group_statement.value.custom_request_handling.insert_header.name
                            value = managed_rule_group_statement.value.custom_request_handling.insert_header.value
                          }
                        }
                      }
                    }
                  }
                  dynamic "captcha" {
                    for_each = managed_rule_group_statement.value.action == "captcha" ? [1] : []
                    content {
                      dynamic "custom_request_handling" {
                        for_each = lookup(managed_rule_group_statement.value, "custom_request_handling", null) != null ? [1] : []
                        content {
                          insert_header {
                            name  = managed_rule_group_statement.value.custom_request_handling.insert_header.name
                            value = managed_rule_group_statement.value.custom_request_handling.insert_header.value
                          }
                        }
                      }
                    }
                  }
                  dynamic "challenge" {
                    for_each = managed_rule_group_statement.value.action == "challenge" ? [1] : []
                    content {
                      dynamic "custom_request_handling" {
                        for_each = lookup(managed_rule_group_statement.value, "custom_request_handling", null) != null ? [1] : []
                        content {
                          insert_header {
                            name  = managed_rule_group_statement.value.custom_request_handling.insert_header.name
                            value = managed_rule_group_statement.value.custom_request_handling.insert_header.value
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            dynamic "managed_rule_group_configs" {
              for_each = lookup(managed_rule_group_statement.value, "managed_rule_group_configs", null) != null ? managed_rule_group_statement.value.managed_rule_group_configs : []

              content {
                dynamic "aws_managed_rules_bot_control_rule_set" {
                  for_each = lookup(managed_rule_group_configs.value, "aws_managed_rules_bot_control_rule_set", null) != null ? [1] : []
                  content {
                    inspection_level = managed_rule_group_configs.value.aws_managed_rules_bot_control_rule_set.inspection_level
                  }
                }

                dynamic "aws_managed_rules_atp_rule_set" {
                  for_each = lookup(managed_rule_group_configs.value, "aws_managed_rules_atp_rule_set", null) != null ? [1] : []
                  content {
                    enable_regex_in_path = lookup(managed_rule_group_configs.value.aws_managed_rules_atp_rule_set, "enable_regex_in_path", null)
                    login_path           = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.login_path

                    dynamic "request_inspection" {
                      for_each = lookup(managed_rule_group_configs.value.aws_managed_rules_atp_rule_set, "request_inspection", null) != null ? [1] : []
                      content {
                        payload_type = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.request_inspection.payload_type
                        username_field {
                          identifier = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.request_inspection.username_field.identifier
                        }
                        password_field {
                          identifier = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.request_inspection.password_field.identifier
                        }
                      }
                    }
                    dynamic "response_inspection" {
                      for_each = lookup(managed_rule_group_configs.value.aws_managed_rules_atp_rule_set, "response_inspection", null) != null ? [1] : []
                      content {
                        dynamic "body_contains" {
                          for_each = lookup(managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection, "body_contains", null) != null ? [1] : []
                          content {
                            failure_strings = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection.body_contains.failure_strings
                            success_strings = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection.body_contains.success_strings
                          }
                        }
                        dynamic "header" {
                          for_each = lookup(managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection, "header", null) != null ? [1] : []
                          content {
                            failure_values = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection.header.failure_values
                            name           = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection.header.name
                            success_values = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection.header.success_values
                          }
                        }
                        dynamic "json" {
                          for_each = lookup(managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection, "json", null) != null ? [1] : []
                          content {
                            failure_values = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection.json.failure_values
                            identifier     = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection.json.identifier
                            success_values = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection.json.success_values
                          }
                        }
                        dynamic "status_code" {
                          for_each = lookup(managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection, "status_code", null) != null ? [1] : []
                          content {
                            failure_codes = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection.status_code.failure_codes
                            success_codes = managed_rule_group_configs.value.aws_managed_rules_atp_rule_set.response_inspection.status_code.success_codes
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
