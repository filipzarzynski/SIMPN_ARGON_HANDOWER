---
name: simon-pr-delivery
description: >-
  Use this skill once all Track tasks and multi-pass checks are complete to rebase
  onto the latest upstream main, verify zero merge conflicts against main and all sibling
  parallel Track branches, push the branch, and create the Pull Request.
---

# SIMON Pull Request & Merge Verification Skill (`simon-pr-delivery`)

Activate this skill in **Phase 5** after `verify_track.sh <TRACK> --final` succeeds.

## What [prepare_and_create_pr.py](./scripts/prepare_and_create_pr.py) Does

1. **Rebases Onto Latest Upstream `main`**:
   - Fetches `origin/main` (`https://github.com/Szpili/SIMON.git`) and rebases your Track branch cleanly so commit history is linear and up-to-date.
2. **Cross-Track Merge Conflict Verification**:
   - Pushes your branch to the shared local integration hub (`workspaces/_upstream_hub.git`).
   - Tests merging your branch with `origin/main` AND with every other active/completed sibling Track branch (`Track A`–`Track F`) in a temporary git index (`git merge-tree`), proving zero merge conflicts.
3. **Remote Push & Pull Request Creation**:
   - Pushes your branch to `origin` (or `SIMON_FORK_URL` if set).
   - If `GITHUB_TOKEN` / `GH_TOKEN` or `gh` CLI is available, opens the GitHub Pull Request automatically via the GitHub REST API (`https://api.github.com/repos/Szpili/SIMON/pulls`).
   - Generates a complete Pull Request artifact at `parallel_agents/track_<X>_*/PR_SUBMISSION.md` containing the commit log, diffstat, verification results, cross-track merge status, and PR body.

## Steps to Execute

1. Run the PR delivery script from `/home/agent/SIMPN_ARGON_HANDOWER`:
   ```bash
   python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track <TRACK_LETTER>
   ```
2. Review the generated `parallel_agents/track_<X>_*/PR_SUBMISSION.md` to confirm:
   - `Upstream Rebase Status: CLEAN`
   - `Cross-Track Merge Check: 0 CONFLICTS`
   - PR URL (if `GITHUB_TOKEN` is configured) or ready-to-push PR bundle.
