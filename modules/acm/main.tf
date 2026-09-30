# ---------------------------------------------------------------------------------------------------------------------
# ACM CERTIFICATE
# Configurable TLS certificate with DNS validation.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_acm_certificate" "cert" {
  count                     = var.domain_name != "" ? 1 : 0
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  tags = merge(
    var.tags,
    {
      Name = var.domain_name
      Tier = "Security"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE 53 DNS VALIDATION RECORDS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route53_record" "cert_validation" {
  for_each = (var.domain_name != "" && var.create_validation_records && var.zone_id != "") ? {
    for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

# ---------------------------------------------------------------------------------------------------------------------
# ACM CERTIFICATE VALIDATION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_acm_certificate_validation" "cert" {
  count                   = (var.domain_name != "" && var.create_validation_records && var.zone_id != "") ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
