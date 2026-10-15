# Agent Task Specification: Track F — Submission Consistency, UI Polish & Security Hardening (`PR-6`)

**Target Branch:** `fix/submission-and-ui-polish`
**Assigned Role:** Full-Stack UI, Python Tooling & Documentation Engineer (Gemini 3.8 Flash High)
**Estimated Time:** ~1.5–2 hours
**Prerequisite Reading:** [`../AGENT_RULES_COMMON.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/AGENT_RULES_COMMON.md), [`../../03_CODEBASE_AUDIT_TOOLS_AND_UI.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/03_CODEBASE_AUDIT_TOOLS_AND_UI.md), [`../../04_CLAIMS_VS_REALITY_MATRIX.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/04_CLAIMS_VS_REALITY_MATRIX.md)

---

## 1. Objective

Clean up all presentation, UI, and Python tool bugs identified in the audit so judges inspecting the SvelteKit UI, submission markdown, or Python tools encounter zero contradictions or security anti-patterns:
1. **`BUG-16` (`docs/zgloszenie/LABLAB-SUBMISSION.md` & `README.md`):** Reconcile the contradiction where `LABLAB-SUBMISSION.md:30` says *"Total across all 7 workspace crates: 211 tests"* while `Cargo.toml` has **5** workspace crates with **187** Rust tests (+ 24 Python tests = 211 total), and where `LABLAB-SUBMISSION.md:45` lists `M14` as *"pending hardware slot"* right above the completed MI300X results table.
2. **`BUG-13` (`ui/src/routes/network/+page.svelte`):** Either clearly label the `/network` 8-node SVG topology and `4812` receipts counter as `"SIMULATED TOPOLOGY PREVIEW"` in the UI badge, or wire it to fetch live data from `/api/status` when `simon_api.py` is running (falling back to simulation banner when offline).
3. **`BUG-14` (`ui/src/routes/demo/+page.svelte`):** Clarify the *"Tamper with signature"* button in `/demo` so it is accurately labeled (`"Strip signature / M0 payload tamper"` + add an actual 1-bit flip in `podpis_wykonawcy` hex button that tests real Ed25519 signature rejection!).
4. **`BUG-10` (`tools/simon-api/simon_api.py`):** Remove the hardcoded `"simon-demo-key"` default API key and require `SIMON_API_KEY` env var (or generate a random ephemeral key printed at startup).
5. **`BUG-11` (`tools/simon-verifier/verifier_loop.py`):** Replace `shell=True` in `subprocess.run(args.simon_cmd, shell=True, ...)` with `shlex.split(args.simon_cmd)` (`shell=False`).
6. **`BUG-12` (`demo/app.py` and `demo/app.en.py`):** Fix `hashlib.sha256()` receipt ID display in the Streamlit demo to use `blake3` (or clearly compute the matching domain hash) so it matches the Rust protocol.

---

## 2. Permitted Files (Strict Scope)

You may **ONLY** modify:
- `README.md`
- `docs/zgloszenie/LABLAB-SUBMISSION.md`
- `ui/src/routes/network/+page.svelte`
- `ui/src/routes/demo/+page.svelte`
- `tools/simon-api/simon_api.py`
- `tools/simon-verifier/verifier_loop.py`
- `demo/app.py`
- `demo/app.en.py`

Do **NOT** touch any Rust files (`crates/**`) or `tools/simon-industry/**`.

---

## 3. Exact Findings & Line Numbers to Fix

### Task F.1: Fix `LABLAB-SUBMISSION.md` & `README.md` (`BUG-16`)
1. In [`docs/zgloszenie/LABLAB-SUBMISSION.md:20-55`](file:///home/agent/SIMON/docs/zgloszenie/LABLAB-SUBMISSION.md#L20-L55):
   - Change *"Total across all 7 workspace crates: 211 tests, 0 failures"* to accurately state: *"Total across all 5 Rust workspace crates + Python verification suites: 211 tests (187 Rust + 24 Python), 0 failures"*.
   - Update line 45 in the milestone table so `M14` says `done (199.1 tok/s on MI300X, 8/8 CANARY-7)` instead of `pending hardware slot`.
2. In [`README.md`](file:///home/agent/SIMON/README.md):
   - Ensure the test count breakdown (`187 Rust tests across 5 crates + 24 Python industry/verifier tests = 211 total`) is consistent.

### Task F.2: Fix `/demo` Tamper Buttons (`BUG-14`)
Inspect [`ui/src/routes/demo/+page.svelte:72-95`](file:///home/agent/SIMON/ui/src/routes/demo/+page.svelte#L72-L95):
- Currently, `tamperSignature()` sets `signature_hex: null` and `payload_hash_hex: 'deadbeef...'`.
- **Fix:**
  - Keep a button for `"Flip 1 byte in Ed25519 signature"` that flips the first byte of `signature_hex` (e.g. `^ 0xff`) while keeping `signature_hex` 64 bytes (128 hex chars) so the WASM verifier actually exercises Ed25519 signature verification failure (`signature verification failed`).
  - Keep a separate button for `"Tamper output text / hash"` that modifies `output_text` without updating the signature.

### Task F.3: Label `/network` Simulation Clearly (`BUG-13`)
Inspect [`ui/src/routes/network/+page.svelte:1-120`](file:///home/agent/SIMON/ui/src/routes/network/+page.svelte#L1-L120):
- Add a clear badge in the header: `SIMULATED P2P TOPOLOGY (8-NODE REFERENCE MESH)` so judges do not mistake the hardcoded `setInterval` animation for live telemetry, while keeping the visual presentation intact.

### Task F.4: Harden `simon_api.py` (`BUG-10`) & `verifier_loop.py` (`BUG-11`)
1. In [`tools/simon-api/simon_api.py:42`](file:///home/agent/SIMON/tools/simon-api/simon_api.py#L40-L50):
   - Replace `API_KEY = os.environ.get("SIMON_API_KEY", "simon-demo-key")` with:
     ```python
     API_KEY = os.environ.get("SIMON_API_KEY") or secrets.token_urlsafe(24)
     ```
     (and log a warning if generated ephemerally).
2. In [`tools/simon-verifier/verifier_loop.py:73-77`](file:///home/agent/SIMON/tools/simon-verifier/verifier_loop.py#L70-L82):
   - Import `shlex` and replace `subprocess.run(cmd, shell=True, ...)` with `subprocess.run(shlex.split(cmd), shell=False, ...)`.

---

## 4. Verification Commands

Run inside your worktree:
```bash
python3 -m py_compile tools/simon-api/simon_api.py tools/simon-verifier/verifier_loop.py demo/app.py demo/app.en.py
cd ui && npm run check && npm run build
```
