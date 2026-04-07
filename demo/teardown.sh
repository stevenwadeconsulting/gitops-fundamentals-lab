#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# MCP Demo Teardown
# Run this from your LAPTOP after the demo
# ============================================================================

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config-workshop}"

echo "=== Cleaning up MCP demo state ==="

# Remove any canary releases if they exist
kubectl delete helmrelease podinfo-canary -n production --ignore-not-found

# The Lab 5 breakage should be fixed by the attendee via git revert
# If it's still broken, remind them to revert
echo ""
echo "Checking HelmRelease status..."
flux get helmreleases -A
echo ""
echo "If podinfo is still broken, the attendee needs to git revert the Lab 5 breakage."
echo ""
echo "=== Demo teardown complete ==="
