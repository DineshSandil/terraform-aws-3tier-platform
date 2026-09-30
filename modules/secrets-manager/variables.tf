variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key used to encrypt the secret"
  type        = string
  default     = null
}

variable "db_username" {
  description = "Master username for database credentials"
  type        = string
  default     = "dbadmin"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_host" {
  description = "Database hostname or address (optional, can be passed after RDS creation or updated)"
  type        = string
  default     = "localhost"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before permanent secret deletion"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
