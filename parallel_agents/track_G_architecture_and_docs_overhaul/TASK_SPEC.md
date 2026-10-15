# Agent Task Specification: Track G (Stage 2) — Architecture & Documentation Overhaul (`[FZ-G]`)

**Stage:** Stage 2 (Run AFTER Stage 1 Tracks A–F are integrated into `fz-contrib`)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-G-architecture-and-docs-overhaul`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_G`  
**Exclusive Permitted Files:**
* `docs/ARCHITECTURE.md`
* `docs/THREAT-MODEL.md`
* `ROADMAP.md`
* `docs/whitepaper/SIMON-whitepaper-EN.md`

---

## 1. Objective

Deliver a clean, self-contained documentation and architectural clarity upgrade on top of `fz-contrib` so judges and developers inspecting the repo have an authoritative, honest, diagrammed architectural guide:
1. **Create `docs/ARCHITECTURE.md` (`[FZ-G1]`)**:
   - End-to-end Mermaid architecture and sequence diagrams for:
     - **Track 1 Intelligent Industry Pipeline**: UCI AI4I 2020 Milling (`10,000` rows) $\rightarrow$ `rules.py` (`8 ms`, 0 tokens) $\rightarrow$ Multi-turn Gemma 4 26B-A4B M7 Agent on RTX 3090 (`61.8 tok/s`) / AMD Instinct MI300X (`199.1 tok/s`) $\rightarrow$ `Receipt` (`SIMON/RECEIPT/v1` Level 0 + `WiazaniaM1` Level 1) $\rightarrow$ `CANARY-7` verification.
     - **Cryptographic Verification Hierarchy**: Level 0 (`Receipt::verify_self` + `Receipt::zgodny_z_wyjsciem` with `SIMON/RECEIPT/v1` & `SIMON/OUTPUT/v1` SHA-256 + Ed25519), Level 1 (`WiazaniaM1` with `SIMON/PROMPT/v1`, `SIMON/CHAIN/v1`, `SIMON/SAMPLING/v1`, `SIMON/TOKENIZER/v1`), M3 (`m3::ocena` cross-hardware FP drift telemetry), M7 (`Sufit` + `Zezwolenie` under `SIMON/GRANT/v1` & `SIMON/GRANT-PARAMS/v1`), M12 (`KL + Top-5 Jaccard`), LIDAR (`onetoken.py`), and `CANARY-7`.
     - **P2P Transport & Coordinator**: `simon agent` $\leftrightarrow$ `simon node` (`/simon/prompt/1.0.0`), ACP (`AcpServer`), and Gossipsub (`simon coord` + `Registry`).
2. **Align `docs/THREAT-MODEL.md`, `ROADMAP.md`, and `docs/whitepaper/SIMON-whitepaper-EN.md` (`[FZ-G2]`)**:
   - Explicitly document what cryptographic receipts prove (**non-repudiation and tamper-evidence** of the signed `{job_id, model_hash, output_digest, wiazania}` tuple) versus what active behavioral probing (`M12`, `LIDAR`, `CANARY-7`) catches (**silent model substitution, quantization downgrade, and cloud endpoint regression**).
   - Update milestone statuses (`M14` MI300X completed, `M1` live token chain wired, `M7` industry tool-calling agent wired).

---

## 2. Granular Commit Plan (Cherry-Pickable by Team Captain)

1. `[FZ-G1] docs(arch): add comprehensive docs/ARCHITECTURE.md with Mermaid data flows and verification hierarchy`
2. `[FZ-G2] docs(threat-model,roadmap): align threat boundaries and M1/M7/M14 milestone status with codebase`

---

## 3. Verification & PR Delivery

```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh G --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track G
```
