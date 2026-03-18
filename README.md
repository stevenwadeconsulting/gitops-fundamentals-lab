# GitOps Fundamentals Workshop

Welcome to the GitOps Fundamentals Workshop! This hands-on workshop transforms how you think about deployment. You'll build a working GitOps pipeline on a real Kubernetes cluster, make changes through pull requests, and watch automated reconciliation happen.

## Workshop Overview

This workshop is for engineers who are tired of deployments that require human intervention at every step. By the end of the day, you'll have a complete GitOps workflow you can adapt for your organisation and the confidence to deploy on Friday.

### What You'll Learn

- The four GitOps principles that change everything
- Flux architecture: Source Controllers, Kustomize Controllers, Helm Controllers
- Multi-environment pipelines with Kustomize overlays
- Helm integration the GitOps way
- Image update automation for hands-free deployments
- Secret management with SOPS encryption
- Monitoring, troubleshooting, and rollback patterns from 50+ rescues

## Prerequisites

- Working knowledge of Kubernetes (Deployments, Services, Namespaces)
- Familiarity with Git (commits, branches, pull requests)
- Comfort with YAML
- If you can run `kubectl get pods` and push to a Git repository, you're ready

## Lab Environment

Each participant will have access to:

- A pre-configured Kubernetes cluster with Flux installed
- A dedicated GitHub repository for GitOps workflows
- All workshop materials and example manifests

No local Kubernetes installation required.

## Getting Started

1. Access your workshop environment using the credentials provided on your desk
2. Verify Flux is running:
   ```bash
   flux check
   ```
3. Clone this repository:
   ```bash
   git clone https://github.com/stevenwadeconsulting/gitops-fundamentals-lab.git
   cd gitops-fundamentals-lab
   cd examples
   ```

## Workshop Labs

1. **[Your First GitOps Pipeline](docs/labs/1-first-pipeline.md)** - Bootstrap Flux, deploy via pull request, watch reconciliation
2. **[Multi-Environment Mastery](docs/labs/2-multi-environment.md)** - Kustomize overlays for dev, staging, and production
3. **[Helm Integration](docs/labs/3-helm-integration.md)** - HelmRepository and HelmRelease resources
4. **[Image Update Automation](docs/labs/4-image-automation.md)** - Automatic deployments when new images are pushed
5. **[Secret Management with SOPS](docs/labs/5-sops-secrets.md)** - Encrypt secrets in Git with Mozilla SOPS
6. **[Monitoring & Troubleshooting](docs/labs/6-monitoring-troubleshooting.md)** - Observability, debugging, and rollback strategies

## Workshop Flow

Each lab includes four key sections:

1. **Objective**: What you'll learn in the lab
2. **Tasks**: Step-by-step instructions with explanations
3. **Validation**: How to verify your work
4. **Clean-up**: Instructions to reset your environment after each exercise

**Important**: Please follow the clean-up instructions at the end of each lab to ensure your cluster resources remain available for later exercises.

## Additional Resources

- [Flux Official Documentation](https://fluxcd.io/flux/)
- [GitOps Principles](https://opengitops.dev/)
- [Kustomize Documentation](https://kustomize.io/)
- [Mozilla SOPS](https://github.com/getsops/sops)
- [Kubernetes Official Documentation](https://kubernetes.io/docs/home/)

## Troubleshooting

If you encounter any issues during the labs:

1. Check Flux status:
   ```bash
   flux check
   flux get all
   ```

2. Inspect events:
   ```bash
   flux events
   ```

3. Ask for assistance from the workshop instructor

## Feedback

Your feedback is valuable! At the end of the workshop, please share your thoughts by completing our [feedback form](https://forms.gle/HxoVhSZRNk49BweS9).

## License

This workshop material is available under the [MIT License](LICENSE).
