# 01 — Architecture Overview & Data Flows

This document maps the **actual implemented architecture** of SIMON (`https://github.com/Szpili/SIMON`, baseline `1d71e6d` after Stage 1 merge & Captain review) as verified directly from the source code, separating what runs live in production from what exists as offline verifiers, Gossipsub coordination, or Stage 2/3 queued work (for the Stage 2/3 wave-annotated team brief, see [`08_TEAM_SYNC_ARCHITECTURE_AND_WAVE_BRIEF.md`](./08_TEAM_SYNC_ARCHITECTURE_AND_WAVE_BRIEF.md)).

---

## 1. High-Level Repository Topology

```mermaid
flowchart TB
    subgraph UI_Layer["Presentation & Verification Layer"]
        SvelteUI["ui/ (SvelteKit Static App) - Routes: /, /demo, /network, /industry, /receipts"]
        WASM["crates/simon-verify-wasm - In-browser Ed25519 + M1 + M3 verifier"]
        Streamlit["demo/app.en.py - Interactive Streamlit CLI wrapper"]
    end

    subgraph Gateway_Tools["Python Gateways, Industry & Probing Tools (tools/)"]
        Industry["tools/simon-industry/ - rules.py + tickets.py + agent_triage.py + export_ui.py"]
        API["tools/simon-api/simon_api.py - OpenAI HTTP Gateway (:18600)"]
        Monitor["tools/simon-monitor/simon_monitor.py - GPU & Job Telemetry (:8081)"]
        Verifier["tools/simon-verifier/ - verifier_loop.py + fp_matrix.py"]
        Lidar["tools/simon-lidar/ - lidar.py + onetoken.py"]
        Canary["tools/simon-canary/ - simon_canary.py (CANARY-7)"]
        Guard["tools/simon-guard/ - guard_small.py + pii_pl.py (:19301)"]
    end

    subgraph Rust_Workspace["Rust Workspace (crates/)"]
        CLI["crates/simon-cli (bin: simon) - Roles: agent, node, coord | Subcommands: verify, audyt, guard"]
        Harness["crates/simon-harness - request_response, client_protocol, acp_server, transport"]
        NodeReg["crates/simon-node - In-memory Registry, VRF candidate selection & Capability"]
        Core["crates/simon-core - crypto, receipt, m3, cap, przeplyw, limity, web, obserwacja, rejestr, tozsamosc"]
    end

    subgraph Hardware_Backends["LLM Inference Backends"]
        RTX3090["Local Node: RTX 3090 - llama-server / vLLM (gemma-4-26b-a4b-it-qat-q4_0)"]
        MI300X["Cloud Node: AMD Instinct MI300X (192GB) - ROCm 7.2 + vLLM 0.27.1 (gemma-4-26b-a4b-it-bf16)"]
    end

    SvelteUI --> WASM
    WASM --> Core
    SvelteUI -. "Polls /api/monitor" .-> Monitor
    Industry -- "POST /v1/chat/completions" --> API
    API -- "spawns subprocess" --> CLI
    Streamlit -- "spawns subprocess" --> CLI
    CLI --> Harness
    CLI --> NodeReg
    CLI --> Core
    CLI -- "HTTP /v1/chat/completions" --> RTX3090
    CLI -- "SSH Tunnel + libp2p /simon/prompt/1.0.0" --> MI300X
```

---

## 2. Critical Discovery: The "Two Disconnected Worlds" in the Network Layer

Reading `crates/simon-harness` alongside `crates/simon-cli` reveals that **two separate network protocols exist in the repo, and the live inference path does not route through the Gossipsub coordinator**:

### Flow A: The Actual Live Point-to-Point Flow (`agent.rs` $\leftrightarrow$ `node.rs`)
Used by `simon --role agent`, `simon-api`, `simon-industry`, and `demo/app.en.py`.
* **Bypasses Gossipsub and Coordinator completely.**
* Requires the client (`agent.rs`) to already know the exact Multiaddr and `PeerId` of the target worker node (`--bootstrap /ip4/.../tcp/9001/p2p/<peer_id>`).

