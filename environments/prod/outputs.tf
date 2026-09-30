output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = module.vpc.private_db_subnet_ids
}

output "alb_dns_name" {
  description = "Publicly accessible DNS hostname of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS Service"
  value       = module.ecs.service_name
}

output "ecr_repository_url" {
  description = "URL of the ECR Docker repository"
  value       = module.ecr.repository_url
}

output "rds_endpoint" {
  description = "Endpoint address of the RDS PostgreSQL instance"
  value       = module.rds.db_instance_endpoint
}

output "rds_address" {
  description = "Hostname address of the RDS PostgreSQL instance"
  value       = module.rds.db_instance_address
}

output "rds_port" {
  description = "Port of the RDS PostgreSQL instance"
  value       = module.rds.db_instance_port
}

output "rds_database_name" {
  description = "Database name in PostgreSQL"
  value       = module.rds.db_name
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret storing database credentials"
  value       = module.secrets_manager.secret_arn
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch log group for ECS application logs"
  value       = module.ecs.log_group_name
}

output "route53_record_fqdn" {
  description = "Route 53 FQDN pointing to ALB (if configured)"
  value       = module.route53.fqdn
}

output "kms_key_arn" {
  description = "ARN of the customer managed KMS key"
  value       = module.kms.key_arn
}

output "s3_bucket_name" {
  description = "Name of the supporting S3 bucket"
  value       = module.s3.bucket_id
}

output "alarm_sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarm notifications"
  value       = module.cloudwatch.sns_topic_arn
}
