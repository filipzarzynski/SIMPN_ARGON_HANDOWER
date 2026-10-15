# SIMON Rust Struct & Domain Tag Reference (`crates/simon-core`)

## 1. `Receipt` (`crates/simon-core/src/receipt.rs`)

| Field Name (Rust & JSON) | Type | Notes |
| :--- | :--- | :--- |
| `job_id` | `String` | Unique job identifier |
| `node_id` | `String` | Executor node identifier (usually hex public key) |
| `model_hash` | `String` | Model identifier / GGUF name |
| `precision` | `Precision` | Enum: `Bf16` (`"bf16"`), `Fp16` (`"fp16"`), `Fp32` (`"fp32"`), `Fp8` (`"fp8"`), `Fp4` (`"fp4"`) |
| `prompt_tokens` | `u32` | Input token count |
| `completion_tokens` | `u32` | Output token count |
| `started_at_us` | `u64` | Unix timestamp in microseconds when inference started (`Track A` fixes `started_at_us == finished_at_us`) |
| `finished_at_us` | `u64` | Unix timestamp in microseconds when inference finished |
| `activation_hash` | `String` | e.g. `"toploc:NIE_POLICZONY"` |
| `output_digest` | `String` | 64-char hex SHA-256 from `odcisk_wyjscia(job_id, output)` (`"SIMON/OUTPUT/v1"`) |
| `runtime` | `String` | e.g. `"vllm/0.27.1"`, `"ollama/0.5.1"`, `"llama.cpp/1"` (`Track A` adds `/props` detection) |
| `wiazania` | `Option<WiazaniaM1>` | Proof Level 1 token-chain & sampling bindings (`skip_serializing_if = "Option::is_none"`) |
| `signer` | `PublicKey` | 32-byte Ed25519 public key (serialized as 64-char hex) |
| `signature` | `Option<Signature>` | 64-byte Ed25519 signature (serialized as 128-char hex) |

## 2. `WiazaniaM1` (`crates/simon-core/src/receipt.rs`)

| Field Name (Rust & JSON) | Type | Domain / Formula |
| :--- | :--- | :--- |
| `receipt_level` | `u8` | `1` (`RECEIPT_LEVEL_M1`) |
| `schema_version` | `u8` | `1` (`SCHEMA_VERSION_M1`) |
| `runtime` | `String` | Runtime descriptor |
| `tokenizer_hash` | `String` | `odcisk_tokenizera(bytes)` (`"SIMON/TOKENIZER/v1"`) |
| `prompt_digest` | `String` | `odcisk_promptu(tokenizer_hash, client_nonce, prompt_token_ids)` (`"SIMON/PROMPT/v1"`) |
| `token_chain_digest` | `String` | `lancuch_tokenow(&prompt_digest, output_token_ids)` (`"SIMON/CHAIN/v1"` rolling SHA-256 chain) |
| `params_digest` | `String` | `SamplingCommitment::odcisk()` (`"SIMON/SAMPLING/v1"`) |
| `seed` | `u64` | Deterministic sampling seed |

## 3. Key Functions in `crates/simon-core/src/receipt.rs`
- `odcisk_wyjscia(job_id: &str, output: &str) -> Result<String, Error>`
- `odcisk_promptu(tokenizer_hash: &str, client_nonce: &str, prompt_token_ids: &[u32]) -> Result<String, Error>`
- `lancuch_tokenow(prompt_digest: &str, output_token_ids: &[u32]) -> String`
- `odcisk_tokenizera(surowe_bajty_tokenizera: &[u8]) -> Result<String, Error>`
- `Receipt::z_wiazaniem_m1(self, runtime, tokenizer_hash, client_nonce, prompt_token_ids, output_token_ids, params_digest, seed) -> Result<Self, Error>`
- `Receipt::zweryfikuj_m1(&self, oczekiwany_tokenizer_hash, oczekiwany_nonce, prompt_token_ids, output_token_ids) -> Result<(), Error>`