```mermaid
sequenceDiagram
    autonumber
    participant Py as simon_api.py / tickets.py
    participant Agent as simon --role agent (agent.rs)
    participant Node as simon --role node (node.rs)
    participant LLM as vLLM / llama-server (:18020 / :8000)

    Py->>Agent: Spawn subprocess with --request-file - (stdin JSON) & --expect-signer
    Note over Agent: Loads ~/.simon/api-client.id (0600, tozsamosc.rs), builds JobOrder with fresh nonce & signs Autoryzacja (never published to Gossipsub)
    Agent->>Node: Dial --bootstrap Multiaddr (TCP+Noise+Yamux) & send PromptRequest over CBOR /simon/prompt/1.0.0
    Note over Node: Checks 4096-entry (peer, job_id) replay ring & --rate-per-peer token bucket, then acquires przyjecia (max_jobs*4) & sloty (max_jobs) semaphores
    Node->>LLM: Startup /props & /v1/models probe + POST /tokenize (Context gate C+1: ctx <= b.max_ctx)
    Node->>LLM: POST /v1/chat/completions (messages, tools, temp, max_tokens - no logprobs)
    LLM-->>Node: HTTP 200 JSON (choices[0].message, usage)
    Note over Node: zbuduj_podpisany_receipt: output_digest = SHA256(SIMON/OUTPUT/v1), real started/finished_at_us, whole-token Precision (or Unknown), wiazania = None (Level 0 - wired in Stage 2 Track H), Ed25519 sign
    Node-->>Agent: PromptReply::Ok(PromptResponse { output, receipt, ... })
    Note over Agent: zweryfikuj_receipt: r.verify_self() + podpisal_oczekiwany(--expect-signer) + r.job_id & r.model_hash + r.zgodny_z_wyjsciem(output) + zweryfikuj_m1(order.nonce) -> poziom_sprawdzony
    Agent-->>Py: Prints JSON line to stdout (receipt_zweryfikowany: true, poziom_dowodu, signer_pinned)
```

### Flow B: The Gossipsub + Coordinator Flow (`acp_server.rs` & `coord.rs`)
Exists in `crates/simon-harness/src/client_protocol.rs`, `acp_server.rs`, and `crates/simon-cli/src/coord.rs`. Stage 1 (`Track E` + Captain commit `c1f8ef9`) wired `wybierz_kandydata_vrf`, `assign`, `complete_job`, and `TOPIC_JOB_RESULT` handling in `coord.rs`, while `JobResult` signing and `RegisterMsg` signing/vouching are queued for Stage 2 (`Track J`):

```mermaid
sequenceDiagram
    autonumber
    participant ACP as AcpServer (acp_server.rs)
    participant Gossip as libp2p Gossipsub (simon/v1/*)
    participant Coord as simon --role coord (coord.rs)
    participant Node as simon --role node (node.rs)

    Node->>Gossip: At startup + every 30s: Publish unsigned RegisterMsg to simon/v1/node-register
    Note over Node,Coord: Stage 1 limit: RegisterMsg is unsigned (Stage 2 Track J adds SIMON/NODE-REGISTER/v1 + NodeVoucher)
    Gossip->>Coord: Receives RegisterMsg -> rejestr.register(msg)
    ACP->>Gossip: Publish JobOrder to simon/v1/job-order
    Gossip->>Coord: Receives JobOrder -> obsluz_zlecenie (coord.rs)
    Note over Coord: Verifies order.zweryfikuj_autoryzacje(teraz), selects node via wybierz_kandydata_vrf(model, vrf_seed), calls rejestr.assign(job_id, node_id), and signs OrderAccepted
    Coord->>Gossip: Publish OrderAccepted to simon/v1/order-accepted
    Node->>Gossip: Publish JobResult to simon/v1/job-result after execution
    Gossip->>Coord: Receives JobResult -> obsluz_wynik (coord.rs)
    Note over Coord: Verifies assigned_node == Some(node_id), marks degraded + complete_job on failure, or verifies Receipt & complete_job on ok=true (Stage 2 Track J signs JobResult failures too)
```

---

## 3. Cryptographic Data Structures & Domain Separation Flow

Every hash in `crates/simon-core` is computed via `content_digest<T>(&value)` (`crates/simon-core/src/lib.rs`), which runs `serde_json::to_string(value)`, hashes the UTF-8 bytes with SHA-256, and returns a 64-character lowercase hex string. Ed25519 signatures (`crates/simon-core/src/crypto.rs`) sign the **64-byte ASCII hex string** of the digest.

```mermaid
flowchart LR
    subgraph Level0["Proof Level 0 (Live in node.rs)"]
        Out["(job_id, output)"] -->|"DOMENA: SIMON/OUTPUT/v1"| OutDig["output_digest (64-hex)"]
        OutDig --> Rec["Receipt struct (signature: None)"]
        Meta["job_id, node_id, model_hash, runtime, precision, activation_hash, tokens, timestamps_us, signer"] --> Rec
        Rec -->|"DOMENA: SIMON/RECEIPT/v1"| RecDig["Receipt::digest() (64-hex)"]
        RecDig -->|"Ed25519 sign(digest.as_bytes())"| Sig["Receipt.signature + --expect-signer key pinning"]
    end

    subgraph Level1["Proof Level 1 — WiazaniaM1 (Verified in Core/WASM; Live Node Wiring in Stage 2 Track H)"]
        TokBytes["tokenizer.json bytes"] -->|"SHA256(SIMON/TOKENIZER/v1 || 0x00 || bytes)"| TokHash["tokenizer_hash"]
        TokHash & Nonce["client_nonce (from order.nonce)"] & PIds["prompt_token_ids: &[u32]"] -->|"DOMENA: SIMON/PROMPT/v1"| PDig["prompt_digest"]
        PDig & OIds["output_token_ids: &[u32]"] -->|"DOMENA: SIMON/CHAIN/v1"| Chain["output_token_chain"]
        Samp["Sampling params (int scaled)"] -->|"DOMENA: SIMON/SAMPLING/v1"| SHash["sampling_params_hash"]
        Chain & SHash --> Wiaz["WiazaniaM1 struct (included in Receipt before signing)"]
        Wiaz -.-> Rec
    end

    subgraph M7_Confinement["M7 Authority Confinement (cap.rs & przeplyw.rs)"]
        Tool["(akcja, parametry)"] -->|"DOMENA: SIMON/GRANT-PARAMS/v1"| ParamDig["parametry_digest"]
        ParamDig --> Zez["Zezwolenie (Operator Grant): id, akcja, parametry_digest, wystawca, wazne_do_us"]
        Zez -->|"DOMENA: SIMON/GRANT/v1 + Ed25519 sign"| ZezSig["Single-use capability check: cap::sprawdz(sufit, zezwolenie, ...)"]
    end
```

