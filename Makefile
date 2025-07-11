.PHONY: help kind-argocd atlantis-up flux-bootstrap destroy lint argocd-port-forward atlantis-down flux-reconcile

help: ## Show this help message
	@echo "GitOps-Lab Makefile Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

validate-env: ## Validate environment configuration and dependencies
	@echo "🔍 Validating environment..."
	@chmod +x scripts/validate-env.sh
	@./scripts/validate-env.sh

integration-test: ## Run integration tests for GitOps lab
	@echo "🧪 Running integration tests..."
	@chmod +x scripts/integration-test.sh
	@./scripts/integration-test.sh

kind-argocd: ## Start Kind cluster with ArgoCD
	@echo "🚀 Starting Kind cluster with ArgoCD..."
	cd kind-argocd-demo && ./install-argocd.sh
	@echo "✅ ArgoCD is ready! Run 'make argocd-port-forward' to access UI"

argocd-port-forward: ## Port-forward ArgoCD UI to localhost:8080
	@echo "🌐 Port-forwarding ArgoCD UI to localhost:8080..."
	@echo "Default credentials: admin / $(shell kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo 'password-not-ready')"
	kubectl port-forward svc/argocd-server -n argocd 8080:443

atlantis-up: ## Start Atlantis with Docker Compose
	@echo "🐳 Starting Atlantis..."
	cd terraform-atlantis-demo && docker-compose up -d
	@echo "✅ Atlantis is running on http://localhost:4141"

atlantis-down: ## Stop Atlantis
	@echo "🛑 Stopping Atlantis..."
	cd terraform-atlantis-demo && docker-compose down

flux-bootstrap: ## Bootstrap Flux in Kind cluster
	@echo "🌊 Bootstrapping Flux..."
	@if ! kind get clusters | grep -q gitops-lab; then \
		echo "❌ Kind cluster not found. Run 'make kind-argocd' first"; \
		exit 1; \
	fi
	@if [ -z "$(GITHUB_OWNER)" ] || [ -z "$(GITHUB_REPO)" ]; then \
		echo "❌ Please set GITHUB_OWNER and GITHUB_REPO environment variables"; \
		echo "Example: GITHUB_OWNER=myorg GITHUB_REPO=gitops-lab make flux-bootstrap"; \
		exit 1; \
	fi
	cd flux-image-auto-demo && \
	flux bootstrap github \
		--owner=$(GITHUB_OWNER) \
		--repository=$(GITHUB_REPO) \
		--branch=main \
		--path=./flux-image-auto-demo/clusters/local \
		--personal || echo "Note: Configure your GitHub token with GITHUB_TOKEN env var"

flux-reconcile: ## Force Flux reconciliation
	@echo "🔄 Force reconciling Flux..."
	flux reconcile source git flux-system
	flux reconcile kustomization flux-system

destroy: ## Clean up all resources
	@echo "🧹 Cleaning up all resources..."
	-kind delete cluster --name gitops-lab
	-cd terraform-atlantis-demo && docker-compose down
	@echo "✅ All resources cleaned up"

lint: ## Run linting checks
	@echo "🔍 Running linting checks..."
	@if command -v yamllint >/dev/null 2>&1; then \
		yamllint -c .yamllint.yml . || echo "⚠️  YAML linting issues found"; \
	else \
		echo "⚠️  yamllint not installed, skipping YAML linting"; \
	fi
	@if command -v terraform >/dev/null 2>&1; then \
		cd terraform-atlantis-demo/s3-bucket && terraform fmt -check || echo "⚠️  Terraform formatting issues"; \
	else \
		echo "⚠️  Terraform not installed, skipping Terraform linting"; \
	fi
	@echo "✅ Linting completed"

# Default target
all: help