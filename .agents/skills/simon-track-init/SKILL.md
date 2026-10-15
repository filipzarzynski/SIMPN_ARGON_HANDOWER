---
name: simon-track-init
description: >-
  Use this skill immediately at the start of a Track (A, B, C, D, E, or F) agent session
  to initialize the isolated workspace subfolder, clone the upstream Szpili/SIMON repository,
  check out the track's dedicated feature branch, and configure local git remotes and excludes.
---

# SIMON Track Initialization Skill (`simon-track-init`)

Activate this skill as **Step 1** whenever you are assigned as **Track A, B, C, D, E, or F** agent inside `SIMPN_ARGON_HANDOWER`.

## What This Skill Does

Running [init_track.sh](./scripts/init_track.sh) performs a concurrency-safe (`flock`) setup for your assigned track:
1. Initializes/updates the shared local bare integration hub (`workspaces/_upstream_hub.git`) mirrored from `https://github.com/Szpili/SIMON.git` (using `/home/agent/SIMON` for local object sharing when available).
2. Clones `https://github.com/Szpili/SIMON.git` into your dedicated isolated directory `workspaces/track_<X>` and links `parallel_agents/track_<X>_*/repo` to it.
3. Checks out your track's dedicated branch (`fix/node-receipt-truth`, `feat/live-m1-receipts`, `feat/industry-m7-agent`, `fix/core-security-hardening`, `feat/coordinator-gossipsub-bridge`, or `fix/submission-and-ui-polish`) tracking `origin/main`.
4. Injects track-specific `AGENTS.md` and `.agents` skill links into `workspaces/track_<X>` while registering them in `.git/info/exclude` so `git status` inside your clone stays 100% clean.

## Steps to Execute

1. Run the initialization script with your assigned track letter (`A`, `B`, `C`, `D`, `E`, or `F`):
   ```bash
   bash .agents/skills/simon-track-init/scripts/init_track.sh <TRACK_LETTER>
   ```
2. Verify the output confirms:
   - Your clone directory path (`workspaces/track_<X>`)
   - Your checked-out branch name
   - Clean `git status --short`
   - Your exclusive permitted file list and `TASK_SPEC.md` path
3. Read the printed `TASK_SPEC.md` file before making any edits.
