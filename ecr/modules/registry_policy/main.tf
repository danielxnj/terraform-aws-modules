
################################################################################
# Registry Policy
################################################################################

resource "aws_ecr_registry_policy" "this" {
  count = var.create ? 1 : 0

  policy = var.registry_policy
}
