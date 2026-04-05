#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# MCP Demo Teardown
# Run this after the demo to clean up the broken HelmRelease
# ============================================================================

echo "=== Cleaning up MCP demo state ==="

kubectl delete helmrelease podinfo-canary -n production --ignore-not-found
echo "Broken HelmRelease removed."

echo "=== Demo teardown complete ==="
