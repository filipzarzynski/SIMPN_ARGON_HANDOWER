# Agent Task Specification: Track H (Stage 2) — Live Node-to-Agent M1 Integration & E2E Test (`PR-8`)

**Stage:** Stage 2 (Run AFTER Stage 1 Tracks A, B, and D are integrated into `fz-contrib`)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-H-e2e-integration-and-live-m1-bridge`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_H`  
**Exclusive Permitted Files:**
* `crates/simon-cli/src/node.rs`
* `crates/simon-cli/tests/e2e_m1_receipt.rs`

---

## 1. Objective

In Stage 1:
- **Track A** updated `crates/simon-cli/src/node.rs` (fixing `started_at_us`/`finished_at_us`, `wykryj_precyzje`, `llama.cpp` `/props` runtime detection, and `llama-server` `/tokenize` parsing).
- **Track B** extended `PromptResponse` (`tokenizer_hash`, `prompt_token_ids`, `output_token_ids`), added `wspolne::tokenizuj_tekst` and `wspolne::domyslny_odcisk_tokenizera` in `crates/simon-cli/src/wspolne.rs`, and wired `r.zweryfikuj_m1(...)` in `crates/simon-cli/src/agent.rs`.
- **Track D** hardened `Receipt::zweryfikuj_m1` in `crates/simon-core/src/receipt.rs` to require a valid Ed25519 signature (`self.verify_self()?`).

Now that Tracks A, B, and D are merged onto `fz-contrib`, **Track H** connects `node.rs` to `wspolne::tokenizuj_tekst` and `Receipt::z_wiazaniem_m1`, and adds an end-to-end integration test:
1. **Wire `wspolne::tokenizuj_tekst` & `Receipt::z_wiazaniem_m1` into `crates/simon-cli/src/node.rs` (`[FZ-H1]`)**:
   - In `policz` (`crates/simon-cli/src/node.rs`), attempt to tokenize both `req.prompt` and `output` using `crate::wspolne::tokenizuj_tekst(&b.url, ...)`.
   - When both return `Some(p_ids)` and `Some(o_ids)`:
     - Compute `tok_hash = crate::wspolne::domyslny_odcisk_tokenizera(&b.model)?` and `params_digest = simon_core::receipt::SamplingCommitment::greedy().odcisk()?`.
     - Attach `.z_wiazaniem_m1(format!("{}/{}", b.runtime, b.model), &tok_hash, &req.nonce, &p_ids, &o_ids, &params_digest, 42)?` to the `Receipt` before `.sign(&b.klucz)`!
     - Populate `tokenizer_hash: Some(tok_hash)`, `prompt_token_ids: Some(p_ids)`, and `output_token_ids: Some(o_ids)` on the returned `PromptResponse`.
   - When `/tokenize` is unavailable or returns `None`, gracefully fall back to Proof Level 0 (`wiazania: None`).
2. **Add End-to-End Integration Test (`crates/simon-cli/tests/e2e_m1_receipt.rs`) (`[FZ-H2]`)**:
   - Create `crates/simon-cli/tests/e2e_m1_receipt.rs` testing the complete M0 + M1 `Receipt` lifecycle (`Receipt::z_wiazaniem_m1` $\rightarrow$ `.sign(&klucz)` $\rightarrow$ `r.verify_self()` $\rightarrow$ `r.zgodny_z_wyjsciem()` $\rightarrow$ `r.zweryfikuj_m1()`), including tamper rejection when any token ID in `output_token_ids` or `signature` is modified.

---

## 2. Granular Commit Plan (Cherry-Pickable by Team Captain)

1. `[FZ-H1] feat(node): attach live WiazaniaM1 token chain in policz when /tokenize returns token IDs`
2. `[FZ-H2] test(cli): add e2e_m1_receipt integration test verifying M0+M1 receipt lifecycle`

---

## 3. Verification & PR Delivery

```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh H --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track H
```
