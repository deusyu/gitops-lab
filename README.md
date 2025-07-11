# GitOps-Lab 

[![CI/CD Status](https://github.com/your-org/gitops-lab/workflows/GitOps%20Lab%20CI/CD/badge.svg)](https://github.com/your-org/gitops-lab/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A comprehensive GitOps learning laboratory featuring multiple tools and workflows for modern DevOps practices.

## 📋 Overview

This repository contains hands-on demonstrations of popular GitOps tools and patterns:

- **Kind + ArgoCD**: Kubernetes-native GitOps with declarative deployments
- **Terraform + Atlantis**: Infrastructure as Code with automated PR workflows  
- **Flux**: GitOps toolkit with automatic image updates

## 🎯 Quick Start

```bash
# Clone the repository
git clone <your-repository-url>
cd gitops-lab

# Validate environment and dependencies
make validate-env

# Start Kind cluster with ArgoCD
make kind-argocd

# Run integration tests
make integration-test
```

## 🛠️ Available Demos

### 1. Kind + ArgoCD Demo
- Local Kubernetes cluster with ArgoCD
- Sample guestbook application
- Declarative GitOps workflows

### 2. Terraform + Atlantis Demo
- Infrastructure as Code automation
- PR-based Terraform workflows
- AWS S3 bucket provisioning example

### 3. Flux Image Auto-Update Demo
- Automatic image updates
- Helm-based deployments
- GitOps automation with Flux

## 📚 Make Commands

```bash
# Environment & Testing
make validate-env         # Validate environment configuration
make integration-test     # Run comprehensive integration tests
make lint                 # Run linting checks

# Kind + ArgoCD
make kind-argocd          # Start Kind cluster with ArgoCD
make argocd-port-forward  # Port-forward ArgoCD UI (localhost:8080)

# Atlantis (requires GITHUB_* env vars)
make atlantis-up          # Start Atlantis with Docker Compose
make atlantis-down        # Stop Atlantis

# Flux (requires GITHUB_OWNER and GITHUB_REPO env vars)
make flux-bootstrap       # Bootstrap Flux in Kind cluster
make flux-reconcile       # Force reconciliation

# Cleanup
make destroy              # Clean up all resources
```

## 🔧 Prerequisites

- Docker
- Kind
- kubectl
- Terraform (for Atlantis demo)
- Flux CLI (for Flux demo)

## ⚙️ Environment Configuration

### For Atlantis Demo:
```bash
export GITHUB_USER="your-github-username"
export GITHUB_TOKEN="your-github-token"
export GITHUB_WEBHOOK_SECRET="your-webhook-secret"
export ATLANTIS_REPO_ALLOWLIST="github.com/your-org/gitops-lab"
```

### For Flux Demo:
```bash
export GITHUB_OWNER="your-github-org"
export GITHUB_REPO="gitops-lab"
export GITHUB_TOKEN="your-github-token"
```

### For AWS Terraform Resources:
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"  # optional, defaults to us-east-1
```

## 📖 Learning Path

1. **Start with Kind + ArgoCD**: Learn declarative GitOps basics
2. **Explore Atlantis**: Understand Infrastructure as Code automation
3. **Try Flux**: Experience advanced GitOps with auto-updates

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## � CI/CD with GitHub Actions

This project includes comprehensive GitHub Actions workflows that:

- ✅ **Validate & Lint**: YAML, Terraform, Shell scripts, and Kubernetes resources
- ✅ **Test Kind + ArgoCD**: End-to-end cluster setup and application deployment
- ✅ **Test Atlantis**: Configuration validation and Terraform workflows  
- ✅ **Security Scanning**: Vulnerability scanning with Trivy
- ✅ **Integration Tests**: Full GitOps workflow validation
- ✅ **Documentation**: README-Makefile consistency checks

### Workflow Triggers:
- **Push to main/develop**: Full test suite including integration tests
- **Pull Requests**: Validation and testing (excludes integration tests)
- **Manual**: Can be triggered via GitHub UI

### View Results:
Check the [Actions tab](../../actions) to see test results and CI/CD status.

## �📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🆘 Troubleshooting

### Common Issues

- **Kind cluster not starting**: Check Docker is running
- **ArgoCD UI not accessible**: Ensure port-forward is active
- **Atlantis webhooks**: Configure GitHub webhook URL correctly

### Useful Commands

```bash
# Check Kind cluster status
kind get clusters

# View ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Reset everything
make destroy && make kind-argocd
```