# Lab 3: Helm Integration

## Introduction

Many teams already use Helm charts for packaging applications. The good news: you don't have to choose between Helm and GitOps. Flux integrates natively with Helm, letting you declare your Helm releases in Git and have Flux manage the full lifecycle - install, upgrade, rollback, and uninstall.

In this lab, you'll learn how to use HelmRepository and HelmRelease resources to deploy applications from public and private Helm chart repositories.

## Objectives

By the end of this lab, you will be able to:

- Create HelmRepository sources pointing to chart repositories
- Deploy applications using HelmRelease resources
- Override Helm values through GitOps
- Upgrade and roll back Helm releases through Git commits
- Understand how Flux manages the Helm release lifecycle

## Prerequisites

- Completion of [Lab 2: Multi-Environment Mastery](2-multi-environment.md)
- Basic familiarity with Helm concepts (charts, values, releases)

!!! warning
    Execute `cd ../003-helm-integration` to navigate to this lab directory

## Lab Tasks

### Task 1: Creating a HelmRepository Source

Let's start by adding a HelmRepository source. We'll use the Bitnami charts repository:

```bash
# View the HelmRepository manifest
cat helm-repository.yaml
```

```yaml
# helm-repository.yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: bitnami
  namespace: flux-system
spec:
  interval: 1h
  url: https://charts.bitnami.com/bitnami
```

Apply the HelmRepository:

```bash
kubectl apply -f helm-repository.yaml
```

Verify the repository is ready:

```bash
# Check the source status
flux get sources helm

# Wait for the repository index to be fetched
kubectl wait helmrepository/bitnami -n flux-system --for=condition=ready --timeout=60s
```

!!! info
    The `interval: 1h` field tells Flux to refresh the Helm repository index every hour. This is how Flux discovers new chart versions without you having to do anything.

### Task 2: Deploying a Helm Chart with HelmRelease

Now let's deploy Redis using a HelmRelease. Examine the manifest:

```bash
# View the HelmRelease manifest
cat redis-release.yaml
```

```yaml
# redis-release.yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: redis
  namespace: flux-system
spec:
  interval: 5m
  chart:
    spec:
      chart: redis
      version: ">=19.0.0 <20.0.0"
      sourceRef:
        kind: HelmRepository
        name: bitnami
      interval: 1h
  targetNamespace: redis
  install:
    createNamespace: true
  values:
    architecture: standalone
    auth:
      enabled: false
    master:
      persistence:
        enabled: false
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 250m
          memory: 256Mi
```

Apply the HelmRelease:

```bash
kubectl apply -f redis-release.yaml
```

Watch the deployment:

```bash
# Watch the HelmRelease status
flux get helmreleases --watch

# Once ready, check the deployed resources
kubectl get all -n redis
```

!!! info
    Key fields in the HelmRelease:

    - `chart.spec.version`: Uses a semver range so Flux can auto-upgrade within safe bounds
    - `targetNamespace`: Where the chart resources are deployed
    - `install.createNamespace`: Automatically creates the namespace if it doesn't exist
    - `values`: Inline Helm values that override chart defaults

### Task 3: Exploring the Helm Release

Let's examine what Flux created:

```bash
# View the Helm release details
flux get helmreleases

# Check the actual Helm release
helm list -n redis

# View the Helm release history
helm history redis -n redis
```

!!! note
    Flux manages the Helm release through its own controller - you don't need to run `helm install` or `helm upgrade` manually. The HelmRelease custom resource is the declaration, and Flux handles the imperative Helm commands behind the scenes.

### Task 4: Updating Helm Values Through Git

Let's update the Redis configuration by changing the values in our HelmRelease. We'll enable authentication:

```bash
# Create an updated HelmRelease with auth enabled
cat > redis-release-updated.yaml << 'EOF'
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: redis
  namespace: flux-system
spec:
  interval: 5m
  chart:
    spec:
      chart: redis
      version: ">=19.0.0 <20.0.0"
      sourceRef:
        kind: HelmRepository
        name: bitnami
      interval: 1h
  targetNamespace: redis
  install:
    createNamespace: true
  values:
    architecture: standalone
    auth:
      enabled: true
      password: workshop-redis-pass
    master:
      persistence:
        enabled: false
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 250m
          memory: 256Mi
EOF

# Apply the updated release
kubectl apply -f redis-release-updated.yaml
```

Watch the upgrade:

```bash
# Watch the HelmRelease reconcile
flux get helmreleases --watch

# Check the Helm release history
helm history redis -n redis
```

