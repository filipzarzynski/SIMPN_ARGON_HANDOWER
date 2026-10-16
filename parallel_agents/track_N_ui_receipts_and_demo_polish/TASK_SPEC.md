# Agent Task Specification: Track N (Stage 3, Wave 3B) — UI `/receipts` & `/demo` Claim Matrix & Accessibility Polish (`[FZ-N]`)

**Stage:** Stage 3, Wave 3B (Run AFTER Stage 3 Wave 3A Tracks K & L are integrated into `fz-contrib`)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-N-ui-receipts-and-demo-polish`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_N`  
**Exclusive Permitted Files:**
* `ui/src/routes/receipts/+page.svelte`
* `ui/src/routes/demo/+page.svelte`

---

## 0. Mandatory Skills to Read First
1. `/home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-captain-review-guardrails/SKILL.md`
2. `/home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-industry-and-ui/SKILL.md`

---

## 1. Objective

Polish the Captain's new `/receipts` page (`ui/src/routes/receipts/+page.svelte`, added in commit `c5f563b`) and `/demo` page (`ui/src/routes/demo/+page.svelte`) so judges get a crystal-clear, accessible, 390px-responsive interactive experience that strictly adheres to `docs/THREAT-MODEL.md` and `docs/STRESS-TESTS.md`:

1. **Enhance `ui/src/routes/receipts/+page.svelte` with the Level 0 vs Level 1 (M1) vs M3/M7 Breakdown & Stress-Test Summary (`[FZ-N1]`)**:
   - Keep 100% of the Captain's existing prose and headings (`What a receipt proves`, `It proves`, `It does not prove`, `How to use it`).
   - Add a clear, concise **Verification Levels & Claim Labels** table directly below `How to use it` that maps SIMON's mechanisms to the 4 labels from `docs/THREAT-MODEL.md`:
     - **Level 0 (`SIMON/RECEIPT/v1` + `SIMON/OUTPUT/v1`):** *Cryptographically proven* — Ed25519 signature over output digest, job ID, model hash, and integer microsecond timestamps (`started_at_us`, `finished_at_us`). Requires key pinning (`node_id` / `--signer`) to identify the node.
     - **Level 1 (`WiazaniaM1` — `SIMON/PROMPT/v1`, `SIMON/CHAIN/v1`):** *Cryptographically proven* — commits exact prompt token IDs, client nonce, tokenizer hash, and ordered output token chain (verified offline in CLI and browser WASM).
     - **M3 Audit & Canary (`m3::ocena`, `CANARY-7`, verifier pilot):** *Empirically detected (telemetry, not proof)* — catches gross trajectory fabrication and catastrophic GGUF weight bit-flips (`ffn_down` 0/8); does not prove model identity.
     - **M7 Capability Ceiling (`Sufit` + `Zezwolenie` + `rules.py`):** *Policy / heuristic (blast-radius reduction)* — locks failure modes, urgency, and inspection step IDs to deterministic plant rules and requires an operator Ed25519 grant (`SIMON/GRANT/v1`).
   - Ensure mobile responsiveness at 390px width (`overflow-x-auto` wrapper on tables, `min-w-0`).

2. **Harden Accessibility & Tamper Presets on `ui/src/routes/demo/+page.svelte` (`[FZ-N2]`)**:
   - Add explicit `type="button"` and `aria-pressed={poziom === 0}` / `aria-pressed={poziom === 1}` attributes to the Level 0 / Level 1 switcher buttons (matching the Captain's accessibility fix in commit `5854038` on `NodePanel.svelte` and `VerifierPanel.svelte`).
   - Add a **Tamper Client Nonce (Replay Attack)** button in Level 1 mode (`poziom === 1`) alongside output-token tamper and signature tamper, allowing judges to test `docs/STRESS-TESTS.md` Row 4 (`Replay an old receipt for a new job` $\rightarrow$ client nonce mismatch rejected by WASM `weryfikuj_m1`) right in the browser, with `restore1()` resetting the nonce back to `ZADANIE_M1.client_nonce`.

---

## 2. Granular Commit Plan (Cherry-Pickable by Team Captain)

1. `[FZ-N1] feat(ui): add verification levels and claim-label reference table to /receipts page`
2. `[FZ-N2] feat(ui): add client-nonce replay tamper preset and button aria-pressed semantics to /demo`

---

## 3. Verification & PR Delivery

```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh N --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track N
```
