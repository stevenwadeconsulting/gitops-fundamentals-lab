# Flux MCP Server Demo

AI-assisted GitOps. Talk to your cluster in natural language. Debug, analyse, and operate your GitOps pipelines without memorising kubectl commands.

**Duration:** 20 minutes (live demo by Steve, not a hands-on lab)

---

!!! info "This is a live demo"
    Steve will demonstrate the Flux MCP Server on a live cluster. Watch the prompts. Watch the responses. Think about how much time your team spends doing this manually.

---

## What You'll See

### 1. Health check in one prompt

Instead of running `flux check`, `flux get all -A`, and `kubectl get events -A` separately:

> "Analyse the Flux installation in my current cluster and report the status of all components and managed resources."

One prompt. One synthesised answer. The AI calls the same Kubernetes API you would, it just presents the synthesis.

---

### 2. Dependency visualisation from live state

> "List the Flux Kustomizations and draw a Mermaid diagram showing the depends-on relationships."

The AI reads your cluster's actual Kustomization resources, parses the `dependsOn` fields, and generates a live dependency diagram. Not from documentation. From your cluster. Always accurate.

---

### 3. Root cause analysis

This is the most powerful capability. Steve will intentionally break a HelmRelease, then ask:

> "Perform a root cause analysis of the last failed Helm release in the podinfo namespace."

The AI will:

1. Check the HelmRelease status and events
2. Check the HelmChart source status
3. Check the Helm controller pod
4. Pull the controller logs filtered to the release name
5. Synthesise a root cause with remediation steps

This is what an on-call engineer does over 15-20 minutes. The MCP server does it in 30 seconds.

---

### 4. Live operations

> "Suspend all failing HelmReleases in the test namespace, then delete them from the cluster."

> "Resume all suspended Flux Kustomizations in the cluster and verify their status."

Write operations through natural language. Every action goes through your existing RBAC. The AI can't do anything your service account couldn't do with kubectl. And there's a `--read-only` mode for production.

---

### 5. Documentation-grounded answers

> "How do I configure mutual TLS for a Flux GitRepository? Answer using the latest Flux docs."

The AI searches the live Flux documentation, not its training data. GitOps tooling changes fast. This ensures answers reflect the current API.

---

## Why This Matters

This isn't about typing instead of kubectl. It's about **cognitive load**.

Every minute you spend:

- Remembering the right command
- Parsing YAML output
- Correlating events with logs
- Mentally diffing two clusters

...is a minute you're not shipping. The Flux MCP Server removes the translation layer between "what do I want to know?" and "the answer."

---

## The Future of Platform Operations

Flux MCP is early. It launched in 2025. Most teams haven't seen it yet. But this is where platform operations is going:

- AI agents that understand your cluster state
- Natural language debugging that chains multiple tools automatically
- Cross-cluster comparison without terminal window gymnastics
- Documentation that's always current, never stale

The teams who figure this out first will have an unfair advantage.

---

## Try It Yourself (After the Workshop)

Install the MCP server:

```bash
brew install controlplaneio-fluxcd/tap/flux-operator-mcp
```

Add to your AI assistant's MCP configuration:

```json
{
  "flux-operator-mcp": {
    "command": "flux-operator-mcp",
    "args": ["serve", "--read-only=false"],
    "env": {
      "KUBECONFIG": "/path/to/.kube/config"
    }
  }
}
```

Start with:

> "What version of Flux is running in my current cluster?"

If that works, everything is connected.

---

## Resources

- [Flux MCP Server Documentation](https://fluxoperator.dev/mcp-server/){ target="_blank" }
- [AI Prompting Guide](https://fluxoperator.dev/docs/mcp/prompting/){ target="_blank" }
- [Blog: AI-Assisted GitOps](https://fluxcd.io/blog/2025/05/ai-assisted-gitops/){ target="_blank" }
- [Agent Skills Repository](https://github.com/fluxcd/agent-skills){ target="_blank" }

---

## Effective Prompting Tips

| Tip | Why |
|-----|-----|
| Start broad, then narrow | "Analyse the Flux installation" before "debug this specific resource" |
| Name specific resources | "the podinfo HelmRelease in production" is 3x faster than "any failing releases" |
| Ask for Mermaid diagrams | Visually compelling. Renders inline in Claude and VS Code. |
| Chain operations | "Suspend all failing releases, then delete them" demonstrates workflow automation |
| Append "Search the latest docs" | Routes through `search_flux_docs` instead of stale training data |
| Ask "Which cluster am I connected to?" first | Prevents accidental operations on the wrong cluster |