!!! tip
    In a production GitOps workflow, this values change would be a Git commit. The pattern is the same as what we learned in Lab 1 - change the manifest in Git, and Flux reconciles the cluster.

### Task 5: Using ValuesFrom for External Configuration

Flux can also pull Helm values from ConfigMaps or Secrets. This is useful when you want to separate sensitive values from the HelmRelease manifest:

```bash
# Create a ConfigMap with Helm values
cat > redis-values-configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-values
  namespace: flux-system
data:
  values.yaml: |
    master:
      resources:
        requests:
          cpu: 200m
          memory: 256Mi
        limits:
          cpu: 500m
          memory: 512Mi
EOF

kubectl apply -f redis-values-configmap.yaml
```

Now examine how to reference this ConfigMap in a HelmRelease:

```bash
# View the HelmRelease with valuesFrom
cat redis-release-with-valuesFrom.yaml
```

```yaml
# redis-release-with-valuesFrom.yaml (reference only - don't apply)
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: redis
  namespace: flux-system
spec:
  interval: 5m
  chart:
    spec:
      chart: redis
      version: ">=19.0.0 <20.0.0"
      sourceRef:
        kind: HelmRepository
        name: bitnami
      interval: 1h
  targetNamespace: redis
  install:
    createNamespace: true
  values:
    architecture: standalone
    auth:
      enabled: false
  valuesFrom:
    - kind: ConfigMap
      name: redis-values
      valuesKey: values.yaml
```

!!! info
    `valuesFrom` values are merged with inline `values`, with `valuesFrom` taking precedence. This pattern is useful for:

    - Separating environment-specific values into ConfigMaps
    - Storing sensitive values in Secrets
    - Sharing common values across multiple HelmReleases

### Task 6: Handling Helm Release Failures

Let's see what happens when a HelmRelease fails. We'll intentionally deploy with invalid values:

```bash
# Create a HelmRelease with invalid values
cat > redis-bad-release.yaml << 'EOF'
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: redis-bad
  namespace: flux-system
spec:
  interval: 5m
  chart:
    spec:
      chart: redis
      version: ">=19.0.0 <20.0.0"
      sourceRef:
        kind: HelmRepository
        name: bitnami
      interval: 1h
  targetNamespace: redis-bad
  install:
    createNamespace: true
    remediation:
      retries: 3
  values:
    architecture: nonexistent-mode
EOF

kubectl apply -f redis-bad-release.yaml
```

Observe the failure:

```bash
# Check the HelmRelease status
flux get helmreleases

# Get detailed error information
kubectl describe helmrelease redis-bad -n flux-system

# View Flux events for the failed release
flux events --for helmrelease/redis-bad
```

!!! info
    Notice the `install.remediation.retries` field. Flux will attempt to install the release up to 3 times before giving up. You can also configure `upgrade.remediation` for upgrade failures with automatic rollback.

Clean up the failed release:

```bash
kubectl delete helmrelease redis-bad -n flux-system
kubectl delete namespace redis-bad --ignore-not-found
```

### Task 7: Cleanup

Before moving to the next lab, clean up all Helm resources:

```bash
# Delete the HelmRelease (this will uninstall the Helm chart)
kubectl delete helmrelease redis -n flux-system

# Delete the HelmRepository
kubectl delete helmrepository bitnami -n flux-system

# Delete the ConfigMap
kubectl delete configmap redis-values -n flux-system

# Verify resources are cleaned up
flux get helmreleases
flux get sources helm
kubectl get all -n redis
```

## Lab Validation

Let's confirm you've mastered the key concepts from this lab:

- You can create HelmRepository sources and HelmRelease resources
- You understand how Helm values are managed through GitOps
- You know how to use valuesFrom for external configuration
- You understand how Flux handles Helm release failures and remediation

## Summary

Congratulations! You have completed Lab 3 of the GitOps Fundamentals Workshop. In this lab, you've learned:

1. How to create HelmRepository sources for chart repositories
2. How to deploy applications using HelmRelease resources
3. How to manage Helm values through inline values and valuesFrom
4. How Flux handles the full Helm lifecycle (install, upgrade, rollback)
5. How remediation works for failed releases

Helm integration means you don't have to choose between the Helm ecosystem and GitOps. You get the best of both worlds.

## Next Steps

Proceed to [Lab 4: Image Update Automation](4-image-automation.md) to learn how to automate deployments when new container images are pushed.
