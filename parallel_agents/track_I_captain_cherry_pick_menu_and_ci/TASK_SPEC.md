# Agent Task Specification: Track I (Stage 2) — Team Captain Cherry-Pick Menu & Fast Verification Script (`PR-9`)

**Stage:** Stage 2 (Run AFTER Stage 1 Tracks A–F are integrated into `fz-contrib`)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-I-captain-cherry-pick-menu-and-ci`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_I`  
**Exclusive Permitted Files:**
* `scripts/verify_all_fast.sh`
* `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md`

---

## 1. Objective

Eliminate the **Team Captain review bottleneck** by creating:
1. **A One-Command Full-Stack Verification Script (`scripts/verify_all_fast.sh`) (`[FZ-I1]`)**:
   - Runs `python3 scripts/wartownik_stalych.py`, `cargo test --workspace`, `cargo clippy --workspace -- -D warnings`, `python3 tools/simon-industry/rules.py`, and (if `ui/node_modules` exists) `npm --prefix ui run check`, printing a crisp pass/fail summary table in under 30 seconds.
2. **A Team Captain Cherry-Pick Menu (`docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md`) (`[FZ-I2]`)**:
   - Inspects `git log origin/main..hub/fz-contrib` and categorizes every `[FZ-*]` commit on `fz-contrib` into:
     - **Category 1 — Zero-Risk Bug & Security Fixes (Must-Have Cherry-Picks)**: Exact `git cherry-pick <sha>` commands for `Track D` (`Receipt::zweryfikuj_m1` signature check, `web.rs` IPv6 SSRF, `m3.rs` `NaN` logprob & `topk` sorting, `cap.rs` non-object JSON check), `Track A` (`started_at_us`/`finished_at_us`, `wykryj_precyzje`, `llama.cpp` `/props` & `/tokenize`, `--expect-signer`), and `Track F` (`LABLAB-SUBMISSION.md` & UI tamper buttons).
     - **Category 2 — Hackathon Showcase Upgrades**: Track 1 Gemma 4 M7 tool-calling agent & interactive `/industry` WASM verifier (`Track C`), Live M1 `WiazaniaM1` token chain (`Track B` & `Track H`).
     - **Category 3 — P2P Coordinator & MapReduce Upgrades**: `Track E` (`Registry::wybierz_kandydata_vrf`, `coord.rs` assignment/completion lifecycle, `mapreduce.rs` UTF-8 token budgeting).

---

## 2. Granular Commit Plan (Cherry-Pickable by Team Captain)

1. `[FZ-I1] feat(scripts): add scripts/verify_all_fast.sh one-command full-stack verification runner`
2. `[FZ-I2] docs(contrib): add docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md for rapid Team Captain review`

---

## 3. Verification & PR Delivery

```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh I --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track I
```
