# SIMPN_ARGON_HANDOWER — Parallel Agent Workspace Rules (`AGENTS.md`)

You are an autonomous Antigravity coding agent operating inside **`SIMPN_ARGON_HANDOWER`**, the central audit and multi-agent orchestration workspace for the **SIMON** repository (`https://github.com/Szpili/SIMON.git`) competing in **AMD Developer Hackathon: ACT III**.

All parallel agents (`Track A` through `Track F`) initialize inside this shared workspace, clone the upstream `Szpili/SIMON` repository into their **own isolated subfolder** (`workspaces/track_<X>`), work exclusively on their **dedicated branch** and **strictly partitioned file scope**, make **granular, logical, non-breaking commits**, verify their work across multiple passes, and deliver a conflict-free **Pull Request**.

---

## 1. Track Routing Table (Identify Your Role Immediately)

When prompted with `"you are track <X> agent..."`, locate your assigned row below and obey its **Subfolder**, **Branch**, **Task Spec**, and **Exclusive File Scope**:

| Track | PR ID | Dedicated Clone Subfolder | Dedicated Branch Name | Task Specification | Exclusive File Ownership (ONLY touch these files in your clone) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Track A** | `PR-1` | `workspaces/track_A` | `fix/node-receipt-truth` | [`parallel_agents/track_A_receipt_and_node_truth/TASK_SPEC.md`](./parallel_agents/track_A_receipt_and_node_truth/TASK_SPEC.md) | `crates/simon-cli/src/node.rs` |
| **Track B** | `PR-2` | `workspaces/track_B` | `feat/live-m1-receipts` | [`parallel_agents/track_B_live_m1_token_binding/TASK_SPEC.md`](./parallel_agents/track_B_live_m1_token_binding/TASK_SPEC.md) | `crates/simon-cli/src/agent.rs`, `crates/simon-cli/src/wspolne.rs` |
| **Track C** | `PR-3` | `workspaces/track_C` | `feat/industry-m7-agent` | [`parallel_agents/track_C_industry_gemma4_live_agent/TASK_SPEC.md`](./parallel_agents/track_C_industry_gemma4_live_agent/TASK_SPEC.md) | `tools/simon-industry/**`, `ui/src/lib/industry-run.json`, `ui/src/routes/industry/+page.svelte` |
| **Track D** | `PR-4` | `workspaces/track_D` | `fix/core-security-hardening` | [`parallel_agents/track_D_core_security_and_wasm_fixes/TASK_SPEC.md`](./parallel_agents/track_D_core_security_and_wasm_fixes/TASK_SPEC.md) | `crates/simon-core/src/**`, `crates/simon-verify-wasm/src/lib.rs` |
| **Track E** | `PR-5` | `workspaces/track_E` | `feat/coordinator-gossipsub-bridge` | [`parallel_agents/track_E_p2p_coordinator_bridge/TASK_SPEC.md`](./parallel_agents/track_E_p2p_coordinator_bridge/TASK_SPEC.md) | `crates/simon-cli/src/coord.rs`, `crates/simon-cli/src/mapreduce.rs`, `crates/simon-node/src/lib.rs` |
| **Track F** | `PR-6` | `workspaces/track_F` | `fix/submission-and-ui-polish` | [`parallel_agents/track_F_submission_and_ui_polish/TASK_SPEC.md`](./parallel_agents/track_F_submission_and_ui_polish/TASK_SPEC.md) | `README.md`, `docs/zgloszenie/LABLAB-SUBMISSION.md`, `ui/src/routes/demo/+page.svelte`, `ui/src/routes/network/+page.svelte`, `tools/simon-api/simon_api.py`, `tools/simon-verifier/verifier_loop.py`, `demo/app.py`, `demo/app.en.py` |

---

## 2. Mandatory 5-Phase Execution Workflow

Every Track agent MUST execute these 5 phases in order:

### Phase 1: Initialize Dedicated Subfolder & Clone Upstream (`simon-track-init` skill)
1. Read and follow `.agents/skills/simon-track-init/SKILL.md`.
2. Run the initialization script from the handover root:
   ```bash
   bash .agents/skills/simon-track-init/scripts/init_track.sh <TRACK_LETTER>
   ```
   *(where `<TRACK_LETTER>` is `A`, `B`, `C`, `D`, `E`, or `F`).*
3. This script:
   - Initializes a shared local integration bare repo at `workspaces/_upstream_hub.git` (cloned from `https://github.com/Szpili/SIMON.git`) so parallel agents can cross-verify merges even offline.
   - Clones `https://github.com/Szpili/SIMON.git` into `workspaces/track_<X>` (and links `parallel_agents/track_<X>_*/repo` -> `workspaces/track_<X>`).
   - Checks out your dedicated branch (`fix/node-receipt-truth`, `feat/live-m1-receipts`, etc.) from `origin/main`.
   - Configures `.git/info/exclude` inside `workspaces/track_<X>` so your working tree stays 100% clean.

### Phase 2: Read Your Task Spec, Common Rules & Target Files
1. Read [`parallel_agents/AGENT_RULES_COMMON.md`](./parallel_agents/AGENT_RULES_COMMON.md) and your assigned `TASK_SPEC.md`.
2. Activate the domain skill matching your track:
   - Tracks A, B, D, E: read `.agents/skills/simon-crypto-and-protocol/SKILL.md`
   - Tracks C, F: read `.agents/skills/simon-industry-and-ui/SKILL.md`
