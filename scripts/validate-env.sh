#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Validating environment configuration..."

# Track validation errors
ERRORS=0

# Function to check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "❌ Required command '$1' not found"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ Found: $1"
    fi
}

# Function to check environment variable
check_env_var() {
    local var_name="$1"
    local required="${2:-false}"
    local description="${3:-}"
    
    # Use eval to safely check variable
    local var_value
    var_value=$(eval echo \$"$var_name" 2>/dev/null || echo "")
    
    if [ -z "$var_value" ]; then
        if [ "$required" = "true" ]; then
            echo "❌ Required environment variable '$var_name' is not set"
            [ -n "$description" ] && echo "   $description"
            ERRORS=$((ERRORS + 1))
        else
            echo "⚠️  Optional environment variable '$var_name' is not set"
            [ -n "$description" ] && echo "   $description"
        fi
    else
        echo "✅ $var_name is set"
    fi
}

echo ""
echo "📋 Checking required tools..."
check_command "docker"
check_command "kind"
check_command "kubectl"
check_command "make"

echo ""
echo "📋 Checking optional tools..."
check_command "terraform" || echo "   (Required for Atlantis demo)"
check_command "flux" || echo "   (Required for Flux demo)"
check_command "yamllint" || echo "   (Required for linting)"

echo ""
echo "📋 Checking environment variables for Atlantis demo..."
check_env_var "GITHUB_USER" false "Required for Atlantis GitHub integration"
check_env_var "GITHUB_TOKEN" false "Required for Atlantis GitHub integration"
check_env_var "GITHUB_WEBHOOK_SECRET" false "Used for GitHub webhook security"
check_env_var "ATLANTIS_REPO_ALLOWLIST" false "Controls which repos Atlantis can access"

echo ""
echo "📋 Checking environment variables for Flux demo..."
check_env_var "GITHUB_OWNER" false "Required for Flux bootstrap"
check_env_var "GITHUB_REPO" false "Required for Flux bootstrap"

echo ""
echo "📋 Checking AWS credentials for Terraform demo..."
check_env_var "AWS_ACCESS_KEY_ID" false "Required for AWS Terraform resources"
check_env_var "AWS_SECRET_ACCESS_KEY" false "Required for AWS Terraform resources"
check_env_var "AWS_REGION" false "AWS region for resources (defaults to us-east-1)"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ Environment validation passed!"
    echo ""
    echo "🚀 You can now run:"
    echo "   make kind-argocd    # Start Kind cluster with ArgoCD"
    echo "   make atlantis-up    # Start Atlantis (set GitHub env vars first)"
    echo "   make flux-bootstrap # Bootstrap Flux (set GITHUB_OWNER and GITHUB_REPO first)"
else
    echo "❌ Environment validation failed with $ERRORS errors"
    echo ""
    echo "📝 To fix the issues:"
    echo "   1. Install missing tools"
    echo "   2. Set required environment variables"
    echo "   3. Run this script again"
    exit 1
fi