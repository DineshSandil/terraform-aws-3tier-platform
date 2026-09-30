# ==============================================================================
# GitHub Actions OIDC Provider & Least-Privilege IAM Role
# Deploys AWS IAM OpenID Connect integration for GitHub Actions CI/CD workflows.
# ==============================================================================

variable "github_org" {
  description = "GitHub organization or username (e.g., your-username)"
  type        = string
  default     = "your-org"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "terraform-aws-3tier-platform"
}

# 1. GitHub OpenID Connect Identity Provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f8d264fcd9"]
}

# 2. IAM Role for GitHub Actions
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions-terraform-deployment-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
  description        = "IAM role assumed by GitHub Actions workflows via OIDC for Terraform deployments"

  tags = {
    Name      = "github-actions-terraform-deployment-role"
    ManagedBy = "Terraform"
    Purpose   = "CICD"
  }
}

# 3. Policy attachment for Terraform deployment permissions
resource "aws_iam_role_policy_attachment" "power_user" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

output "github_actions_role_arn" {
  description = "Add this ARN to GitHub Secrets as AWS_OIDC_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}
