# 01 — SIMON Architecture, Data Flows & Stage/Wave Evolution Map (Team Sync Brief)

**Baseline Commit (`fz-contrib`):** `1d71e6d` (merges `upstream/main` `5854038` + `upstream/fz-contrib` `53854d2` — post-Stage 1 Captain & Claude Opus 5.5 review)  
**Purpose:** Single-document executive and technical briefing for the hackathon team call. Grounded 100% in the actual source code, this document separates:
* `[LIVE NOW — Post-Stage 1 (1d71e6d)]` — What is currently implemented, tested, and running in the repository right now.
* `[STAGE 2 — Wave 2A (Tracks H, J)]` — Urgent protocol & security closing items from the Captain's [`docs/STRESS-TESTS.md`](file:///home/agent/SIMON/docs/STRESS-TESTS.md) `## Next` list (`#1` Signed `JobResult`, `#2` Live M1 token binding with `MAX_M1_TOKENS`, `#3` Signed `RegisterMsg` + operator vouching + Sybil tests).
* `[STAGE 2 — Wave 2B (Tracks G, I)]` — Upstream `docs/ARCHITECTURE.md`, `STRESS-TESTS.md` rows 7/17/18 update, and one-command Captain verification gate (`scripts/verify_all_fast.sh` + cherry-pick menu).
* `[STAGE 3 — Wave 3A (Tracks K, L)]` — `STRESS-TESTS.md` `Next #4` prepared VPN target network attack harness (`vpn_attack_harness.rs`), client M1 missing-token gate, and `simon_api.py` / `simon_monitor.py` hardening.
* `[STAGE 3 — Wave 3B (Tracks M, N)]` — Industry NFKC/link/role guardrail parity across `tickets.py` & `agent_triage.py` (`stress_corpus.json` expanded 17 $\rightarrow$ 25 cases) and UI `/receipts` + `/demo` polish.

---

## 1. Executive 60-Second Brief for the Team Call

