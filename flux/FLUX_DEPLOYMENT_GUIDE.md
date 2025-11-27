# Flux CD Deployment Guide

This guide walks you through deploying the application using Flux CD after the infrastructure has been provisioned.

## Prerequisites

- ✅ AWS EKS cluster created via Terraform
- ✅ Flux CD installed on the cluster### 1. Apply Terraform Changes (Automated)

We have automated the Flux installation and bootstrapping process in Terraform.

**Prerequisite:** You need a GitHub Personal Access Token (PAT) with `repo` permissions.

```bash
cd terraform

# Export your GitHub PAT as an environment variable
export TF_VAR_github_token="ghp_your_token_here"

# Initialize and Apply
terraform init
terraform apply
```

### 2. GitHub Actions (Automated CI/CD)

If you use the included GitHub Actions workflow (`.github/workflows/create-infra.yml`), you must:

1.  Go to your GitHub Repository **Settings** > **Secrets and variables** > **Actions**.
2.  Create a **New repository secret**.
3.  Name: `GH_PAT`
4.  Value: Your GitHub Personal Access Token (with `repo` scope).

The workflow will automatically inject this token into Terraform to bootstrap Flux.

**What happens automatically:**
1.  **Installs Flux CD** components on the cluster.
2.  **Creates the `flux-git-auth` secret** using your token.
3.  **Bootstraps Flux** by applying the manifest files (`flux/sources/git-repository.yaml` and `flux/sync.yaml`).

> **Note**: You no longer need to manually run `kubectl apply` for the Flux manifests or manually create the secret!

### 2. Verify Deploymentput: All pods should be Running
# - source-controller
# - kustomize-controller
# - helm-controller
# - notification-controller
# - image-reflector-controller
# - image-automation-controller
```

### 3. Apply Flux Manifests

Apply the Flux CD manifests in order:

```bash
# Navigate to the repository root
cd /path/to/devops_playground

# Apply source configurations
kubectl apply -f flux/sources/

# Apply HelmRelease
kubectl apply -f flux/releases/

# Apply image automation
kubectl apply -f flux/image-automation/
```

### 4. Verify Flux Resources

```bash
# Check GitRepository
kubectl get gitrepository -n flux-system
# Should show: devops-playground-charts

# Check HelmRelease
kubectl get helmrelease -n flux-system
# Should show: devops-playground

# Check ImageRepository
kubectl get imagerepository -n flux-system
# Should show: backend, frontend

# Check ImagePolicy
kubectl get imagepolicy -n flux-system
# Should show: backend, frontend

# Check ImageUpdateAutomation
kubectl get imageupdateautomation -n flux-system
# Should show: devops-playground
```

### 5. Monitor Application Deployment

```bash
# Watch HelmRelease reconciliation
kubectl get helmrelease devops-playground -n flux-system -w

# Check application pods
kubectl get pods -n devops-playground -w

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=backend -n devops-playground --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n devops-playground --timeout=300s
```

### 6. Get Application URL

```bash
# Get the ingress URL
kubectl get ingress -n devops-playground

# The ADDRESS column shows your Load Balancer URL
# Example: a1234567890abcdef-1234567890.eu-north-1.elb.amazonaws.com
```

### 7. Test the Application

Open the ingress URL in your browser. You should see the Hex to RGB converter application.

## Monitoring Image Updates

### Watch for New Images

```bash
# Monitor image-reflector-controller logs
kubectl logs -n flux-system deployment/image-reflector-controller -f

# Check latest detected images
kubectl get imagerepository backend -n flux-system -o jsonpath='{.status.lastScanResult.latestTags[0]}'
kubectl get imagerepository frontend -n flux-system -o jsonpath='{.status.lastScanResult.latestTags[0]}'
```

### Trigger an Update

1. Push changes to the backend or frontend repository
2. Wait for CI to build and push new image to GHCR
3. Flux will detect the new image within 1 minute
4. Check for automated commit in this repository:
   ```bash
   git pull
   git log --oneline -5
   # Look for commits from "fluxcdbot"
   ```
5. Verify pods are updated:
   ```bash
   kubectl get pods -n devops-playground
   # Check the AGE column - new pods should be created
   ```

## Troubleshooting

### HelmRelease Stuck

```bash
# Check HelmRelease status
kubectl describe helmrelease devops-playground -n flux-system

# Check helm-controller logs
kubectl logs -n flux-system deployment/helm-controller -f

# Force reconciliation
kubectl annotate helmrelease devops-playground -n flux-system \
  reconcile.fluxcd.io/requestedAt="$(date +%s)" --overwrite
```

### Images Not Updating

```bash
# Check ImageRepository status (images are public, no auth needed)

# Check ImageRepository status
kubectl describe imagerepository backend -n flux-system
kubectl describe imagerepository frontend -n flux-system

# Check for errors in image-reflector-controller
kubectl logs -n flux-system deployment/image-reflector-controller --tail=50
```

### Automation Not Committing

```bash
# Check ImageUpdateAutomation status
kubectl describe imageupdateautomation devops-playground -n flux-system

# Check image-automation-controller logs
kubectl logs -n flux-system deployment/image-automation-controller --tail=50

# Common issue: Flux needs write access to the repository
# Make sure the GitRepository uses SSH with a deploy key that has write access
```

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n devops-playground

# Describe pod for events
kubectl describe pod <pod-name> -n devops-playground

# Check pod logs
kubectl logs <pod-name> -n devops-playground

# Common issues:
# - Image pull errors: Verify images are public and accessible
# - Resource limits: Check node capacity
```

## Cleanup

To remove the application:

```bash
# Delete Flux manifests
kubectl delete -f flux/image-automation/
kubectl delete -f flux/releases/
kubectl delete -f flux/sources/

# Delete the namespace
kubectl delete namespace devops-playground
```

To remove Flux CD entirely:

```bash
# Delete Flux namespace
kubectl delete namespace flux-system

# Or use Terraform to remove it
# (Comment out the flux helm_release in terraform/main.tf and apply)
```

## Next Steps

- Configure Slack/Discord notifications for deployments
- Set up monitoring with Prometheus/Grafana
- Implement canary deployments with Flagger
- Add automated testing before deployment
- Configure backup and disaster recovery
