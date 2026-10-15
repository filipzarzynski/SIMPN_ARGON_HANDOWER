#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <A|B|C|D|E|F> [UPSTREAM_URL]"
    exit 1
fi

TRACK_RAW="$(echo "$1" | tr '[:lower:]' '[:upper:]')"
TRACK="${TRACK_RAW#TRACK_}"
TRACK="${TRACK#TRACK}"
UPSTREAM_URL="${2:-https://github.com/Szpili/SIMON.git}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HANDOVER_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
LOCAL_CACHE_REPO="/home/agent/SIMON"

case "$TRACK" in
    A)
        BRANCH="fix/node-receipt-truth"
        TRACK_DIR_NAME="track_A_receipt_and_node_truth"
        PR_ID="PR-1"
        ALLOWED_FILES="crates/simon-cli/src/node.rs"
        ;;
    B)
        BRANCH="feat/live-m1-receipts"
        TRACK_DIR_NAME="track_B_live_m1_token_binding"
        PR_ID="PR-2"
        ALLOWED_FILES="crates/simon-cli/src/agent.rs, crates/simon-cli/src/wspolne.rs"
        ;;
    C)
        BRANCH="feat/industry-m7-agent"
        TRACK_DIR_NAME="track_C_industry_gemma4_live_agent"
        PR_ID="PR-3"
        ALLOWED_FILES="tools/simon-industry/**, ui/src/lib/industry-run.json, ui/src/routes/industry/+page.svelte"
        ;;
    D)
        BRANCH="fix/core-security-hardening"
        TRACK_DIR_NAME="track_D_core_security_and_wasm_fixes"
        PR_ID="PR-4"
        ALLOWED_FILES="crates/simon-core/src/**, crates/simon-verify-wasm/src/lib.rs"
        ;;
    E)
        BRANCH="feat/coordinator-gossipsub-bridge"
        TRACK_DIR_NAME="track_E_p2p_coordinator_bridge"
        PR_ID="PR-5"
        ALLOWED_FILES="crates/simon-cli/src/coord.rs, crates/simon-cli/src/mapreduce.rs, crates/simon-node/src/lib.rs"
        ;;
    F)
        BRANCH="fix/submission-and-ui-polish"
        TRACK_DIR_NAME="track_F_submission_and_ui_polish"
        PR_ID="PR-6"
        ALLOWED_FILES="README.md, docs/zgloszenie/LABLAB-SUBMISSION.md, ui/src/routes/demo/+page.svelte, ui/src/routes/network/+page.svelte, tools/simon-api/simon_api.py, tools/simon-verifier/verifier_loop.py, demo/app.py, demo/app.en.py"
        ;;
    *)
        echo "ERROR: Invalid track '$1'. Must be one of: A, B, C, D, E, F"
        exit 1
        ;;
esac

WORKSPACES_DIR="$HANDOVER_ROOT/workspaces"
HUB_REPO="$WORKSPACES_DIR/_upstream_hub.git"
LOCK_FILE="$WORKSPACES_DIR/.hub.lock"
CLONE_DIR="$WORKSPACES_DIR/track_${TRACK}"
SPEC_DIR="$HANDOVER_ROOT/parallel_agents/${TRACK_DIR_NAME}"

mkdir -p "$WORKSPACES_DIR"

# Concurrency-safe initialization of the shared local integration hub
(
    flock -x 200
    if [ ! -d "$HUB_REPO" ]; then
        echo "[Track $TRACK] Initializing shared local integration hub at $HUB_REPO ..."
        if [ -d "$LOCAL_CACHE_REPO/.git" ]; then
            git clone --bare --reference-if-able "$LOCAL_CACHE_REPO" "$UPSTREAM_URL" "$HUB_REPO"
        else
            git clone --bare "$UPSTREAM_URL" "$HUB_REPO"
        fi
    else
        git -C "$HUB_REPO" fetch origin "+refs/heads/main:refs/heads/main" 2>/dev/null || true
    fi
) 200>"$LOCK_FILE"

