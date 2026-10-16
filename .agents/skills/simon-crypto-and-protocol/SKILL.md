---
name: simon-crypto-and-protocol
description: >-
  Use this skill when modifying Rust crates in SIMON (Stage 1 Tracks A, B, D, E;
  Stage 2 Tracks H, J; Stage 3 Track K: simon-core, simon-verify-wasm, simon-node,
  simon-harness, or simon-cli). Provides the exact cryptographic domain separators,
  M0/M1/M3 receipt verification invariants, conservative Precision rules, and P2P security rules.
---

# SIMON Cryptography, Receipt & Protocol Reference (`simon-crypto-and-protocol`)

Activate this skill whenever you work on **Track H, Track J, or Track K** (or any Rust crate in `crates/`). Also read [`.agents/skills/simon-captain-review-guardrails/SKILL.md`](../simon-captain-review-guardrails/SKILL.md).

## 1. Cryptographic Primitives & Domain Separation (`SIMON/*/v1`)

All content hashing in `simon-core` uses **SHA-256 (`sha2::Sha256`)** over canonical JSON (`content_digest(&serde_json::json!({ "domena": DOMENA_*, ... }))` in `crates/simon-core/src/crypto.rs`). Ed25519 signatures use `Keypair::sign_digest(&digest)` and `PublicKey::verify_digest(&digest, &sig)`.

- **NEVER** change any existing domain string in `crates/simon-core`:
  - `SIMON/OUTPUT/v1` (`crates/simon-core/src/receipt.rs` — `DOMENA_ODCISKU_WYJSCIA`)
  - `SIMON/PROMPT/v1` (`crates/simon-core/src/receipt.rs` — `DOMENA_PROMPTU`)
  - `SIMON/CHAIN/v1` (`crates/simon-core/src/receipt.rs` — `DOMENA_LANCUCHA`)
  - `SIMON/SAMPLING/v1` (`crates/simon-core/src/receipt.rs` — `DOMENA_PARAMETROW`)
  - `SIMON/TOKENIZER/v1` (`crates/simon-core/src/receipt.rs` — `DOMENA_TOKENIZERA`)
  - `SIMON/GRANT/v1` & `SIMON/GRANT-PARAMS/v1` (`crates/simon-core/src/cap.rs`)
  - `SIMON/OBSERVATION/v1` (`crates/simon-core/src/obserwacja.rs`)
  - `SIMON/PRACA/v1` (`crates/simon-core/src/pomiar.rs`)
- **Stage 2 Domain Tags (`crates/simon-node/src/lib.rs`)**:
  - `SIMON/JOB-RESULT/v1` (`DOMENA_JOB_RESULT`) — authenticates `JobResult` (both successes and failures) signed by the node's registered key.
  - `SIMON/NODE-REGISTER/v1` (`DOMENA_NODE_REGISTER`) — authenticates `RegisterMsg` proof-of-possession and optional operator voucher signature.

## 2. Receipt Tiers, Precision & Verification Invariants

Read [domain_tags_and_serde.md](./references/domain_tags_and_serde.md) for the exact struct fields and methods on `Receipt`, `WiazaniaM1`, `Precision`, and `SamplingCommitment`.

- **Conservative `Precision` (`Precision::{Bf16, Fp16, Fp32, Fp8, Fp4, Int8, Int4, Unknown}`)**:
  - Receipts **NEVER** sign a guessed precision. `wykryj_precyzje(model_hash)` splits on non-alphanumeric tokens, maps GGUF `q4`/`iq4`/`awq`/`gptq`/`int4`/`4bit`/`w4a*` to `Int4`, `q8`/`iq8`/`int8`/`8bit`/`w8a*` to `Int8`, and returns `Precision::Unknown` on unmarked names, unsupported widths (`Q5`, `Q6`), or conflicting markers (`awq-fp8`).
- **Level 0 (`Receipt::verify_self`, `Receipt::zgodny_z_wyjsciem`, `podpisal_oczekiwany`)**:
  - `verify_self()` checks the Ed25519 signature under `self.signer` (the key inside the receipt).
  - Because `verify_self()` uses the receipt's own key, any attacker can generate a keypair and self-sign arbitrary text unless the client pins `--expect-signer` (`podpisal_oczekiwany` in `agent.rs`, `signer_pinned` in JSON output).
- **Level 1 (`Receipt::z_wiazaniem_m1`, `Receipt::zweryfikuj_m1`, `poziom_sprawdzony`)**:
  - **Live M1 Length Cap (`MAX_M1_TOKENS = 65_536`)**: Both `wspolne::tokenizuj_tekst` / `wyciagnij_id_tokenow` and `agent.rs` must enforce `MAX_M1_TOKENS` (`65_536`) so untrusted peers cannot trigger memory/CPU exhaustion via huge token arrays.
  - **Client Proof Level (`poziom_sprawdzony`)**: A client reports `poziom_dowodu = 1` ONLY when `zweryfikuj_receipt` passed AND non-empty token vectors (`prompt_token_ids`, `output_token_ids`) were verified via `zweryfikuj_m1` against the **client's own `order.nonce`**. Node-declared `receipt.poziom()` is reported separately as `poziom_deklarowany_przez_node`.
- **M3 (`crates/simon-core/src/m3.rs`)**:
  - `ocena_json` rejects any JSON audit containing `"simulated"` with any value other than `false` (`true`, `"true"`, `1`, `null`).

## 3. Build & Test Commands

Always prepend `/home/agent/.cargo/bin` to `PATH` and run clippy with `--all-targets`:
```bash
export PATH="/home/agent/.cargo/bin:$PATH"
python3 scripts/wartownik_stalych.py crates
cargo test --workspace --locked
cargo clippy --workspace --all-targets -- -D warnings
```
