terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # When bootstrapping is completed, uncomment the remote state backend block:
  # backend "s3" {
  #   bucket         = "terraform-aws-3tier-platform-tfstate-xxxx"
  #   key            = "environments/prod/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-aws-3tier-platform-tflocks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
      CostCenter  = var.cost_center
    },
    var.tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# 1. KMS CUSTOMER MANAGED KEY
# ---------------------------------------------------------------------------------------------------------------------

module "kms" {
  source                  = "../../modules/kms"
  name_prefix             = local.name_prefix
  description             = "Production KMS Key for ${local.name_prefix} encryption at rest"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 2. S3 SUPPORTING / APPLICATION STORAGE
# ---------------------------------------------------------------------------------------------------------------------

module "s3" {
  source                 = "../../modules/s3"
  name_prefix            = local.name_prefix
  kms_key_arn            = module.kms.key_arn
  enable_versioning      = true
  enable_lifecycle_rules = true
  tags                   = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 3. VPC NETWORKING (HIGH AVAILABILITY: MULTI-AZ NAT GATEWAYS & EXTENDED FLOW LOGS)
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source                   = "../../modules/vpc"
  name_prefix              = local.name_prefix
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  single_nat_gateway       = var.single_nat_gateway
  enable_flow_logs         = true
  flow_logs_retention_days = 90
  kms_key_arn              = module.kms.key_arn
  tags                     = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 4. SECURITY GROUPS (TIERED ISOLATION)
# ---------------------------------------------------------------------------------------------------------------------

module "security_groups" {
  source         = "../../modules/security-groups"
  name_prefix    = local.name_prefix
  vpc_id         = module.vpc.vpc_id
  container_port = var.container_port
  db_port        = 5432
  tags           = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 5. SECRETS MANAGER (DATABASE CREDENTIALS GENERATION & STORAGE)
# ---------------------------------------------------------------------------------------------------------------------

module "secrets_manager" {
  source                  = "../../modules/secrets-manager"
  name_prefix             = local.name_prefix
  kms_key_arn             = module.kms.key_arn
  db_username             = "dbadmin"
  db_name                 = "appdb"
  db_host                 = module.rds.db_instance_address
  db_port                 = module.rds.db_instance_port
  recovery_window_in_days = 30
  tags                    = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 6. IAM ROLES (LEAST PRIVILEGE)
# ---------------------------------------------------------------------------------------------------------------------

module "iam" {
  source         = "../../modules/iam"
  name_prefix    = local.name_prefix
  secret_arns    = [module.secrets_manager.secret_arn]
  kms_key_arns   = [module.kms.key_arn]
  s3_bucket_arns = [module.s3.bucket_arn]
  tags           = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 7. ECR REPOSITORY (IMMUTABLE IMAGES IN PRODUCTION)
# ---------------------------------------------------------------------------------------------------------------------

module "ecr" {
  source               = "../../modules/ecr"
  name_prefix          = local.name_prefix
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  kms_key_arn          = module.kms.key_arn
  max_image_count      = 50
  tags                 = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 8. ACM CERTIFICATE (OPTIONAL BASED ON DOMAIN_NAME)
# ---------------------------------------------------------------------------------------------------------------------

module "acm" {
  source                    = "../../modules/acm"
  domain_name               = var.domain_name
  create_validation_records = false
  tags                      = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 9. APPLICATION LOAD BALANCER (DELETION PROTECTION ENABLED)
# ---------------------------------------------------------------------------------------------------------------------

module "alb" {
  source                     = "../../modules/alb"
  name_prefix                = local.name_prefix
  vpc_id                     = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.public_subnet_ids
  alb_security_group_id      = module.security_groups.alb_security_group_id
  container_port             = var.container_port
  certificate_arn            = module.acm.certificate_arn
  enable_deletion_protection = var.enable_deletion_protection
  tags                       = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 10. RDS POSTGRESQL (TIER 3: MULTI-AZ, DELETION PROTECTION, 30-DAY BACKUPS)
# ---------------------------------------------------------------------------------------------------------------------

module "rds" {
  source                      = "../../modules/rds"
  name_prefix                 = local.name_prefix
  db_subnet_group_name        = module.vpc.db_subnet_group_name
  rds_security_group_id       = module.security_groups.rds_security_group_id
  database_name               = "appdb"
  admin_username              = "dbadmin"
  admin_password              = module.secrets_manager.master_password
  engine_version              = var.rds_engine_version
  instance_class              = var.rds_instance_class
  allocated_storage           = var.rds_allocated_storage
  storage_type                = "gp3"
  multi_az                    = var.multi_az
  backup_retention_period     = var.backup_retention_period
  enable_deletion_protection  = var.enable_deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot
  kms_key_arn                 = module.kms.key_arn
  enable_performance_insights = true
  monitoring_interval         = 60
  tags                        = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 11. ECS FARGATE (TIER 2: APPLICATION)
# ---------------------------------------------------------------------------------------------------------------------

module "ecs" {
  source                    = "../../modules/ecs"
  name_prefix               = local.name_prefix
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_app_subnet_ids
  ecs_security_group_id     = module.security_groups.ecs_security_group_id
  target_group_arn          = module.alb.target_group_arn
  container_image           = var.container_image
  container_port            = var.container_port
  ecs_cpu                   = var.ecs_cpu
  ecs_memory                = var.ecs_memory
  desired_count             = var.ecs_desired_count
  task_execution_role_arn   = module.iam.ecs_task_execution_role_arn
  task_role_arn             = module.iam.ecs_task_role_arn
  enable_container_insights = true
  log_retention_days        = 90
  kms_key_arn               = module.kms.key_arn

