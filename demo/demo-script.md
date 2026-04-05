# MCP Demo Script

**When:** 15:25-15:45 (after Lab 5, before AMA)
**Where:** Your laptop (participant-001's cluster)
**Tool:** Claude Desktop or Cursor with MCP configured

---

## Pre-Demo (15:20, during the break)

1. SSH into participant-001's bastion
2. Run: `bash demo/setup.sh`
3. Verify: one working HelmRelease, one broken
4. On your laptop: copy kubeconfig from bastion (`scp -i id_rsa root@BASTION_IP:/root/.kube/config ~/.kube/config`)
5. Open Claude Desktop / Cursor with MCP configured
6. Test: "What version of Flux is running in my current cluster?" (should return a real answer)

---

## The Setup (30 seconds)

Say to the room:

> "Everything we've done today has been about making Git the source of truth. But there's still a gap: when something goes wrong, you're still debugging with kubectl, looking at logs, piecing together what happened.
>
> What if you could just ask?
>
> Not a chatbot. Not a wrapper around kubectl. A model that actually understands your cluster's state, your Flux configuration, your reconciliation history.
>
> Let me show you what I mean."

---

## Prompt 1: Health Check (2 minutes)

Type into the AI assistant:

> "Analyse the Flux installation in my current cluster and report the status of all components and managed resources."

**What the audience sees:** A structured health summary: Flux version, component health, all Kustomizations, HelmReleases, sources, and their status. One of the releases will show as failing.

**Say:**

> "That's equivalent to running flux check, flux get all, and kubectl get events. Three commands synthesised into one answer. But notice something: it found a failing HelmRelease. Let's dig into that."

---

## Prompt 2: Dependency Diagram (2 minutes)

> "List the Flux Kustomizations and draw a Mermaid diagram showing the depends-on relationships."

**What the audience sees:** A Mermaid flowchart rendered inline, showing the deployment order and dependencies.

**Say:**

> "This diagram was generated from live cluster state, not from documentation. If someone adds a new dependency tomorrow, the diagram updates automatically."

---

## Prompt 3: Root Cause Analysis (5 minutes)

This is the centrepiece.

> "Perform a root cause analysis of the last failed Helm release in the production namespace."

**What the audience sees:** The AI traces through the HelmRelease, checks the HelmChart source, reads the controller logs, and presents a root cause: image tag 99.99.99 doesn't exist.

**Say:**

> "It traced from the HelmRelease, through the HelmChart, down to the controller logs. That's the full GitOps stack, one query, one answer. 
>
> An on-call engineer would take 15-20 minutes to do this manually. The MCP server did it in 30 seconds.
>
> And notice: it gave us the fix. Change the image tag. In our workshop, that fix goes through Git. Commit, push, Flux reconciles."

Pause. Let that land.

---

## Prompt 4: Live Operations (3 minutes)

> "Delete the podinfo-canary HelmRelease from the production namespace."

**What the audience sees:** The AI deletes the broken release.

> "Verify the deletion was successful and show me the current state of all HelmReleases in production."

**What the audience sees:** Only the healthy podinfo release remains.

**Say:**

> "Write operations go through your existing RBAC. The AI can't do anything your service account couldn't do with kubectl. And there's a read-only mode for production clusters."

---

## Prompt 5: Documentation (2 minutes)

> "How do I configure health checks for a HelmRelease? Search the latest Flux docs."

**What the audience sees:** An accurate, current answer based on the live Flux documentation.

**Say:**

> "This tool exists because GitOps tooling changes fast. The search_flux_docs call ensures answers reflect the current API, not what the model was trained on six months ago."

---

## The Landing (1 minute)

> "This isn't about typing instead of kubectl. It's about cognitive load.
>
> Every minute you spend piecing together what happened is a minute you're not shipping.
>
> Flux MCP is early. But this is where platform operations is going. The teams who figure this out first will have an unfair advantage.
>
> If you want to try this on your own cluster, the setup is on the workshop site. It's one binary and three lines of config."

---

## Fallback Plan

If the MCP server or AI assistant fails during the live demo:

1. Don't panic. Say: "This is experimental software. This is what experimental looks like in real time."
2. Fall back to the four-step troubleshooting pattern from Lab 5 (you already taught them this)
3. Show the MCP setup instructions on the workshop site and tell them to try it later
4. The credibility cost of a failed demo is near zero if you handle it honestly

---

## Post-Demo

Run on the bastion: `bash demo/teardown.sh`
