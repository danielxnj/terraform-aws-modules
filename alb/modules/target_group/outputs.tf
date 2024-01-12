output "arn" {
    description = "The ARN of the target group"
    value       = aws_lb_target_group.this[0].arn
}