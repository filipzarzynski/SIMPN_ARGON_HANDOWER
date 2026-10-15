#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <A|B|C|D|E|F|G|H|I> [--final]"
    exit 1
fi

TRACK_RAW="$(echo "$1" | tr '[:lower:]' '[:upper:]')"
TRACK="${TRACK_RAW#TRACK_}"
TRACK="${TRACK#TRACK}"
FINAL_MODE="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HANDOVER_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CLONE_DIR="$HANDOVER_ROOT/workspaces/track_${TRACK}"

export PATH="/home/agent/.cargo/bin:/usr/local/bin:$PATH"

if [ ! -d "$CLONE_DIR/.git" ]; then
    echo "ERROR: Clone directory $CLONE_DIR does not exist. Run init_track.sh $TRACK first."
    exit 1
fi

cd "$CLONE_DIR"
git fetch hub 2>/dev/null || true

# Stage 1 tracks compare against hub/main; Stage 2 tracks compare against hub/fz-contrib
case "$TRACK" in
    A|B|C|D|E|F)
        DIFF_BASE="hub/main"
        ;;
    G|H|I)
        DIFF_BASE="hub/fz-contrib"
        ;;
    *)
        echo "ERROR: Invalid track '$TRACK'."
        exit 1
        ;;
esac

echo "========================================================================"
echo " [Pass 1/3] Auditing File Scope & Working Tree for Track $TRACK (vs $DIFF_BASE)"
echo "========================================================================"

if [ "$FINAL_MODE" = "--final" ]; then
    DIRTY="$(git status --porcelain)"
    if [ -n "$DIRTY" ]; then
        echo "ERROR: Working tree in $CLONE_DIR is not clean:"
        echo "$DIRTY"
        exit 1
    fi
fi

CHANGED_FILES="$( (git diff --name-only "$DIFF_BASE"...HEAD; git diff --name-only; git diff --name-only --cached) | sort -u | sed '/^$/d' )"

if [ -z "$CHANGED_FILES" ]; then
    echo "WARNING: No changed files detected relative to $DIFF_BASE yet."
else
    echo "Changed files:"
    echo "$CHANGED_FILES" | sed 's/^/  - /'
fi

