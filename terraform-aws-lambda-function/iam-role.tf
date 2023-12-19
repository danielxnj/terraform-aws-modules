# resource "aws_iam_role" "this" {
#   count = local.enabled && var.create_iam_role ? 1 : 0

#   name                 = var.iam_role_name
#   description          = var.iam_role_description
#   assume_role_policy   = var.assume_role_policy
#   permissions_boundary = var.permissions_boundary
#   path                 = var.iam_role_path
#   tags                 = var.iam_role_tags
# }

# data "aws_iam_policy_document" "assume_role_policy" {
#   count = local.enabled ? 1 : 0

#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = concat(["lambda.amazonaws.com"], var.lambda_at_edge_enabled ? ["edgelambda.amazonaws.com"] : [])
#     }
#   }
# }

# resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
#   count = local.enabled ? 1 : 0

#   policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
#   role       = data.aws_iam_role.this[0].name
# }

# resource "aws_iam_role_policy_attachment" "cloudwatch_insights" {
#   count = local.enabled && var.cloudwatch_lambda_insights_enabled ? 1 : 0

#   policy_arn = "arn:${local.partition}:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
#   role       = data.aws_iam_role.this[0].name
# }

# resource "aws_iam_role_policy_attachment" "vpc_access" {
#   count = local.enabled && var.vpc_config != null ? 1 : 0

#   policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
#   role       = data.aws_iam_role.this[0].name
# }

# resource "aws_iam_role_policy_attachment" "xray" {
#   count = local.enabled && var.tracing_config_mode != null ? 1 : 0

#   policy_arn = "arn:${local.partition}:iam::aws:policy/AWSXRayDaemonWriteAccess"
#   role       = data.aws_iam_role.this[0].name
# }

# # Allow Lambda to access specific SSM parameters
# data "aws_iam_policy_document" "ssm" {
#   count = try((local.enabled && var.ssm_parameter_names != null && length(var.ssm_parameter_names) > 0), false) ? 1 : 0

#   statement {
#     actions = [
#       "ssm:GetParameter",
#       "ssm:GetParameters",
#       "ssm:GetParametersByPath",
#     ]

#     resources = formatlist("arn:${local.partition}:ssm:${local.region_name}:${local.account_id}:parameter%s", var.ssm_parameter_names)
#   }
# }

# resource "aws_iam_policy" "ssm" {
#   count = try((local.enabled && var.ssm_parameter_names != null && length(var.ssm_parameter_names) > 0), false) ? 1 : 0

#   name        = "${var.function_name}-ssm-policy-${local.region_name}"
#   description = var.iam_policy_description
#   policy      = data.aws_iam_policy_document.ssm[count.index].json
# }

# resource "aws_iam_role_policy_attachment" "ssm" {
#   count = try((local.enabled && var.ssm_parameter_names != null && length(var.ssm_parameter_names) > 0), false) ? 1 : 0

#   policy_arn = aws_iam_policy.ssm[count.index].arn
#   role       = data.aws_iam_role.this[0].name
# }

# resource "aws_iam_role_policy_attachment" "custom" {
#   for_each = local.enabled && var.create_iam_role && length(var.iam_policy_arns) > 0 ? var.iam_policy_arns : toset([])

#   role       = data.aws_iam_role.this[0].name
#   policy_arn = each.key
# }
