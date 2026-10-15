#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HANDOVER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HUB_REPO="$HANDOVER_ROOT/workspaces/_upstream_hub.git"
FORK_URL="https://github.com/filipzarzynski/SIMON.git"
UPSTREAM_URL="https://github.com/Szpili/SIMON.git"

echo "=== 1. Fetching latest upstream main from $UPSTREAM_URL ==="
git -C "$HUB_REPO" fetch upstream main

UPSTREAM_HEAD="$(git -C "$HUB_REPO" rev-parse refs/remotes/upstream/main)"
echo "Upstream main HEAD is: $UPSTREAM_HEAD"

echo "=== 2. Current branches on hub ready for remote ==="
git -C "$HUB_REPO" log -n 1 --oneline fz-contrib
git -C "$HUB_REPO" log -n 1 --oneline fz/track-D-core-security-hardening
git -C "$HUB_REPO" log -n 1 --oneline fz/track-A-node-receipt-truth
git -C "$HUB_REPO" log -n 1 --oneline fz/track-F-submission-and-ui-polish
git -C "$HUB_REPO" log -n 1 --oneline fz/track-C-industry-m7-agent
git -C "$HUB_REPO" log -n 1 --oneline fz/track-E-coordinator-gossipsub-bridge
git -C "$HUB_REPO" log -n 1 --oneline fz/track-B-live-m1-receipts

echo "=== 3. Pushing fz-contrib and all completed track branches to $FORK_URL ==="
TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"

if [ -n "$TOKEN" ]; then
    AUTH_FORK_URL="https://x-access-token:${TOKEN}@github.com/filipzarzynski/SIMON.git"
    git -C "$HUB_REPO" push -f "$AUTH_FORK_URL" fz-contrib:refs/heads/fz-contrib
    git -C "$HUB_REPO" push -f "$AUTH_FORK_URL" fz/track-D-core-security-hardening:refs/heads/fz/track-D-core-security-hardening
    git -C "$HUB_REPO" push -f "$AUTH_FORK_URL" fz/track-A-node-receipt-truth:refs/heads/fz/track-A-node-receipt-truth
    git -C "$HUB_REPO" push -f "$AUTH_FORK_URL" fz/track-F-submission-and-ui-polish:refs/heads/fz/track-F-submission-and-ui-polish
    git -C "$HUB_REPO" push -f "$AUTH_FORK_URL" fz/track-C-industry-m7-agent:refs/heads/fz/track-C-industry-m7-agent
    git -C "$HUB_REPO" push -f "$AUTH_FORK_URL" fz/track-E-coordinator-gossipsub-bridge:refs/heads/fz/track-E-coordinator-gossipsub-bridge
    git -C "$HUB_REPO" push -f "$AUTH_FORK_URL" fz/track-B-live-m1-receipts:refs/heads/fz/track-B-live-m1-receipts
    echo "SUCCESS: All branches pushed to $FORK_URL"
else
    echo "Notice: No GITHUB_TOKEN or GH_TOKEN found in environment."
    echo "To push with credentials, run:"
    echo "  GITHUB_TOKEN=<your_github_pat> bash scripts/sync_and_push_remote.sh"
    echo "Or if your terminal has git credentials configured, run:"
    echo "  git -C \"$HUB_REPO\" push fork fz-contrib:refs/heads/fz-contrib"
    echo "  git -C \"$HUB_REPO\" push fork fz/track-D-core-security-hardening"
    echo "  git -C \"$HUB_REPO\" push fork fz/track-A-node-receipt-truth"
    echo "  git -C \"$HUB_REPO\" push fork fz/track-F-submission-and-ui-polish"
    echo "  git -C \"$HUB_REPO\" push fork fz/track-C-industry-m7-agent"
    echo "  git -C \"$HUB_REPO\" push fork fz/track-E-coordinator-gossipsub-bridge"
    echo "  git -C \"$HUB_REPO\" push fork fz/track-B-live-m1-receipts"
fi
