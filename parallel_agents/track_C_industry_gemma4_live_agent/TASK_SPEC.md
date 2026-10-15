# Track C — Upgrade Intelligent Industry with M7 Capability Grants (`Zezwolenie`), Autonomous Tool-Calling Triage & Interactive UI (`[FZ-C]`)

**Stage:** Stage 1 (Wave 1B — Feature)  
**Status:** **Integrated in `fz-contrib`** · **[Fork PR #5](https://github.com/filipzarzynski/SIMON/pull/5)**  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-C-industry-m7-agent`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_C`  
**Exclusive Permitted Files:**
* `tools/simon-industry/tickets.py`
* `tools/simon-industry/agent_triage.py` (new file)
* `tools/simon-industry/export_ui.py`
* `ui/src/lib/industry-run.json`
* `ui/src/routes/industry/+page.svelte`

*(100% file-disjoint from all other Stage 1 tracks!)*

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
* And on `/industry` (`ui/src/routes/industry/+page.svelte`), judges can only view a static table—unlike `/demo`, there are no buttons to **Tamper with Ticket Output**, **Simulate Dishonest Node**, or **Issue M7 Operator Grant (`Zezwolenie`)** live in the browser!

---

## Step-by-Step Implementation Instructions (Commit Each Task with `[FZ-C<N>]`)

### Task C1 (`[FZ-C1]`): Create `tools/simon-industry/agent_triage.py` (Autonomous Multi-Turn Tool-Calling Industrial Agent + M7 Capability Ceiling)
Create `tools/simon-industry/agent_triage.py` that implements an autonomous 2-to-4 turn diagnostic agent over `simon-api` (`:18600/v1/chat/completions`) using `gemma-4-26b-a4b-it-bf16` (MI300X) and `gemma-4-26b-a4b-it-qat-q4_0` (RTX 3090):
1. **Define 3 Read-Only Diagnostic Tools & 1 Gated Action Tool (`TOOLS`):**
   * `lookup_machine_history(product_type: str, udi: int)`: returns recent wear/temperature trend from `ai4i2020.csv` around `udi`.
   * `check_spare_parts_inventory(failure_mode: str)`: returns stock level, lead time, and part IDs for `HDF` (cooling fan/filter), `PWF` (inverter/spindle drive), `OSF` (torque coupling/bearings), `TWF` (carbide milling insert).
   * `propose_work_order(urgency: str, failure_modes: list[str], action_code: str, part_id: str, summary: str)`: proposes a gated maintenance action.
2. **Enforce Deterministic M7 Capability Ceiling (`Sufit` equivalent + `SIMON/GRANT-PARAMS/v1`):**
   * Validate `propose_work_order` arguments against strict enum bounds (`urgency in ["medium", "high", "inspect before next shift", "plan tool change"]`, `action_code in ["INSPECT_COOLING", "CALIBRATE_POWER_DRIVE", "REDUCE_FEED_STRAIN", "REPLACE_TOOL_INSERT"]`) and reject any unlisted parameter or shutdown command.
   * Compute the exact `SIMON/GRANT-PARAMS/v1` parameter commitment digest matching `crates/simon-core/src/cap.rs:221-227` (`content_digest("SIMON/GRANT-PARAMS/v1", ...)`):
     ```python
     # Canonical JSON with sorted keys prefixed by "SIMON/GRANT-PARAMS/v1\x00"
     canon = json.dumps({
         "akcja": "propose_work_order",
         "domena": "SIMON/GRANT-PARAMS/v1",
         "parametry": args
     }, separators=(",", ":"), sort_keys=True).encode("utf-8")
     parametry_digest = hashlib.sha256(b"SIMON/GRANT-PARAMS/v1\x00" + canon).hexdigest()
     ```
3. **Support `--selfcheck` CLI flag:**
   * Running `python3 tools/simon-industry/agent_triage.py --selfcheck` (or with no args) runs a deterministic self-check testing the tool execution loop, schema ceiling, forbidden action rejection, and `SIMON/GRANT-PARAMS/v1` digest calculation.

### Task C2 (`[FZ-C2]`): Make `/industry` (`ui/src/routes/industry/+page.svelte`) Interactive in the Browser!
In `ui/src/routes/industry/+page.svelte`:
1. Add an interactive **"Live Cryptographic Audit & M7 Capability Grant Explorer"** panel for the selected record (or each expanded ticket row with a non-null `receipt` and `signed_output`):
   * **Button 1 — "Verify Authentic Ticket (WASM Ed25519 + SHA-256)":** Runs `verifyReceipt(JSON.stringify(r.receipt), r.signed_output)` and shows `VALID — Signed by <node_id> (<model_hash>)`.
   * **Button 2 — "Simulate MITM Tamper (Alter Urgency / Evidence)":** Mutates `r.signed_output` (e.g. changing `"needs_human_review": true` to `false` or altering `"urgency"`), re-runs `verifyReceipt` in WASM, and displays the exact cryptographic failure (`tresc_ok: false` — `SIMON/OUTPUT/v1` SHA-256 digest mismatch!).
   * **Button 3 — "Simulate Signature Forgery (Flip Ed25519 Byte)":** Flips the first byte of `r.receipt.signature`, re-runs `verifyReceipt` in WASM, and displays `podpis_ok: false`.
   * **Button 4 — "Issue M7 Operator Capability Grant (`Zezwolenie`)":** Computes the `SIMON/GRANT-PARAMS/v1` SHA-256 parameter digest for the selected ticket's `failure_modes` & `checks` directly in the browser via WebCrypto `crypto.subtle.digest('SHA-256', ...)`, showing how `needs_human_review: true` transitions to a single-use parameter-bound `Zezwolenie` token before any ERP/PLC work order is dispatched.

---

## Granular Commit Plan (Cherry-Pickable by Team Captain)
1. `[FZ-C1] feat(industry): add agent_triage.py multi-turn tool-calling agent with M7 SIMON/GRANT-PARAMS/v1 ceiling`
2. `[FZ-C2] feat(ui): add interactive WASM tamper & M7 Zezwolenie capability grant explorer to /industry`

---

## Verification & PR Delivery
```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh C --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track C
```
