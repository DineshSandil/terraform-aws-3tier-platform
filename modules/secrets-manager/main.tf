# ---------------------------------------------------------------------------------------------------------------------
# SECURE PASSWORD GENERATION
# ---------------------------------------------------------------------------------------------------------------------

resource "random_password" "master" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS SECRETS MANAGER SECRET
# Stores database credentials encrypted with KMS.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "db" {
  name_prefix             = "${var.name_prefix}-db-secret-"
  description             = "Database credentials and connection configuration for ${var.name_prefix}"
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-secret"
      Tier = "Security"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    engine       = "postgres"
    host         = var.db_host
    port         = var.db_port
    username     = var.db_username
    password     = random_password.master.result
    dbname       = var.db_name
    database_url = "postgresql://${var.db_username}:${random_password.master.result}@${var.db_host}:${var.db_port}/${var.db_name}"
  })
}
