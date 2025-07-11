#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Setting up Kind cluster with ArgoCD..."

# Cleanup function for error handling
cleanup() {
    if [ $? -ne 0 ]; then
        echo "❌ Installation failed. To clean up, run: kind delete cluster --name gitops-lab"
    fi
}
trap cleanup EXIT

# Create Kind cluster if it doesn't exist
if ! kind get clusters | grep -q gitops-lab; then
    echo "📦 Creating Kind cluster..."
    if ! kind create cluster --config kind-cluster.yaml; then
        echo "❌ Failed to create Kind cluster"
        exit 1
    fi
else
    echo "✅ Kind cluster already exists"
fi

# Switch to Kind context
echo "🔄 Switching to Kind context..."
kubectl config use-context kind-gitops-lab

# Install ArgoCD
echo "🔧 Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD from upstream manifests with retry
echo "📥 Downloading and applying ArgoCD manifests..."
for i in {1..3}; do
    if kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml; then
        break
    fi
    echo "⏳ Retry $i/3 - waiting 10 seconds..."
    sleep 10
done

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-dex-server -n argocd

# Additional wait for ArgoCD to be fully functional
echo "⏳ Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=ready --timeout=300s pod -l app.kubernetes.io/name=argocd-server -n argocd

# Deploy ArgoCD Application for guestbook (GitOps way)
echo "� Creating ArgoCD Application for guestbook..."
if kubectl apply -f apps/guestbook-app.yaml; then
    echo "⏳ Waiting for ArgoCD to sync the application..."
    
    # Wait for application to be created
    sleep 10
    
    # Wait for guestbook namespace to be created by ArgoCD
    timeout=60
    while [ $timeout -gt 0 ]; do
        if kubectl get namespace guestbook &>/dev/null; then
            echo "✅ Guestbook namespace created by ArgoCD"
            break
        fi
        echo "⏳ Waiting for ArgoCD to create guestbook namespace..."
        sleep 5
        timeout=$((timeout - 5))
    done
    
    # Wait for deployment to be created and ready
    timeout=120
    while [ $timeout -gt 0 ]; do
        if kubectl get deployment guestbook-ui -n guestbook &>/dev/null; then
            echo "⏳ Waiting for guestbook deployment to be ready..."
            if kubectl wait --for=condition=available --timeout=60s deployment/guestbook-ui -n guestbook; then
                echo "✅ Guestbook application deployed successfully via ArgoCD"
                break
            fi
        fi
        echo "⏳ Waiting for ArgoCD to deploy guestbook application..."
        sleep 10
        timeout=$((timeout - 10))
    done
    
    if [ $timeout -le 0 ]; then
        echo "⚠️  Timeout waiting for ArgoCD to deploy guestbook, but ArgoCD Application is created"
    fi
else
    echo "⚠️  Failed to create ArgoCD Application, but ArgoCD is ready"
fi

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