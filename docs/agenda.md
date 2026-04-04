# Agenda

## Schedule

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

## What You'll Learn

- **GitOps with Flux Operator**: Declarative cluster management with a single CRD
- **Multi-Environment Pipelines**: Kustomize overlays for dev, staging, and production
- **Helm Integration**: Managing Helm charts the GitOps way
- **Secret Management**: SOPS encryption so secrets never live in Slack again
- **Monitoring and Troubleshooting**: Patterns from 50+ platform rescues
- **AI-Assisted GitOps**: Live demo of the Flux MCP Server

## Prerequisites

- Working knowledge of Kubernetes (Deployments, Services, Namespaces)
- Familiarity with Git (commits, branches, pull requests)
- Comfort with YAML
- If you can run `kubectl get pods` and push to a Git repository, you're ready

## Lab Structure

Each lab follows a consistent format:

1. **Objective**: What you will learn
2. **Tasks**: Step-by-step instructions
3. **Validation**: How to verify your work
4. **Clean-up**: Reset your environment for the next lab

!!! warning "Follow the clean-up steps"
    Please follow the clean-up instructions at the end of each lab. This ensures your cluster is ready for the next exercise.
