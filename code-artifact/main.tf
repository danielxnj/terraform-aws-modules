resource "aws_codeartifact_domain" "this" {
  count = var.enabled ? 1 : 0
  domain = var.domain
  encryption_key = var.encryption_key
  tags = var.tags
}

resource "aws_codeartifact_domain_permissions_policy" "this" {
  count = var.enabled && var.domain_policy_document != null ? 1 : 0
  domain = aws_codeartifact_domain[0].this.domain
  policy_document = var.domain_policy_document
  domain_owner = var.domain_policy_domain_owner
  policy_revision = var.domain_policy_revision

}

resource "aws_codeartifact_repository" "this" {
  count = var.enabled ? 1 : 0
  repository = var.repository
  domain     = aws_codeartifact_domain.this[0].domain
  description = var.description
  domain_owner = var.repository_domain_owner

  dynamic "external_connections" {
    for_each = var.external_connections
    content {
      external_connection_name = external_connections.value.external_connection_name
      package_format = external_connections.value.package_format
      status = external_connections.value.status
    }
    }

    dynamic "upstream" {
    for_each = var.upstreams
    content {
      repository_name = upstream.value.repository_name
    }
    }

    tags = var.repository_tags
}

resource "aws_codeartifact_repository_permissions_policy" "this" {
  count = var.enabled && var.repository_policy_document != null ? 1 : 0
  domain = aws_codeartifact_domain.this[0].domain
  repository = aws_codeartifact_repository.this[0].repository
  policy_document = var.repository_policy_document
  domain_owner = var.repository_policy_domain_owner
  policy_revision = var.repository_policy_revision
}