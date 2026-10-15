# `ui/src/lib/industry-run.json` Schema Reference

The SvelteKit route `ui/src/routes/industry/+page.svelte` imports `$lib/industry-run.json`. Any update to `tools/simon-industry/export_ui.py` MUST preserve all existing top-level and per-ticket fields while adding new fields safely.

## Top-Level Fields
- `generated_at` (`string`, ISO-8601)
- `dataset` (`object`: `name`, `total_rows`, `normal_count`, `failure_count`, `anomaly_count`, `rule_filter_ms`, `tokens_saved_pct`)
- `canary` (`object`: `suite`, `passed`, `total`, `duration_s`, `model`, `hardware`, `checks`: array of `{id, name, passed, latency_ms, detail}`)
- `hardware_comparison` (`object`: `edge` (`RTX 3090`, `61.8 tok/s`) vs `cloud` (`AMD Instinct MI300X`, `199.1 tok/s`, `speedup: 3.22`))
- `tickets` (`array` of Ticket objects)

## Per-Ticket Object Fields (`tickets[i]`)
- `udi` (`number`)
- `product_id` (`string`, e.g. `"L47256"`)
- `type` (`string`: `"L" | "M" | "H"`)
- `category` (`string`: `"FAILURE" | "ANOMALY"`)
- `triggered_rules` (`array` of `string`)
- `metrics` (`object`: `air_temp_k`, `process_temp_k`, `rpm`, `torque_nm`, `tool_wear_min`, `temp_diff_k`, `power_w`, `strain_index`)
- `ticket` (`object`: `severity`, `diagnosis`, `recommended_action`, `estimated_downtime_h`, `parts_needed`)
- `node_used` (`string`: `"edge-rtx3090"` or `"amd-mi300x"`)
- `latency_ms` (`number`)
- `receipt` (`object`: full `SIMON-RECEIPT-v1` JSON with non-zero `timestamp_us`, accurate `precision`, and unique `payload_hash_hex` / `signature_hex` per ticket)
- `agent_trace` (`array` of `{step, tool, args, result_summary}`, added in **Track C / `PR-3`**)
