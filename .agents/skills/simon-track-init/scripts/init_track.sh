#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <A|B|C|D|E|F|G|H|I|J|K|L|M|N> [UPSTREAM_URL]"
    exit 1
fi

TRACK_RAW="$(echo "$1" | tr '[:lower:]' '[:upper:]')"
TRACK="${TRACK_RAW#TRACK_}"
TRACK="${TRACK#TRACK}"
UPSTREAM_URL="${2:-https://github.com/Szpili/SIMON.git}"
FORK_URL="${3:-https://github.com/filipzarzynski/SIMON.git}"
BASE_BRANCH="fz-contrib"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HANDOVER_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
LOCAL_CACHE_REPO="/home/agent/SIMON"

case "$TRACK" in
    A)
        STAGE="1 (Completed)"
        BRANCH="fz/track-A-node-receipt-truth"
        TRACK_DIR_NAME="track_A_receipt_and_node_truth"
        TRACK_TAG="FZ-A"
        ALLOWED_FILES="crates/simon-cli/src/node.rs, crates/simon-cli/src/main.rs"
        ;;
    B)
        STAGE="1 (Completed)"
        BRANCH="fz/track-B-live-m1-receipts"
        TRACK_DIR_NAME="track_B_live_m1_token_binding"
        TRACK_TAG="FZ-B"
        ALLOWED_FILES="crates/simon-harness/src/request_response.rs, crates/simon-cli/src/wspolne.rs, crates/simon-cli/src/agent.rs, crates/simon-cli/src/node.rs"
        ;;
    C)
        STAGE="1 (Completed)"
        BRANCH="fz/track-C-industry-m7-agent"
        TRACK_DIR_NAME="track_C_industry_gemma4_live_agent"
        TRACK_TAG="FZ-C"
        ALLOWED_FILES="tools/simon-industry/**, ui/src/lib/industry-run.json, ui/src/routes/industry/+page.svelte"
        ;;
    D)
        STAGE="1 (Completed)"
        BRANCH="fz/track-D-core-security-hardening"
        TRACK_DIR_NAME="track_D_core_security_and_wasm_fixes"
        TRACK_TAG="FZ-D"
        ALLOWED_FILES="crates/simon-core/src/**, crates/simon-core/tests/**, crates/simon-verify-wasm/src/lib.rs"
        ;;
    E)
        STAGE="1 (Completed)"
        BRANCH="fz/track-E-coordinator-gossipsub-bridge"
        TRACK_DIR_NAME="track_E_p2p_coordinator_bridge"
        TRACK_TAG="FZ-E"
        ALLOWED_FILES="crates/simon-cli/src/coord.rs, crates/simon-cli/src/mapreduce.rs, crates/simon-node/src/lib.rs"
        ;;
    F)
        STAGE="1 (Completed)"
        BRANCH="fz/track-F-submission-and-ui-polish"
        TRACK_DIR_NAME="track_F_submission_and_ui_polish"
        TRACK_TAG="FZ-F"
        ALLOWED_FILES="README.md, docs/zgloszenie/LABLAB-SUBMISSION.md, ui/src/routes/demo/+page.svelte, ui/src/routes/network/+page.svelte, ui/src/lib/components/NodePanel.svelte, tools/simon-api/simon_api.py, tools/simon-verifier/verifier_loop.py, demo/app.py, demo/app.en.py"
        ;;
    G)
        STAGE="2 (Wave 2B)"
        BRANCH="fz/track-G-architecture-and-docs-overhaul"
        TRACK_DIR_NAME="track_G_architecture_and_docs_overhaul"
        TRACK_TAG="FZ-G"
        ALLOWED_FILES="docs/ARCHITECTURE.md, docs/STRESS-TESTS.md, docs/THREAT-MODEL.md, ROADMAP.md, docs/whitepaper/SIMON-whitepaper-EN.md"
        ;;
    H)
        STAGE="2 (Wave 2A)"
        BRANCH="fz/track-H-e2e-integration-and-live-m1-bridge"
        TRACK_DIR_NAME="track_H_e2e_integration_and_live_m1_bridge"
        TRACK_TAG="FZ-H"
        ALLOWED_FILES="crates/simon-cli/src/wspolne.rs, crates/simon-cli/src/node.rs, crates/simon-cli/tests/e2e_m1_receipt.rs"
        ;;
    I)
        STAGE="2 (Wave 2B)"
        BRANCH="fz/track-I-captain-cherry-pick-menu-and-ci"
        TRACK_DIR_NAME="track_I_captain_cherry_pick_menu_and_ci"
        TRACK_TAG="FZ-I"
        ALLOWED_FILES="docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md, scripts/verify_all_fast.sh"
        ;;
    J)
        STAGE="2 (Wave 2A)"
        BRANCH="fz/track-J-signed-job-result-and-registration"
        TRACK_DIR_NAME="track_J_signed_job_result_and_registration"
        TRACK_TAG="FZ-J"
        ALLOWED_FILES="crates/simon-node/src/lib.rs, crates/simon-cli/src/coord.rs"
        ;;
    K)
        STAGE="3 (Wave 3A)"
        BRANCH="fz/track-K-vpn-attack-harness-and-agent-m1-gate"
        TRACK_DIR_NAME="track_K_vpn_attack_harness_and_agent_m1_gate"
        TRACK_TAG="FZ-K"
        ALLOWED_FILES="crates/simon-cli/src/agent.rs, crates/simon-cli/tests/vpn_attack_harness.rs"
        ;;
    L)
        STAGE="3 (Wave 3A)"
        BRANCH="fz/track-L-gateway-and-monitor-hardening"
        TRACK_DIR_NAME="track_L_gateway_and_monitor_hardening"
        TRACK_TAG="FZ-L"
        ALLOWED_FILES="tools/simon-api/simon_api.py, tools/simon-api/test_gateway.py, tools/simon-monitor/simon_monitor.py"
        ;;
    M)
        STAGE="3 (Wave 3B)"
        BRANCH="fz/track-M-industry-adversarial-corpus"
        TRACK_DIR_NAME="track_M_industry_adversarial_corpus"
        TRACK_TAG="FZ-M"
        ALLOWED_FILES="tools/simon-industry/tickets.py, tools/simon-industry/agent_triage.py, tools/simon-industry/stress_corpus.json"
        ;;
    N)
        STAGE="3 (Wave 3B)"
        BRANCH="fz/track-N-ui-receipts-and-demo-polish"
        TRACK_DIR_NAME="track_N_ui_receipts_and_demo_polish"
        TRACK_TAG="FZ-N"
        ALLOWED_FILES="ui/src/routes/receipts/+page.svelte, ui/src/routes/demo/+page.svelte"
        ;;
    *)
        echo "ERROR: Invalid track '$1'. Must be one of: A..F (Stage 1), G..J (Stage 2), or K..N (Stage 3)"
        exit 1
        ;;
