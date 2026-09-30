#!/usr/bin/env bash
# ==============================================================================
# Terraform Remote State Bootstrapping Script
# Provisions an S3 bucket (with versioning, encryption, and public access block)
# and a DynamoDB table for distributed state locking across dev, staging, prod.
# ==============================================================================

set -euo pipefail

AWS_REGION="${1:-ap-south-1}"
PROJECT_NAME="${2:-terraform-aws-3tier-platform}"
RANDOM_SUFFIX=$(openssl rand -hex 4)
STATE_BUCKET="${PROJECT_NAME}-tfstate-${RANDOM_SUFFIX}"
LOCK_TABLE="${PROJECT_NAME}-tflocks"

echo "==================================================================="
echo "🚀 Bootstrapping Terraform Remote Backend"
echo "Region:          ${AWS_REGION}"
echo "S3 State Bucket: ${STATE_BUCKET}"
echo "DynamoDB Table:  ${LOCK_TABLE}"
echo "==================================================================="

# 1. Create S3 Bucket
echo "📦 Creating S3 bucket for remote state..."
if [ "${AWS_REGION}" = "us-east-1" ]; then
    aws s3api create-bucket \
        --bucket "${STATE_BUCKET}" \
        --region "${AWS_REGION}"
else
    aws s3api create-bucket \
        --bucket "${STATE_BUCKET}" \
        --region "${AWS_REGION}" \
        --create-bucket-configuration LocationConstraint="${AWS_REGION}"
fi

# 2. Enable Bucket Versioning (Essential for state file rollback and history)
echo "🔒 Enabling S3 bucket versioning..."
aws s3api put-bucket-versioning \
    --bucket "${STATE_BUCKET}" \
    --versioning-configuration Status=Enabled

# 3. Enable Default Encryption (KMS or AES256)
echo "🔑 Enabling server-side encryption on S3 bucket..."
aws s3api put-bucket-encryption \
    --bucket "${STATE_BUCKET}" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                },
                "BucketKeyEnabled": true
            }
        ]
    }'

# 4. Block All Public Access
echo "🛡️  Enforcing Public Access Block on state bucket..."
aws s3api put-public-access-block \
    --bucket "${STATE_BUCKET}" \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }'

# 5. Create DynamoDB Table for State Locking
echo "🗄️  Creating DynamoDB lock table with PAY_PER_REQUEST billing..."
aws dynamodb create-table \
    --table-name "${LOCK_TABLE}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${AWS_REGION}" \
    --tags Key=Project,Value="${PROJECT_NAME}" Key=ManagedBy,Value="TerraformBootstrap"

echo "⏳ Waiting for DynamoDB table creation..."
aws dynamodb wait table-exists --table-name "${LOCK_TABLE}" --region "${AWS_REGION}"

echo "==================================================================="
echo "✅ Remote State Backend successfully provisioned!"
echo ""
echo "To configure your environments, add the following backend block to:"
echo "environments/<env>/main.tf or backend.tf"
echo ""
cat <<EOF
terraform {
  backend "s3" {
    bucket         = "${STATE_BUCKET}"
    key            = "environments/\${var.environment}/terraform.tfstate"
    region         = "${AWS_REGION}"
    dynamodb_table = "${LOCK_TABLE}"
    encrypt        = true
  }
}
EOF
echo "==================================================================="
