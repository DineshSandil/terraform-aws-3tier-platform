variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group in private database subnets"
  type        = string
}

variable "rds_security_group_id" {
  description = "Security group ID allowing access ONLY from ECS security group"
  type        = string
}

variable "database_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "appdb"
}

variable "admin_username" {
  description = "Master username for PostgreSQL database"
  type        = string
  default     = "dbadmin"
}

variable "admin_password" {
  description = "Master password for PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "family" {
  description = "DB parameter group family (e.g., postgres15)"
  type        = string
  default     = "postgres15"
}

variable "instance_class" {
  description = "Compute and memory capacity of the RDS instance"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in gibibytes (GiB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for storage autoscaling (GiB)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (gp3, gp2, io1)"
  type        = string
  default     = "gp3"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Daily time range during which automated backups are created"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Weekly time range during which system maintenance can occur"
  type        = string
  default     = "Sun:04:30-Sun:05:30"
}

variable "enable_deletion_protection" {
  description = "If true, database cannot be deleted accidentally"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB is deleted"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for RDS storage encryption"
  type        = string
  default     = null
}

variable "enable_performance_insights" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "Enhanced Monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
