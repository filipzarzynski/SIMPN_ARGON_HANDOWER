# 09 — Hackathon Judging Defense & Win-Optimization Strategy

**Target Hackathon:** [AMD Developer Hackathon: ACT III](https://lablab.ai/ai-hackathons/amd-developer-hackathon-act-iii)  
**Track:** Intelligent Industry  
**Submission URL:** [SIMON: Signed, Verifiable AI Tickets on AMD MI300X](https://lablab.ai/ai-hackathons/amd-developer-hackathon-act-iii/simon/simon-signed-verifiable-ai-tickets-on-amd-mi300x)  
**Live Demo:** [https://pop-os.tailaf1556.ts.net/simon/industry](https://pop-os.tailaf1556.ts.net/simon/industry)  
**Static Fallback Mirror:** [https://szpili.github.io/SIMON/industry](https://szpili.github.io/SIMON/industry)  
**Pitch Video (4:32):** [Narrated Video](https://storage.googleapis.com/lablab-video-submissions/submissions/doktsxdh39zj182lmvmqegwh/vd232o0bc2eo9n6clofkg4wd/video/video_aja6drcm87a9hplb08mh4qgu.mp4)  
**Slide Deck (PDF):** [10-Slide Pitch Deck](https://storage.googleapis.com/lablab-static-eu/submissions/doktsxdh39zj182lmvmqegwh/vd232o0bc2eo9n6clofkg4wd/presentation/presentation_pmx1mg25g1hhckk2gk4f8mob.pdf)  
**Codebase Base Commit:** [`8fbe206`](https://github.com/Szpili/SIMON/commit/8fbe2061d68909efb4e2a0c11cb16b0faed0d87e) (`upstream/main`, CI Green)

---

## 1. Executive Summary & Judging Phase Status

As of **Oct 17, 2026, 12:00 CEST**, the code freeze is in effect and judging is actively in progress.
Both Stage 1 (`PR #8`) and Stage 2 (`PR #9`) have been merged into `Szpili/SIMON:main`.
All 15 predeclared shop-floor run receipts are cryptographically verified in the browser via WebAssembly (`simon-verify-wasm`), the demo has zero external dependencies on GitHub Pages, and CI checks are 100% green.

To optimize the hackathon win probability during judging, the team must execute four key actions:
1. **Preserve Demo Uptime & Resilience**: Both Tailscale live funnel and GitHub Pages static mirror are healthy.
2. **Highlight the AMD Advantage**: Real measured MI300X benchmarks (192GB HBM3, native BF16, 64 concurrent streams) + live AMD Token Factory Cloud API bridge.
3. **Master the Defense FAQ**: Anticipate and decisively answer judge skepticism (TEE vs. Receipt boundary, M7 physics rule ceiling, replay defenses).
4. **Maintain Strict Code Freeze**: Zero disruptive commits to `main` while judges review.

---

## 2. AMD Hardware & Platform Showcase (Key Hackathon Differentiator)

Judges evaluate whether AMD is *deeply integrated into the core product* rather than cosmetically attached. SIMON demonstrates this at two distinct layers:

### 2.1 On-Premise / Cloud AMD Instinct MI300X (192 GB HBM3)
* **Execution Environment:** ROCm 7.2.3 + vLLM 0.27.1 on AMD Developer Cloud.
* **Why MI300X Matters for Industry:**
  - Running Gemma 4 26B-A4B or Qwen3.8-27B in **native unquantized BF16** requires ~54–60 GB of memory. On consumer hardware (e.g. 24 GB RTX 3090), the model must undergo aggressive 4-bit quantization (`q4_0` / QAT), sacrificing subtle reasoning on rare failure modes.
  - MI300X's 192 GB HBM3 memory allows running unquantized BF16 across **64 concurrent streams** without degradation, achieving a median latency of **1.64 s** (vs. 1.37 s on RTX 3090 INT4).
  - Pre-registered cross-vendor test (`docs/FP-PREREGISTRATION.md`): Audited 32 prompts on MI300X against RTX 3090. Identical audit trigger rates confirmed zero GPU vendor bias.

### 2.2 AMD Token Factory Integration (`tools/amd/tokenfactory_bridge.py`)
* **Endpoint:** `https://developer.amd.com.cn/radeon/api/v1` (Radeon Cloud / Token Factory)
* **Available Models:** 16 models including `Gemma-4-31B-IT`, `Qwen3.8-27B`, `DeepSeek-V4.1-Flash`, `GLM-5.3-Flash`.
* **Bridge Architecture:**
  - `tokenfactory_bridge.py` runs locally on `127.0.0.1:18460`, protects the shared API key in a `0600` file, strips recursive Gemma thinking tokens (`"enable_thinking": false`), enforces a `1 MiB` body limit, and proxies requests to Token Factory models with exponential backoff on 429 rate limits.
  - Allows plant operators to route peak burst inference to AMD cloud GPUs without changing any receipt verification logic.

---

## 3. Judge Q&A & Technical Defense Guide

### Q1: "Why not use Confidential Computing (AMD SEV-SNP / TEE) to prove execution?"
> **Defense:**
> "Confidential Computing provides execution proof, but requires specialized enterprise server CPUs, adds memory encryption overhead, and is unavailable on the diverse edge machines and consumer GPUs commonly deployed in industrial machining plants.
> 
> SIMON solves a different, urgent problem: **cryptographic non-repudiation and auditability inside a company VPN**. It proves *who* signed *which* advice for *which* sensor alarm with an Ed25519 signature, client nonce binding, and tokenizer commitment (M1). When combined with our deterministic physics rules ceiling (M7), the LLM is mathematically prevented from issuing unauthorized or out-of-spec actions, regardless of whether it ran on an edge GPU or a cloud cluster."

### Q2: "How does the safety gate work, and how was the 7/12 $\rightarrow$ 0/15 escape rate measured?"
> **Defense:**
> "In an industrial plant, an LLM must never decide whether a machine is at risk. That is governed by physical laws.
> 
> 1. **M7 Deterministic Ceiling:** `rules.py` computes physics checks (Heat Dissipation, Power Failure, Overstrain, Tool Wear) in **8 ms with 0 tokens**. If rules don't fire, the LLM is never called.
> 2. **Constrained Triage:** When a rule fires, the LLM drafts the ticket narrative and selects inspection steps strictly from the plant's pre-approved catalog by step ID (it cannot invent new steps).
> 3. **The Validator Lock:** Every draft is checked before publishing: fields, failure modes, and urgency must match the physics rules; any invented numbers, external links, or role markers immediately hold the ticket for human technician review.
> 4. **Empirical Result:** On our adversarial stress corpus of prompt injection and hallucination attacks, our initial keyword validator let 7 out of 12 unsafe drafts escape (58% failure). After adding Unicode normalization (NFKC + `Cf` invisible character stripping), strict catalog ID locks, and urgency pinning, **0 out of 15 unsafe drafts escaped (0% failure)**."

### Q3: "What stops a rogue or compromised node from signing falsified tickets?"
> **Defense:**
> "SIMON implements defense-in-depth across the network and application layers:
> 1. **Key Pinning (`--expect-signer`):** The gateway only accepts tickets signed by the designated node key for that plant machine.
> 2. **Client Nonce Replay Defense:** The client includes a 128-bit random nonce in the job order; the Level 1 receipt binds this nonce to the token chain. Replaying an old receipt with a different nonce fails WASM verification.
> 3. **Canary Drift Probes (M3 & `CANARY-7`):** Nodes periodically execute fixed canary prompts; statistical deviation in logprob distributions flags hardware bit flips or silent model substitutions.
> 4. **Signed Coordinator Registration (`SIMON/NODE-REGISTER/v1`) & Vouchers (`SIMON/NODE-VOUCH/v1`):** Nodes must prove possession of their key and present an operator voucher before receiving coordinator job assignments, preventing Sybil floods."

### Q4: "What does the browser WebAssembly verifier actually do?"
> **Defense:**
> "Our static demo mirror at `https://szpili.github.io/SIMON/industry` has **zero backend dependency**. The browser downloads the compiled `simon-verify-wasm` module (compiled from our core Rust crate), parses the raw JSON receipts, validates the Ed25519 digital signature against the node's public key, recalculates the SHA-256 output digest, and checks the Level 1 token commitments. If a single byte of the ticket text or node timestamp is altered, the browser UI marks it in red as invalid."

---

## 4. Live Demo & Mirror Health Protocol

The team and automated agents should monitor demo availability using this verification script:

```bash
# Test Tailscale Live Funnel
curl -sI --max-time 8 https://pop-os.tailaf1556.ts.net/simon/industry | head -n 1

# Test GitHub Pages Static Mirror (Zero-Dependency Fallback)
curl -sI --max-time 8 https://szpili.github.io/SIMON/industry | head -n 1

# Verify all 15 industry run receipts in WASM
node ui/scripts/check-receipts.mjs
```

Both endpoints currently return `HTTP/2 200 OK`. If the Tailscale machine undergoes maintenance or reboots, the GitHub Pages static mirror guarantees judges can review and verify all receipts without disruption.

---

## 5. Post-Hackathon Roadmap (Post-Judging Execution)

Once judging concludes, the following items are pre-staged for immediate execution on isolated branches:
1. **Codebase-Wide PL $\rightarrow$ EN Unification (`feature/language-cleanup`):**
   - Refactor internal Polish identifiers (`zweryfikuj_m1`, `Zezwolenie`, `Sufit`, `odcisk_wyjscia`) to clean English equivalents without breaking external JSON wire compatibility.
2. **External Tester VPN Attack Harness (`feature/stage3-vpn-harness`):**
   - Implement `crates/simon-cli/tests/vpn_attack_harness.rs` (`docs/STRESS-TESTS.md` Next #4) testing connected nodes against rows 1–7, 17, 18 of the threat matrix.
3. **Persistent Agent Process Pool:**
   - Replace the per-request `simon --role agent` subprocess with an in-memory Tokio client connection pool to eliminate the ~14 ms local handshake overhead.
