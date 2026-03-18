# Lab 1: Your First GitOps Pipeline

## Introduction

Welcome to your first hands-on lab with GitOps! In this lab, you will connect your Kubernetes cluster to a Git repository using Flux, deploy your first application through a pull request, and watch automated reconciliation in action. This is the foundation everything else in the workshop builds upon.

By the end of this lab, you'll understand why GitOps is fundamentally different from traditional CI/CD - and why that difference matters.

## Objectives

By the end of this lab, you will be able to:

- Understand the Flux architecture and its core components
- Verify a Flux installation on a Kubernetes cluster
- Create a GitRepository source that watches your repository
- Deploy an application using a Kustomization resource
- Make changes through a pull request and watch reconciliation happen
- Inspect Flux resources and understand their status

## Prerequisites

- Access to your assigned Kubernetes cluster with Flux installed
- Access to your dedicated GitHub repository
- Basic familiarity with Git and Kubernetes

!!! warning
    Execute `cd 001-first-pipeline` to navigate to this lab directory

## Lab Environment Validation

Let's first ensure Flux is running correctly on your cluster:

```bash
# Check Flux components are healthy
flux check

# View the Flux system namespace
kubectl get pods -n flux-system
```

You should see the following controllers running:

- `source-controller` - Fetches artifacts from sources (Git, Helm, OCI)
- `kustomize-controller` - Reconciles Kustomization resources
- `helm-controller` - Reconciles HelmRelease resources
- `notification-controller` - Handles events and alerts

!!! info
    These four controllers form the core of Flux. Each has a specific responsibility, and together they create a powerful reconciliation loop that keeps your cluster in sync with Git.

## Lab Tasks

### Task 1: Connect Flux to Your Repository

Before Flux can watch your Git repository, it needs credentials. You'll create a Kubernetes Secret containing the Personal Access Token (PAT) from your instructions page.

!!! warning
    You will need the **PAT** from your participant instructions page for this step. If you've closed the page, refer back to the URL from the [Accessing Your Environment](../access.md) guide.

Create the Flux Git credentials secret:

```bash
# Replace <YOUR_PAT> with the PAT from your instructions page
kubectl create secret generic github-credentials \
  --namespace=flux-system \
  --from-literal=username=participant \
  --from-literal=password=<YOUR_PAT>
```

Verify the secret was created:

```bash
kubectl get secret github-credentials -n flux-system
```

!!! info
    This secret is how Flux authenticates with GitHub to pull your repository and (in Lab 4) push automated commits back. Every GitRepository resource that needs authentication will reference this secret via `secretRef`.

### Task 2: Understanding Flux Custom Resources

Before we start deploying, let's explore the custom resources Flux has installed:

```bash
# List all Flux custom resource definitions
kubectl get crds | grep fluxcd

# Examine the GitRepository CRD
kubectl explain gitrepository.spec
```

The key resource types you'll work with today:

| Resource | Controller | Purpose |
|----------|-----------|---------|
| `GitRepository` | source-controller | Watches a Git repository for changes |
| `HelmRepository` | source-controller | Watches a Helm chart repository |
| `Kustomization` | kustomize-controller | Applies manifests from a source |
| `HelmRelease` | helm-controller | Manages Helm chart releases |

### Task 3: Examining the Pre-configured GitRepository

Your cluster has been bootstrapped with a GitRepository that points to your workshop repository. Let's examine it:

```bash
# List all Git sources
flux get sources git

# Get detailed information about the source
kubectl describe gitrepository flux-system -n flux-system
```

!!! info
    Notice the `Ready` condition and the `Artifact` section. The source-controller periodically fetches the latest commit from your repository and makes the content available as an artifact for other controllers to consume.

Let's also check the existing Kustomization that was set up during bootstrap:

```bash
# List all Kustomizations
flux get kustomizations

# Describe the flux-system Kustomization
kubectl describe kustomization flux-system -n flux-system
```

### Task 4: Creating Your First Application Source

Now let's configure Flux to watch a specific path in your repository for application manifests. First, examine the GitRepository manifest we'll use:

```bash
# View the application source manifest
cat app-source.yaml
```

```yaml
# app-source.yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: workshop-apps
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/stevenwadeconsulting/gitops-fundamentals-lab
  ref:
    branch: main
  secretRef:
    name: github-credentials
```

Apply the GitRepository:

```bash
kubectl apply -f app-source.yaml
```

Verify the source is ready:

```bash
# Check the source status
flux get sources git

# Wait for the source to be ready
kubectl wait gitrepository/workshop-apps -n flux-system --for=condition=ready --timeout=60s
```

!!! note
    The `interval: 1m` field tells Flux to check for new commits every minute. In production, you might increase this interval or use webhooks for immediate reconciliation.

### Task 5: Deploying Your First Application

Now let's deploy a simple nginx application through Flux. First, examine the application manifests:

```bash
# View the application namespace
cat app/namespace.yaml

# View the application deployment
cat app/deployment.yaml

# View the application service
cat app/service.yaml
```

