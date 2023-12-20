output "cloudwatch_log_group_name" {
  description = "Name of Cloudwatch log group"
  value       = try(aws_cloudwatch_log_group.this[0].name, "")
}

output "arn" {
  description = "ARN of Cloudwatch log group"
  value       = try(aws_cloudwatch_log_group.this[0].arn, "")
}

output "id" {
  description = "ARN of Cloudwatch log group"
  value       = try(aws_cloudwatch_log_group.this[0].name, "")
}
