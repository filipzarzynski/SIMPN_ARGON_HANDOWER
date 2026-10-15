# SIMON (`Szpili/SIMON`) — Deep-Dive Audit & Parallel Agent Handover Workspace

**Upstream Target Repository:** `https://github.com/Szpili/SIMON.git` (local reference cache at [`/home/agent/SIMON`](file:///home/agent/SIMON))
**Target Hackathon:** [AMD Developer Hackathon: ACT III](https://lablab.ai/ai-hackathons/amd-developer-hackathon-act-iii)
**Shared Agent Workspace:** [`/home/agent/SIMPN_ARGON_HANDOWER`](file:///home/agent/SIMPN_ARGON_HANDOWER) (`https://github.com/filipzarzynski/SIMPN_ARGON_HANDOWER.git`)

---

## Quick Start: Launching Parallel Track Agents (`A`–`F`) in Antigravity

This repository is configured with root [`AGENTS.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/AGENTS.md) rules and 5 workspace skills in [`.agents/skills/`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/). Open this directory as your workspace in Antigravity and prompt any agent (`Track A`, `B`, `C`, `D`, `E`, or `F`) with:

> `you are track A agent, please clone upstream repo to your dedicated subfolder in this workspace and start working on your assigned tasks on dedicated branch making sure commits are granular, logical and not breaking, then once you are finished and checked everything multiple times create a pull request with your task addressing any possible merge issues`

See [`parallel_agents/ORCHESTRATOR_GUIDE.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/ORCHESTRATOR_GUIDE.md) for all 6 copy-paste prompts and the architecture of the shared local integration hub (`workspaces/_upstream_hub.git`).

---

## Directory Index

### Part I — Technical Audit, Architecture & Hackathon Strategy
1. **[`00_EXECUTIVE_ASSESSMENT_AND_HACKATHON.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/00_EXECUTIVE_ASSESSMENT_AND_HACKATHON.md)** — Independent evaluation of the core thesis, codebase reality vs. claims, and **AMD Developer Hackathon: ACT III** prize-by-prize viability matrix.
2. **[`01_ARCHITECTURE_AND_DATA_FLOWS.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/01_ARCHITECTURE_AND_DATA_FLOWS.md)** — End-to-end Mermaid architecture and sequence diagrams, the **"Two Disconnected Worlds"** inside the Rust workspace, `SIMON-*-v1` cryptographic domain tree, and Track 1 Intelligent Industry pipeline.
3. **[`02_CODEBASE_AUDIT_RUST.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/02_CODEBASE_AUDIT_RUST.md)** — File-by-file, line-by-line audit of root `Cargo.toml`, `simon-core`, `simon-verify-wasm`, `simon-harness`, `simon-node`, and `simon-cli`.
4. **[`03_CODEBASE_AUDIT_TOOLS_AND_UI.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/03_CODEBASE_AUDIT_TOOLS_AND_UI.md)** — File-by-file, line-by-line audit of `tools/*`, `scripts/*`, `demo/*`, `deploy/*`, `przyklady/*`, `docs/*`, and `ui/*`.
5. **[`04_CLAIMS_VS_REALITY_MATRIX.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/04_CLAIMS_VS_REALITY_MATRIX.md)** — Claim-by-claim verification table (`C1`–`C9`) and Master Catalog of **16 concrete bugs and security vulnerabilities (`BUG-01` through `BUG-16`)** with exact file and line numbers.
6. **[`05_HACKATHON_ROADMAP_AND_PR_CATALOG.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/05_HACKATHON_ROADMAP_AND_PR_CATALOG.md)** — Prioritized Tier 0 / Tier 1 / Tier 2 hackathon roadmap and 6 non-overlapping feature-branch / PR specifications (`PR-1` through `PR-6`).

---

### Part II — Antigravity Workspace Rules & Skills
- **[`AGENTS.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/AGENTS.md)** — Root workspace rule file loaded automatically by Antigravity. Maps Tracks `A`–`F` to their isolated `workspaces/track_<X>` subfolders, branches, task specs, exclusive file scopes, and 5-phase workflow.
- **[`.agents/skills/simon-track-init/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-track-init/SKILL.md)** — Automated concurrency-safe upstream cloning and branch setup ([`init_track.sh`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-track-init/scripts/init_track.sh)).
- **[`.agents/skills/simon-crypto-and-protocol/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-crypto-and-protocol/SKILL.md)** — Cryptographic domain constants (`SIMON-*-v1`), M0/M1/M3 invariants, and Polish/English serde reference ([`domain_tags_and_serde.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-crypto-and-protocol/references/domain_tags_and_serde.md)).
- **[`.agents/skills/simon-industry-and-ui/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-industry-and-ui/SKILL.md)** — Track 1 Intelligent Industry pipeline & SvelteKit 5 UI schema reference ([`industry_schema.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-industry-and-ui/references/industry_schema.md)).
- **[`.agents/skills/simon-verify-suite/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-verify-suite/SKILL.md)** — Multi-pass scope, commit granularity, and test suite verifier ([`verify_track.sh`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-verify-suite/scripts/verify_track.sh)).
- **[`.agents/skills/simon-pr-delivery/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-pr-delivery/SKILL.md)** — Upstream rebase, cross-track `git merge-tree` conflict verifier, and PR generator ([`prepare_and_create_pr.py`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py)).

---

### Part III — Track Specifications (`parallel_agents/`)
- **[`parallel_agents/ORCHESTRATOR_GUIDE.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/ORCHESTRATOR_GUIDE.md)** — Multi-agent prompt templates and workflow diagram.
- **[`parallel_agents/AGENT_RULES_COMMON.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/AGENT_RULES_COMMON.md)** — Shared technical rules and bilingual naming glossary.
- **[`parallel_agents/track_A_receipt_and_node_truth/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_A_receipt_and_node_truth/TASK_SPEC.md)** — `PR-1` (`fix/node-receipt-truth`): Fixes `BUG-01` (`0 µs` timestamp), `BUG-02` (hardcoded `"fp16"`), and `BUG-05` (`simon-node` GGUF SHA-256 verification).
- **[`parallel_agents/track_B_live_m1_token_binding/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_B_live_m1_token_binding/TASK_SPEC.md)** — `PR-2` (`feat/live-m1-receipts`): Fixes `BUG-03` (populates M1 `TokenCommitment` chain in live receipts and verifies them in `simon agent`).
- **[`parallel_agents/track_C_industry_gemma4_live_agent/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_C_industry_gemma4_live_agent/TASK_SPEC.md)** — `PR-3` (`feat/industry-m7-agent`): Fixes `BUG-09` (replaces single-shot `curl` in `tools/simon-industry/tickets.py` with a multi-turn Gemma 4 tool-calling loop + verified SIMON receipts).
- **[`parallel_agents/track_D_core_security_and_wasm_fixes/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_D_core_security_and_wasm_fixes/TASK_SPEC.md)** — `PR-4` (`fix/core-security-hardening`): Fixes `BUG-04` (`zweryfikuj_m1` unsigned receipt bypass), `BUG-06` (`web.rs` IPv4-mapped IPv6 SSRF bypass), `BUG-15` (WASM `signature_valid: true` when `signature_hex` is `null`), `m3.rs` `NaN` injection, and `cap.rs` non-object JSON bypass.
- **[`parallel_agents/track_E_p2p_coordinator_bridge/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_E_p2p_coordinator_bridge/TASK_SPEC.md)** — `PR-5` (`feat/coordinator-gossipsub-bridge`): Fixes `BUG-07` (`SimonNode` HTTP backend bridge) and `BUG-08` (`mapreduce.rs` silent truncation).
- **[`parallel_agents/track_F_submission_and_ui_polish/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_F_submission_and_ui_polish/TASK_SPEC.md)** — `PR-6` (`fix/submission-and-ui-polish`): Fixes `BUG-10`, `BUG-11`, `BUG-12`, `BUG-13`, `BUG-14`, and `BUG-16`.
