# 03 — Line-by-Line Codebase Audit: Python Tools, Verifiers, Industry, Scripts & UI

This document covers every non-Rust component of `/home/agent/SIMON`: `tools/*`, `scripts/*`, `demo/*`, `deploy/*`, `przyklady/*`, `docs/*`, and `ui/*`.

---

## 1. `tools/simon-industry/` (Hackathon Track 1: Intelligent Industry)

### 1.1 `tools/simon-industry/rules.py` (Lines 1–62)
* **Purpose:** Deterministic physical failure detector for the UCI AI4I 2020 Predictive Maintenance dataset (10,000 synthetic milling-machine rows).
* **Mechanics (`L10-38`):**
  * `features(row)` (`L13-18`): Computes `temp_diff_K = round(proc - air, 1)`, `power_W = round(torque * rpm * 2 * math.pi / 60)`, and `strain_minNm = round(wear * torque)`.
  * `findings(f)` (`L21-38`): Evaluates the 4 deterministic AI4I failure modes:
    * `HDF` (Heat Dissipation Failure, urgency `"high"`): `temp_diff_K < 8.6 and rpm < 1380`.
    * `PWF` (Power Failure, urgency `"high"`): `not 3500 <= power_W <= 9000`.
    * `OSF` (Overstrain Failure, urgency `"high"`): `strain_minNm > OSF_LIMIT[type]` (`L: 11000, M: 12000, H: 13000`).
    * `TWF` (Tool Wear Zone, urgency `"medium"`): `wear_min >= 200`.
* **Audit Note:** Does not catch `RNF` (Random Failure, 19 rows in dataset) or probabilistic `TWF` below 200 min, which the author explicitly documents as deterministic rule misses (`no_ticket`).

### 1.2 `tools/simon-industry/tickets.py` (Lines 1–156)
* **Purpose:** Calls Gemma 4 (`gemma-4-26b-a4b-it-qat-q4_0` on RTX 3090 or `gemma-4-26b-a4b-it-bf16` on AMD MI300X) via `simon-api` (`:18600`) to draft JSON maintenance tickets for records flagged by `rules.py`, then validates them deterministically.
* **Key Functions:**
  * `FORBIDDEN` (`L34`): Regex blocking autonomous plant control commands: `\b(shut ?down|stop the machine|switch off|turn off|bypass|override|disable)\b`.
  * `check(raw, msgs, finds)` (`L51-78`):
    1. Extracts JSON object via `re.search(r"\{.*\}", raw, re.S)`.
    2. Checks all 7 required keys (`summary`, `failure_modes`, `urgency`, `evidence`, `recommended_actions`, `spare_parts`, `needs_human_review`).
    3. Checks `set(obj["failure_modes"]) == {x["mode"] for x in finds}`.
    4. Checks `obj["urgency"]` matches rule urgencies and `obj["needs_human_review"] is True`.
    5. **Anti-Hallucination Numeric Gate (`L72-74`):** Extracts all numbers (`\d+(?:\.\d+)?`) from the generated JSON (`evidence`, `summary`, `recommended_actions`) and verifies that `numbers(body) - (numbers(input_prompt) | {0..10})` is empty!
    6. Checks `not FORBIDDEN.search(body)`.
  * `sample(rows, per_mode=3, seed=20261017)` (`L81-94`): Selects 3 records each from 6 buckets (`HDF`, `PWF`, `OSF`, `TWF`, `multi`, and `missed`), totaling 18 records (15 flagged + 3 missed).
* **Architectural Gap:** `tickets.py` is purely a Python validator; it **does not invoke `simon-core::cap::waliduj` or `Zezwolenie`** (M7 capability ceiling and operator grants).

### 1.3 `tools/simon-industry/export_ui.py` (Lines 1–48) & `heartbeat.sh` (Lines 1–9)
* `export_ui.py` converts `tickets.py` JSONL output into `ui/src/lib/industry-run.json`, preserving `receipt` and `signed_output` so the browser can verify Ed25519 signatures via WASM.
* `heartbeat.sh` runs 2 tickets every 15 minutes across the 3090 and MI300X nodes to keep `/network` populated.

---

## 2. `tools/simon-verifier/` (M3 Teacher-Forced Logprob Auditing)

### 2.1 `tools/simon-verifier/verifier_loop.py` (Lines 1–75)
* **Mechanics (`petla`, `L41-51`):** Given `prompt_token_ids` ($P$) and `output_token_ids` ($Y$), makes $|Y|$ sequential HTTP POST requests to `llama-server` `/completion` (`n_predict=1, temperature=0, top_k=1, seed=42, n_probs=k, cache_prompt=True`), feeding `ctx = P + Y[:t]` and recording `(indeks, node_token, topk)` for `simon audyt`.
* **Limitations:**
  * Works **only** with `llama-server` (requires token-ID array `prompt` and `completion_probabilities`), not vLLM or Ollama.
  * Makes $O(T)$ sequential round-trip HTTP calls instead of a single prefill pass.

