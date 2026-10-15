# Track A — Fix Node Receipt Metadata Lies, `llama.cpp` Runtime/Tokenize & Signer Verification (`PR-1`)

**Branch Name:** `fix/node-receipt-truth`  
**Worktree Path:** `/home/agent/SIMPN_ARGON_HANDOWER/worktrees/track_A`  
**Owned Files:**
* `crates/simon-cli/src/node.rs`
* `crates/simon-cli/src/main.rs`
* `crates/simon-cli/src/agent.rs` (only `--expect-signer` verification in `zweryfikuj_receipt`)

---

## Context & Problem Statement

In `crates/simon-cli/src/node.rs`, every signed `Receipt` currently contains three factual errors that are visible in `docs/industry/run-3090-mi300x-2026-10-15.jsonl` and `ui/src/lib/industry-run.json`:
1. **`started_at_us == finished_at_us` (`0 µs` duration):** In `zbuduj_podpisany_receipt` (`node.rs:710-755`), `teraz` is sampled once *after* inference finishes and assigned to both `started_at_us` and `finished_at_us` (`L721-724, L740-741`).
2. **Hardcoded `precision: Precision::Fp16` (`node.rs:731`):** Even when the RTX 3090 runs `gemma-4-26b-a4b-it-qat-q4_0` or the AMD MI300X runs `gemma-4-26b-a4b-it-bf16`, the receipt signs `"precision": "fp16"`.
3. **`"runtime": "nieznany/1"` on `llama.cpp` (`node.rs:608-639`):** `wykryj_runtime` checks `/api/version` (Ollama) and `/version` (vLLM), but never checks `llama-server`'s `/props` endpoint.
4. **Broken `/tokenize` Context Gate on `llama-server` (`node.rs:646-704`):** `odczytaj_realny_ctx` sends `{"prompt": prompt}` and looks for `v["count"]`. `llama-server` expects `{"content": prompt}` and returns `{"tokens": [1, 2, ...]}`.
5. **Unchecked Signer Key in `agent.rs` & `main.rs`:** `zweryfikuj_receipt` (`agent.rs:729-751`) and `weryfikuj_offline` (`main.rs:346-503`) only call `r.verify_self()`, never checking `r.signer` against an expected node public key when `--expect-signer` is provided.

---

## Step-by-Step Implementation Instructions

### Task A1: Record Real `started_at_us` and `finished_at_us` (`crates/simon-cli/src/node.rs`)
1. In `policz` (`node.rs:297-402`), capture `started_at_us` using `SystemTime::now().duration_since(UNIX_EPOCH)` **immediately before** sending the HTTP POST request (`L310`), and capture `finished_at_us` **immediately after** the HTTP response body is received (`L345`). Ensure `finished_at_us >= started_at_us`.
2. Update `zbuduj_podpisany_receipt` (`node.rs:710-755`) signature to accept `started_at_us: u64, finished_at_us: u64` (and `precision: Precision`) instead of sampling `teraz` inside `zbuduj_podpisany_receipt`.

### Task A2: Infer Precision from Model Name or CLI Flag (`crates/simon-cli/src/node.rs`)
1. Write a pure helper `fn wykryj_precyzje(model_hash: &str) -> Precision` in `node.rs`:
   * Case-insensitive substring check on `model_hash`:
     * If contains `"bf16"` $\rightarrow$ `Precision::Bf16`
     * If contains `"fp8"` or `"q8"` $\rightarrow$ `Precision::Fp8`
     * If contains `"fp4"` or `"q4"` or `"awq"` or `"gptq"` $\rightarrow$ `Precision::Fp4`
     * If contains `"fp32"` or `"f32"` $\rightarrow$ `Precision::Fp32`
     * Default $\rightarrow$ `Precision::Fp16`
2. Pass `wykryj_precyzje(&b.model)` into `zbuduj_podpisany_receipt`.

### Task A3: Detect `llama.cpp` Runtime in `wykryj_runtime` (`crates/simon-cli/src/node.rs:608-639`)
1. In `wykryj_runtime(model_url: &str)` (`L608-639`), after checking `/api/version` (Ollama) and `/version` (vLLM), check `GET {baza}/props`:
   * If HTTP 200 and JSON contains `"default_generation_settings"` or `"total_slots"`, return `"llama.cpp/1".to_string()`.

### Task A4: Support Both vLLM and `llama-server` in `odczytaj_realny_ctx` (`crates/simon-cli/src/node.rs:646-704`)
1. In `odczytaj_realny_ctx`, send `{"prompt": prompt, "content": prompt}` in the POST body to `/tokenize`.
2. When parsing the response `v`:
   * First check `v.get("count").and_then(|c| c.as_u64())` (vLLM format).
   * If `None`, check `v.get("tokens").and_then(|t| t.as_array()).map(|a| a.len() as u64)` (`llama-server` format).

### Task A5: Add `--expect-signer <hex_pubkey>` to `main.rs` and `agent.rs`
1. In `crates/simon-cli/src/main.rs`:
   * Add `pub expect_signer: Option<String>` to `struct Opcje` (`L140-192`) and parse `--expect-signer` in `Opcje::parse` (`L194-332`) and `rozwin_podkomende` (`L509-558`).
   * In `weryfikuj_offline` (`L380-395`), if `opcje.expect_signer` is `Some(ref hex_pk)`, verify `r.signer.to_hex() == hex_pk.to_lowercase()`.
2. In `crates/simon-cli/src/agent.rs`:
   * In `zweryfikuj_receipt`, if `opcje.expect_signer` is provided, verify `r.signer.to_hex()` matches before accepting the receipt.

---

## Verification & Unit Tests to Add
Add unit tests in `crates/simon-cli/src/node.rs`:
* `test_wykryj_precyzje_z_nazwy_modelu`: verifies `"gemma-4-26b-a4b-it-bf16"` $\rightarrow$ `Precision::Bf16`, `"gemma-4-26b-a4b-it-qat-q4_0"` $\rightarrow$ `Precision::Fp4`, `"qwen-q8_0"` $\rightarrow$ `Precision::Fp8`.
* `test_receipt_czas_trwania_niezerowy`: verifies `finished_at_us >= started_at_us` and that `started_at_us` reflects pre-request time.
* `test_tokenize_llama_cpp_format`: verifies `{"tokens": [10, 20, 30]}` parses as `Some(3)`.

Run:
```bash
cargo test -p simon-cli
python3 scripts/wartownik_stalych.py
```
