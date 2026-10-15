# SIMPN_ARGON_HANDOWER — Parallel Agent Workspace Rules (`AGENTS.md`)

You are an autonomous Antigravity coding agent operating inside **`SIMPN_ARGON_HANDOWER`**, the central audit and multi-agent orchestration workspace for the **SIMON** repository (`https://github.com/Szpili/SIMON.git`) competing in **AMD Developer Hackathon: ACT III**.

---

## 0. Golden Rule: Target `fz-contrib` (NEVER `main`) & Keep Commits Cherry-Pickable

To protect the upstream `Szpili/SIMON` `main` branch and eliminate the **Team Captain review bottleneck**:
1. **Dedicated Base Branch (`fz-contrib`)**: Every Track agent branches off **`fz-contrib`** into `fz/track-<X>-<slug>` and targets **`fz-contrib`** (NEVER `main`) when creating a Pull Request.
2. **Self-Contained, Cherry-Pickable Commits (`[FZ-<X><N>]`)**: Prefix every commit message with `[FZ-<X>1]`, `[FZ-<X>2]`, etc. (e.g., `[FZ-A1] fix(node): populate real Unix timestamp_us in live Receipt (BUG-01)`). Every single commit MUST compile and pass tests independently so the Team Captain can cherry-pick individual fixes onto `main` in seconds.

---

## 1. Track Routing Table (Stage 1: Tracks A–F | Stage 2: Tracks G–I)

When prompted with `"you are track <X> agent..."`, locate your assigned row below and obey its **Subfolder**, **Branch**, **Task Spec**, and **Exclusive File Scope**:

### Stage 1 Tracks (Independent & Disjoint — Can Run in Parallel or in Priority Waves)

| Track | Wave | PR ID | Dedicated Clone Subfolder | Dedicated Track Branch (`-> fz-contrib`) | Task Specification | Exclusive File Ownership (ONLY touch these files) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Track D** | **1A (Urgent)** | `PR-4` | `workspaces/track_D` | `fz/track-D-core-security-hardening` | [`parallel_agents/track_D_core_security_and_wasm_fixes/TASK_SPEC.md`](./parallel_agents/track_D_core_security_and_wasm_fixes/TASK_SPEC.md) | `crates/simon-core/src/**`, `crates/simon-verify-wasm/src/lib.rs` |
| **Track A** | **1A (Urgent)** | `PR-1` | `workspaces/track_A` | `fz/track-A-node-receipt-truth` | [`parallel_agents/track_A_receipt_and_node_truth/TASK_SPEC.md`](./parallel_agents/track_A_receipt_and_node_truth/TASK_SPEC.md) | `crates/simon-cli/src/node.rs` |
| **Track F** | **1A (Urgent)** | `PR-6` | `workspaces/track_F` | `fz/track-F-submission-and-ui-polish` | [`parallel_agents/track_F_submission_and_ui_polish/TASK_SPEC.md`](./parallel_agents/track_F_submission_and_ui_polish/TASK_SPEC.md) | `README.md`, `docs/zgloszenie/LABLAB-SUBMISSION.md`, `ui/src/routes/demo/+page.svelte`, `ui/src/routes/network/+page.svelte`, `tools/simon-api/simon_api.py`, `tools/simon-verifier/verifier_loop.py`, `demo/app.py`, `demo/app.en.py` |
| **Track C** | **1B (Feature)** | `PR-3` | `workspaces/track_C` | `fz/track-C-industry-m7-agent` | [`parallel_agents/track_C_industry_gemma4_live_agent/TASK_SPEC.md`](./parallel_agents/track_C_industry_gemma4_live_agent/TASK_SPEC.md) | `tools/simon-industry/**`, `ui/src/lib/industry-run.json`, `ui/src/routes/industry/+page.svelte` |
| **Track B** | **1B (Feature)** | `PR-2` | `workspaces/track_B` | `fz/track-B-live-m1-receipts` | [`parallel_agents/track_B_live_m1_token_binding/TASK_SPEC.md`](./parallel_agents/track_B_live_m1_token_binding/TASK_SPEC.md) | `crates/simon-cli/src/agent.rs`, `crates/simon-cli/src/wspolne.rs` |
| **Track E** | **1B (Feature)** | `PR-5` | `workspaces/track_E` | `fz/track-E-coordinator-gossipsub-bridge` | [`parallel_agents/track_E_p2p_coordinator_bridge/TASK_SPEC.md`](./parallel_agents/track_E_p2p_coordinator_bridge/TASK_SPEC.md) | `crates/simon-cli/src/coord.rs`, `crates/simon-cli/src/mapreduce.rs`, `crates/simon-node/src/lib.rs` |

### Stage 2 Tracks (Run AFTER Stage 1 Tracks A–F Are Integrated into `fz-contrib`)

