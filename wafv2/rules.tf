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

  name          = var.name
  description   = var.description
  scope         = var.scope
  token_domains = var.token_domains
  tags          = var.tags

  dynamic "default_action" {
    for_each = var.default_action
    content {
      dynamic "allow" {
        for_each = default_action.value.allow
        content {}
      }

      dynamic "block" {
        for_each = default_action.value.block
        content {}
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
      name     = rule.value.name
      priority = rule.value.priority

      dynamic "action" {
        for_each = lookup(rule.value, "action", null) != null ? rule.value.action : []
        content {
          dynamic "allow" {
            for_each = action.value.allow
            content {
            }
          }
          dynamic "block" {
            for_each = action.value.block
            content {
            }
          }
          dynamic "count" {
            for_each = action.value.count
            content {
            }
          }
          dynamic "captcha" {
            for_each = action.value.captcha
            content {
            }
          }
          dynamic "challenge" {
            for_each = action.value.challenge
            content {
            }
          }
        }
      }

      dynamic "override_action" {
        for_each = lookup(rule.value, "override_action", null) != null ? rule.value.override_action : []
        content {
          dynamic "count" {
            for_each = override_action.value.count
            content {
            }
          }
          dynamic "none" {
            for_each = override_action.value.none
            content {
            }
          }
        }
      }

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
        for_each = lookup(rule.value, "rule_label", null) != null ? rule.value.rule_label : []
        content {
          name = rule_label.value
        }
      }

      dynamic "statement" {
        for_each = lookup(rule.value, "statement", null) != null ? rule.value.statement : []
        content {
          dynamic "managed_rule_group_statement" {
            for_each = lookup(statement.value, "managed_rule_group_statement", null) != null ? statement.value.managed_rule_group_statement : []

            content {
              name        = managed_rule_group_statement.value.name
              vendor_name = managed_rule_group_statement.value.vendor_name
              version     = lookup(managed_rule_group_statement.value, "version", "") != "" ? managed_rule_group_statement.value.version : null


              dynamic "scope_down_statement" {
                for_each = lookup(managed_rule_group_statement.value, "scope_down_statement", null) != null ? managed_rule_group_statement.value.scope_down_statement : []

                content {
                  dynamic "byte_match_statement" {
                    for_each = lookup(scope_down_statement.value, "byte_match_statement", null) != null ? scope_down_statement.value.byte_match_statement : []

                    content {
                      positional_constraint = lookup(byte_match_statement.value, "positional_constraint", null)
                      search_string         = byte_match_statement.value.search_string
                      dynamic "field_to_match" {
                        for_each = lookup(byte_match_statement.value, "field_to_match", null) != null ? byte_match_statement.value.field_to_match : []
                        content {
                          dynamic "uri_path" {
                            for_each = lookup(field_to_match.value, "uri_path", null) != null ? [1] : []
                            content {}
                          }
                        }
                      }
                      dynamic "text_transformation" {
                        for_each = lookup(byte_match_statement.value, "text_transformation", null) != null ? byte_match_statement.value.text_transformation : []
                        content {
                          priority = text_transformation.value.priority
                          type     = text_transformation.value.type
                        }
                      }
                    }
                  }

                  dynamic "and_statement" {
                    for_each = lookup(scope_down_statement.value, "and_statement", null) != null ? scope_down_statement.value.and_statement : []
                    content {
                      dynamic "statement" {
                        for_each = lookup(and_statement.value, "statement", null) != null ? and_statement.value.statement : []
                        content {
                          dynamic "not_statement" {
                            for_each = lookup(statement.value, "not_statement", null) != null ? statement.value.not_statement : []
                            content {
                              statement {
                                dynamic "byte_match_statement" {
                                  for_each = lookup(not_statement.value.statement[0], "byte_match_statement", null) != null ? not_statement.value.statement[0].byte_match_statement : []
                                  content {
                                    positional_constraint = lookup(byte_match_statement.value, "positional_constraint", null)
                                    search_string         = byte_match_statement.value.search_string
                                    dynamic "field_to_match" {
                                      for_each = lookup(byte_match_statement.value, "field_to_match", null) != null ? byte_match_statement.value.field_to_match : []
                                      content {
                                        dynamic "uri_path" {
                                          for_each = lookup(field_to_match.value, "uri_path", null) != null ? [1] : []
                                          content {}
                                        }
                                      }
                                    }
                                    dynamic "text_transformation" {
                                      for_each = lookup(byte_match_statement.value, "text_transformation", null) != null ? byte_match_statement.value.text_transformation : []
                                      content {
                                        priority = text_transformation.value.priority
                                        type     = text_transformation.value.type
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

              dynamic "rule_action_override" {
                for_each = lookup(managed_rule_group_statement.value, "rule_action_override", null) != null ? managed_rule_group_statement.value.rule_action_override : []
                content {
                  name = rule_action_override.value.name
                  dynamic "action_to_use" {
                    for_each = lookup(rule_action_override.value, "action_to_use", null) != null ? rule_action_override.value.action_to_use : []
                    content {

                      dynamic "allow" {
                        for_each = action_to_use.value.allow
                        content {
                          dynamic "custom_request_handling" {
                            for_each = allow.value.custom_request_handling
                            content {
                              insert_header {
                                name  = custom_request_handling.value[0].insert_header.name
                                value = custom_request_handling.value[0].insert_header.value
                              }
                            }
                          }
                        }
                      }
                      dynamic "block" {
                        for_each = action_to_use.value.block
                        content {
                          dynamic "custom_response" {
                            for_each = block.value.custom_response
                            content {
                              response_code            = custom_response.value[0].response_code
                              custom_response_body_key = lookup(custom_response.value[0], "custom_response_body_key", null)
                              dynamic "response_header" {
                                for_each = lookup(custom_response.value[0], "response_header", null) != null ? [1] : []
                                content {
                                  name  = custom_response.value[0].response_header.name
                                  value = custom_response.value[0].response_header.value
                                }
                              }
                            }
                          }
                        }
                      }
                      dynamic "count" {
                        for_each = action_to_use.value.count
                        content {
                          dynamic "custom_request_handling" {
                            for_each = count.value.custom_request_handling
                            content {
                              insert_header {
                                name  = custom_request_handling.value[0].insert_header.name
                                value = custom_request_handling.value[0].insert_header.value
                              }
                            }
                          }
                        }
                      }
                      dynamic "captcha" {
                        for_each = action_to_use.value.captcha
                        content {
                          dynamic "custom_request_handling" {
                            for_each = captcha.value.custom_request_handling
                            content {
                              insert_header {
                                name  = custom_request_handling.value[0].insert_header.name
                                value = custom_request_handling.value[0].insert_header.value
                              }
                            }
                          }
                        }
                      }
                      dynamic "challenge" {
                        for_each = action_to_use.value.challenge
                        content {
                          dynamic "custom_request_handling" {
                            for_each = challenge.value.custom_request_handling
                            content {
                              insert_header {
                                name  = custom_request_handling.value[0].insert_header.name
                                value = custom_request_handling.value[0].insert_header.value
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
  }
}
