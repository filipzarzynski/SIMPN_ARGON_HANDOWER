# Agent Task Specification: Track H (Stage 2) — Live Node-to-Agent M1 Integration & E2E Test (`PR-8`)

**Stage:** Stage 2 (Run AFTER Stage 1 Tracks A, B, and D are integrated into `fz-contrib`)
**Target Base Branch:** `fz-contrib` (NEVER `main`)
**Dedicated Track Branch:** `fz/track-H-e2e-integration-and-live-m1-bridge`
**Assigned Role:** Rust Systems Integration Engineer (Gemini 3.8 Flash High)
**Prerequisite Reading:** [`../AGENT_RULES_COMMON.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/AGENT_RULES_COMMON.md), [`../track_A_receipt_and_node_truth/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_A_receipt_and_node_truth/TASK_SPEC.md), [`../track_B_live_m1_token_binding/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_B_live_m1_token_binding/TASK_SPEC.md)

---

## 1. Objective

In Stage 1, Track A updated `crates/simon-cli/src/node.rs` (fixing `timestamp_us`, dynamic GGUF precision, and GGUF SHA-256 verification) while Track B added `zbuduj_zobowiazania_tokenow` in `crates/simon-cli/src/wspolne.rs` and M1 verification in `crates/simon-cli/src/agent.rs`.
Now that both are on `fz-contrib`, Track H connects them in `node.rs` and adds a dedicated E2E integration test:
1. **Wire `wspolne::zbuduj_zobowiazania_tokenow` into `node.rs` (`[FZ-H1]`)**:
   - In `crates/simon-cli/src/node.rs`, when building the `Receipt` from `OdpowiedzLlm`, call `crate::wspolne::zbuduj_zobowiazania_tokenow(&odp_llm.tokeny, &odp_llm.logproby)` and, if non-empty, attach `.z_zobowiazaniami_m1(zobowiazania_m1)` to `BudowniczyReceipt`.
2. **Add End-to-End Integration Test (`crates/simon-cli/tests/e2e_m1_receipt.rs`) (`[FZ-H2]`)**:
   - Create an integration test that constructs a live node response with token logprobs, builds and signs the `Receipt` with both M0 and M1 commitments + real Unix timestamp + dynamic precision, and verifies that `Receipt::zweryfikuj_m1()` and `Receipt::zweryfikuj()` pass and reject 1-bit tampering in any token commitment.

---

## 2. Permitted Files (Strict Scope)

You may **ONLY** modify or create:
- `crates/simon-cli/src/node.rs`
- `crates/simon-cli/tests/e2e_m1_receipt.rs`

---

## 3. Granular Commit Plan (Cherry-Pickable by Team Captain)

1. `[FZ-H1] feat(node): attach M1 token commitments from wspolne::zbuduj_zobowiazania_tokenow in live node Receipt`
2. `[FZ-H2] test(cli): add e2e_m1_receipt integration test verifying M0+M1 receipt lifecycle`

---

## 4. Verification & PR Delivery

```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh H --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track H
```
