#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <A|B|C|D|E|F> [--final]"
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

echo "========================================================================"
echo " [Pass 1/3] Auditing File Scope & Working Tree for Track $TRACK"
echo "========================================================================"

if [ "$FINAL_MODE" = "--final" ]; then
    DIRTY="$(git status --porcelain)"
    if [ -n "$DIRTY" ]; then
        echo "ERROR: Working tree in $CLONE_DIR is not clean:"
        echo "$DIRTY"
        exit 1
    fi
fi

CHANGED_FILES="$( (git diff --name-only origin/main...HEAD; git diff --name-only; git diff --name-only --cached) | sort -u | sed '/^$/d' )"

if [ -z "$CHANGED_FILES" ]; then
    echo "WARNING: No changed files detected relative to origin/main yet."
else
    echo "Changed files:"
    echo "$CHANGED_FILES" | sed 's/^/  - /'
fi

is_allowed_file() {
    local f="$1"
    case "$TRACK" in
        A)
            [[ "$f" == "crates/simon-cli/src/node.rs" ]]
            ;;
        B)
            [[ "$f" == "crates/simon-cli/src/agent.rs" || "$f" == "crates/simon-cli/src/wspolne.rs" ]]
            ;;
        C)
            [[ "$f" == tools/simon-industry/* || "$f" == "ui/src/lib/industry-run.json" || "$f" == "ui/src/routes/industry/+page.svelte" ]]
            ;;
        D)
            [[ "$f" == crates/simon-core/src/* || "$f" == "crates/simon-verify-wasm/src/lib.rs" ]]
            ;;
        E)
            [[ "$f" == "crates/simon-cli/src/coord.rs" || "$f" == "crates/simon-cli/src/mapreduce.rs" || "$f" == "crates/simon-node/src/lib.rs" ]]
            ;;
        F)
            [[ "$f" == "README.md" || "$f" == "docs/zgloszenie/LABLAB-SUBMISSION.md" || "$f" == "ui/src/routes/demo/+page.svelte" || "$f" == "ui/src/routes/network/+page.svelte" || "$f" == "tools/simon-api/simon_api.py" || "$f" == "tools/simon-verifier/verifier_loop.py" || "$f" == "demo/app.py" || "$f" == "demo/app.en.py" ]]
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
echo " [Pass 2/3] Auditing Commit History for Track $TRACK"
echo "========================================================================"
COMMIT_COUNT="$(git rev-list --count origin/main..HEAD)"
echo "Commits ahead of origin/main: $COMMIT_COUNT"
git log --oneline origin/main..HEAD | sed 's/^/  /'

if [ "$FINAL_MODE" = "--final" ] && [ "$COMMIT_COUNT" -lt 1 ]; then
    echo "ERROR: No commits found on branch ahead of origin/main in --final mode."
    exit 1
fi

echo "========================================================================"
echo " [Pass 3/3] Running Verification & Test Suites for Track $TRACK"
echo "========================================================================"

case "$TRACK" in
    A|B)
        python3 scripts/wartownik_stalych.py
        cargo test -p simon-core -p simon-cli
        cargo clippy -p simon-cli -- -D warnings
        ;;
    C)
        python3 tools/simon-industry/rules.py --self-test
        python3 -m py_compile tools/simon-industry/rules.py tools/simon-industry/tickets.py tools/simon-industry/export_ui.py
        python3 -c 'import json; d=json.load(open("ui/src/lib/industry-run.json")); assert len(d["tickets"]) > 0; print("industry-run.json tickets:", len(d["tickets"]))'
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
esac

echo "========================================================================"
echo " ALL VERIFICATION PASSES SUCCEEDED FOR TRACK $TRACK!"
echo "========================================================================"
