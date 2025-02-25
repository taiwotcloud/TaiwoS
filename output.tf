output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts."
  value       = aws_sns_topic.alerts.arn
}

output "cloudwatch_dashboard_url" {
  description = "URL to access the CloudWatch dashboard."
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.monitoring_dashboard.dashboard_name}"
}
