variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Target deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "terraform-aws-3tier-platform"
}

variable "owner" {
  description = "Team or individual responsible for the resources"
  type        = string
  default     = "DevOps"
}

variable "cost_center" {
  description = "Cost center identifier for billing tracking"
  type        = string
  default     = "Engineering-3Tier"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
