# Lab 2: Multi-Environment Mastery

## Introduction

In the real world, you don't deploy straight to production. You need development, staging, and production environments - each with their own configurations, resource limits, and replicas. The challenge is managing these differences without duplicating manifests everywhere.

In this lab, you'll use Kustomize overlays to manage multiple environments from a single set of base manifests. You'll build a promotion workflow that gives you confidence, not anxiety.

## Objectives

By the end of this lab, you will be able to:

- Structure a GitOps repository for multiple environments
- Use Kustomize base and overlays for environment-specific configuration
- Deploy the same application to dev, staging, and production with different settings
- Implement a promotion workflow between environments
- Understand common repository structures and when to use each

## Prerequisites

- Completion of [Lab 1: Your First GitOps Pipeline](1-first-pipeline.md)
- Understanding of Flux GitRepository and Kustomization resources

!!! warning
    Execute `cd ../002-multi-environment` to navigate to this lab directory

## Lab Tasks

### Task 1: Understanding the Repository Structure

Let's examine the multi-environment structure we'll be working with:

```bash
# View the directory structure
find . -type f -name "*.yaml" | sort
```

The structure follows a base-and-overlays pattern:

```
002-multi-environment/
├── base/
│   ├── kustomization.yaml
│   ├── namespace.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── dev/
    │   ├── kustomization.yaml
    │   └── patch-replicas.yaml
    ├── staging/
    │   ├── kustomization.yaml
    │   └── patch-replicas.yaml
    └── production/
        ├── kustomization.yaml
        ├── patch-replicas.yaml
        └── patch-resources.yaml
```

!!! info
    The **base** directory contains the common manifests shared across all environments. Each **overlay** directory contains environment-specific patches that modify the base. This approach eliminates duplication while allowing environment-specific customisation.

Let's examine the base manifests:

```bash
# View the base kustomization
cat base/kustomization.yaml

# View the base deployment
cat base/deployment.yaml

# View the base service
cat base/service.yaml
```

Now examine the overlay patches:

```bash
# Dev overlay - minimal resources, single replica
cat overlays/dev/kustomization.yaml
cat overlays/dev/patch-replicas.yaml

# Staging overlay - moderate resources, 2 replicas
cat overlays/staging/kustomization.yaml
cat overlays/staging/patch-replicas.yaml

# Production overlay - full resources, 3 replicas, resource limits
cat overlays/production/kustomization.yaml
cat overlays/production/patch-replicas.yaml
cat overlays/production/patch-resources.yaml
```

### Task 2: Deploying to the Dev Environment

Let's start by deploying to the dev environment. First, create the Flux Kustomization:

```bash
# View the dev Flux Kustomization
cat flux/dev-kustomization.yaml
```

```yaml
# flux/dev-kustomization.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: app-dev
  namespace: flux-system
spec:
  interval: 5m
  path: ./examples/002-multi-environment/overlays/dev
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  wait: true
  timeout: 2m
```

Apply the dev Kustomization:

```bash
kubectl apply -f flux/dev-kustomization.yaml
```

Wait for the deployment and verify:

```bash
# Watch the reconciliation
flux get kustomizations --watch

# Check what was deployed
kubectl get all -n app-dev
```

!!! note
    Notice the dev environment has a single replica and minimal resource requests. This keeps development costs low while still running the full application stack.

### Task 3: Deploying to Staging

Now let's deploy to staging:

```bash
# View the staging Flux Kustomization
cat flux/staging-kustomization.yaml

# Apply the staging Kustomization
kubectl apply -f flux/staging-kustomization.yaml

# Watch the reconciliation
flux get kustomizations --watch

# Check what was deployed
kubectl get all -n app-staging
```

Compare the dev and staging deployments:

```bash
# Compare replica counts
echo "Dev replicas:"
kubectl get deployment nginx -n app-dev -o jsonpath='{.spec.replicas}'
echo ""
echo "Staging replicas:"
kubectl get deployment nginx -n app-staging -o jsonpath='{.spec.replicas}'
echo ""
```

### Task 4: Deploying to Production

Finally, let's deploy to production:

