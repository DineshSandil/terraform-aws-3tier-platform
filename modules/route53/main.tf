locals {
  enabled          = var.domain_name != "" && var.target_dns_name != ""
  full_record_name = var.record_subdomain != "" ? "${var.record_subdomain}.${var.domain_name}" : var.domain_name
  zone_id          = local.enabled ? (var.create_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.existing[0].zone_id) : ""
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE 53 HOSTED ZONE (LOOKUP OR CONDITIONAL CREATION)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "main" {
  count = var.domain_name != "" && var.create_zone ? 1 : 0
  name  = var.domain_name

  tags = merge(
    var.tags,
    {
      Name = var.domain_name
      Tier = "Networking"
    }
  )
}

data "aws_route53_zone" "existing" {
  count        = var.domain_name != "" && !var.create_zone ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE 53 ALIAS RECORDS (ALB INGRESS ROUTING)
# ---------------------------------------------------------------------------------------------------------------------

# A Record (IPv4 Alias)
resource "aws_route53_record" "alb_alias_a" {
  count   = local.enabled ? 1 : 0
  zone_id = local.zone_id
  name    = local.full_record_name
  type    = "A"

  alias {
    name                   = var.target_dns_name
    zone_id                = var.target_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

# AAAA Record (IPv6 Alias)
resource "aws_route53_record" "alb_alias_aaaa" {
  count   = local.enabled ? 1 : 0
  zone_id = local.zone_id
  name    = local.full_record_name
  type    = "AAAA"

  alias {
    name                   = var.target_dns_name
    zone_id                = var.target_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}
