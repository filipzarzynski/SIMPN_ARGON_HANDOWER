---
name: simon-crypto-and-protocol
description: >-
  Use this skill when modifying Rust crates in SIMON (Tracks A, B, D, or E:
  simon-core, simon-verify-wasm, simon-node, simon-harness, or simon-cli).
  Provides the exact cryptographic domain separators, M0/M1/M3 receipt verification
  invariants, canonical JSON serialization rules, and Polish/English serde mappings.
---

# SIMON Cryptography, Receipt & Protocol Reference (`simon-crypto-and-protocol`)

Activate this skill whenever you work on **Track A, Track B, Track D, or Track E** (any Rust crate in `crates/`).

## 1. Cryptographic Primitives & Domain Separation (`SIMON-*-v1`)

All hashing in SIMON uses **BLAKE3 (`blake3::Hasher`)** with explicit ASCII domain tags followed by a `0x00` byte separator via `haszuj_z_domena(domena, dane)` (`crates/simon-core/src/crypto.rs`).

- **NEVER** modify any of the 9 domain strings in `crates/simon-core`:
  - `SIMON-RECEIPT-v1` (`crates/simon-core/src/receipt.rs`)
  - `SIMON-M1-TOKEN-v1` (`crates/simon-core/src/receipt.rs`)
  - `SIMON-M1-ROOT-v1` (`crates/simon-core/src/receipt.rs`)
  - `SIMON-M3-LOGPROB-v1` (`crates/simon-core/src/m3.rs`)
  - `SIMON-CAP-v1`, `SIMON-WEIGHTS-v1`, `SIMON-PROMPT-v1`, `SIMON-OUTPUT-v1`, `SIMON-CONFIG-v1` (`crates/simon-core/src/protokol.rs`)
- **Verification**: Always run `python3 scripts/wartownik_stalych.py` inside your clone after editing any `.rs` file.

## 2. Receipt Tiers (`M0`, `M1`, `M3`)

Read [domain_tags_and_serde.md](./references/domain_tags_and_serde.md) for the exact struct fields, byte layouts, and Polish-to-English `#[serde(rename = "...")]` mappings.

- **M0 (`Receipt::zweryfikuj`)**:
  - Recomputes `skrot_ladunku = BLAKE3("SIMON-RECEIPT-v1" || 0x00 || canonical_json_without_signature_and_payload_hash)`.
  - Verifies the 64-byte Ed25519 `podpis_wykonawcy` (`signature_hex`) using the executor's 32-byte public key (`executor_pubkey_hex`).
  - **CRITICAL (`Track D`)**: An unsigned receipt (`podpis_wykonawcy == None`) MUST NEVER pass verification (`zweryfikuj`, `zweryfikuj_m1`, or WASM `verify_receipt_json`).
- **M1 (`Receipt::zweryfikuj_m1`)**:
  - First calls `self.zweryfikuj()?` (M0 signature & payload hash check).
  - Then verifies the non-empty `zobowiazania_tokenow` (`Vec<TokenCommitment>`) chain (`0..N` contiguous `indeks`, each `TokenCommitment::zweryfikuj()` passes) and matches `oblicz_korzen_m1` against `skrot_zobowiazan_tokenow` (`token_commitments_root_hex`).
- **M3 (`m3.rs`)**:
  - Passive logprob comparison (`PorownanieLogprob::ocen`). Note that `HardFail` is intentionally disabled per `docs/FP-RESULT.md` due to cross-hardware FP drift (`0.088–0.130 nats`), returning `DriftWarn` instead.
  - **CRITICAL (`Track D`)**: Reject non-finite (`!x.is_finite()`, i.e. `NaN` or `±Inf`) logprob values before computing deltas (`BladM3::NieprawidlowyLogprob`).

## 3. Build & Test Commands

Always prepend `/home/agent/.cargo/bin` to `PATH`:
```bash
export PATH="/home/agent/.cargo/bin:$PATH"
cargo test --workspace
cargo clippy --workspace -- -D warnings
python3 scripts/wartownik_stalych.py
```
