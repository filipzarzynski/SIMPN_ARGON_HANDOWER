# Multi-Agent Orchestrator Guide (For Gemini 3.8 Flash High Coding Agents in Antigravity)

This directory (`/home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/`) is structured specifically so an orchestrator agent or human developer can launch **up to 6 parallel Gemini 3.8 Flash High coding agents** in Antigravity without merge conflicts, context bloat, or hallucinated assumptions.

---

## 1. How Work Is Partitioned for Zero-Conflict Parallelism

Flash-tier coding agents perform best when:
1. Every task has an **explicit list of owned files** (and an explicit list of **off-limits files**).
2. Every bug/feature has **exact line numbers, current code snippets, and target replacement behavior**.
3. Each parallel agent works in an **isolated `git worktree`** (or Antigravity `Workspace: "share"` / `"branch"` subagent mode) on its own feature branch.

| Track Folder | Branch Name | Owned Files (Exclusive Write Scope) | Can Run in Parallel With |
| :--- | :--- | :--- | :--- |
| **`track_A_receipt_and_node_truth`** | `fix/node-receipt-truth` | `crates/simon-cli/src/node.rs`<br>`crates/simon-cli/src/main.rs` | Tracks C, D, E, F (Run Track B *after* Track A or merge A into B) |
| **`track_B_live_m1_token_binding`** | `feat/live-m1-receipts` | `crates/simon-harness/src/request_response.rs`<br>`crates/simon-cli/src/node.rs`<br>`crates/simon-cli/src/agent.rs` | Tracks C, D, E, F (Depends on or subsumes Track A in `node.rs`) |
| **`track_C_industry_gemma4_live_agent`** | `feat/industry-m7-agent` | `tools/simon-industry/*`<br>`ui/src/routes/industry/+page.svelte` | Tracks A, B, D, E |
| **`track_D_core_security_and_wasm_fixes`** | `fix/core-security-hardening` | `crates/simon-core/src/*`<br>`crates/simon-core/tests/*`<br>`crates/simon-verify-wasm/src/lib.rs` | Tracks A, B, C, E, F (100% disjoint from CLI, Harness, Tools, and UI!) |
| **`track_E_p2p_coordinator_bridge`** | `feat/coordinator-gossipsub-bridge` | `crates/simon-harness/src/acp_server.rs`<br>`crates/simon-harness/src/client_protocol.rs`<br>`crates/simon-node/src/lib.rs`<br>`crates/simon-cli/src/coord.rs` | Tracks A, B, C, D, F (100% disjoint!) |
| **`track_F_submission_and_ui_polish`** | `fix/submission-and-ui-polish` | `docs/zgloszenie/LABLAB-SUBMISSION.md`<br>`ui/src/lib/components/VerifierPanel.svelte`<br>`ui/src/lib/components/NodePanel.svelte` | Tracks A, B, D, E |

---

## 2. How to Spawn Parallel Agents in Antigravity

### Option A: Using Antigravity's `invoke_subagent` Tool (`Workspace: "share"` or `git worktree`)
If you are an orchestrator agent inside Antigravity, you can spawn Wave 1 + Wave 2 agents concurrently in a single `invoke_subagent` tool call, or create git worktrees under `/home/agent/SIMPN_ARGON_HANDOWER/worktrees/`:

```bash
# Create isolated git worktrees so /home/agent/SIMON stays untouched on main!
mkdir -p /home/agent/SIMPN_ARGON_HANDOWER/worktrees
git -C /home/agent/SIMON worktree add -b fix/node-receipt-truth /home/agent/SIMPN_ARGON_HANDOWER/worktrees/track_A main
git -C /home/agent/SIMON worktree add -b feat/industry-m7-agent /home/agent/SIMPN_ARGON_HANDOWER/worktrees/track_C main
git -C /home/agent/SIMON worktree add -b fix/core-security-hardening /home/agent/SIMPN_ARGON_HANDOWER/worktrees/track_D main
git -C /home/agent/SIMON worktree add -b feat/coordinator-gossipsub-bridge /home/agent/SIMPN_ARGON_HANDOWER/worktrees/track_E main
git -C /home/agent/SIMON worktree add -b fix/submission-and-ui-polish /home/agent/SIMPN_ARGON_HANDOWER/worktrees/track_F main
```

### Option B: Copy-Paste Prompt Template for Any Individual Gemini 3.8 Flash Agent
Give each agent this exact starter prompt (substituting `<TRACK_DIR>`):

```text
You are assigned to execute a scoped engineering track for the SIMON hackathon project.
1. Read `/home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/AGENT_RULES_COMMON.md` first.
2. Read your exact task specification in `/home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/<TRACK_DIR>/TASK_SPEC.md`.
3. Work ONLY inside your assigned git worktree/branch and touch ONLY the files listed in your TASK_SPEC.md.
4. Run all verification tests specified in your TASK_SPEC.md before committing your branch.
```
