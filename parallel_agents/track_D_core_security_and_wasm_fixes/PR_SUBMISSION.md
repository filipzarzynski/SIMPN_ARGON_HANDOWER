# Pull Request Submission Report — Track D (PR-4, Stage 1)

- **Generated At**: `2026-10-15T19:47:21Z`
- **Track**: Track D (`PR-4`)
- **Track Branch**: `fz/track-D-core-security-hardening`
- **Target PR Base Branch**: `fz-contrib` (**NEVER** directly to `main`)
- **HEAD Commit**: `3d5349a030ea20a8731e7b882ab5c67a981952da`
- **Integrated into Local Hub `fz-contrib`**: `YES (Linear / Cherry-Pickable)`
- **Portable Git Bundle**: `/home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_D_core_security_and_wasm_fixes/PR-4_D.bundle`
- **Remote Push (`origin`)**: `LOCAL_HUB_AND_BUNDLE_READY (set GITHUB_TOKEN/credentials to push upstream)`
- **GitHub PR URL (into `fz-contrib`)**: `Ready to open from fz/track-D-core-security-hardening -> fz-contrib`

---

## PR Title
`[FZ-D] fix(core,wasm): enforce M0 signature in M1/WASM, block IPv6-mapped SSRF, NaN logprobs, and non-object Cap JSON`

## Summary (PR-4 — Track D, Stage 1)

- **Target Integration Branch**: `fz-contrib` *(does **not** touch `main` directly; prepared for Team Captain review / cherry-pick)*
- **Addresses Audit Findings**: `BUG-04`, `BUG-06`, `BUG-15`

### Captain's Granular Cherry-Pick Menu
Every commit on this branch is self-contained, compiles cleanly, and passes tests independently:

| # | Commit | Description | Files Touched | Captain Cherry-Pick Command |
| :--- | :--- | :--- | :--- | :--- |
| `1` | `ccfbd1d` | [FZ-D1] fix(core,wasm): enforce Ed25519 signature verification inside Receipt::zweryfikuj_m1 | `crates/simon-core/src/receipt.rs, crates/simon-core/tests/tamper_matrix.rs, crates/simon-verify-wasm/src/lib.rs` | `git cherry-pick ccfbd1dd93291e856ca6bb152f6f86568dfef647` |
| `2` | `23ca3e7` | [FZ-D2] fix(core): block IPv4-mapped IPv6, ULA, and link-local SSRF bypasses in web.rs | `crates/simon-core/src/web.rs` | `git cherry-pick 23ca3e70cfc4c81a66547b55a4ad90437ba8fde4` |
| `3` | `358065c` | [FZ-D3] fix(core): reject NaN/Inf logprobs and sort topk descending in m3::ocena | `crates/simon-core/src/m3.rs` | `git cherry-pick 358065c48a00a3de148f320ff69169f3af6b0c77` |
| `4` | `3d5349a` | [FZ-D4] fix(core): harden cap.rs JSON object check, tozsamosc 0600 file creation, obserwacja sign, and protokol clock | `crates/simon-core/src/cap.rs, crates/simon-core/src/obserwacja.rs, crates/simon-core/src/protokol.rs, crates/simon-core/src/tozsamosc.rs` | `git cherry-pick 3d5349a030ea20a8731e7b882ab5c67a981952da` |

### Diffstat
```text
crates/simon-core/src/cap.rs             | 73 ++++++++++++++++++++++++++++----
 crates/simon-core/src/m3.rs              | 59 ++++++++++++++++++++++++--
 crates/simon-core/src/obserwacja.rs      | 11 +++++
 crates/simon-core/src/protokol.rs        | 14 +++++-
 crates/simon-core/src/receipt.rs         | 36 ++++++++++++++++
 crates/simon-core/src/tozsamosc.rs       | 13 ++++++
 crates/simon-core/src/web.rs             | 47 ++++++++++++++++----
 crates/simon-core/tests/tamper_matrix.rs | 13 ++++++
 crates/simon-verify-wasm/src/lib.rs      | 15 +++++++
 9 files changed, 259 insertions(+), 22 deletions(-)
```

### Cross-Track & `fz-contrib` Merge Verification
- **Base `fz-contrib`**: CLEAN (0 conflicts)
- **Track A (`fz/track-A-node-receipt-truth`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track B (`fz/track-B-live-m1-receipts`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track C (`fz/track-C-industry-m7-agent`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track E (`fz/track-E-coordinator-gossipsub-bridge`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track F (`fz/track-F-submission-and-ui-polish`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track G (`fz/track-G-architecture-and-docs-overhaul`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track H (`fz/track-H-e2e-integration-and-live-m1-bridge`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track I (`fz/track-I-captain-cherry-pick-menu-and-ci`)**: Not pushed to hub yet (disjoint file scope guaranteed)


## Modified Files (9)
- `crates/simon-core/src/cap.rs`
- `crates/simon-core/src/m3.rs`
- `crates/simon-core/src/obserwacja.rs`
- `crates/simon-core/src/protokol.rs`
- `crates/simon-core/src/receipt.rs`
- `crates/simon-core/src/tozsamosc.rs`
- `crates/simon-core/src/web.rs`
- `crates/simon-core/tests/tamper_matrix.rs`
- `crates/simon-verify-wasm/src/lib.rs`
