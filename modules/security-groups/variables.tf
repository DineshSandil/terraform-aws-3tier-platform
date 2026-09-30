variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where security groups will be created"
  type        = string
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
  default     = 80
}

variable "db_port" {
  description = "The port PostgreSQL listens on"
  type        = number
  default     = 5432
}

variable "alb_ingress_cidr_blocks" {
  description = "List of CIDR blocks permitted to reach the ALB on HTTP/HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
