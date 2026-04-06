# Lab 1: Your First GitOps Pipeline

Deploy an application through Git. No `kubectl apply`. No CI pipeline. Push to Git, watch it appear in your cluster.

<span class="lab-duration">50 minutes</span>

---

## Objectives

By the end of this lab, you will:

- Deploy an application to your cluster entirely through Git
- Understand the Flux reconciliation loop
- Experience drift detection and automatic correction
- Know the difference between push-based CI/CD and pull-based GitOps

---

## The GitOps Reconciliation Loop

```mermaid
graph LR
    A[You push YAML to Git] --> B[Git Repository]
    B -->|Flux polls| C[Source Controller]
    C -->|new commit detected| D[Kustomize Controller]
    D -->|applies to cluster| E[Kubernetes]
    E -->|drift detected| D

    style A fill:#1F2937,stroke:#D4A843,color:#F0EFE8
    style B fill:#1F2937,stroke:#D4A843,color:#F0EFE8
    style E fill:#1F2937,stroke:#22C55E,color:#F0EFE8
```

You push to Git. Flux detects the change. Flux applies it to the cluster. If something drifts (manual change, restart, scaling), Flux corrects it. Git always wins.

---

## Prerequisites

- [x] Completed [Lab 0: Flux Operator Bootstrap](0-bootstrap.md)
- [x] Flux is running and syncing from your repository

---

## Task 1: Create the application namespace

On your **local machine**, create the file `apps/podinfo/namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: podinfo
```

---

## Task 2: Create the application deployment

Create the file `apps/podinfo/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: podinfo
  namespace: podinfo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: podinfo
  template:
    metadata:
      labels:
        app: podinfo
    spec:
      containers:
        - name: podinfo
          image: ghcr.io/stefanprodan/podinfo:6.7.0
          ports:
            - containerPort: 9898
              name: http
          resources:
            requests:
              cpu: 100m
              memory: 64Mi
            limits:
              cpu: 200m
              memory: 128Mi
```

---

## Task 3: Create the service

Create the file `apps/podinfo/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: podinfo
  namespace: podinfo
spec:
  type: ClusterIP
  selector:
    app: podinfo
  ports:
    - port: 9898
      targetPort: http
      protocol: TCP
```

---

## Task 4: Create the Kustomization file

Create the file `apps/podinfo/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace.yaml
  - deployment.yaml
  - service.yaml
```

---

## Task 5: Tell Flux to watch the apps directory

Create the file `clusters/apps.yaml`:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: apps
  namespace: flux-system
spec:
  interval: 5m
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./apps/podinfo
  wait: true
  timeout: 2m
```

!!! info "What is this?"
    This is a Flux Kustomization (not to be confused with Kustomize). It tells Flux: "watch the `apps/podinfo` directory in my Git repo. Apply whatever you find there. If something disappears from Git, delete it from the cluster too (`prune: true`). Check every 5 minutes."

---

## Task 6: Push and watch

Your repo should now look like this:

```
your-repo/
├── clusters/
│   ├── flux-instance.yaml
│   └── apps.yaml              <-- NEW: tells Flux to watch apps/
├── apps/
│   └── podinfo/
│       ├── kustomization.yaml <-- NEW
│       ├── namespace.yaml     <-- NEW
│       ├── deployment.yaml    <-- NEW
│       └── service.yaml       <-- NEW
└── ...
```

Commit and push everything:

```bash
git add -A
git commit -m "Deploy podinfo via GitOps"
git push
```

Now switch to your **bastion node** and watch Flux reconcile:

```bash
flux get kustomizations --watch
```

Wait for the `apps` kustomization to show `Ready: True`. Then check your application:

```bash
kubectl get pods -n podinfo
kubectl get svc -n podinfo
```

!!! success "The aha moment"
    You just deployed an application to Kubernetes without touching kubectl. You pushed YAML to Git. Flux detected the change, pulled it, and applied it. This is GitOps.

---

## Task 7: Make a change through Git

On your **local machine**, edit `apps/podinfo/deployment.yaml` and change the replicas:

```yaml
spec:
  replicas: 3    # changed from 1
