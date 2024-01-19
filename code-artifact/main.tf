resource "aws_codeartifact_domain" "this" {
  count = var.enabled ? 1 : 0
  domain = var.domain
  encryption_key = var.encryption_key
  tags = var.tags
}

resource "aws_codeartifact_domain_permissions_policy" "this" {
  count = var.enabled && var.domain_policy_document != null ? 1 : 0
  domain = aws_codeartifact_domain.this[0].domain
  policy_document = var.domain_policy_document
}

resource "aws_codeartifact_repository" "this" {
  for_each = var.enabled ? var.repositories : {}
  repository = each.value.repository
  domain     = aws_codeartifact_domain.this[0].domain
  description = each.value.description

  dynamic "external_connections" {
    for_each = each.value.external_connections
    content {
      external_connection_name = external_connections.value.external_connection_name
      package_format = external_connections.value.package_format
      status = external_connections.value.status
    }
    }

    dynamic "upstream" {
    for_each = each.value.upstreams
    content {
      repository_name = upstream.value.repository_name
    }
    }

    tags = each.value.tags
}

resource "aws_codeartifact_repository_permissions_policy" "this" {
  for_each = var.enabled ? var.repositories : {}
  domain = aws_codeartifact_domain.this[0].domain
  repository = aws_codeartifact_repository.this[each.key].repository
  policy_document = each.value.policy_document
}