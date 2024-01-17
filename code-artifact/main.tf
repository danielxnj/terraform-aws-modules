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
}

resource "aws_codeartifact_repository" "this" {
  count = var.enabled ? 1 : 0
  repository = var.repository
  domain     = aws_codeartifact_domain[0].this.domain
}

resource "aws_codeartifact_repository_permissions_policy" "this" {
  count = var.enabled && var.repository_policy_document != null ? 1 : 0
  domain = aws_codeartifact_domain[0].this.domain
  repository = aws_codeartifact_repository[0].this.repository
  policy_document = var.repository_policy_document
}