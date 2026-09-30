variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "terraform-aws-3tier-platform"
}

variable "owner" {
  description = "Resource owner team"
  type        = string
  default     = "DevOps"
}

variable "cost_center" {
  description = "Cost Center code"
  type        = string
  default     = "DevOps-Production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs for subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "Private application subnet CIDRs"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "Private database subnet CIDRs"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "single_nat_gateway" {
  description = "Set to false in production for Multi-AZ NAT Gateway redundancy"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Custom root domain name (optional)"
  type        = string
  default     = ""
}

variable "record_subdomain" {
  description = "Subdomain prefix for production environment (e.g., 'app')"
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Container image URI"
  type        = string
  default     = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 80
}

variable "ecs_cpu" {
  description = "ECS Task CPU allocation"
  type        = number
  default     = 1024
}

variable "ecs_memory" {
  description = "ECS Task Memory allocation (MB)"
  type        = number
  default     = 2048
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 3
}

variable "ecs_min_capacity" {
  description = "Minimum ECS task count"
  type        = number
  default     = 3
}

variable "ecs_max_capacity" {
  description = "Maximum ECS task count"
  type        = number
  default     = 10
}

variable "target_cpu_utilization" {
  description = "Target average CPU utilization percentage"
  type        = number
  default     = 60
}

variable "target_memory_utilization" {
  description = "Target average Memory utilization percentage"
  type        = number
  default     = 70
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "rds_instance_class" {
  description = "RDS instance class (Production grade)"
  type        = string
  default     = "db.r6g.large"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage (GiB)"
  type        = number
  default     = 100
}

variable "backup_retention_period" {
  description = "Automated backup retention days (30 days for production)"
  type        = number
  default     = 30
}

variable "multi_az" {
  description = "Enable RDS Multi-AZ high availability"
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on RDS and ALB in production"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Must be false in production to ensure safety snapshot is taken upon decommission"
  type        = bool
  default     = false
}

variable "alarm_email" {
  description = "Production alert notification email"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
