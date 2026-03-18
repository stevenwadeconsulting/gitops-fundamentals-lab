# Accessing Your Workshop Environment

This guide explains how to access your dedicated environment for the GitOps Fundamentals workshop.

## Access Overview

Each participant has been assigned their own environment consisting of:

- A bastion host (jump server) in Digital Ocean
- A Kubernetes cluster with Flux pre-installed
- A dedicated GitHub repository for GitOps workflows

## 1️⃣ Find Your Participant Number

Locate the participant number provided on your desk. You will need this number to access your unique environment.

## 2️⃣ Access Your Instructions Page

Open your web browser and navigate to the following URL, replacing `<participant number>` with your assigned number:

```
https://gitops-workshop.lon1.digitaloceanspaces.com/<participant number>/instructions.html
```

For example, if your participant number is 042, you would navigate to:
```
https://gitops-workshop.lon1.digitaloceanspaces.com/participant-042/instructions.html
```

## 3️⃣ Follow the Web Instructions

On the instruction page, you will find:

- SSH credentials for your bastion host
- Details about your Kubernetes environment
- **Your GitHub Personal Access Token (PAT)** - you will need this in Lab 1
- **Your GitHub repository URL** - this is your personal copy of the workshop repo
- Initial access instructions

!!! warning
    Keep your instructions page open throughout the workshop. You will need the **PAT** and **repository URL** during the labs.

Follow all steps provided on this page to connect to your bastion host.

## 4️⃣ Set Up Your Workshop Environment

Once you have successfully connected to your bastion host, your participant repository has been pre-cloned. Navigate to it:

```bash
cd ~/workshop
cd examples
```

## 5️⃣ Verify Flux Is Running

Confirm that Flux is installed and healthy on your cluster:

```bash
flux check
```

You should see all Flux components reporting as healthy. If you encounter any issues, ask for assistance before proceeding.

## Troubleshooting

If you encounter any issues:

1. Double-check your participant number
2. Ensure you're using the correct SSH credentials from your instructions page
3. Verify Flux is running: `flux check`
4. Ask one of the workshop facilitators for assistance

Your environment will remain available throughout the duration of the workshop.
