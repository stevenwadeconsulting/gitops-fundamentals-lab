#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# MCP Demo Setup Script
# Run this from your LAPTOP before the demo segment (15:25)
# This creates the demo state: working apps + one intentionally broken release
# ============================================================================

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config-workshop}"

echo "=== Setting up MCP demo state ==="

# 1. Ensure podinfo is healthy in production (should already be from Lab 3)
echo "Checking podinfo HelmRelease in production..."
flux get helmrelease podinfo -n production

# 2. Create a second HelmRelease with a deliberately broken image tag
echo "Creating broken HelmRelease for demo..."
kubectl apply -f - <<EOF
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: podinfo-canary
  namespace: production
spec:
  interval: 5m
  chart:
    spec:
      chart: podinfo
      version: ">=6.0.0"
      sourceRef:
        kind: HelmRepository
        name: podinfo
        namespace: flux-system
  values:
    replicaCount: 2
    image:
      tag: "99.99.99"
    ui:
      message: "Canary release - should fail"
EOF

echo "Waiting 30 seconds for the failure to register..."
sleep 30

# 3. Verify the broken state
echo ""
echo "=== Demo state ready ==="
echo ""
echo "Working releases:"
flux get helmrelease podinfo -n production
echo ""
echo "Broken release (should show Ready: False):"
flux get helmrelease podinfo-canary -n production
echo ""
echo "=== You're ready for the MCP demo ==="
echo ""
echo "Prompts to use (in order):"
echo ""
echo '1. "Analyse the Flux installation in my current cluster and report the status of all components."'
echo '2. "List the Flux Kustomizations and draw a Mermaid diagram showing the depends-on relationships."'
echo '3. "Perform a root cause analysis of the last failed Helm release in the production namespace."'
echo '4. "Resume all suspended Flux resources and verify their status."'
echo '5. "How do I configure health checks for a HelmRelease? Search the latest Flux docs."'
