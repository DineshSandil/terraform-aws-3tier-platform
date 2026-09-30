#!/usr/bin/env bash
# ==============================================================================
# Comprehensive Terraform Validation & Linting Script
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

echo "==================================================================="
echo "🔍 Running Terraform Quality & Validation Checks"
echo "Directory: ${ROOT_DIR}"
echo "==================================================================="

# 1. Format check
echo "➡️  Checking Terraform code formatting..."
if terraform fmt -check -recursive; then
    echo "✅ Formatting check passed!"
else
    echo "❌ Formatting errors detected. Run 'terraform fmt -recursive' to fix."
    exit 1
fi

# 2. Validate Root Module
echo ""
echo "➡️  Validating root module..."
terraform init -backend=false > /dev/null
terraform validate
echo "✅ Root module is valid!"

# 3. Validate Environments
for env in dev staging prod; do
    echo ""
    echo "➡️  Validating environments/${env}..."
    cd "${ROOT_DIR}/environments/${env}"
    terraform init -backend=false > /dev/null
    terraform validate
    echo "✅ environments/${env} is valid!"
    cd "${ROOT_DIR}"
done

# 4. Security Scanning (Checkov / tfsec if available)
echo ""
echo "➡️  Checking for Security Linters..."
if command -v tfsec &> /dev/null; then
    echo "🛡️  Running tfsec..."
    tfsec .
elif command -v checkov &> /dev/null; then
    echo "🛡️  Running checkov..."
    checkov -d . --framework terraform
else
    echo "ℹ️  tfsec/checkov not detected locally. (Security scans are configured in CI/CD pipeline)."
fi

echo ""
echo "==================================================================="
echo "🎉 ALL VALIDATION CHECKS COMPLETED SUCCESSFULLY!"
echo "==================================================================="
