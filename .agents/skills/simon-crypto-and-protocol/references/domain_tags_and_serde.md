# SIMON Rust Struct & Domain Tag Reference (`crates/simon-core` & `crates/simon-node`)

## 1. `Receipt` (`crates/simon-core/src/receipt.rs`)

| Field Name (Rust & JSON) | Type | Notes |
| :--- | :--- | :--- |
| `job_id` | `String` | Unique job identifier |
| `node_id` | `String` | Executor node identifier (`klucz.public().to_hex()`) |
| `model_hash` | `String` | Model identifier / GGUF name |
| `runtime` | `String` | e.g. `"vllm/0.27.1"`, `"ollama/0.5.1"`, `"llama.cpp/1"` |
| `precision` | `Precision` | Enum: `Bf16` (`"bf16"`), `Fp16` (`"fp16"`), `Fp32` (`"fp32"`), `Fp8` (`"fp8"`), `Fp4` (`"fp4"`), `Int8` (`"int8"`), `Int4` (`"int4"`), `Unknown` (`"unknown"`). **Never guess!** |
| `activation_hash` | `String` | e.g. `"toploc:NIE_POLICZONY"` |
| `prompt_tokens` | `u32` | Input token count |
| `completion_tokens` | `u32` | Output token count |
| `output_digest` | `String` | 64-char hex SHA-256 from `odcisk_wyjscia(job_id, output)` (`"SIMON/OUTPUT/v1"`) |
| `started_at_us` | `u64` | Unix timestamp in microseconds when inference started |
| `finished_at_us` | `u64` | Unix timestamp in microseconds when inference finished |
| `signer` | `PublicKey` | 32-byte Ed25519 public key (serialized as 64-char hex) |
| `signature` | `Option<Signature>` | 64-byte Ed25519 signature (serialized as 128-char hex) |
| `wiazania` | `Option<WiazaniaM1>` | Proof Level 1 token-chain & sampling bindings (`#[serde(flatten, default, skip_serializing_if = "Option::is_none")]`) |

## 2. `WiazaniaM1` (`crates/simon-core/src/receipt.rs`)

| Field Name (Rust & JSON) | Type | Domain / Formula |
| :--- | :--- | :--- |
| `schema_version` | `u8` | `1` (`SCHEMA_VERSION_M1`) |
| `receipt_level` | `u8` | `1` (`RECEIPT_LEVEL_M1`) |
| `exec_profile` | `String` | Runtime & precision descriptor (e.g. `format!("{runtime}/{precision:?}")`) |
| `tokenizer_hash` | `String` | `odcisk_tokenizera(bytes)` (`"SIMON/TOKENIZER/v1"`) |
| `prompt_digest` | `String` | `odcisk_promptu(tokenizer_hash, client_nonce, prompt_token_ids)` (`"SIMON/PROMPT/v1"`) |
| `output_token_chain` | `String` | `lancuch_tokenow(&prompt_digest, output_token_ids)` (`"SIMON/CHAIN/v1"`) |
| `client_nonce` | `String` | Client order nonce (`req.nonce`) |
| `sampling_params_hash` | `String` | `SamplingCommitment::greedy().odcisk()` (`"SIMON/SAMPLING/v1"`) |
| `rng_seed` | `u64` | Deterministic sampling seed (`0` for greedy) |

## 3. Exact Signatures in `crates/simon-core/src/receipt.rs`
- `odcisk_wyjscia(job_id: &str, output: &str) -> Result<String, SimonError>`
- `odcisk_promptu(tokenizer_hash: &str, client_nonce: &str, prompt_token_ids: &[u32]) -> Result<String, SimonError>`
- `lancuch_tokenow(prompt_digest: &str, output_token_ids: &[u32]) -> Result<String, SimonError>`
- `odcisk_tokenizera(bytes: &[u8]) -> String`
- `SamplingCommitment::greedy().odcisk() -> Result<String, SimonError>`
- `Receipt::z_wiazaniem_m1(self, tokenizer_hash: String, client_nonce: String, prompt_token_ids: &[u32], output_token_ids: &[u32], sampling_params_hash: String, rng_seed: u64, exec_profile: String) -> Result<Self, SimonError>`
- `Receipt::zweryfikuj_m1(&self, tokenizer_hash: &str, client_nonce: &str, prompt_token_ids: &[u32], output_token_ids: &[u32]) -> Result<(), SimonError>`

## 4. Stage 2 Node & Coordinator Domain Tags (`crates/simon-node/src/lib.rs`)
- `SIMON/JOB-RESULT/v1` (`DOMENA_JOB_RESULT`): Domain tag for `JobResult::digest()` & `JobResult::sign(&Keypair)` / `JobResult::verify_from_node(&PublicKey)`, binding `(job_id, node_id, ok, error, receipt_digest)` so both successes and **failures** on gossipsub are cryptographically authenticated by the assigned node's registered key.
- `SIMON/NODE-REGISTER/v1` (`DOMENA_NODE_REGISTER`): Domain tag for `RegisterMsg::digest()` & `RegisterMsg::sign(&Keypair)` / `RegisterMsg::verify_self()`, proving possession of `pubkey` on `TOPIC_NODE_REGISTER` (with optional operator voucher signature).
