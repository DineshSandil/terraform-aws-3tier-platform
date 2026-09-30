output "zone_id" {
  description = "The ID of the Route 53 hosted zone"
  value       = local.zone_id
}

output "zone_name" {
  description = "The name of the Route 53 hosted zone"
  value       = var.domain_name
}

output "fqdn" {
  description = "Fully qualified domain name pointing to ALB"
  value       = local.enabled ? local.full_record_name : null
}
