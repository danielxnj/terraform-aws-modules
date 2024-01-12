output "id" {
  description = "Instance id"
  value       = aws_iam_instance_profile.this[0].name
}