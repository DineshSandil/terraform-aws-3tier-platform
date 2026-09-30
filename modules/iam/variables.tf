variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "secret_arns" {
  description = "List of Secrets Manager ARNs the ECS task execution role is allowed to access"
  type        = list(string)
  default     = []
}

variable "kms_key_arns" {
  description = "List of KMS Key ARNs the ECS task execution role is allowed to decrypt"
  type        = list(string)
  default     = []
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs the ECS task role is allowed to access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
