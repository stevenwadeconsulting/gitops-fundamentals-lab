# Cheat Sheet

Every command you need. Print this page. Stick it on your monitor.

---

## Flux Status

```bash
# Everything at a glance
flux get all

# Health check
flux check

# All Kustomizations
flux get kustomizations

# All HelmReleases
flux get helmreleases -A

# All sources
flux get sources all
```

---

## Notifications

```bash
# List alert providers
flux get alert-providers

# List alerts
flux get alerts

# Check notification controller logs
kubectl logs -n flux-system deploy/notification-controller --tail=20
```

---

## Troubleshooting (Four-Step Pattern)

```bash
# 1. What failed?
flux get all

# 2. What's the error?
kubectl describe kustomization <name> -n flux-system

# 3. What happened?
flux events --for kustomization/<name>

# 4. Why?
kubectl logs -n flux-system deploy/kustomize-controller --tail=20
```

Replace `kustomization` with `helmrelease`, `gitrepository`, or any Flux resource. The four steps are the same.

---

## Reconciliation

```bash
# Force immediate reconciliation
flux reconcile kustomization <name>

# Reconcile a source first, then kustomization
flux reconcile source git flux-system
flux reconcile kustomization <name> --with-source

# Reconcile a HelmRelease
flux reconcile helmrelease <name> -n <namespace>
```

---

## Suspend and Resume

```bash
# Pause reconciliation
flux suspend kustomization <name>

# Resume reconciliation
flux resume kustomization <name>

# Check what's suspended
flux get kustomizations | grep True
```

---

## Rollback

```bash
# Revert the last commit
git revert HEAD --no-edit
git push

# Never use this (Flux will undo it):
# kubectl rollout undo deployment/<name>
```

---

## SOPS Encryption

```bash
# Encrypt a file (reads .sops.yaml for config)
sops --encrypt secret.yaml > secret.encrypted.yaml

# Decrypt a file (needs the private key)
sops --decrypt secret.encrypted.yaml

# Edit in place
sops secret.encrypted.yaml
```

---

## Helm via Flux

```bash
# List Flux-managed Helm releases
flux get helmreleases -A

# See what Helm thinks
helm list -A
helm history <release-name> -n <namespace>
```

---

## Useful kubectl

```bash
# Pods in a namespace
kubectl get pods -n <namespace>

# Watch pods
kubectl get pods -n <namespace> --watch

# Describe a Flux resource
kubectl describe kustomization <name> -n flux-system
kubectl describe helmrelease <name> -n <namespace>

# Exec into a pod
kubectl exec -n <namespace> deploy/<name> -- env

# Logs
kubectl logs -n <namespace> deploy/<name> --tail=20
```

---

## Flux Operator UI

```bash
# Start port-forward on the bastion
kubectl port-forward -n flux-system svc/flux-operator 9080:9080 --address 0.0.0.0 &

# Open in browser: http://<YOUR_BASTION_IP>:9080

# Check if port-forward is still running
jobs

# Restart if it stopped
kubectl port-forward -n flux-system svc/flux-operator 9080:9080 --address 0.0.0.0 &
```
