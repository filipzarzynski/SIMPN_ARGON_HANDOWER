---
name: simon-industry-and-ui
description: >-
  Use this skill when working on Track G, I, L, M, or N (tools/simon-industry,
  tools/simon-api, tools/simon-monitor, SvelteKit UI in ui/, or architecture/submission docs).
  Includes the Team Captain's rule-binding ceiling, Unicode NFKC normalization,
  signer-pinning, and 390px mobile UI/accessibility requirements.
---

# SIMON Intelligent Industry, Gateway & SvelteKit UI Skill (`simon-industry-and-ui`)

Activate this skill when working on **Track G, Track I, Track L, Track M, or Track N**. Always read [`.agents/skills/simon-captain-review-guardrails/SKILL.md`](../simon-captain-review-guardrails/SKILL.md) first.

## 1. Track 1: Intelligent Industry Pipeline (`tools/simon-industry/`)

- **Stage 1 (`rules.py`)**: Deterministic rule filter on `data/ai4i2020.csv` (10,000 rows, 8 ms runtime, 0 LLM tokens). Identifies 329 failures and 20 borderline anomalies.
  - Self-check: `python3 tools/simon-industry/rules.py`
- **Stage 2 (`tickets.py`, `agent_triage.py`, `stress_corpus.json`)**:
  - **Strict Rule-Binding (`execute_propose_work_order(args, findings)`)**:
    - Proposals must match `rules.findings(row)` for that specific machine: exact `failure_modes` (no duplicates, no extra modes), `urgency` equal to the most urgent finding (`findings[0]["urgency"]`), and `(action_code, part_id)` equal to the catalog entry for `findings[0]["mode"]`. If `findings` is empty, no work order is permitted.
  - **Free-Text Normalization & Filtering**:
    - Normalize with `unicodedata.normalize("NFKC")`, strip Unicode `Cf` format characters (zero-width spaces `\u200b`, soft hyphens `\u00ad`, bidi overrides `\u202e`), replace hyphens with spaces, collapse whitespace, and check max length *after* normalization.
    - Block shutdown/energize commands (`shut down`, `shutdown`, `power off`, `cut power`, `de-energize`, `deenergise`) while permitting legitimate technician steps (`"Disconnect the faulty sensor cable and inspect it."`).
  - **CSV Input Sanitization**:
    - Strip non-alphanumeric characters from CSV `Product ID` (`re.sub(r'[^A-Za-z0-9-]', '', ...)[:16]`) and `Type` (`re.sub(r'[^A-Za-z]', '', ...)[:2]`) in both the prompt and every tool output.
  - **Zero Local Path Leaks**: Never reference `/home/agent/...` in `find_default_csv()` or anywhere else.
  - Run all Python self-checks:
    ```bash
    for m in "simon-industry rules" "simon-industry tickets" "simon-industry agent_triage" "simon-canary simon_canary" "simon-monitor simon_monitor"; do
      set -- $m
      python3 -c "import sys; sys.path.insert(0, 'tools/$1'); import $2; $2.selfcheck(); print('$2 ok')"
    done
    ```

## 2. Gateway (`tools/simon-api/`) & Monitor (`tools/simon-monitor/`)

- **`simon_api.py`**:
  - Passes `--expect-signer <node_id>` when `node_id` is configured in `nodes.json` and reports `"signer_pinned": bool(r.get("signer_pinned"))`.
  - Reports `"proof_level": int(r.get("poziom_dowodu") or 0)` and `"m1_binding_checked": int(r.get("poziom_dowodu") or 0) >= 1` (what the agent *verified*, never the node's unverified `poziom_deklarowany_przez_node`).
  - Returns HTTP `503` with `Retry-After` when all nodes return `node_zajety` or `rate_limit`.
  - Uses constant-time SHA-256 digest comparison (`hmac.compare_digest(sha256(got), sha256(expected))`) for `SIMON_API_KEY`.
  - Run tests: `python3 -m unittest discover -s tools/simon-api -p "test_*.py" && python3 tools/simon-api/check_failover.py`

## 3. SvelteKit 5 UI (`ui/`)

- **Framework**: SvelteKit 2 + Svelte 5 Runes (`$state`, `$derived`) + TailwindCSS + Vite.
- **Signer Pinning in UI (`ui/src/lib/plant-nodes.ts`)**:
  - `plantNode(signer)` checks if the receipt's Ed25519 signer is on the plant's known node list (`RTX 3090 · Poland`, `AMD Instinct MI300X · Atlanta`), displaying `plant-listed node: <name>` vs `unknown node`.
- **Browser Capability Grant Previews**:
  - The browser has no operator private key; grant previews must set `signature: null` and `status: "UNSIGNED_PREVIEW"`, computing the exact `SIMON/GRANT-PARAMS/v1` SHA-256 digest over the 5 parameters (`action_code`, `failure_modes`, `part_id`, `summary`, `urgency`).
- **390px Mobile Viewport & Accessibility**:
  - Use `min-w-0` on grid children and `break-all` / `whitespace-pre-wrap` on hex/JSON blocks so pages never overflow a `390px` phone screen.
  - Add `type="button"`, `aria-pressed`, `aria-label`, and `aria-live="polite"`.
- **UI Verification**:
  ```bash
  npm --prefix ui run check
  npm --prefix ui run fixtures && git -C ui diff --exit-code src/lib/fixture.ts
  BASE_PATH=/SIMON npm --prefix ui run build
  ```
