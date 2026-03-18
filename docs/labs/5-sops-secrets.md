# Lab 5: Secret Management with SOPS

## Introduction

"Just put the secret in Slack." We've all heard it. We've all done it. And it's a problem.

If Git is your single source of truth, you need secrets in Git too - but obviously not in plain text. Mozilla SOPS (Secrets OPerationS) solves this by encrypting secrets at rest in your repository while keeping them decryptable only by your cluster.

In this lab, you'll encrypt Kubernetes Secrets with SOPS using age encryption, commit them to Git, and watch Flux decrypt and apply them automatically.

## Objectives

By the end of this lab, you will be able to:

- Understand why SOPS is the recommended approach for GitOps secret management
- Encrypt Kubernetes Secrets using SOPS and age
- Configure Flux to decrypt SOPS-encrypted secrets
- Deploy applications that consume encrypted secrets
- Rotate encryption keys

## Prerequisites

- Completion of [Lab 4: Image Update Automation](4-image-automation.md)
- Understanding of Kubernetes Secrets

!!! warning
    Execute `cd ../005-sops-secrets` to navigate to this lab directory

## Lab Tasks

### Task 1: Understanding SOPS and Age

SOPS encrypts the **values** in a YAML file while leaving the **keys** in plain text. This means you can still see the structure of a Secret in Git, but the sensitive data is encrypted.

Age is a modern encryption tool that SOPS supports. It's simpler than PGP and purpose-built for file encryption.

```bash
# Verify SOPS is installed
sops --version

# Verify age is installed
age --version
```

Let's see how SOPS works by examining a pre-encrypted secret:

```bash
# View the encrypted secret
cat encrypted-secret.yaml
```

!!! info
    Notice how the YAML structure is visible (apiVersion, kind, metadata, data keys) but the values are encrypted. The `sops` metadata at the bottom of the file contains the encryption details - which key was used, when it was encrypted, and the MAC (message authentication code) to detect tampering.

### Task 2: Creating an Age Key Pair

Let's create an age key pair for encryption:

```bash
# Generate a new age key pair
age-keygen -o age.key

# View the public key (you'll need this for encryption)
cat age.key | grep "public key"
```

!!! warning
    In production, the age private key would be securely stored and distributed to your cluster. Never commit the private key to Git. For this workshop, the key is pre-configured on your cluster.

Now let's make the private key available to Flux. In your workshop environment, this has already been done, but let's understand the process:

```bash
# This is how you'd create the secret for Flux (already done for you)
# kubectl create secret generic sops-age \
#   --namespace=flux-system \
#   --from-file=age.agekey=age.key

# Verify the secret exists
kubectl get secret sops-age -n flux-system
```

### Task 3: Encrypting a Secret with SOPS

Let's create and encrypt a new Kubernetes Secret:

```bash
# View the plain-text secret we want to encrypt
cat plain-secret.yaml
```

```yaml
# plain-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-credentials
  namespace: sops-demo
type: Opaque
stringData:
  database-url: "postgresql://admin:supersecret@db.example.com:5432/myapp"
  api-key: "sk-live-abc123def456ghi789"
```

Now encrypt it:

```bash
# Get the age public key
export AGE_PUBLIC_KEY=$(cat age.key | grep "public key" | awk '{print $NF}')

# Encrypt the secret with SOPS
sops --age=$AGE_PUBLIC_KEY \
  --encrypt \
  --encrypted-regex '^(data|stringData)$' \
  plain-secret.yaml > encrypted-app-secret.yaml

# View the encrypted result
cat encrypted-app-secret.yaml
```

!!! info
    The `--encrypted-regex '^(data|stringData)$'` flag tells SOPS to only encrypt the `data` and `stringData` fields. This keeps the rest of the manifest (apiVersion, kind, metadata) readable in Git while protecting the sensitive values.

Let's verify we can decrypt it:

```bash
# Decrypt the secret (using the private key)
export SOPS_AGE_KEY_FILE=age.key
sops --decrypt encrypted-app-secret.yaml
```

### Task 4: Configuring Flux for SOPS Decryption

To have Flux automatically decrypt SOPS-encrypted secrets, we need to configure the Kustomization with decryption settings:

