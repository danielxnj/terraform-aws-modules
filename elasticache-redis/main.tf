#
# Security Group Resources
#
locals {
  enabled = module.this.enabled

  legacy_egress_rule = local.use_legacy_egress ? {
    key         = "legacy-egress"
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.egress_cidr_blocks
    description = "Allow outbound traffic to existing CIDR blocks"
  } : null

  legacy_cidr_ingress_rule = length(var.allowed_cidr_blocks) == 0 ? null : {
    key         = "legacy-cidr-ingress"
    type        = "ingress"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow inbound traffic from CIDR blocks"
  }

  sg_rules = {
    legacy = merge(local.legacy_egress_rule, local.legacy_cidr_ingress_rule),
    extra  = var.additional_security_group_rules
  }
}

# resource "aws_security_group" "default" {
#   count       = module.this.enabled && local.create_security_group ? 1 : 0
#   name        = var.security_group_name
#   description = var.security_group_description
#   vpc_id      = var.vpc_name != null ? data.aws_vpc.default[0].id : var.vpc_id
#   tags        = var.security_group_tags
# }


# resource "aws_security_group_rule" "default" {
#   for_each = local.create_security_group ? var.security_group_rules : {}

#   type              = each.value.type
#   description       = try(each.value.description, "")
#   from_port         = try(each.value.from_port, -1)
#   to_port           = try(each.value.to_port, -1)
#   protocol          = each.value.protocol
#   cidr_blocks       = each.value.cidr_blocks
#   security_group_id = var.create_security_group ? aws_security_group.default[0].id : data.aws_security_group.default[0].id
# }


locals {
  elasticache_subnet_group_name = var.elasticache_subnet_group_name != "" ? var.elasticache_subnet_group_name : join("", aws_elasticache_subnet_group.default[*].name)

  # if !cluster, then node_count = replica cluster_size, if cluster then node_count = shard*(replica + 1)
  # Why doing this 'The "count" value depends on resource attributes that cannot be determined until apply'. So pre-calculating
  member_clusters_count = (var.cluster_mode_enabled
    ?
    (var.cluster_mode_num_node_groups * (var.cluster_mode_replicas_per_node_group + 1))
    :
    var.cluster_size
  )

  # elasticache_member_clusters = module.this.enabled ? tolist(aws_elasticache_replication_group.default[0].member_clusters) : []
}

resource "aws_elasticache_subnet_group" "default" {
  count       = module.this.enabled && var.create_subnet_group_name ? 1 : 0
  name        = var.subnet_group_name
  description = var.subnet_group_description != null ? var.subnet_group_description : "Elasticache subnet group for ${module.this.id}"
  subnet_ids  = coalesce(var.subnet_ids, data.aws_subnet.default[*].id, [])
  tags        = var.subnet_group_tags
}

resource "aws_elasticache_parameter_group" "default" {
  count       = module.this.enabled && var.create_parameter_group_name ? 1 : 0
  name        = var.parameter_group_name
  description = var.parameter_group_description != null ? var.parameter_group_description : "Elasticache parameter group for ${module.this.id}"
  family      = var.family

  dynamic "parameter" {
    for_each = var.parameter
    content {
      name  = parameter.value.name
      value = tostring(parameter.value.value)
    }
  }

  tags = var.parameter_group_tags

  # Ignore changes to the description since it will try to recreate the resource
  lifecycle {
    ignore_changes = [
      description,
    ]
  }
}

# data "aws_security_group" "default" {
#   count = module.this.enabled && var.security_group_name != "" ? 1 : 0
#   name  = var.security_group_name
# }

data "aws_security_group" "default" {
  for_each = module.this.enabled ? toset(var.security_groups) : []

  name   = each.key
  vpc_id = var.vpc_name != null ? data.aws_vpc.default[0].id : var.vpc_id
}

# data "aws_security_group" "default" {
#   name = "dev-redis-allow-ec2"
# }

resource "aws_elasticache_replication_group" "default" {
  count = module.this.enabled ? 1 : 0

  auth_token                  = var.transit_encryption_enabled ? var.auth_token : null
  replication_group_id        = var.replication_group_id == "" ? module.this.id : var.replication_group_id
  description                 = var.description
  node_type                   = var.instance_type
  num_cache_clusters          = var.num_cache_clusters
  port                        = var.port
  parameter_group_name        = var.parameter_group_name
  preferred_cache_cluster_azs = var.preferred_cache_cluster_azs
  automatic_failover_enabled  = var.automatic_failover_enabled
  multi_az_enabled            = var.multi_az_enabled
  subnet_group_name           = var.subnet_group_name
  # It would be nice to remove null or duplicate security group IDs, if there are any, using `compact`,
  # but that causes problems, and having duplicates does not seem to cause problems.
  # See https://github.com/hashicorp/terraform/issues/29799
  security_group_ids         = [for sg in data.aws_security_group.default : split("/", sg.arn)[length(split("/", sg.arn)) - 1]]
  security_group_names       = var.security_group_names
  maintenance_window         = var.maintenance_window
  notification_topic_arn     = var.notification_topic_arn
  engine_version             = var.engine_version
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled || var.auth_token != null
  kms_key_id                 = var.at_rest_encryption_enabled ? var.kms_key_id : null
  snapshot_name              = var.snapshot_name
  snapshot_arns              = var.snapshot_arns
  snapshot_window            = var.snapshot_window
  snapshot_retention_limit   = var.snapshot_retention_limit
  final_snapshot_identifier  = var.final_snapshot_identifier
  # apply_immediately          = var.apply_immediately
  data_tiering_enabled       = var.data_tiering_enabled
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configuration

    content {
      destination      = lookup(log_delivery_configuration.value, "destination", null)
      destination_type = lookup(log_delivery_configuration.value, "destination_type", null)
      log_format       = lookup(log_delivery_configuration.value, "log_format", null)
      log_type         = lookup(log_delivery_configuration.value, "log_type", null)
    }
  }

  tags = module.this.tags

  num_node_groups         = var.cluster_mode_enabled ? var.cluster_mode_num_node_groups : null
  replicas_per_node_group = var.cluster_mode_enabled ? var.cluster_mode_replicas_per_node_group : null
  user_group_ids          = var.user_group_ids
}

#
# CloudWatch Resources
#
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  count               = module.this.enabled && var.cloudwatch_metric_alarms_enabled ? local.member_clusters_count : 0
  alarm_name          = "${element(tolist(aws_elasticache_replication_group.default[0].member_clusters), count.index)}-cpu-utilization"
  alarm_description   = "Redis cluster CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"

  threshold = var.alarm_cpu_threshold_percent

  dimensions = {
    CacheClusterId = element(tolist(aws_elasticache_replication_group.default[0].member_clusters), count.index)
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  depends_on    = [aws_elasticache_replication_group.default]

  tags = module.this.tags
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  count               = module.this.enabled && var.cloudwatch_metric_alarms_enabled ? local.member_clusters_count : 0
  alarm_name          = "${element(tolist(aws_elasticache_replication_group.default[0].member_clusters), count.index)}-freeable-memory"
  alarm_description   = "Redis cluster freeable memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"

  threshold = var.alarm_memory_threshold_bytes

  dimensions = {
    CacheClusterId = element(tolist(aws_elasticache_replication_group.default[0].member_clusters), count.index)
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  depends_on    = [aws_elasticache_replication_group.default]

  tags = module.this.tags
}

