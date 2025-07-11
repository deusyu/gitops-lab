#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Setting up Kind cluster with ArgoCD..."

# Create Kind cluster if it doesn't exist
if ! kind get clusters | grep -q gitops-lab; then
    echo "📦 Creating Kind cluster..."
    kind create cluster --config kind-cluster.yaml
else
    echo "✅ Kind cluster already exists"
fi

# Switch to Kind context
kubectl config use-context kind-gitops-lab

# Install ArgoCD
echo "🔧 Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD from upstream manifests
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Create guestbook namespace
kubectl create namespace guestbook --dry-run=client -o yaml | kubectl apply -f -

# Apply guestbook application
kubectl apply -f apps/guestbook/

echo "✅ Setup complete!"
echo ""
echo "To access ArgoCD UI:"
echo "1. Run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "2. Open: https://localhost:8080"
echo "3. Username: admin"
echo "4. Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "To verify guestbook app:"
echo "kubectl get pods -n guestbook"