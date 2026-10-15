---
name: simon-verify-suite
description: >-
  Use this skill to run multi-pass verification on your Track's isolated clone
  (workspaces/track_<X>) before committing and before creating a Pull Request.
  Verifies strict file-scope boundaries, commit granularity, Rust/Python/UI test suites,
  Clippy lints, and cryptographic constant integrity.
---

# SIMON Multi-Pass Verification Skill (`simon-verify-suite`)

Activate this skill during **Phase 3 (before commits)** and **Phase 4 (final multi-pass verification)** for any Track (`A`–`I`).

## What [verify_track.sh](./scripts/verify_track.sh) Checks

1. **Pass 1 — File Scope & Working Tree Audit**:
   - Ensures `git status --porcelain` is clean (when run in `--final` mode).
   - Verifies that every file in `git diff --name-only <base>...HEAD` (and working tree) matches your Track's **Exclusive File Ownership** glob rules. Any modification outside your assigned files fails the check immediately so parallel tracks never collide.
2. **Pass 2 — Commit Granularity Audit**:
   - Checks `git log --oneline <base>..HEAD` to confirm logical, granular `[FZ-<X><N>]` commits exist.
3. **Pass 3 — Language & Domain Test Suites**:
   - **Tracks A, B, D, E, H (Rust)**: Runs `python3 scripts/wartownik_stalych.py`, `cargo test` for the affected crates, and `cargo clippy -- -D warnings`.
   - **Track C (Industry + UI)**: Runs `python3 tools/simon-industry/rules.py`, `python3 tools/simon-industry/agent_triage.py --selfcheck`, `python3 -m py_compile` on `tools/simon-industry/*.py`, validates `ui/src/lib/industry-run.json` (`records` & `summary.tickets`), and runs `npm run check && npm run build` inside `ui/`.
   - **Track F (Submission + UI + Python)**: Runs `python3 -m py_compile` on modified Python scripts and runs `npm run check && npm run build` inside `ui/`.

## How to Run

From `/home/agent/SIMPN_ARGON_HANDOWER`:
```bash
# Quick check during development (allows uncommitted changes in working tree):
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh <TRACK_LETTER>

# Strict final check before creating PR (requires clean working tree & >=1 commits):
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh <TRACK_LETTER> --final
```
