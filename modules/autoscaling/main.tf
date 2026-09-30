# ---------------------------------------------------------------------------------------------------------------------
# ECS APPLICATION AUTO SCALING TARGET
# Registers the ECS service as a scalable target with min and max bounds.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# ---------------------------------------------------------------------------------------------------------------------
# CPU TARGET TRACKING AUTOSCALING POLICY
# Dynamically adjusts task count to maintain CPU utilization near target threshold.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.name_prefix}-ecs-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.target_cpu_utilization
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MEMORY TARGET TRACKING AUTOSCALING POLICY
# Dynamically adjusts task count to maintain memory utilization near target threshold.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_appautoscaling_policy" "memory" {
  name               = "${var.name_prefix}-ecs-memory-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.target_memory_utilization
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}
