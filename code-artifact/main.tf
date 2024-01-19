resource "aws_codeartifact_domain" "this" {
  count = var.enabled ? 1 : 0
  domain = var.domain
  encryption_key = var.encryption_key_alias != null? data.aws_kms_key.kms[0].arn :  var.encryption_key
  tags = var.tags
}

resource "aws_codeartifact_domain_permissions_policy" "this" {
  count = var.enabled && var.domain_policy_document != null ? 1 : 0
  domain = aws_codeartifact_domain.this[0].domain
  policy_document = var.domain_policy_document
}

resource "aws_codeartifact_repository" "this" {
  for_each = var.enabled ? var.repositories : null
  repository = each.key
  domain     = aws_codeartifact_domain.this[0].domain
  description = try(each.value.description, null)

  dynamic "external_connections" {
    for_each = try(each.value.external_connections, null) != null ? each.value.external_connections : []
    content {
      external_connection_name = external_connections.value.external_connection_name
      package_format = external_connections.value.package_format
      status = external_connections.value.status
    }
    }

    dynamic "upstream" {
    for_each = try(each.value.upstreams, null) != null ? each.value.upstreams : []
    content {
      repository_name = upstream.value.repository_name
    }
    }

    tags = try(each.value.tags, null)
}

resource "aws_codeartifact_repository_permissions_policy" "this" {
  for_each = var.enabled ? { for k, v in var.repositories : k => v if v != null && v.policy_document != null } : {}
  domain = aws_codeartifact_domain.this[0].domain
  repository = aws_codeartifact_repository.this[each.key].repository
  policy_document = each.value.policy_document
}
