# ---------------------------------------------------------------------------------------------------------------------
# IAM DATA SOURCES
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# 1. ECS TASK EXECUTION ROLE
# Used by the ECS agent / Fargate infrastructure to pull images from ECR,
# stream logs to CloudWatch, and fetch secrets/parameters at container launch time.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.name_prefix}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ecs-task-execution-role"
      Tier = "Application"
    }
  )
}

# Attach standard AWS managed task execution policy (ECR pull + basic CloudWatch logging)
resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Fine-grained policy for Secrets Manager and KMS decryption
data "aws_iam_policy_document" "ecs_task_execution_secrets" {
  statement {
    sid    = "AccessSecretsManager"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = length(var.secret_arns) > 0 ? var.secret_arns : ["*"]
  }

  dynamic "statement" {
    for_each = length(var.kms_key_arns) > 0 ? [1] : []
    content {
      sid    = "DecryptKmsSecrets"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey"
      ]
      resources = var.kms_key_arns
    }
  }
}

resource "aws_iam_policy" "ecs_task_execution_secrets" {
  name        = "${var.name_prefix}-ecs-secrets-policy"
  description = "Allows ECS Task Execution Role to fetch secrets and decrypt KMS keys"
  policy      = data.aws_iam_policy_document.ecs_task_execution_secrets.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_secrets.arn
}

# ---------------------------------------------------------------------------------------------------------------------
# 2. ECS TASK ROLE
# Used by the running application container code (least privilege, no administrative access).
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.name_prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ecs-task-role"
      Tier = "Application"
    }
  )
}

data "aws_iam_policy_document" "ecs_task_custom" {
  # Allow publishing application metrics to CloudWatch
  statement {
    sid    = "CloudWatchMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }

  # Allow S3 bucket operations if application buckets are specified
  dynamic "statement" {
    for_each = length(var.s3_bucket_arns) > 0 ? [1] : []
    content {
      sid    = "AppS3BucketAccess"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ]
      resources = concat(
        var.s3_bucket_arns,
        [for b in var.s3_bucket_arns : "${b}/*"]
      )
    }
  }
}

resource "aws_iam_policy" "ecs_task_custom" {
  name        = "${var.name_prefix}-ecs-app-policy"
  description = "Least privilege application permissions for ECS running tasks"
  policy      = data.aws_iam_policy_document.ecs_task_custom.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_custom" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_custom.arn
}
