# ---------------------------------------------------------------------------------------------------------------------
# RDS PARAMETER GROUP (ENFORCE SSL IN TRANSIT)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_parameter_group" "main" {
  name        = "${var.name_prefix}-pg"
  family      = var.family
  description = "Custom parameter group for ${var.name_prefix} enforcing SSL/TLS in transit"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-pg"
      Tier = "Database"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS ENHANCED MONITORING IAM ROLE (OPTIONAL BASED ON INTERVAL)
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "rds_monitoring_assume" {
  count = var.monitoring_interval > 0 ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_monitoring" {
  count              = var.monitoring_interval > 0 ? 1 : 0
  name               = "${var.name_prefix}-rds-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.rds_monitoring_assume[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS POSTGRESQL INSTANCE
# Highly available, encrypted at rest, and isolated in private database subnets with no internet exposure.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_instance" "main" {
  identifier                      = "${var.name_prefix}-postgres"
  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.instance_class
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.max_allocated_storage
  storage_type                    = var.storage_type
  storage_encrypted               = true
  kms_key_id                      = var.kms_key_arn
  db_name                         = var.database_name
  username                        = var.admin_username
  password                        = var.admin_password
  port                            = 5432
  vpc_security_group_ids          = [var.rds_security_group_id]
  db_subnet_group_name            = var.db_subnet_group_name
  parameter_group_name            = aws_db_parameter_group.main.name
  multi_az                        = var.multi_az
  publicly_accessible             = false
  backup_retention_period         = var.backup_retention_period
  backup_window                   = var.backup_window
  maintenance_window              = var.maintenance_window
  auto_minor_version_upgrade      = true
  copy_tags_to_snapshot           = true
  deletion_protection             = var.enable_deletion_protection
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${var.name_prefix}-postgres-final-snapshot"
  performance_insights_enabled    = var.enable_performance_insights
  performance_insights_kms_key_id = var.enable_performance_insights ? var.kms_key_arn : null
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-postgres"
      Tier = "Database"
    }
  )
}