| Track | Wave | PR ID | Dedicated Clone Subfolder | Dedicated Track Branch (`-> fz-contrib`) | Task Specification | Exclusive File Ownership (ONLY touch these files) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Track G** | **Stage 2** | `PR-7` | `workspaces/track_G` | `fz/track-G-architecture-and-docs-overhaul` | [`parallel_agents/track_G_architecture_and_docs_overhaul/TASK_SPEC.md`](./parallel_agents/track_G_architecture_and_docs_overhaul/TASK_SPEC.md) | `docs/ARCHITECTURE.md`, `docs/THREAT-MODEL.md`, `ROADMAP.md`, `docs/whitepaper/SIMON-whitepaper-EN.md` |
| **Track H** | **Stage 2** | `PR-8` | `workspaces/track_H` | `fz/track-H-e2e-integration-and-live-m1-bridge` | [`parallel_agents/track_H_e2e_integration_and_live_m1_bridge/TASK_SPEC.md`](./parallel_agents/track_H_e2e_integration_and_live_m1_bridge/TASK_SPEC.md) | `crates/simon-cli/src/node.rs`, `crates/simon-cli/tests/e2e_m1_receipt.rs` |
| **Track I** | **Stage 2** | `PR-9` | `workspaces/track_I` | `fz/track-I-captain-cherry-pick-menu-and-ci` | [`parallel_agents/track_I_captain_cherry_pick_menu_and_ci/TASK_SPEC.md`](./parallel_agents/track_I_captain_cherry_pick_menu_and_ci/TASK_SPEC.md) | `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md`, `scripts/verify_all_fast.sh` |

---

## 2. Mandatory 5-Phase Execution Workflow

Every Track agent MUST execute these 5 phases in order:

### Phase 1: Initialize Dedicated Subfolder & Clone Upstream (`simon-track-init` skill)
1. Read `.agents/skills/simon-track-init/SKILL.md` and run:
   ```bash
   bash .agents/skills/simon-track-init/scripts/init_track.sh <TRACK_LETTER>
   ```
   *(where `<TRACK_LETTER>` is `A`..`I`).*
2. This initializes `workspaces/_upstream_hub.git` with the shared `fz-contrib` base branch, clones `https://github.com/Szpili/SIMON.git` into `workspaces/track_<X>`, and checks out `fz/track-<X>-...` off `fz-contrib`.

### Phase 2: Read Your Task Spec, Common Rules & Target Files
1. Read [`parallel_agents/AGENT_RULES_COMMON.md`](./parallel_agents/AGENT_RULES_COMMON.md) and your assigned `TASK_SPEC.md`.
2. Activate the domain skill matching your track:
   - Tracks A, B, D, E, H: read `.agents/skills/simon-crypto-and-protocol/SKILL.md`
   - Tracks C, F, G, I: read `.agents/skills/simon-industry-and-ui/SKILL.md`
3. Inspect the exact lines of every target file inside `workspaces/track_<X>/` using `view_file` before writing any code.

### Phase 3: Implement in Self-Contained, Cherry-Pickable Commits
1. **Strict Scope Rule**: NEVER modify any file outside your Track's **Exclusive File Ownership** column. Do NOT touch `/home/agent/SIMON`.
2. **Cherry-Pickable Commit Rule**:
   - Implement one sub-task (`Task <X>.1`, `Task <X>.2`, ...) at a time inside `workspaces/track_<X>`.
   - Compile and run tests after **each** sub-task (`export PATH="/home/agent/.cargo/bin:$PATH"`).
   - Commit with `[FZ-<X><N>]` prefix:
     - `[FZ-A1] fix(node): populate Unix epoch timestamp_us in live receipts (BUG-01)`
     - `[FZ-A2] fix(node): derive BackendConfig precision from GGUF filename (BUG-02)`
     - `[FZ-A3] fix(node): verify GGUF SHA-256 against --weights-hash at startup (BUG-05)`
   - Each commit must be 100% self-contained so the Team Captain can `git cherry-pick` it in isolation.

### Phase 4: Multi-Pass Verification (`simon-verify-suite` skill)
1. Read `.agents/skills/simon-verify-suite/SKILL.md` and run:
   ```bash
   bash .agents/skills/simon-verify-suite/scripts/verify_track.sh <TRACK_LETTER> --final
   ```
2. Confirm all 3 passes (File Scope, Commit History, and Rust/Python/UI Test Suites) pass with zero errors or warnings.

### Phase 5: Merge Check, `fz-contrib` Integration & Pull Request (`simon-pr-delivery` skill)
1. Read `.agents/skills/simon-pr-delivery/SKILL.md` and run:
   ```bash
   python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track <TRACK_LETTER>
   ```
2. This tool verifies zero conflicts against `fz-contrib` and all sibling tracks, linearly integrates your commits onto `hub/fz-contrib`, pushes `fz-contrib` and `fz/track-<X>-...` to remote (if credentials exist), opens a PR targeting **`fz-contrib`** (never `main`), and writes the **Captain's Cherry-Pick Menu** to `parallel_agents/track_<X>_*/PR_SUBMISSION.md`.
