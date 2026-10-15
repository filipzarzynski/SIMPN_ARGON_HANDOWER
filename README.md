# SIMON (`Szpili/SIMON`) — Deep-Dive Audit & Parallel Agent Handover Package

**Target Repository:** [`/home/agent/SIMON`](file:///home/agent/SIMON) (`https://github.com/Szpili/SIMON`, commit `e55ca11`, clean & untouched)
**Target Hackathon:** [AMD Developer Hackathon: ACT III](https://lablab.ai/ai-hackathons/amd-developer-hackathon-act-iii)
**Handover Directory:** `/home/agent/SIMPN_ARGON_HANDOWER` (symlinked at `/home/agent/SIMON_ARGON_HANDOVER`)

---

## Directory Index

### Part I — Technical Audit, Architecture & Hackathon Strategy
1. **[`00_EXECUTIVE_ASSESSMENT_AND_HACKATHON.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/00_EXECUTIVE_ASSESSMENT_AND_HACKATHON.md)**
   - Independent evaluation of the core thesis (why open P2P untrusted inference fails for high-context agentic workloads, where the real thesis pivots to hybrid edge/burst enterprise auditability, and why `FP-RESULT.md`'s negative result is actually the strongest intellectual asset in the repo).
   - **AMD Developer Hackathon: ACT III** prize-by-prize viability matrix (Track 1: Intelligent Industry, $5k Best Use of AMD GPU, $5k Best Use of Google Gemma, Vibe Generation Prize, Evolus Side Track).
2. **[`01_ARCHITECTURE_AND_DATA_FLOWS.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/01_ARCHITECTURE_AND_DATA_FLOWS.md)**
   - End-to-end Mermaid architecture and sequence diagrams.
   - Documentation of the **"Two Disconnected Worlds"** inside the Rust codebase (Live `simon agent` $\leftrightarrow$ `simon node` vs. isolated `AcpServer`/`SimonNode` Gossipsub harness).
   - Cryptographic domain-separation inventory (`SIMON-*-v1`) and the M0 / M1 / M3 verification hierarchy.
   - Track 1 Intelligent Industry (`ai4i2020.csv` $\rightarrow$ `rules.py` $\rightarrow$ RTX 3090 / AMD MI300X Gemma 4 26B-A4B $\rightarrow$ `industry-run.json` $\rightarrow$ SvelteKit UI) pipeline.
3. **[`02_CODEBASE_AUDIT_RUST.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/02_CODEBASE_AUDIT_RUST.md)**
   - File-by-file, line-by-line audit of root `Cargo.toml`, `crates/simon-core`, `crates/simon-verify-wasm`, `crates/simon-harness`, `crates/simon-node`, and `crates/simon-cli`.
4. **[`03_CODEBASE_AUDIT_TOOLS_AND_UI.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/03_CODEBASE_AUDIT_TOOLS_AND_UI.md)**
   - File-by-file, line-by-line audit of `tools/simon-industry`, `tools/simon-verifier`, `tools/simon-lidar`, `tools/simon-canary`, `tools/simon-api`, `tools/simon-monitor`, `tools/simon-bench`, `tools/simon-guard`, `tools/amd`, `scripts/`, `demo/`, `deploy/`, `przyklady/`, `docs/`, and `ui/`.
5. **[`04_CLAIMS_VS_REALITY_MATRIX.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/04_CLAIMS_VS_REALITY_MATRIX.md)**
   - Claim-by-claim verification table (`C1`–`C9`) comparing README/whitepaper/submission claims against actual code.
   - Master Catalog of **16 concrete bugs and security vulnerabilities (`BUG-01` through `BUG-16`)** with exact file and line numbers.
6. **[`05_HACKATHON_ROADMAP_AND_PR_CATALOG.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/05_HACKATHON_ROADMAP_AND_PR_CATALOG.md)**
   - Prioritized Tier 0 / Tier 1 / Tier 2 hackathon roadmap.
   - 6 non-overlapping feature-branch / PR specifications (`PR-1` through `PR-6`).

---

### Part II — Parallel Gemini 3.8 Flash High Agent Handover Pack
- **[`parallel_agents/ORCHESTRATOR_GUIDE.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/ORCHESTRATOR_GUIDE.md)** — How to spawn 6 parallel agents in isolated `git worktree` checkouts with zero merge conflicts, plus merge order and prompt templates.
- **[`parallel_agents/AGENT_RULES_COMMON.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/AGENT_RULES_COMMON.md)** — Shared rules, toolchain paths, bilingual Polish/English naming map, and cryptographic invariants.
- **[`parallel_agents/track_A_receipt_and_node_truth/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_A_receipt_and_node_truth/TASK_SPEC.md)** — `PR-1` (`fix/node-receipt-truth`): Fixes `BUG-01` (`0 µs` timestamp), `BUG-02` (hardcoded `"fp16"`), and `BUG-05` (`simon-node` GGUF SHA-256 verification).
- **[`parallel_agents/track_B_live_m1_token_binding/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_B_live_m1_token_binding/TASK_SPEC.md)** — `PR-2` (`feat/live-m1-receipts`): Fixes `BUG-03` (populates M1 `TokenCommitment` chain in live receipts and verifies them in `simon agent`).
- **[`parallel_agents/track_C_industry_gemma4_live_agent/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_C_industry_gemma4_live_agent/TASK_SPEC.md)** — `PR-3` (`feat/industry-m7-agent`): Fixes `BUG-09` (replaces single-shot `curl` in `tools/simon-industry/tickets.py` with a multi-turn Gemma 4 tool-calling loop + verified SIMON receipts).
- **[`parallel_agents/track_D_core_security_and_wasm_fixes/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_D_core_security_and_wasm_fixes/TASK_SPEC.md)** — `PR-4` (`fix/core-security-hardening`): Fixes `BUG-04` (`zweryfikuj_m1` unsigned receipt bypass), `BUG-06` (`web.rs` IPv4-mapped IPv6 SSRF bypass), `BUG-15` (WASM `signature_valid: true` when `signature_hex` is `null`), `m3.rs` `NaN` injection, and `cap.rs` non-object JSON bypass.
- **[`parallel_agents/track_E_p2p_coordinator_bridge/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_E_p2p_coordinator_bridge/TASK_SPEC.md)** — `PR-5` (`feat/coordinator-gossipsub-bridge`): Fixes `BUG-07` (`SimonNode` HTTP backend bridge) and `BUG-08` (`mapreduce.rs` silent truncation).
- **[`parallel_agents/track_F_submission_and_ui_polish/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_F_submission_and_ui_polish/TASK_SPEC.md)** — `PR-6` (`fix/submission-and-ui-polish`): Fixes `BUG-10`, `BUG-11`, `BUG-12`, `BUG-13`, `BUG-14`, and `BUG-16`.
