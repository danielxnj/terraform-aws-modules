output "arn" {
  value       = aws_elasticsearch_domain.default[0].arn
  description = "ARN of the Elasticsearch domain"
}

output "id" {
  value       = aws_elasticsearch_domain.default[0].domain_id
  description = "Unique identifier for the Elasticsearch domain"
}

