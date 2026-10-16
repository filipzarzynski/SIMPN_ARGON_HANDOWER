# Stage 1 Post-Mortem: Team Captain (`Szpili`) & Claude Review Analysis

**Date:** 2026-10-16  
**Reviewed Branch:** `fz-contrib` (Stage 1 Tracks A–F, merged into `main` via [Upstream PR #8](https://github.com/Szpili/SIMON/pull/8) at commit `d108364`, followed by `5854038` on `main` and `d2f0d4f`..`53854d2` on `upstream/fz-contrib`)  
**Total Captain + Claude Review Commits Analyzed:** **22 commits** (`c35383a` through `53854d2` + `5854038`)

---

## 1. Executive Summary

All 6 Stage 1 tracks (`Track A` through `Track F`) implemented by the parallel Gemini 3.8 Flash (High) agents were merged into `fz-contrib` and subsequently into `Szpili/SIMON:main` (`PR #8`). However, before and immediately after merging `fz-contrib`, the Team Captain (`Szpili`) and his Claude Opus 5.5 agent (plus Argon & Copilot skeptic passes) had to land **22 corrective commits** addressing over 20 distinct engineering, security, and claim-discipline flaws introduced by the Stage 1 agents.

This post-mortem dissects **every single one of the 22 Captain commits**, groups them into **7 root failure patterns**, and establishes both **automated verification gates** (in [`verify_track.sh`](file:///home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-verify-suite/scripts/verify_track.sh)) and **updated Stage 2 (Waves 2A & 2B) and Stage 3 (Waves 3A & 3B) specifications** so that subsequent parallel agents operate at the Captain's exact standard.

---

## 2. Complete Catalog of the 22 Captain & Claude Commits

| # | Commit SHA | Track Fixed | Summary | Root Failure Pattern |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `c35383a` (`077c0d9`) | Track D (`cap.rs`) | `fix(core): missing tool args (null) mean no parameters, not a type error` | Pattern 6: Serde `Value::Null` regression |
| 2 | `e662a18` (`dc42482`) | Track D (`cap.rs`) | `test(core): arrays and explicit null for tool args` | Pattern 6: Missing edge-case tests |
| 3 | `f21bd64` (`f246743`) | Track A (`node.rs`, `receipt.rs`) | `fix(core,cli): receipts never sign a guessed precision` (added `Int8`, `Int4`, `Unknown`) | Pattern 1: Signing a guessed claim |
| 4 | `40fe464` (`e65d33a`) | Track A (`node.rs`) | `fix(cli): precision from whole name tokens; quantization wins over base format` | Pattern 1: Substring matching on model names/hex |
| 5 | `cf76ccc` (`99f3e14`) | Track A (`node.rs`) | `fix(cli): conservative precision rule — GGUF/W4A/FP8 families, any quant marker blocks base format, conflicts sign unknown` | Pattern 1: Incomplete quantization family rules |
| 6 | `35449f4` (`a33fadd`) | Track A (`node.rs`) | `fix(cli): precision — whole GGUF tokens only, AWQ/GPTQ with fp8/fp4 is a conflict, generic 'quantized' blocks base format` | Pattern 1: Prefix-only token matching (`q8deadbeef`) |
| 7 | `775b041` (`6e08827`) | Track F (`ui`, `docs`, `tools`) | `fix(ui,docs,tools): remove claims the repo cannot back` (dropped `/network` simulated badge, unbacked 61.8/199.1 tok/s, CANARY-7 claim; marked dry-run `simulated`) | Pattern 3: Overclaiming & mislabeling live UI |
| 8 | `6f709ff` (`2cd4e9f`) | Track F (`m3.rs`, `docs`, `api`) | `fix(core,tools,docs): any 'simulated' value but false rejects an audit; hashed token compare; no hard-coded test count` | Pattern 3 & 6: Weak `simulated` check, length leak in Bearer compare, pinned test count |
| 9 | `d5c0f4e` (`b1c9a52`) | Track F (`m3.rs`, `api`) | `test(core): simulated audits rejected for the right reason; accurate token-compare comment` | Pattern 6: Assertion specificity |
| 10 | `befdb9d` | Track B (`agent.rs`, `api`) | `fix(cli,api): proof level is what the client verified, not what the node declared; own nonce in map-reduce M1` | Pattern 2: Trusting node-declared `receipt_level` & receipt's own `client_nonce` |
| 11 | `950593a` | Track B (`agent.rs`) | `style(cli): poziom_sprawdzony above the zweryfikuj_receipt doc block` | Misplaced helper inside doc comment |
| 12 | `1b26870` | Track E & B (`coord.rs`, `agent.rs`) | `fix(coord,cli): coordinator ignores results for jobs not assigned to that node; agent nonce is mandatory` | Pattern 5 & 2: Unassigned `JobResult` DoS on gossipsub & optional nonce fallback |
| 13 | `9450c2d` | Track C (`agent_triage.py`) | `fix(industry): triage agent may only restate what the rules decided` | Pattern 4: Enum-only check vs binding to `rules.findings(row)` + Unicode/CSV sanitization |
| 14 | `a8dc462` | Track C (`agent_triage.py`) | `fix(industry): selfcheck message prints the real rejection count` | Hardcoded print string vs variable |
| 15 | `354e3db` | Track C (`industry/+page.svelte`) | `fix(ui/industry): no fake grant signature, no '100% authentic', no phone overflow` | Pattern 3 & 7: Fake browser signature, overclaiming verdict copy, 390px mobile overflow |
| 16 | `783c667` | Tracks C, E, F (`triage`, `api`, `coord`, `ui`) | `fix(industry,api,coord,ui): review round on fz-contrib fixes` (multi-finding urgency/action pairing, `complete_job` on failure, `m1_binding_checked`, last `MITM Caught!` label) | Pattern 4, 5, 3 |
| 17 | `d108364` | Stage 1 Merge (`main`) | `Merge PR #8 (Filip): fz-contrib stage 1, tracks A-F` | Upstream merge into `main` |
| 18 | `5854038` | Track F (`LABLAB-SUBMISSION.md`) | `submission text: per-node medians from the run data (1.56 s RTX 3090, 1.67 s MI300X)` | Pattern 3: Exact median calculation from `.jsonl` data |
| 19 | `d2f0d4f` | Tracks A, B, C, E, F (`agent`, `api`, `coord`, `triage`, `ui`) | `fix(agent,api,coord,industry,ui): pin the receipt signer; second review round` (live `--expect-signer` in `agent.rs` & `simon_api.py`, remove leaked `/home/agent/SIMPN_ARGON_HANDOWER` path, catch `REJECTED_BY_CEILING` in loop, 5 hashed grant params) | Pattern 2 & 4: Unpinned live signer, leaked local path, unhandled tool error |
| 20 | `7f4fb64` | Track E (`coord.rs`) | `style(coord): clippy contains_key in test` | Missing `--all-targets` in clippy invocation |
| 21 | `c5f563b` | Node DoS (`node.rs`, `main.rs`, `api`) | `feat(node): per-peer rate limit and replay guard (DoS from inside the company network)` (`--rate-per-peer`, 4096 `(peer, job_id)` replay window) | Pattern 5: VPN insider DoS protection |
| 22 | `e2948a3` & `53854d2` | UI & Docs (`plant-nodes.ts`, `/receipts`, `STRESS-TESTS.md`, `ci.yml`) | `feat(ui): plant-listed vs unknown node badge; /receipts — what a receipt proves` & `docs: STRESS-TESTS.md — attack → test → result → fix/limit; agent_triage self-check in CI` | Pattern 2 & 3: Honest receipt UX & attack matrix |

---

## 3. Deep Dive: The 7 Root Failure Patterns & Permanent Fixes

### Pattern 1: Never Sign or Report a Guess (`f21bd64`, `40fe464`, `cf76ccc`, `35449f4`)
* **What happened**: Track A replaced hardcoded `Precision::Fp16` with `wykryj_precyzje(model_hash)`, which used substring `.contains()` (`"q4" -> Fp4`, `"q8" -> Fp8`, default `Fp16`).
* **Why it was wrong**:
  1. Integer weight quantization (`GGUF Q4_0`, `IQ4_XS`, `AWQ`, `GPTQ`, `INT4`, `Q8_0`, `W8A8`) is **integer** quantization (`Int4` / `Int8`), NOT floating-point (`Fp4` / `Fp8`).
  2. Substring matching matched hex substrings like `"...f16..."` or `"q8deadbeef"`, and matched `"bf16"` before `"q4_0"` on `"gemma-bf16-q4_0"`.
  3. Defaulting unmarked models (or `Q5_K_M` / `Q6_K` or conflicting `"awq-fp8"`) to `Fp16` caused the node to **sign a guessed claim**.
* **Mandatory Rule for Stage 2 & 3**:
  - **NEVER guess a signed field.** If a value is unknown, ambiguous, or unsupported, use `Precision::Unknown`, `Option::None`, or return `Err`.
  - Parse whole alphanumeric tokens only (`split(|c: char| !c.is_ascii_alphanumeric())`), never substrings.

### Pattern 2: Client-Verified State vs. Node-Declared State (`befdb9d`, `1b26870`, `d2f0d4f`, `e2948a3`)
* **What happened**:
  1. Track B set `poziom_dowodu = rec.poziom()` (what the node's receipt *claimed*), so a dishonest node claiming `receipt_level = 1` without sending `prompt_token_ids`/`output_token_ids` got `poziom_dowodu = 1` with zero M1 verification performed.
  2. Track B fell back to reading `client_nonce` from inside the node's own receipt (`rec.wiazania.client_nonce`) when `oczekiwany_nonce` was `None` or in `wyodrebnij_output` (MapReduce) — which verified the receipt against itself!
  3. Track A wired `--expect-signer` only to offline `--verify-receipt`, leaving live `--role agent` and `simon_api.py` unpinned (`verify_self()` only checks the key embedded inside the receipt itself).
* **Mandatory Rule for Stage 2 & 3**:
  - **Never trust a node's declaration as a client verdict.** Always distinguish `poziom_sprawdzony` (verified by client on actual tokens) from `poziom_deklarowany_przez_node`.
  - **Nonces and expected signers MUST come from the client's own order/config**, never from the receipt being verified.

### Pattern 3: Zero Overclaiming in UI, Verdicts, and Documentation (`775b041`, `6f709ff`, `354e3db`, `783c667`, `5854038`)
* **What happened**:
  1. Track F added a `"SIMULATED P2P TOPOLOGY"` badge to `/network`, which actually displays live telemetry from `simon-monitor` (hiding the live AMD Instinct MI300X node from judges!).
  2. Track C put `"ALLOW TICKET (100% Authentic)"` and `"MITM Attack Detected"` in `/industry`, and fabricated a fake string `"ed25519:operator_sig_..."` with `"status": "APPROVED"` for the browser capability grant button (when the browser has no operator private key).
  3. Track F wrote unbacked `61.8 tok/s` / `199.1 tok/s` / `8/8 CANARY-7 pass` and hardcoded `192 automated unit/integration tests` in `README.md` and `LABLAB-SUBMISSION.md`.
* **Mandatory Rule for Stage 2 & 3**:
  - **Every public claim or UI badge must state only what was cryptographically checked** (e.g., `"SIGNATURE & DIGEST VALID — Proves signer key and exact text; does not prove which model weights executed"`).
  - Browser previews without a private key must set `signature: null` and `status: "UNSIGNED_PREVIEW"`.
  - Never hardcode total repo test counts in docs (they break on the very next test commit) or cite numbers not backed by committed data files in `docs/`.

### Pattern 4: Rule-Bound Guardrails, Unicode Normalization & Zero Workspace Path Leaks (`9450c2d`, `783c667`, `d2f0d4f`)
* **What happened**:
  1. Track C's `execute_propose_work_order` only checked whether `urgency` and `action_code` belonged to static lists rather than verifying they matched `rules.findings(row)[0]` (the most urgent rule finding for that machine).
  2. Free-text filtering only checked ASCII `"shut down"`, missing Unicode `NFKC` full-width (`ｐｏｗｅｒ off`), zero-width format chars (`shut\u200bdown`), hyphens (`shut-down`), and shutdown synonyms (`de-energize`, `cut power`).
  3. Raw CSV fields (`product_id`, `type`) were interpolated into the prompt and tool outputs without sanitization.
  4. Track C left `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_C/...` inside `find_default_csv()`!
* **Mandatory Rule for Stage 2 & 3**:
  - **Never include `/home/agent/SIMPN_ARGON_HANDOWER` or `/home/agent/SIMON` in any repository file.** (`verify_track.sh` now fails the build automatically if any workspace path appears in a diff).
  - All free-text guardrails must normalize with `NFKC`, strip Unicode `Cf` format characters, treat hyphens as spaces, and check length *after* normalization.

### Pattern 5: Adversarial P2P & Gossipsub State Machines (`1b26870`, `783c667`, `c5f563b`)
* **What happened**:
  1. Track E's `coord::obsluz_wynik` degraded `res.node_id` on any `JobResult` failure arriving over gossipsub without checking `rejestr.assigned.get(&res.job_id) == Some(&res.node_id)` — allowing any peer to DoS any node with a single unsigned packet.
  2. When an assigned job failed, `obsluz_wynik` forgot to call `rejestr.complete_job(&res.job_id)`, leaking the assignment forever.
* **Mandatory Rule for Stage 2 & 3**:
  - Treat every gossipsub message (`JobResult`, `RegisterMsg`, `JobOrder`) and every P2P request (`PromptRequest`, `PromptResponse`) as untrusted input from a potential attacker inside the VPN.
  - Enforce length caps (`MAX_M1_TOKENS`) on all vector fields before hashing or storing.

### Pattern 6: Serde `Value::Null` Compatibility, `simulated` Audit Rejection & Constant-Time Auth (`c35383a`, `6f709ff`)
* **What happened**:
  1. Track D's `cap::waliduj` rejected `Value::Null` when serde deserialized a tool call with omitted optional `args` (`{"tool":"status"}`).
  2. Track F's `simon_api.py` compared raw strings in `hmac.compare_digest` (leaking key length) instead of comparing `sha256` digests.
  3. `m3::ocena_json` needed to reject any `"simulated"` field value other than `false` (`true`, `"true"`, `1`, `null`).

### Pattern 7: Mobile 390px Responsiveness & Accessibility (`354e3db`, `e2948a3`)
* **What happened**: Track C's `/industry` page was `494px` wide on a `390px` mobile screen because grid children lacked `min-w-0` and hex strings lacked `break-all`. Buttons lacked `type="button"` and `aria-pressed`.

---

## 4. Impact on Stage 2 and Stage 3 Architecture

In commit `53854d2`, the Team Captain created [`docs/STRESS-TESTS.md`](file:///home/agent/SIMON/docs/STRESS-TESTS.md) defining a 16-row attack matrix for SIMON inside a company VPN and explicitly listed the 4 next priorities under `## Next (owner in the team channel)`:

1. **Sign `JobResult` (failures too) with the node key; coordinator verifies before any state change.** -> **Assigned to Stage 2, Wave 2A (`Track J`)**
2. **Wire live M1: node tokenizes prompt and output via the backend, sends ids with length caps.** -> **Assigned to Stage 2, Wave 2A (`Track H`)**
3. **Signed node registration (keys and vouching for new nodes), then Sybil tests.** -> **Assigned to Stage 2, Wave 2A (`Track J`)**
4. **A prepared target network for an outside tester (attack the connected nodes, report against this table).** -> **Assigned to Stage 3, Wave 3A (`Track K`)**

Accordingly, we have reorganized **Stage 2** into **Wave 2A (`Track H`, `Track J`)** and **Wave 2B (`Track G`, `Track I`)**, and created **Stage 3** split into **Wave 3A (`Track K`, `Track L`)** and **Wave 3B (`Track M`, `Track N`)**, with **100% mutually disjoint file ownership across all 8 tracks (`G`–`N`)**.