```bash
# View the production Flux Kustomization
cat flux/production-kustomization.yaml

# Apply the production Kustomization
kubectl apply -f flux/production-kustomization.yaml

# Watch the reconciliation
flux get kustomizations --watch

# Check what was deployed
kubectl get all -n app-production
```

Compare all three environments:

```bash
# Compare deployments across environments
for env in dev staging production; do
  echo "=== $env ==="
  kubectl get deployment nginx -n app-$env -o jsonpath='{.spec.replicas} replicas, image: {.spec.template.spec.containers[0].image}'
  echo ""
  kubectl get deployment nginx -n app-$env -o jsonpath='resources: {.spec.template.spec.containers[0].resources}'
  echo ""
  echo ""
done
```

!!! info
    Same application, same base manifests, but each environment has appropriate settings:

    - **Dev**: 1 replica, minimal resources - fast iteration, low cost
    - **Staging**: 2 replicas, moderate resources - mirrors production structure
    - **Production**: 3 replicas, full resources with limits - reliability and performance

### Task 5: Simulating a Promotion Workflow

In a real GitOps workflow, promoting from dev to staging to production happens through Git. Let's simulate updating the application image version across environments.

First, update the dev overlay with a new image tag:

```bash
# Update the image in the dev overlay
cd overlays/dev
cat > patch-image.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  template:
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
EOF

# Add the patch to the dev kustomization
```

Edit the dev `kustomization.yaml` to include the new patch:

```bash
cat > kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: app-dev
resources:
  - ../../base
patches:
  - path: patch-replicas.yaml
  - path: patch-image.yaml
EOF
```

Commit and push:

```bash
cd ../../..
git add .
git commit -m "feat: update dev to nginx 1.27-alpine"
git push origin main
```

Reconcile and verify:

```bash
flux reconcile source git flux-system
flux reconcile kustomization app-dev

# Verify the image was updated in dev
kubectl get deployment nginx -n app-dev -o jsonpath='{.spec.template.spec.containers[0].image}'
```

!!! tip
    In a production workflow, you would:

    1. Create a PR to update the image in the dev overlay
    2. After testing in dev, create another PR to update the staging overlay
    3. After testing in staging, create a final PR to update the production overlay

    Each promotion is a Git commit with a clear audit trail. No manual `kubectl` commands needed.

### Task 6: Understanding Repository Structures

There are two common approaches for structuring GitOps repositories:

**Monorepo (what we're using)**
```
repo/
├── apps/
│   ├── base/
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── production/
└── infrastructure/
    ├── base/
    └── overlays/
```

**Repo-per-environment**
```
app-config-dev/        # Dev environment repository
app-config-staging/    # Staging environment repository
app-config-production/ # Production environment repository
```

!!! info
    **Monorepo** works well for teams of 5-15. Everything is in one place, easy to see the full picture, and promotion is a directory-level change.

    **Repo-per-environment** works better for teams of 50+. It provides stronger access control (who can push to the production repo) and clearer separation of concerns.

    Choose based on your team size and security requirements, not on what looks more sophisticated.

### Task 7: Cleanup

Before moving to the next lab, clean up all environment deployments:

```bash
# Delete all Kustomizations
kubectl delete kustomization app-dev app-staging app-production -n flux-system

# Verify resources are cleaned up
kubectl get all -n app-dev
kubectl get all -n app-staging
kubectl get all -n app-production
flux get kustomizations
```

## Lab Validation

Let's confirm you've mastered the key concepts from this lab:

- You understand how Kustomize base and overlays work for multi-environment management
- You can deploy the same application with different configurations per environment
- You understand how promotion workflows work through Git commits
- You know the trade-offs between monorepo and repo-per-environment structures

## Summary

Congratulations! You have completed Lab 2 of the GitOps Fundamentals Workshop. In this lab, you've learned:

1. How to structure a repository for multiple environments using Kustomize
2. How base manifests and overlay patches eliminate duplication
3. How to deploy to dev, staging, and production with environment-specific configuration
4. How promotion workflows use Git commits to move changes between environments
5. The trade-offs between different repository structures

This pattern is the foundation of enterprise GitOps. Every organisation that "gets it" uses some variation of this approach.

## Next Steps

Proceed to [Lab 3: Helm Integration](3-helm-integration.md) to learn how to manage Helm charts the GitOps way.
