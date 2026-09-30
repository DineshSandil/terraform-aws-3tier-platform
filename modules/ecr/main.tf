locals {
  repo_name = var.repository_name != "" ? var.repository_name : "${var.name_prefix}-app"
}

# ---------------------------------------------------------------------------------------------------------------------
# ECR REPOSITORY
# Secure container image registry with vulnerability scanning and lifecycle pruning.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "main" {
  name                 = local.repo_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.kms_key_arn != null ? "KMS" : "AES256"
    kms_key         = var.kms_key_arn
  }

  tags = merge(
    var.tags,
    {
      Name = local.repo_name
      Tier = "Application"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# LIFECYCLE POLICY
# Automatically prune untagged scratch builds and retain only the last N production images.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 14 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Retain only the latest ${var.max_image_count} tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "release", "build"]
          countType     = "imageCountMoreThan"
          countNumber   = var.max_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Fallback: retain last ${var.max_image_count} images of any tag"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
