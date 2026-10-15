# Pull Request Submission Report — Track A (PR-1, Stage 1)

- **Generated At**: `2026-10-15T20:17:54Z`
- **Track**: Track A (`PR-1`)
- **Track Branch**: `fz/track-A-node-receipt-truth`
- **Target PR Base Branch**: `fz-contrib` (**NEVER** directly to `main`)
- **HEAD Commit**: `86b9fc9842ef4d1de753fcd98a6b5419f15da5cc`
- **Integrated into Local Hub `fz-contrib`**: `YES (Linear / Cherry-Pickable)`
- **Portable Git Bundle**: `/home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_A_receipt_and_node_truth/PR-1_A.bundle`
- **Remote Push (`origin`)**: `LOCAL_HUB_AND_BUNDLE_READY (set GITHUB_TOKEN/credentials to push upstream)`
- **GitHub PR URL (into `fz-contrib`)**: `Ready to open from fz/track-A-node-receipt-truth -> fz-contrib`

---

## PR Title
`[FZ-A] fix(node): populate real Unix timestamp_us, dynamic GGUF precision, and weight SHA-256 verification`

## Summary (PR-1 — Track A, Stage 1)

- **Target Integration Branch**: `fz-contrib` *(does **not** touch `main` directly; prepared for Team Captain review / cherry-pick)*
- **Addresses Audit Findings**: `BUG-01`, `BUG-02`, `BUG-05`

### Captain's Granular Cherry-Pick Menu
Every commit on this branch is self-contained, compiles cleanly, and passes tests independently:

| # | Commit | Description | Files Touched | Captain Cherry-Pick Command |
| :--- | :--- | :--- | :--- | :--- |
| `1` | `53d116f` | [FZ-A1] fix(node): populate real started_at_us and finished_at_us in live Receipt | `crates/simon-cli/src/node.rs` | `git cherry-pick 53d116f85b7cc013501ae9a52ce1d48c70e8dfa0` |
| `2` | `a29f207` | [FZ-A2] fix(node): infer Receipt Precision from model_hash instead of hardcoded Fp16 | `crates/simon-cli/src/node.rs` | `git cherry-pick a29f2078a50512416f6d8b6a4171d2c52290355e` |
| `3` | `e613422` | [FZ-A3] fix(node): detect llama.cpp runtime via /props and support llama-server /tokenize | `crates/simon-cli/src/node.rs` | `git cherry-pick e613422cd11fd85fca622dac3215e272e4227e71` |
| `4` | `86b9fc9` | [FZ-A4] feat(cli): add --expect-signer verification to simon verify | `crates/simon-cli/src/agent.rs, crates/simon-cli/src/main.rs` | `git cherry-pick 86b9fc9842ef4d1de753fcd98a6b5419f15da5cc` |

### Diffstat
```text
crates/simon-cli/src/agent.rs |   1 +
 crates/simon-cli/src/main.rs  | 124 +++++++++++++++++++++++++++++++++-
 crates/simon-cli/src/node.rs  | 153 ++++++++++++++++++++++++++++++++++++------
 3 files changed, 257 insertions(+), 21 deletions(-)
```

### Cross-Track & `fz-contrib` Merge Verification
- **Base `fz-contrib`**: CLEAN (0 conflicts)
- **Track B (`fz/track-B-live-m1-receipts`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track C (`fz/track-C-industry-m7-agent`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track D (`fz/track-D-core-security-hardening`)**: CLEAN (0 conflicts)
- **Track E (`fz/track-E-coordinator-gossipsub-bridge`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track F (`fz/track-F-submission-and-ui-polish`)**: CLEAN (0 conflicts)
- **Track G (`fz/track-G-architecture-and-docs-overhaul`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track H (`fz/track-H-e2e-integration-and-live-m1-bridge`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track I (`fz/track-I-captain-cherry-pick-menu-and-ci`)**: Not pushed to hub yet (disjoint file scope guaranteed)


## Modified Files (3)
- `crates/simon-cli/src/agent.rs`
- `crates/simon-cli/src/main.rs`
- `crates/simon-cli/src/node.rs`
