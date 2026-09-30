data "aws_region" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP FOR ECS APPLICATION LOGS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.name_prefix}-app"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ecs-logs"
      Tier = "Observability"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-cluster"
      Tier = "Application"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS TASK DEFINITION (FARGATE)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.name_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.ecs_cpu)
  memory                   = tostring(var.ecs_memory)
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = var.environment_variables
      secrets     = var.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-task-def"
      Tier = "Application"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS SERVICE (DEPLOYED IN PRIVATE SUBNETS, NO PUBLIC IP)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_service" "main" {
  name                               = "${var.name_prefix}-service"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_execute_command             = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    # Ignore desired_count changes so AutoScaling target policies control scaling smoothly
    ignore_changes = [desired_count]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ecs-service"
      Tier = "Application"
    }
  )
}
