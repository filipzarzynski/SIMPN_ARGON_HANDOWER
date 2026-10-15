# Track B — Wire Proof Level 1 (`WiazaniaM1`) Transport, `/tokenize` Helper & Agent Verifier (`PR-2`)

**Stage:** Stage 1 (Wave 1B — Feature)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-B-live-m1-receipts`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_B`  
**Exclusive Permitted Files:**
* `crates/simon-harness/src/request_response.rs`
* `crates/simon-cli/src/wspolne.rs`
* `crates/simon-cli/src/agent.rs`

*(100% file-disjoint from Track A (`node.rs`, `main.rs`) and all other Stage 1 tracks! Stage 2 Track H will connect `node.rs` to `wspolne::tokenizuj_tekst` after Stage 1 merges into `fz-contrib`.)*

---

## Context & Problem Statement

Although `crates/simon-core/src/receipt.rs` implements **Proof Level 1 (`WiazaniaM1`)** (`Receipt::z_wiazaniem_m1`, `Receipt::zweryfikuj_m1`, `odcisk_promptu`, `lancuch_tokenow`, `odcisk_tokenizera`, `SamplingCommitment`), the P2P transport struct `PromptResponse` (`crates/simon-harness/src/request_response.rs:54-69`), shared CLI utilities (`crates/simon-cli/src/wspolne.rs`), and the agent verifier (`crates/simon-cli/src/agent.rs`) have no plumbing to transport or verify Level 1 token chains over the wire!

---

## Step-by-Step Implementation Instructions (Commit Each Task with `[FZ-B<N>]`)

### Task B1 (`[FZ-B1]`): Extend `PromptResponse` with Optional M1 Token Vectors (`crates/simon-harness/src/request_response.rs`)
1. In `struct PromptResponse` (`crates/simon-harness/src/request_response.rs:54-69`), add backward-compatible `#[serde(default, skip_serializing_if = "Option::is_none")]` fields:
   ```rust
   #[serde(default, skip_serializing_if = "Option::is_none")]
   pub tokenizer_hash: Option<String>,
   #[serde(default, skip_serializing_if = "Option::is_none")]
   pub prompt_token_ids: Option<Vec<u32>>,
   #[serde(default, skip_serializing_if = "Option::is_none")]
   pub output_token_ids: Option<Vec<u32>>,
   ```
   Using `#[serde(default, skip_serializing_if = "Option::is_none")]` preserves 100% wire compatibility with existing Level 0 nodes and clients.
2. Update any `PromptResponse { ... }` struct literals in `crates/simon-harness/src/request_response.rs` tests to initialize the new optional fields to `None`, and add a roundtrip CBOR test with `Some(...)` token arrays.

### Task B2 (`[FZ-B2]`): Add `/tokenize` Token Vector Helper & M1 Builder in `crates/simon-cli/src/wspolne.rs`
1. In `crates/simon-cli/src/wspolne.rs`, add:
   * `pub fn wyciagnij_id_tokenow(v: &serde_json::Value) -> Option<Vec<u32>>`: extracts `v.get("tokens").and_then(|t| t.as_array())`, mapping elements via `as_u64().and_then(|x| u32::try_from(x).ok())`, returning `Some(vec)` if non-empty.
   * `pub async fn tokenizuj_tekst(model_url: &str, tekst: &str) -> Option<Vec<u32>>`: derives base URL `{baza}/tokenize` from `model_url` (stripping `/v1/...` or `/api/...`), sends `POST {baza}/tokenize` with `{"prompt": tekst, "content": tekst}` (2-second timeout via `reqwest::Client`), and parses via `wyciagnij_id_tokenow`.
   * `pub fn domyslny_odcisk_tokenizera(model_hash: &str) -> Result<String, simon_core::Error>`: calls `simon_core::receipt::odcisk_tokenizera(model_hash.as_bytes())`.
2. Add unit tests in `crates/simon-cli/src/wspolne.rs` testing `wyciagnij_id_tokenow` and `domyslny_odcisk_tokenizera`.

### Task B3 (`[FZ-B3]`): Verify `zweryfikuj_m1` Automatically in `crates/simon-cli/src/agent.rs`
1. In `crates/simon-cli/src/agent.rs`:
   * Update any `PromptResponse` construction in tests (`agent.rs:860-960`) to include `tokenizer_hash: None, prompt_token_ids: None, output_token_ids: None`.
   * In `zweryfikuj_receipt` / `obsluz_odpowiedz` (`agent.rs:640-760`):
     * When `odpowiedz.tokenizer_hash`, `odpowiedz.prompt_token_ids`, and `odpowiedz.output_token_ids` are `Some(...)` (and `r.poziom() >= 1`), verify:
       ```rust
       r.zweryfikuj_m1(&tok_hash, oczekiwany_nonce, &p_ids, &o_ids)
           .map_err(|e| format!("weryfikacja M1 nie powiodla sie: {e}"))?;
       ```
     * Include `"poziom_dowodu": r.poziom()` in the `--json` stdout output (`agent.rs:665-692`).
   * Add a unit test in `crates/simon-cli/src/agent.rs` constructing a Level 1 `Receipt` via `Receipt::z_wiazaniem_m1` and verifying that `zweryfikuj_receipt` accepts valid M1 bindings and rejects tampered `output_token_ids`.

---

## Granular Commit Plan (Cherry-Pickable by Team Captain)
1. `[FZ-B1] feat(harness): add optional M1 token binding fields to PromptResponse`
2. `[FZ-B2] feat(cli): add tokenizuj_tekst and M1 tokenizer hash helpers in wspolne.rs`
3. `[FZ-B3] feat(agent): verify WiazaniaM1 token chain in agent.rs and report poziom_dowodu`

---

## Verification & PR Delivery
```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh B --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track B
```
