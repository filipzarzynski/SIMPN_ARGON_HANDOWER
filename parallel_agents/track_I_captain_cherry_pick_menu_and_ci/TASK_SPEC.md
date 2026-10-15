# Agent Task Specification: Track I (Stage 2) — Team Captain Cherry-Pick Menu & Fast Verification Script (`PR-9`)

**Stage:** Stage 2 (Run AFTER Stage 1 Tracks A–F are integrated into `fz-contrib`)
**Target Base Branch:** `fz-contrib` (NEVER `main`)
**Dedicated Track Branch:** `fz/track-I-captain-cherry-pick-menu-and-ci`
**Assigned Role:** Release & Developer Experience Engineer (Gemini 3.8 Flash High)
**Prerequisite Reading:** [`../AGENT_RULES_COMMON.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/AGENT_RULES_COMMON.md), [`../../05_HACKATHON_ROADMAP_AND_PR_CATALOG.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/05_HACKATHON_ROADMAP_AND_PR_CATALOG.md)

---

## 1. Objective

Eliminate the **Team Captain review bottleneck** by creating:
1. **A One-Command Full-Stack Verification Script (`scripts/verify_all_fast.sh`) (`[FZ-I1]`)**:
   - Runs `python3 scripts/wartownik_stalych.py`, `cargo test --workspace`, `cargo clippy --workspace -- -D warnings`, `python3 tools/simon-industry/rules.py --self-test`, and (if `ui/node_modules` exists) `npm --prefix ui run check`, printing a crisp pass/fail summary table in under 30 seconds.
2. **A Team Captain Cherry-Pick Menu (`docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md`) (`[FZ-I2]`)**:
   - Inspects `git log origin/main..hub/fz-contrib` and categorizes every `[FZ-*]` commit on `fz-contrib` into:
     - **Category 1 — Zero-Risk Bug & Security Fixes (Must-Have Cherry-Picks)**: Exact `git cherry-pick <sha>` commands for `BUG-01` (`0 µs` timestamp), `BUG-02` (GGUF precision), `BUG-04`/`BUG-15` (unsigned M1/WASM bypass), `BUG-06` (IPv6 SSRF), `BUG-16` (`LABLAB-SUBMISSION.md` contradictions).
     - **Category 2 — Hackathon Showcase Upgrades**: Track 1 Gemma 4 M7 tool-calling agent (`Track C`), Live M1 token commitments (`Track B`/`Track H`), UI tamper/topology badges (`Track F`).
     - **Category 3 — P2P Coordinator & MapReduce Fixes**: `Track E` (`mapreduce.rs` chunk retention and `SimonNode` HTTP executor).

---

## 2. Permitted Files (Strict Scope)

You may **ONLY** create or modify:
- `scripts/verify_all_fast.sh`
- `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md`

---

## 3. Granular Commit Plan (Cherry-Pickable by Team Captain)

1. `[FZ-I1] feat(scripts): add scripts/verify_all_fast.sh one-command full-stack verification runner`
2. `[FZ-I2] docs(contrib): add docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md for rapid Team Captain review`

---

## 4. Verification & PR Delivery

```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh I --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track I
```
