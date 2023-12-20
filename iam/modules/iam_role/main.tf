
resource "aws_iam_role" "default" {
  count                = var.enabled ? 1 : 0
  name                 = var.role_name
  assume_role_policy   = var.assume_role_policy
  description          = var.role_description
  max_session_duration = var.max_session_duration
  permissions_boundary = var.permissions_boundary
  path                 = var.path
  dynamic "inline_policy" {
    for_each = var.inline_policies
    content {
      name   = inline_policy.value.name
      policy = inline_policy.value.policy
    }
  }
  tags = var.tags_enabled ? var.tags : null
}

resource "aws_iam_instance_profile" "default" {
  for_each = var.enabled ? { for role in var.instance_profiles : role.name => role } : {}
  name     = each.key
  role     = join("", aws_iam_role.default.*.name)
  path     = try(each.value.path, null)
  tags     = try(each.value.tags, {})
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = var.enabled ? { for k, v in var.managed_policy_arns : "${var.role_name}_${k}" => v } : {}
  role       = join("", aws_iam_role.default.*.name)
  policy_arn = each.value
}

