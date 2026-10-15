# Track A — Fix Node Receipt Metadata Lies, `llama.cpp` Runtime/Tokenize & Signer Verification (`[FZ-A]` · Upstream PR #5)

**Stage:** Stage 1 (Wave 1A — Urgent)  
**Live Upstream PR:** **[Szpili/SIMON PR #5](https://github.com/Szpili/SIMON/pull/5)** (Waiting for Merge)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-A-node-receipt-truth`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_A`  
**Exclusive Permitted Files:**
* `crates/simon-cli/src/node.rs`
* `crates/simon-cli/src/main.rs`

*(100% file-disjoint from Tracks B, C, D, E, and F!)*

---

## Context & Problem Statement

In `crates/simon-cli/src/node.rs`, every signed `Receipt` currently contains factual errors that are visible in `docs/industry/run-3090-mi300x-2026-10-15.jsonl` and `ui/src/lib/industry-run.json`:
1. **`started_at_us == finished_at_us` (`0 µs` duration):** In `zbuduj_podpisany_receipt` (`node.rs:710-755`), `teraz` is sampled once *after* inference finishes and assigned to both `started_at_us` and `finished_at_us` (`L721-724, L740-741`).
2. **Hardcoded `precision: Precision::Fp16` (`node.rs:731`):** Even when the RTX 3090 runs `gemma-4-26b-a4b-it-qat-q4_0` or the AMD MI300X runs `gemma-4-26b-a4b-it-bf16`, the receipt signs `"precision": "fp16"`.
3. **`"runtime": "nieznany/1"` on `llama.cpp` (`node.rs:608-639`):** `wykryj_runtime` checks `/api/version` (Ollama) and `/version` (vLLM), but never checks `llama-server`'s `/props` endpoint.
4. **Broken `/tokenize` Context Gate on `llama-server` (`node.rs:646-704`):** `odczytaj_realny_ctx` sends `{"prompt": prompt}` and looks for `v["count"]`. `llama-server` expects `{"content": prompt}` and returns `{"tokens": [1, 2, ...]}`.
5. **Unchecked Signer Key in `main.rs` (`simon verify`):** `weryfikuj_offline` (`main.rs:346-503`) only calls `r.verify_self()`, never checking `r.signer` against an expected node public key when `--expect-signer <hex_pubkey>` is provided.

---

## Step-by-Step Implementation Instructions (Commit Each Task with `[FZ-A<N>]`)

### Task A1 (`[FZ-A1]`): Record Real `started_at_us` and `finished_at_us` (`crates/simon-cli/src/node.rs`)
1. In `policz` (`node.rs:297-402`), capture `started_at_us` using `SystemTime::now().duration_since(UNIX_EPOCH)` **immediately before** sending the HTTP POST request (`L304`), and capture `finished_at_us` **immediately after** the HTTP response body is received (`L335`). Ensure `finished_at_us = finished_at_us.max(started_at_us)`.
2. Update `zbuduj_podpisany_receipt` (`node.rs:710-755`) signature to accept `started_at_us: u64, finished_at_us: u64` instead of sampling `teraz` inside `zbuduj_podpisany_receipt`.
3. Update all call sites of `zbuduj_podpisany_receipt` inside `node.rs` (including existing tests at the bottom of `node.rs`).

### Task A2 (`[FZ-A2]`): Infer `Precision` from Model Name (`crates/simon-cli/src/node.rs`)
1. Write a pure helper `pub(crate) fn wykryj_precyzje(model_hash: &str) -> Precision` in `node.rs`:
   * Case-insensitive substring check on `model_hash.to_ascii_lowercase()`:
     * If contains `"bf16"` $\rightarrow$ `Precision::Bf16`
     * If contains `"fp8"` or `"q8"` $\rightarrow$ `Precision::Fp8`
     * If contains `"fp4"` or `"q4"` or `"awq"` or `"gptq"` or `"int4"` $\rightarrow$ `Precision::Fp4`
     * If contains `"fp32"` or `"f32"` $\rightarrow$ `Precision::Fp32`
     * Default $\rightarrow$ `Precision::Fp16`
2. Use `wykryj_precyzje(model_hash)` inside `zbuduj_podpisany_receipt` instead of hardcoded `Precision::Fp16`.
3. Add unit test `test_wykryj_precyzje_z_nazwy_modelu` verifying `"gemma-4-26b-a4b-it-bf16"` $\rightarrow$ `Precision::Bf16`, `"gemma-4-26b-a4b-it-qat-q4_0"` $\rightarrow$ `Precision::Fp4`, and `"qwen-q8_0"` $\rightarrow$ `Precision::Fp8`.

### Task A3 (`[FZ-A3]`): Detect `llama.cpp` Runtime in `wykryj_runtime` & Support `llama-server` `/tokenize` (`crates/simon-cli/src/node.rs`)
1. In `wykryj_runtime(model_url: &str)` (`node.rs:608-639`), after checking `/api/version` (Ollama) and `/version` (vLLM), check `GET {baza}/props`:
   * If HTTP 200 and JSON contains `"default_generation_settings"` or `"total_slots"`, return `"llama.cpp/1".to_string()`.
2. In `odczytaj_realny_ctx` (`node.rs:646-704`), send `{"prompt": prompt, "content": prompt}` in the POST body to `/tokenize`.
3. Extract a pure helper `pub(crate) fn wyciagnij_liczbe_tokenow(v: &serde_json::Value) -> Option<u64>` that checks:
   * `v.get("count").and_then(|c| c.as_u64())` (vLLM format), OR
   * `v.get("tokens").and_then(|t| t.as_array()).map(|a| a.len() as u64)` (`llama-server` format).
4. Add unit test `test_tokenize_llama_cpp_format` verifying both `{"count": 42}` and `{"tokens": [10, 20, 30]}`.

### Task A4 (`[FZ-A4]`): Add `--expect-signer <hex_pubkey>` to `crates/simon-cli/src/main.rs`
1. In `crates/simon-cli/src/main.rs`:
   * Add `pub expect_signer: Option<String>` to `struct Opcje` (`L140-192`), initialize to `None`, and parse `--expect-signer` (and `--signer` in `rozwin_podkomende` for `simon verify`) in `Opcje::parse` (`L194-332`).
   * In `weryfikuj_offline` (`L380-405`), if `opcje.expect_signer` is `Some(ref hex_pk)`, verify `r.signer.to_hex().eq_ignore_ascii_case(hex_pk.trim())`, returning a clear error if the signer does not match.
   * Add a unit test in `main.rs` verifying that `Opcje::parse` parses `--expect-signer` and rejects mismatched signer hex.

---

## Granular Commit Plan (Cherry-Pickable by Team Captain)
1. `[FZ-A1] fix(node): populate real started_at_us and finished_at_us in live Receipt`
2. `[FZ-A2] fix(node): infer Receipt Precision from model_hash instead of hardcoded Fp16`
3. `[FZ-A3] fix(node): detect llama.cpp runtime via /props and support llama-server /tokenize`
4. `[FZ-A4] feat(cli): add --expect-signer verification to simon verify`

---

## Verification & PR Delivery
```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh A --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track A
```
