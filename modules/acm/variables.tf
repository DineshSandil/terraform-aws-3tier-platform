variable "domain_name" {
  description = "The primary domain name for the ACM SSL certificate (leave empty if not using custom domain)"
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "Route 53 hosted zone ID for automatic DNS validation"
  type        = string
  default     = ""
}

variable "create_validation_records" {
  description = "Whether to automatically create Route 53 DNS validation records"
  type        = bool
  default     = true
}

variable "subject_alternative_names" {
  description = "List of Subject Alternative Names (SANs) for the certificate"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
