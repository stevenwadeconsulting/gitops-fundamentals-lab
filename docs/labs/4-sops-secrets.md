# Lab 4: Secret Management with SOPS

Encrypt secrets in Git. Commit them safely. Watch Flux decrypt and apply them automatically. No more secrets in Slack.

**Duration:** 40 minutes

---

## Objectives

By the end of this lab, you will:

- Generate an age encryption key pair
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

## Task 1: Generate an age key pair

On your **bastion node**, generate an encryption key:

```bash
age-keygen -o age-key.txt
```

This creates a file with both the public and private key. Display the public key:

```bash
grep "public key" age-key.txt
```

Copy the public key (starts with `age1...`). You'll need it in Task 3.

!!! warning "The private key stays on the cluster"
    The private key in `age-key.txt` is what Flux uses to decrypt. It never goes in Git. The public key is what you use to encrypt. It can be shared freely.

---

## Task 2: Create the decryption secret for Flux

On your **bastion node**, create a Kubernetes Secret from the age key so Flux can decrypt:

```bash
cat age-key.txt | kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=/dev/stdin
```

Verify:

```bash
kubectl get secret sops-age -n flux-system
```

---

## Task 3: Create a SOPS configuration file

On your **local machine**, create `.sops.yaml` in the root of your repository:

```yaml
creation_rules:
  - path_regex: .*\.encrypted\.yaml$
    encrypted_regex: ^(data|stringData)$
    age: YOUR_AGE_PUBLIC_KEY
```

Replace `YOUR_AGE_PUBLIC_KEY` with the public key from Task 1 (the `age1...` string).

!!! info "What does this do?"
    This tells SOPS: for any file ending in `.encrypted.yaml`, only encrypt the `data` and `stringData` fields. The metadata (name, namespace, labels) stays readable. You can see what secrets exist in Git without being able to read the values.

---

## Task 4: Create a plain secret

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

## Task 5: Encrypt the secret with SOPS

On your **bastion node**, encrypt the secret. First, set the age recipient:

```bash
export SOPS_AGE_RECIPIENTS="YOUR_AGE_PUBLIC_KEY"
```

Clone your repo on the bastion temporarily:

```bash
git clone https://github.com/platformfix/gitops-workshop-YOUR_USERNAME /tmp/workshop
cd /tmp/workshop
```

Pull the latest changes (including the `.sops.yaml` and plain secret):

```bash
git pull
```

Encrypt the secret:

```bash
sops --encrypt --encrypted-regex '^(data|stringData)$' \
  apps/podinfo-helm/secret.yaml > apps/podinfo-helm/secret.encrypted.yaml
```

View the encrypted file:

```bash
cat apps/podinfo-helm/secret.encrypted.yaml
```

!!! success "The aha moment"
    Look at the output. The `metadata` section (name, namespace) is in plain text. You can see this is a secret called `podinfo-secrets` in the `production` namespace. But the `stringData` values are encrypted. You know what secrets exist. You can't read the values. This is safe to commit to Git.

Remove the plain secret and push:

```bash
rm apps/podinfo-helm/secret.yaml
git add -A
git commit -m "Add SOPS-encrypted secret for podinfo"
git push
```

Pull the changes on your **local machine**:

```bash
git pull
```

---

## Task 6: Configure Flux to decrypt SOPS secrets

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

## Task 7: Verify the secret was decrypted and applied

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

## Task 8: Update the HelmRelease to use the secret

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

## Task 9: Verify the application has the secrets

On your **bastion node**, once Flux reconciles:

```bash
kubectl exec -n production deploy/podinfo -- env | grep -E "API_KEY|DB_PASSWORD"
```

Both environment variables should show their decrypted values. The secrets went from an encrypted file in Git to environment variables in a running pod. No human touched the cluster.

---

## Validation

Confirm all of the following before moving on:

- [ ] `sops-age` secret exists in `flux-system` namespace
- [ ] `.sops.yaml` exists in the root of your repo
- [ ] `secret.encrypted.yaml` exists in `apps/podinfo-helm/` with encrypted values
- [ ] No plain text `secret.yaml` exists in Git
- [ ] `kubectl get secret podinfo-secrets -n production` returns the secret
- [ ] Decrypted values are accessible inside the podinfo pod

---

## What you built

```
your-repo/
├── .sops.yaml                        <-- NEW: encryption rules
├── clusters/
│   ├── ...
│   └── apps-podinfo-helm.yaml        <-- UPDATED: decryption block
├── apps/
│   ├── podinfo/
│   └── podinfo-helm/
│       ├── kustomization.yaml
│       ├── production.yaml            <-- UPDATED: extraEnvFrom
│       └── secret.encrypted.yaml      <-- NEW: encrypted, safe in Git
├── infrastructure/
│   └── sources/
└── ...
```

Secrets in Git. Encrypted at rest. Decrypted by Flux. Version controlled. Auditable. No more Slack messages with passwords.

!!! quote "Think about your current setup"
    Where do your secrets live right now? Be honest. How many people have access? How do you rotate them? How do you audit who changed what? SOPS gives you version history, access control via Git, and encryption at rest. For free.

[Next: Lab 5 - Monitoring and Troubleshooting](5-monitoring-troubleshooting.md){ .md-button .md-button--primary }
