output "certificate_arn" {
  description = "The ARN of the validated ACM certificate"
  value       = try(aws_acm_certificate_validation.cert[0].certificate_arn, try(aws_acm_certificate.cert[0].arn, null))
}

output "certificate_domain" {
  description = "The domain name of the certificate"
  value       = try(aws_acm_certificate.cert[0].domain_name, null)
}
