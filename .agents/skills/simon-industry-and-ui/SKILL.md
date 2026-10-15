---
name: simon-industry-and-ui
description: >-
  Use this skill when working on Track C (tools/simon-industry, Gemma 4 M7 tool-calling agent,
  industry-run.json, ui/src/routes/industry/+page.svelte) or Track F (SvelteKit UI in ui/,
  demo tamper controls, network topology view, Python tools, and LABLAB-SUBMISSION.md).
---

# SIMON Intelligent Industry & SvelteKit UI Skill (`simon-industry-and-ui`)

Activate this skill when working on **Track C (`PR-3`)** or **Track F (`PR-6`)**.

## 1. Track 1: Intelligent Industry Pipeline (`tools/simon-industry/`)

- **Stage 1 (`rules.py`)**: Deterministic rule filter on `data/ai4i2020.csv` (10,000 rows, 8 ms runtime, 0 LLM tokens). Identifies 329 failures and 20 borderline anomalies.
  - Run unit tests: `python3 tools/simon-industry/rules.py` (note: takes NO CLI arguments; runs `selfcheck()` + dataset summary automatically).
- **Stage 2 (`tickets.py`, `agent_triage.py` & `export_ui.py`)**:
  - Escalates anomalies to **Gemma 4 26B-A4B** on local **RTX 3090** (`gemma-4-26b-a4b-it-qat-q4_0`, `61.8 tok/s`) or **AMD Instinct MI300X** (`gemma-4-26b-a4b-it-bf16`, `199.1 tok/s`).
  - **Track C Upgrade (`PR-3`)**: Adds `tools/simon-industry/agent_triage.py` (autonomous multi-turn tool-calling triage + M7 `SIMON/GRANT-PARAMS/v1` capability ceiling) and makes `/industry` (`ui/src/routes/industry/+page.svelte`) interactive in the browser with live WASM `verifyReceipt` tamper and M7 grant verification!
  - See [industry_schema.md](./references/industry_schema.md) for the exact JSON structure of `ui/src/lib/industry-run.json`.

## 2. SvelteKit 5 UI (`ui/`)

- **Framework**: SvelteKit 2 + Svelte 5 Runes (`$state`, `$derived`) + TailwindCSS + Vite.
- **WASM Verification Helpers (`ui/src/lib/verify.ts`)**:
  - `verifyReceipt(receiptJson: string, output: string)` -> returns `{ ok, podpis_ok, tresc_ok, poziom, signer, model_hash, job_id, blad }`
  - `verifyM1(receiptJson: string, output: string, tokenizerHash: string, clientNonce: string, promptTokens: Uint32Array, outputTokens: Uint32Array)` -> returns `{ ok, podpis_ok, tresc_ok, m1_ok, poziom, signer, model_hash, job_id, blad }`
- **Routes**:
  - `ui/src/routes/+page.svelte` — Overview & architecture
  - `ui/src/routes/industry/+page.svelte` — Track 1 Intelligent Industry dashboard (consumes `ui/src/lib/industry-run.json`)
  - `ui/src/routes/demo/+page.svelte` & `ui/src/lib/components/NodePanel.svelte` — Interactive WASM receipt verifier (`Track F` adds real Ed25519 signature byte-flip tamper button so `podpis_ok: false` can be tested live)
  - `ui/src/routes/network/+page.svelte` — 8-node topology visualization (`Track F` adds clear `SIMULATED P2P TOPOLOGY` badge)
- **Verification Commands**:
  ```bash
  npm --prefix ui run check
  npm --prefix ui run build
  ```
