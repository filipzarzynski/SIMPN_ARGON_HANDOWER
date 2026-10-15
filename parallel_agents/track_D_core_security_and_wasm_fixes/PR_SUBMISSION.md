# Pull Request Submission Report — Track D (PR-4, Stage 1)

- **Generated At**: `2026-10-15T20:17:05Z`
- **Track**: Track D (`PR-4`)
- **Track Branch**: `fz/track-D-core-security-hardening`
- **Target PR Base Branch**: `fz-contrib` (**NEVER** directly to `main`)
- **HEAD Commit**: `35df585dd00722816b9cf30a2a658c4dd3dd96b5`
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
| `1` | `f966e46` | [FZ-D1] fix(core,wasm): enforce Ed25519 signature verification inside Receipt::zweryfikuj_m1 | `crates/simon-core/src/receipt.rs, crates/simon-core/tests/tamper_matrix.rs, crates/simon-verify-wasm/src/lib.rs` | `git cherry-pick f966e46067f74eb5793017840d491e272d54dcce` |
| `2` | `723dd25` | [FZ-D2] fix(core): block IPv4-mapped IPv6, ULA, and link-local SSRF bypasses in web.rs | `crates/simon-core/src/web.rs` | `git cherry-pick 723dd25414db4ec8de081c07b676b30cbc081967` |
| `3` | `7d95021` | [FZ-D3] fix(core): reject NaN/Inf logprobs and sort topk descending in m3::ocena | `crates/simon-core/src/m3.rs` | `git cherry-pick 7d95021f8424ddd070a2fd47ed7dc17bd4ac75de` |
| `4` | `35df585` | [FZ-D4] fix(core): harden cap.rs JSON object check, tozsamosc 0600 file creation, obserwacja sign, and protokol clock | `crates/simon-core/src/cap.rs, crates/simon-core/src/obserwacja.rs, crates/simon-core/src/protokol.rs, crates/simon-core/src/tozsamosc.rs` | `git cherry-pick 35df585dd00722816b9cf30a2a658c4dd3dd96b5` |

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
- **Track A (`fz/track-A-node-receipt-truth`)**: CLEAN (0 conflicts)
- **Track B (`fz/track-B-live-m1-receipts`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track C (`fz/track-C-industry-m7-agent`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track E (`fz/track-E-coordinator-gossipsub-bridge`)**: Not pushed to hub yet (disjoint file scope guaranteed)
- **Track F (`fz/track-F-submission-and-ui-polish`)**: CONFLICT DETECTED
```
e54372d274d60dc1660a92966470904d4ec56a8a
100644 524ca602ae9a7db28e76916898895e1f2655c508 1	ui/src/lib/components/NodePanel.svelte
100644 9c378e637501c9ad10c81809699ae33d05fb9734 2	ui/src/lib/components/NodePanel.svelte
100644 b4f1b9d585c7b68432b9a3eb5ff8969a7723f5d0 3	ui/src/lib/components/NodePanel.svelte
100644 0a50457f891c4aee7a56b48042f911683f1207c2 1	ui/src/routes/demo/+page.svelte
100644 37a3256a1d4a5048fe1f632ebf65860da308f458 2	ui/src/routes/demo/+page.svelte
100644 95aca6a03964d8080b5b296d72c70ccc3e131e8c 3	ui/src/routes/demo/+page.svelte

Auto-merging ui/src/lib/components/NodePanel.svelte
CONFLICT (content): Merge conflict in ui/src/lib/components/NodePanel.svelte
Auto-merging ui/src/routes/demo/+page.svelte
CONFLICT (content): Merge conflict in ui/src/routes/demo/+page.svelte

```
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
