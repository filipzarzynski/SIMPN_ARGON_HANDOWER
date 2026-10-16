# Agent Task Specification: Track H (Stage 2, Wave 2A) — Live M1 Token Binding with Length Caps & E2E Test ([FZ-H])

**Stage & Wave:** Stage 2 — Wave 2A (Urgent Protocol Closing — `docs/STRESS-TESTS.md` Next #2)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-H-e2e-integration-and-live-m1-bridge`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_H`  
**Exclusive Permitted Files:**
* `crates/simon-cli/src/wspolne.rs`
* `crates/simon-cli/src/node.rs`
* `crates/simon-cli/tests/e2e_m1_receipt.rs` *(NEW)*

---

## 1. Objective (`docs/STRESS-TESTS.md` Next #2)

In `docs/STRESS-TESTS.md`, the Team Captain (`Szpili`) listed under `## Next (owner in the team channel)`:
> `2. Wire live M1: node tokenizes prompt and output via the backend, sends ids with length caps.`

In Stage 1, `Track B` added optional M1 token fields (`tokenizer_hash`, `prompt_token_ids`, `output_token_ids`) to `PromptResponse`, helper functions (`wyciagnij_id_tokenow`, `tokenizuj_tekst`, `domyslny_odcisk_tokenizera`) to `crates/simon-cli/src/wspolne.rs`, and `poziom_sprawdzony` client verification to `crates/simon-cli/src/agent.rs`. However, `policz()` in `crates/simon-cli/src/node.rs` (lines 441–468) still sets `wiazania: None` and leaves `tokenizer_hash`, `prompt_token_ids`, and `output_token_ids` as `None`.

Your task is to wire live M1 tokenization in `wspolne.rs` and `node.rs` with **strict length caps (`MAX_M1_TOKENS = 65_536`)** and **conservative fallback** (never sign a guessed or partial M1 claim!), and prove the full pipeline in `crates/simon-cli/tests/e2e_m1_receipt.rs`.

---

## 2. Mandatory Captain Guardrails for Track H

Read [`.agents/skills/simon-captain-review-guardrails/SKILL.md`](../../.agents/skills/simon-captain-review-guardrails/SKILL.md) before writing code:
1. **Never Sign a Guess or Partial M1 Claim**:
   - Only attach `WiazaniaM1` (`receipt.z_wiazaniem_m1(...)`) when **ALL** of the following hold:
     - `!req.chat` (text mode — in chat mode `req.prompt` is a JSON envelope, not raw text),
     - `!req.nonce.trim().is_empty()`,
     - `/tokenize` returned `Some(p_ids)` and `Some(o_ids)` that are both **non-empty** and **`<= MAX_M1_TOKENS`** (`65_536`),
     - `domyslny_odcisk_tokenizera(model_hash)` and `SamplingCommitment::greedy().odcisk()` both succeeded.
   - If ANY check above does not hold (e.g., backend does not expose `/tokenize`, or returns `> MAX_M1_TOKENS` tokens, or job is in chat mode), **fall back cleanly to Level 0**: `wiazania: None`, and set `tokenizer_hash: None, prompt_token_ids: None, output_token_ids: None` in `PromptResponse`.
2. **Length Caps (`MAX_M1_TOKENS = 65_536`)**:
   - Define `pub const MAX_M1_TOKENS: usize = 65_536;` in `crates/simon-cli/src/wspolne.rs`.
   - In `wyciagnij_id_tokenow(v: &serde_json::Value) -> Option<Vec<u32>>`, reject arrays where `arr.is_empty()` OR `arr.len() > MAX_M1_TOKENS`, and require every element in `arr` to be a valid `u32` (`if ids.len() != arr.len() { return None; }` — never silently drop invalid non-integer elements from the middle of a token sequence!).
3. **Forward `SIMON_MODEL_API_KEY` in `tokenizuj_tekst`**:
   - Ensure `tokenizuj_tekst` includes the `SIMON_MODEL_API_KEY` Bearer header if present in the environment (matching `klient_backendu()` in `node.rs`).
   - Remove `#[allow(dead_code)]` from `wyciagnij_id_tokenow`, `tokenizuj_tekst`, and `domyslny_odcisk_tokenizera` in `wspolne.rs` once wired into `node.rs`.

---

## 3. Granular Commit Plan (3 Atomic Commits)

### Commit 1: `[FZ-H1] fix(cli): enforce MAX_M1_TOKENS cap and strict array parsing in wspolne::tokenizuj_tekst`
- **File**: `crates/simon-cli/src/wspolne.rs`
- Define `pub const MAX_M1_TOKENS: usize = 65_536;`.
- Update `wyciagnij_id_tokenow`:
  - Return `None` if `arr.is_empty() || arr.len() > MAX_M1_TOKENS`.
  - Use `.map(|x| x.as_u64().and_then(|n| u32::try_from(n).ok())).collect::<Option<Vec<u32>>>()` so any non-`u32` element rejects the array instead of silently skipping tokens!
- Update `tokenizuj_tekst` to attach `Authorization: Bearer <SIMON_MODEL_API_KEY>` when `std::env::var("SIMON_MODEL_API_KEY")` is non-empty.
- Update unit tests in `wspolne.rs` (`test_wyciagnij_id_tokenow`) to verify that mixed/invalid elements (`["invalid", 42]`) and oversized arrays (`> MAX_M1_TOKENS`) return `None`.

### Commit 2: `[FZ-H2] feat(node): wire live M1 token commitments with length caps in node::policz`
- **Files**: `crates/simon-cli/src/node.rs`, `crates/simon-cli/src/wspolne.rs`
- Remove `#[allow(dead_code)]` from the M1 helpers in `wspolne.rs`.
- In `crates/simon-cli/src/node.rs` (`policz` and `zbuduj_podpisany_receipt`):
  - For `!req.chat && !req.nonce.trim().is_empty()`, call `crate::wspolne::tokenizuj_tekst(model_url, &req.prompt).await` and `crate::wspolne::tokenizuj_tekst(model_url, &output).await`.
  - When both return `Some(p_ids)` and `Some(o_ids)` (within `MAX_M1_TOKENS`), compute `tok_hash = crate::wspolne::domyslny_odcisk_tokenizera(model_hash)` and `params_hash = simon_core::receipt::SamplingCommitment::greedy().odcisk()`.
  - Pass optional M1 binding data `m1_dane: Option<(&str, &[u32], &[u32])>` into `zbuduj_podpisany_receipt` so `receipt.z_wiazaniem_m1(tok_hash.to_string(), req.nonce.clone(), p_ids, o_ids, params_hash, 0, format!("{runtime}/{:?}", precision).to_lowercase())` is applied **before** `receipt.sign(klucz)`.
  - Only populate `tokenizer_hash`, `prompt_token_ids`, and `output_token_ids` on `PromptResponse` when the signed receipt actually contains `wiazania.is_some()`.
- Add unit tests in `node.rs::testy_receiptu` verifying both Level 1 receipt construction (when M1 token slices are provided) and Level 0 fallback (when `None`).

### Commit 3: `[FZ-H3] test(cli): add E2E live M1 receipt generation and tamper verification test suite`
- **File**: `crates/simon-cli/tests/e2e_m1_receipt.rs` *(NEW)*
- Spin up an in-process mock HTTP backend handling `/v1/models`, `/version`, `/tokenize`, and `/v1/chat/completions`.
- Test 4 scenarios end-to-end:
  1. **Honest M1 Flow**: Node with `/tokenize` produces a signed receipt with `poziom() == 1` and `PromptResponse` carries `tokenizer_hash`, `prompt_token_ids`, and `output_token_ids`. Client `Receipt::zweryfikuj_m1` passes with the order's `nonce` and verifies `zgodny_z_wyjsciem`.
  2. **Tampered Output Token IDs Rejected**: Flipping 1 token ID in `output_token_ids` causes `zweryfikuj_m1` to fail (`Err`).
  3. **Wrong Client Nonce Rejected**: Verifying against a different `nonce` fails (`Err`).
  4. **Fallback to M0 When `/tokenize` Unavailable or Over Cap**: When `/tokenize` returns HTTP 404 or an invalid array, the node cleanly signs a valid Level 0 receipt (`poziom() == 0`, `verify_self().is_ok()`) with `tokenizer_hash: None`.

---

## 4. Verification Requirements

```bash
export PATH="/home/agent/.cargo/bin:$PATH"
bash /home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-verify-suite/scripts/verify_track.sh H --final
python3 /home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track H
```
