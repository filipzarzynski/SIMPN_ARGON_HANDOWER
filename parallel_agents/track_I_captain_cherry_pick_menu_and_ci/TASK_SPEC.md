# Agent Task Specification: Track I (Stage 2, Wave 2B) — Team Captain Cherry-Pick Menu & Fast Verification Gate (`[FZ-I]`)

**Stage:** Stage 2, Wave 2B (Run AFTER Wave 2A Tracks H & J are integrated into `fz-contrib`)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-I-captain-cherry-pick-menu-and-ci`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_I`  
**Exclusive Permitted Files:**
* `scripts/verify_all_fast.sh`
* `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md`

---

## 0. Mandatory Skills to Read First
1. `/home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-captain-review-guardrails/SKILL.md`
2. `/home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-verify-suite/SKILL.md`

---

## 1. Objective

Eliminate the **Team Captain review bottleneck** by creating a fast, zero-GPU verification gate and an up-to-date cherry-pick guide covering Stage 2 (`Tracks H, J, G, I`) and Stage 3 (`Tracks K, L, M, N`):

1. **Create `scripts/verify_all_fast.sh` (`[FZ-I1]`)**:
   - Executable (`chmod +x`) bash script with `set -euo pipefail` that runs the full CPU/offline test and guardrail suite in under 30 seconds:
     1. `python3 scripts/wartownik_stalych.py` (protocol & constant sync guard)
     2. `cargo test --workspace` (all Rust unit & integration tests across `simon-core`, `simon-harness`, `simon-node`, `simon-cli`, `simon-verify-wasm`)
     3. `cargo clippy --workspace --all-targets -- -D warnings` (including integration tests and examples!)
     4. All 5 Python `.selfcheck()` suites:
        - `python3 tools/simon-industry/rules.py`
        - `python3 tools/simon-industry/tickets.py`
        - `python3 tools/simon-industry/agent_triage.py`
        - `python3 tools/simon-industry/export_ui.py`
        - `python3 tools/simon-api/simon_api.py --selfcheck`
     5. Captain Guardrail Greps:
        - Fails if `SIMPN_ARGON_HANDOWER` or `/home/agent/` appears anywhere in tracked files.
        - Fails if banned overclaim phrases (`"100% Authentic"`, `"100% Cryptographically Verified"`, `"guarantees the claimed model"`, `"SIMULATED P2P TOPOLOGY"`) appear outside `docs/THREAT-MODEL.md` ("Sentences we must never publish") or `scripts/verify_all_fast.sh`.
     6. Optional UI check: if `ui/node_modules` exists, runs `npm --prefix ui run check`.
   - Prints a clean, aligned PASS/FAIL summary table with elapsed time per step.

2. **Create `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md` (`[FZ-I2]`)**:
   - Inspects `git log origin/main..HEAD` and documents the exact commits and test evidence for Stage 2 (`[FZ-H]`, `[FZ-J]`, `[FZ-G]`, `[FZ-I]`):
     - **Category 1 — `docs/STRESS-TESTS.md` Next #1 & #3 (`[FZ-J]`)**: Signed `JobResult` (`SIMON/JOB-RESULT/v1`, including failures) and signed `RegisterMsg` + `NodeVoucher` (`SIMON/NODE-REGISTER/v1`, `SIMON/NODE-VOUCH/v1`) with Sybil flood tests.
     - **Category 2 — `docs/STRESS-TESTS.md` Next #2 (`[FZ-H]`)**: Live M1 token binding (`PromptResponse::{prompt_tokens, output_tokens}`, `MAX_M1_TOKENS = 65_536` cap, `WiazaniaM1` in `node.rs`, and `e2e_m1_receipt.rs` in-process harness).
     - **Category 3 — Documentation & Fast Verification Gate (`[FZ-G]`, `[FZ-I]`)**: `docs/ARCHITECTURE.md`, `docs/STRESS-TESTS.md` rows 7/17/18, and `scripts/verify_all_fast.sh`.
   - Includes exact `git cherry-pick <sha>` commands and one-liner verification commands per track so `Szpili` can cherry-pick individual tracks or merge `fz-contrib` in one click.

---

## 2. Granular Commit Plan (Cherry-Pickable by Team Captain)

1. `[FZ-I1] feat(scripts): add scripts/verify_all_fast.sh full-stack verification and guardrail runner`
2. `[FZ-I2] docs(contrib): add docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md for Stage 2 Team Captain review`

---

## 3. Verification & PR Delivery

```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh I --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track I
```
