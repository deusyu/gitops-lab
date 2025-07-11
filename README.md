GitOps-Lab 🛠️🚀

Hands-on GitOps demos (Argo CD · Flux v2 · Atlantis + Terraform) bootstrapped with Cursor Agent. Fork / clone / run — each demo spins up in ≤10 min on a laptop.

⸻

📁 Repository Layout

.gitignore                → Ignore rules for Terraform, K8s, etc.
LICENSE                   → MIT
Makefile                  → One-liners: bootstrap / destroy / lint

.github/workflows/
└─ lint.yml               → yamllint + terraform fmt / validate

kind-argocd-demo/         → Kind cluster + Argo CD (guestbook app)
terraform-atlantis-demo/  → Atlantis container managing TF to AWS/localstack
flux-image-auto-demo/     → Flux v2 bootstrap + ImageUpdate automation

hack/                     → Helper scripts (e.g. bump-image.sh)


⸻

⚡ Quick Start (all demos)

Prerequisites: Docker ≥ 24 · kubectl · kind · Terraform 1.8 · flux CLI · (optional) AWS CLI + credentials. macOS/Linux both supported.

# 1. Clone & enter
$ git clone https://github.com/<you>/gitops-lab.git && cd gitops-lab

# 2. Bring up the Kind + Argo CD demo (⏱ 3-5 min)
$ make kind-argocd

# 3. Verify GitOps sync
$ kubectl -n guestbook get pods   # See guestbook pods running

Demo	Bootstrap	Verify	Destroy
Kind + Argo CD	make kind-argocd	Edit apps/guestbook/deployment.yaml image tag → commit → Argo auto-sync	make kind-destroy
Atlantis + Terraform	make atlantis-up	Create PR editing s3-bucket/main.tf → Atlantis plan/apply	make atlantis-down
Flux v2 Image Automation	make flux-bootstrap	Run hack/bump-image.sh → Flux raises PR → merge → auto rollout	make flux-destroy

⏳ Hint: Each Make target prints the exact commands so you can learn & tweak.

⸻

🧰 Demo Details

1. Kind + Argo CD
	•	Single-node Kind cluster (kind-cluster.yaml).
	•	Argo CD installed via upstream manifests.
	•	Sample guestbook app with Kustomize overlays — change image/tag and watch Argo reconcile.

2. Atlantis + Terraform
	•	docker-compose.yaml spins Atlantis + nginx reverse proxy.
	•	.atlantis.yaml defines workspaces; PR → plan comment → atlantis apply comment.
	•	Default module creates an S3 bucket (swap to localstack if no AWS creds).

3. Flux v2 Image Automation
	•	flux bootstrap github … creates flux-system/ and pushes back to repo.
	•	podinfo HelmRelease; Image Update Controller watches Docker Hub tags, opens PRs.
	•	Merge PR → Flux sync → rollout.

⸻

🛡  Security & Cost Notes
	•	Secrets → never commit raw creds — use Sealed Secrets / SOPS if moving to prod.
	•	Atlantis role is least privilege (create/read S3 only).
	•	All cloud resources live in us-east-1 and tag "gitops-lab-demo:true"; run make atlantis-down to avoid charges.

⸻

🧪 Lint & Drift Checks
	•	GitHub Actions lint.yml runs on every PR / push: yamllint + terraform fmt/validate.
	•	(Optional) nightly drift-plan.yml shows infra drift and comments on latest commit.

⸻

🤝 Contributing

Pull requests are welcome! Feel free to open issues for bugs & feature ideas. For larger changes, open a discussion first.

Dev Container / Codespaces

A .devcontainer.json is coming — run the demos entirely in browser.

⸻

📜 License

MIT © 2025 Rainman Deus — do what you want, have fun, give credit.