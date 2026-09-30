# ---------------------------------------------------------------------------------------------------------------------
# TIER 1: PRESENTATION / ALB SECURITY GROUP
# Exposes only HTTP (80) for redirect and HTTPS (443) to incoming client traffic.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer - allows public HTTP/HTTPS only"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound HTTP for redirection to HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
  }

  ingress {
    description = "Allow inbound HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic to targets and services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-alb-sg"
      Tier = "Presentation"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# TIER 2: APPLICATION / ECS SECURITY GROUP
# Accepts application traffic strictly from the ALB Security Group.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "ecs" {
  name        = "${var.name_prefix}-ecs-sg"
  description = "Security group for ECS tasks - permits ingress ONLY from ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow container port ingress from ALB SG only"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic for pulling images, logging, and external APIs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ecs-sg"
      Tier = "Application"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# TIER 3: DATABASE / RDS SECURITY GROUP
# Accepts PostgreSQL traffic strictly from the ECS Security Group. Never exposed to 0.0.0.0/0.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Security group for RDS PostgreSQL - permits ingress ONLY from ECS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow PostgreSQL access strictly from ECS Security Group"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rds-sg"
      Tier = "Database"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
