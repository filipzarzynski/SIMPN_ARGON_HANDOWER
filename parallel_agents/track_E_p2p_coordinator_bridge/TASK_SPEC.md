# Agent Task Specification: Track E — P2P Coordinator-to-Node Bridge & MapReduce Truthfulness (`PR-5`)

**Target Branch:** `feat/coordinator-gossipsub-bridge`
**Assigned Role:** P2P Networking & MapReduce Engineer (Gemini 3.8 Flash High)
**Estimated Time:** ~2–3 hours
**Prerequisite Reading:** [`../AGENT_RULES_COMMON.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/AGENT_RULES_COMMON.md), [`../../01_ARCHITECTURE_AND_DATA_FLOWS.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/01_ARCHITECTURE_AND_DATA_FLOWS.md)

---

## 1. Objective

Resolve the "Two Disconnected Worlds" architectural gap (`BUG-07`) and the `mapreduce.rs` silent truncation bug (`BUG-08`):
1. **`BUG-07` (`crates/simon-cli/src/coord.rs` & `crates/simon-node/src/lib.rs`):** Currently, `simon coord` runs [`AcpServer`](file:///home/agent/SIMON/crates/simon-harness/src/acp_server.rs#L102-L321), which requires connected libp2p peers to publish Gossipsub `simon/v0/orders` announcements and respond on `/simon/req/1.0.0`. Meanwhile, `simon node` ([`node.rs`](file:///home/agent/SIMON/crates/simon-cli/src/node.rs#L1-L820)) never uses `simon-node`'s [`SimonNode`](file:///home/agent/SIMON/crates/simon-node/src/lib.rs#L97-L295) or Gossipsub. We want to add a real LLM backend option to `simon coord` or bridge `SimonNode` in `crates/simon-node/src/lib.rs` to an HTTP `llama-server` backend so `simon coord` can execute end-to-end against real LLM workers instead of `mock_executor`.
2. **`BUG-08` (`crates/simon-cli/src/mapreduce.rs`):** Fix [`mapreduce.rs:88`](file:///home/agent/SIMON/crates/simon-cli/src/mapreduce.rs#L85-L95) where `przeplyw.zbierz()` silently truncates outputs once `min_odpowiedzi` (`1`) is reached, even when 3+ map chunks were submitted, and add real fan-out option or multi-chunk aggregation.

---

## 2. Permitted Files (Strict Scope)

You may **ONLY** modify:
- `crates/simon-cli/src/coord.rs`
- `crates/simon-cli/src/mapreduce.rs`
- `crates/simon-node/src/lib.rs`

Do **NOT** modify `crates/simon-cli/src/node.rs`, `crates/simon-cli/src/agent.rs`, or `crates/simon-core/*`.

---

## 3. Exact Findings & Line Numbers to Fix

### Task E.1: Fix `mapreduce.rs` Silent Truncation (`BUG-08`)
Inspect [`crates/simon-cli/src/mapreduce.rs:70-120`](file:///home/agent/SIMON/crates/simon-cli/src/mapreduce.rs#L70-L120):
- At line 88:
  ```rust
  let mut przeplyw = PrzeplywMapReduce::nowy(id_zadania, 1, Duration::from_secs(30))?;
  ```
  Because `min_odpowiedzi` is hardcoded to `1`, and [`PrzeplywMapReduce::zbierz`](file:///home/agent/SIMON/crates/simon-core/src/przeplyw.rs#L168-L195) truncates `poprawne` to `min_odpowiedzi`, a 3-chunk MapReduce job discards chunks 2 and 3!
- **Fix:**
  1. Pass `czesci.len().max(1)` (the actual number of map chunks) as `min_odpowiedzi` to `PrzeplywMapReduce::nowy(id_zadania, czesci.len().max(1), Duration::from_secs(30))`.
  2. Ensure each map chunk gets a deterministic, distinct `id_zlecenia` or chunk index so all valid chunk responses are collected and concatenated in order before the Reduce summary.
  3. Add a unit test in `crates/simon-cli/src/mapreduce.rs` verifying that a 3-chunk input retains all 3 map chunk outputs in the final `PrzeplywMapReduce::zbierz` result.

### Task E.2: Add HTTP Backend Executor to `SimonNode` (`BUG-07`)
Inspect [`crates/simon-node/src/lib.rs:64-95`](file:///home/agent/SIMON/crates/simon-node/src/lib.rs#L64-L95) and [`crates/simon-cli/src/coord.rs:1-85`](file:///home/agent/SIMON/crates/simon-cli/src/coord.rs#L1-L85):
- Currently, `SimonNode` only exposes `mock_executor`, which returns `ECHO(model): prompt`.
- **Fix:**
  1. In `crates/simon-node/src/lib.rs`, add an HTTP executor builder (or async callback mechanism / `ureq` or `reqwest` or `tokio::net::TcpStream` HTTP call to `llama-server` `/v1/completions`) so a `SimonNode` instance can optionally forward incoming `/simon/req/1.0.0` `RequestPayload` prompts to a local `http://127.0.0.1:8080/v1/completions` endpoint and return a signed `ResponsePayload` with the real completion and `Receipt`.
  2. In `crates/simon-cli/src/coord.rs`, add an optional `--spawn-local-worker <HTTP_URL>` (or `--local-worker-model <MODEL>`) flag that spawns an in-process `SimonNode` connected to the coordinator swarm, allowing `simon coord` to be demonstrated end-to-end out of the box without separate test harnesses.

---

## 4. Verification Commands

Run inside your worktree:
```bash
export PATH="/home/agent/.cargo/bin:$PATH"
cargo test -p simon-node -p simon-cli
cargo clippy -p simon-node -p simon-cli -- -D warnings
```
