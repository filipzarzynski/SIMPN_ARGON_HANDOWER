# Track E — Fix P2P Coordinator VRF Selection, Registry Assignment Lifecycle & MapReduce Context Budgeting (`PR-5`)

**Stage:** Stage 1 (Wave 1B — Feature)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-E-coordinator-gossipsub-bridge`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_E`  
**Exclusive Permitted Files:**
* `crates/simon-node/src/lib.rs`
* `crates/simon-cli/src/coord.rs`
* `crates/simon-cli/src/mapreduce.rs`

*(100% file-disjoint from all other Stage 1 tracks!)*

---

## Context & Problem Statement

In `crates/simon-node/src/lib.rs`, `crates/simon-cli/src/coord.rs`, and `crates/simon-cli/src/mapreduce.rs`:
1. **`Registry` Missing VRF Selection & Degraded State (`crates/simon-node/src/lib.rs:95-210`):**
   * `NodeState::Degraded` (`L75`) is defined on the enum with a `#[allow(dead_code)]` annotation because no `mark_degraded` method exists on `Registry`!
   * `Registry` has `kandydaci_dla_modelu` (`L137-166`), which always returns candidates in alphabetical `BTreeMap` key order (`node_id`), meaning `coord.rs` (`L137`) always picks the lexicographically first `node_id` (`kandydaci.first()`) instead of using a deterministic hash-based VRF seed selection!
2. **`coord.rs` Hardcodes `wymagany_ctx = 0`, `"vrf-mvp"`, and Never Calls `rejestr.assign` or Handles `TOPIC_JOB_RESULT` (`crates/simon-cli/src/coord.rs:108-174`):**
   * At `coord.rs:116`, the coordinator only subscribes to `TOPIC_REGISTER` and `TOPIC_JOB_ORDER`, ignoring `TOPIC_JOB_RESULT`!
   * At `coord.rs:135`, `rejestr.kandydaci_dla_modelu(&order.model_hash, 0)` passes `wymagany_ctx = 0`.
   * At `coord.rs:137-159`, `coord.rs` picks `kandydaci.first()`, never calls `rejestr.assign(&order.job_id, wybrany)`, and hardcodes `vrf_seed: "vrf-mvp".into()`.
3. **`mapreduce.rs` Token Estimation Uses Naive Byte Division (`crates/simon-cli/src/mapreduce.rs:8-75`):**
   * `grupuj_do_budzetu` (`L52`) estimates tokens as `k.len() / 4` without accounting for non-ASCII / Polish UTF-8 multibyte characters or whitespace word boundaries.

---

## Step-by-Step Implementation Instructions (Commit Each Task with `[FZ-E<N>]`)

### Task E1 (`[FZ-E1]`): Add `mark_degraded`, `active_assignments`, and Deterministic VRF Selection to `Registry` (`crates/simon-node/src/lib.rs`)
1. In `crates/simon-node/src/lib.rs`:
   * Remove `#[allow(dead_code)]` above `Degraded` (`L74`) and add `pub fn mark_degraded(&mut self, node_id: &str) -> Result<(), Error>` on `Registry` that sets `wpis.state = NodeState::Degraded`. Update `kandydaci_dla_modelu` (`L137-166`) so nodes in `NodeState::Degraded` or `NodeState::Offline` are excluded from active candidate selection unless recovered via `heartbeat`.
   * Add `pub fn wybierz_kandydata_vrf(&self, model_hash: &str, wymagany_ctx: u32, job_id: &str, teraz_s: u64) -> Option<(String, String)>` on `Registry`:
     * Calls `self.kandydaci_dla_modelu(model_hash, wymagany_ctx)` (filtering out stale nodes via `self.timeout_s`).
     * Computes a deterministic VRF seed `vrf_seed = simon_core::content_digest("SIMON/VRF/v1", &(model_hash, job_id)).ok()?`.
     * Selects the candidate whose `content_digest("SIMON/VRF-PICK/v1", &(&vrf_seed, &cand.node_id))` is lexicographically smallest, returning `Some((wybrany_node_id, vrf_seed))`.
   * Add unit tests in `crates/simon-node/src/lib.rs` verifying `mark_degraded` exclusions and deterministic VRF candidate distribution across multiple registered nodes.

### Task E2 (`[FZ-E2]`): Wire Real VRF Seed, `rejestr.assign()`, and `TOPIC_JOB_RESULT` Completion in `crates/simon-cli/src/coord.rs`
1. In `crates/simon-cli/src/coord.rs`:
   * Import `TOPIC_JOB_RESULT` from `simon_harness::transport` and `JobResult` from `simon_node`.
   * Subscribe `swarm.behaviour_mut().gossipsub` to `IdentTopic::new(TOPIC_JOB_RESULT)` (`L116`).
   * When handling `TOPIC_JOB_ORDER` (`L132-169`):
     * Estimate required context tokens from `order.prompt_hash` / minimum 512 tokens (`let wymagany_ctx = 512;`, falling back to `0` if no node reports `max_ctx >= 512`).
     * Use `rejestr.wybierz_kandydata_vrf(&order.model_hash, wymagany_ctx, &order.job_id, teraz_sekundy())` (falling back to `wymagany_ctx = 0` if empty).
     * Call `let _ = rejestr.assign(&order.job_id, &wybrany_node);` before publishing `JobAssignment` with the real `vrf_seed`!
   * When handling `TOPIC_JOB_RESULT`:
     * Parse `JobResult` from `msg.data` and call `let _ = rejestr.complete(&res.job_id);` (or `rejestr.mark_degraded(&res.node_id)` if `res.output_digest.is_empty()`).
   * Add unit tests in `crates/simon-cli/src/coord.rs` verifying the coordinator's `Registry` assignment and `JobResult` completion lifecycle.

### Task E3 (`[FZ-E3]`): Improve `mapreduce.rs` Token Estimation & Add Multibyte / Chunk-Order Tests (`crates/simon-cli/src/mapreduce.rs`)
1. In `crates/simon-cli/src/mapreduce.rs`:
   * Add a helper `pub fn oszacuj_tokeny(tekst: &str) -> usize` that estimates token count using `tekst.chars().count().div_ceil(4).max(tekst.split_whitespace().count())` and use it in `grupuj_do_budzetu` (`L52`) instead of raw byte length `k.len() / 4`.
   * Add unit tests in `crates/simon-cli/src/mapreduce.rs` verifying `oszacuj_tokeny`, UTF-8 multibyte chunking in `podziel_na_kawalki`, and multi-batch order preservation in `grupuj_do_budzetu`.

---

## Granular Commit Plan (Cherry-Pickable by Team Captain)
1. `[FZ-E1] feat(node): add mark_degraded and deterministic VRF candidate selection to Registry`
2. `[FZ-E2] fix(coord): wire VRF seed, rejestr.assign, and TOPIC_JOB_RESULT handling in coord.rs`
3. `[FZ-E3] fix(mapreduce): improve UTF-8 token budget estimation and add chunking tests`

---

## Verification & PR Delivery
```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh E --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track E
```