---

## 4. Intelligent Industry (Hackathon Track 1) Data Flow

Implemented in `tools/simon-industry/` (`rules.py`, `tickets.py`, `agent_triage.py`, `export_ui.py`) + `ui/src/routes/industry/+page.svelte`:

```mermaid
flowchart LR
    CSV["UCI AI4I 2020 Dataset: data/ai4i2020.csv (10,000 rows)"] --> Sample["tickets.py:sample() - 18 stratified rows (15 rule hits + 3 RNF misses)"]
    Sample --> Rules["rules.py:findings() - Deterministic physics rules: HDF, PWF, OSF, TWF + CHECKS catalog"]
    Rules -->|"No rule fired (3 rows)"| Skip["No LLM Call - No ticket issued (recorded as rules miss)"]
    Rules -->|"1+ rules fired (15 rows)"| Prompt["tickets.py:prompt() & agent_triage.py - Cleaned CSV IDs + derived W/Nm/K + rules"]
    Prompt -->|"Round-robin model selection"| API["simon_api.py (:18600) - POST /v1/chat/completions (--expect-signer)"]
    API -->|"gemma-4-26b-a4b-it-qat-q4_0"| N3090["Node 1: Local RTX 3090 (llama.cpp)"]
    API -->|"gemma-4-26b-a4b-it-bf16"| NMI300X["Node 2: AMD Instinct MI300X (ROCm 7.2 + vLLM 0.27.1)"]
    N3090 & NMI300X -->|"Signed Receipt + JSON Ticket / Tool Proposal"| Check["tickets.py:check() & agent_triage.py M7 Ceiling - Checks from rules.CHECKS catalog, evidence from rules, NFKC/Cf & 17-case stress_corpus.json"]
    Check --> Export["export_ui.py - Writes ui/src/lib/industry-run.json"]
    Export --> Browser["/industry SvelteKit Page - Runs simon-verify-wasm in browser + shows plant-listed node vs unknown node"]
```

---

## 5. Key Architectural Bottlenecks & Design Decisions

1. **Process-per-Request Overhead in `simon_api.py` (`tools/simon-api/simon_api.py`):**
   * For every HTTP `/v1/chat/completions` request, `simon_api.py` spawns a fresh OS process `simon --role agent ...`, which initializes a Tokio runtime, generates a libp2p Swarm, performs a fresh TCP + Noise + Yamux handshake to the node, sends one CBOR request, verifies the receipt (and `--expect-signer` when `node_id` is in `nodes.json`), and exits.
   * On localhost (`docs/AMD-MI300X-RESULTS.md`), this only adds **~14 ms** of median latency (`3.93s` vs `3.92s`), because Rust startup + loopback TCP/Noise handshake is fast. Over WAN (`~124 ms` RTT to MI300X), the extra TCP+Noise handshake adds ~2–3 RTTs per request.
2. **Whole-Job Buffering vs. Token Streaming (`crates/simon-cli/src/node.rs`):**
   * Because a node cannot sign `output_digest` until the entire output string `output` is known, `node.rs` calls `/v1/chat/completions` with non-streaming JSON, waits for completion, signs the receipt, and sends a single `PromptResponse` over libp2p.
   * Consequently, `simon_api.py:_stream` sends `: simon job running` SSE keepalive comments every 5s while waiting, and then emits the response + receipt in one burst at the end ("streaming after the fact").
3. **Why Map-Reduce (`mapreduce.rs`) Works While Model Sharding Failed:**
   * Splitting model layers (pipeline parallelism) or MoE experts across WAN requires tens of synchronization barriers *per generated token* (measured 12× to 55× slowdown in `docs/AMD-MI300X-RESULTS.md`).
   * By contrast, `crates/simon-cli/src/mapreduce.rs` and `agent.rs` keep whole models on each node and split **long input documents** into UTF-8 safe chunks with automatic context-limit halving (`wyslij_kawalek_z_retry` on `ctx_ponad_limit`), producing an independent signed receipt for every Map and Reduce step.
