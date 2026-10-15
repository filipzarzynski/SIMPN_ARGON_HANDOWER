# 00 — Executive Assessment, Independent Thesis Critique & Hackathon Viability

**Repository Audited:** `https://github.com/Szpili/SIMON` (`/home/agent/SIMON`, commit `e55ca11`)  
**Target Event:** [AMD Developer Hackathon: ACT III](https://lablab.ai/ai-hackathons/amd-developer-hackathon-act-iii) (Oct 12–18, 2026)  
**Audit Date:** 2026-10-15

---

## 1. Independent Assessment of the Core Idea (Addressing Your Skepticism Objectively)

You raised four specific doubts about SIMON's premise:
1. *Will people actually route inference to untrusted P2P nodes on a dynamic spot market vs. trusted cloud / own hardware?*
2. *Can you actually stop dishonest nodes from substituting cheaper/quantized models or tampering with outputs?*
3. *Isn't assuming data confidentiality is "not an issue" fatal for real users?*
4. *In agentic workloads with large contexts and heavy tool use, doesn't the network/verification overhead kill the value proposition?*

Here is the grounded, independent technical verdict on each point—neither sugarcoating the flaws nor dismissing what actually works:

### 1.1 The Open P2P Untrusted Inference Market Thesis: **Your Skepticism Is 90% Valid**
* **Why open P2P untrusted inference fails for serious workloads:**
  1. **Zero Data Confidentiality:** Without hardware TEEs (e.g., AMD SEV-SNP + NVIDIA H100/B200 Confidential Computing or MI300X confidential VMs), the node operator sees the raw plaintext prompt, system instructions, proprietary code/data, and generated tokens. No enterprise will send proprietary agent contexts or customer data to an anonymous home GPU on a P2P network. (`docs/THREAT-MODEL.md:107` explicitly admits confidentiality is out of scope).
  2. **The Verification Paradox (Empirically Proven by SIMON's Own Author!):** If you don't trust the node, how do you verify it ran `Gemma-4-26B-BF16` and not a distilled `3B-Q4` model?
     * **Cryptographic Proofs (ZKML):** 1,000×–10,000× overhead—impossible for live LLMs.
     * **Activation Hashing (TopLoc, arXiv:2501.16007):** Requires deterministic teacher-forced activation comparison. In SIMON, TopLoc was never implemented (`activation_hash` is hardcoded to `"toploc:NIE_POLICZONY"` at `crates/simon-cli/src/node.rs:733`).
     * **Teacher-Forced Logprob Auditing (M3):** The author built M3 (`crates/simon-core/src/m3.rs`) and ran a pre-registered false-positive experiment (`docs/FP-PREREGISTRATION.md`, `docs/FP-RESULT.md`). **It failed:** even the *exact same RTX 3090 GPU* checking its own greedy output flagged **5/32 prompts** because batching/KV-cache (`cache_prompt=true` vs `false`) shifted floating-point reduction order enough to flip near-tie tokens (`margin < 0.05`). Legitimate `q4_0` KV-cache quantization flagged **26/32 prompts**. Because of this, the author had to disable slashing (`m3::decyzja` at `crates/simon-core/src/m3.rs:233-249` never returns `HardFail`).
  3. **High-Context Agentic Workloads & KV-Cache Gravity:**
     * In multi-turn agentic loops (e.g., 30k–100k token contexts with 20 tool calls), **KV-cache state is everything**. If a single node keeps your prefix in VRAM, each subsequent tool-call turn only prefills the new ~500 tokens (taking ~100 ms).
     * If you route each turn across a dynamic P2P market of untrusted nodes, or split a job across nodes, you lose prefix KV-cache locality and must re-transmit and re-prefill 50,000+ tokens over WAN on every turn.
     * In fact, SIMON's own AMD MI300X benchmarks (`docs/AMD-MI300X-RESULTS.md:55-96`) proved that splitting a 14B dense model across WAN is **12× slower** (`4.1` vs `48.2 tok/s`) and offloading MoE experts across WAN is **43×–55× slower** (`2.9` vs `125.1 tok/s`).

### 1.2 Where You Should NOT Dismiss the Project: **What Actually Has Real Value**
If you strip away the "Web3 / open P2P crypto-market (`THINK` token)" fantasy—which the author himself largely abandoned in October after proving in `docs/WASH-COMPUTE.md` that fixed-pie token issuance is vulnerable to wash-compute—three genuinely valuable engineering ideas remain:

1. **Multi-Rig Federated Routing Across Semi-Trusted / Hybrid Infrastructure (Local Edge + Cloud Burst):**
   * An industrial plant, hospital, or dev shop often has **local edge GPUs** (e.g., an on-prem RTX 3090 running quantized models for low-cost routine alerts) and **rented cloud burst GPUs** (e.g., an AMD Instinct MI300X 192GB HBM3 droplet on DigitalOcean/RunPod/Vast.ai for heavy BF16 reasoning or concurrent spikes).
   * Using libp2p (`Noise` + `Yamux` + `Ed25519` peer identities) as a zero-config encrypted mesh between an edge rig behind NAT and a cloud GPU—without setting up VPNs, TLS certificates, or API gateways—is genuinely practical.
2. **Cryptographic Non-Repudiation & Audit Trails for Regulated AI Pipelines (Proof Level 0 + Level 1):**
   * Even if a receipt doesn't prove *which matrix multiplications happened in silicon*, a domain-separated Ed25519 signature over `(job_id, model_hash, output_digest)` (`crates/simon-core/src/receipt.rs:135-141`) + client-signed timing observation (`crates/simon-core/src/obserwacja.rs`) creates a **tamper-evident chain of custody**.
   * In industrial maintenance (Track 1) or enterprise compliance, being able to prove *"Ticket #12 was generated by Node `10391fe9` (AMD MI300X) at timestamp $T$, its JSON output was not modified in transit, and Operator key `X` signed single-use capability grant `Zezwolenie` before the PLC/ERP executed `schedule_replacement`"* is a **real, defensible product feature**.
3. **Confinement of Untrusted Model Outputs (`M7`: `cap.rs` + `przeplyw.rs`):**
   * Treating the LLM output as untrusted (`Zaufanie::ModelDerived`) and enforcing a deterministic capability ceiling (`crates/simon-core/src/cap.rs`) + single-use parameter-bound operator grants (`Zezwolenie`) before any side-effecting tool executes is clean, sound security engineering.

---

## 2. Idea vs. Codebase Reality: The Brutal Truth

When we audited every line of code against the documentation, we uncovered a fascinating duality:

### 2.1 The Author's Scientific Honesty Is Extraordinary
Unlike 99% of hackathon/AI repos that hide broken experiments behind marketing hype, the main author (`Szpili`) documented every failed hypothesis in detail:
* When M3 failed its pre-registered false-positive test (`5/32` self-fail), he published `docs/FP-RESULT.md`, disabled `HardFail` in `crates/simon-core/src/m3.rs:233-249`, and rewrote `README.md` and `docs/WHAT-AND-WHY.md` to state upfront: *"SIMON does not prove which weights a remote node executed."*
* When he discovered on Sept 17 that `output_digest` didn't actually hash the output text and `gen_ms` was hardcoded to `65.0 tok/s`, he documented it in `docs/SECURITY-LOG.en.md` and wrote regression detectors (`crates/simon-core/src/pomiar.rs` and `scripts/wartownik_stalych.py`).
* When he analyzed his own whitepaper's tokenomics, he wrote `docs/WASH-COMPUTE.md` proving mathematically that a node-client coalition can farm tokens profitably whenever external demand is low.

### 2.2 However, the Codebase Has Major Structural Gaps & "Two Disconnected Worlds"

| Area | What the Architecture Suggests | What the Code Actually Does |
| :--- | :--- | :--- |
| **Network Flow** | Client publishes `JobOrder` to Gossipsub $\rightarrow$ Coordinator verifies `Autoryzacja` & VRF-assigns node $\rightarrow$ Node executes & publishes `OrderCompleted`. | **Two unbridged worlds:** `agent.rs` builds `JobOrder` + `Autoryzacja`, verifies its own signature (`agent.rs:490`), **throws `JobOrder` away**, and dials the Node directly via `/simon/prompt/1`. Meanwhile `coord.rs` listens on Gossipsub, emits `OrderAccepted` with hardcoded `"vrf-mvp"`, and **never assigns or forwards jobs to any node**. |
| **Live Receipt Proof Level** | Level 0 (Signature) and Level 1 (`WiazaniaM1`: token chain, prompt digest, tokenizer hash, sampling commitment). | **Every live receipt from `simon --role node` is Proof Level 0.** `node.rs:731-744` hardcodes `wiazania: None`, `activation_hash: "toploc:NIE_POLICZONY"`, `precision: Precision::Fp16`, and sets `started_at_us == finished_at_us` (`0 µs` duration!). Level 1 (`WiazaniaM1`) only exists in synthetic offline fixtures (`examples/gen_m1.rs`). |
| **Model Hash & Attestation** | Nodes are matched by cryptographic model hash and only `attested` capabilities are used for assignment (`RULES #2` in `simon-node/src/lib.rs:29`). | **Zero file hashing & self-attestation:** `node.rs:501-539` never hashes any GGUF/safetensors file; it queries `GET /v1/models` on the local HTTP server (or falls back to the `--model-hash` CLI string!). Worse, `node.rs:120` fills in its own `attested: Some(...)` field in an unsigned `RegisterMsg`, and `Registry::kandydaci_dla_modelu` (`simon-node/src/lib.rs:153`) reads `declared` instead of `attested`! |
| **Client Node Identity Verification** | Client verifies receipt was signed by the expected registered node (`verify_for_node`). | `agent.rs:738` and `simon-verify-wasm/src/lib.rs:84` only call `r.verify_self()`—accepting **any** self-signed Ed25519 keypair in `r.signer` without checking it against the dialed peer or registry! |
| **WASM M1 Verification** | Browser verifies Level 1 receipt signature and token commitments. | **Bug:** `Receipt::zweryfikuj_m1` (`receipt.rs:299-330`) and `simon_verify_wasm::weryfikuj_m1` (`lib.rs:132-174`) **never call `verify_self()`**—an unsigned or invalidly signed receipt passes M1 verification! |
| **UI (`/demo`, `/industry`)** | Interactive verification explorer and industrial maintenance pipeline. | Cryptographic verification in browser is **100% real Rust WASM**, but data in `/demo` and `/industry` is **100% static JSON snapshots**. On `/demo`, the default Level 1 (M1+M3) tab uses synthetic dummy tokens (`[100..139]`, `"DEMO OUTPUT"`). On `/industry`, all 15 receipts from RTX 3090 (`Q4_0`) and MI300X (`BF16`) claim `"precision": "fp16"` and `0 µs` duration. |

---

## 3. Hackathon Market Viability Analysis (AMD Developer Hackathon: ACT III)

### 3.1 What the Hackathon Judges & Sponsors Actually Care About
From the official [AMD Developer Hackathon: ACT III page](https://lablab.ai/ai-hackathons/amd-developer-hackathon-act-iii):
* **Core Mandate:** *"Each track challenges your team to solve a real business problem and show a working product."*
* **Tracks:**
  1. **Track 1: Intelligent Industry (by Vibe Generation):** Predict equipment failures, explain anomalies, recommend maintenance actions, and show a working product on realistic industrial data.
  2. **Track 2: Health and Wellbeing**
  3. **Track 3: Reinvent Commerce**
  4. **Track 4: Create a New Kind of Experience**
  5. **Partner Challenge: Evolus Business Agents on AMD (€1,011.50 prize)**
* **Cash & Hardware Prizes:**
  * **$5,000 Best Solution Built on AMD:** Mandatory AMD technology usage (MI300X / ROCm / Ryzen AI).
  * **$5,000 Best Product Built with Google's Gemma Models:** *"Build with Google DeepMind's Gemma family of open models running on AMD GPUs with ROCm. Show what open models on open hardware can do when you put them to work on a real problem."*
  * **Vibe Generation Special Prize (AirPods 5 for team):** Judged by Hybrid, Becreatives, and Vibe Generation on Track 1.
* **Judging Criteria:**
  1. Technology & Autonomous Behavior
  2. Use Case & Business Impact
  3. Presentation & Demo
  4. Use of Sponsor Technologies (AMD ROCm/MI300X + Google Gemma)

### 3.2 How SIMON Currently Scores Against This Rubric
In `ROADMAP.md:72-74` (written Sept 18), the author wrote: *"Tracks are announced Oct 12 — if it doesn't fit, we rewrite the description for the track, not the project for the track."*
On Oct 15 (today!), the author executed that exact pivot (`commits 86e9774..e55ca11`), adding `tools/simon-industry/` + `/industry` UI route using **Gemma 4 26B-A4B** on **RTX 3090 + AMD Instinct MI300X (ROCm 7.2, vLLM 0.27.1)** over the UCI AI4I 2020 milling-machine dataset.

**Strengths for the Hackathon (Why SIMON Can Actually Contend for Prizes):**
1. **Triple Prize Eligibility ($5k AMD + $5k Google Gemma + Vibe Generation Track 1):**
   * Most hackathon teams only run a cloud API or a toy local model. SIMON has **real, verifiable empirical runs on an AMD Instinct MI300X (192 GB HBM3, ROCm 7.2)** running **Google's brand-new Gemma 4 26B-A4B (`gemma-4-26b-a4b-it-bf16`)** alongside an on-prem RTX 3090 (`gemma-4-26b-a4b-it-qat-q4_0`).
2. **Real Systems Engineering Depth:**
   * A multi-crate Rust workspace (`simon-core`, `simon-node`, `simon-harness`, `simon-cli`, `simon-verify-wasm`), real libp2p networking, real in-browser Rust WASM Ed25519 verification, and rigorous MI300X throughput/overhead benchmarks (`1,998.8 tok/s` at `c=64`, `~14 ms` receipt overhead across 510 jobs). Technical judges love real Rust + ROCm data over generic LangChain wrappers.

**Weaknesses / Vulnerabilities That Could Cost the Team the Win (What We Must Fix):**
1. **The "Intelligent Industry" Layer Currently Feels Thin & Static:**
   * Right now, `tools/simon-industry/` is 267 lines of Python (`rules.py` + `tickets.py`), and `/industry` in the UI only displays a static 18-event JSON file (`industry-run.json`) with no interactive "Run Live Triage / Tamper Test / Approve Maintenance Action" controls.
   * Furthermore, the signed receipts inside `industry-run.json` have embarrassing metadata bugs: the RTX 3090 (`Q4_0` on `llama.cpp`) claims `"runtime": "nieznany/1"` and `"precision": "fp16"`, the MI300X (`BF16`) claims `"precision": "fp16"`, and every receipt has `started_at_us == finished_at_us` (`0 µs` duration).
2. **M7 (`cap.rs` / `Zezwolenie`) Is Not Connected to `simon-industry`!**
   * SIMON already has a killer feature in `crates/simon-core/src/cap.rs`: cryptographic capability ceilings (`Sufit`) and single-use operator grants (`Zezwolenie`) for high-consequence actions!
   * Yet `tools/simon-industry/tickets.py` checks a 4-line Python set (`ACTION_WHITELIST`) instead of using `simon-core`'s `cap::waliduj` and `Zezwolenie`! Connecting `simon-industry` to `simon-core::cap` (and exposing `Zezwolenie` signing/verification in WASM on the `/industry` page) instantly unifies the "Intelligent Industry" story with SIMON's core security architecture!
3. **Lack of True "Autonomous Behavior" (Criterion #1):**
   * Currently, `tickets.py` makes a single one-shot prompt to Gemma 4 per failed sensor row. Adding a multi-step **Autonomous Industrial Triage Agent** mode (using SIMON's already-implemented `--request-file` Chat + Tool-Calling support in `node.rs`/`agent.rs`!) where Gemma 4 queries historical sensor trends, checks spare-part inventory, proposes a tool call, and gets gated by `simon-core::cap::Sufit` + `Zezwolenie` directly hits Judging Criterion #1 (*Technology & Autonomous Behavior*).

---

## 4. How You Can Be the MVP Addition to the Team (Without Being a "Party Pooper")

You don't need to tell your friends *"your P2P inference market thesis is flawed."* Instead, you can frame your contribution constructively:
> *"The author already pivoted the narrative from open P2P verification to signed audit trails + hybrid edge/MI300X routing for Intelligent Industry. Right now the core Rust crypto and MI300X benchmarks are super solid, but the Industry vertical and live receipt metadata have a few gaps that judges will spot. I can wire SIMON's Rust capability grants (`M7`) + live M1 token bindings directly into the Gemma 4 Industry pipeline and make the `/industry` UI interactive."*

See [`05_HACKATHON_ROADMAP_AND_PR_CATALOG.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/05_HACKATHON_ROADMAP_AND_PR_CATALOG.md) and [`parallel_agents/ORCHESTRATOR_GUIDE.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/ORCHESTRATOR_GUIDE.md) for the exact PR branches and parallel agent task specifications.
