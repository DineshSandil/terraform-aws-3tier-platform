variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB and Target Group are deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for deploying the ALB across AZs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "container_port" {
  description = "Port on which the ECS tasks receive traffic"
  type        = number
  default     = 80
}

variable "certificate_arn" {
  description = "ARN of the ACM SSL/TLS certificate for HTTPS listener (optional)"
  type        = string
  default     = null
}

variable "health_check_path" {
  description = "HTTP path for target group health checks"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "HTTP response codes to indicate a healthy target"
  type        = string
  default     = "200-399"
}

variable "deregistration_delay" {
  description = "Time in seconds for targets to finish handling in-flight requests during deregistration"
  type        = number
  default     = 30
}

variable "enable_deletion_protection" {
  description = "Whether to prevent accidental deletion of the load balancer"
  type        = bool
  default     = false
}

variable "enable_access_logs" {
  description = "Whether to enable ALB access logging to S3"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