### 2.2 `tools/simon-verifier/model_substitution.py` (Lines 1–230)
* **Purpose:** Sensitivity benchmark testing whether logprob metrics separate `--honest` from `--sub`.
* **Three Code Bugs Found:**
  1. **Inverted Trajectory Direction (`L182-187`):** Generates `seq` on `--ref` (`L182`) and teacher-forces `--sub` on `--ref`'s trajectory (`L187`), whereas in real M3 the *node/substitute* generates the trajectory and `--ref` teacher-forces it.
  2. **Mismatched `contain2` Formula (`L103`):** Computes `"contain2": 1 if (other_t and ref_t and other_t[0][0] in r2) else 0`, **omitting the `margin <= 0.25` check** used by `simon-core/src/m3.rs:110` and `fp_matrix.py:30`!
  3. **Out-of-Vocabulary Random Control (`L190`):** Generates random token IDs via `random.randint(0, 100000)`, which exceeds 32k vocab sizes and triggers HTTP 500s swallowed by `except Exception:` at `L192`.

### 2.3 `tools/simon-verifier/fp_matrix.py` (Lines 1–105) & `fp_local_gpu.sh` (Lines 1–61)
* **Mechanics (`L24-30, L62-88`):** Generates a 20-token greedy sequence on each honest config `url` (`cache_prompt=False` inside `ms.gen_reference`), then teacher-forces that sequence on `--ref` (`cache_prompt=True` inside `ms.force_eval`) and checks `contain2_step` (`rank <= 2` and `margin <= 0.25`).
* **Why `ref` Failed Against Itself (`docs/FP-RESULT.md`):**
  1. `ms.gen_reference` (`model_substitution.py:61`) sets `"cache_prompt": False` (full prefill on generation), whereas `ms.force_eval` (`model_substitution.py:70`) sets `"cache_prompt": True` (incremental 1-token decode with KV cache during verification)! That CUDA kernel difference (batch GEMM vs 1-token GEMV) shifted logits by $\sim 10^{-3}$, flipping tokens at near-ties (`margin < 0.05`).
  2. With `tokens=20` and `max_poza=0.02`, $1/20 = 0.05 > 0.02$, so **even 1 flipped token out of 20 fails the prompt**.

---

## 3. `tools/simon-lidar/` (Node-Level Behavioral & Distributional Probing)

### 3.1 `tools/simon-lidar/lidar.py` (Lines 1–336)
* **Mechanics:** Runs an agentic coding loop (`MAX_STEPS = 15`, `temp=0.7, top_p=0.9`) across 6 coding task variants (`verify_a/b`, `recover_a/b`, `resolve_a/b` where `resolve_b` has an intentional conflict between `README.md` and `test_prices.py`). Extracts **194 categorical features** and classifies the model using Jeffreys-smoothed Bernoulli/Categorical Naive Bayes (`score`, `L219-231`) with an open-set leave-one-out floor (`verdict`, `L246-263`).
* **Flaws:**
  1. **Trivial Evasion by Dishonest Node:** All 6 task prompts (`L26-34`) and 5 tool schemas (`L36-46`) are static and hardcoded in the public repo. A dishonest node operator can trivially fingerprint the probe and route only those 6 tasks to the expensive model.
  2. **Blind to Quantization:** Confused `qwen2.5-3b-q4` with `qwen2.5-3b-q8` (`0/4` accuracy).
  3. **Subtle Denominator Mismatch in `verdict()` (`L248` vs `L255`):** `floor` is computed via `loo(fps)` ($N-1$ denominator), whereas `sc` is computed on all `fps` ($N$ denominator).

### 3.2 `tools/simon-lidar/onetoken.py` (Lines 1–122)
* **Mechanics:** Sends 20 short 1-word questions (10 EN + 10 PL, `L13-25`) 30 times each at `temperature=1.0, max_tokens=6`, normalizes the first word (`norm`, `L40-48`), and computes base-2 Jensen-Shannon Divergence (`jsd`, `L61-74`).
* **Flaws:** Static prompts (`L13-25`), and **no `verify` command or threshold** (`L88-118` only has `run` and `eval`) because intra-model JSD varies from `0.076` to `0.494` across model families.

---

## 4. `tools/simon-canary/simon_canary.py` (Lines 1–137)
* Sends 8 deterministic greedy trivia prompts (`Paris`, `7|Seven`, `Thursday`, `H2O`, `F`, `Jupiter`, `April`, `cold`) in parallel (`ThreadPoolExecutor(8)`). Re-tests once on failure (`>= 3` misses) before triggering `--on-fail`. Explicitly sets `"self_reported": True` (`L91`)—designed for catching accidental GPU memory bit flips (GPUHammer), not adversarial fraud.

---