Now create a Kustomization resource that tells Flux to apply these manifests:

```bash
# View the Kustomization manifest
cat app-kustomization.yaml
```

```yaml
# app-kustomization.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: workshop-app
  namespace: flux-system
spec:
  interval: 5m
  path: ./examples/001-first-pipeline/app
  prune: true
  sourceRef:
    kind: GitRepository
    name: workshop-apps
  targetNamespace: workshop-app
  wait: true
  timeout: 2m
```

Apply the Kustomization:

```bash
kubectl apply -f app-kustomization.yaml
```

Watch the deployment happen:

```bash
# Watch the Kustomization reconciliation
flux get kustomizations --watch

# Once ready, check the deployed resources
kubectl get all -n workshop-app
```

!!! info
    Key fields in the Kustomization:

    - `path`: The directory in the Git repository containing the manifests
    - `prune: true`: Resources removed from Git will be garbage collected from the cluster
    - `sourceRef`: Links to the GitRepository we created earlier
    - `wait: true`: Flux waits for all resources to become ready before reporting success

### Task 6: Making Changes Through Git

This is where GitOps shines. Let's make a change to our application through Git and watch Flux reconcile it automatically.

First, let's see what's currently deployed:

```bash
# Check the current number of replicas
kubectl get deployment nginx -n workshop-app

# Check the current image version
kubectl get deployment nginx -n workshop-app -o jsonpath='{.spec.template.spec.containers[0].image}'
```

Now, edit the deployment manifest to scale up from 2 to 3 replicas:

```bash
# Edit the deployment file
cd app
sed -i 's/replicas: 2/replicas: 3/' deployment.yaml

# Commit and push the change
git add deployment.yaml
git commit -m "feat: scale nginx to 3 replicas"
git push origin main
```

Now watch Flux pick up the change:

```bash
# Trigger an immediate reconciliation (instead of waiting for the interval)
flux reconcile source git workshop-apps

# Watch the Kustomization reconcile
flux get kustomizations --watch
```

Verify the change was applied:

```bash
# Check the updated replica count
kubectl get deployment nginx -n workshop-app
```

!!! tip
    In production, you would make this change through a pull request rather than pushing directly to main. This gives you code review, approval workflows, and an audit trail. We pushed directly here for speed, but the pull request workflow is the recommended approach.

### Task 7: Understanding Reconciliation

Let's explore how Flux detects and corrects drift. Try manually scaling the deployment:

```bash
# Manually scale the deployment (simulating drift)
kubectl scale deployment nginx -n workshop-app --replicas=5

# Check the current state
kubectl get deployment nginx -n workshop-app
```

Now wait for Flux to reconcile (or trigger it manually):

```bash
# Trigger reconciliation
flux reconcile kustomization workshop-app

# Check the replica count again
kubectl get deployment nginx -n workshop-app
```

!!! info
    Flux restored the replica count to 3 (what's defined in Git). This is the power of GitOps - Git is the single source of truth. Any manual changes (drift) are automatically corrected. This is why you can deploy on Friday without fear.

### Task 8: Inspecting Flux Events

Flux provides detailed events for troubleshooting and understanding what's happening:

```bash
# View Flux events
flux events

# View events for a specific resource
flux events --for kustomization/workshop-app

# Check the Kustomization status in detail
kubectl describe kustomization workshop-app -n flux-system
```

### Task 9: Cleanup

Before moving to the next lab, clean up the application resources:

```bash
# Delete the Kustomization (this will also delete the deployed resources because prune is enabled)
kubectl delete kustomization workshop-app -n flux-system

# Delete the GitRepository source
kubectl delete gitrepository workshop-apps -n flux-system

# Verify resources are cleaned up
kubectl get all -n workshop-app
flux get kustomizations
flux get sources git
```

!!! note
    When you delete a Kustomization with `prune: true`, Flux automatically removes all resources it was managing. This is the inverse of reconciliation - removing the desired state from Git removes the resources from the cluster.

## Lab Validation

Let's confirm you've mastered the key concepts from this lab:

- You can verify a Flux installation and understand its components
- You can create GitRepository sources and Kustomization resources
- You understand how changes in Git are reconciled to the cluster
- You've seen drift detection and correction in action
- You can inspect Flux events for troubleshooting

## Summary

Congratulations! You have completed Lab 1 of the GitOps Fundamentals Workshop. In this lab, you've learned:

1. How Flux's architecture works (source-controller, kustomize-controller, helm-controller, notification-controller)
2. How to create a GitRepository source to watch your repository
3. How to deploy applications using Kustomization resources
4. How changes in Git are automatically reconciled to your cluster
5. How Flux detects and corrects configuration drift
6. How to inspect events and troubleshoot Flux resources

You've now experienced the core GitOps loop: Git is the source of truth, and Flux ensures your cluster matches what's in Git. This fundamental concept underpins everything we'll build in the rest of the workshop.

## Next Steps

Proceed to [Lab 2: Multi-Environment Mastery](2-multi-environment.md) to learn how to structure your repository for multiple environments and build promotion workflows.