esac

WORKSPACES_DIR="$HANDOVER_ROOT/workspaces"
HUB_REPO="$WORKSPACES_DIR/_upstream_hub.git"
LOCK_FILE="$WORKSPACES_DIR/.hub.lock"
CLONE_DIR="$WORKSPACES_DIR/track_${TRACK}"
SPEC_DIR="$HANDOVER_ROOT/parallel_agents/${TRACK_DIR_NAME}"

mkdir -p "$WORKSPACES_DIR"

# Concurrency-safe initialization of the shared local integration hub & fz-contrib base branch
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
        git -C "$HUB_REPO" remote set-url upstream "$UPSTREAM_URL" 2>/dev/null || git -C "$HUB_REPO" remote add upstream "$UPSTREAM_URL" 2>/dev/null || true
        git -C "$HUB_REPO" remote set-url origin "$FORK_URL" 2>/dev/null || git -C "$HUB_REPO" remote add origin "$FORK_URL" 2>/dev/null || true
        git -C "$HUB_REPO" fetch upstream "+refs/heads/main:refs/heads/upstream_main" 2>/dev/null || true
    fi

    # Ensure fz-contrib branch exists in the hub (initialized from main if not yet created)
    if ! git -C "$HUB_REPO" show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
        MAIN_SHA="$(git -C "$HUB_REPO" rev-parse refs/heads/main)"
        git -C "$HUB_REPO" update-ref "refs/heads/$BASE_BRANCH" "$MAIN_SHA"
        echo "[Track $TRACK] Created integration base branch '$BASE_BRANCH' at main ($MAIN_SHA)"
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
    echo "[Track $TRACK] Existing clone found at $CLONE_DIR; fetching latest..."
    git -C "$CLONE_DIR" fetch origin 2>/dev/null || true
fi

# Configure git identity and remotes inside the clone
git -C "$CLONE_DIR" config user.name "FZ (Track $TRACK)"
git -C "$CLONE_DIR" config user.email "fz-track-${TRACK,,}@simon-argon.local"

# origin points to user's fork (filipzarzynski/SIMON) for pushes and PRs
if git -C "$CLONE_DIR" remote get-url origin >/dev/null 2>&1; then
    git -C "$CLONE_DIR" remote set-url origin "$FORK_URL"
else
    git -C "$CLONE_DIR" remote add origin "$FORK_URL"
fi

# upstream points to original canonical repository (Szpili/SIMON) for tracking main
if git -C "$CLONE_DIR" remote get-url upstream >/dev/null 2>&1; then
    git -C "$CLONE_DIR" remote set-url upstream "$UPSTREAM_URL"
