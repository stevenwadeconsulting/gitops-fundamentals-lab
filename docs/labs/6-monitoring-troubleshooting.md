# Lab 6: Monitoring & Troubleshooting

## Introduction

Things will go wrong. The question isn't if, but when - and how quickly you can figure out what happened and fix it. In this lab, you'll learn the monitoring, troubleshooting, and rollback patterns that come from rescuing 50+ platforms.

This lab is about building the muscle memory so that when something goes wrong at 6 PM on a Friday, you know exactly where to look and what to do.

## Objectives

By the end of this lab, you will be able to:

- Monitor the health of your Flux controllers and reconciliation
- Set up Flux notifications and alerts
- Troubleshoot common Flux failures with confidence
- Perform rollbacks using Git (the GitOps way)
- Understand the troubleshooting patterns that work in production

## Prerequisites

- Completion of [Lab 5: Secret Management with SOPS](5-sops-secrets.md)
- Understanding of all Flux resources covered so far

!!! warning
    Execute `cd ../006-monitoring-troubleshooting` to navigate to this lab directory

## Lab Tasks

### Task 1: Monitoring Flux Health

Let's start with the commands you'll use every day to understand the state of your cluster:

```bash
# The single most useful command - shows everything
flux get all

# Check all sources
flux get sources all

# Check all Kustomizations
flux get kustomizations

# Check all HelmReleases
flux get helmreleases

# Check controller health
flux check
```

!!! info
    `flux get all` is your dashboard. It shows every Flux resource, its status, and when it was last reconciled. Make this your first command when investigating any issue.

Let's look at the Flux controller logs:

```bash
# View source-controller logs
kubectl logs -n flux-system deploy/source-controller --tail=20

# View kustomize-controller logs
kubectl logs -n flux-system deploy/kustomize-controller --tail=20

# View helm-controller logs
kubectl logs -n flux-system deploy/helm-controller --tail=20
```

### Task 2: Setting Up Flux Notifications

Flux can send notifications to Slack, Microsoft Teams, GitHub, and other providers. Let's set up a notification provider and alert:

```bash
# View the notification provider manifest
cat notification-provider.yaml
```

```yaml
# notification-provider.yaml
apiVersion: notification.toolkit.fluxcd.io/v1beta3
kind: Provider
metadata:
  name: github-status
  namespace: flux-system
spec:
  type: github
  address: https://github.com/stevenwadeconsulting/gitops-fundamentals-lab
  secretRef:
    name: github-credentials
```

```bash
# View the alert manifest
cat alert.yaml
```

```yaml
# alert.yaml
apiVersion: notification.toolkit.fluxcd.io/v1beta3
kind: Alert
metadata:
  name: on-call-alert
  namespace: flux-system
spec:
  providerRef:
    name: github-status
  eventSeverity: error
  eventSources:
    - kind: Kustomization
      name: "*"
    - kind: HelmRelease
      name: "*"
  summary: "Flux reconciliation error"
```

Apply the notification resources:

```bash
kubectl apply -f notification-provider.yaml
kubectl apply -f alert.yaml

# Verify the alert is configured
flux get alerts
```

!!! info
    Alerts filter events by severity and source. Setting `eventSeverity: error` means you'll only be notified when something fails - not on every successful reconciliation. In production, you'd typically set up alerts for errors and a separate channel for informational events.

### Task 3: Triggering and Diagnosing a Failure

Let's deploy something that will fail and walk through the troubleshooting process:

```bash
# Deploy an application with an intentional error
kubectl apply -f broken-kustomization.yaml
```

Now let's diagnose the failure:

```bash
# Step 1: Check the overall status
flux get all

# Step 2: Look at the failing resource
flux get kustomizations

# Step 3: Get the error details
kubectl describe kustomization broken-app -n flux-system

# Step 4: Check the events
flux events --for kustomization/broken-app

# Step 5: Check the controller logs for more detail
kubectl logs -n flux-system deploy/kustomize-controller --tail=50 | grep broken-app
```

!!! tip
    The troubleshooting pattern is always the same:

    1. **What failed?** → `flux get all`
    2. **What's the error?** → `kubectl describe` the failing resource
    3. **What happened?** → `flux events --for <resource>`
    4. **Why?** → Controller logs

    This pattern works for every Flux resource type. Memorise it.

### Task 4: Common Failure Scenarios

Let's walk through the most common failures and how to identify them:

**Scenario 1: Source fetch failure**

```bash
# Create a GitRepository pointing to a non-existent repo
kubectl apply -f broken-source.yaml

# Diagnose the failure
flux get sources git
kubectl describe gitrepository broken-source -n flux-system
```

```bash
# Clean up
kubectl delete gitrepository broken-source -n flux-system
```

**Scenario 2: Kustomization path not found**