3. Inspect the exact lines of every target file inside `workspaces/track_<X>/` using `view_file` before writing any code.

### Phase 3: Implement in Granular, Logical, Non-Breaking Commits
1. **Strict Scope Rule**: NEVER modify any file outside your Track's **Exclusive File Ownership** column. Do NOT modify files in the parent `SIMPN_ARGON_HANDOWER` repo (except when generating your final `PR_SUBMISSION.md` report in your track folder). Do NOT touch `/home/agent/SIMON`.
2. **Granular Commit Rule**: Break your implementation down by sub-task (`Task <X>.1`, `Task <X>.2`, `Task <X>.3`, plus unit tests):
   - Implement one logical change at a time inside `workspaces/track_<X>`.
   - After **each** sub-task, compile and run the relevant test suite (`export PATH="/home/agent/.cargo/bin:$PATH"`).
   - Only commit when the code compiles cleanly with zero warnings and all tests pass.
   - Use clear conventional commit messages in English:
     - `fix(node): populate Unix epoch timestamp_us in live receipts (BUG-01)`
     - `fix(node): derive BackendConfig precision from GGUF filename (BUG-02)`
     - `test(node): add unit tests for GGUF SHA-256 verification and precision`
   - Every Track should produce **2 to 5 atomic, logical commits**—never a single monolithic "do everything" commit and never a broken intermediate commit.

### Phase 4: Multi-Pass Verification (`simon-verify-suite` skill)
1. Read `.agents/skills/simon-verify-suite/SKILL.md` and run the automated multi-pass verifier:
   ```bash
   bash .agents/skills/simon-verify-suite/scripts/verify_track.sh <TRACK_LETTER>
   ```
2. This script checks:
   - **Pass 1 (File Scope & Clean Tree)**: `git status --porcelain` is empty and `git diff --name-only origin/main...HEAD` only contains files in your Track's Exclusive File Ownership list.
   - **Pass 2 (Commit Granularity)**: At least 2 logical commits on your branch ahead of `origin/main`.
   - **Pass 3 (Compilation, Clippy, Constants Guard & Tests)**: Runs `cargo test`, `cargo clippy -- -D warnings`, `python3 scripts/wartownik_stalych.py`, Python tests, and SvelteKit `npm run check && npm run build` as appropriate.
3. Re-read your `git diff origin/main...HEAD` line-by-line to confirm all edge cases in `TASK_SPEC.md` are addressed.

### Phase 5: Merge Conflict Check & Pull Request Delivery (`simon-pr-delivery` skill)
1. Read `.agents/skills/simon-pr-delivery/SKILL.md` and run:
   ```bash
   python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track <TRACK_LETTER>
   ```
2. This tool:
   - Fetches the latest `main` from `https://github.com/Szpili/SIMON.git` and rebases your branch cleanly onto `origin/main`.
   - Pushes your branch to the shared local integration hub (`workspaces/_upstream_hub.git`) AND tests a dry-run merge against **all other completed Track branches** (`A`–`F`) in the hub, resolving or reporting any merge issues.
   - Attempts to push your branch to the upstream/fork GitHub remote (`origin` / `SIMON_FORK_URL`) and, if `gh` or `GITHUB_TOKEN` is available, automatically opens the GitHub Pull Request.
   - Writes a complete, review-ready Pull Request specification and verification log to `parallel_agents/track_<X>_*/PR_SUBMISSION.md`.

---

## 3. Critical Technical Invariants (Always Enforced)

1. **Toolchain Paths**:
   - Rust (`cargo`, `rustc`, `wasm-pack`): Always prepend `export PATH="/home/agent/.cargo/bin:$PATH"` in `run_command`.
   - Node (`node`, `npm`): `/usr/local/bin/node`, `/usr/local/bin/npm`.
   - Python: `/usr/bin/python3`.
2. **Cryptographic Domain Separators (NEVER alter)**:
   - `DOMENA_RECEIPT = "SIMON-RECEIPT-v1"`
   - `DOMENA_M1_TOKEN = "SIMON-M1-TOKEN-v1"`
   - `DOMENA_M1_KORZEN = "SIMON-M1-ROOT-v1"`
   - `DOMENA_M3_LOGPROB = "SIMON-M3-LOGPROB-v1"`
   - `DOMENA_CAP = "SIMON-CAP-v1"`, `DOMENA_WEIGHTS = "SIMON-WEIGHTS-v1"`, `DOMENA_PROMPT = "SIMON-PROMPT-v1"`, `DOMENA_OUTPUT = "SIMON-OUTPUT-v1"`, `DOMENA_CONFIG = "SIMON-CONFIG-v1"`
   - Run `python3 scripts/wartownik_stalych.py` inside `workspaces/track_<X>` after any core/CLI change.
3. **Bilingual Rust Codebase Convention**:
   - Rust struct/field/function identifiers in `simon-core` and `simon-cli` are in **Polish**, while JSON wire format uses `#[serde(rename = "...")]` in **English** (with `#[serde(alias = "...")]` for Polish). Preserve all existing serde renames and aliases.
4. **Error Handling**:
   - Never use `.unwrap()` or `.expect()` in library production paths (`simon-core`, `simon-verify-wasm`, `simon-harness`, `simon-node`); propagate errors via `Result<T, Blad*>` and `thiserror`.
