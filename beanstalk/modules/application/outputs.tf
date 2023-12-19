output "elastic_beanstalk_application_name" {
  value       = aws_elastic_beanstalk_application.default[0].name
  description = "Elastic Beanstalk Application name"
}
