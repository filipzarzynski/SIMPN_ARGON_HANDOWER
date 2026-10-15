# SIMON (`Szpili/SIMON`) — Deep-Dive Audit & Parallel Agent Handover Workspace

**Upstream Target Repository:** `https://github.com/Szpili/SIMON.git` (local reference cache at [`/home/agent/SIMON`](file:///home/agent/SIMON))
**Target Integration Base Branch:** `fz-contrib` *(agents NEVER PR directly to `main`; all commits are atomic and prefixed with `[FZ-*]` so the Team Captain can either merge `fz-contrib` or cherry-pick individual commits onto `main`)*
**Target Hackathon:** [AMD Developer Hackathon: ACT III](https://lablab.ai/ai-hackathons/amd-developer-hackathon-act-iii)
**Shared Agent Workspace:** [`/home/agent/SIMPN_ARGON_HANDOWER`](file:///home/agent/SIMPN_ARGON_HANDOWER) (`https://github.com/filipzarzynski/SIMPN_ARGON_HANDOWER.git`)

---

## Quick Start: Launching Parallel Track Agents (`A`–`I`) in Antigravity

This repository is configured with root [`AGENTS.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/AGENTS.md) rules and 5 workspace skills in [`.agents/skills/`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/). Open this directory as your workspace in Antigravity and prompt any agent (`Track A`–`F` in Stage 1; `Track G`–`I` in Stage 2) with:

> `you are track D agent, please clone upstream repo to your dedicated subfolder in this workspace and start working on your assigned tasks on dedicated branch making sure commits are granular, logical and not breaking, then once you are finished and checked everything multiple times create a pull request with your task addressing any possible merge issues`

See [`parallel_agents/ORCHESTRATOR_GUIDE.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/ORCHESTRATOR_GUIDE.md) for the **Recommended Wave Execution Strategy** (Wave 1A Urgent Bugfixes `[D, A, F]` $\rightarrow$ Wave 1B Feature Upgrades `[C, B, E]` $\rightarrow$ Stage 2 Overhaul & Rollup `[G, H, I]`).

---

## Directory Index

### Part I — Technical Audit, Architecture & Hackathon Strategy
1. **[`00_EXECUTIVE_ASSESSMENT_AND_HACKATHON.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/00_EXECUTIVE_ASSESSMENT_AND_HACKATHON.md)** — Independent evaluation of the core thesis, codebase reality vs. claims, and **AMD Developer Hackathon: ACT III** prize-by-prize viability matrix.
2. **[`01_ARCHITECTURE_AND_DATA_FLOWS.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/01_ARCHITECTURE_AND_DATA_FLOWS.md)** — End-to-end Mermaid architecture and sequence diagrams, the **"Two Disconnected Worlds"** inside the Rust workspace, `SIMON-*-v1` cryptographic domain tree, and Track 1 Intelligent Industry pipeline.
3. **[`02_CODEBASE_AUDIT_RUST.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/02_CODEBASE_AUDIT_RUST.md)** — File-by-file, line-by-line audit of root `Cargo.toml`, `simon-core`, `simon-verify-wasm`, `simon-harness`, `simon-node`, and `simon-cli`.
4. **[`03_CODEBASE_AUDIT_TOOLS_AND_UI.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/03_CODEBASE_AUDIT_TOOLS_AND_UI.md)** — File-by-file, line-by-line audit of `tools/*`, `scripts/*`, `demo/*`, `deploy/*`, `przyklady/*`, `docs/*`, and `ui/*`.
5. **[`04_CLAIMS_VS_REALITY_MATRIX.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/04_CLAIMS_VS_REALITY_MATRIX.md)** — Claim-by-claim verification table (`C1`–`C9`) and Master Catalog of **16 concrete bugs and security vulnerabilities (`BUG-01` through `BUG-16`)** with exact file and line numbers.
6. **[`05_HACKATHON_ROADMAP_AND_PR_CATALOG.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/05_HACKATHON_ROADMAP_AND_PR_CATALOG.md)** — Prioritized Tier 0 / Tier 1 / Tier 2 hackathon roadmap and PR specifications.

---

### Part II — Antigravity Workspace Rules & Skills
- **[`AGENTS.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/AGENTS.md)** — Root workspace rule file loaded automatically by Antigravity. Maps Stage 1 (`Tracks A`–`F`) and Stage 2 (`Tracks G`–`I`) to their isolated `workspaces/track_<X>` subfolders, `fz/track-*` branches targeting `fz-contrib`, task specs, exclusive file scopes, and 5-phase workflow.
- **[`.agents/skills/simon-track-init/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-track-init/SKILL.md)** — Automated concurrency-safe upstream cloning, `fz-contrib` base branch setup, and `fz/track-*` branch checkout ([`init_track.sh`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-track-init/scripts/init_track.sh)).
- **[`.agents/skills/simon-crypto-and-protocol/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-crypto-and-protocol/SKILL.md)** — Cryptographic domain constants (`SIMON-*-v1`), M0/M1/M3 invariants, and Polish/English serde reference ([`domain_tags_and_serde.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-crypto-and-protocol/references/domain_tags_and_serde.md)).
- **[`.agents/skills/simon-industry-and-ui/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-industry-and-ui/SKILL.md)** — Track 1 Intelligent Industry pipeline & SvelteKit 5 UI schema reference ([`industry_schema.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-industry-and-ui/references/industry_schema.md)).
- **[`.agents/skills/simon-verify-suite/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-verify-suite/SKILL.md)** — Multi-pass scope, commit granularity, and test suite verifier ([`verify_track.sh`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-verify-suite/scripts/verify_track.sh)).
- **[`.agents/skills/simon-pr-delivery/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-pr-delivery/SKILL.md)** — `fz-contrib` linear commit integrator, cross-track `git merge-tree` conflict verifier, Captain Cherry-Pick Menu builder, and PR generator ([`prepare_and_create_pr.py`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py)).

---

### Part III — Track Specifications (`parallel_agents/`)

#### Stage 1 Tracks (Disjoint File Scopes — Run Wave 1A `[D, A, F]` + Wave 1B `[C, B, E]`)
- **[`parallel_agents/track_D_core_security_and_wasm_fixes/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_D_core_security_and_wasm_fixes/TASK_SPEC.md)** — `PR-4` (`fz/track-D-core-security-hardening`): Fixes `BUG-04` (`zweryfikuj_m1` unsigned receipt bypass), `BUG-06` (`web.rs` IPv4-mapped IPv6 SSRF bypass), `BUG-15` (WASM `signature_valid: true` when `signature_hex` is `null`), `m3.rs` `NaN` injection, and `cap.rs` non-object JSON bypass.
- **[`parallel_agents/track_A_receipt_and_node_truth/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_A_receipt_and_node_truth/TASK_SPEC.md)** — `PR-1` (`fz/track-A-node-receipt-truth`): Fixes `BUG-01` (`0 µs` timestamp), `BUG-02` (hardcoded `"fp16"`), and `BUG-05` (`simon-node` GGUF SHA-256 verification).
- **[`parallel_agents/track_F_submission_and_ui_polish/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_F_submission_and_ui_polish/TASK_SPEC.md)** — `PR-6` (`fz/track-F-submission-and-ui-polish`): Fixes `BUG-10`, `BUG-11`, `BUG-12`, `BUG-13`, `BUG-14`, and `BUG-16`.
- **[`parallel_agents/track_C_industry_gemma4_live_agent/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_C_industry_gemma4_live_agent/TASK_SPEC.md)** — `PR-3` (`fz/track-C-industry-m7-agent`): Fixes `BUG-09` (replaces single-shot `curl` in `tools/simon-industry/tickets.py` with a multi-turn Gemma 4 tool-calling loop + verified SIMON receipts).
- **[`parallel_agents/track_B_live_m1_token_binding/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_B_live_m1_token_binding/TASK_SPEC.md)** — `PR-2` (`fz/track-B-live-m1-receipts`): Fixes `BUG-03` (wires M1 `TokenCommitment` builder in `wspolne.rs` and verifies them in `simon agent`).
- **[`parallel_agents/track_E_p2p_coordinator_bridge/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_E_p2p_coordinator_bridge/TASK_SPEC.md)** — `PR-5` (`fz/track-E-coordinator-gossipsub-bridge`): Fixes `BUG-07` (`SimonNode` HTTP backend bridge) and `BUG-08` (`mapreduce.rs` silent truncation).

#### Stage 2 Tracks (Run AFTER Stage 1 is Integrated into `fz-contrib`)
- **[`parallel_agents/track_G_architecture_and_docs_overhaul/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_G_architecture_and_docs_overhaul/TASK_SPEC.md)** — `PR-7` (`fz/track-G-architecture-and-docs-overhaul`): Creates `docs/ARCHITECTURE.md` with Mermaid data flows and aligns `docs/THREAT-MODEL.md`, `ROADMAP.md`, and `docs/whitepaper/SIMON-whitepaper-EN.md` with the verified codebase.
- **[`parallel_agents/track_H_e2e_integration_and_live_m1_bridge/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_H_e2e_integration_and_live_m1_bridge/TASK_SPEC.md)** — `PR-8` (`fz/track-H-e2e-integration-and-live-m1-bridge`): Connects `wspolne::zbuduj_zobowiazania_tokenow` into `node.rs` and adds `crates/simon-cli/tests/e2e_m1_receipt.rs`.
- **[`parallel_agents/track_I_captain_cherry_pick_menu_and_ci/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_I_captain_cherry_pick_menu_and_ci/TASK_SPEC.md)** — `PR-9` (`fz/track-I-captain-cherry-pick-menu-and-ci`): Generates `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md` for the Team Captain and `scripts/verify_all_fast.sh`.
