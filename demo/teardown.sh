#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# MCP Demo Teardown
# Run this from your LAPTOP after the demo to clean up
# ============================================================================

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config-workshop}"

echo "=== Cleaning up MCP demo state ==="

kubectl delete helmrelease podinfo-canary -n production --ignore-not-found
echo "Broken HelmRelease removed."

echo "=== Demo teardown complete ==="