  environment_variables = [
    {
      name  = "ENVIRONMENT"
      value = var.environment
    },
    {
      name  = "PORT"
      value = tostring(var.container_port)
    }
  ]

  secrets = [
    {
      name      = "DATABASE_URL"
      valueFrom = "${module.secrets_manager.secret_arn}:database_url::"
    },
    {
      name      = "DB_HOST"
      valueFrom = "${module.secrets_manager.secret_arn}:host::"
    },
    {
      name      = "DB_USER"
      valueFrom = "${module.secrets_manager.secret_arn}:username::"
    },
    {
      name      = "DB_PASS"
      valueFrom = "${module.secrets_manager.secret_arn}:password::"
    },
    {
      name      = "DB_NAME"
      valueFrom = "${module.secrets_manager.secret_arn}:dbname::"
    }
  ]

  tags = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 12. ECS AUTO SCALING (SCALES UP TO 10 TASKS IN PRODUCTION)
# ---------------------------------------------------------------------------------------------------------------------

module "autoscaling" {
  source                    = "../../modules/autoscaling"
  name_prefix               = local.name_prefix
  cluster_name              = module.ecs.cluster_name
  service_name              = module.ecs.service_name
  min_capacity              = var.ecs_min_capacity
  max_capacity              = var.ecs_max_capacity
  target_cpu_utilization    = var.target_cpu_utilization
  target_memory_utilization = var.target_memory_utilization
  tags                      = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 13. CLOUDWATCH ALARMS & OBSERVABILITY
# ---------------------------------------------------------------------------------------------------------------------

module "cloudwatch" {
  source                  = "../../modules/cloudwatch"
  name_prefix             = local.name_prefix
  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.service_name
  alb_arn_suffix          = module.alb.alb_arn
  target_group_arn_suffix = module.alb.target_group_arn
  rds_instance_id         = module.rds.db_instance_id
  ecs_cpu_threshold       = 80
  ecs_memory_threshold    = 80
  alb_5xx_threshold       = 10
  alb_latency_threshold   = 1.0
  rds_cpu_threshold       = 80
  alarm_email             = var.alarm_email
  kms_key_arn             = module.kms.key_arn
  tags                    = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 14. ROUTE 53 DNS (OPTIONAL)
# ---------------------------------------------------------------------------------------------------------------------

module "route53" {
  source           = "../../modules/route53"
  domain_name      = var.domain_name
  record_subdomain = var.record_subdomain
  create_zone      = false
  target_dns_name  = module.alb.alb_dns_name
  target_zone_id   = module.alb.alb_zone_id
  tags             = local.common_tags
}
