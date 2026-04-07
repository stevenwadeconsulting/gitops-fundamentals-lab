#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# MCP Demo Setup Script
# Run this from your LAPTOP during the break before the demo segment (14:40)
# ============================================================================

echo "=== MCP Demo Setup ==="
echo ""

# Step 1: Get the kubeconfig from the bastion
BASTION_IP="${1:?Usage: ./setup.sh <BASTION_IP>}"
SSH_KEY="${SSH_KEY:-./id_rsa}"

echo "Step 1: Copying kubeconfig from bastion..."
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no "root@${BASTION_IP}:/root/.kube/config" ~/.kube/config-workshop
echo "Kubeconfig saved to ~/.kube/config-workshop"

# Step 2: Test the connection
echo ""
echo "Step 2: Testing cluster connection..."
export KUBECONFIG=~/.kube/config-workshop
kubectl get nodes
echo ""

# Step 3: Verify Flux is running
echo "Step 3: Verifying Flux..."
flux get all
echo ""

# Step 4: Check for broken HelmRelease from Lab 5
echo "Step 4: Checking for broken resources from Lab 5..."
echo ""
echo "HelmReleases:"
flux get helmreleases -A
echo ""
echo "Kustomizations:"
flux get kustomizations
echo ""

# Step 5: Claude Desktop config
echo "=== Claude Desktop Configuration ==="
echo ""
echo "Add or update your Claude Desktop config at:"
echo "  ~/Library/Application Support/Claude/claude_desktop_config.json"
echo ""
echo "Add this to the JSON:"
echo ""
cat <<'CONFIG'
{
  "mcpServers": {
    "flux-operator-mcp": {
      "command": "flux-operator-mcp",
      "args": ["serve", "--read-only=false", "--mask-secrets=true"],
      "env": {
        "KUBECONFIG": "/Users/steve.wade/.kube/config-workshop"
      }
    }
  }
}
CONFIG
echo ""
echo "Then restart Claude Desktop."
echo ""
echo "=== Demo Prompts (in order) ==="
echo ""
echo '1. "Analyse the Flux installation in my current cluster and report the status of all components."'
echo '2. "List the Flux Kustomizations and draw a Mermaid diagram showing the depends-on relationships."'
echo '3. "Perform a root cause analysis of the last failed Helm release in the production namespace."'
echo '   (Uses the breakage from Lab 5 - attendees just saw the manual troubleshooting, now MCP does it in 30 seconds)'
echo '4. "How do I configure health checks for a HelmRelease? Search the latest Flux docs."'
echo ""
echo "=== Ready to demo ==="
