# What You Built

Congratulations. You just built a production-grade GitOps pipeline in 6 hours. Here's what's in your repository.

---

## Your Final Repository

```
your-repo/
├── .sops.yaml                             # SOPS encryption config (pre-configured)
├── sops/
│   └── age-key.txt                        # Workshop encryption key (pre-configured)
├── clusters/
│   ├── flux-instance.yaml                 # Flux manages itself (Lab 0)
│   ├── infrastructure.yaml                # Shared HelmRepositories (Lab 3)
│   ├── apps-podinfo-helm.yaml             # Helm-managed app + SOPS decryption (Labs 3-4)
│   └── notifications.yaml                 # GitHub commit status alerts (Lab 5)
├── apps/
│   ├── podinfo/                           # Raw YAML reference from Labs 1-2 (not synced)
│   │   ├── base/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   └── kustomization.yaml
│   │   └── overlays/
│   │       ├── dev/
│   │       ├── staging/
│   │       └── production/
│   └── podinfo-helm/
│       ├── namespace.yaml                 # Production namespace (Lab 3)
│       ├── production.yaml                # HelmRelease (Lab 3)
│       ├── secret.encrypted.yaml          # SOPS encrypted secret (Lab 4)
│       └── kustomization.yaml
├── infrastructure/
│   └── sources/
│       └── podinfo.yaml                   # HelmRepository (Lab 3)
└── notes.md                               # Your scratchpad + GitHub token
```

!!! info "What's active vs reference"
    The `apps/podinfo/` directory still exists from Labs 1-2 but no Flux Kustomization watches it. It's there as a reference for how raw YAML works. Everything that's actively deployed comes through the `apps/podinfo-helm/` path via Helm.

---

## What You Can Do Monday

| Skill | How |
|-------|-----|
| Deploy through Git | Push YAML. Flux reconciles. No kubectl apply. |
| Multi-environment | One base, three overlays. Promote with a commit. |
| Helm via GitOps | HelmRelease in Git. No helm install from laptops. |
| Encrypted secrets | SOPS in Git. Flux decrypts. No secrets in Slack. |
| Debug in 2 minutes | Status, describe, events, logs. Every time. |
| Rollback in 30 seconds | git revert. Push. Flux reconciles. |

---

## Take It Further

### Production-Grade Templates

The workshop used simplified examples. For your real team, use these:

| Template | What It Has |
|----------|-------------|
| [flux2-kustomize-template](https://github.com/swade1987/flux2-kustomize-template) | CI validation, kubeconform, pluto, conventional commits, multi-env overlays |
| [flux2-sops-template](https://github.com/swade1987/flux2-sops-template) | Pre-commit hooks that block unencrypted secrets, AWS KMS for production |

### The 10 Landmines

You've built the pipeline. Now avoid the landmines.

[The 10 Landmines Between Your GitOps Workshop and Production](https://guides.platformfix.com/gitops-10-landmines){ target="_blank" }

Free guide with a 25-question readiness audit you can run with your team in 15 minutes. Share it before your next planning meeting.

### Book a Platform Review

If you're sitting with the gap between what you learned today and how it applies to your specific stack, I'm happy to have that conversation.

[Book a 30-Minute Platform Review](https://calendly.com/platformfixer/devops-pro){ .md-button .md-button--primary target="_blank" }

You describe your stack. I tell you what I'd delete first. No pitch. Just the findings.

### Stay Connected

- [LinkedIn](https://www.linkedin.com/in/stevendavidwade/){ target="_blank" }: Weekly platform engineering insights
- [The Deletion Digest](https://newsletter.platformfix.com){ target="_blank" }: Weekly newsletter. One idea, no fluff.

---

Delete before you add.
