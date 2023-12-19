output "cloudfront_origin_access_identity_id" {
  description = "The IDS of the origin access identities created"
  value       = aws_cloudfront_origin_access_identity.this[0].id
}

output "cloudfront_origin_access_identity_iam_arn" {
  description = "The IAM arns of the origin access identities created"
  value       = aws_cloudfront_origin_access_identity.this[0].iam_arn
}

output "cloudfront_access_identity_path" {
  description = "The path of the origin access identities created"
  value       = aws_cloudfront_origin_access_identity.this[0].cloudfront_access_identity_path
}
