---
name: simon-track-init
description: >-
  Use this skill immediately at the start of any Track (Stage 1: A, B, C, D, E, F;
  Stage 2: G, H, I) agent session to initialize the isolated workspace subfolder,
  clone the upstream Szpili/SIMON repository, ensure the shared `fz-contrib` integration
  branch exists, and check out the track's dedicated `fz/track-*` branch off `fz-contrib`.
---

# SIMON Track Initialization Skill (`simon-track-init`)

Activate this skill as **Step 1** whenever you are assigned as a **Track A, B, C, D, E, F, G, H, or I** agent inside `SIMPN_ARGON_HANDOWER`.

## Branch Strategy (`fz-contrib` Integration Base — Never PR Directly to `main`)

To avoid spamming the Team Captain or polluting `main` on `Szpili/SIMON`:
1. All contributions target the dedicated **`fz-contrib`** branch (initialized from `origin/main`).
2. Each Track works on its own branch `fz/track-<X>-<slug>` branched off `fz-contrib`.
3. Every commit on `fz/track-<X>-<slug>` MUST be **self-contained, non-breaking, and individually cherry-pickable** with prefix `[FZ-<X><N>]` (e.g., `[FZ-A1] fix(node): populate real Unix timestamp_us in Receipt`).
4. Pull Requests from Track agents target **`fz-contrib`** (never `main`). Once reviewed, the Team Captain can either merge `fz-contrib` into `main` or cherry-pick individual `[FZ-*]` commits.

## Steps to Execute

1. Run the initialization script with your assigned track letter (`A`–`I`):
   ```bash
   bash .agents/skills/simon-track-init/scripts/init_track.sh <TRACK_LETTER>
   ```
2. Verify the output confirms:
   - Your clone directory path (`workspaces/track_<X>`)
   - Your checked-out branch (`fz/track-<X>-...`) based on `fz-contrib`
   - Clean `git status --short`
   - Your exclusive permitted file list and `TASK_SPEC.md` path
3. Read the printed `TASK_SPEC.md` file before making any edits.
