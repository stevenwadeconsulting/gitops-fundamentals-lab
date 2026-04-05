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
# Expose the UI via NodePort
kubectl -n flux-system patch svc flux-operator \
  -p '{"spec": {"type": "NodePort", "ports": [{"port": 9080, "targetPort": 9080, "nodePort": 30080}]}}'

# Get the node IP
kubectl get nodes -o wide

# Open in browser: http://<NODE_EXTERNAL_IP>:30080
```