else
    git -C "$CLONE_DIR" remote add upstream "$UPSTREAM_URL"
fi

# hub points to shared local bare repository for instant inter-agent coordination
if git -C "$CLONE_DIR" remote get-url hub >/dev/null 2>&1; then
    git -C "$CLONE_DIR" remote set-url hub "$HUB_REPO"
else
    git -C "$CLONE_DIR" remote add hub "$HUB_REPO"
fi

git -C "$CLONE_DIR" fetch hub
git -C "$CLONE_DIR" fetch upstream main 2>/dev/null || true

# Ensure local fz-contrib tracking ref exists
git -C "$CLONE_DIR" branch -f "$BASE_BRANCH" "hub/$BASE_BRANCH"

# Checkout or create the dedicated track branch off fz-contrib
if git -C "$CLONE_DIR" show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git -C "$CLONE_DIR" checkout "$BRANCH"
else
    git -C "$CLONE_DIR" checkout -b "$BRANCH" "hub/$BASE_BRANCH"
fi

# Create convenience symlink inside parallel_agents/track_<X>_*/repo
mkdir -p "$SPEC_DIR"
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
# Track $TRACK ([$TRACK_TAG] — Stage $STAGE) Local Clone Rules

- **Assigned Track**: Track $TRACK ([$TRACK_TAG], Stage $STAGE)
- **Target PR Base Branch**: \`$BASE_BRANCH\` (**NEVER** PR directly to \`main\`!)
- **Dedicated Track Branch**: \`$BRANCH\`
- **Clone Directory**: \`$CLONE_DIR\`
- **Task Specification**: [\`$SPEC_DIR/TASK_SPEC.md\`](file://$SPEC_DIR/TASK_SPEC.md)
- **Captain Guardrails Skill**: [\`$HANDOVER_ROOT/.agents/skills/simon-captain-review-guardrails/SKILL.md\`](file://$HANDOVER_ROOT/.agents/skills/simon-captain-review-guardrails/SKILL.md)
- **Common Rules**: [\`$HANDOVER_ROOT/parallel_agents/AGENT_RULES_COMMON.md\`](file://$HANDOVER_ROOT/parallel_agents/AGENT_RULES_COMMON.md)
- **Exclusive Permitted Files**: \`$ALLOWED_FILES\`

## Strict Constraints (Enforced by verify_track.sh)
1. **NEVER** edit or stage any file outside: \`$ALLOWED_FILES\`.
2. **Read \`simon-captain-review-guardrails\` BEFORE writing code**:
   - Never guess signed claims (\`Precision::Unknown\`, \`poziom_sprawdzony\`, \`order.nonce\`, \`--expect-signer\`).
   - Never overclaim in docs/UI (follow \`docs/THREAT-MODEL.md\` and \`docs/STRESS-TESTS.md\`).
   - Never leak \`SIMPN_ARGON_HANDOWER\` or \`/home/agent/\` into any tracked file.
3. **Cherry-Pickable Granular Commits**: Prefix every commit message with \`[FZ-${TRACK}1]\`, \`[FZ-${TRACK}2]\`, etc. (e.g. \`[FZ-${TRACK}1] fix(...): ...\`). Each commit MUST compile and pass tests independently so the Team Captain can cherry-pick individual commits onto \`main\`.
4. Prepend \`export PATH="/home/agent/.cargo/bin:\$PATH"\` when running \`cargo\`, \`rustc\`, or \`wasm-pack\`.
5. Run \`bash $HANDOVER_ROOT/.agents/skills/simon-verify-suite/scripts/verify_track.sh $TRACK --final\` before finishing.
6. Run \`python3 $HANDOVER_ROOT/.agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track $TRACK\` to rebase onto \`$BASE_BRANCH\`, integrate into \`$BASE_BRANCH\`, and create the PR targeting \`$BASE_BRANCH\`.
EOF

echo "========================================================================"
echo " Track $TRACK ([$TRACK_TAG] — Stage $STAGE) Workspace Initialized Successfully!"
echo "------------------------------------------------------------------------"
echo " Clone Directory : $CLONE_DIR"
echo " Symlink         : $SPEC_DIR/repo"
echo " Base Branch     : $BASE_BRANCH ($(git -C "$CLONE_DIR" rev-parse --short "hub/$BASE_BRANCH"))"
echo " Active Branch   : $(git -C "$CLONE_DIR" branch --show-current)"
echo " Task Spec       : $SPEC_DIR/TASK_SPEC.md"
echo " Permitted Files : $ALLOWED_FILES"
echo " Git Status      : $(git -C "$CLONE_DIR" status --short | wc -l) modified/untracked files"
echo "========================================================================"
