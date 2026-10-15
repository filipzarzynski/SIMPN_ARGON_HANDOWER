# SIMON Polish/English Serde Map & Binary Layouts

## 1. `Receipt` (`crates/simon-core/src/receipt.rs`)

| Rust Identifier (Polish) | JSON Wire Name (`#[serde(rename)]`) | Type | Notes |
| :--- | :--- | :--- | :--- |
| `wersja` | `version` | `u32` | Always `1` (`WERSJA_RECEIPT`) |
| `id_zlecenia` | `order_id_hex` | `Skrot32` | 64-char hex |
| `wykonawca` | `executor_pubkey_hex` | `KluczPubliczny` | 64-char Ed25519 pubkey hex |
| `skrot_wag` | `weights_hash_hex` | `Skrot32` | `SIMON-WEIGHTS-v1` hash of GGUF SHA-256 |
| `skrot_konfiguracji` | `backend_config_hash_hex` | `Skrot32` | `SIMON-CONFIG-v1` hash |
| `skrot_promptu` | `prompt_hash_hex` | `Skrot32` | `SIMON-PROMPT-v1` hash |
| `skrot_wyjscia` | `output_hash_hex` | `Skrot32` | `SIMON-OUTPUT-v1` hash |
| `liczba_tokenow_wejscia` | `prompt_tokens` | `u32` | Input token count |
| `liczba_tokenow_wyjscia` | `completion_tokens` | `u32` | Output token count |
| `czas_wykonania_us` | `timestamp_us` | `u64` | Unix timestamp in microseconds (`Track A` fixes hardcoded `0`) |
| `zobowiazania_tokenow` | `token_commitments` | `Vec<TokenCommitment>` | M1 per-token commitments (`Track B` populates in live node) |
| `skrot_zobowiazan_tokenow` | `token_commitments_root_hex` | `Option<Skrot32>` | M1 root (`SIMON-M1-ROOT-v1`) |
| `zobowiazania_logprobow` | `logprob_commitments` | `Vec<ZobowiazanieLogproba>` | M3 logprob commitments |
| `skrot_zobowiazan_logprobow` | `logprob_commitments_root_hex` | `Option<Skrot32>` | M3 root |
| `skrot_ladunku` | `payload_hash_hex` | `Skrot32` | `SIMON-RECEIPT-v1` hash |
| `podpis_wykonawcy` | `signature_hex` | `Option<Podpis>` | 128-char Ed25519 signature hex |

## 2. `TokenCommitment` (`crates/simon-core/src/receipt.rs`)

Binary preimage hashed with `DOMENA_M1_TOKEN` (`"SIMON-M1-TOKEN-v1"`):
- `indeks.to_le_bytes()` (`u32`, 4 bytes LE)
- `id_tokenu.to_le_bytes()` (`u32`, 4 bytes LE)
- `(tekst.len() as u32).to_le_bytes()` (`u32`, 4 bytes LE)
- `tekst.as_bytes()` (UTF-8 bytes)
- `logprob_q16.to_le_bytes()` (`i32`, 4 bytes LE, where `q16 = (logprob_f32 * 65536.0).round() as i32`)
- `skrot_kandydatow` (`32` bytes: `BLAKE3` of canonical sorted top-k candidate pairs, or `[0u8; 32]` if empty)