```bash
# Create a Kustomization with an invalid path
kubectl apply -f broken-path-kustomization.yaml

# Diagnose the failure
flux get kustomizations
kubectl describe kustomization broken-path -n flux-system
```

```bash
# Clean up
kubectl delete kustomization broken-path -n flux-system
```

**Scenario 3: Invalid manifests**

```bash
# Create a Kustomization pointing to invalid YAML
kubectl apply -f broken-manifests-kustomization.yaml

# Diagnose the failure
flux get kustomizations
flux events --for kustomization/broken-manifests
```

```bash
# Clean up
kubectl delete kustomization broken-manifests -n flux-system
```

!!! info
    In each scenario, the error message tells you exactly what went wrong. Flux doesn't hide failures - it reports them clearly through status conditions and events.

### Task 5: Performing a GitOps Rollback

In GitOps, rollback means reverting a commit in Git. Let's walk through this:

First, deploy a working application:

```bash
# Deploy the application
kubectl apply -f working-app-kustomization.yaml

# Wait for it to be ready
flux get kustomizations --watch

# Verify the deployment
kubectl get deployment rollback-demo -n rollback-demo
```

Now let's simulate a bad change and roll back:

```bash
# Make a "bad" change - update to a broken image
cd working-app
sed -i 's|nginx:1.25|nginx:nonexistent-tag|' deployment.yaml
git add deployment.yaml
git commit -m "feat: update to new image version"
git push origin main

# Wait for Flux to pick up the change
flux reconcile source git flux-system
flux reconcile kustomization working-app

# Observe the failure
kubectl get pods -n rollback-demo
kubectl describe deployment rollback-demo -n rollback-demo
```

Now roll back using Git:

```bash
# Revert the last commit
git revert HEAD --no-edit
git push origin main

# Trigger reconciliation
flux reconcile source git flux-system
flux reconcile kustomization working-app

# Verify the rollback
kubectl get pods -n rollback-demo
kubectl get deployment rollback-demo -n rollback-demo -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""
```

!!! info
    This is the GitOps rollback pattern:

    1. `git revert` (not `git reset` - we want the history)
    2. `git push`
    3. Flux reconciles

    The rollback is a Git commit with a clear audit trail. You can see who reverted, when, and why. Compare this to `kubectl rollout undo` where there's no audit trail and no guarantee the next reconciliation won't re-apply the broken state.

### Task 6: Flux Suspend and Resume

Sometimes you need to pause reconciliation temporarily - for example, during a maintenance window:

```bash
# Suspend a Kustomization
flux suspend kustomization working-app

# Verify it's suspended
flux get kustomizations

# Make a change that would normally be reconciled
kubectl scale deployment rollback-demo -n rollback-demo --replicas=5

# Verify the change sticks (Flux isn't reconciling)
kubectl get deployment rollback-demo -n rollback-demo
```

Resume reconciliation:

```bash
# Resume the Kustomization
flux resume kustomization working-app

# Watch Flux correct the drift
flux get kustomizations --watch

# Verify the replica count was restored
kubectl get deployment rollback-demo -n rollback-demo
```

!!! tip
    Suspend/resume is useful for:

    - Maintenance windows where you need to make manual changes
    - Debugging reconciliation loops
    - Pausing a deployment while investigating an issue

    Always remember to resume when you're done.

### Task 7: Cleanup

Clean up all resources from this lab:

```bash
# Delete all lab resources
kubectl delete kustomization working-app broken-app -n flux-system --ignore-not-found
kubectl delete alert on-call-alert -n flux-system --ignore-not-found
kubectl delete provider github-status -n flux-system --ignore-not-found

# Verify cleanup
flux get all
```

## Lab Validation

Let's confirm you've mastered the key concepts from this lab:

- You can monitor Flux health using `flux get all` and controller logs
- You can set up notifications and alerts for Flux events
- You know the four-step troubleshooting pattern (status, describe, events, logs)
- You can perform rollbacks using `git revert`
- You understand when and how to use `flux suspend` and `flux resume`

## Summary

Congratulations! You have completed Lab 6 of the GitOps Fundamentals Workshop. In this lab, you've learned:

1. How to monitor Flux health and reconciliation status
2. How to set up notifications for failed reconciliations
3. The four-step troubleshooting pattern that works for every failure
4. How to perform rollbacks the GitOps way (git revert, not kubectl rollout undo)
5. How to suspend and resume reconciliation for maintenance windows

These are the patterns from 50+ platform rescues. They work because they're simple, repeatable, and don't require you to remember which magic kubectl command to run at 6 PM on a Friday.

## What's Next?

You've completed all the hands-on labs! Head back for the **Ask Me Anything** session where we'll discuss:

- Your specific challenges and migration strategy
- Your "but we're different because..." scenarios
- Your 30-day adoption roadmap

No question is too awkward. This is the session that makes the workshop stick.
