# Agent Task Specification: Track G (Stage 2) — Architecture & Documentation Overhaul (`PR-7`)

**Stage:** Stage 2 (Run AFTER Stage 1 Tracks A–F are integrated into `fz-contrib`)
**Target Base Branch:** `fz-contrib` (NEVER `main`)
**Dedicated Track Branch:** `fz/track-G-architecture-and-docs-overhaul`
**Assigned Role:** Principal Systems Architect & Technical Writer (Gemini 3.8 Flash High)
**Prerequisite Reading:** [`../AGENT_RULES_COMMON.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/parallel_agents/AGENT_RULES_COMMON.md), [`../../01_ARCHITECTURE_AND_DATA_FLOWS.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/01_ARCHITECTURE_AND_DATA_FLOWS.md), [`../../04_CLAIMS_VS_REALITY_MATRIX.md`](file:///home/agent/SIMPN_ARGON_HANDOWER/04_CLAIMS_VS_REALITY_MATRIX.md)

---

## 1. Objective

Deliver a clean, self-contained documentation and architectural clarity upgrade on top of `fz-contrib` so judges and developers inspecting the repo have an authoritative, honest, diagrammed architectural guide:
1. **Create `docs/ARCHITECTURE.md` (`[FZ-G1]`)**:
   - End-to-end Mermaid architecture and sequence diagrams for:
     - **Track 1 Intelligent Industry Pipeline**: UCI AI4I 2020 Milling (`10,000` rows) $\rightarrow$ `rules.py` (`8 ms`, 0 tokens) $\rightarrow$ Multi-turn Gemma 4 26B-A4B M7 Agent on RTX 3090 (`61.8 tok/s`) / AMD Instinct MI300X (`199.1 tok/s`) $\rightarrow$ `SIMON-RECEIPT-v1` (M0 + M1) $\rightarrow$ Nightly `CANARY-7` verification.
     - **Cryptographic Verification Hierarchy**: M0 (`SIMON-RECEIPT-v1` Ed25519 + BLAKE3), M1 (`SIMON-M1-TOKEN-v1` / `SIMON-M1-ROOT-v1` per-token binding), M3 (cross-hardware FP drift telemetry), M12 (`KL + Top-5 Jaccard`), LIDAR (`onetoken.py`), and `CANARY-7`.
     - **P2P Transport & Coordinator**: `simon agent` $\leftrightarrow$ `simon node` and `AcpServer` (`simon coord`) $\leftrightarrow$ `SimonNode`.
2. **Align `docs/THREAT-MODEL.md`, `ROADMAP.md`, and `docs/whitepaper/SIMON-whitepaper-EN.md` (`[FZ-G2]`)**:
   - Explicitly document what cryptographic receipts prove (**non-repudiation and tamper-evidence** of the signed `{prompt, config, weights_hash, token_commitments, output}` tuple) versus what active behavioral probing (`M12`, `LIDAR`, `CANARY-7`) catches (**silent model substitution, quantization downgrade, and cloud endpoint regression**).
   - Update milestone statuses (`M14` MI300X completed, `M1` live token commitments wired, `M7` industry tool-calling agent wired).

---

## 2. Permitted Files (Strict Scope)

You may **ONLY** modify or create:
- `docs/ARCHITECTURE.md`
- `docs/THREAT-MODEL.md`
- `ROADMAP.md`
- `docs/whitepaper/SIMON-whitepaper-EN.md`

---

## 3. Granular Commit Plan (Cherry-Pickable by Team Captain)

1. `[FZ-G1] docs(arch): add comprehensive docs/ARCHITECTURE.md with Mermaid data flows and verification hierarchy`
2. `[FZ-G2] docs(threat-model,roadmap): align threat boundaries and M1/M14 milestone status with codebase`

---

## 4. Verification & PR Delivery

```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh G --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track G
```
