# Agenda

A full day of hands-on GitOps. Five labs. One demo. Zero slides you'll forget by Tuesday.

---

## Morning: Foundations

!!! abstract "09:00 - 09:45 | The Deployment Reality Check"
    Why most CI/CD pipelines create more problems than they solve. The four GitOps principles that change everything. Making the case to your leadership with numbers they'll care about.

!!! success "09:45 - 11:00 | Lab 1: Your First GitOps Pipeline"
    Connect your cluster to Git. Deploy your first application through a pull request. Watch reconciliation in action. Experience drift detection and correction.

    **Aha moment:** You push a change to Git, sit back, and watch it appear in your cluster. No CI script. No kubectl. No human intervention.

!!! quote "11:00 - 11:20 | Break"

!!! success "11:20 - 12:40 | Lab 2: Multi-Environment Mastery"
    Repository structures that scale. Kustomize overlays for dev, staging, and production. Promotion workflows that don't require prayer.

    **Aha moment:** You promote from dev to production with a single PR. Same config, different overlays. Zero drift possible.

!!! quote "12:40 - 13:20 | Lunch"

---

## Afternoon: Production Patterns

!!! success "13:20 - 14:00 | Lab 3: Helm Integration"
    Helm charts managed the GitOps way. HelmRepository and HelmRelease resources. Values management through Git. Remediation and rollback.

!!! success "14:00 - 14:40 | Lab 4: Secret Management with SOPS"
    Encrypt secrets in Git. Configure Flux to decrypt automatically. No more secrets in Slack. No more `kubectl create secret` by hand.

    **Aha moment:** You encrypt a secret, commit it to Git, and watch Flux decrypt and apply it.

!!! quote "14:40 - 15:00 | Break"

---

## Closing: Operations and the Future

!!! success "15:00 - 15:25 | Lab 5: Monitoring and Troubleshooting"
    Break things on purpose. Learn the four-step troubleshooting pattern from 50+ platform rescues. Rollback strategies that actually work. Suspend and resume for maintenance windows.

!!! danger "15:25 - 15:45 | Flux MCP Server Demo"
    AI-assisted GitOps debugging. Talk to your cluster in natural language. Root cause analysis. Cross-cluster comparison. This is where platform operations is going.

    **Aha moment:** "What's not reconciling?" and getting an actual answer.

!!! note "15:45 - 16:15 | Ask Me Anything"
    Your specific challenges. Your migration strategy. Your "but we're different because..." scenarios. No question is too awkward.

---

## Prerequisites

You're ready if you can:

- Run `kubectl get pods` and understand the output
- Push a commit to a Git repository
- Read a YAML file without crying

Helpful but not required: prior CI/CD experience, Helm or Kustomize exposure.

## Lab Structure

Each lab follows a consistent format:

1. **Objective**: What you will learn
2. **Tasks**: Step-by-step instructions
3. **Validation**: How to verify your work
4. **Clean-up**: Reset your environment for the next lab

!!! warning "Follow the clean-up steps"
    Clean-up at the end of each lab ensures your cluster is ready for the next exercise. Don't skip it.
