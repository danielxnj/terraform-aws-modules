output "arn" {
  value       = join("", aws_iam_policy.default.*.arn)
  description = "The Amazon Resource Name (ARN) specifying the policy"
}
