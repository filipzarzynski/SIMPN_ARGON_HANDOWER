# Pull Request Submission Report — Track H ([FZ-H], Stage 2)

- **Generated At**: `2026-10-16T18:45:28Z`
- **Track**: Track H ([`FZ-H`])
- **Track Branch**: `fz/track-H-e2e-integration-and-live-m1-bridge`
- **Target PR Base Branch**: `fz-contrib` (**NEVER** directly to `main`)
- **Base Commit Before Integration**: `e7e8a50deea488ec751fd9957a06297e96f120a5`
- **HEAD Commit**: `e3296a8b22dc0959353a7ac2dccb9b02597bd0af`
- **Integrated into Local Hub `fz-contrib`**: `YES (Linear / Cherry-Pickable)`
- **Portable Git Bundle**: `/home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_H_e2e_integration_and_live_m1_bridge/FZ-H.bundle`
- **Remote Push (`fork`)**: `PUSHED`
- **GitHub PR URL (into `fz-contrib`)**: `https://github.com/filipzarzynski/SIMON/pull/4 (and https://github.com/Szpili/SIMON/compare/main...fz-contrib)`

---

## PR Title
`[FZ-H] feat(cli): wire live M1 token chain with MAX_M1_TOKENS caps and in-process E2E test`

## Summary (Track H — [FZ-H], Stage 2)

- **Target Integration Branch**: `fz-contrib` *(does **not** touch `main` directly; prepared for Team Captain review / cherry-pick)*
- **Addresses Roadmap / Stress-Test Items**: `STRESS-TESTS-NEXT-2`, `BUG-03-E2E`

### Captain's Granular Cherry-Pick Menu
Every commit on this branch is self-contained, compiles cleanly, and passes tests independently:

| # | Commit | Description | Files Touched | Captain Cherry-Pick Command |
| :--- | :--- | :--- | :--- | :--- |
| `1` | `65cadc7` | [FZ-H1] fix(cli): enforce MAX_M1_TOKENS cap and strict array parsing in wspolne::tokenizuj_tekst | `crates/simon-cli/src/wspolne.rs` | `git cherry-pick 65cadc7ea16d79fb4c587ba3ec44da9a33680968` |
| `2` | `2360454` | [FZ-H2] feat(node): wire live M1 token commitments with length caps in node::policz | `crates/simon-cli/src/node.rs, crates/simon-cli/src/wspolne.rs` | `git cherry-pick 2360454f7d2c8086450417d385d6c9e4aa2a48ed` |
| `3` | `e3296a8` | [FZ-H3] test(cli): add E2E live M1 receipt generation and tamper verification test suite | `crates/simon-cli/tests/e2e_m1_receipt.rs` | `git cherry-pick e3296a8b22dc0959353a7ac2dccb9b02597bd0af` |

### Diffstat
```text
crates/simon-cli/src/node.rs             | 185 +++++++++++--
 crates/simon-cli/src/wspolne.rs          |  44 ++--
 crates/simon-cli/tests/e2e_m1_receipt.rs | 439 +++++++++++++++++++++++++++++++
 3 files changed, 636 insertions(+), 32 deletions(-)
```

### Cross-Track & `fz-contrib` Merge Verification
- **Base `fz-contrib`**: CLEAN (0 conflicts)
- **Track G (`fz/track-G-architecture-and-docs-overhaul`)**: CLEAN (0 conflicts)
- **Track I (`fz/track-I-captain-cherry-pick-menu-and-ci`)**: CLEAN (0 conflicts)
- **Track J (`fz/track-J-signed-job-result-and-registration`)**: CLEAN (0 conflicts)


## Modified Files (3)
- `crates/simon-cli/src/node.rs`
- `crates/simon-cli/src/wspolne.rs`
- `crates/simon-cli/tests/e2e_m1_receipt.rs`
