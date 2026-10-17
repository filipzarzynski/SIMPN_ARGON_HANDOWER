# Common Rules & Environment Guide for All SIMON Coding Agents

Every agent working on a SIMON feature branch MUST follow these rules without exception.

---

## 1. Non-Negotiable Repository, Security & Captain Guardrail Rules

1. **Do NOT pollute `/home/agent/SIMON` or target `main` directly:**
   * Always work inside your dedicated clone directory `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_<X>` initialized via `bash .agents/skills/simon-track-init/scripts/init_track.sh <X>`.
   * Always branch off `fz-contrib` (`8fbe206`) into `fz/track-<X>-<slug>` and target **`fz-contrib`** (NEVER `main`) when creating a PR.
   * Prefix every commit with `[FZ-<X><N>]` (e.g., `[FZ-H1] feat(cli): wire live M1 token chain with MAX_M1_TOKENS cap`). Every commit must compile and pass tests independently so the Team Captain can cherry-pick individual commits onto `main`.
2. **Mandatory Captain Review Guardrails ([`simon-captain-review-guardrails`](../.agents/skills/simon-captain-review-guardrails/SKILL.md)):**
   * **Never guess a signed claim:** Unknown quantization/precision $\rightarrow$ `Precision::Unknown` (never default to `Fp16` or map integer quant to `Fp4`/`Fp8`). Unknown proof level $\rightarrow$ `poziom_sprawdzony` (never node-declared `receipt.poziom()`). Nonce verification $\rightarrow$ always use the client's own `order.nonce` (never fall back to `receipt.wiazania.client_nonce`).
   * **Strict claim discipline (`docs/THREAT-MODEL.md` & `docs/STRESS-TESTS.md`):** SIMON is a **verifiable inference-result publication** layer, NOT an execution-proof layer. Never write `"100% Authentic"`, `"100% Cryptographically Verified"`, `"guarantees the model ran"`, `"SIMULATED P2P TOPOLOGY"`, or fake `"ed25519:operator_sig_..."`.
   * **Governing rule (`no evidence, no status`):** Never publish unbacked `tok/s` numbers (such as `61.8` or `199.1 tok/s` for Gemma 4) or fragile hardcoded test counts (`"255 tests"`).
   * **Never leak local workspace paths:** Never include `SIMPN_ARGON_HANDOWER` or `/home/agent/` in any file inside the SIMON repository.
   * **Enforce bounds on untrusted network inputs:** Cap token arrays at `MAX_M1_TOKENS = 65_536`, HTTP bodies at `1 MiB`, and verify node signatures before mutating coordinator `Registry` state.
3. **Preserve Existing Bilingual Naming Conventions:**
   * The Rust codebase uses Polish identifiers for internal domain functions/types (e.g., `zweryfikuj_m1`, `odcisk_wyjscia`, `Zezwolenie`, `Sufit`, `kandydaci_dla_modelu`) and English for wire-serialized JSON fields (`job_id`, `model_hash`, `output_digest`, `started_at_us`, `finished_at_us`). **Never rename existing public structs, functions, or JSON fields**, or you will break existing tests and wire compatibility!
4. **Never Hardcode Fake Metrics or Constants:**
   * The repository has an automated linter `python3 scripts/wartownik_stalych.py` that scans `crates/**/*.rs` for hardcoded throughput divisors (`tokens / <number>`) and fails CI if found.
5. **No Floating-Point Numbers in `content_digest`:**
   * Never pass `f32`/`f64` inside any struct hashed by `simon_core::content_digest`. Always use scaled integers (`u64`/`i64`).
6. **Preserve Documentation Integrity:**
   * Do not delete existing comments or docstrings unless updating an explicitly inaccurate doc comment noted in your `TASK_SPEC.md`.
7. **Strict Mermaid Diagram Syntax Rules for Documentation ([`simon-mermaid-validator`](../.agents/skills/simon-mermaid-validator/SKILL.md)):**
   * Always quote flowchart node labels containing special characters, parentheses, brackets, or commas: `id["Label (Extra Info)"]`.
   * Never use semicolons `;` inside `sequenceDiagram` `Note over ...:` text or message labels (in Mermaid, `;` terminates the statement and causes the parser to treat following words as arrow operators).
   * Never use unescaped arrows (`->`, `-->`, `--`, `->>`) inside sequence diagram note text (use `yields`, `sending`, or `to`).
   * Never use angle-bracket placeholders (`<pubkey>`, `<node_id>`) in Mermaid diagrams (they are parsed as HTML tags); use `[pubkey]` or `(node_id)`.
   * Never use double pipes (`||`) inside `|...|` edge labels in flowcharts.
   * Always run `python3 scripts/check_mermaid.py <changed_files>` before staging commits that touch Markdown files.

---

## 2. Environment & Toolchain Setup on This Machine

* **Pre-installed binaries:**
  * Rust (`cargo` / `rustc` `1.99.1`): `/home/agent/.cargo/bin` (Always run `export PATH="/home/agent/.cargo/bin:$PATH"`)
  * Python 3: `/usr/bin/python3`
  * Git: `/usr/bin/git`
  * Node.js & npm: `/usr/local/bin/node`, `/usr/local/bin/npm`
  * Ollama: `/usr/local/bin/ollama`

---

## 3. Standard Verification Commands Before Committing

Before marking your track complete, run `bash .agents/skills/simon-verify-suite/scripts/verify_track.sh <X> --final`, which executes the 4-pass verification suite:

* **Rust Workspace Tests & Clippy (`--all-targets`):**
  ```bash
  export PATH="/home/agent/.cargo/bin:$PATH"
  python3 scripts/wartownik_stalych.py
  cargo test --workspace
  cargo clippy --workspace --all-targets -- -D warnings
  ```
* **Python Self-Checks:**
  ```bash
  python3 tools/simon-industry/rules.py
  python3 -c 'import sys; sys.path.insert(0, "tools/simon-industry"); import tickets; tickets.selfcheck()'
  python3 tools/simon-industry/agent_triage.py --selfcheck
  python3 tools/simon-industry/export_ui.py
  python3 tools/simon-api/test_gateway.py
  python3 -c 'import sys; sys.path.insert(0, "tools/simon-monitor"); import simon_monitor; simon_monitor.selfcheck()'
  ```
* **UI Build Check (`ui/`):**
  ```bash
  npm --prefix ui run check
  npm --prefix ui run build
  ```
