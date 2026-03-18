# 🚀 GitOps Fundamentals Workshop

Welcome to the GitOps Fundamentals Workshop! This hands-on workshop will transform how you think about deployment. You'll build a working GitOps pipeline on a real Kubernetes cluster, make changes through pull requests, watch automated reconciliation happen, and understand why this changes everything.

<div style="padding: 15px; margin: 20px 0; background-color: #e1f5fe; border-left: 5px solid #03a9f4; border-radius: 4px;">
<h3 style="margin-top: 0; color: #0277bd;">👨‍🏫 Meet Your Instructor</h3>
<p>This workshop is led by Steve Wade - an industry veteran who has rescued 50+ platforms, former Flux maintainer, and founder of the Cloud Native Club. He's been implementing Flux at scale since before it graduated.</p>
<p><a href="about-instructor">Learn more about your instructor →</a></p>
</div>

## 🔍 Workshop Overview

This workshop is for engineers who are tired of deployments that require human intervention at every step. By the end of the day, you'll have a complete GitOps workflow you can adapt for your organisation, the confidence to deploy on Friday (yes, really), and a 30-day adoption roadmap for your team.

### 📚 What You Will Learn

- **🏗️ GitOps Principles**: The four principles that change everything about deployment
- **🔄 Flux Architecture**: Source Controllers, Kustomize Controllers, Helm Controllers - demystified
- **🌍 Multi-Environment Pipelines**: Repository structures and promotion workflows that scale
- **⎈ Helm Integration**: Managing Helm charts the GitOps way
- **🤖 Image Automation**: New versions flow automatically from registry to cluster
- **🔐 Secret Management**: SOPS encryption so secrets never live in Slack again
- **🔍 Observability**: Monitoring, troubleshooting, and rollback strategies from 50+ rescues

## 📅 Agenda

| Time | Session |
|------|---------|
| 09:00 - 09:45 | **The Deployment Reality Check** - Why most CI/CD pipelines create more problems than they solve |
| 09:45 - 11:00 | **Lab 1: Your First GitOps Pipeline** - Connect your cluster to Git, deploy through a PR |
| 11:00 - 11:20 | Break |
| 11:20 - 12:40 | **Lab 2: Multi-Environment Mastery** - Kustomize overlays, promotion workflows |
| 12:40 - 13:20 | Lunch |
| 13:20 - 14:00 | **Lab 3: Helm Integration** - Helm charts the GitOps way |
| 14:00 - 14:20 | **Lab 4: Image Update Automation** - Hands-free deployments |
| 14:20 - 14:40 | **Lab 5: Secret Management with SOPS** - No more secrets in Slack |
| 14:40 - 15:00 | Break |
| 15:00 - 15:45 | **Lab 6: When Things Go Wrong** - Monitoring, troubleshooting, rollbacks |
| 15:45 - 16:15 | **Ask Me Anything** - Your challenges, your migration strategy |

## ✅ Prerequisites

- Working knowledge of Kubernetes (you know what Deployments, Services, and Namespaces are)
- Familiarity with Git (commits, branches, pull requests)
- Comfort with YAML (you won't cry when you see a ConfigMap)
- If you can run `kubectl get pods` and push to a Git repository, you're ready

## 💻 Lab Environment

Each participant will have access to:

- A pre-configured Kubernetes cluster with Flux installed
- A dedicated GitHub repository for GitOps workflows
- All workshop materials and example manifests

No local Kubernetes installation required. No Docker Desktop. No fighting with minikube. You'll be deploying within 45 minutes of sitting down.

To access your environment, follow the instructions provided [here](access.md).

## 🧪 Workshop Labs

The workshop consists of six hands-on labs, each building on the previous:

1. **[🔰 Your First GitOps Pipeline](labs/1-first-pipeline.md)** - Bootstrap Flux, deploy via pull request, watch reconciliation
2. **[🌍 Multi-Environment Mastery](labs/2-multi-environment.md)** - Kustomize overlays for dev, staging, and production
3. **[⎈ Helm Integration](labs/3-helm-integration.md)** - HelmRepository and HelmRelease resources
4. **[🤖 Image Update Automation](labs/4-image-automation.md)** - Automatic deployments when new images are pushed
5. **[🔐 Secret Management with SOPS](labs/5-sops-secrets.md)** - Encrypt secrets in Git with Mozilla SOPS
6. **[🔍 Monitoring & Troubleshooting](labs/6-monitoring-troubleshooting.md)** - Observability, debugging, and rollback strategies

## 🔄 Workshop Flow

<div style="padding: 15px; margin: 20px 0; background-color: #e3f2fd; border-left: 5px solid #2196f3; border-radius: 4px;">
<p>Each lab follows a consistent structure to enhance your learning:</p>
<ol>
  <li><strong>Objective</strong>: What you will learn in the lab</li>
  <li><strong>Tasks</strong>: Step-by-step instructions with explanations</li>
  <li><strong>Validation</strong>: How to verify your work</li>
  <li><strong>Clean-up</strong>: Instructions to reset your environment after each exercise</li>
</ol>
<p><strong>Important</strong>: Please follow the clean-up instructions at the end of each lab to ensure your cluster resources remain available for later exercises.</p>
</div>

## 📚 Additional Resources

- [Flux Official Documentation](https://fluxcd.io/flux/)
- [GitOps Principles](https://opengitops.dev/)
- [Kustomize Documentation](https://kustomize.io/)
- [Mozilla SOPS](https://github.com/getsops/sops)
- [Kubernetes Official Documentation](https://kubernetes.io/docs/home/)

## 🛠️ Troubleshooting

If you encounter any issues during the labs:

1. Check the Flux status:
   ```bash
   flux check
   flux get all
   ```

2. Inspect Flux events:
   ```bash
   flux events
   kubectl get events -n flux-system
   ```

3. Check resource reconciliation:
   ```bash
   flux get kustomizations
   flux get sources git
   ```

4. Ask for assistance from the workshop instructor

## 💬 Feedback

<div style="padding: 15px; margin: 20px 0; background-color: #fff8e1; border-left: 5px solid #ffc107; border-radius: 4px;">
<h3 style="margin-top: 0; color: #ff8f00;">📝 Your Feedback Matters!</h3>
<p>At the end of the workshop, please take a few minutes to share your thoughts by completing our <a href="https://forms.gle/HxoVhSZRNk49BweS9">feedback form</a>.</p>
<p>Your input helps us improve future workshops and develop new content based on your needs and interests.</p>
</div>
