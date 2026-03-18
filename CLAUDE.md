# CLAUDE.md

## Project Overview

This is a **one-day GitOps Fundamentals workshop** repository, following the same structure and conventions as the existing [k8s-fundamentals-labs](https://github.com/stevenwadeconsulting/k8s-fundamentals-labs) repo. The workshop teaches Flux-based GitOps on Kubernetes through 6 hands-on labs.

## Architecture Decisions

### Participant Isolation (Repo per participant)
- This repo is a **GitHub template repository**
- The Terraform provisioning module (separate repo) creates `gitops-workshop-participant-NNN` repos under `stevenwadeconsulting` org from this template
- Each participant's Flux is bootstrapped pointing to their own repo
- This gives full isolation and allows image automation (Lab 4) to commit back to Git without conflicts
- Future: consider moving to a `platformfix` GitHub org

### Authentication (Fine-grained PAT)
- A single fine-grained PAT (scoped to `stevenwadeconsulting` org, `contents:read/write` on `gitops-workshop-participant-*` repos) is used everywhere
- **Flux** uses it via a `github-credentials` Secret in `flux-system` namespace - participants create this in Lab 1 using the PAT from their instructions page
- **Bastion hosts** have git credential store pre-configured so participants can `git push` without auth prompts
- **Participants don't need a GitHub account** - everything is pre-configured on their bastion

### Separation of Concerns
- **This repo** = workshop content only (docs, labs, example manifests). It is the GitHub template that participant repos are created from.
- **Terraform module repo** (separate, already exists) = all infrastructure provisioning. It creates DigitalOcean clusters, bastions, participant GitHub repos, PATs, and generates per-participant instruction HTML pages (uploaded to DigitalOcean Spaces). That module also handles:
  - Installing Flux on each cluster
  - Pre-installing CLI tools (sops, age) on bastions
  - Configuring git credentials on bastions
  - Generating the participant instructions page with their PAT, repo URL, and SSH credentials
- Participants get their PAT and repo URL from the instructions HTML page, then use it in Lab 1 to create the Flux `github-credentials` secret

### Repository Structure
- `docs/` - MkDocs Material site (workshop guide, hosted on GitHub Pages)
- `examples/` - YAML manifests organised by lab number (001-006), this is what participants work with
- `.github/workflows/` - CI/CD for docs deployment and commit linting

### Tech Stack
- **Documentation:** MkDocs with Material theme (same as k8s-fundamentals-labs)
- **GitOps tool:** Flux v2
- **Secret management:** Mozilla SOPS with age encryption
- **Cluster provisioning:** DigitalOcean Kubernetes via Terraform (separate repo)
- **Participant repos:** GitHub template repository, created by Terraform module

## Workshop Agenda Mapping

| Time | Session | Lab |
|------|---------|-----|
| 09:00-09:45 | The Deployment Reality Check | (slides/discussion, no lab) |
| 09:45-11:00 | Flux Architecture & First Pipeline | Lab 1 |
| 11:20-12:40 | Multi-Environment Mastery | Lab 2 |
| 13:20-14:00 | Helm Integration | Lab 3 |
| 14:00-14:20 | Image Update Automation | Lab 4 |
| 14:20-14:40 | Secret Management with SOPS | Lab 5 |
| 15:00-15:45 | When Things Go Wrong | Lab 6 |
| 15:45-16:15 | Ask Me Anything | (no lab) |

## Commands

- `make serve` - Run MkDocs locally via Docker (http://localhost:8000)
- `make initialise` - Install and run pre-commit hooks

## Conventions

- Conventional commits enforced via pre-commit hooks and CI
- Lab markdown uses admonition boxes (`!!! info`, `!!! warning`, `!!! tip`, `!!! note`)
- Each lab directory in examples/ is prefixed with a zero-padded number (e.g., `001-first-pipeline`)
- Each lab has a consistent structure: Introduction, Objectives, Prerequisites, warning box for `cd`, Tasks, Validation, Summary, Next Steps
- Emojis are used in documentation headings (matching k8s-fundamentals-labs style)

## Outstanding Work

### Terraform Module (separate repo)
- [ ] Add GitHub repo creation from template to the existing Terraform module
- [ ] Add fine-grained PAT creation (or document manual step) in the Terraform module
- [ ] Add PAT and repo URL to the generated participant instructions HTML page
- [ ] Pre-install `sops` and `age` CLI tools on bastion hosts
- [ ] Install Flux + image automation controllers on each cluster
- [ ] Configure git credentials on bastions (credential store with PAT)
- [ ] Pre-clone participant repo on bastion

### This Repo - Lab Content Refinement
- [ ] Update Lab 1 so participants create the `github-credentials` Flux secret using the PAT from their instructions page
- [ ] Update `docs/access.md` to reference the PAT and repo URL from the instructions page
- [ ] Test all 6 labs end-to-end on a real cluster to verify commands and expected outputs
- [ ] Verify Flux API versions match the Flux version that will be installed (v2.x)
- [ ] Lab 4: confirm podinfo image tags available in ghcr.io for the semver range used
- [ ] Lab 5: replace placeholder encrypted-secret.yaml with a real SOPS-encrypted file (generated during provisioning)
- [ ] Lab 6: test all broken-* scenarios produce clear, instructive error messages
- [ ] Review timing: ensure each lab fits within its allocated slot

### This Repo - Documentation
- [ ] Create/update the feedback form URL (currently pointing to k8s workshop form)
- [ ] Update `docs/access.md` with final DigitalOcean Spaces URL pattern for this workshop
- [ ] Add workshop slides or presentation notes for the 09:00-09:45 theory session
- [ ] Add a "30-day adoption roadmap" page or handout (mentioned in the abstract)

### This Repo - CI/CD & Repo Config
- [ ] Set this repo as a GitHub template repository in GitHub settings
- [ ] Enable GitHub Pages on the stevenwadeconsulting/gitops-fundamentals-lab repo
- [ ] Verify docs workflow deploys correctly
- [ ] Add `.sops.yaml` configuration file for default encryption rules
