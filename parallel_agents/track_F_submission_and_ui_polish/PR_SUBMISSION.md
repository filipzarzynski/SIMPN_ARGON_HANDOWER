# Pull Request Submission Report — Track F (PR-6, Stage 1)

- **Generated At**: `2026-10-15T21:11:59Z`
- **Track**: Track F (`PR-6`)
- **Track Branch**: `fz/track-F-submission-and-ui-polish`
- **Target PR Base Branch**: `fz-contrib` (**NEVER** directly to `main`)
- **HEAD Commit**: `e36ecbb3cd5217ebf6201adae480f46d7013804d`
- **Integrated into Local Hub `fz-contrib`**: `YES (Linear / Cherry-Pickable)`
- **Portable Git Bundle**: `/home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_F_submission_and_ui_polish/PR-6_F.bundle`
- **Remote Push (`fork`)**: `PUSHED`
- **GitHub PR URL (into `fz-contrib`)**: `Ready to open from fz/track-F-submission-and-ui-polish -> fz-contrib`

---

## PR Title
`[FZ-F] fix(ui,docs,tools): reconcile submission test/MI300X tables, clarify UI demo/network badges, and harden Python tools`

## Summary (PR-6 — Track F, Stage 1)

- **Target Integration Branch**: `fz-contrib` *(does **not** touch `main` directly; prepared for Team Captain review / cherry-pick)*
- **Addresses Audit Findings**: `BUG-10`, `BUG-11`, `BUG-12`, `BUG-13`, `BUG-14`, `BUG-16`

### Captain's Granular Cherry-Pick Menu
Every commit on this branch is self-contained, compiles cleanly, and passes tests independently:

| # | Commit | Description | Files Touched | Captain Cherry-Pick Command |
| :--- | :--- | :--- | :--- | :--- |
| `1` | `360fd58` | [FZ-F1] feat(ui): add Ed25519 signature tamper button to /demo and simulation badge to /network | `ui/src/lib/components/NodePanel.svelte, ui/src/routes/demo/+page.svelte, ui/src/routes/network/+page.svelte` | `git cherry-pick 360fd58ccee8a0c340d7fb458c10217c8185a454` |
| `2` | `a7f3c06` | [FZ-F2] fix(tools): make simon_api.py proof_level M1-aware and add optional SIMON_API_KEY auth | `demo/app.en.py, demo/app.py, tools/simon-api/simon_api.py, tools/simon-verifier/verifier_loop.py` | `git cherry-pick a7f3c0641aeb0dc26580f65232ac17219a056bf6` |
| `3` | `e36ecbb` | [FZ-F3] docs(submission): align crate/test counts and MI300X metrics across README and LABLAB-SUBMISSION | `README.md, docs/zgloszenie/LABLAB-SUBMISSION.md` | `git cherry-pick e36ecbb3cd5217ebf6201adae480f46d7013804d` |

### Diffstat
```text
README.md                              | 12 ++---
 demo/app.en.py                         |  8 ++--
 demo/app.py                            |  8 ++--
 docs/zgloszenie/LABLAB-SUBMISSION.md   | 13 +++---
 tools/simon-api/simon_api.py           | 21 ++++++++-
 tools/simon-verifier/verifier_loop.py  | 82 ++++++++++++++++++++++++++++++++--
 ui/src/lib/components/NodePanel.svelte | 15 +++++--
 ui/src/routes/demo/+page.svelte        | 48 +++++++++++++++-----
 ui/src/routes/network/+page.svelte     |  5 ++-
 9 files changed, 172 insertions(+), 40 deletions(-)
```

### Cross-Track & `fz-contrib` Merge Verification
- **Base `fz-contrib`**: CLEAN (0 conflicts)
- **Track A (`fz/track-A-node-receipt-truth`)**: CLEAN (0 conflicts)
- **Track B (`fz/track-B-live-m1-receipts`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track C (`fz/track-C-industry-m7-agent`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track D (`fz/track-D-core-security-hardening`)**: CLEAN (0 conflicts)
- **Track E (`fz/track-E-coordinator-gossipsub-bridge`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track G (`fz/track-G-architecture-and-docs-overhaul`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track H (`fz/track-H-e2e-integration-and-live-m1-bridge`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track I (`fz/track-I-captain-cherry-pick-menu-and-ci`)**: Not pushed to hub yet (disjoint file scope guaranteed)


## Modified Files (9)
- `README.md`
- `demo/app.en.py`
- `demo/app.py`
- `docs/zgloszenie/LABLAB-SUBMISSION.md`
- `tools/simon-api/simon_api.py`
- `tools/simon-verifier/verifier_loop.py`
- `ui/src/lib/components/NodePanel.svelte`
- `ui/src/routes/demo/+page.svelte`
- `ui/src/routes/network/+page.svelte`
