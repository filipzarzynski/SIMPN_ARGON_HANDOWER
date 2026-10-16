---
name: simon-verify-suite
description: >-
  Use this skill to run 4-pass verification on your Track's isolated clone
  (workspaces/track_<X>) before committing and before creating a Pull Request.
  Verifies strict file-scope boundaries, Captain Review Guardrails (zero path leaks
  and zero banned overclaims), commit granularity, Rust/Python/UI test suites,
  Clippy `--all-targets` lints, and cryptographic constant integrity.
---

# SIMON Multi-Pass Verification Skill (`simon-verify-suite`)

Activate this skill during **Phase 3 (before commits)** and **Phase 4 (final multi-pass verification)** for any Track (`A`–`N`).

## What [verify_track.sh](./scripts/verify_track.sh) Checks

1. **Pass 1 — File Scope & Working Tree Audit**:
   - Ensures `git status --porcelain` is clean (when run in `--final` mode).
   - Verifies that every file in `git diff --name-only <base>...HEAD` (and working tree) matches your Track's **Exclusive File Ownership** glob rules. Any modification outside your assigned files fails the check immediately so parallel tracks never collide.
2. **Pass 2 — Captain Guardrails Audit (Path Leaks & Banned Overclaims)**:
   - Fails immediately if `SIMPN_ARGON_HANDOWER` or `/home/agent/` appears in any modified file.
   - Fails immediately if banned overclaim phrases (`"100% Authentic"`, `"100% Cryptographically Verified"`, `"guarantees the claimed model"`, `"SIMULATED P2P TOPOLOGY"`, `"ed25519:operator_sig_"`) appear in any modified file (outside `docs/THREAT-MODEL.md` or `scripts/verify_all_fast.sh`).
3. **Pass 3 — Commit Granularity Audit**:
   - Checks `git log --oneline <base>..HEAD` to confirm logical, granular `[FZ-<X><N>]` commits exist.
4. **Pass 4 — Language & Domain Test Suites**:
   - **Tracks A, B, D, E, H, J, K (Rust)**: Runs `python3 scripts/wartownik_stalych.py`, `cargo test` for the affected crates, and `cargo clippy --all-targets -- -D warnings`.
   - **Tracks C, M (Industry + UI)**: Runs `rules.py`, `tickets.selfcheck()`, `agent_triage.py --selfcheck`, `export_ui.py`, `python3 -m py_compile` on `tools/simon-industry/*.py`, and (for Track C) `npm run check && npm run build` inside `ui/`.
   - **Track L (Gateway + Monitor)**: Runs `python3 tools/simon-api/test_gateway.py`, `python3 tools/simon-api/simon_api.py --selfcheck`, and `python3 tools/simon-monitor/simon_monitor.py --selfcheck`.
   - **Tracks F, N (UI)**: Runs `npm run check && npm run build` inside `ui/`.
   - **Tracks G, I (Docs + Fast CI Gate)**: Runs `python3 scripts/wartownik_stalych.py` and `bash scripts/verify_all_fast.sh` (if present).

## How to Run

From `/home/agent/SIMPN_ARGON_HANDOWER`:
```bash
# Quick check during development (allows uncommitted changes in working tree):
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh <TRACK_LETTER>

# Strict final check before creating PR (requires clean working tree & >=1 commits):
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh <TRACK_LETTER> --final
```
