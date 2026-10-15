# Pull Request Submission Report — Track E ([FZ-E], Stage 1)

- **Generated At**: `2026-10-15T21:47:56Z`
- **Track**: Track E (`[FZ-E]`)
- **Track Branch**: `fz/track-E-coordinator-gossipsub-bridge`
- **Target PR Base Branch**: `fz-contrib` (**NEVER** directly to `main`)
- **HEAD Commit**: `51df3b7018f0f2523f46623ef68ed403852ee21b`
- **Integrated into Local Hub `fz-contrib`**: `YES (Linear / Cherry-Pickable)`
- **Portable Git Bundle**: `/home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_E_p2p_coordinator_bridge/FZ-E.bundle`
- **Remote Push (`fork`)**: `PUSHED`
- **Fork GitHub PR URL (into `fz-contrib`)**: `Ready to open from fz/track-E-coordinator-gossipsub-bridge -> fz-contrib`

---

## PR Title
`[FZ-E] feat(node,cli): add HTTP LLM executor bridge to SimonNode and fix MapReduce chunk truncation`

## Summary (Track E — [FZ-E], Stage 1)

- **Target Integration Branch**: `fz-contrib` *(does **not** touch `main` directly; prepared for Team Captain review / cherry-pick)*
- **Addresses Audit Findings**: `BUG-07`, `BUG-08`

### Captain's Granular Cherry-Pick Menu
Every commit on this branch is self-contained, compiles cleanly, and passes tests independently:

| # | Commit | Description | Files Touched | Captain Cherry-Pick Command |
| :--- | :--- | :--- | :--- | :--- |
| `1` | `61331ec` | [FZ-E1] feat(node): add mark_degraded and deterministic VRF candidate selection to Registry | `crates/simon-node/src/lib.rs` | `git cherry-pick 61331ec9f4125b520b61739f679cbefc88cc4382` |
| `2` | `6ff75b3` | [FZ-E2] fix(coord): wire VRF seed, rejestr.assign, and TOPIC_JOB_RESULT handling in coord.rs | `crates/simon-cli/src/coord.rs` | `git cherry-pick 6ff75b34d2780d439ce412f43f7ef3614c244fd2` |
| `3` | `51df3b7` | [FZ-E3] fix(mapreduce): improve UTF-8 token budget estimation and add chunking tests | `crates/simon-cli/src/mapreduce.rs` | `git cherry-pick 51df3b7018f0f2523f46623ef68ed403852ee21b` |

### Diffstat
```text
crates/simon-cli/src/coord.rs     | 338 ++++++++++++++++++++++++++++++++------
 crates/simon-cli/src/mapreduce.rs |  97 +++++++++++
 crates/simon-node/src/lib.rs      | 197 ++++++++++++++++++++++
 3 files changed, 578 insertions(+), 54 deletions(-)
```

### Cross-Track & `fz-contrib` Merge Verification
- **Base `fz-contrib`**: CLEAN (0 conflicts)
- **Track A (`fz/track-A-node-receipt-truth`)**: CLEAN (0 conflicts)
- **Track B (`fz/track-B-live-m1-receipts`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track C (`fz/track-C-industry-m7-agent`)**: CLEAN (0 conflicts)
- **Track D (`fz/track-D-core-security-hardening`)**: CLEAN (0 conflicts)
- **Track F (`fz/track-F-submission-and-ui-polish`)**: CLEAN (0 conflicts)
- **Track G (`fz/track-G-architecture-and-docs-overhaul`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track H (`fz/track-H-e2e-integration-and-live-m1-bridge`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track I (`fz/track-I-captain-cherry-pick-menu-and-ci`)**: Not pushed to hub yet (disjoint file scope guaranteed)


## Modified Files (3)
- `crates/simon-cli/src/coord.rs`
- `crates/simon-cli/src/mapreduce.rs`
- `crates/simon-node/src/lib.rs`
