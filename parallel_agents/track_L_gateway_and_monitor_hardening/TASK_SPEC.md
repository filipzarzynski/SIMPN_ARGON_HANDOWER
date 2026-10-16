# Agent Task Specification: Track L (Stage 3, Wave 3A) — OpenAI Gateway & Network Monitor Hardening (`[FZ-L]`)

**Stage:** Stage 3, Wave 3A (Run AFTER Stage 2 Tracks H, J, G, I are integrated into `fz-contrib`)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-L-gateway-and-monitor-hardening`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_L`  
**Exclusive Permitted Files:**
* `tools/simon-api/simon_api.py`
* `tools/simon-api/test_gateway.py`
* `tools/simon-monitor/simon_monitor.py`

---

## 0. Mandatory Skills to Read First
1. `/home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-captain-review-guardrails/SKILL.md`
2. `/home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-crypto-and-protocol/SKILL.md`

---

## 1. Objective

Harden the Python OpenAI gateway (`tools/simon-api/simon_api.py`) and network monitor (`tools/simon-monitor/simon_monitor.py`) against body-size DoS, SSRF in remote telemetry polling, and unpinned-signer ambiguity, while adding `--selfcheck` CLI flags so `verify_all_fast.sh` can run both deterministically:

1. **Harden `tools/simon-api/simon_api.py` & `tools/simon-api/test_gateway.py` (`[FZ-L1]`)**:
   - **Enforce `MAX_BODY_BYTES = 1_048_576` (1 MiB) in `do_POST`**:
     - Currently line 204 reads `self.rfile.read(int(self.headers.get("Content-Length", 0)))` with no upper cap or negative check. A rogue VPN client sending `Content-Length: 2000000000` causes memory exhaustion.
     - Reject negative `Content-Length` with `400` and `Content-Length > MAX_BODY_BYTES` with `413` (`"request body too large"`).
   - **Record `signer_pinned` in `log_job` (`simon_api.py` line 66)**:
     - Include `"signer_pinned": bool(r.get("signer_pinned"))` in each JSONL line written to `SIMON_API_JOBLOG` so `simon_monitor.py` and `/network` can see whether a job's receipt signer was pinned in `nodes.json`.
   - **Add `--selfcheck` CLI flag to `simon_api.py`**:
     - When invoked as `python3 tools/simon-api/simon_api.py --selfcheck`, run `test_gateway.py`'s `unittest` suite (or an inline deterministic selfcheck covering SHA-256 `hmac.compare_digest` auth, `413` body cap, `503` + `Retry-After` on `node_zajety`/`rate_limit`, `proof_level` from `poziom_dowodu`, and `signer_pinned` propagation) and exit `0`.
   - Expand `tools/simon-api/test_gateway.py` with tests for `Content-Length > MAX_BODY_BYTES` (`413`), negative `Content-Length` (`400`), and `signer_pinned` in `log_job`.

2. **Harden `tools/simon-monitor/simon_monitor.py` (`[FZ-L2]`)**:
   - **Add `--selfcheck` CLI flag**:
     - Allow `python3 tools/simon-monitor/simon_monitor.py --selfcheck` to run `selfcheck()`, print `[simon-monitor] selfcheck OK`, and exit `0` without starting `ThreadingHTTPServer`.
   - **Guard `fetch_stats(url)` against non-HTTP schemes and oversized responses**:
     - Validate that `url` starts with `http://` or `https://` (blocking `file://` or other `urllib` handlers) and cap `r.read(65536)` to 64 KiB so a misbehaving stats endpoint cannot hang or OOM the monitor loop.
   - **Expose `proof_level` and `signer_pinned` counts in `State.totals`**:
     - Track `verified_m1_jobs` (`j.get("proof_level", 0) >= 1`) and `pinned_jobs` (`bool(j.get("signer_pinned"))`) in `State.totals` and verify them in `selfcheck()`.

---

## 2. Granular Commit Plan (Cherry-Pickable by Team Captain)

1. `[FZ-L1] feat(simon-api): enforce 1 MiB body limit, log signer_pinned, and add --selfcheck flag`
2. `[FZ-L2] feat(simon-monitor): bound fetch_stats read, track M1/pinned job totals, and add --selfcheck flag`

---

## 3. Verification & PR Delivery

```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh L --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track L
```
