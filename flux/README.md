# Flux CD Configuration

This directory contains all Flux CD manifests for GitOps-based continuous deployment.

## Directory Structure

```
flux/
├── sync.yaml             # Kustomization to sync git to cluster
├── sources/              # Source repositories
│   └── git-repository.yaml          # GitRepository for this repo
├── releases/             # Helm releases
│   └── devops-playground.yaml       # HelmRelease for the application
└── image-automation/     # Image update automation
    ├── backend-registry.yaml        # ImageRepository for backend
    ├── backend-policy.yaml          # ImagePolicy for backend
    ├── frontend-registry.yaml       # ImageRepository for frontend
    ├── frontend-policy.yaml         # ImagePolicy for frontend
    └── image-update-automation.yaml # Automated git commits
```

## How It Works

### 1. Source Management
- **GitRepository** (`sources/git-repository.yaml`): Flux monitors this repository for Helm charts

### 2. Application Deployment
- **HelmRelease** (`releases/devops-playground.yaml`): Defines the desired state of the application
- Uses the Helm umbrella chart from `charts/devops-playground`
- Image tags are automatically updated by Flux

### 3. Image Automation
- **ImageRepository**: Monitors GHCR for new backend/frontend images (public repositories, no authentication needed)
- **ImagePolicy**: Defines which image tags to use (currently: latest alphabetically)
- **ImageUpdateAutomation**: Automatically commits updated image tags to git

## Setup Instructions

### Prerequisites
- EKS cluster running with Flux CD installed (via Terraform)
- `kubectl` configured to access the cluster

### Step 1: Apply Flux Manifests

```bash
# Apply via Terraform (Automated)
# Export your GitHub PAT
export TF_VAR_github_token="ghp_your_token_here"

# Apply Terraform
cd terraform
terraform apply

# This will automatically:
# 1. Install Flux
# 2. Create the authentication secret
# 3. Apply the manifests below
```

### Step 2: Verify Installation

```bash
# Check Flux components
kubectl get pods -n flux-system

# Check GitRepository
kubectl get gitrepository -n flux-system

# Check HelmRelease
kubectl get helmrelease -n flux-system

# Check ImageRepository
kubectl get imagerepository -n flux-system

# Check ImagePolicy
kubectl get imagepolicy -n flux-system

# Check application deployment
kubectl get pods -n devops-playground
```

## Monitoring

### Watch for Image Updates

```bash
# Monitor image-reflector-controller logs
kubectl logs -n flux-system deployment/image-reflector-controller -f

# Check latest detected images
kubectl get imagerepository -n flux-system -o yaml
```

### Check Image Policies

```bash
# View current image policies
kubectl get imagepolicy -n flux-system -o yaml
```

### Monitor Automation

```bash
# Check image update automation status
kubectl get imageupdateautomation -n flux-system -o yaml

# Watch for automated commits in git log
git log --oneline
```

## Workflow

1. **Developer pushes code** to backend/frontend repository
2. **CI builds and pushes** new Docker image to GHCR
3. **Flux detects new image** via ImageRepository (every 1 minute)
4. **ImagePolicy evaluates** if the new image matches the policy
5. **ImageUpdateAutomation commits** the new tag to `flux/releases/devops-playground.yaml`
6. **Flux detects git change** and reconciles HelmRelease
7. **Application is updated** with the new image

## Customization

### Change Image Tag Strategy

Edit the `ImagePolicy` files to use different tag selection strategies:

**Semantic Versioning:**
```yaml
spec:
  policy:
    semver:
      range: '>=1.0.0'
```

**Regex Pattern:**
```yaml
spec:
  policy:
    alphabetical:
      order: asc
    filterTags:
      pattern: '^v[0-9]+\.[0-9]+\.[0-9]+$'
```

### Adjust Sync Interval

Change the `interval` field in any resource to adjust how often Flux checks for updates:

```yaml
spec:
  interval: 5m  # Check every 5 minutes instead of 1 minute
```

## Troubleshooting

### HelmRelease not deploying

```bash
# Check HelmRelease status
kubectl describe helmrelease devops-playground -n flux-system

# Check helm-controller logs
kubectl logs -n flux-system deployment/helm-controller -f
```

### Images not updating

```bash
# Check if images are accessible (public repositories)

# Check ImageRepository status
kubectl describe imagerepository backend -n flux-system
kubectl describe imagerepository frontend -n flux-system

# Check image-reflector-controller logs
kubectl logs -n flux-system deployment/image-reflector-controller -f
```

### Automation not committing

```bash
# Check ImageUpdateAutomation status
kubectl describe imageupdateautomation devops-playground -n flux-system

# Check image-automation-controller logs
kubectl logs -n flux-system deployment/image-automation-controller -f
```

## Resources

- [Flux CD Documentation](https://fluxcd.io/docs/)
- [Image Automation Guide](https://fluxcd.io/docs/guides/image-update/)
- [HelmRelease API Reference](https://fluxcd.io/docs/components/helm/helmreleases/)
