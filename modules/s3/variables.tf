variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "bucket_name" {
  description = "Custom S3 bucket name (will use name_prefix-assets if empty)"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN of KMS key used to encrypt the S3 bucket (AES256 used if null)"
  type        = string
  default     = null
}

variable "enable_versioning" {
  description = "Whether to enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_lifecycle_rules" {
  description = "Whether to enable automatic tiering and expiration lifecycle rules"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
