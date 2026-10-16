# SIMPN_ARGON_HANDOWER — Parallel Agent Workspace Rules (`AGENTS.md`)

You are an autonomous Antigravity coding agent operating inside **`SIMPN_ARGON_HANDOWER`**, the central audit and multi-agent orchestration workspace for the **SIMON** repository (`https://github.com/Szpili/SIMON.git`) competing in **AMD Developer Hackathon: ACT III**.

---

## 0. Golden Rules: Target `fz-contrib` (NEVER `main`), Keep Commits Cherry-Pickable & Obey Captain Guardrails

To protect the upstream `Szpili/SIMON` `main` branch and eliminate the **Team Captain review bottleneck**:
1. **Dedicated Base Branch (`fz-contrib`)**: Every Track agent branches off **`fz-contrib`** (`82baa8e`, synced with `upstream/fz-contrib` and `upstream/main`) into `fz/track-<X>-<slug>` and targets **`fz-contrib`** (NEVER `main`) when creating a Pull Request.
2. **Self-Contained, Cherry-Pickable Commits (`[FZ-<X><N>]`)**: Prefix every commit message with `[FZ-<X>1]`, `[FZ-<X>2]`, etc. (e.g., `[FZ-H1] feat(cli): wire live M1 token chain with MAX_M1_TOKENS cap`). Every single commit MUST compile and pass tests (`cargo clippy --workspace --all-targets -- -D warnings`) independently so the Team Captain can cherry-pick individual fixes onto `main` in seconds.
3. **Read [`.agents/skills/simon-captain-review-guardrails/SKILL.md`](./.agents/skills/simon-captain-review-guardrails/SKILL.md) BEFORE Writing Any Code**:
   - **Never guess signed claims:** Unknown precision $\rightarrow$ `Precision::Unknown`; `proof_level` $\rightarrow$ `poziom_sprawdzony`; `client_nonce` $\rightarrow$ `order.nonce` (never `receipt.wiazania.client_nonce`).
   - **Never overclaim in UI/docs:** Obey [`docs/THREAT-MODEL.md`](file:///home/agent/SIMON/docs/THREAT-MODEL.md) and [`docs/STRESS-TESTS.md`](file:///home/agent/SIMON/docs/STRESS-TESTS.md). Never write `"100% Authentic"`, `"100% Cryptographically Verified"`, `"SIMULATED P2P TOPOLOGY"`, fake `"ed25519:operator_sig_..."`, or unbacked `tok/s` numbers.
   - **Never leak workspace paths:** Never include `SIMPN_ARGON_HANDOWER` or `/home/agent/` in any file inside the SIMON repository.

---

## 1. Track Routing Table (Stage 1: Completed | Stage 2: Waves 2A & 2B | Stage 3: Waves 3A & 3B)

When prompted with `"you are track <X> agent..."`, locate your assigned row below and obey its **Subfolder**, **Branch**, **Task Spec**, and **Exclusive File Scope**:

### Stage 1 Tracks (Completed & Merged into `upstream/main` via PR #8 + Post-Merge Refinements in `4186b4d`)

| Track | Wave | Commit Tag | Dedicated Clone Subfolder | Dedicated Track Branch (`-> fz-contrib`) | Upstream Status | Post-Mortem & Task Specification |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Track D** | **1A** | `[FZ-D]` | `workspaces/track_D` | `fz/track-D-core-security-hardening` | **Merged in PR #8** (`d108364`) | [`07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md`](./07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md) |
| **Track A** | **1A** | `[FZ-A]` | `workspaces/track_A` | `fz/track-A-node-receipt-truth` | **Merged in PR #8** (`d108364`) | [`07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md`](./07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md) |
| **Track F** | **1A** | `[FZ-F]` | `workspaces/track_F` | `fz/track-F-submission-and-ui-polish` | **Merged in PR #8** (`d108364`) | [`07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md`](./07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md) |
| **Track C** | **1B** | `[FZ-C]` | `workspaces/track_C` | `fz/track-C-industry-m7-agent` | **Merged in PR #8** (`d108364`) | [`07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md`](./07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md) |
| **Track B** | **1B** | `[FZ-B]` | `workspaces/track_B` | `fz/track-B-live-m1-receipts` | **Merged in PR #8** (`d108364`) | [`07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md`](./07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md) |
| **Track E** | **1B** | `[FZ-E]` | `workspaces/track_E` | `fz/track-E-coordinator-gossipsub-bridge` | **Merged in PR #8** (`d108364`) | [`07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md`](./07_STAGE1_CAPTAIN_REVIEW_POSTMORTEM.md) |

---

### Stage 2 Tracks (Completed & Integrated in Upstream PR #9 [82baa8e] — All 4 Tracks G, H, I, J)

All 4 Stage 2 tracks (`H`, `J`, `G`, `I`) were completed cleanly with 100% disjoint file scopes, passed all verification suites, and are integrated into `fz-contrib` (`82baa8e`) awaiting Captain review in [Szpili/SIMON#9](https://github.com/Szpili/SIMON/pull/9):

| Track | Wave | Commit Tag | Dedicated Clone Subfolder | Dedicated Track Branch (`-> fz-contrib`) | Roadmap Target (`docs/STRESS-TESTS.md`) | Task Specification | Exclusive File Ownership |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Track H** | **2A (Urgent Protocol)** | `[FZ-H]` | `workspaces/track_H` | `fz/track-H-e2e-integration-and-live-m1-bridge` | **Next #2**: Wire live M1 token chain with `MAX_M1_TOKENS = 65_536` caps + E2E test | [`parallel_agents/track_H_e2e_integration_and_live_m1_bridge/TASK_SPEC.md`](./parallel_agents/track_H_e2e_integration_and_live_m1_bridge/TASK_SPEC.md) | `crates/simon-cli/src/wspolne.rs`, `crates/simon-cli/src/node.rs`, `crates/simon-cli/tests/e2e_m1_receipt.rs` |
| **Track J** | **2A (Urgent Security)** | `[FZ-J]` | `workspaces/track_J` | `fz/track-J-signed-job-result-and-registration` | **Next #1 & #3**: Sign `JobResult` (failures too) + signed `RegisterMsg` & operator vouching + Sybil tests | [`parallel_agents/track_J_signed_job_result_and_registration/TASK_SPEC.md`](./parallel_agents/track_J_signed_job_result_and_registration/TASK_SPEC.md) | `crates/simon-node/src/lib.rs`, `crates/simon-cli/src/coord.rs` |
| **Track G** | **2B (Arch & Matrix)** | `[FZ-G]` | `workspaces/track_G` | `fz/track-G-architecture-and-docs-overhaul` | `docs/ARCHITECTURE.md` + update `STRESS-TESTS.md` rows 7/17/18 & `THREAT-MODEL.md` | [`parallel_agents/track_G_architecture_and_docs_overhaul/TASK_SPEC.md`](./parallel_agents/track_G_architecture_and_docs_overhaul/TASK_SPEC.md) | `docs/ARCHITECTURE.md`, `docs/STRESS-TESTS.md`, `docs/THREAT-MODEL.md`, `ROADMAP.md`, `docs/whitepaper/SIMON-whitepaper-EN.md` |
| **Track I** | **2B (Captain Gate)** | `[FZ-I]` | `workspaces/track_I` | `fz/track-I-captain-cherry-pick-menu-and-ci` | Fast full-stack guardrail verifier (`verify_all_fast.sh`) + Stage 2 Cherry-Pick Menu | [`parallel_agents/track_I_captain_cherry_pick_menu_and_ci/TASK_SPEC.md`](./parallel_agents/track_I_captain_cherry_pick_menu_and_ci/TASK_SPEC.md) | `scripts/verify_all_fast.sh`, `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md` |

---

### Stage 3 Tracks (Split into Waves 3A & 3B — Ready to Run off `82baa8e`)

Run off **`82baa8e` on `fz-contrib`**. All 4 Stage 3 tracks (`K`, `L`, `M`, `N`) have **100% disjoint file scopes**:

| Track | Wave | Commit Tag | Dedicated Clone Subfolder | Dedicated Track Branch (`-> fz-contrib`) | Roadmap Target (`docs/STRESS-TESTS.md`) | Task Specification | Exclusive File Ownership |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Track K** | **3A (Attack Harness)** | `[FZ-K]` | `workspaces/track_K` | `fz/track-K-vpn-attack-harness-and-agent-m1-gate` | **Next #4**: Prepared VPN target network attack harness (`vpn_attack_harness.rs`) + `agent.rs` M1 missing-token rejection | [`parallel_agents/track_K_vpn_attack_harness_and_agent_m1_gate/TASK_SPEC.md`](./parallel_agents/track_K_vpn_attack_harness_and_agent_m1_gate/TASK_SPEC.md) | `crates/simon-cli/src/agent.rs`, `crates/simon-cli/tests/vpn_attack_harness.rs` |
| **Track L** | **3A (Gateway/Monitor)** | `[FZ-L]` | `workspaces/track_L` | `fz/track-L-gateway-and-monitor-hardening` | `simon_api.py` 1 MiB body limit + `signer_pinned` joblog + `simon_monitor.py` bounded `fetch_stats` + `--selfcheck` | [`parallel_agents/track_L_gateway_and_monitor_hardening/TASK_SPEC.md`](./parallel_agents/track_L_gateway_and_monitor_hardening/TASK_SPEC.md) | `tools/simon-api/simon_api.py`, `tools/simon-api/test_gateway.py`, `tools/simon-monitor/simon_monitor.py` |
| **Track M** | **3B (Industry Corpus)** | `[FZ-M]` | `workspaces/track_M` | `fz/track-M-industry-adversarial-corpus` | Unify NFKC/`Cf`/link/role/urgency checks across `tickets.py` & `agent_triage.py` + expand `stress_corpus.json` to 25 cases | [`parallel_agents/track_M_industry_adversarial_corpus/TASK_SPEC.md`](./parallel_agents/track_M_industry_adversarial_corpus/TASK_SPEC.md) | `tools/simon-industry/tickets.py`, `tools/simon-industry/agent_triage.py`, `tools/simon-industry/stress_corpus.json` |
| **Track N** | **3B (UI Polish)** | `[FZ-N]` | `workspaces/track_N` | `fz/track-N-ui-receipts-and-demo-polish` | `/receipts` claim-label reference table + `/demo` client-nonce replay tamper preset & `aria-pressed` semantics | [`parallel_agents/track_N_ui_receipts_and_demo_polish/TASK_SPEC.md`](./parallel_agents/track_N_ui_receipts_and_demo_polish/TASK_SPEC.md) | `ui/src/routes/receipts/+page.svelte`, `ui/src/routes/demo/+page.svelte` |

---

## 2. Mandatory 5-Phase Execution Workflow

Every Track agent MUST execute these 5 phases in order:

### Phase 1: Initialize Dedicated Subfolder & Clone Upstream (`simon-track-init` skill)
1. Read [`.agents/skills/simon-track-init/SKILL.md`](./.agents/skills/simon-track-init/SKILL.md) and run:
   ```bash
   bash .agents/skills/simon-track-init/scripts/init_track.sh <TRACK_LETTER>
   ```
   *(where `<TRACK_LETTER>` is `G`..`N`).*
2. This initializes `workspaces/_upstream_hub.git` with the shared `fz-contrib` base branch (`82baa8e`), clones `https://github.com/Szpili/SIMON.git` into `workspaces/track_<X>`, and checks out `fz/track-<X>-...` off `fz-contrib`.

### Phase 2: Read Captain Guardrails, Your Task Spec & Target Files
1. **MANDATORY FIRST READ:** Read [`.agents/skills/simon-captain-review-guardrails/SKILL.md`](./.agents/skills/simon-captain-review-guardrails/SKILL.md), [`parallel_agents/AGENT_RULES_COMMON.md`](./parallel_agents/AGENT_RULES_COMMON.md), and your assigned `TASK_SPEC.md`.
2. Activate the domain skill matching your track:
   - Tracks H, J, K, L: read [`.agents/skills/simon-crypto-and-protocol/SKILL.md`](./.agents/skills/simon-crypto-and-protocol/SKILL.md)
   - Tracks G, I, M, N: read [`.agents/skills/simon-industry-and-ui/SKILL.md`](./.agents/skills/simon-industry-and-ui/SKILL.md)
   - Any track touching Markdown with Mermaid charts: read [`.agents/skills/simon-mermaid-validator/SKILL.md`](./.agents/skills/simon-mermaid-validator/SKILL.md) and run `python3 scripts/check_mermaid.py <files>`
3. Inspect the exact lines of every target file inside `workspaces/track_<X>/` using `view_file` before writing any code.

### Phase 3: Implement in Self-Contained, Cherry-Pickable Commits
1. **Strict Scope Rule**: NEVER modify any file outside your Track's **Exclusive File Ownership** column. Do NOT touch `/home/agent/SIMON`.
2. **Cherry-Pickable Commit Rule**:
   - Implement one sub-task (`[FZ-<X>1]`, `[FZ-<X>2]`, ...) at a time inside `workspaces/track_<X>`.
   - Compile and run tests + `cargo clippy --workspace --all-targets -- -D warnings` after **each** sub-task (`export PATH="/home/agent/.cargo/bin:$PATH"`).
   - Commit with `[FZ-<X><N>]` prefix. Each commit must be 100% self-contained so the Team Captain can `git cherry-pick` it in isolation.

### Phase 4: 4-Pass Verification (`simon-verify-suite` skill)
1. Read [`.agents/skills/simon-verify-suite/SKILL.md`](./.agents/skills/simon-verify-suite/SKILL.md) and run:
   ```bash
   bash .agents/skills/simon-verify-suite/scripts/verify_track.sh <TRACK_LETTER> --final
   ```
2. Confirm all 4 passes (File Scope, Captain Guardrail Path/Overclaim & Mermaid Syntax Scan, Commit History, and Rust/Python/UI Test Suites) pass with zero errors or warnings.

### Phase 5: Merge Check, `fz-contrib` Integration & Pull Request (`simon-pr-delivery` skill)
1. Read [`.agents/skills/simon-pr-delivery/SKILL.md`](./.agents/skills/simon-pr-delivery/SKILL.md) and run:
   ```bash
   python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track <TRACK_LETTER>
   ```
2. This tool verifies zero conflicts against `fz-contrib` and all sibling tracks in the same stage, linearly integrates your commits onto `hub/fz-contrib`, pushes `fz-contrib` and `fz/track-<X>-...` to remote (if credentials exist), opens a PR targeting **`fz-contrib`** (never `main`), and writes the **Captain's Cherry-Pick Menu** to `parallel_agents/track_<X>_*/PR_SUBMISSION.md`.
