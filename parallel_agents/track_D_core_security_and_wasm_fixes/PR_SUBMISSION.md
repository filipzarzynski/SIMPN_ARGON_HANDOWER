# Pull Request Submission Report — Track D ([FZ-D], Stage 1) — Upstream PR #4

- **Generated At**: `2026-10-15T20:58:26Z`
- **Track**: Track D (`[FZ-D]`)
- **Track Branch**: `fz/track-D-core-security-hardening`
- **Target PR Base Branch**: `fz-contrib` (**NEVER** directly to `main`)
- **HEAD Commit**: `3669a8413ee6d5d4b2d4704ef594319e16e6073b`
- **Integrated into Local Hub `fz-contrib`**: `YES (Linear / Cherry-Pickable)`
- **Portable Git Bundle**: `/home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_D_core_security_and_wasm_fixes/FZ-D.bundle`
- **Upstream GitHub PR (Szpili/SIMON)**: `https://github.com/Szpili/SIMON/pull/4` (WAITING FOR MERGE)
- **Fork PR (filipzarzynski/SIMON)**: `https://github.com/filipzarzynski/SIMON/pull/1`
- **Target Integration Base**: `fz-contrib` / `main`

---

## PR Title
`[FZ-D] fix(core,wasm): enforce M0 signature in M1/WASM, block IPv6-mapped SSRF, NaN logprobs, and non-object Cap JSON`

## Summary (Track D — [FZ-D], Stage 1)

- **Target Integration Branch**: `fz-contrib` *(does **not** touch `main` directly; prepared for Team Captain review / cherry-pick)*
- **Addresses Audit Findings**: `BUG-04`, `BUG-06`, `BUG-15`

### Captain's Granular Cherry-Pick Menu
Every commit on this branch is self-contained, compiles cleanly, and passes tests independently:

| # | Commit | Description | Files Touched | Captain Cherry-Pick Command |
| :--- | :--- | :--- | :--- | :--- |
| `1` | `39d1315` | [FZ-D1] fix(core,wasm): enforce Ed25519 signature verification inside Receipt::zweryfikuj_m1 | `crates/simon-core/src/receipt.rs, crates/simon-core/tests/tamper_matrix.rs, crates/simon-verify-wasm/src/lib.rs` | `git cherry-pick 39d131569dc8cd126ac57f52d1a7263f18da2d4a` |
| `2` | `f51f977` | [FZ-D2] fix(core): block IPv4-mapped IPv6, ULA, and link-local SSRF bypasses in web.rs | `crates/simon-core/src/web.rs` | `git cherry-pick f51f97713638629fcbd23a57fefeb67c0a7f6476` |
| `3` | `a90db89` | [FZ-D3] fix(core): reject NaN/Inf logprobs and sort topk descending in m3::ocena | `crates/simon-core/src/m3.rs` | `git cherry-pick a90db89dc78b334e1acef425ae66c04097ad7407` |
| `4` | `3669a84` | [FZ-D4] fix(core): harden cap.rs JSON object check, tozsamosc 0600 file creation, obserwacja sign, and protokol clock | `crates/simon-core/src/cap.rs, crates/simon-core/src/obserwacja.rs, crates/simon-core/src/protokol.rs, crates/simon-core/src/tozsamosc.rs` | `git cherry-pick 3669a8413ee6d5d4b2d4704ef594319e16e6073b` |

### Diffstat
```text
crates/simon-core/src/cap.rs             | 73 ++++++++++++++++++++++++++++----
 crates/simon-core/src/m3.rs              | 59 ++++++++++++++++++++++++--
 crates/simon-core/src/obserwacja.rs      | 11 +++++
 crates/simon-core/src/protokol.rs        | 14 +++++-
 crates/simon-core/src/receipt.rs         | 35 +++++++++++++++
 crates/simon-core/src/tozsamosc.rs       | 13 ++++++
 crates/simon-core/src/web.rs             | 47 ++++++++++++++++----
 crates/simon-core/tests/tamper_matrix.rs | 13 ++++++
 crates/simon-verify-wasm/src/lib.rs      | 15 +++++++
 9 files changed, 258 insertions(+), 22 deletions(-)
```

### Cross-Track & `fz-contrib` Merge Verification
- **Base `fz-contrib`**: CLEAN (0 conflicts)
- **Track A (`fz/track-A-node-receipt-truth`)**: CLEAN (0 conflicts)
- **Track B (`fz/track-B-live-m1-receipts`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track C (`fz/track-C-industry-m7-agent`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track E (`fz/track-E-coordinator-gossipsub-bridge`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track F (`fz/track-F-submission-and-ui-polish`)**: CLEAN (0 conflicts)
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
