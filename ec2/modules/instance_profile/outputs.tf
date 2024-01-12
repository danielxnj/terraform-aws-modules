output "name" {
  description = "Instance name"
  value       = aws_iam_instance_profile.this[0].name
}