variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ECS service is deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for deploying ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID allowing traffic from ALB"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of ALB target group to route traffic to tasks"
  type        = string
}

variable "container_name" {
  description = "Name of the application container"
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Docker image for the application container"
  type        = string
  default     = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "ecs_cpu" {
  description = "CPU units for ECS task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512
}

variable "ecs_memory" {
  description = "Memory (MB) for ECS task (512, 1024, 2048, etc.)"
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Desired number of ECS tasks running in the service"
  type        = number
  default     = 2
}

variable "task_execution_role_arn" {
  description = "ARN of the IAM role allowing ECS agents to pull images and push logs"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the IAM role giving application code least-privilege AWS access"
  type        = string
}

variable "enable_container_insights" {
  description = "Whether to enable CloudWatch Container Insights for ECS cluster"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "KMS Key ARN for encrypting CloudWatch log group (optional)"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "List of environment variable maps ({ name = ..., value = ... })"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "List of secrets maps ({ name = ..., valueFrom = ... }) from Secrets Manager / SSM"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
