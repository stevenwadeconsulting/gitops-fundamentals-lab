# Lab 4: Secret Management with SOPS

Encrypt secrets in Git. Commit them safely. Watch Flux decrypt and apply them automatically. No more secrets in Slack.

**Duration:** 40 minutes

---

## Objectives

By the end of this lab, you will:

- Create the Flux decryption secret from the workshop key
- Encrypt a Kubernetes Secret with SOPS
- Configure Flux to decrypt SOPS-encrypted secrets automatically
- Deploy an application that consumes an encrypted secret
- Understand why this is safer than every alternative your team is currently using

---

## Prerequisites

- [x] Completed [Lab 3: Helm Integration](3-helm-integration.md)
- [x] Flux is managing both raw YAML and Helm deployments

---

## The Problem

Secrets have to live somewhere. Right now, on most teams, they live in:

- Slack messages ("can you send me the DB password?")
- Shared 1Password vaults (better, but not in Git)
- Environment variables set manually on the cluster
- Unencrypted YAML committed to Git (please no)

None of these are GitOps. If Git is the source of truth for everything else, secrets should be in Git too. But they need to be encrypted.

SOPS (Secrets OPerationS) encrypts the values of a Kubernetes Secret while leaving the keys and structure visible. You can see what secrets exist and what keys they contain, but the actual values are encrypted. Flux decrypts them automatically before applying to the cluster.

---

## Your Workshop Encryption Key

Your repository already contains everything you need:

- **`.sops.yaml`** in the root: tells SOPS which public key to use for encryption
- **`sops/age-key.txt`**: contains both the public and private age key

!!! warning "Workshop only"
    In production, you would NEVER commit the private key to Git. It would be created securely on the cluster and nowhere else. For this workshop, we've included it so you can focus on the workflow, not key management.

---

## Task 1: Create the decryption secret for Flux

On your **bastion node**, create the Kubernetes Secret from the age key in your repo:

```bash
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -
```

Now create the secret. You'll need the age key file from your repo. On the bastion:

```bash
cat << 'EOF' | kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=/dev/stdin
# created: 2026-04-05T18:55:29+01:00
# public key: age1x4r5557tw69dwnjv87d0lz342auelwnxf9rcrlv7fmv9jskycv9qc6ynrj
AGE-SECRET-KEY-1FEUWA2066MH03X79XDQZTWL9UYZE8CV0532VJASEDP8FJDVVPNDSPAEWPG
EOF
```

Verify:

```bash
kubectl get secret sops-age -n flux-system
```

!!! info "What just happened?"
    You created a Kubernetes Secret containing the age private key. Flux will use this to decrypt any SOPS-encrypted files it finds. The private key lives in the cluster, not in Git (in production).

---

## Task 2: Create a plain secret

On your **local machine**, create the file `apps/podinfo-helm/secret.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: podinfo-secrets
  namespace: production
type: Opaque
stringData:
  API_KEY: "my-super-secret-api-key-12345"
  DB_PASSWORD: "production-database-password"
```

---

## Task 3: Encrypt the secret with SOPS

On your **local machine** (you need `sops` installed), encrypt the secret:

```bash
sops --encrypt apps/podinfo-helm/secret.yaml > apps/podinfo-helm/secret.encrypted.yaml
```

!!! tip "No flags needed"
    SOPS reads `.sops.yaml` from your repo root automatically. It knows which key to use and which fields to encrypt. One command.

View the encrypted file:

```bash
cat apps/podinfo-helm/secret.encrypted.yaml
```

!!! success "The aha moment"
    Look at the output. The `metadata` section (name, namespace) is in plain text. You can see this is a secret called `podinfo-secrets` in the `production` namespace. But the `stringData` values are encrypted. You know what secrets exist. You can't read the values. This is safe to commit to Git.

Remove the plain secret and commit:

```bash
rm apps/podinfo-helm/secret.yaml
git add -A
git commit -m "Add SOPS-encrypted secret for podinfo"
git push
```

