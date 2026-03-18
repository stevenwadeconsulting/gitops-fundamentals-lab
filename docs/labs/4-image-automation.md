# Lab 4: Image Update Automation

## Introduction

What if new container images could flow automatically from your registry to your cluster - without anyone touching kubectl or editing YAML? That's exactly what Flux's Image Update Automation does.

In this lab, you'll configure Flux to watch a container registry for new image tags, evaluate them against a policy, and automatically commit updated image references back to your Git repository. The GitOps loop handles the rest.

## Objectives

By the end of this lab, you will be able to:

- Create ImageRepository resources to scan container registries
- Define ImagePolicy resources to control which tags are selected
- Configure ImageUpdateAutomation to commit changes back to Git
- Understand the full automation flow from image push to cluster deployment

## Prerequisites

- Completion of [Lab 3: Helm Integration](3-helm-integration.md)
- Understanding of container registries and image tagging

!!! warning
    Execute `cd ../004-image-automation` to navigate to this lab directory

## Lab Tasks

### Task 1: Understanding the Automation Flow

Before we configure anything, let's understand the full flow:

```
1. Developer pushes code → CI builds and pushes image with tag (e.g., v1.2.3)
2. Flux image-reflector-controller scans the registry and finds the new tag
3. Flux evaluates the tag against your ImagePolicy (e.g., "latest semver")
4. Flux image-automation-controller updates the YAML in Git with the new tag
5. Flux source-controller detects the new commit
6. Flux kustomize-controller applies the updated manifests to the cluster
```

!!! info
    This is a pull-based model. Flux pulls information from the registry - the registry doesn't need to know about Flux. This is more secure than webhook-based approaches because your cluster never needs to be exposed to the internet.

First, verify the image automation controllers are running:

```bash
# Check for image automation controllers
kubectl get pods -n flux-system | grep image
```

You should see:

- `image-reflector-controller` - Scans container registries
- `image-automation-controller` - Commits image updates to Git

### Task 2: Deploying an Application to Automate

Let's deploy a sample application that we'll configure for image automation:

```bash
# View the application manifests
cat app/namespace.yaml
cat app/deployment.yaml
cat app/service.yaml

# Apply the manifests through a Kustomization
kubectl apply -f flux-kustomization.yaml

# Wait for the deployment
flux get kustomizations --watch

# Verify the deployment
kubectl get all -n image-auto-demo
```

Examine the deployment manifest closely:

```bash
cat app/deployment.yaml
```

!!! info
    Notice the comment marker `# {"$imagepolicy": "flux-system:podinfo"}` next to the image field. This marker tells the image-automation-controller which line to update when a new image is selected. Without this marker, Flux won't know where to write the updated tag.

### Task 3: Creating an ImageRepository

An ImageRepository tells Flux which container registry to scan:

```bash
# View the ImageRepository manifest
cat image-repository.yaml
```

```yaml
# image-repository.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: podinfo
  namespace: flux-system
spec:
  image: ghcr.io/stefanprodan/podinfo
  interval: 5m
  provider: generic
```

Apply and verify:

```bash
kubectl apply -f image-repository.yaml

# Check the scan results
flux get image repository podinfo

# View the discovered tags
kubectl describe imagerepository podinfo -n flux-system
```

!!! note
    The `interval: 5m` means Flux scans the registry every 5 minutes for new tags. For high-throughput registries, you might want to increase this interval to reduce API calls.

### Task 4: Creating an ImagePolicy

An ImagePolicy defines which image tag to select from the scanned tags:

```bash
# View the ImagePolicy manifest
cat image-policy.yaml
```

```yaml
# image-policy.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: podinfo
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: podinfo
  policy:
    semver:
      range: ">=6.0.0 <7.0.0"
```

Apply and verify:

```bash
kubectl apply -f image-policy.yaml

# Check which image was selected
flux get image policy podinfo
```

!!! info
    Flux supports several policy types:

    - `semver`: Select based on semantic versioning ranges (recommended for production)
    - `alphabetical`: Select the latest alphabetically (useful for date-based tags)
    - `numerical`: Select the highest number

    The semver range `>=6.0.0 <7.0.0` means "any 6.x.x release, but don't jump to 7.x.x". This gives you automatic patch and minor updates while protecting against breaking major version changes.

### Task 5: Configuring ImageUpdateAutomation

Now let's configure the automation that commits image updates back to Git:

```bash
# View the ImageUpdateAutomation manifest
cat image-update-automation.yaml
```

```yaml
# image-update-automation.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageUpdateAutomation
metadata:
  name: podinfo
  namespace: flux-system
spec:
  interval: 5m
  sourceRef:
    kind: GitRepository
    name: flux-system
  git:
    checkout:
      ref:
        branch: main
    commit:
      author:
        name: fluxcdbot
        email: fluxcdbot@users.noreply.github.com
      messageTemplate: |
        chore: update image {{range .Changed.Changes}}{{print .OldValue}} -> {{print .NewValue}}{{end}}
    push:
      branch: main
  update:
    path: ./examples/004-image-automation/app
    strategy: Setters
```

Apply and verify:

```bash
kubectl apply -f image-update-automation.yaml

# Check the automation status
flux get image update podinfo

# View the automation details
kubectl describe imageupdateautomation podinfo -n flux-system
```

!!! info
    Key fields:

    - `git.commit.messageTemplate`: Customise the commit message Flux creates
    - `update.path`: Only update files in this directory (prevents accidental changes elsewhere)
    - `update.strategy: Setters`: Uses the `$imagepolicy` markers to know which lines to update

### Task 6: Observing the Automation in Action

Let's check if the automation has already updated our deployment:

```bash
# Check the latest image policy selection
flux get image policy podinfo

# Check the current deployment image
kubectl get deployment podinfo -n image-auto-demo -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""

# Check the Git log for automation commits
git pull origin main
git log --oneline -5
```

!!! tip
    If the image was updated, you'll see a commit from `fluxcdbot` with a message like "chore: update image ghcr.io/stefanprodan/podinfo:6.5.0 -> ghcr.io/stefanprodan/podinfo:6.7.0". This is the automation at work - no human intervention required.

### Task 7: Cleanup

Before moving to the next lab, clean up the image automation resources:

```bash
# Delete image automation resources
kubectl delete imageupdateautomation podinfo -n flux-system
kubectl delete imagepolicy podinfo -n flux-system
kubectl delete imagerepository podinfo -n flux-system

# Delete the application Kustomization
kubectl delete kustomization image-auto-demo -n flux-system

# Verify resources are cleaned up
flux get image all
kubectl get all -n image-auto-demo
```

## Lab Validation

Let's confirm you've mastered the key concepts from this lab:

- You understand the full image automation flow (scan, evaluate, commit, reconcile)
- You can create ImageRepository and ImagePolicy resources
- You understand semver-based image policies
- You know how ImageUpdateAutomation commits changes back to Git
- You understand the role of `$imagepolicy` markers in deployment manifests

## Summary

Congratulations! You have completed Lab 4 of the GitOps Fundamentals Workshop. In this lab, you've learned:

1. How the image automation flow works end-to-end
2. How to scan container registries with ImageRepository
3. How to control tag selection with ImagePolicy and semver ranges
4. How to automate Git commits with ImageUpdateAutomation
5. How `$imagepolicy` markers connect policies to deployment manifests

Image Update Automation is what makes hands-free deployments possible. Your CI pipeline pushes an image, and Flux takes care of the rest - all through Git.

## Next Steps

Proceed to [Lab 5: Secret Management with SOPS](5-sops-secrets.md) to learn how to manage secrets in Git without exposing sensitive data.
