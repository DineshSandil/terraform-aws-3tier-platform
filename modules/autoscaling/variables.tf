variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service to scale"
  type        = string
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks to maintain"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks to scale out to"
  type        = number
  default     = 10
}

variable "target_cpu_utilization" {
  description = "Target average CPU utilization percentage across tasks"
  type        = number
  default     = 60
}

variable "target_memory_utilization" {
  description = "Target average memory utilization percentage across tasks"
  type        = number
  default     = 70
}

variable "scale_in_cooldown" {
  description = "Cooldown period in seconds before allowing another scale-in action"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown period in seconds before allowing another scale-out action"
  type        = number
  default     = 60
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