!!! note "Don't have sops locally?"
    If sops isn't installed on your laptop, you can do this on the **bastion node** instead. Pull your repo, encrypt there, commit and push. But for real-world use, sops should be on every developer's machine.

---

## Task 4: Configure Flux to decrypt SOPS secrets

On your **local machine**, update the Helm Kustomization to enable SOPS decryption. Edit `clusters/apps-podinfo-helm.yaml` and add the `decryption` block:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: apps-podinfo-helm
  namespace: flux-system
spec:
  interval: 5m
  dependsOn:
    - name: infrastructure
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./apps/podinfo-helm
  wait: true
  timeout: 5m
  decryption:
    provider: sops
    secretRef:
      name: sops-age
```

Commit and push:

```bash
git add -A
git commit -m "Enable SOPS decryption for podinfo-helm Kustomization"
git push
```

---

## Task 5: Verify the secret was decrypted and applied

On your **bastion node**, wait for Flux to reconcile:

```bash
flux get kustomizations --watch
```

Once `apps-podinfo-helm` shows `Ready: True`:

```bash
kubectl get secret podinfo-secrets -n production
```

Verify the decrypted value:

```bash
kubectl get secret podinfo-secrets -n production -o jsonpath='{.data.API_KEY}' | base64 -d
```

You should see `my-super-secret-api-key-12345`. Encrypted in Git. Decrypted by Flux. Applied to the cluster.

---

## Task 6: Update the HelmRelease to use the secret

On your **local machine**, edit `apps/podinfo-helm/production.yaml` to mount the secret:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: podinfo
  namespace: production
spec:
  interval: 5m
  chart:
    spec:
      chart: podinfo
      version: ">=6.0.0"
      sourceRef:
        kind: HelmRepository
        name: podinfo
        namespace: flux-system
  values:
    replicaCount: 3
    resources:
      requests:
        cpu: 200m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
    ui:
      message: "Hello from production (Helm + SOPS)"
    extraEnvFrom:
      - secretRef:
          name: podinfo-secrets
```

Commit and push:

```bash
git add -A
git commit -m "Mount encrypted secrets into podinfo HelmRelease"
git push
```

---

## Task 7: Verify the application has the secrets

On your **bastion node**, once Flux reconciles:

```bash
kubectl exec -n production deploy/podinfo -- env | grep -E "API_KEY|DB_PASSWORD"
```

Both environment variables should show their decrypted values. Encrypted file in Git. Decrypted secret in the cluster. Environment variables in the running pod. No human touched anything.

---

## Validation

Confirm all of the following before moving on:

- [ ] `sops-age` secret exists in `flux-system` namespace
- [ ] `secret.encrypted.yaml` exists in `apps/podinfo-helm/` with encrypted values
- [ ] No plain text `secret.yaml` exists in Git
- [ ] `kubectl get secret podinfo-secrets -n production` returns the secret
- [ ] Decrypted values are accessible inside the podinfo pod

---

## What you built

```
your-repo/
├── .sops.yaml                        <-- Encryption rules (public key)
├── sops/
│   └── age-key.txt                   <-- Key pair (workshop only, never in prod)
├── clusters/
│   └── apps-podinfo-helm.yaml        <-- UPDATED: decryption block
├── apps/
│   └── podinfo-helm/
│       ├── production.yaml            <-- UPDATED: extraEnvFrom
│       └── secret.encrypted.yaml      <-- NEW: encrypted, safe in Git
└── ...
```

Secrets in Git. Encrypted at rest. Decrypted by Flux. Version controlled. Auditable.

!!! quote "Think about your current setup"
    Where do your secrets live right now? Be honest. How many people have access? How do you rotate them? How do you audit who changed what? SOPS gives you version history, access control via Git, and encryption at rest. For free.

[Next: Lab 5 - Monitoring and Troubleshooting](5-monitoring-troubleshooting.md){ .md-button .md-button--primary }
