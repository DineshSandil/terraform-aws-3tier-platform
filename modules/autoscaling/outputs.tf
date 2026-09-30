output "autoscaling_target_id" {
  description = "The ID of the scalable target"
  value       = aws_appautoscaling_target.ecs.id
}

output "cpu_policy_arn" {
  description = "The ARN of the CPU scaling policy"
  value       = aws_appautoscaling_policy.cpu.arn
}

output "memory_policy_arn" {
  description = "The ARN of the memory scaling policy"
  value       = aws_appautoscaling_policy.memory.arn
}
