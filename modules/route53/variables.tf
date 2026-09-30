variable "domain_name" {
  description = "The root domain name (e.g. example.com). If empty, Route 53 resources will not be created."
  type        = string
  default     = ""
}

variable "record_subdomain" {
  description = "Subdomain prefix for the application (e.g. 'app' creates app.example.com; leave empty for apex domain)"
  type        = string
  default     = "app"
}

variable "create_zone" {
  description = "Whether to create a new Route 53 hosted zone (true) or use an existing one (false)"
  type        = bool
  default     = false
}

variable "target_dns_name" {
  description = "DNS name of the target load balancer (ALB)"
  type        = string
  default     = ""
}

variable "target_zone_id" {
  description = "Hosted zone ID of the target load balancer (ALB)"
  type        = string
  default     = ""
}

variable "evaluate_target_health" {
  description = "Whether Route 53 should evaluate the health of the target load balancer"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
