---
name: simon-pr-delivery
description: >-
  Use this skill once all Track tasks and 4-pass checks are complete to verify
  zero merge conflicts against `fz-contrib` and sibling Track branches, integrate
  your atomic cherry-pickable commits into the shared `fz-contrib` branch, and
  create a Pull Request targeting `fz-contrib` (never directly targeting `main`).
---

# SIMON Pull Request & `fz-contrib` Integration Skill (`simon-pr-delivery`)

Activate this skill in **Phase 5** after `verify_track.sh <TRACK> --final` succeeds.

## Why We Target `fz-contrib` (Never `main`)

To respect the Team Captain's review bandwidth and keep `Szpili/SIMON`'s `main` branch pristine:
1. Every Track agent (`A`–`N`) works on `fz/track-<X>-<slug>` and targets **`fz-contrib`** as its PR base branch.
2. Each commit is atomic, non-breaking, and prefixed with `[FZ-<X><N>]` so the Team Captain can either review/merge `fz-contrib` as a whole or **cherry-pick individual commits** (`git cherry-pick <sha>`) straight onto `main` in seconds.
3. Under an exclusive `flock`, [prepare_and_create_pr.py](./scripts/prepare_and_create_pr.py) also integrates your verified track commits into `hub/fz-contrib` (`workspaces/_upstream_hub.git`) and pushes `fz-contrib` + `fz/track-<X>-<slug>` to remote when credentials are configured.

## Steps to Execute

1. Run the PR delivery script from `/home/agent/SIMPN_ARGON_HANDOWER`:
   ```bash
   python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track <TRACK_LETTER>
   ```
2. Review the generated `parallel_agents/track_<X>_*/PR_SUBMISSION.md` to confirm:
   - `Target Base Branch: fz-contrib`
   - `Cross-Track Merge Check: 0 CONFLICTS`
   - `Captain's Cherry-Pick Menu` with exact `git cherry-pick <sha>` commands for every commit on your branch.
