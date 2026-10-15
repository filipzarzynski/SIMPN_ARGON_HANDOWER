# Pull Request Submission Report — Track A ([FZ-A], Stage 1) — Upstream PR #5

- **Generated At**: `2026-10-15T21:06:08Z`
- **Track**: Track A (`[FZ-A]`)
- **Track Branch**: `fz/track-A-node-receipt-truth`
- **Target PR Base Branch**: `fz-contrib` (**NEVER** directly to `main`)
- **HEAD Commit**: `02010bef0d5d7ecca145f0ac47d3a3e319e10cd0`
- **Integrated into Local Hub `fz-contrib`**: `YES (Linear / Cherry-Pickable)`
- **Portable Git Bundle**: `/home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_A_receipt_and_node_truth/FZ-A.bundle`
- **Upstream GitHub PR (Szpili/SIMON)**: `https://github.com/Szpili/SIMON/pull/5` (WAITING FOR MERGE)
- **Fork PR (filipzarzynski/SIMON)**: `https://github.com/filipzarzynski/SIMON/pull/3`
- **Target Integration Base**: `fz-contrib` / `main`

---

## PR Title
`[FZ-A] fix(node): populate real Unix timestamp_us, dynamic GGUF precision, and weight SHA-256 verification`

## Summary (Track A — [FZ-A], Stage 1)

- **Target Integration Branch**: `fz-contrib` *(does **not** touch `main` directly; prepared for Team Captain review / cherry-pick)*
- **Addresses Audit Findings**: `BUG-01`, `BUG-02`, `BUG-05`

### Captain's Granular Cherry-Pick Menu
Every commit on this branch is self-contained, compiles cleanly, and passes tests independently:

| # | Commit | Description | Files Touched | Captain Cherry-Pick Command |
| :--- | :--- | :--- | :--- | :--- |
| `1` | `39d1315` | [FZ-D1] fix(core,wasm): enforce Ed25519 signature verification inside Receipt::zweryfikuj_m1 | `crates/simon-core/src/receipt.rs, crates/simon-core/tests/tamper_matrix.rs, crates/simon-verify-wasm/src/lib.rs` | `git cherry-pick 39d131569dc8cd126ac57f52d1a7263f18da2d4a` |
| `2` | `f51f977` | [FZ-D2] fix(core): block IPv4-mapped IPv6, ULA, and link-local SSRF bypasses in web.rs | `crates/simon-core/src/web.rs` | `git cherry-pick f51f97713638629fcbd23a57fefeb67c0a7f6476` |
| `3` | `a90db89` | [FZ-D3] fix(core): reject NaN/Inf logprobs and sort topk descending in m3::ocena | `crates/simon-core/src/m3.rs` | `git cherry-pick a90db89dc78b334e1acef425ae66c04097ad7407` |
| `4` | `3669a84` | [FZ-D4] fix(core): harden cap.rs JSON object check, tozsamosc 0600 file creation, obserwacja sign, and protokol clock | `crates/simon-core/src/cap.rs, crates/simon-core/src/obserwacja.rs, crates/simon-core/src/protokol.rs, crates/simon-core/src/tozsamosc.rs` | `git cherry-pick 3669a8413ee6d5d4b2d4704ef594319e16e6073b` |
| `5` | `bf4b6c0` | [FZ-A1] fix(node): populate real started_at_us and finished_at_us in live Receipt | `crates/simon-cli/src/node.rs` | `git cherry-pick bf4b6c0c6920c1d0cf9fb654c97461c65d0002c2` |
| `6` | `cc60fac` | [FZ-A2] fix(node): infer Receipt Precision from model_hash instead of hardcoded Fp16 | `crates/simon-cli/src/node.rs` | `git cherry-pick cc60facf5503416d6008c77516b6ef49c892dcbb` |
| `7` | `e7e4133` | [FZ-A3] fix(node): detect llama.cpp runtime via /props and support llama-server /tokenize | `crates/simon-cli/src/node.rs` | `git cherry-pick e7e4133156d55f5ce500ee2bd777504cdcb064c8` |
| `8` | `02010be` | [FZ-A4] feat(cli): add --expect-signer verification to simon verify | `crates/simon-cli/src/agent.rs, crates/simon-cli/src/main.rs` | `git cherry-pick 02010bef0d5d7ecca145f0ac47d3a3e319e10cd0` |

### Diffstat
```text
crates/simon-cli/src/agent.rs            |   1 +
 crates/simon-cli/src/main.rs             | 124 ++++++++++++++++++++++++-
 crates/simon-cli/src/node.rs             | 153 +++++++++++++++++++++++++++----
 crates/simon-core/src/cap.rs             |  73 +++++++++++++--
 crates/simon-core/src/m3.rs              |  59 +++++++++++-
 crates/simon-core/src/obserwacja.rs      |  11 +++
 crates/simon-core/src/protokol.rs        |  14 ++-
 crates/simon-core/src/receipt.rs         |  35 +++++++
 crates/simon-core/src/tozsamosc.rs       |  13 +++
 crates/simon-core/src/web.rs             |  47 ++++++++--
 crates/simon-core/tests/tamper_matrix.rs |  13 +++
 crates/simon-verify-wasm/src/lib.rs      |  15 +++
 12 files changed, 515 insertions(+), 43 deletions(-)
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


## Modified Files (12)
- `crates/simon-cli/src/agent.rs`
- `crates/simon-cli/src/main.rs`
- `crates/simon-cli/src/node.rs`
- `crates/simon-core/src/cap.rs`
- `crates/simon-core/src/m3.rs`
- `crates/simon-core/src/obserwacja.rs`
- `crates/simon-core/src/protokol.rs`
- `crates/simon-core/src/receipt.rs`
- `crates/simon-core/src/tozsamosc.rs`
- `crates/simon-core/src/web.rs`
- `crates/simon-core/tests/tamper_matrix.rs`
- `crates/simon-verify-wasm/src/lib.rs`
