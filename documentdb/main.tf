resource "random_password" "password" {
  count   = module.this.enabled && var.create_random_password ? 1 : 0
  length  = 16
  special = false
}

resource "aws_docdb_cluster" "default" {
  count                           = module.this.enabled ? 1 : 0
  cluster_identifier              = var.cluster_identifier
  master_username                 = var.master_username
  master_password                 = var.create_random_password ? random_password.password[0].result : try(var.master_password, null)
  backup_retention_period         = var.retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  final_snapshot_identifier       = var.final_snapshot_identifier
  skip_final_snapshot             = var.skip_final_snapshot
  deletion_protection             = var.deletion_protection
  apply_immediately               = var.apply_immediately
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id
  port                            = var.db_port
  snapshot_identifier             = var.snapshot_identifier
  vpc_security_group_ids          = var.vpc_security_group_ids
  db_subnet_group_name            = var.db_subnet_group_name
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  engine                          = var.engine
  engine_version                  = var.engine_version
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  tags                            = module.this.tags

  lifecycle {
    ignore_changes = [
      master_password
    ]
  }
}

resource "aws_docdb_cluster_instance" "default" {
  for_each = { for k, v in var.cluster_instances : k => v }

  identifier                   = each.value.identifier
  cluster_identifier           = join("", aws_docdb_cluster.default[*].id)
  apply_immediately            = try(each.value.apply_immediately, null)
  preferred_maintenance_window = each.value.preferred_maintenance_window
  instance_class               = each.value.instance_class
  engine                       = each.value.engine
  auto_minor_version_upgrade   = each.value.auto_minor_version_upgrade
  enable_performance_insights  = try(each.value.enable_performance_insights, null)
  promotion_tier               = each.value.promotion_tier
  tags                         = each.value.tags
}

resource "aws_docdb_subnet_group" "default" {
  count       = module.this.enabled && var.enable_aws_docdb_subnet_group ? 1 : 0
  name        = var.db_subnet_group_name
  description = var.db_subnet_group_description
  subnet_ids  = var.subnet_names != [] ? data.aws_subnet.default[*].id: var.subnet_ids
  tags        = var.db_subnet_group_tags
}

# https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html
resource "aws_docdb_cluster_parameter_group" "default" {
  count       = module.this.enabled && var.enable_aws_docdb_cluster_parameter_group ? 1 : 0
  name        = var.cluster_parameter_group_name
  description = var.cluster_parameter_group_description
  family      = var.cluster_family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  tags = var.cluster_parameter_group_tags
}
