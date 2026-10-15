# Common Rules & Environment Guide for All SIMON Coding Agents

Every agent working on a SIMON feature branch MUST follow these rules without exception.

---

## 1. Non-Negotiable Repository & Codebase Rules

1. **Do NOT pollute `/home/agent/SIMON` `main` branch:**
   * Always work in your assigned feature branch or git worktree (`/home/agent/SIMPN_ARGON_HANDOWER/worktrees/<track>`).
2. **Preserve Existing Bilingual Naming Conventions:**
   * The Rust codebase uses Polish identifiers for internal domain functions/types (e.g., `zweryfikuj_m1`, `odcisk_wyjscia`, `Zezwolenie`, `Sufit`, `kandydaci_dla_modelu`) and English for wire-serialized JSON fields (`job_id`, `model_hash`, `output_digest`, `started_at_us`). **Never rename existing public structs, functions, or JSON fields**, or you will break existing tests and wire compatibility!
3. **Never Hardcode Fake Metrics or Constants:**
   * The repository has an automated linter `python3 scripts/wartownik_stalych.py` that scans `crates/**/*.rs` for hardcoded throughput divisors (`tokens / <number>`) and fails CI if found.
4. **No Floating-Point Numbers in `content_digest`:**
   * Never pass `f32`/`f64` inside any struct hashed by `simon_core::content_digest`. Always use scaled integers (`u64`/`i64`).
5. **Preserve Documentation Integrity:**
   * Do not delete existing comments or docstrings unless updating an explicitly inaccurate doc comment noted in your `TASK_SPEC.md`.

---

## 2. Environment & Toolchain Setup on This Machine

* **Pre-installed binaries:**
  * Python 3: `/usr/bin/python3`
  * Git: `/usr/bin/git`
  * Node.js & npm: `/usr/local/bin/node`, `/usr/local/bin/npm`
  * Ollama: `/usr/local/bin/ollama`
* **Rust (`cargo` / `rustc`):**
  * If `cargo` is not yet in `~/.cargo/bin`, install it once via:
    ```bash
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
    export PATH="$HOME/.cargo/bin:$PATH"
    ```
  * If building `simon-verify-wasm` for the UI:
    ```bash
    rustup target add wasm32-unknown-unknown
    cargo install wasm-bindgen-cli
    ```

---

## 3. Standard Verification Commands Before Committing

Before marking your track complete, run the relevant checks for your scope:

* **Rust Workspace Tests:**
  ```bash
  export PATH="$HOME/.cargo/bin:$PATH"
  cargo test --workspace
  python3 scripts/wartownik_stalych.py
  ```
* **Python Self-Checks:**
  ```bash
  python3 tools/simon-industry/rules.py
  python3 tools/simon-industry/tickets.py --help
  python3 tools/simon-canary/simon_canary.py --help
  python3 tools/simon-api/check_failover.py
  ```
* **UI Build Check (`ui/`):**
  ```bash
  npm --prefix ui run check
  npm --prefix ui run build
  ```
