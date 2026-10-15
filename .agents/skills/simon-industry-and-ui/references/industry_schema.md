# `ui/src/lib/industry-run.json` Schema Reference

The SvelteKit route `ui/src/routes/industry/+page.svelte` imports `$lib/industry-run.json`. Any update to `tools/simon-industry/export_ui.py` or `ui/src/lib/industry-run.json` MUST preserve all existing top-level and per-record fields while adding new fields safely.

## Top-Level Fields
- `summary` (`object`):
  - `records` (`number`, e.g. `18`)
  - `tickets` (`number`, e.g. `15`)
  - `clean` (`number`, e.g. `15`)
  - `no_ticket` (`number`, e.g. `3`)
  - `errors` (`number`, e.g. `0`)
  - `median_ms` (`number`, e.g. `1749`)
  - `nodes` (`array` of `string`: `["AMD Instinct MI300X · Atlanta · Gemma 4 BF16 (vLLM)", "RTX 3090 · Poland · Gemma 4 QAT q4_0 (llama.cpp)"]`)
- `records` (`array` of Record objects)

## Per-Record Object Fields (`records[i]`)
- `record` (`string`, UDI e.g. `"4362"`)
- `product` (`string`, e.g. `"M19221"`)
- `label` (`object`: `{TWF, HDF, PWF, OSF, RNF}`)
- `features` (`object`: `{type, air_K, process_K, rpm, torque_Nm, wear_min, temp_diff_K, power_W, strain_minNm}`)
- `findings` (`array` of `{mode, name, rule, measured, urgency}`)
- `ticket` (`object | null`: `{title, summary, failure_modes, evidence, checks, urgency, needs_human_review}`)
- `problems` (`array | null`)
- `note` (`string | null`)
- `error` (`string | null`)
- `model` (`string | null`, e.g. `"gemma-4-26b-a4b-it-qat-q4_0"` or `"gemma-4-26b-a4b-it-bf16"`)
- `wall_ms` (`number | null`)
- `node_id` (`string`, 64-char Ed25519 signer hex)
- `node_label` (`string | null`)
- `receipt` (`object | null`: full `Receipt` JSON with `job_id`, `node_id`, `model_hash`, `precision`, `prompt_tokens`, `completion_tokens`, `started_at_us`, `finished_at_us`, `activation_hash`, `output_digest`, `runtime`, `signer`, `signature`)
- `signed_output` (`string | null`: exact raw output string hashed under `"SIMON/OUTPUT/v1"` with `receipt.job_id` to produce `receipt.output_digest`)
- `run` (`string`, e.g. `"run-3090-mi300x-2026-10-15.jsonl"`)
