# Pull Request Submission Report — Track I ([FZ-I], Stage 2)

- **Generated At**: `2026-10-16T18:45:37Z`
- **Track**: Track I ([`FZ-I`])
- **Track Branch**: `fz/track-I-captain-cherry-pick-menu-and-ci`
- **Target PR Base Branch**: `fz-contrib` (**NEVER** directly to `main`)
- **Base Commit Before Integration**: `e3296a8b22dc0959353a7ac2dccb9b02597bd0af`
- **HEAD Commit**: `f8be75201dd1a292e28d98ceb2d966223d68cc07`
- **Integrated into Local Hub `fz-contrib`**: `YES (Linear / Cherry-Pickable)`
- **Portable Git Bundle**: `/home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_I_captain_cherry_pick_menu_and_ci/FZ-I.bundle`
- **Remote Push (`fork`)**: `PUSHED`
- **GitHub PR URL (into `fz-contrib`)**: `https://github.com/filipzarzynski/SIMON/pull/4 (and https://github.com/Szpili/SIMON/compare/main...fz-contrib)`

---

## PR Title
`[FZ-I] feat(scripts,docs): add verify_all_fast.sh guardrail runner and Stage 2 Captain cherry-pick menu`

## Summary (Track I — [FZ-I], Stage 2)

- **Target Integration Branch**: `fz-contrib` *(does **not** touch `main` directly; prepared for Team Captain review / cherry-pick)*
- **Addresses Roadmap / Stress-Test Items**: `CAPTAIN-REVIEW-UX`

### Captain's Granular Cherry-Pick Menu
Every commit on this branch is self-contained, compiles cleanly, and passes tests independently:

| # | Commit | Description | Files Touched | Captain Cherry-Pick Command |
| :--- | :--- | :--- | :--- | :--- |
| `1` | `c40ec8c` | [FZ-I1] feat(scripts): add scripts/verify_all_fast.sh full-stack verification and guardrail runner | `scripts/verify_all_fast.sh` | `git cherry-pick c40ec8cdae9e7e8a4a642251743c55a1562b1bdd` |
| `2` | `f8be752` | [FZ-I2] docs(contrib): add docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md for Stage 2 Team Captain review | `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md` | `git cherry-pick f8be75201dd1a292e28d98ceb2d966223d68cc07` |

### Diffstat
```text
docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md | 140 ++++++++++++++++++++++++
 scripts/verify_all_fast.sh           | 206 +++++++++++++++++++++++++++++++++++
 2 files changed, 346 insertions(+)
```

### Cross-Track & `fz-contrib` Merge Verification
- **Base `fz-contrib`**: CLEAN (0 conflicts)
- **Track G (`fz/track-G-architecture-and-docs-overhaul`)**: CLEAN (0 conflicts)
- **Track H (`fz/track-H-e2e-integration-and-live-m1-bridge`)**: CLEAN (0 conflicts)
- **Track J (`fz/track-J-signed-job-result-and-registration`)**: CLEAN (0 conflicts)


## Modified Files (2)
- `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md`
- `scripts/verify_all_fast.sh`
