# Your Environment

Everything is pre-configured. No local installs. You'll be deploying within 45 minutes.

---

## What You Get

- A **bastion node** with kubectl, Flux, Helm, SOPS, and age pre-installed
- A **Kubernetes cluster** with worker nodes ready
- A **personal GitHub repository** for your GitOps workflow (via GitHub Classroom)
- A **personal instruction page** with your SSH key and connection details

---

## Step 1: Open Your Instruction Page

Find the card on your desk with your participant number.

Open your browser and go to:

```
https://workshop.platformfix.com/gitops/join/participant-XXX/
```

Replace `XXX` with your number. For example, participant 7:

```
https://workshop.platformfix.com/gitops/join/participant-007/
```

Your instruction page has everything you need: SSH key download, bastion IP, cluster details, and your GitHub repo URL.

!!! tip "Keep this tab open"
    You'll reference your instruction page throughout the day.

---

## Step 2: Download Your SSH Key and Connect

From your instruction page:

1. Click **Download SSH Private Key**
2. Open a terminal and set permissions:

    ```bash
    chmod 600 id_rsa
    ```

3. Connect to your bastion node (the command is on your instruction page):

    ```bash
    ssh -i id_rsa root@<your-bastion-ip>
    ```

!!! note "Windows users"
    Use WSL or Git Bash. If you must use PuTTY, convert the key to PPK format with PuTTYgen.

---

## Step 3: Verify Your Cluster

Once connected to your bastion:

```bash
kubectl get nodes
```

You should see worker nodes in `Ready` state. If not, raise your hand.

---

## Step 4: Accept Your GitHub Classroom Repository

Steve will share a GitHub Classroom link at the start of the workshop.

1. Click the link
2. Authorise with your GitHub account
3. A private repository will be created for you under the `platformfix` organisation
4. Clone it to your **local machine** (not the bastion):

    ```bash
    git clone <your-repo-url>
    ```

!!! warning "Git changes happen on your laptop, not the bastion"
    You'll edit files and push from your local machine. The bastion is for running kubectl and flux commands to observe what Flux does with your changes.

---

## Step 5: Verify Your Tools

On the bastion, confirm everything is installed:

```bash
kubectl version --client
flux version --client
flux-operator --version
helm version --short
sops --version
age --version
```

All commands should return version numbers. If anything is missing, raise your hand.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Can't download SSH key | Try a different browser. Check the URL matches your participant number. |
| SSH connection refused | Double check the IP from your instruction page. Make sure `chmod 600` was run. |
| kubectl not working | Run `cat ~/.kube/config` on the bastion. If empty, raise your hand. |
| GitHub Classroom link not working | Make sure you're signed into GitHub. Try an incognito window. |

If none of that works, raise your hand. Don't waste lab time debugging access issues.