```bash
# View the Kustomization with SOPS decryption
cat flux-kustomization.yaml
```

```yaml
# flux-kustomization.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: sops-demo
  namespace: flux-system
spec:
  interval: 5m
  path: ./examples/005-sops-secrets/app
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  decryption:
    provider: sops
    secretRef:
      name: sops-age
  wait: true
  timeout: 2m
```

!!! info
    The `decryption` block tells the kustomize-controller to use SOPS for decryption and to use the `sops-age` Secret for the decryption key. When Flux encounters an encrypted file, it automatically decrypts it before applying to the cluster.

Apply the Kustomization:

```bash
kubectl apply -f flux-kustomization.yaml

# Watch the reconciliation
flux get kustomizations --watch
```

### Task 5: Verifying the Decrypted Secret

Let's verify that Flux decrypted and applied the secret correctly:

```bash
# Check the secret exists in the target namespace
kubectl get secret app-credentials -n sops-demo

# Verify the secret contains the decrypted values
kubectl get secret app-credentials -n sops-demo -o jsonpath='{.data.database-url}' | base64 -d
echo ""
kubectl get secret app-credentials -n sops-demo -o jsonpath='{.data.api-key}' | base64 -d
echo ""
```

!!! tip
    The secret is stored encrypted in Git but decrypted in the cluster. If someone gains access to your Git repository, they can see the secret structure but not the values. If someone gains access to your cluster, they can see the decrypted values - but that's the same as with any Kubernetes Secret.

### Task 6: Deploying an Application That Uses the Secret

Let's deploy an application that consumes the encrypted secret:

```bash
# View the application deployment
cat app/deployment.yaml

# Check the deployed application
kubectl get all -n sops-demo

# Verify the application can access the secret
POD_NAME=$(kubectl get pods -n sops-demo -l app=sops-demo -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -n sops-demo -- env | grep -E 'DATABASE_URL|API_KEY'
```

### Task 7: Updating an Encrypted Secret

To update an encrypted secret, you decrypt it, make changes, and re-encrypt:

```bash
# Decrypt, edit, and re-encrypt in one step
export SOPS_AGE_KEY_FILE=age.key
sops encrypted-app-secret.yaml
```

This opens the file in your editor with decrypted values. After saving, SOPS automatically re-encrypts the file.

Alternatively, you can use the command-line approach:

```bash
# Decrypt to a temp file, edit, re-encrypt
sops --decrypt encrypted-app-secret.yaml > /tmp/secret.yaml
# Edit /tmp/secret.yaml
sops --age=$AGE_PUBLIC_KEY \
  --encrypt \
  --encrypted-regex '^(data|stringData)$' \
  /tmp/secret.yaml > encrypted-app-secret.yaml
rm /tmp/secret.yaml
```

### Task 8: Cleanup

Before moving to the next lab, clean up the SOPS resources:

```bash
# Delete the Kustomization
kubectl delete kustomization sops-demo -n flux-system

# Verify resources are cleaned up
kubectl get all -n sops-demo
kubectl get secret app-credentials -n sops-demo
flux get kustomizations
```

## Lab Validation

Let's confirm you've mastered the key concepts from this lab:

- You understand how SOPS encrypts values while keeping keys readable
- You can encrypt and decrypt Kubernetes Secrets using SOPS and age
- You can configure Flux Kustomizations for SOPS decryption
- You understand the workflow for updating encrypted secrets

## Summary

Congratulations! You have completed Lab 5 of the GitOps Fundamentals Workshop. In this lab, you've learned:

1. How SOPS encrypts YAML values while keeping structure visible
2. How to use age encryption with SOPS for secret management
3. How to configure Flux to automatically decrypt SOPS-encrypted secrets
4. The workflow for creating, updating, and managing encrypted secrets in Git

No more secrets in Slack. No more "can you send me the database password?" in chat. Secrets live in Git, encrypted at rest, and only your cluster can decrypt them.

## Next Steps

Proceed to [Lab 6: Monitoring & Troubleshooting](6-monitoring-troubleshooting.md) to learn how to monitor your GitOps pipeline and troubleshoot when things go wrong.
