variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "description" {
  description = "The description of the key as viewed in AWS console"
  type        = string
  default     = "KMS customer managed key for 3-tier platform encryption at rest"
}

variable "deletion_window_in_days" {
  description = "The waiting period, specified in number of days, before key deletion"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
