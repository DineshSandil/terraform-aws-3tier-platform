variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "repository_name" {
  description = "Name of the ECR repository (defaults to name_prefix-app if empty)"
  type        = string
  default     = ""
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key to use for ECR encryption at rest (uses AES256 if null)"
  type        = string
  default     = null
}

variable "max_image_count" {
  description = "Maximum number of tagged images to retain before expiration"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
