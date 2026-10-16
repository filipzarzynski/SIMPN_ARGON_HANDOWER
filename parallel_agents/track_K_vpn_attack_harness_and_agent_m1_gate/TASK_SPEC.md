# Agent Task Specification: Track K (Stage 3, Wave 3A) — VPN Target Network Attack Harness & Agent M1 Gate (`[FZ-K]`)

**Stage:** Stage 3, Wave 3A (Run AFTER Stage 2 Tracks H, J, G, I are integrated into `fz-contrib`)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-K-vpn-attack-harness-and-agent-m1-gate`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_K`  
**Exclusive Permitted Files:**
* `crates/simon-cli/src/agent.rs`
* `crates/simon-cli/tests/vpn_attack_harness.rs` *(NEW)*

---

## 0. Mandatory Skills to Read First
1. `/home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-captain-review-guardrails/SKILL.md`
2. `/home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-crypto-and-protocol/SKILL.md`

---

## 1. Objective

Directly deliver item **#4** of `docs/STRESS-TESTS.md` (`## Next: A prepared target network for an outside tester (attack the connected nodes, report against this table)`) and close the client-side `agent.rs` M1 downgrade and ledger status gaps:

1. **Harden `agent.rs` Client-Side M1 Verification & Ledger Status (`[FZ-K1]`)**:
   - **Close the M1 Downgrade / Partial-Token Bypass in `zweryfikuj_receipt` (`crates/simon-cli/src/agent.rs` lines 801–835)**:
     - Currently, if a node signs a receipt with `r.poziom() >= 1` (`wiazania.is_some()`), `zweryfikuj_receipt` only calls `r.zweryfikuj_m1(...)` when `m1` (`Some((tok_hash, nonce, p_ids, o_ids))`) is `Some`. If a dishonest node sets `wiazania` in the receipt JSON (`receipt_level: 1`) but omits `prompt_token_ids` or `output_token_ids` in `PromptResponse`, `zweryfikuj_receipt` returns `true` without checking `zweryfikuj_m1`!
     - Fix `zweryfikuj_receipt`: if `r.poziom() >= 1` and `m1.is_none()`, `zweryfikuj_receipt` MUST reject (`return false`) because a receipt claiming Level 1 (`WiazaniaM1`) without accompanying token arrays to verify it against is an incomplete/unverifiable Level 1 claim.
     - Also enforce `simon_harness::request_response::MAX_M1_TOKENS` (`65_536`) client-side in `wyodrebnij_output` / `obsluz_odpowiedz` before hashing token slices.
   - **Record Accurate `StatusWeryfikacji` in `RekordPracyV1` (`agent.rs` line 704)**:
     - Currently line 704 hardcodes `verification_status: StatusWeryfikacji::OutputBound` even when `poziom_dowodu >= 1` (`m1_info.is_some()`) and `prompt_commitment` is known from `rec.wiazania`.
     - Populate `prompt_commitment: rec.wiazania.as_ref().map(|w| w.prompt_digest.clone())` and `tokenizer_manifest_hash: rec.wiazania.as_ref().map(|w| w.tokenizer_hash.clone())`, and keep `StatusWeryfikacji::OutputBound` (since M3 execution audit is not performed inline), adding a unit test verifying `zweryfikuj_receipt` rejects a Level 1 receipt when `m1` is `None`.

2. **Create `crates/simon-cli/tests/vpn_attack_harness.rs` (`[FZ-K2]`)**:
   - An automated, reproducible integration test suite implementing the **"Prepared VPN Target Network Attack Harness"** from `docs/STRESS-TESTS.md` Next #4.
   - Spins up an in-process target network (coordinator + honest node + mock backend + attacker peers) and executes 8 numbered adversarial scenarios mapped directly to `docs/STRESS-TESTS.md` rows, asserting every attack is caught:
     - **Attack 1 (Row 1 & 2 — Output / Receipt Field Tampering):** Attacker flips 1 char of output or 1 `u64` counter after signing $\rightarrow$ rejected by `zweryfikuj_receipt`.
     - **Attack 2 (Row 3 — Rogue Self-Signed Node Key vs Key Pinning):** Rogue node on the VPN signs valid receipt with its own key $\rightarrow$ rejected when client pins `--expect-signer`.
     - **Attack 3 (Row 4 — Replay Old Receipt with Stale Nonce):** Attacker replays a valid Level 1 receipt from an earlier job $\rightarrow$ rejected because client verifies against its own `order.nonce`.
     - **Attack 4 (Row 5 & 6 — Job Replay & Per-Peer Rate Flood):** Attacker replays `(peer, job_id)` and bursts above `--rate-per-peer` $\rightarrow$ rejected with `powtorzony_job` and `rate_limit`.
     - **Attack 5 (Row 7 — Forged Gossip `JobResult` / Wrong Node Key Failure):** Attacker broadcasts a forged failure `SignedJobResult` signed by a different key to degrade an honest node $\rightarrow$ coordinator rejects via `SignedJobResult::verify` and keeps honest node `Healthy`.
     - **Attack 6 (Row 17 — Live M1 Token Chain Tampering & Missing-Token Downgrade):** Dishonest node alters 1 token ID in `output_token_ids` OR sends a Level 1 receipt with `output_token_ids: None` $\rightarrow$ rejected by client.
     - **Attack 7 (Row 18 — Unvouched Sybil Registration Flood):** 20 Sybil nodes broadcast self-signed `RegisterMsg` without an operator `NodeVoucher` to a voucher-enforcing coordinator $\rightarrow$ all 20 rejected, 0 Sybil nodes enter `Registry`.
   - Prints a crisp summary table (`Attack # -> STRESS-TESTS.md Row -> Verdict`) during `cargo test --test vpn_attack_harness`.

---

## 2. Granular Commit Plan (Cherry-Pickable by Team Captain)

1. `[FZ-K1] fix(agent): reject level-1 receipts missing M1 token arrays and populate M1 ledger commitments`
2. `[FZ-K2] test(cli): add vpn_attack_harness.rs reproducing STRESS-TESTS.md adversarial scenarios`

---

## 3. Verification & PR Delivery

```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh K --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track K
```
