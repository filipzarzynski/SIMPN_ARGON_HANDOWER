# Track C — Upgrade Intelligent Industry with M7 Capability Grants (`Zezwolenie`), Autonomous Tool-Calling Triage & Interactive UI (`PR-3`)

**Branch Name:** `feat/industry-m7-agent`  
**Worktree Path:** `/home/agent/SIMPN_ARGON_HANDOWER/worktrees/track_C`  
**Owned Files:**
* `tools/simon-industry/tickets.py`
* `tools/simon-industry/agent_triage.py` (new file)
* `tools/simon-industry/export_ui.py`
* `ui/src/routes/industry/+page.svelte`

---

## Context & Problem Statement

For the **AMD Developer Hackathon: ACT III**, the judging rubric scores:
1. **Technology & Autonomous Behavior**
2. **Use Case & Business Impact (Track 1: Intelligent Industry)**
3. **Presentation & Demo**
4. **Use of Sponsor Technologies (Google Gemma 4 + AMD Instinct MI300X ROCm)**

Right now:
* `tools/simon-industry/tickets.py` makes a **single one-shot prompt** to Gemma 4 (`gemma-4-26b-a4b-it-qat-q4_0` on RTX 3090 and `gemma-4-26b-a4b-it-bf16` on AMD MI300X), without using SIMON's already-implemented OpenAI tool-calling support (`crates/simon-cli/src/node.rs:407-486` and `tools/simon-api/check_tools.py`).
* Even worse, SIMON's core security module `crates/simon-core/src/cap.rs` (`Sufit` capability ceiling + `Zezwolenie` single-use Ed25519 operator grants under `"SIMON/GRANT-PARAMS/v1"`) is **completely disconnected** from `tools/simon-industry/`!
* And on `/industry` (`ui/src/routes/industry/+page.svelte`), judges can only view a static table—unlike `/demo`, there are no buttons to **Tamper with Ticket Output**, **Tamper with Failure Codes**, or **Verify M7 Operator Grant (`Zezwolenie`)** live in the browser!

---

## Step-by-Step Implementation Instructions

### Task C1: Create `tools/simon-industry/agent_triage.py` (Autonomous Multi-Turn Tool-Calling Industrial Agent + M7 Capability Ceiling)
Create `tools/simon-industry/agent_triage.py` that implements an autonomous 2-to-4 turn diagnostic agent over `simon-api` (`:18600/v1/chat/completions`) using `gemma-4-26b-a4b-it-bf16` (MI300X) and `gemma-4-26b-a4b-it-qat-q4_0` (RTX 3090):
1. **Define 3 Read-Only Diagnostic Tools & 1 Gated Action Tool (`TOOLS`):**
   * `lookup_machine_history(product_type: str, udi: int)`: returns recent wear/temperature trend from `ai4i2020.csv` around `udi`.
   * `check_spare_parts_inventory(failure_mode: str)`: returns stock level, lead time, and part IDs for `HDF` (cooling fan/filter), `PWF` (inverter/spindle drive), `OSF` (torque coupling/bearings), `TWF` (carbide milling insert).
   * `propose_work_order(urgency: str, failure_modes: list[str], action_code: str, part_id: str, summary: str)`: proposes a gated maintenance action.
2. **Enforce Deterministic M7 Capability Ceiling (`Sufit` equivalent + `SIMON/GRANT-PARAMS/v1`):**
   * Validate `propose_work_order` arguments against strict enum bounds (`urgency in ["medium", "high"]`, `action_code in ["INSPECT_COOLING", "CALIBRATE_POWER_DRIVE", "REDUCE_FEED_STRAIN", "REPLACE_TOOL_INSERT"]`) and reject any unlisted parameter or shutdown command.
   * Compute the exact `SIMON/GRANT-PARAMS/v1` parameter commitment digest matching `crates/simon-core/src/cap.rs:221-227`:
     ```python
     # Canonical JSON with sorted keys (matches serde_json::json! BTreeMap in Rust)
     payload = json.dumps({
         "akcja": "propose_work_order",
         "domena": "SIMON/GRANT-PARAMS/v1",
         "parametry": args
     }, separators=(",", ":"), sort_keys=True).encode("utf-8")
     parametry_digest = hashlib.sha256(payload).hexdigest()
     ```
3. **Include `selfcheck()`:**
   * Add a deterministic `selfcheck()` function (just like `rules.py` and `tickets.py`) that tests the tool execution loop, schema ceiling, forbidden action rejection, and exact `SIMON/GRANT-PARAMS/v1` hash compatibility with Rust `simon-core::cap::odcisk_parametrow_akcji`.

### Task C2: Make `/industry` (`ui/src/routes/industry/+page.svelte`) Interactive in the Browser!
In `ui/src/routes/industry/+page.svelte`:
1. Add an interactive **"Live Cryptographic Audit & Tamper Explorer"** panel when a user clicks any of the 15 tickets (or on the currently selected ticket):
   * **Button 1 — "Verify Authentic Ticket (WASM Ed25519 + SHA-256)":** Runs `verifyReceipt(JSON.stringify(r.receipt), r.signed_output)` and shows `VALID — Signed by <node_id> (<model_hash>)`.
   * **Button 2 — "Simulate MITM Tamper (Change Urgency high → low)":** Mutates `"high"` to `"low"` in `signed_output`, re-runs `verifyReceipt` in WASM, and displays the exact cryptographic failure (`tresc_ok: false` — `SIMON/OUTPUT/v1` SHA-256 digest mismatch!).
   * **Button 3 — "Simulate Dishonest Node (Inject Forbidden Shutdown Command)":** Injects `"shut down the spindle immediately"` into `recommended_actions`, showing **both** WASM `output_digest` rejection (if altered in transit) AND deterministic M7 / `tickets.py` guardrail rejection (`FORBIDDEN` action blocked).
   * **Button 4 — "Issue M7 Operator Capability Grant (`Zezwolenie`)":** Computes the `SIMON/GRANT-PARAMS/v1` SHA-256 parameter digest for the selected ticket's `recommended_actions` & `spare_parts` directly in the browser, showing how `needs_human_review: true` transitions to a single-use parameter-bound `Zezwolenie` token before any ERP/PLC work order is dispatched.

---

## Verification Commands
```bash
python3 tools/simon-industry/rules.py
python3 tools/simon-industry/tickets.py --help
python3 tools/simon-industry/agent_triage.py --selfcheck
npm --prefix ui run check
npm --prefix ui run build
```
