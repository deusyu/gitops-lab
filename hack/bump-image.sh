#!/usr/bin/env bash
set -euo pipefail

# Script to simulate bumping image tags for GitOps demos
# This demonstrates how image updates trigger GitOps workflows

echo "🏷️  Simulating image tag bump for GitOps demos..."

# Default values
APP_NAME="${1:-podinfo}"
CURRENT_TAG="${2:-6.4.0}"
NEW_TAG="${3:-6.4.1}"

case $APP_NAME in
  "podinfo")
    FILE="flux-image-auto-demo/apps/podinfo/helmrelease.yaml"
    echo "📝 Updating $FILE..."
    if [[ -f "$FILE" ]]; then
      # Update the image tag in the HelmRelease
      sed -i.bak "s/tag: $CURRENT_TAG/tag: $NEW_TAG/g" "$FILE"
      rm "$FILE.bak"
      echo "✅ Updated podinfo image tag from $CURRENT_TAG to $NEW_TAG"
    else
      echo "❌ File $FILE not found"
      exit 1
    fi
    ;;
  "guestbook")
    FILE="kind-argocd-demo/apps/guestbook/deployment.yaml"
    echo "📝 Updating $FILE..."
    if [[ -f "$FILE" ]]; then
      # Update the image tag in the deployment
      sed -i.bak "s/:$CURRENT_TAG/:$NEW_TAG/g" "$FILE"
      rm "$FILE.bak"
      echo "✅ Updated guestbook image tag from $CURRENT_TAG to $NEW_TAG"
    else
      echo "❌ File $FILE not found"
      exit 1
    fi
    ;;
  *)
    echo "❌ Unknown app: $APP_NAME"
    echo "Usage: $0 [podinfo|guestbook] [current_tag] [new_tag]"
    exit 1
    ;;
esac

echo ""
echo "🔄 To see the GitOps workflow in action:"
if [[ "$APP_NAME" == "podinfo" ]]; then
  echo "1. git add -A && git commit -m 'Update podinfo image to $NEW_TAG'"
  echo "2. git push origin main"
  echo "3. Watch Flux sync: flux get helmreleases -w"
else
  echo "1. git add -A && git commit -m 'Update guestbook image to $NEW_TAG'"
  echo "2. git push origin main"
  echo "3. Watch ArgoCD sync: kubectl get pods -n guestbook -w"
fi