# ---------------------------------------------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER
# Highly available across public subnets in multiple availability zones.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb" "main" {
  name                       = "${var.name_prefix}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_security_group_id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = true

  dynamic "access_logs" {
    for_each = var.enable_access_logs && var.access_logs_bucket != null ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = "alb-logs/${var.name_prefix}"
      enabled = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-alb"
      Tier = "Presentation"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# TARGET GROUP (TARGET TYPE: IP FOR ECS FARGATE)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_target_group" "main" {
  name                 = "${var.name_prefix}-tg"
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = var.deregistration_delay

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = var.health_check_matcher
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-tg"
      Tier = "Presentation"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# HTTP LISTENER (PORT 80)
# Redirects HTTP to HTTPS when an SSL certificate is provided; forwards to target group otherwise.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.certificate_arn != null && var.certificate_arn != "" ? [1] : []
    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.certificate_arn == null || var.certificate_arn == "" ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.main.arn
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-http-listener"
      Tier = "Presentation"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# HTTPS LISTENER (PORT 443)
# Terminated with ACM certificate using modern TLS 1.3 / 1.2 security policy.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != null && var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-https-listener"
      Tier = "Presentation"
    }
  )
}