```

Commit and push:

```bash
git add -A
git commit -m "Scale podinfo to 3 replicas"
git push
```

On your **bastion node**, watch the change apply:

```bash
kubectl get pods -n podinfo --watch
```

Two new pods should appear within a minute. You didn't run `kubectl scale`. You changed a file in Git.

---

## Task 8: Experience drift detection

This is where GitOps proves its value. On your **bastion node**, manually scale the deployment down:

```bash
kubectl scale deployment podinfo -n podinfo --replicas=1
```

Check the pods:

```bash
kubectl get pods -n podinfo
```

You should see 2 pods terminating. Now force Flux to reconcile immediately (rather than waiting for the 5-minute interval):

```bash
flux reconcile kustomization apps
```

Wait a few seconds, then check again:

```bash
kubectl get pods -n podinfo
```

!!! success "Drift corrected"
    Flux re-applied the desired state from Git (3 replicas) and overrode your manual change. This is the reconciliation loop. Git always wins. Manual changes get reverted.

    In production, this happens automatically on every reconciliation interval. We forced it here so you don't have to wait 5 minutes. The point is the same: nobody can change the cluster and have it stick. Git is the source of truth.

---

## Task 9: Inspect Flux events

On your **bastion node**, see what Flux has been doing:

```bash
flux events --for kustomization/apps
```

You should see events for the initial deployment, the scale-up, and the drift correction.

For more detail:

```bash
kubectl describe kustomization apps -n flux-system
```

---

## Task 10: See it visually - the Flux Operator UI

Everything you've done so far has been through the CLI. Flux Operator includes a built-in web dashboard that shows your GitOps pipelines visually.

On your **bastion node**, change the Flux Operator service to a LoadBalancer:

```bash
kubectl -n flux-system patch svc flux-operator -p '{"spec": {"type": "LoadBalancer"}}'
```

Wait for the external IP to be assigned (this takes 30-60 seconds):

```bash
kubectl get svc flux-operator -n flux-system --watch
```

Once you see an `EXTERNAL-IP` (not `<pending>`), press `Ctrl+C` and note the IP address.

Open your browser and go to:

```
http://<EXTERNAL-IP>:9080
```

!!! success "Visual confirmation"
    You should see your GitOps pipelines: the GitRepository source, the Kustomization for your apps, the reconciliation status, all in one dashboard. Every change you push to Git will appear here. Keep this tab open for the rest of the day.

!!! tip "Troubleshooting the UI"
    If the EXTERNAL-IP stays as `<pending>` for more than 2 minutes, raise your hand. If the page doesn't load, make sure you're using port `9080` (not 8080).

---

## Validation

Confirm all of the following before moving on:

- [ ] podinfo deployment is running with 3 replicas in the `podinfo` namespace
- [ ] podinfo service exists in the `podinfo` namespace
- [ ] `flux get kustomizations` shows `apps` as `Ready: True`
- [ ] Manual `kubectl scale` was automatically reverted by Flux
- [ ] Flux Operator UI is accessible at `http://localhost:9080`

---

## What you built

```
your-repo/
├── clusters/
│   ├── flux-instance.yaml
│   └── apps.yaml
├── apps/
│   └── podinfo/
│       ├── kustomization.yaml
│       ├── namespace.yaml
│       ├── deployment.yaml
│       └── service.yaml
└── ...
```

You now have a working GitOps pipeline. Git is the source of truth. Flux reconciles. Drift gets corrected. No CI. No kubectl apply. No human in the loop.

!!! quote "Think about your current setup"
    How long would it take to deploy an application with your current pipeline? How many approval steps? How many people need to be involved? That's the gap GitOps closes.

[Next: Lab 2 - Multi-Environment Mastery](2-multi-environment.md){ .md-button .md-button--primary }