is_allowed_file() {
    local f="$1"
    case "$TRACK" in
        A)
            [[ "$f" == "crates/simon-cli/src/node.rs" || "$f" == "crates/simon-cli/src/main.rs" || "$f" == "crates/simon-cli/src/agent.rs" ]]
            ;;
        B)
            [[ "$f" == "crates/simon-harness/src/request_response.rs" || "$f" == "crates/simon-cli/src/wspolne.rs" || "$f" == "crates/simon-cli/src/agent.rs" || "$f" == "crates/simon-cli/src/node.rs" ]]
            ;;
        C)
            [[ "$f" == tools/simon-industry/* || "$f" == "ui/src/lib/industry-run.json" || "$f" == "ui/src/routes/industry/+page.svelte" ]]
            ;;
        D)
            [[ "$f" == crates/simon-core/src/* || "$f" == crates/simon-core/tests/* || "$f" == "crates/simon-verify-wasm/src/lib.rs" ]]
            ;;
        E)
            [[ "$f" == "crates/simon-cli/src/coord.rs" || "$f" == "crates/simon-cli/src/mapreduce.rs" || "$f" == "crates/simon-node/src/lib.rs" ]]
            ;;
        F)
            [[ "$f" == "README.md" || "$f" == "docs/zgloszenie/LABLAB-SUBMISSION.md" || "$f" == "ui/src/routes/demo/+page.svelte" || "$f" == "ui/src/routes/network/+page.svelte" || "$f" == "ui/src/lib/components/NodePanel.svelte" || "$f" == "tools/simon-api/simon_api.py" || "$f" == "tools/simon-verifier/verifier_loop.py" || "$f" == "demo/app.py" || "$f" == "demo/app.en.py" ]]
            ;;
        G)
            [[ "$f" == "docs/ARCHITECTURE.md" || "$f" == "docs/THREAT-MODEL.md" || "$f" == "ROADMAP.md" || "$f" == "docs/whitepaper/SIMON-whitepaper-EN.md" ]]
            ;;
        H)
            [[ "$f" == "crates/simon-cli/src/node.rs" || "$f" == "crates/simon-cli/tests/e2e_m1_receipt.rs" ]]
            ;;
        I)
            [[ "$f" == "docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md" || "$f" == "scripts/verify_all_fast.sh" ]]
            ;;
        *)
            return 1
            ;;
    esac
}

SCOPE_VIOLATION=0
while IFS= read -r file; do
    [ -z "$file" ] && continue
    if ! is_allowed_file "$file"; then
        echo "ERROR: File '$file' is OUTSIDE Track $TRACK's exclusive scope!"
        SCOPE_VIOLATION=1
    fi
done <<< "$CHANGED_FILES"

if [ "$SCOPE_VIOLATION" -ne 0 ]; then
    echo "FAILED Pass 1: Revert out-of-scope file modifications immediately."
    exit 1
fi
echo "PASS 1 OK: All modified files are strictly within Track $TRACK's permitted scope."

echo "========================================================================"
echo " [Pass 2/3] Auditing Granular Cherry-Pickable Commits for Track $TRACK"
echo "========================================================================"
COMMIT_COUNT="$(git rev-list --count "$DIFF_BASE"..HEAD)"
echo "Commits ahead of $DIFF_BASE: $COMMIT_COUNT"
git log --oneline "$DIFF_BASE"..HEAD | sed 's/^/  /'

if [ "$FINAL_MODE" = "--final" ] && [ "$COMMIT_COUNT" -lt 1 ]; then
    echo "ERROR: No commits found on branch ahead of $DIFF_BASE in --final mode."
    exit 1
fi

echo "========================================================================"
echo " [Pass 3/3] Running Verification & Test Suites for Track $TRACK"
echo "========================================================================"

case "$TRACK" in
    A)
        python3 scripts/wartownik_stalych.py
        cargo test -p simon-core -p simon-cli
        cargo clippy -p simon-cli --no-deps -- -D warnings
        ;;
    B|H)
        python3 scripts/wartownik_stalych.py
        cargo test -p simon-core -p simon-harness -p simon-cli
        cargo clippy -p simon-harness -p simon-cli -- -D warnings
        ;;
    C)
        python3 tools/simon-industry/rules.py
        python3 -m py_compile tools/simon-industry/rules.py tools/simon-industry/tickets.py tools/simon-industry/export_ui.py
        if [ -f "tools/simon-industry/agent_triage.py" ]; then
            python3 -m py_compile tools/simon-industry/agent_triage.py
            python3 tools/simon-industry/agent_triage.py --selfcheck
        fi
        python3 -c 'import json; d=json.load(open("ui/src/lib/industry-run.json")); assert len(d["records"]) > 0 and d["summary"]["tickets"] > 0; print("industry-run.json records:", len(d["records"]), "tickets:", d["summary"]["tickets"])'
        if [ -d "ui" ]; then
            (cd ui && ([ -d node_modules ] || npm install --no-audit --no-fund) && npm run check && npm run build)
        fi
        ;;
    D)
        python3 scripts/wartownik_stalych.py
        cargo test -p simon-core -p simon-verify-wasm
        cargo clippy -p simon-core -p simon-verify-wasm -- -D warnings
        ;;
    E)
        python3 scripts/wartownik_stalych.py
        cargo test -p simon-node -p simon-cli
        cargo clippy -p simon-node -p simon-cli -- -D warnings
        ;;
    F)
        python3 -m py_compile tools/simon-api/simon_api.py tools/simon-verifier/verifier_loop.py demo/app.py demo/app.en.py
        if [ -d "ui" ]; then
            (cd ui && ([ -d node_modules ] || npm install --no-audit --no-fund) && npm run check && npm run build)
        fi
        ;;
    G|I)
        python3 scripts/wartownik_stalych.py
        if [ -f "scripts/verify_all_fast.sh" ]; then
            bash scripts/verify_all_fast.sh
        fi
        ;;
esac

echo "========================================================================"
echo " ALL VERIFICATION PASSES SUCCEEDED FOR TRACK $TRACK!"
echo "========================================================================"
