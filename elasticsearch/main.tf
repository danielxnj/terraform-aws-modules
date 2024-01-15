# module "user_label" {
#   source  = "cloudposse/label/null"
#   version = "0.25.0"

#   attributes = ["user"]

#   context = module.this.context
# }

# module "kibana_label" {
#   source  = "cloudposse/label/null"
#   version = "0.25.0"

#   attributes = ["kibana"]

#   context = module.this.context
# }

# resource "aws_security_group" "default" {
#   count       = module.this.enabled && var.vpc_enabled && var.create_security_group ? 1 : 0
#   vpc_id      = var.vpc_id
#   name        = module.this.id
#   description = "Allow inbound traffic from Security Groups and CIDRs. Allow all outbound traffic"
#   tags        = module.this.tags

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_security_group_rule" "ingress_security_groups" {
#   count                    = module.this.enabled && var.vpc_enabled && var.create_security_group ? length(var.security_groups) : 0
#   description              = "Allow inbound traffic from Security Groups"
#   type                     = "ingress"
#   from_port                = var.ingress_port_range_start
#   to_port                  = var.ingress_port_range_end
#   protocol                 = "tcp"
#   source_security_group_id = var.security_groups[count.index]
#   security_group_id        = join("", aws_security_group.default[*].id)
# }

# resource "aws_security_group_rule" "ingress_cidr_blocks" {
#   count             = module.this.enabled && var.vpc_enabled && var.create_security_group && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
#   description       = "Allow inbound traffic from CIDR blocks"
#   type              = "ingress"
#   from_port         = var.ingress_port_range_start
#   to_port           = var.ingress_port_range_end
#   protocol          = "tcp"
#   cidr_blocks       = var.allowed_cidr_blocks
#   security_group_id = join("", aws_security_group.default[*].id)
# }

# resource "aws_security_group_rule" "egress" {
#   count             = module.this.enabled && var.vpc_enabled && var.create_security_group ? 1 : 0
#   description       = "Allow all egress traffic"
#   type              = "egress"
#   from_port         = 0
#   to_port           = 65535
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = join("", aws_security_group.default[*].id)
# }

# https://github.com/terraform-providers/terraform-provider-aws/issues/5218
# resource "aws_iam_service_linked_role" "default" {
#   count            = module.this.enabled && var.create_iam_service_linked_role ? 1 : 0
#   aws_service_name = "es.amazonaws.com"
#   description      = "AWSServiceRoleForAmazonElasticsearchService Service-Linked Role"
# }

# Role that pods can assume for access to elasticsearch and kibana
# resource "aws_iam_role" "elasticsearch_user" {
#   count              = module.this.enabled && var.create_elasticsearch_user_role && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
#   name               = module.user_label.id
#   assume_role_policy = join("", data.aws_iam_policy_document.assume_role[*].json)
#   description        = "IAM Role to assume to access the Elasticsearch ${module.this.id} cluster"
#   tags               = module.user_label.tags

#   max_session_duration = var.iam_role_max_session_duration

#   permissions_boundary = var.iam_role_permissions_boundary
# }

# data "aws_iam_policy_document" "assume_role" {
#   count = module.this.enabled && var.create_elasticsearch_user_role && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0

#   statement {
#     actions = [
#       "sts:AssumeRole"
#     ]

#     principals {
#       type        = "Service"
#       identifiers = var.aws_ec2_service_name
#     }

#     principals {
#       type        = "AWS"
#       identifiers = compact(concat(var.iam_authorizing_role_arns, var.iam_role_arns))
#     }

#     effect = "Allow"
#   }
# }

