output "key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.main.arn
}

output "key_id" {
  description = "The globally unique identifier for the key"
  value       = aws_kms_key.main.key_id
}

output "alias_arn" {
  description = "The ARN of the key alias"
  value       = aws_kms_alias.main.arn
}

output "alias_name" {
  description = "The name of the key alias"
  value       = aws_kms_alias.main.name
}
