# Track F — Submission Consistency, UI Tamper/Topology Polish & Python Tool Hardening (`[FZ-F]` · Upstream PR #6)

**Stage:** Stage 1 (Wave 1A — Urgent)  
**Live Upstream PR:** **[Szpili/SIMON PR #6](https://github.com/Szpili/SIMON/pull/6)** (Waiting for Merge)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-F-submission-and-ui-polish`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_F`  
**Exclusive Permitted Files:**
* `README.md`
* `docs/zgloszenie/LABLAB-SUBMISSION.md`
* `ui/src/routes/demo/+page.svelte`
* `ui/src/routes/network/+page.svelte`
* `ui/src/lib/components/NodePanel.svelte`
* `tools/simon-api/simon_api.py`
* `tools/simon-verifier/verifier_loop.py`
* `demo/app.py`
* `demo/app.en.py`

*(100% file-disjoint from all Rust crates and `tools/simon-industry/**`!)*

---

## Context & Problem Statement

Clean up all presentation, UI, and Python tool issues identified in the audit so judges inspecting the SvelteKit UI, submission markdown, or Python tools encounter zero contradictions or security anti-patterns:
1. **`docs/zgloszenie/LABLAB-SUBMISSION.md` & `README.md`:** Ensure test count descriptions and AMD Instinct MI300X / Gemma 4 benchmark summaries are 100% consistent across both files (`5` Rust workspace crates in `Cargo.toml` + Python industry/canary self-checks).
2. **`ui/src/routes/demo/+page.svelte` & `ui/src/lib/components/NodePanel.svelte`:** Currently, the tamper buttons on `/demo` only mutate `output0 = output0 + ' '` (Level 0) or `outTok` token 5 (Level 1), which only tests `tresc_ok: false` / `m1_ok: false` while `podpis_ok` stays `true`! Judges have no button to test **Ed25519 signature rejection (`podpis_ok: false`)** directly in the UI!
3. **`ui/src/routes/network/+page.svelte`:** Add a clear, honest `"SIMULATED P2P TOPOLOGY PREVIEW"` badge in the `/network` header so judges know the SVG topology animation is a visual simulation rather than live telemetry.
4. **`tools/simon-api/simon_api.py`:** Currently `simon_api.py` hardcodes `"proof_level": 0` at lines 71 and 128 instead of reading `rc.get("wiazania", {}).get("receipt_level", 0)` from the signed receipt, and has no optional `SIMON_API_KEY` Bearer token check.
5. **`tools/simon-verifier/verifier_loop.py` & `demo/app.py` / `demo/app.en.py`:** Add `--dry-run` / `--selfcheck` verification to `verifier_loop.py` and ensure `demo/app.py` and `demo/app.en.py` display accurate `"SIMON/RECEIPT/v1"` / `"SIMON/OUTPUT/v1"` SHA-256 domain labels matching `crates/simon-core/src/receipt.rs`.

---

## Step-by-Step Implementation Instructions (Commit Each Task with `[FZ-F<N>]`)

### Task F1 (`[FZ-F1]`): Add Real Ed25519 Signature Tamper Button to `/demo` (`ui/src/routes/demo/+page.svelte` & `ui/src/lib/components/NodePanel.svelte`) & Simulation Badge to `/network` (`ui/src/routes/network/+page.svelte`)
1. In `ui/src/lib/components/NodePanel.svelte` and `ui/src/routes/demo/+page.svelte`:
   * Add an optional `onTamperSig?: () => void` prop to `NodePanel.svelte` and render a `"Tamper signature"` button alongside the existing `"Tamper +1 space"` / `"Tamper token 5"` button.
   * In `ui/src/routes/demo/+page.svelte`, implement `tamperSigL0()` and `tamperSigL1()` that flip the first two hex characters of `r0.signature` / `r1.signature` (e.g. toggling `'0'` $\leftrightarrow$ `'f'`) so clicking `"Tamper signature"` causes the WASM Ed25519 verifier to return `podpis_ok: false` (`Signature: INVALID`)!
2. In `ui/src/routes/network/+page.svelte`:
   * Add a clear badge in the top bar: `SIMULATED P2P TOPOLOGY (8-NODE REFERENCE MESH)` so judges do not mistake the `setInterval` animation for live telemetry.

### Task F2 (`[FZ-F2]`): Make `tools/simon-api/simon_api.py` M1-Aware + Optional `SIMON_API_KEY` Auth, and Polish `verifier_loop.py`, `demo/app.py`, `demo/app.en.py`
1. In `tools/simon-api/simon_api.py`:
   * At lines 71 and 128, replace `"proof_level": 0,` with:
     ```python
     "proof_level": (rc.get("wiazania") or {}).get("receipt_level", 0) if isinstance(rc, dict) else 0,
     ```
   * Add optional `SIMON_API_KEY` environment variable check in `Handler`: if `os.environ.get("SIMON_API_KEY")` is set and non-empty, require `Authorization: Bearer <SIMON_API_KEY>` on `/v1/*` requests (returning `401 Unauthorized` otherwise). When `SIMON_API_KEY` is unset, keep local `127.0.0.1` access open so existing local scripts continue to work seamlessly.
2. In `tools/simon-verifier/verifier_loop.py`:
   * Validate `args.node` against URL/multiaddr characters so malformed arguments are rejected cleanly before `subprocess.run`.
3. In `demo/app.py` and `demo/app.en.py`:
   * Ensure any receipt domain explanation references `SIMON/RECEIPT/v1` and `SIMON/OUTPUT/v1` (SHA-256 + Ed25519).

### Task F3 (`[FZ-F3]`): Ensure `README.md` & `docs/zgloszenie/LABLAB-SUBMISSION.md` Crate & Test Counts Are 100% Aligned
1. In `README.md` and `docs/zgloszenie/LABLAB-SUBMISSION.md`:
   * Ensure any mention of workspace crates explicitly notes the 5 Rust crates (`simon-core`, `simon-verify-wasm`, `simon-harness`, `simon-node`, `simon-cli`) + Python industry/verifier self-check suites, and that all MI300X (`199.1 tok/s`, `8/8 CANARY-7`) and RTX 3090 (`61.8 tok/s`) metrics match across both documents.

---

## Granular Commit Plan (Cherry-Pickable by Team Captain)
1. `[FZ-F1] feat(ui): add Ed25519 signature tamper button to /demo and simulation badge to /network`
2. `[FZ-F2] fix(tools): make simon_api.py proof_level M1-aware and add optional SIMON_API_KEY auth`
3. `[FZ-F3] docs(submission): align crate/test counts and MI300X metrics across README and LABLAB-SUBMISSION`

---

## Verification & PR Delivery
```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh F --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track F
```
