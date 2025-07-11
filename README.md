# GitOps-Lab 

A comprehensive GitOps learning laboratory featuring multiple tools and workflows for modern DevOps practices.

## 📋 Overview

This repository contains hands-on demonstrations of popular GitOps tools and patterns:

- **Kind + ArgoCD**: Kubernetes-native GitOps with declarative deployments
- **Terraform + Atlantis**: Infrastructure as Code with automated PR workflows  
- **Flux**: GitOps toolkit with automatic image updates

## 🎯 Quick Start

```bash
# Clone the repository
git clone https://github.com/your-org/gitops-lab.git
cd gitops-lab

# Start Kind cluster with ArgoCD
make kind-argocd

# Verify ArgoCD is running
kubectl get pods -n argocd
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
# Kind + ArgoCD
make kind-argocd          # Start Kind cluster with ArgoCD
make argocd-port-forward  # Port-forward ArgoCD UI (localhost:8080)

# Atlantis
make atlantis-up          # Start Atlantis with Docker Compose
make atlantis-down        # Stop Atlantis

# Flux
make flux-bootstrap       # Bootstrap Flux in Kind cluster
make flux-reconcile       # Force reconciliation

# Utilities
make destroy              # Clean up all resources
make lint                 # Run linting checks
```

## 🔧 Prerequisites

- Docker
- Kind
- kubectl
- Terraform (for Atlantis demo)
- Flux CLI (for Flux demo)

## 📖 Learning Path

1. **Start with Kind + ArgoCD**: Learn declarative GitOps basics
2. **Explore Atlantis**: Understand Infrastructure as Code automation
3. **Try Flux**: Experience advanced GitOps with auto-updates

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

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