# Clone or reuse the dedicated subfolder for this track
if [ ! -d "$CLONE_DIR/.git" ]; then
    echo "[Track $TRACK] Cloning upstream ($UPSTREAM_URL) into $CLONE_DIR ..."
    rm -rf "$CLONE_DIR"
    if [ -d "$LOCAL_CACHE_REPO/.git" ]; then
        git clone --reference-if-able "$LOCAL_CACHE_REPO" "$UPSTREAM_URL" "$CLONE_DIR"
    else
        git clone "$UPSTREAM_URL" "$CLONE_DIR"
    fi
else
    echo "[Track $TRACK] Existing clone found at $CLONE_DIR; fetching latest origin..."
    git -C "$CLONE_DIR" fetch origin
fi

# Configure git identity and remotes inside the clone
git -C "$CLONE_DIR" config user.name "SIMON Track $TRACK Agent"
git -C "$CLONE_DIR" config user.email "track-${TRACK,,}@simon-argon.local"

if git -C "$CLONE_DIR" remote get-url hub >/dev/null 2>&1; then
    git -C "$CLONE_DIR" remote set-url hub "$HUB_REPO"
else
    git -C "$CLONE_DIR" remote add hub "$HUB_REPO"
fi

# Checkout or create the dedicated branch
if git -C "$CLONE_DIR" show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git -C "$CLONE_DIR" checkout "$BRANCH"
else
    git -C "$CLONE_DIR" checkout -b "$BRANCH" origin/main
fi

# Create convenience symlink inside parallel_agents/track_<X>_*/repo
ln -sfn "$CLONE_DIR" "$SPEC_DIR/repo"

# Configure .git/info/exclude so local AGENTS.md and .agents symlink never appear as untracked in git status
EXCLUDE_FILE="$CLONE_DIR/.git/info/exclude"
for pattern in "/AGENTS.md" "/.agents"; do
    if ! grep -qxF "$pattern" "$EXCLUDE_FILE" 2>/dev/null; then
        echo "$pattern" >> "$EXCLUDE_FILE"
    fi
done

# Link workspace skills into the clone root and generate track-scoped AGENTS.md
ln -sfn "$HANDOVER_ROOT/.agents" "$CLONE_DIR/.agents"
cat > "$CLONE_DIR/AGENTS.md" <<EOF
# Track $TRACK ($PR_ID) Local Clone Rules

- **Assigned Track**: Track $TRACK ($PR_ID)
- **Dedicated Branch**: \`$BRANCH\`
- **Clone Directory**: \`$CLONE_DIR\`
- **Task Specification**: [\`$SPEC_DIR/TASK_SPEC.md\`](file://$SPEC_DIR/TASK_SPEC.md)
- **Common Rules**: [\`$HANDOVER_ROOT/parallel_agents/AGENT_RULES_COMMON.md\`](file://$HANDOVER_ROOT/parallel_agents/AGENT_RULES_COMMON.md)
- **Exclusive Permitted Files**: \`$ALLOWED_FILES\`

## Strict Constraints
1. **NEVER** edit or stage any file outside: \`$ALLOWED_FILES\`.
2. Prepend \`export PATH="/home/agent/.cargo/bin:\$PATH"\` when running \`cargo\`, \`rustc\`, or \`wasm-pack\`.
3. Commit logically and granularly after each sub-task in \`TASK_SPEC.md\` only after tests pass.
4. Run \`bash $HANDOVER_ROOT/.agents/skills/simon-verify-suite/scripts/verify_track.sh $TRACK\` before finishing.
5. Run \`python3 $HANDOVER_ROOT/.agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track $TRACK\` to verify mergeability and create the PR.
EOF

echo "========================================================================"
echo " Track $TRACK ($PR_ID) Workspace Initialized Successfully!"
echo "------------------------------------------------------------------------"
echo " Clone Directory : $CLONE_DIR"
echo " Symlink         : $SPEC_DIR/repo"
echo " Active Branch   : $(git -C "$CLONE_DIR" branch --show-current)"
echo " Base Commit     : $(git -C "$CLONE_DIR" rev-parse --short HEAD)"
echo " Task Spec       : $SPEC_DIR/TASK_SPEC.md"
echo " Permitted Files : $ALLOWED_FILES"
echo " Git Status      : $(git -C "$CLONE_DIR" status --short | wc -l) modified/untracked files"
echo "========================================================================"
