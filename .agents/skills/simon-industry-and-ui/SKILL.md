---
name: simon-industry-and-ui
description: >-
  Use this skill when working on Track C (tools/simon-industry, Gemma 4 M7 tool-calling agent,
  industry-run.json) or Track F (SvelteKit UI in ui/, demo tamper controls, network topology
  view, Python tools, and LABLAB-SUBMISSION.md).
---

# SIMON Intelligent Industry & SvelteKit UI Skill (`simon-industry-and-ui`)

Activate this skill when working on **Track C (`PR-3`)** or **Track F (`PR-6`)**.

## 1. Track 1: Intelligent Industry Pipeline (`tools/simon-industry/`)

- **Stage 1 (`rules.py`)**: Deterministic rule filter on `data/ai4i2020.csv` (10,000 rows, 8 ms runtime, 0 LLM tokens). Identifies 329 failures and 20 borderline anomalies.
  - Run unit tests: `python3 tools/simon-industry/rules.py --self-test`
- **Stage 2 (`tickets.py` & `export_ui.py`)**:
  - Escalates anomalies to **Gemma 4 26B-A4B (`Q4_K_M`)** on local **RTX 3090** (`61.8 tok/s`) or **AMD Instinct MI300X** (`199.1 tok/s`).
  - **Track C Upgrade (`PR-3`)**: Replaces single-shot `curl` with a multi-turn tool-calling agent loop (`lookup_bearing_history`, `lookup_iso_threshold`, `draft_maintenance_ticket`) backed by per-ticket `SIMON-RECEIPT-v1` cryptographic verification and deterministic offline replay (`--offline-replay`).
  - See [industry_schema.md](./references/industry_schema.md) for the exact JSON structure required by `ui/src/lib/industry-run.json`.

## 2. SvelteKit 5 UI (`ui/`)

- **Framework**: SvelteKit 2 + Svelte 5 Runes (`$state`, `$derived`) + TailwindCSS 4 + Vite 6.
- **Routes**:
  - `ui/src/routes/+page.svelte` — Overview & architecture
  - `ui/src/routes/industry/+page.svelte` — Track 1 Intelligent Industry dashboard (consumes `ui/src/lib/industry-run.json`)
  - `ui/src/routes/demo/+page.svelte` — Interactive WASM receipt verifier (`Track F` fixes signature tamper buttons)
  - `ui/src/routes/network/+page.svelte` — 8-node topology visualization (`Track F` adds clear `SIMULATED P2P TOPOLOGY` badge)
- **Verification Commands**:
  ```bash
  cd ui && npm run check && npm run build
  ```
