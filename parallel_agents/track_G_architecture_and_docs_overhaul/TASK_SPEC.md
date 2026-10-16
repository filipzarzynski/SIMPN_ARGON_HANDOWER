# Agent Task Specification: Track G (Stage 2, Wave 2B) — Architecture, Stress-Tests & Documentation Alignment (`[FZ-G]`)

**Stage:** Stage 2, Wave 2B (Run AFTER Wave 2A Tracks H & J are integrated into `fz-contrib`)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-G-architecture-and-docs-overhaul`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_G`  
**Exclusive Permitted Files:**
* `docs/ARCHITECTURE.md`
* `docs/STRESS-TESTS.md`
* `docs/THREAT-MODEL.md`
* `ROADMAP.md`
* `docs/whitepaper/SIMON-whitepaper-EN.md`

---

## 0. Mandatory Skills to Read First
1. `/home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-captain-review-guardrails/SKILL.md`
2. `/home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-crypto-and-protocol/SKILL.md`
3. `/home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-industry-and-ui/SKILL.md`

> [!CAUTION]
> **Captain Guardrails for Track G (Non-Negotiable):**
> 1. **Governing rule (`no evidence, no status`):** Every performance number you write MUST match a raw data file in `docs/` (`docs/AMD-MI300X-RESULTS.md`, `docs/amd-data/`, `docs/industry/`).
>    - **DO NOT** write `61.8 tok/s` or `199.1 tok/s` for Gemma 4 (the Captain deleted those in commit `875b450` because they had no raw data file; use the measured `12–17 s per alert` for Gemma 4 26B-A4B on RTX 3090 + AMD MI300X, and `64 concurrent streams at ~2000 tok/s` / `510 jobs` from `docs/AMD-MI300X-RESULTS.md` for Qwen3.8-27B on MI300X).
>    - **DO NOT** hardcode fragile test counts (e.g. `"255 tests"` or `"48/48 tests"`).
> 2. **Strict Claim Discipline (`docs/THREAT-MODEL.md`):**
>    - SIMON is a **verifiable inference-result publication** layer, NOT an execution-proof layer.
>    - Never write `"100% Authentic"`, `"100% Cryptographically Verified"`, `"guarantees the model ran"`, or `"prevents prompt injection"`.

---

## 1. Objective

Deliver an authoritative, Captain-grade documentation and stress-test matrix update on top of `fz-contrib` (after Wave 2A Tracks H and J land):

1. **Create `docs/ARCHITECTURE.md` (`[FZ-G1]`)**:
   - End-to-end Mermaid architecture and sequence diagrams (using quoted node labels `id["Label (Extra Info)"]`) for:
     - **Track 1 Intelligent Industry Pipeline**: UCI AI4I 2020 Milling (`10,000` rows) $\rightarrow$ `rules.py` (`8 ms`, 0 tokens, deterministic 5-mode catalog) $\rightarrow$ Gemma 4 26B-A4B triage & ticket generation on RTX 3090 + AMD Instinct MI300X (`12–17 s/alert`, NFKC + `Cf` format-stripped inputs, action/mode/urgency locked to `rules.findings(row)[0]`, steps restricted to `STEP_CATALOG[mode]`) $\rightarrow$ `Receipt` (`SIMON/RECEIPT/v1` Level 0 + `WiazaniaM1` Level 1) + operator `Zezwolenie` (`SIMON/GRANT/v1`).
     - **Cryptographic Verification & Probing Hierarchy**:
       - **Cryptographically proven (offline CPU / WASM):** Level 0 (`Receipt::verify_self` + `Receipt::zgodny_z_wyjsciem` with `SIMON/RECEIPT/v1` & `SIMON/OUTPUT/v1` SHA-256 + Ed25519 + `--expect-signer` key pinning) and Level 1 (`WiazaniaM1` with `SIMON/PROMPT/v1`, `SIMON/CHAIN/v1`, `SIMON/SAMPLING/v1`, `SIMON/TOKENIZER/v1`, verified against client-held `order.nonce` and token ids capped at `MAX_M1_TOKENS = 65_536`).
       - **Empirically detected (telemetry / probes, NOT proof):** `m3::ocena` cross-hardware FP drift diagnostic (`simulated` flag rejected by CLI/WASM), `docs/VERIFIER-PILOT.md` (behaviour 46/50, quantization separable), `tools/simon-lidar/onetoken.py`, and `tools/simon-canary/simon_canary.py` (`CANARY-7`).
       - **Policy / heuristic (blast-radius reduction, NOT prevention):** `simon_core::cap::{Sufit, Zezwolenie}` (`SIMON/GRANT/v1`, `SIMON/GRANT-PARAMS/v1`), per-peer rate limiting (`--rate-per-peer`), and SSRF IPv4/IPv6/CGNAT filtering (`web.rs`).
     - **P2P Transport & Coordinator**: `simon agent` $\leftrightarrow$ `simon node` (`/simon/prompt/1.0.0` over libp2p Noise), `simon coord` (`SignedJobResult` under `SIMON/JOB-RESULT/v1` and `RegisterMsg` + `NodeVoucher` under `SIMON/NODE-REGISTER/v1` & `SIMON/NODE-VOUCH/v1`), and OpenAI gateway (`tools/simon-api/simon_api.py`).

2. **Update `docs/STRESS-TESTS.md`, `docs/THREAT-MODEL.md`, `ROADMAP.md`, and `docs/whitepaper/SIMON-whitepaper-EN.md` (`[FZ-G2]`)**:
   - In `docs/STRESS-TESTS.md`:
     - Update **Row 7** (`Forged gossip result marks a healthy node Degraded`) to reflect Track J's `SignedJobResult` (`SIMON/JOB-RESULT/v1` signed by the assigned node's Ed25519 key for both successes and failures; tested by `coord.rs::niepodpisany_lub_obcy_blad_odrzucony`).
     - Add **Row 17** (`Live M1 token chain tampering or >65536 token OOM flood`, tested in `crates/simon-cli/tests/e2e_m1_receipt.rs`).
     - Add **Row 18** (`Unsigned / unvouched Sybil node registration flood on gossipsub`, tested in `coord.rs::sybil_bez_vouchera_odrzucony_w_trybie_voucher`).
     - Update `## Honest limits` and `## Next` to reflect that Next items #1, #2, and #3 are now implemented and tested in CI, leaving item #4 (prepared target network harness) as the next step.
   - In `docs/THREAT-MODEL.md`, `ROADMAP.md`, and `docs/whitepaper/SIMON-whitepaper-EN.md`:
     - Align the implementation status table with the current codebase (Level 1 live M1 token chain wired with `MAX_M1_TOKENS`, signed `JobResult` and signed `RegisterMsg` + operator vouching, MI300X 64-stream overhead benchmark in `docs/AMD-MI300X-RESULTS.md`, and VPN stress-test matrix in `docs/STRESS-TESTS.md`).

---

## 2. Granular Commit Plan (Cherry-Pickable by Team Captain)

1. `[FZ-G1] docs(arch): add docs/ARCHITECTURE.md with Mermaid data flows and claim hierarchy`
2. `[FZ-G2] docs(stress-tests,threat-model): update stress-test matrix rows 7/17/18 and milestone statuses`

---

## 3. Verification & PR Delivery

```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh G --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track G
```