### 1.1 Strategic Framing & Deployment Boundary
Following the Oct 15–16 team call and Captain review ([`docs/THREAT-MODEL.md`](file:///home/agent/SIMON/docs/THREAT-MODEL.md), [`docs/STRESS-TESTS.md`](file:///home/agent/SIMON/docs/STRESS-TESTS.md)):
1. **What SIMON Is:** A **verifiable inference-result publication** layer (cryptographic non-repudiation of *who* signed *which* output for *which* input and *which declared* model/parameters), combined with deterministic **policy/capability ceilings (M7)** and empirical **canary/drift probes (M3, `CANARY-7`, verifier pilot)**. It is **not** a cryptographic proof of model execution (which requires a hardware TEE).
2. **Primary Target Deployment:** A **company or machining plant running SIMON across ~5 machines inside its own VPN**, where one participant (an employee, a compromised GPU node, or a gateway) may turn dishonest or suffer silent hardware weight corruption (e.g., consumer RTX 3090 without ECC memory).

### 1.2 Current Codebase vs. Stage 2 & Stage 3 Wave Matrix

| Architectural Subsystem | `[LIVE NOW — Post-Stage 1 (1d71e6d)]` (Already in Repo) | `[STAGE 2 — Waves 2A & 2B]` (Next Up — Priority 1) | `[STAGE 3 — Waves 3A & 3B]` (If Time Permits — Priority 2) |
| :--- | :--- | :--- | :--- |
| **1. Point-to-Point Inference & Receipts (`node.rs` $\leftrightarrow$ `agent.rs`)** | • Real `started_at_us`/`finished_at_us` timestamps<br>• Honest `Precision::{Fp16, Bf16, Fp8, Fp4, Int8, Int4, Unknown}` (no guessing)<br>• `llama.cpp` `/props` & `/tokenize` support<br>• Per-peer replay cache (`4096` jobs) & token-bucket rate limiter (`--rate-per-peer 16/s`)<br>• Key pinning (`--expect-signer`, `signer_pinned`)<br>• **Gap:** Live node still emits **Level 0** receipts (`wiazania: None`) | **`[Wave 2A — Track H]`** (`STRESS-TESTS.md` Next #2):<br>• `node.rs` calls `wspolne::tokenizuj_tekst` on prompt & output, builds `WiazaniaM1` (**Live Proof Level 1**), and returns token IDs in `PromptResponse`<br>• Enforces `MAX_M1_TOKENS = 65_536` cap on both `/tokenize` and `zweryfikuj_m1`<br>• Adds in-process `e2e_m1_receipt.rs` test | **`[Wave 3A — Track K]`** (`STRESS-TESTS.md` Next #4):<br>• Fixes `agent.rs::zweryfikuj_receipt` so a receipt claiming Level 1 (`poziom() >= 1`) without token arrays (`m1.is_none()`) is **rejected** instead of silently passing as Level 0<br>• Populates `prompt_commitment` & `tokenizer_manifest_hash` in `RekordPracyV1` |
| **2. P2P Coordinator, Gossipsub & Node Registry (`coord.rs`, `simon-node`)** | • `Registry::wybierz_kandydata_vrf` deterministic SHA-256 selection<br>• `coord.rs` subscribes to `TOPIC_JOB_RESULT`, checks `assigned_node == Some(node_id)` before `mark_degraded`, and calls `complete_job` on failure<br>• **Gap 1:** `JobResult` on gossip is **unsigned** (anyone who knows `(job_id, node_id)` can forge a failure)<br>• **Gap 2:** `RegisterMsg` on gossip is **unsigned** (Sybil nodes can flood `Registry`) | **`[Wave 2A — Track J]`** (`STRESS-TESTS.md` Next #1 & #3):<br>• Adds `SignedJobResult` (`SIMON/JOB-RESULT/v1`, Ed25519-signed by node key for **both successes and failures**)<br>• Adds Ed25519 signature (`SIMON/NODE-REGISTER/v1`) + optional `NodeVoucher` (`SIMON/NODE-VOUCH/v1`) to `RegisterMsg`<br>• Coordinator flags `--node-key` & `--require-voucher` + Sybil flood test | **`[Wave 3A — Track K]`** (`STRESS-TESTS.md` Next #4):<br>• Adds `crates/simon-cli/tests/vpn_attack_harness.rs`: spins up an in-process target network and runs 7 automated red-team attacks mapped to `STRESS-TESTS.md` rows 1–7, 17, 18 |
| **3. OpenAI HTTP Gateway & Network Monitor (`simon-api`, `simon-monitor`)** | • `simon_api.py` passes `--expect-signer` from `nodes.json`, checks `SIMON_API_KEY` via SHA-256 `hmac.compare_digest`, returns `503` + `Retry-After: 5` on `node_zajety`/`rate_limit`, and reports `proof_level` from `poziom_sprawdzony`<br>• `simon_monitor.py` tracks GPU stats, `CANARY-7` age, and per-node jobs | **`[Wave 2B — Track I]`**:<br>• Adds `scripts/verify_all_fast.sh` running all Rust tests, Clippy `--all-targets`, Python `.selfcheck()` suites, and guardrail greps in <30s | **`[Wave 3A — Track L]`**:<br>• Enforces `MAX_BODY_BYTES = 1 MiB` (`413`) in `simon_api.py` (blocks memory DoS) & logs `signer_pinned` to `SIMON_API_JOBLOG`<br>• Bounds `fetch_stats` in `simon_monitor.py` (`http/https` only, 64 KiB max) & tracks `verified_m1_jobs` / `pinned_jobs` |
| **4. Track 1 Intelligent Industry (`tools/simon-industry/`)** | • `rules.py` deterministic physics rules (`8 ms`, 0 tokens) + per-mode `CHECKS` catalog<br>• `tickets.py` checks step IDs against `rules.CHECKS`, strips model `evidence`, checks 17-case `stress_corpus.json`<br>• `agent_triage.py` locks `failure_modes`, `urgency`, `action_code`, `part_id` to `rules.findings(row)[0]`, normalizes Unicode (`NFKC` + `Cf` strip + dashes), and cleans CSV IDs<br>• **Gap:** `tickets.py` lacks `_znormalizuj` (`NFKC`/`Cf`), and `agent_triage.py` lacks `tickets.py`'s `LINKS` / `ROLE` / `URGENT` checks | **`[Wave 2B — Track G]`**:<br>• Documents the end-to-end Industry + M7 pipeline and claim hierarchy in `docs/ARCHITECTURE.md` | **`[Wave 3B — Track M]`**:<br>• Applies `_znormalizuj` (`NFKC` + `Cf` strip + dash collapse) to `tickets.py`<br>• Adds `LINKS` (including bare domains), `ROLE`, and `URGENT` checks to `agent_triage.py`<br>• Expands `stress_corpus.json` from **17 $\rightarrow$ 25 cases** |
| **5. Web UI (`ui/`) & Documentation (`docs/`)** | • Routes: `/`, `/demo`, `/network`, `/industry`, and new `/receipts` (`What a receipt proves`)<br>• `/industry` shows `plant-listed node` vs `unknown node` + `rules + checks` vs `held for review`<br>• 390px mobile overflow fixed + `type="button"` / `aria-pressed` on `NodePanel` & `VerifierPanel` | **`[Wave 2B — Track G & Track I]`**:<br>• Creates `docs/ARCHITECTURE.md` & `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md`<br>• Updates `docs/STRESS-TESTS.md` rows 7, 17, 18 & `## Honest limits` | **`[Wave 3B — Track N]`**:<br>• Adds Level 0 / Level 1 / M3 / M7 claim-label reference table to `/receipts`<br>• Adds **Tamper Client Nonce (Replay Attack)** button (`STRESS-TESTS.md` Row 4) + `aria-pressed` semantics to `/demo` |

---

## 2. High-Level System Topology (Current State + Stage 2/3 Overlays)

```mermaid
flowchart TB
    subgraph UI_Layer["1. Presentation & Browser WASM Verification Layer (ui/)"]
        SvelteUI["ui/ (SvelteKit 5 Static App)<br/>[LIVE NOW]: /, /demo, /network, /industry, /receipts<br/>[STAGE 3 - Wave 3B / Track N]: /receipts claim-label table + /demo nonce-replay tamper"]
        WASM["crates/simon-verify-wasm<br/>[LIVE NOW]: verify_self + zgodny_z_wyjsciem + weryfikuj_m1 + ocena_m3<br/>(Rejects null signatures, simulated M3 audits, NaN logprobs)"]
        Streamlit["demo/app.en.py & app.py<br/>[LIVE NOW]: Streamlit CLI wrapper (argv -- separator)"]
    end

    subgraph Gateway_Tools["2. Python Gateways, Industry & Probing Tools (tools/)"]
        Industry["tools/simon-industry/<br/>[LIVE NOW]: rules.py + tickets.py (17-case corpus) + agent_triage.py (NFKC/Cf)<br/>[STAGE 3 - Wave 3B / Track M]: NFKC/Cf in tickets.py + LINKS/ROLE in agent_triage.py + 25-case corpus"]
        API["tools/simon-api/simon_api.py (:18600)<br/>[LIVE NOW]: --expect-signer, SHA-256 Bearer auth, 503 Retry-After, poziom_dowodu<br/>[STAGE 3 - Wave 3A / Track L]: 1 MiB body limit (413) + signer_pinned in joblog + --selfcheck"]
        Monitor["tools/simon-monitor/simon_monitor.py (:8081)<br/>[LIVE NOW]: nvidia-smi / stats_url + CANARY-7 age + joblog tail<br/>[STAGE 3 - Wave 3A / Track L]: 64 KiB http/https stats cap + M1/pinned totals + --selfcheck"]
        Probes["Empirical Probes & Guard<br/>[LIVE NOW]: simon-canary (CANARY-7), simon-verifier, simon-lidar (onetoken.py), simon-guard (:19301)"]
    end

    subgraph Rust_Workspace["3. Rust Core & P2P Workspace (crates/)"]
        CLI_Agent["simon --role agent (crates/simon-cli/src/agent.rs)<br/>[LIVE NOW]: P2P /simon/prompt/1.0.0, --expect-signer, poziom_sprawdzony, order.nonce<br/>[STAGE 3 - Wave 3A / Track K]: Reject Level 1 receipt if token arrays missing + vpn_attack_harness.rs"]
        CLI_Node["simon --role node (crates/simon-cli/src/node.rs)<br/>[LIVE NOW]: Real timestamps_us, honest Precision, /props, 4096 replay cache, --rate-per-peer<br/>[STAGE 2 - Wave 2A / Track H]: Live M1 tokenization (/tokenize) + WiazaniaM1 + MAX_M1_TOKENS=65536"]
        CLI_Coord["simon --role coord (crates/simon-cli/src/coord.rs + simon-node)<br/>[LIVE NOW]: VRF candidate selection, assigned-node mark_degraded, complete_job on failure<br/>[STAGE 2 - Wave 2A / Track J]: SignedJobResult (SIMON/JOB-RESULT/v1) + signed RegisterMsg & NodeVoucher"]
        Core["crates/simon-core & simon-harness<br/>[LIVE NOW]: Ed25519, Receipt, WiazaniaM1, m3, cap (Sufit/Zezwolenie), web (IPv4/IPv6/CGNAT SSRF)"]
    end

    subgraph Hardware_Backends["4. LLM Inference Backends"]
        RTX3090["Plant Node 1: Local RTX 3090 (24 GB)<br/>llama-server / vLLM · gemma-4-26b-a4b-it-qat-q4_0"]
        MI300X["Plant Node 2: AMD Instinct MI300X (192 GB, ROCm 7.2.3)<br/>vLLM 0.27.1 · gemma-4-26b-a4b-it-bf16 / Qwen3.8-27B (64 streams @ ~2000 tok/s)"]
    end

    SvelteUI --> WASM
    WASM --> Core
    SvelteUI -. "Polls /api/monitor" .-> Monitor
    Industry -- "POST /v1/chat/completions" --> API
    API -- "spawns subprocess (--request-file -)" --> CLI_Agent
    CLI_Agent -- "libp2p Noise /simon/prompt/1.0.0" --> CLI_Node
    CLI_Node -. "Gossipsub simon/v1/*" .-> CLI_Coord
    CLI_Node -- "HTTP /v1/chat/completions + /tokenize + /props" --> RTX3090
    CLI_Node -- "HTTP /v1/chat/completions + /tokenize + /props" --> MI300X
```

---

## 3. Data Flow A: Point-to-Point Inference & Receipt Pipeline (`simon_api.py` $\leftrightarrow$ `agent.rs` $\leftrightarrow$ `node.rs`)

This is the **primary production path** used by `simon --role agent`, `tools/simon-api/simon_api.py`, `tools/simon-industry/tickets.py`, and `tools/simon-industry/agent_triage.py`.

### 3.1 Sequence Diagram (Current `[LIVE NOW]` vs `[STAGE 2 — Wave 2A]` & `[STAGE 3 — Wave 3A]`)

```mermaid
sequenceDiagram
    autonumber
    participant Client as simon_api.py / tickets.py
    participant Agent as simon --role agent<br/>(crates/simon-cli/src/agent.rs)
    participant Node as simon --role node<br/>(crates/simon-cli/src/node.rs)
    participant LLM as vLLM / llama-server<br/>(HTTP :8000 / :18020)

    Client->>Agent: Spawn with --request-file - (stdin JSON)<br/>+ --expect-signer <node_id> [LIVE NOW: e2948a3]
    Note over Client: [STAGE 3 - Wave 3A / Track L]:<br/>Enforce MAX_BODY_BYTES = 1 MiB (HTTP 413) before reading request
    Note over Agent: 1. Load 0600 identity (~/.simon/api-client.id)<br/>2. Build JobOrder with fresh 128-bit nonce & sign Autoryzacja
    Agent->>Node: Dial --bootstrap Multiaddr over libp2p (TCP + Noise + Yamux)<br/>Send PromptRequest (CBOR /simon/prompt/1.0.0)

    Note over Node: [LIVE NOW: c1f8ef9] Per-Peer Admission Gate:<br/>1. Check (peer, job_id) against 4096-entry replay ring -> reject "powtorzony_job"<br/>2. Check token bucket (--rate-per-peer 16/s, 4s burst) -> reject "rate_limit"<br/>3. Acquire przyjecia (max_jobs*4) & sloty (max_jobs) semaphores

    Node->>LLM: Startup / cached probe: GET /v1/models & GET /props<br/>[LIVE NOW: 40e0d53] Detect vLLM vs llama.cpp runtime & whole-token Precision
    Node->>LLM: POST /tokenize ({"prompt": ...} or {"content": ...})<br/>Context gate C+1: reject "ctx_ponad_limit" if realny_ctx > max_ctx

    Node->>LLM: POST /v1/chat/completions (messages, tools, temp, max_tokens)
    LLM-->>Node: HTTP 200 JSON (choices[0].message, usage,started/finished_at_us)

    rect rgb(30, 55, 40)
        Note over Node,LLM: [STAGE 2 - Wave 2A / Track H] (STRESS-TESTS.md Next #2 — Live M1 Wiring):<br/>1. Call wspolne::tokenizuj_tekst(b, req.prompt) -> prompt_token_ids (capped at MAX_M1_TOKENS = 65_536)<br/>2. Call wspolne::tokenizuj_tekst(b, output) -> output_token_ids (capped at MAX_M1_TOKENS = 65_536)<br/>3. Attach Receipt::z_wiazaniem_m1(tokenizer_hash, req.nonce, &p_ids, &o_ids, ...) BEFORE .sign(&klucz)
    end

    Node-->>Agent: PromptReply::Ok(PromptResponse { output, receipt,<br/>tokenizer_hash, prompt_token_ids, output_token_ids })

    Note over Agent: Client-Side Verification (agent.rs::zweryfikuj_receipt):<br/>1. [LIVE NOW] r.verify_self() (Ed25519 signature over canonical Receipt JSON)<br/>2. [LIVE NOW] podpisal_oczekiwany(receipt, --expect-signer) (Key Pinning)<br/>3. [LIVE NOW] r.job_id == expected && r.model_hash == expected<br/>4. [LIVE NOW] r.zgodny_z_wyjsciem(output) (SIMON/OUTPUT/v1 digest)<br/>5. [LIVE NOW: ca62c72] If M1 tokens present, r.zweryfikuj_m1(tok_hash, order.nonce, p_ids, o_ids)<br/>6. [LIVE NOW: e621d39] poziom_dowodu = poziom_sprawdzony(ok, m1_checked, r.poziom())<br/>7. [STAGE 3 - Wave 3A / Track K] Reject if r.poziom() >= 1 but M1 token arrays are missing!

    Agent-->>Client: Stdout JSON (ok, output, receipt, poziom_dowodu, signer_pinned)
```

---

## 4. Data Flow B: Gossipsub Coordinator & Node Registry (`coord.rs` & `simon-node`)

In `crates/simon-node/src/lib.rs` and `crates/simon-cli/src/coord.rs`, SIMON implements a Gossipsub-based coordinator (`simon --role coord`) that maintains a `Registry` of nodes, selects candidates via deterministic VRF (`wybierz_kandydata_vrf`), and tracks node health via `TOPIC_JOB_RESULT`.

### 4.1 What Changed in Stage 1 vs What Lands in `[STAGE 2 — Wave 2A / Track J]`

During Stage 1 review (`c1f8ef9`, `53854d2`), the Captain fixed `coord.rs` so that an unassigned `JobResult` cannot degrade a healthy node and ensured `complete_job` is called on failure, **but explicitly noted two remaining security limits in [`docs/STRESS-TESTS.md`](file:///home/agent/SIMON/docs/STRESS-TESTS.md#L27-L50)**:
1. **Row 7 & Next #1 (Unsigned `JobResult`):** `JobResult` (`{job_id, node_id, ok, receipt, blad}`) is currently unsigned, and failed jobs have `receipt: None`. Any peer on the VPN who observes a fresh `(job_id, node_id)` assignment on `TOPIC_ORDER_ACCEPTED` can broadcast `JobResult { ok: false, receipt: None }` to `TOPIC_JOB_RESULT` and mark the honest node `Degraded`.
2. **Honest Limits & Next #3 (Unsigned Node Registration / Sybil):** `RegisterMsg` on `TOPIC_NODE_REGISTER` carries no Ed25519 signature and no operator voucher, allowing a Sybil attacker to register arbitrary fake `node_id`s or overwrite an honest node's `RegisterMsg`.

**Both gaps are closed in `[STAGE 2 — Wave 2A / Track J]`:**

```mermaid
sequenceDiagram
    autonumber
    participant Op as Plant Operator Key<br/>(--trusted-voucher)
    participant Node as simon --role node<br/>(crates/simon-cli/src/node.rs)
    participant Gossip as libp2p Gossipsub<br/>(simon/v1/* topics)
    participant Coord as simon --role coord<br/>(crates/simon-cli/src/coord.rs)

    rect rgb(30, 45, 65)
        Note over Op,Coord: [STAGE 2 - Wave 2A / Track J] (STRESS-TESTS.md Next #3 — Signed Registration & Vouching)
        Op->>Node: Optional offline/config NodeVoucher signed under "SIMON/NODE-VOUCH/v1"
        Node->>Gossip: Publish signed RegisterMsg ("SIMON/NODE-REGISTER/v1")<br/>with node_pubkey, timestamp_us, signature, voucher
        Gossip->>Coord: obsluz_rejestracje(dane)
        Note over Coord: 1. Verify RegisterMsg::verify_signature() (node owns node_id)<br/>2. If --require-voucher, verify msg.verify_voucher(&trusted_vouchers)<br/>3. Reject Sybil / unsigned / unvouched nodes before Registry::register()
    end

    Gossip->>Coord: JobOrder on "simon/v1/job-order"
    Note over Coord: [LIVE NOW] Verify order.zweryfikuj_autoryzacje(teraz)<br/>Select node via wybierz_kandydata_vrf(model, vrf_seed)<br/>Record rejestr.assign(job_id, winner.node_id)
    Coord->>Gossip: Publish signed OrderAccepted to "simon/v1/order-accepted"

    rect rgb(30, 55, 40)
        Note over Node,Coord: [STAGE 2 - Wave 2A / Track J] (STRESS-TESTS.md Next #1 — SignedJobResult)
        Node->>Gossip: Publish SignedJobResult ("SIMON/JOB-RESULT/v1")<br/>(Ed25519-signed by node key over {domena, job_id, node_id, ok, receipt_digest, blad, timestamp_us})
        Gossip->>Coord: obsluz_wynik(dane)
        Note over Coord: 1. Look up assigned_node = rejestr.assigned_node(job_id)<br/>2. Look up expected_pubkey for assigned_node (--node-key or registered pubkey)<br/>3. Verify SignedJobResult::verify(&expected_pubkey)<br/>4. If ok=true, also verify Receipt::verify_self() & signer == expected_pubkey<br/>5. Only after valid signature: complete_job(job_id) (or mark_degraded + complete_job on signed failure)
    end
```

---

## 5. Cryptographic Domain Tree & Verification Hierarchy (`simon-core` & `simon-verify-wasm`)

All domain-separated SHA-256 commitments in SIMON use `content_digest<T>` (`serde_json::to_string` $\rightarrow$ SHA-256 $\rightarrow$ 64-char hex) with no floating-point numbers (`f32`/`f64` are forbidden in signed structs; timestamps are `u64` microseconds and temperatures/top-p are integer-scaled `u32`).

```mermaid
flowchart TB
    subgraph L0["Level 0: Authorship & Output Binding [LIVE NOW — Cryptographically Proven]"]
        D_OUT["SIMON/OUTPUT/v1<br/>{domena, job_id, output} -> output_digest"]
        D_REC["SIMON/RECEIPT/v1 (Receipt::digest)<br/>{job_id, node_id, model_hash, runtime, precision,<br/>activation_hash, output_digest, tokens, timestamps_us, signer, wiazania}<br/>-> Ed25519 Receipt.signature"]
        Pin["Client Key Pinning [LIVE NOW: e2948a3]<br/>--expect-signer / nodes.json node_id / simon verify --signer<br/>(Distinguishes plant-listed node vs unknown node)"]
        D_OUT --> D_REC --> Pin
    end

    subgraph L1["Level 1: Input & Token-Chain Binding (WiazaniaM1) [LIVE IN CORE/WASM; LIVE IN NODE IN STAGE 2 WAVE 2A]"]
        D_TOK["SIMON/TOKENIZER/v1 || 0x00 || bytes<br/>-> tokenizer_hash"]
        D_PRM["SIMON/PROMPT/v1<br/>{domena, tokenizer_hash, client_nonce (from order.nonce!), prompt_token_ids}<br/>-> prompt_digest (capped at MAX_M1_TOKENS = 65_536 in Track H)"]
        D_CHN["SIMON/CHAIN/v1<br/>{domena, prompt_digest, output_token_ids}<br/>-> output_token_chain"]
        D_SMP["SIMON/SAMPLING/v1<br/>{domena, temp_milli, top_p_milli, top_k, rep_pen_milli}<br/>-> sampling_params_hash"]
        D_TOK & D_PRM & D_CHN & D_SMP --> Wiaz["WiazaniaM1 inside Receipt<br/>Verified by Receipt::zweryfikuj_m1 (calls verify_self first!)"]
    end

    subgraph P2P_Domains["P2P Coordinator & Client Domains"]
        D_AUT["SIMON/AUTORYZACJA/v1 & SIMON/ACCEPTED/v1 & SIMON/OBSERVATION/v1<br/>[LIVE NOW]: Signed JobOrder, OrderAccepted, ClientObservationV1"]
        D_JR["SIMON/JOB-RESULT/v1<br/>[STAGE 2 - Wave 2A / Track J]: SignedJobResult (successes & failures)"]
        D_NR["SIMON/NODE-REGISTER/v1 & SIMON/NODE-VOUCH/v1<br/>[STAGE 2 - Wave 2A / Track J]: Signed RegisterMsg & Operator NodeVoucher"]
    end

    subgraph M7_Domains["M7 Capability Ceiling & Operator Grants [LIVE NOW — Policy / Blast-Radius Reduction]"]
        D_GP["SIMON/GRANT-PARAMS/v1<br/>{domena, akcja, parametry (null -> {})} -> parametry_digest"]
        D_GR["SIMON/GRANT/v1 (Zezwolenie)<br/>Single-use, TTL-bounded Ed25519 operator grant over parametry_digest"]
        D_GP --> D_GR
    end
```

---

## 6. Track 1 Intelligent Industry Pipeline (`tools/simon-industry/` & `/industry` UI)

This pipeline powers the **Intelligent Industry** hackathon track, running Gemma 4 26B-A4B across the local RTX 3090 (`Q4_0`) and AMD Instinct MI300X (`BF16`) on the UCI AI4I 2020 milling dataset (`10,000` records).

```mermaid
flowchart TB
    CSV["UCI AI4I 2020 Milling Dataset<br/>data/ai4i2020.csv (10,000 rows)"] --> Clean["Input Sanitization<br/>[LIVE NOW: 7f4fb64]: _czysty_id() strips non-[A-Za-z0-9-] from CSV IDs before prompt"]
    Clean --> Rules["1. Deterministic Physics Rules (rules.py — 8 ms, 0 tokens)<br/>[LIVE NOW]: Evaluates HDF, PWF, OSF, TWF thresholds & assigns priority-ordered findings + allowed CHECKS catalog"]
    Rules -->|"No rule fired (9,661 rows)"| NoCall["0 LLM Tokens Spent<br/>(3 labelled RNF/missed rows recorded honestly as 'rules miss')"]
    Rules -->|"Rule fired (15 sampled alerts)"| Branch{"Pipeline Mode"}

    Branch -->|"Batch Ticket Generator (tickets.py)"| Tickets["tickets.py -> simon_api.py (:18600)<br/>Routes across RTX 3090 (Gemma 4 Q4_0) & AMD MI300X (Gemma 4 BF16)"]
    Branch -->|"Multi-Turn Tool Agent (agent_triage.py)"| Triage["agent_triage.py -> simon_api.py (:18600)<br/>Tools: lookup_machine_history, check_spare_parts_inventory,<br/>inspect_sensor_telemetry, propose_work_order"]

    Tickets --> CheckT["tickets.py:check() Output Validator<br/>[LIVE NOW: b51e439]:<br/>• Exact 6-field JSON schema (evidence copied from rules, never model)<br/>• checks must be IDs from rules.CHECKS[mode] (no free-text steps!)<br/>• failure_modes == rules, urgency in rules, needs_human_review == True<br/>• No invented numbers (>10), no LINKS (incl. bare domains), no ROLE, no URGENT, no FORBIDDEN<br/>• Tested against 17-case stress_corpus.json<br/>[STAGE 3 - Wave 3B / Track M]:<br/>• Add _znormalizuj (NFKC + Cf strip + dash collapse) to tickets.py<br/>• Expand stress_corpus.json from 17 -> 25 adversarial cases"]

    Triage --> CheckA["agent_triage.py:execute_propose_work_order() M7 Gate<br/>[LIVE NOW: 7f4fb64]:<br/>• Locks failure_modes, urgency, action_code, and part_id to rules.findings(row)[0]<br/>• _znormalizuj(summary) (NFKC + Cf format strip + dash collapse) + FORBIDDEN synonyms<br/>• Computes SIMON/GRANT-PARAMS/v1 SHA-256 digest for operator Zezwolenie<br/>[STAGE 3 - Wave 3B / Track M]:<br/>• Add LINKS (URLs/emails/bare domains), ROLE, and URGENT checks to summary"]

    CheckT & CheckA --> UI_Ind["SvelteKit /industry Page (ui/src/routes/industry/+page.svelte)<br/>[LIVE NOW: c5f563b, e2948a3]:<br/>• Verifies every ticket's Ed25519 Receipt + output_digest in browser WASM<br/>• Displays 'plant-listed node' vs 'unknown node' (key pinning) & 'rules + checks' vs 'held for review'<br/>• Interactive Tamper Output & Tamper Grant Digest buttons"]
```

---

## 7. Complete Stage 2 & Stage 3 Wave Roadmap (For Team Call Agenda)

All tracks branch off **`fz-contrib` (`1d71e6d`)** and open PRs targeting **`fz-contrib`** (never `main`), with atomic `[FZ-<Track><N>]` commits so the Team Captain (`Szpili`) can cherry-pick individual commits or merge `fz-contrib` in one click.

| Stage & Wave | Track | Tag | Branch (`-> fz-contrib`) | Exclusive Files Touched | Exact Deliverable & `STRESS-TESTS.md` Mapping |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Stage 2 — Wave 2A**<br>*(Urgent Protocol & Security)* | **Track H** | `[FZ-H]` | `fz/track-H-e2e-integration-and-live-m1-bridge` | `crates/simon-cli/src/wspolne.rs`<br>`crates/simon-cli/src/node.rs`<br>`crates/simon-cli/tests/e2e_m1_receipt.rs` | **`STRESS-TESTS.md` Next #2:** Wires live M1 token chain in `node.rs` via `/tokenize`, enforces `MAX_M1_TOKENS = 65_536` cap in `wspolne.rs` & `node.rs`, and adds in-process E2E test (`e2e_m1_receipt.rs`). |
| **Stage 2 — Wave 2A**<br>*(Urgent Protocol & Security)* | **Track J** | `[FZ-J]` | `fz/track-J-signed-job-result-and-registration` | `crates/simon-node/src/lib.rs`<br>`crates/simon-cli/src/coord.rs` | **`STRESS-TESTS.md` Next #1 & #3:** Signs `JobResult` (`SIMON/JOB-RESULT/v1`, failures too) with node key; signs `RegisterMsg` (`SIMON/NODE-REGISTER/v1`) + `NodeVoucher` (`SIMON/NODE-VOUCH/v1`); adds Sybil flood tests. |
| **Stage 2 — Wave 2B**<br>*(Docs & Captain Fast-Gate)* | **Track G** | `[FZ-G]` | `fz/track-G-architecture-and-docs-overhaul` | `docs/ARCHITECTURE.md`<br>`docs/STRESS-TESTS.md`<br>`docs/THREAT-MODEL.md`<br>`ROADMAP.md`<br>`docs/whitepaper/SIMON-whitepaper-EN.md` | Creates `docs/ARCHITECTURE.md` in upstream repo, updates `docs/STRESS-TESTS.md` rows 7/17/18 and `## Honest limits`, and aligns `THREAT-MODEL.md` & `ROADMAP.md`. |
| **Stage 2 — Wave 2B**<br>*(Docs & Captain Fast-Gate)* | **Track I** | `[FZ-I]` | `fz/track-I-captain-cherry-pick-menu-and-ci` | `scripts/verify_all_fast.sh`<br>`docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md` | Adds `<30s` full-stack verification & Captain guardrail script (`scripts/verify_all_fast.sh`) and generates `docs/FZ-CONTRIB-CHERRY-PICK-GUIDE.md`. |
| **Stage 3 — Wave 3A**<br>*(Attack Harness & Gateway)* | **Track K** | `[FZ-K]` | `fz/track-K-vpn-attack-harness-and-agent-m1-gate` | `crates/simon-cli/src/agent.rs`<br>`crates/simon-cli/tests/vpn_attack_harness.rs` | **`STRESS-TESTS.md` Next #4:** Prepared VPN target network attack harness (`vpn_attack_harness.rs`) reproducing rows 1–7, 17, 18 + fixes `agent.rs` to reject Level 1 receipts missing token arrays. |
| **Stage 3 — Wave 3A**<br>*(Attack Harness & Gateway)* | **Track L** | `[FZ-L]` | `fz/track-L-gateway-and-monitor-hardening` | `tools/simon-api/simon_api.py`<br>`tools/simon-api/test_gateway.py`<br>`tools/simon-monitor/simon_monitor.py` | Enforces `1 MiB` HTTP body cap (`413`) and logs `signer_pinned` in `simon_api.py`; caps `fetch_stats` (`http/https`, 64 KiB) and tracks M1/pinned totals in `simon_monitor.py`; adds `--selfcheck` to both. |
| **Stage 3 — Wave 3B**<br>*(Industry Corpus & UI)* | **Track M** | `[FZ-M]` | `fz/track-M-industry-adversarial-corpus` | `tools/simon-industry/tickets.py`<br>`tools/simon-industry/agent_triage.py`<br>`tools/simon-industry/stress_corpus.json` | Brings `tickets.py` and `agent_triage.py` to 100% guardrail parity (`_znormalizuj` NFKC + `Cf` strip in `tickets.py`; `LINKS`/`ROLE`/`URGENT` in `agent_triage.py`) and expands `stress_corpus.json` from 17 to 25 cases. |
| **Stage 3 — Wave 3B**<br>*(Industry Corpus & UI)* | **Track N** | `[FZ-N]` | `fz/track-N-ui-receipts-and-demo-polish` | `ui/src/routes/receipts/+page.svelte`<br>`ui/src/routes/demo/+page.svelte` | Adds Level 0 / Level 1 / M3 / M7 claim-label reference table to `/receipts` and adds client-nonce replay tamper preset (`STRESS-TESTS.md` Row 4) + `aria-pressed` semantics to `/demo`. |
