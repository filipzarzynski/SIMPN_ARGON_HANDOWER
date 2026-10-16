#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HANDOVER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HUB_REPO="$HANDOVER_ROOT/workspaces/_upstream_hub.git"
FORK_URL="https://github.com/filipzarzynski/SIMON.git"
UPSTREAM_URL="https://github.com/Szpili/SIMON.git"

echo "=== 1. Fetching latest upstream main & fz-contrib from $UPSTREAM_URL ==="
git -C "$HUB_REPO" fetch upstream "+refs/heads/main:refs/remotes/upstream/main" "+refs/heads/fz-contrib:refs/remotes/upstream/fz-contrib"

UPSTREAM_MAIN="$(git -C "$HUB_REPO" rev-parse refs/remotes/upstream/main)"
UPSTREAM_FZC="$(git -C "$HUB_REPO" rev-parse refs/remotes/upstream/fz-contrib)"
echo "Upstream main HEAD       : $UPSTREAM_MAIN"
echo "Upstream fz-contrib HEAD : $UPSTREAM_FZC"

echo "=== 2. Current branches on hub ready for remote ==="
git -C "$HUB_REPO" log -n 1 --oneline fz-contrib

ALL_TRACK_BRANCHES=(
    "fz/track-H-e2e-integration-and-live-m1-bridge"
    "fz/track-J-signed-job-result-and-registration"
    "fz/track-G-architecture-and-docs-overhaul"
    "fz/track-I-captain-cherry-pick-menu-and-ci"
    "fz/track-K-vpn-attack-harness-and-agent-m1-gate"
    "fz/track-L-gateway-and-monitor-hardening"
    "fz/track-M-industry-adversarial-corpus"
    "fz/track-N-ui-receipts-and-demo-polish"
)

ACTIVE_BRANCHES=()
for br in "${ALL_TRACK_BRANCHES[@]}"; do
    if git -C "$HUB_REPO" show-ref --verify --quiet "refs/heads/$br"; then
        git -C "$HUB_REPO" log -n 1 --oneline "$br"
        ACTIVE_BRANCHES+=("$br")
    fi
done

echo "=== 3. Pushing fz-contrib and completed Stage 2/3 track branches to $FORK_URL ==="
TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"

if [ -n "$TOKEN" ]; then
    AUTH_FORK_URL="https://x-access-token:${TOKEN}@github.com/filipzarzynski/SIMON.git"
    git -C "$HUB_REPO" push "$AUTH_FORK_URL" fz-contrib:refs/heads/fz-contrib
    for br in "${ACTIVE_BRANCHES[@]}"; do
        git -C "$HUB_REPO" push -f "$AUTH_FORK_URL" "$br:refs/heads/$br"
    done
    echo "SUCCESS: All branches pushed to $FORK_URL"
elif git -C "$HUB_REPO" push origin fz-contrib:refs/heads/fz-contrib 2>/dev/null; then
    for br in "${ACTIVE_BRANCHES[@]}"; do
        git -C "$HUB_REPO" push -f origin "$br:refs/heads/$br"
    done
    echo "SUCCESS: All branches pushed to origin ($FORK_URL)"
else
    echo "Notice: Could not push automatically to $FORK_URL."
    echo "To push with credentials, run:"
    echo "  GITHUB_TOKEN=<your_github_pat> bash scripts/sync_and_push_remote.sh"
fi
