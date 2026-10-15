---
name: simon-crypto-and-protocol
description: >-
  Use this skill when modifying Rust crates in SIMON (Tracks A, B, D, E, or H:
  simon-core, simon-verify-wasm, simon-node, simon-harness, or simon-cli).
  Provides the exact cryptographic domain separators, M0/M1/M3 receipt verification
  invariants, canonical JSON serialization rules, and Rust struct layouts.
---

# SIMON Cryptography, Receipt & Protocol Reference (`simon-crypto-and-protocol`)

Activate this skill whenever you work on **Track A, Track B, Track D, Track E, or Track H** (any Rust crate in `crates/`).

## 1. Cryptographic Primitives & Domain Separation (`SIMON/*/v1`)

All content hashing in `simon-core` uses **SHA-256 (`sha2::Sha256`)** over canonical JSON (`canonical_json`) with explicit ASCII domain tags followed by a `0x00` byte separator via `content_digest(domain, value)` (`crates/simon-core/src/crypto.rs`). Ed25519 signatures use `ed25519-dalek` over `domain.as_bytes() || 0x00 || payload`.

- **NEVER** change any existing domain string in `crates/simon-core`:
  - `SIMON/RECEIPT/v1` (`crates/simon-core/src/receipt.rs` — `DOMENA_RECEIPT`)
  - `SIMON/OUTPUT/v1` (`crates/simon-core/src/receipt.rs` — `DOMENA_ODCISKU_WYJSCIA`)
  - `SIMON/PROMPT/v1` (`crates/simon-core/src/receipt.rs` — `DOMENA_PROMPTU`)
  - `SIMON/CHAIN/v1` (`crates/simon-core/src/receipt.rs` — `DOMENA_LANCUCHA`)
  - `SIMON/SAMPLING/v1` (`crates/simon-core/src/receipt.rs` — `DOMENA_PARAMETROW`)
  - `SIMON/TOKENIZER/v1` (`crates/simon-core/src/receipt.rs` — `DOMENA_TOKENIZERA`)
  - `SIMON/GRANT/v1` & `SIMON/GRANT-PARAMS/v1` (`crates/simon-core/src/cap.rs`)
  - `SIMON/OBSERVATION/v1` (`crates/simon-core/src/obserwacja.rs`)
  - `SIMON/PRACA/v1` (`crates/simon-core/src/pomiar.rs`)
- **Verification**: Always run `python3 scripts/wartownik_stalych.py` inside your clone after editing any `.rs` file.

## 2. Receipt Tiers (Level 0, Level 1 `WiazaniaM1`, and `m3.rs`)

Read [domain_tags_and_serde.md](./references/domain_tags_and_serde.md) for the exact struct fields and methods on `Receipt`, `WiazaniaM1`, `Precision`, and `SamplingCommitment`.

- **Level 0 (`Receipt::verify_self` & `Receipt::zgodny_z_wyjsciem`)**:
  - `Receipt::digest()` computes `content_digest("SIMON/RECEIPT/v1", &self.widok())`.
  - `Receipt::verify_self()` verifies the 64-byte Ed25519 `signature` using `self.signer` over `"SIMON/RECEIPT/v1\0" || digest.as_bytes()`.
  - `Receipt::zgodny_z_wyjsciem(output)` recomputes `odcisk_wyjscia(&self.job_id, output)` (`"SIMON/OUTPUT/v1"`) and compares it in constant time (`porownaj_staly_czas`) against `self.output_digest`.
- **Level 1 (`Receipt::z_wiazaniem_m1` & `Receipt::zweryfikuj_m1`)**:
  - Attaches `wiazania: Some(WiazaniaM1)` binding `tokenizer_hash`, `prompt_digest` (`odcisk_promptu(tokenizer_hash, client_nonce, prompt_token_ids)`), `token_chain_digest` (`lancuch_tokenow(&prompt_digest, output_token_ids)`), `params_digest`, and `seed`.
  - **CRITICAL (`Track D`)**: `Receipt::zweryfikuj_m1` MUST call `self.verify_self()?` at the very start so unsigned or forged receipts cannot pass `zweryfikuj_m1` or `simon_verify_wasm::weryfikuj_m1`!
- **M3 (`crates/simon-core/src/m3.rs`)**:
  - Evaluates token steps `Krok { indeks, token, topk: Vec<(u32, f64)> }` against `Polityka` via `ocena(kroki, p) -> Werdykt`.
  - Note that `HardFail` is intentionally unused in `ocena()` per `docs/FP-RESULT.md` due to cross-hardware FP drift; severe violations return `Werdykt::DriftWarn`.
  - **CRITICAL (`Track D`)**: Reject non-finite (`!lp.is_finite()`, i.e. `NaN` or `±Inf`) logprob values and do not assume `kr.topk` is pre-sorted before computing `top1_lp` and `margin`.

## 3. Build & Test Commands

Always prepend `/home/agent/.cargo/bin` to `PATH`:
```bash
export PATH="/home/agent/.cargo/bin:$PATH"
cargo test --workspace
cargo clippy --workspace -- -D warnings
python3 scripts/wartownik_stalych.py
```
