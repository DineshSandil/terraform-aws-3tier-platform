variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name for CloudWatch alarms"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name for CloudWatch alarms"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB for metrics"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the target group for metrics"
  type        = string
}

variable "rds_instance_id" {
  description = "RDS instance identifier for database metrics"
  type        = string
}

variable "ecs_cpu_threshold" {
  description = "Threshold percentage for ECS CPU utilization alarm"
  type        = number
  default     = 80
}

variable "ecs_memory_threshold" {
  description = "Threshold percentage for ECS memory utilization alarm"
  type        = number
  default     = 80
}

variable "alb_5xx_threshold" {
  description = "Threshold for ALB 5xx count per evaluation period"
  type        = number
  default     = 10
}

variable "alb_latency_threshold" {
  description = "Threshold in seconds for ALB target response time"
  type        = number
  default     = 1.0
}

variable "rds_cpu_threshold" {
  description = "Threshold percentage for RDS CPU utilization alarm"
  type        = number
  default     = 80
}

variable "rds_free_storage_threshold_bytes" {
  description = "Threshold in bytes for low RDS free storage alarm (default ~5GB)"
  type        = number
  default     = 5368709120
}

variable "alarm_email" {
  description = "Optional email address to subscribe to alert notifications"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "KMS Key ARN for encrypting SNS topic"
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
