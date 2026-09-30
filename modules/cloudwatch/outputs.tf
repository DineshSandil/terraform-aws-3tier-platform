output "sns_topic_arn" {
  description = "The ARN of the SNS topic for alarm notifications"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "The name of the SNS topic for alarm notifications"
  value       = aws_sns_topic.alerts.name
}

output "ecs_cpu_alarm_arn" {
  description = "The ARN of the ECS CPU alarm"
  value       = aws_cloudwatch_metric_alarm.ecs_cpu_high.arn
}

output "ecs_memory_alarm_arn" {
  description = "The ARN of the ECS memory alarm"
  value       = aws_cloudwatch_metric_alarm.ecs_memory_high.arn
}

output "alb_5xx_alarm_arn" {
  description = "The ARN of the ALB 5xx alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx_errors.arn
}

output "rds_cpu_alarm_arn" {
  description = "The ARN of the RDS CPU alarm"
  value       = aws_cloudwatch_metric_alarm.rds_cpu_high.arn
}