## 5. `tools/simon-api/simon_api.py` (Lines 1–260)
* OpenAI-compatible HTTP gateway (`127.0.0.1:18600`) that translates `POST /v1/chat/completions` into `simon --role agent --request-file -` subprocess calls.
* **Strengths:**
  * Hot-reloads `nodes.json` (`load_nodes`, `L33-46`) and round-robins across nodes per model (`nodes_in_turn`, `L49-54`).
  * Passes request JSON over `stdin` (`L82-85`) so sensitive prompts never appear in `/proc/<pid>/cmdline`.
  * **Never retries `subprocess.TimeoutExpired`** on another node (`L101-102`).
  * Withholds the model response (`HTTP 502`, `L182-184`) if `receipt_zweryfikowany` is false.
  * Strips `prompt` and `output` when logging to `JOBLOG` (`L62-74`).

---

## 6. `tools/simon-monitor/simon_monitor.py` (Lines 1–246)
* Daemon polling local `nvidia-smi`, remote AMD MI300X `rocm-smi` tunnel (`fetch_stats`), canary status files (`read_canary`), and tailing `SIMON_API_JOBLOG` (`JobTail`) to serve `GET /api/monitor` on `:8081`. Includes startup `selfcheck()` (`L197-237`).

---

## 7. `tools/simon-guard/` (`guard_small.py` & `pii_pl.py`)
* `pii_pl.py` (`Lines 1–247`): High-quality deterministic Polish PII & secret redactor with exact checksum verification for **PESEL** (plus plausible-date fallback `[PESEL?]`), **NIP**, **REGON-9/14**, and **PL IBAN** (ISO 7064 mod 97), executing secret regexes before numeric PII regexes (`L91-144`).
* `guard_small.py` (`Lines 1–166`): Combines `pii_pl.py` (~0.1 ms) with `speakleash/Bielik-Guard-0.5B-v1.1` (~150 ms on CPU) and serves `POST /guard` on `:19301` (called by `simon guard`).

---

## 8. `tools/amd/` (AMD Instinct MI300X Automation)
* `demo_node.sh` (`Lines 1–212`): End-to-end provisioner that deploys `google/gemma-4-26B-A4B-it` (BF16 on `vLLM 0.27.1` + ROCm 7.2) on an AMD Developer Cloud MI300X droplet, locks down port 8000 with `iptables`/`ip6tables`, sets up `simon-node.service` + `simon-gpustats.service`, establishes SSH port-forwarding tunnels, and registers the MI300X node into `demo-nodes.json` and `monitor.json`.

---

## 9. `ui/` (SvelteKit Frontend + Rust WASM Verifier)

### 9.1 `ui/src/lib/verify.ts` (Lines 1–84)
* Loads `simon-verify-wasm` (`crates/simon-verify-wasm`) in the browser and exposes `verifyReceipt`, `verifyM1`, `evalM3`, and `computeOutputDigest`.

### 9.2 Route-by-Route Audit (`ui/src/routes/`)
1. **`/demo` (`ui/src/routes/demo/+page.svelte`, `ui/src/lib/fixture.ts`):**
   * Uses static build-time fixtures (`ui/scripts/generate-fixtures.ts`).
   * **Default Tab (`proofLevel = 'm1'`, Level 1 — M1 + M3):** Uses synthetic dummy data from `examples/gen_m1.rs` (`job_id: "job-m1-demo"`, output `"DEMO OUTPUT"`, token IDs `100..139` and `200..259`, and a 4-token hand-written M3 JSON).
   * **Bug (`ui/src/lib/components/VerifierPanel.svelte:86-97`):** `VerifierPanel.svelte:97` gates the overall `'valid'` / `'rejected'` badge on `m3Ok` (`if (m1Ok && m3Ok) return 'valid'; return 'rejected';`), contradicting the repo's post-`FP-RESULT.md` rule that M3 is non-gating telemetry!
   * **Secondary Tab (`proofLevel = '0'`, Level 0 — Signature):** Loads a real `qwen3.8-27b` receipt from Sept 18, whose output text (`fixture.ts:10`) is truncated mid-sentence (`"... \"A signature"`).
2. **`/network` (`ui/src/routes/network/+page.svelte`):**
   * Polls `/simon-monitor/api/monitor` every 2s. If the monitor is offline, shows an error banner (no static fallback). Calls `verifyReceipt(JSON.stringify(j.receipt), null)` (verifying signature only, since monitor omits output text).
3. **`/industry` (`ui/src/routes/industry/+page.svelte`, `ui/src/lib/industry-run.json`):**
   * Loads static snapshot `industry-run.json` (18 records from `docs/industry/run-3090-mi300x-2026-10-15.jsonl`: 9 tickets on RTX 3090 `gemma-4-26b-a4b-it-qat-q4_0` + 6 tickets on AMD MI300X `gemma-4-26b-a4b-it-bf16` + 3 healthy baselines).
   * Runs **real WASM verification** (`verifyReceipt(JSON.stringify(r.receipt), r.signed_output)`) on mount for all 15 tickets.
   * **Static Only:** Has no interactive "Tamper" buttons (unlike `/demo`) and no live ticket generation or `Zezwolenie` operator approval flow.
