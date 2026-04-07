# Flux MCP Server Demo

AI-assisted GitOps. Talk to your cluster in natural language. Debug, analyse, and operate your GitOps pipelines without memorising kubectl commands.

<span class="lab-duration">20 minutes · live demo</span>

---

!!! info "This is a live demo"
    Steve will demonstrate the Flux MCP Server on a live cluster. Watch the prompts. Watch the responses. Think about how much time your team spends doing this manually.

---

## Demo Prompts

Copy and paste these into Claude Desktop during the demo.

### Prompt 1: Health Check

```
Analyse the Flux installation in my current cluster and report the status of all components and managed resources.
```

One prompt replaces `flux check`, `flux get all -A`, and `kubectl get events -A`. The AI calls the same Kubernetes API you would, it just presents the synthesis.

---

### Prompt 2: Dependency Diagram

```
List the Flux Kustomizations and draw a Mermaid diagram showing the depends-on relationships.
```

The AI reads your cluster's actual Kustomization resources, parses the `dependsOn` fields, and generates a live dependency diagram. Not from documentation. From your cluster. Always accurate.

---

### Prompt 3: Root Cause Analysis

```
Perform a root cause analysis of the last failed Helm release in the production namespace.
```

You just spent Lab 5 debugging this manually with the four-step pattern. The MCP server does the same thing in 30 seconds:

1. Checks the HelmRelease status and events
2. Checks the HelmChart source status
3. Pulls the controller logs
4. Synthesises a root cause with remediation steps

---

### Prompt 4: Documentation Search

```
How do I configure health checks for a HelmRelease? Search the latest Flux docs.
```

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

```
What version of Flux is running in my current cluster?
```

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
| Ask for Mermaid diagrams | Visually compelling. Renders inline in Claude. |
| Append "Search the latest docs" | Routes through `search_flux_docs` instead of stale training data |
| Ask "Which cluster am I connected to?" first | Prevents accidental operations on the wrong cluster |
