# Agent Task Specification: Track J (Stage 2, Wave 2A) — Signed `JobResult` (Failures Included) & Signed `RegisterMsg` ([FZ-J])

**Stage & Wave:** Stage 2 — Wave 2A (Urgent Security Closing — `docs/STRESS-TESTS.md` Next #1 & #3)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-J-signed-job-result-and-registration`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_J`  
**Exclusive Permitted Files:**
* `crates/simon-node/src/lib.rs`
* `crates/simon-cli/src/coord.rs`
* `crates/simon-node/tests/f3_receipt.rs`

---

## 1. Objective (`docs/STRESS-TESTS.md` Row #7 & Next #1, #3)

In `docs/STRESS-TESTS.md` (`53854d2`), the Team Captain (`Szpili`) and Claude Opus 5.5 documented two critical gossipsub vulnerabilities inside a company VPN and listed them as Next #1 and Next #3:

1. **Row #7 & Next #1 — Unsigned Failure Results on Gossipsub (`TOPIC_JOB_RESULT`)**:
   > `limit: failures are unsigned, so a peer that knows a fresh (job, node) pair can still report it failed. Fix: sign JobResult with the node key.`  
   > `1. Sign JobResult (failures too) with the node key; coordinator verifies before any state change.`
   Currently, in `crates/simon-cli/src/coord.rs` (`obsluz_wynik`, lines 129–173), checking `rejestr.assigned.get(&res.job_id) == Some(&res.node_id)` stops random unassigned spoofing, **but `JobOrdered`/`OrderAccepted` and `RegisterMsg` are broadcast on gossipsub**, so every peer on the VPN sees which `(job_id, node_id)` pair was just assigned! Any malicious peer can immediately broadcast an unsigned `JobResult::failure(job_id, node_id, "fake OOM")`, causing `obsluz_wynik` to mark the honest node `Degraded` and drop its job!

2. **Honest Limits & Next #3 — Unsigned Node Registration (`TOPIC_NODE_REGISTER`)**:
   > `Sybil / wash-compute: node registration on gossip is unsigned`  
   > `3. Signed node registration (keys and vouching for new nodes), then Sybil tests.`
   Currently, `RegisterMsg` in `crates/simon-node/src/lib.rs` (lines 40–60) has no signature proving the sender owns the private key for `pubkey`, nor an optional operator voucher signature (`voucher_signature`) to gate admission in a company VPN.

Your task is to close **both** Next #1 and Next #3 cleanly in `crates/simon-node/src/lib.rs` and `crates/simon-cli/src/coord.rs` while preserving backward-compatible unit test helpers where needed.

---

## 2. Mandatory Captain Guardrails for Track J

Read [`.agents/skills/simon-captain-review-guardrails/SKILL.md`](../../.agents/skills/simon-captain-review-guardrails/SKILL.md) before writing code:
1. **Canonical Domain-Separated Digests (`content_digest`)**:
   - Use `simon_core::content_digest` with explicit domain strings:
     - `pub const DOMENA_JOB_RESULT: &str = "SIMON/JOB-RESULT/v1";`
     - `pub const DOMENA_NODE_REGISTER: &str = "SIMON/NODE-REGISTER/v1";`
     - `pub const DOMENA_NODE_VOUCHER: &str = "SIMON/NODE-VOUCHER/v1";`
   - Never include float values in signed canonical JSON (`content_digest` rejects floats by design).
2. **Every Attack Test Needs a Control Case**:
   - In `783c667`, the Captain specifically added a control case to `obcy_wynik_nie_degraduje_wezla`: after proving that an attacker's forged failure is ignored, prove that a **valid signed failure from the assigned node** *does* mark the node `Degraded` and frees `assigned` (`!reg.assigned.contains_key("job-x")`).
3. **Clippy `--all-targets` Clean**:
   - Use `!reg.assigned.contains_key(...)` instead of `reg.assigned.get(...).is_none()` in tests (per Captain commit `7f4fb64`).

---

## 3. Granular Commit Plan (3 Atomic Commits)

### Commit 1: `[FZ-J1] feat(node): sign and verify JobResult (including failures) with node Ed25519 key`
- **File**: `crates/simon-node/src/lib.rs`
- Add `pub const DOMENA_JOB_RESULT: &str = "SIMON/JOB-RESULT/v1";`.
- Add `#[serde(default, skip_serializing_if = "Option::is_none")] pub signature: Option<simon_core::Signature>` to `JobResult`.
- Implement:
  - `pub fn digest(&self) -> Result<String, SimonError>` computing `simon_core::content_digest` over:
    ```rust
    serde_json::json!({
        "domena": DOMENA_JOB_RESULT,
        "job_id": self.job_id,
        "node_id": self.node_id,
        "ok": self.ok,
        "error": self.error,
        "receipt_digest": self.receipt.as_ref().and_then(|r| r.digest().ok()),
    })
    ```
  - `pub fn sign(mut self, keypair: &simon_core::Keypair) -> Result<Self, SimonError>` which signs `self.digest()?` and sets `self.signature = Some(...)`.
  - `pub fn verify_from_node(&self, registered_pubkey: &PublicKey) -> Result<(), SimonError>` which requires `self.signature` (`ok_or(SimonError::BadSignature)?`) and verifies it against `registered_pubkey` over `self.digest()?`.
- Add `Registry::verify_result_from_assigned_node(&self, result: &JobResult) -> Result<(), SimonError>` which verifies:
  1. `self.assigned.get(&result.job_id) == Some(&result.node_id)` (else `ReceiptMismatch`),
  2. `let registered = self.nodes.get(&result.node_id).ok_or(SimonError::UnregisteredKey)?;`,
  3. `result.verify_from_node(&registered.pubkey)?;`.
- Add unit tests in `crates/simon-node/src/lib.rs` testing signed `JobResult::failure` and `JobResult::success`, rejecting unsigned failures, wrong-key failures, and tampered error/job_id fields.

### Commit 2: `[FZ-J2] feat(node): add signed RegisterMsg proof-of-possession, operator voucher, and Sybil tests`
- **File**: `crates/simon-node/src/lib.rs`
- Add `pub const DOMENA_NODE_REGISTER: &str = "SIMON/NODE-REGISTER/v1";` and `pub const DOMENA_NODE_VOUCHER: &str = "SIMON/NODE-VOUCHER/v1";`.
- Add optional fields to `RegisterMsg`:
  - `#[serde(default, skip_serializing_if = "Option::is_none")] pub signature: Option<simon_core::Signature>`
  - `#[serde(default, skip_serializing_if = "Option::is_none")] pub voucher_signature: Option<simon_core::Signature>`
- Implement on `RegisterMsg`:
  - `pub fn digest(&self) -> Result<String, SimonError>` (using `DOMENA_NODE_REGISTER` over `node_id`, `protocol`, `capability.declared`, `region`, `pubkey`).
  - `pub fn voucher_digest(&self) -> Result<String, SimonError>` (using `DOMENA_NODE_VOUCHER` over `node_id`, `protocol`, `pubkey`).
  - `pub fn sign(mut self, node_key: &simon_core::Keypair) -> Result<Self, SimonError>` (sets `self.pubkey = node_key.public()` and `self.signature`).
  - `pub fn with_voucher(mut self, operator_key: &simon_core::Keypair) -> Result<Self, SimonError>` (sets `self.voucher_signature`).
  - `pub fn verify_self(&self) -> Result<(), SimonError>` (verifies `self.signature` under `self.pubkey`).
  - `pub fn verify_voucher(&self, operator_pubkey: &PublicKey) -> Result<(), SimonError>` (verifies `self.voucher_signature` under `operator_pubkey`).
- Add `pub fn register_verified(&mut self, msg: RegisterMsg, operator_voucher_key: Option<&PublicKey>) -> Result<(), SimonError>` on `Registry` that enforces `PROTOCOL_VERSION`, duplicate-node rejection, `msg.verify_self()?`, and (if `operator_voucher_key` is `Some(op)`) `msg.verify_voucher(op)?`.
- Add Sybil & spoofing unit tests in `crates/simon-node/src/lib.rs`:
  1. Attacker attempting to register with a victim's `pubkey` without the private key fails `verify_self()`.
  2. Sybil flood of 50 self-signed nodes without an operator voucher is 100% blocked when `operator_voucher_key` is required (`register_verified(..., Some(&operator.public()))`), while the 2 plant-vouched nodes succeed.

### Commit 3: `[FZ-J3] fix(coord): require signed JobResult from assigned node before state change or degradation`
- **File**: `crates/simon-cli/src/coord.rs`
- Update `obsluz_wynik(rejestr: &mut Registry, res: JobResult)` in `crates/simon-cli/src/coord.rs`:
  - First check `if rejestr.assigned.get(&res.job_id) != Some(&res.node_id)` (ignore unassigned).
  - Next, look up `rejestr.nodes.get(&res.node_id)` and verify `res.verify_from_node(&registered.pubkey)`! If the signature is missing or invalid (`Err`), log `[coord] WYNIK ODRZUCONY (brak ważnego podpisu węzła)` and **`return` without degrading the node or dropping the assignment**!
  - Remove the outdated `// ponytail: porażka nie jest podpisana...` comment since failures are now signed and verified!
  - In `uruchom` (when handling `topic_rejestracji`), if `msg.signature.is_some()` and `msg.verify_self().is_err()`, reject the forged registration before calling `rejestr.register(msg)`.
- Update existing tests in `crates/simon-cli/src/coord.rs` (`obcy_wynik_nie_degraduje_wezla` and `test_obsluz_wynik_success_and_degraded`) so legitimate node results in tests are signed with the node's `Keypair`, and add an explicit test proving that **even when an attacker knows the exact assigned `(job_id, node_id)` pair**, an unsigned or wrong-key `JobResult::failure("job-x", "inny", "forged OOM")` is ignored and does NOT degrade `"inny"`, whereas the control case (signed by `"inny"`'s keypair) degrades `"inny"` and frees `"job-x"`.

---

## 4. Verification Requirements

```bash
export PATH="/home/agent/.cargo/bin:$PATH"
bash /home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-verify-suite/scripts/verify_track.sh J --final
python3 /home/agent/SIMPN_ARGON_HANDOWER/.agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track J
```