resource "aws_elasticsearch_domain" "default" {
  count                 = module.this.enabled ? 1 : 0
  domain_name           = var.domain_name
  elasticsearch_version = var.elasticsearch_version

  advanced_options = var.advanced_options

  access_policies = var.access_policies

  dynamic "advanced_security_options" {
    for_each = var.advanced_security_options != null ? [var.advanced_security_options] : []
    content {
      enabled                        = advanced_security_options.value.enabled
      internal_user_database_enabled = advanced_security_options.value.internal_user_database_enabled

      dynamic "master_user_options" {
        for_each = length(advanced_security_options.value.master_user_options) > 0 ? advanced_security_options.value.master_user_options : []
        content {
          master_user_arn      = try(master_user_options.value.master_user_arn, null)
          master_user_name     = try(master_user_options.value.master_user_name, null)
          master_user_password = try(master_user_options.value.master_user_password, null)
        }
      }
    }
  }

  dynamic "ebs_options" {
    for_each = var.ebs_options != null ? [var.ebs_options] : []
    content {
      ebs_enabled = ebs_options.value.ebs_enabled
      volume_size = try(ebs_options.value.volume_size, null)
      volume_type = try(ebs_options.value.volume_type, null)
      iops = ebs_options.value.iops > 0 ? ebs_options.value.iops : null
      throughput = ebs_options.value.throughput > 125 ? ebs_options.value.throughput : null
    }
  }

dynamic "encrypt_at_rest" {
    for_each = var.encrypt_at_rest != null ? [var.encrypt_at_rest] : []
    content {
      enabled    = encrypt_at_rest.value.enabled
      kms_key_id = lookup(var.encrypt_at_rest, "kms_key_alias", null) != null ? data.aws_kms_key.kms[0].id : try(encrypt_at_rest.value.kms_key_id, null)
    }
  }

  dynamic "domain_endpoint_options" {
    for_each = var.domain_endpoint_options != null ? [var.domain_endpoint_options] : []
    content {
      enforce_https                   = domain_endpoint_options.value.enforce_https
      tls_security_policy             = try(domain_endpoint_options.value.tls_security_policy, null)
      custom_endpoint_enabled         = domain_endpoint_options.value.custom_endpoint_enabled
      custom_endpoint                 = try(domain_endpoint_options.value.custom_endpoint, null)
      custom_endpoint_certificate_arn = try(domain_endpoint_options.value.custom_endpoint_certificate_arn, null)
    }
  }

  dynamic "cluster_config" {
    for_each = var.cluster_config != null ? [var.cluster_config] : []
    content {
      instance_count           = cluster_config.value.instance_count
      instance_type            = cluster_config.value.instance_type
      dedicated_master_enabled = cluster_config.value.dedicated_master_enabled
      dedicated_master_count   = cluster_config.value.dedicated_master_enabled ? cluster_config.value.dedicated_master_count : null
      dedicated_master_type    = cluster_config.value.dedicated_master_enabled ? cluster_config.value.dedicated_master_type : null
      zone_awareness_enabled   = cluster_config.value.zone_awareness_enabled
      warm_enabled             = cluster_config.value.warm_enabled
      warm_count               = cluster_config.value.warm_enabled ? cluster_config.value.warm_count : null
      warm_type                = cluster_config.value.warm_enabled ? cluster_config.value.warm_type : null

      dynamic "zone_awareness_config" {
        for_each = cluster_config.value.zone_awareness_config != null ? cluster_config.value.zone_awareness_config : []
        content {
          availability_zone_count = zone_awareness_config.value.availability_zone_count
        }
      }

      dynamic "cold_storage_options" {
        for_each = cluster_config.value.cold_storage_options != null ? cluster_config.value.cold_storage_options : []
        content {
          enabled = cold_storage_options.value.enabled
        }
      }
    }
  }

  dynamic "auto_tune_options" {
    for_each = var.auto_tune_options != null ? [var.auto_tune_options] : []
    content {
      desired_state = auto_tune_options.value.desired_state
      dynamic "maintenance_schedule" {
        for_each = length(auto_tune_options.value.maintenance_schedule) > 0 ? auto_tune_options.value.maintenance_schedule : []
        content {
          cron_expression_for_recurrence = maintenance_schedule.value.cron_expression_for_recurrence
          duration {
            value     = maintenance_schedule.value.duration[0].value
            unit     = maintenance_schedule.value.duration[0].unit
          }
          start_at = maintenance_schedule.value.start_at
        }
      }
    }
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  dynamic "vpc_options" {
    for_each = var.vpc_options != null ? [var.vpc_options] : []
    content {
      security_group_ids = vpc_options.value.security_group_ids
      subnet_ids          = lookup(vpc_options.value, "subnet_names", null) != null ? data.aws_subnet.default[*].id : vpc_options.value.subnet_ids
    }
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  dynamic "cognito_options" {
    for_each = var.cognito_options != null ? [var.cognito_options] : []
    content {
      enabled          = cognito_options.value.enabled
      user_pool_id     = cognito_options.value.user_pool_id
      identity_pool_id = cognito_options.value.identity_pool_id
      role_arn         = cognito_options.value.role_arn
    }
  }

  dynamic "log_publishing_options" {
    for_each = var.log_publishing_options != null ? var.log_publishing_options : []
    content {
      cloudwatch_log_group_arn = log_publishing_options.value.cloudwatch_log_group_arn
      enabled                  = log_publishing_options.value.enabled
      log_type                 = log_publishing_options.value.log_type
    }
  }

  tags = var.tags

  # depends_on = [aws_iam_service_linked_role.default]
}

# data "aws_iam_policy_document" "default" {
#   count = module.this.enabled && (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0

#   statement {
#     effect = "Allow"

#     actions = distinct(compact(var.iam_actions))

#     resources = [
#       join("", aws_elasticsearch_domain.default[*].arn),
#       "${join("", aws_elasticsearch_domain.default[*].arn)}/*"
#     ]

#     principals {
#       type        = "AWS"
#       identifiers = distinct(compact(concat(var.iam_role_arns, aws_iam_role.elasticsearch_user[*].arn)))
#     }
#   }

#   # This statement is for non VPC ES to allow anonymous access from whitelisted IP ranges without requests signing
#   # https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-ac.html#es-ac-types-ip
#   # https://aws.amazon.com/premiumsupport/knowledge-center/anonymous-not-authorized-elasticsearch/
#   dynamic "statement" {
#     for_each = length(var.allowed_cidr_blocks) > 0 && !var.vpc_enabled ? [true] : []
#     content {
#       effect = "Allow"

#       actions = distinct(compact(var.iam_actions))

#       resources = [
#         join("", aws_elasticsearch_domain.default[*].arn),
#         "${join("", aws_elasticsearch_domain.default[*].arn)}/*"
#       ]

#       principals {
#         type        = "AWS"
#         identifiers = ["*"]
#       }

#       condition {
#         test     = "IpAddress"
#         values   = var.allowed_cidr_blocks
#         variable = "aws:SourceIp"
#       }
#     }
#   }
# }

# resource "aws_elasticsearch_domain_policy" "default" {
#   count           = module.this.enabled && var.access_policies != null ? 1 : 0
#   domain_name     = module.this.id
#   access_policies = var.access_policies
# }

# module "domain_hostname" {
#   source  = "cloudposse/route53-cluster-hostname/aws"
#   version = "0.12.3"

#   enabled  = module.this.enabled && var.domain_hostname_enabled
#   dns_name = var.elasticsearch_subdomain_name == "" ? module.this.id : var.elasticsearch_subdomain_name
#   ttl      = 60
#   zone_id  = var.dns_zone_id
#   records  = [join("", aws_elasticsearch_domain.default[*].endpoint)]

#   context = module.this.context
# }

# module "kibana_hostname" {
#   source  = "cloudposse/route53-cluster-hostname/aws"
#   version = "0.12.3"

#   enabled  = module.this.enabled && var.kibana_hostname_enabled
#   dns_name = var.kibana_subdomain_name == "" ? module.kibana_label.id : var.kibana_subdomain_name
#   ttl      = 60
#   zone_id  = var.dns_zone_id
#   # Note: kibana_endpoint is not just a domain name, it includes a path component,
#   # and as such is not suitable for a DNS record. The plain endpoint is the
#   # hostname portion and should be used for DNS.
#   records = [join("", aws_elasticsearch_domain.default[*].endpoint)]

#   context = module.this.context
# }
