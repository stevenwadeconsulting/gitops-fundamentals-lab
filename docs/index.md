# GitOps Fundamentals with Flux

From Manual Deployments to AI-Assisted Operations. A full-day hands-on workshop by Steve Wade.

You'll build a working GitOps pipeline on a real Kubernetes cluster, deploy through Git, watch automated reconciliation happen, and understand why this changes everything about how you ship software.

!!! tip "Your Instructor"
    Steve Wade rescues failed Kubernetes migrations. 50+ platform audits. Over 100M in complexity prevented. Former Flux maintainer. Trained 6,000+ engineers, 400+ specifically on GitOps.

    [More about Steve](about-instructor.md)

## Workshop Overview

This workshop is for engineers who are tired of deployments that require human intervention at every step. By the end of the day, you'll have:

- A complete GitOps workflow you can adapt for your organisation
- The confidence to deploy on Friday (yes, really)
- A readiness audit you can run with your team in 15 minutes
- The answer to "but what about..." for every objection your colleagues will raise

## What You Will Learn

- **GitOps with Flux Operator**: Declarative cluster management with a single CRD
- **Multi-Environment Pipelines**: Kustomize overlays for dev, staging, and production
- **Helm Integration**: Managing Helm charts the GitOps way
- **Secret Management**: SOPS encryption so secrets never live in Slack again
- **Monitoring and Troubleshooting**: Patterns from 50+ platform rescues
- **AI-Assisted GitOps**: Live demo of the Flux MCP Server for natural language debugging

## Agenda

| Time | Session |
|------|---------|
| 09:00 - 09:45 | **The Deployment Reality Check**: Why most CI/CD pipelines create more problems than they solve |
| 09:45 - 11:00 | **Lab 1: Your First GitOps Pipeline**: Deploy through a pull request, watch reconciliation |
| 11:00 - 11:20 | Break |
| 11:20 - 12:40 | **Lab 2: Multi-Environment Mastery**: Kustomize overlays, promotion workflows |
| 12:40 - 13:20 | Lunch |
| 13:20 - 14:00 | **Lab 3: Helm Integration**: Helm charts managed by Flux |
| 14:00 - 14:40 | **Lab 4: Secret Management with SOPS**: Encrypted secrets in Git |
| 14:40 - 15:00 | Break |
| 15:00 - 15:25 | **Lab 5: Monitoring and Troubleshooting**: Breaking things on purpose |
| 15:25 - 15:45 | **Flux MCP Server Demo**: AI-assisted GitOps debugging |
| 15:45 - 16:15 | **Ask Me Anything**: Your challenges, your migration strategy |

## Prerequisites

- Working knowledge of Kubernetes (Deployments, Services, Namespaces)
- Familiarity with Git (commits, branches, pull requests)
- Comfort with YAML
- If you can run `kubectl get pods` and push to a Git repository, you're ready

## Your Environment

Each participant gets:

- A pre-configured Kubernetes cluster
- A dedicated bastion node with all tools pre-installed (kubectl, Flux, Helm, SOPS, age)
- A personal GitHub repository for your GitOps workflow

No local Kubernetes installation. No Docker Desktop. No minikube. You'll be deploying within 45 minutes of sitting down.

[Access your environment](access.md){ .md-button .md-button--primary }

## Workshop Labs

Five hands-on labs, each building on the previous:

1. **[Your First GitOps Pipeline](labs/1-first-pipeline.md)**: Bootstrap Flux, deploy via Git, watch reconciliation
2. **[Multi-Environment Mastery](labs/2-multi-environment.md)**: Kustomize overlays for dev, staging, and production
3. **[Helm Integration](labs/3-helm-integration.md)**: HelmRepository and HelmRelease resources
4. **[Secret Management with SOPS](labs/4-sops-secrets.md)**: Encrypt secrets in Git
5. **[Monitoring and Troubleshooting](labs/5-monitoring-troubleshooting.md)**: Observability, debugging, and rollbacks

Plus: **[Flux MCP Server Demo](labs/flux-mcp-demo.md)**: AI-assisted GitOps debugging with natural language.

## Lab Structure

Each lab follows a consistent format:

1. **Objective**: What you will learn
2. **Tasks**: Step-by-step instructions with explanations
3. **Validation**: How to verify your work
4. **Clean-up**: Reset your environment for the next lab

!!! warning "Follow the clean-up steps"
    Please follow the clean-up instructions at the end of each lab. This ensures your cluster is ready for the next exercise.

## Troubleshooting

If you hit an issue during the labs:

```bash
# What failed?
flux get all

# What's the error?
kubectl describe kustomization <name> -n flux-system

# What happened?
flux events --for kustomization/<name>

# Why?
kubectl logs -n flux-system deploy/kustomize-controller
```

If none of that helps, raise your hand.

## Resources

- [Flux Documentation](https://fluxcd.io/flux/){ target="_blank" }
- [Flux Operator Documentation](https://fluxcd.controlplane.io/){ target="_blank" }
- [OpenGitOps Principles](https://opengitops.dev/){ target="_blank" }
- [Kustomize Documentation](https://kustomize.io/){ target="_blank" }
- [Mozilla SOPS](https://github.com/getsops/sops){ target="_blank" }

## After the Workshop

- [The 10 Landmines Between Your GitOps Workshop and Production](https://guides.platformfix.com/gitops-10-landmines){ target="_blank" }: Free guide with the 25-question readiness audit
- [Book a Platform Review](https://calendly.com/platformfixer/devops-pro){ target="_blank" }: 30 minutes. You describe your stack. I tell you what I'd delete first.
- [The Deletion Digest](https://newsletter.platformfix.com){ target="_blank" }: Weekly newsletter. One idea, no fluff.

## Feedback

!!! note "Your feedback matters"
    At the end of the workshop, please take a few minutes to share your thoughts via the [feedback form](https://forms.gle/HxoVhSZRNk49BweS9){ target="_blank" }.
