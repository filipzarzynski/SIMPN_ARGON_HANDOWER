# SIMON (`Szpili/SIMON`) — Deep-Dive Audit & Parallel Agent Handover Workspace

**Upstream Target Repository:** `https://github.com/Szpili/SIMON.git` (local reference cache at [`/home/agent/SIMON`](file:///home/agent/SIMON))  
**Target Integration Base Branch:** `fz-contrib` (`8fbe206`, synced with `upstream/main` `8fbe206` — *submitted & judging in progress*)  
**Target Hackathon:** [AMD Developer Hackathon: ACT III](https://lablab.ai/ai-hackathons/amd-developer-hackathon-act-iii)  
**Submission URL:** [SIMON: Signed, Verifiable AI Tickets on AMD MI300X](https://lablab.ai/ai-hackathons/amd-developer-hackathon-act-iii/simon/simon-signed-verifiable-ai-tickets-on-amd-mi300x)  
**Live Demo:** [https://pop-os.tailaf1556.ts.net/simon/industry](https://pop-os.tailaf1556.ts.net/simon/industry) | **Static Mirror:** [https://szpili.github.io/SIMON/industry](https://szpili.github.io/SIMON/industry)  
**Shared Agent Workspace:** [`/home/agent/SIMPN_ARGON_HANDOWER`](file:///home/agent/SIMPN_ARGON_HANDOWER) (`https://github.com/filipzarzynski/SIMPN_ARGON_HANDOWER.git`)

---

## Current Status: SUBMITTED & JUDGING IN PROGRESS 🎉

SIMON was officially submitted before the Oct 17, 12:00 CEST code freeze:
* **All PRs Merged:** Stage 1 (`PR #8`) and Stage 2 (`PR #9`) are fully merged into `Szpili/SIMON:main` at [`8fbe206`](https://github.com/Szpili/SIMON/commit/8fbe2061d68909efb4e2a0c11cb16b0faed0d87e).
* **Browser Verification:** **15/15 industry run receipts** verified offline in browser via rebuilt WebAssembly (`simon-verify-wasm`).
* **Measured Safety Improvement:** Unsafe-draft escape rate dropped from **7/12 (58%) to 0/15 (0%)** on the adversarial stress corpus.
* **AMD MI300X Benchmark:** 64 concurrent streams under ROCm vLLM with **510/510 receipts verified** at 1.64s median latency.
* **Token Factory Bridge:** Local bridge (`tools/amd/tokenfactory_bridge.py`) verified against 16 AMD Radeon Cloud models.
* **Judging Brief & Strategy:** See [`09_JUDGING_DEFENSE_AND_STRATEGY_BRIEF.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/09_JUDGING_DEFENSE_AND_STRATEGY_BRIEF.md).

---

## Directory Index

### Part I — Technical Audit, Architecture, Post-Mortem & Hackathon Strategy
1. **[`00_EXECUTIVE_ASSESSMENT_AND_HACKATHON.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/00_EXECUTIVE_ASSESSMENT_AND_HACKATHON.md)** — Independent evaluation of the core thesis, codebase reality vs. claims, and **AMD Developer Hackathon: ACT III** prize-by-prize viability matrix.
2. **[`01_ARCHITECTURE_AND_DATA_FLOWS.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/01_ARCHITECTURE_AND_DATA_FLOWS.md)** — End-to-end Mermaid architecture and sequence diagrams, the **"Two Disconnected Worlds"** inside the Rust workspace, `SIMON-*-v1` cryptographic domain tree, and Track 1 Intelligent Industry pipeline.
3. **[`02_CODEBASE_AUDIT_RUST.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/02_CODEBASE_AUDIT_RUST.md)** — File-by-file, line-by-line audit of root `Cargo.toml`, `simon-core`, `simon-verify-wasm`, `simon-harness`, `simon-node`, and `simon-cli`.
4. **[`03_CODEBASE_AUDIT_TOOLS_AND_UI.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/03_CODEBASE_AUDIT_TOOLS_AND_UI.md)** — File-by-file, line-by-line audit of `tools/*`, `scripts/*`, `demo/*`, `deploy/*`, `przyklady/*`, `docs/*`, and `ui/*`.
5. **[`04_CLAIMS_VS_REALITY_MATRIX.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/04_CLAIMS_VS_REALITY_MATRIX.md)** — Claim-by-claim verification table (`C1`–`C9`) and Master Catalog of **16 concrete bugs and security vulnerabilities (`BUG-01` through `BUG-16`)** with exact file and line numbers.
6. **[`05_HACKATHON_ROADMAP_AND_PR_CATALOG.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/05_HACKATHON_ROADMAP_AND_PR_CATALOG.md)** — Master Track Catalog (`Tracks A` through `N`) across Stage 1 (completed), Stage 2 (`Waves 2A & 2B`), and Stage 3 (`Waves 3A & 3B`).
7. **[`07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md)** — Comprehensive commit-by-commit post-mortem of the 22 review/fix commits made by `Szpili` and Claude Opus 5.5 when merging Stage 1 (`PR #8`), and how those 7 failure patterns are prevented in Stage 2 and Stage 3.
8. **[`08_TEAM_SYNC_ARCHITECTURE_AND_WAVE_BRIEF.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/08_TEAM_SYNC_ARCHITECTURE_AND_WAVE_BRIEF.md)** — Team sync call executive brief mapping live architecture (`8fbe206`) against post-hackathon staged waves.
9. **[`09_JUDGING_DEFENSE_AND_STRATEGY_BRIEF.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/09_JUDGING_DEFENSE_AND_STRATEGY_BRIEF.md)** — Hackathon judging defense strategy, AMD hardware showcase (MI300X & Token Factory), judge Q&A FAQ, and live demo uptime protocol.

---

### Part II — Antigravity Workspace Rules & Skills
- **[`AGENTS.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/AGENTS.md)** — Root workspace rule file loaded automatically by Antigravity. Maps Stage 1 (`Tracks A`–`F`), Stage 2 (`Tracks H, J, G, I`), and Stage 3 (`Tracks K, L, M, N`) to their isolated `workspaces/track_<X>` subfolders, `fz/track-*` branches targeting `fz-contrib`, task specs, exclusive file scopes, and 5-phase workflow.
- **[`.agents/skills/simon-captain-review-guardrails/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-captain-review-guardrails/SKILL.md)** — **Mandatory guardrails** distilled from the Captain's 22 Stage 1 review commits (never guess signed claims, strict `THREAT-MODEL.md` claim discipline, no unbacked numbers, no workspace path leaks, bounded network inputs).
- **[`.agents/skills/simon-track-init/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-track-init/SKILL.md)** — Automated concurrency-safe upstream cloning, `fz-contrib` base branch setup, and `fz/track-*` branch checkout ([`init_track.sh`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-track-init/scripts/init_track.sh)).
- **[`.agents/skills/simon-crypto-and-protocol/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-crypto-and-protocol/SKILL.md)** — Cryptographic domain constants (`SIMON-*-v1`), M0/M1/M3 invariants, and Polish/English serde reference ([`domain_tags_and_serde.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-crypto-and-protocol/references/domain_tags_and_serde.md)).
- **[`.agents/skills/simon-industry-and-ui/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-industry-and-ui/SKILL.md)** — Track 1 Intelligent Industry pipeline & SvelteKit 5 UI schema reference ([`industry_schema.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-industry-and-ui/references/industry_schema.md)).
- **[`.agents/skills/simon-verify-suite/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-verify-suite/SKILL.md)** — 4-pass scope, Captain guardrail scan, commit granularity, and test suite verifier ([`verify_track.sh`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-verify-suite/scripts/verify_track.sh)).
- **[`.agents/skills/simon-pr-delivery/SKILL.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-pr-delivery/SKILL.md)** — `fz-contrib` linear commit integrator, cross-track `git merge-tree` conflict verifier, Captain Cherry-Pick Menu builder, and PR generator ([`prepare_and_create_pr.py`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py)).

---

### Part III — Track Specifications (`parallel_agents/`)

#### Stage 2 Tracks (Waves 2A `[H, J]` & 2B `[G, I]` — 100% Disjoint File Scopes)
- **[`parallel_agents/track_H_e2e_integration_and_live_m1_bridge/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_H_e2e_integration_and_live_m1_bridge/TASK_SPEC.md)** — `[FZ-H]` (Wave 2A, `fz/track-H-e2e-integration-and-live-m1-bridge`): Addresses `STRESS-TESTS.md` Next #2 — wires `PromptResponse::{prompt_tokens, output_tokens}` with `MAX_M1_TOKENS = 65_536` caps and `Receipt::z_wiazaniem_m1` in `node.rs`, plus `crates/simon-cli/tests/e2e_m1_receipt.rs`.
- **[`parallel_agents/track_J_signed_job_result_and_registration/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_J_signed_job_result_and_registration/TASK_SPEC.md)** — `[FZ-J]` (Wave 2A, `fz/track-J-signed-job-result-and-registration`): Addresses `STRESS-TESTS.md` Next #1 & #3 — signs `JobResult` (`SIMON/JOB-RESULT/v1`, including failures) and `RegisterMsg` + `NodeVoucher` (`SIMON/NODE-REGISTER/v1`, `SIMON/NODE-VOUCH/v1`) with Sybil tests.
- **[`parallel_agents/track_G_architecture_and_docs_overhaul/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_G_architecture_and_docs_overhaul/TASK_SPEC.md)** — `[FZ-G]` (Wave 2B, `fz/track-G-architecture-and-docs-overhaul`): Creates `docs/ARCHITECTURE.md` and updates `docs/STRESS-TESTS.md` rows 7/17/18, `docs/THREAT-MODEL.md`, `ROADMAP.md`, and `docs/whitepaper/SIMON-whitepaper-EN.md`.
- **[`parallel_agents/track_I_captain_cherry_pick_menu_and_ci/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_I_captain_cherry_pick_menu_and_ci/TASK_SPEC.md)** — `[FZ-I]` (Wave 2B, `fz/track-I-captain-cherry-pick-menu-and-ci`): Creates `scripts/verify_all_fast.sh` and `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md`.

#### Stage 3 Tracks (Waves 3A `[K, L]` & 3B `[M, N]` — 100% Disjoint File Scopes, Run After Stage 2)
- **[`parallel_agents/track_K_vpn_attack_harness_and_agent_m1_gate/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_K_vpn_attack_harness_and_agent_m1_gate/TASK_SPEC.md)** — `[FZ-K]` (Wave 3A, `fz/track-K-vpn-attack-harness-and-agent-m1-gate`): Addresses `STRESS-TESTS.md` Next #4 — creates `crates/simon-cli/tests/vpn_attack_harness.rs` and hardens `agent.rs` to reject Level 1 receipts missing token arrays.
- **[`parallel_agents/track_L_gateway_and_monitor_hardening/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_L_gateway_and_monitor_hardening/TASK_SPEC.md)** — `[FZ-L]` (Wave 3A, `fz/track-L-gateway-and-monitor-hardening`): Enforces 1 MiB body limit and logs `signer_pinned` in `simon_api.py`; bounds `fetch_stats` in `simon_monitor.py`; adds `--selfcheck` to both.
- **[`parallel_agents/track_M_industry_adversarial_corpus/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_M_industry_adversarial_corpus/TASK_SPEC.md)** — `[FZ-M]` (Wave 3B, `fz/track-M-industry-adversarial-corpus`): Unifies NFKC/`Cf` and link/role/urgency checks across `tickets.py` and `agent_triage.py`, and expands `stress_corpus.json` from 17 to 25 cases.
- **[`parallel_agents/track_N_ui_receipts_and_demo_polish/TASK_SPEC.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/track_N_ui_receipts_and_demo_polish/TASK_SPEC.md)** — `[FZ-N]` (Wave 3B, `fz/track-N-ui-receipts-and-demo-polish`): Adds verification level / claim-label table to `/receipts` and adds a client-nonce replay tamper preset + `aria-pressed` semantics to `/demo`.
