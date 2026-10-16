---
name: simon-captain-review-guardrails
description: >-
  Mandatory pre-implementation and pre-commit review checklist derived from the Team Captain
  (Szpili) and Claude Opus 5.5 review of Stage 1 (22 corrective commits). Activate this skill
  on EVERY Stage 2 (Tracks G, H, I, J) and Stage 3 (Tracks K, L, M, N) task to prevent
  guessed claims, unpinned signers, overclaiming UI/docs, weak guardrails, and gossipsub DoS bugs.
---

# SIMON Team Captain & Claude Review Guardrails (`simon-captain-review-guardrails`)

Every Stage 2 (`Track G`–`Track J`) and Stage 3 (`Track K`–`Track N`) agent **MUST** enforce all 7 rules below before staging any commit. These rules come directly from the 22 corrective commits made by Team Captain (`Szpili`) and Claude Opus 5.5 during the Stage 1 review (`c35383a`..`53854d2` + `5854038`).

---

## Rule 1: Never Sign or Report a Guess (Fail Closed / Use `Unknown` or `None`)

- **Why**: A signed `Receipt`, `JobResult`, or `RegisterMsg` is a cryptographic statement. Guessing a field when data is missing or ambiguous falsifies the signed record.
- **DO NOT**:
  - Default `Precision` to `Fp16` when a model name has no marker or has unsupported/conflicting markers (`Q5_K_M`, `awq-fp8`).
  - Map integer quantizations (`GGUF Q4_*`, `IQ4_*`, `AWQ`, `GPTQ`, `INT4`, `Q8_*`, `W8A8`) to `Fp4` or `Fp8` — they are `Precision::Int4` and `Precision::Int8`.
  - Match substrings inside model hashes (`lower.contains("f16")` matches hex digests!). Always split on non-alphanumeric boundaries (`split(|c: char| !c.is_ascii_alphanumeric())`).
  - Sign an M1 `WiazaniaM1` commitment if `/tokenize` failed, returned empty tokens, or exceeded `MAX_M1_TOKENS`.
- **DO**:
  - Return `Precision::Unknown` whenever markers are absent, unsupported (`Q5`/`Q6`), or conflicting.
  - Fall back cleanly to Level 0 (`wiazania: None`, `tokenizer_hash: None`, `prompt_token_ids: None`, `output_token_ids: None`) whenever live tokenization is unavailable or invalid.

---

## Rule 2: Verified State vs. Node-Declared State (Client Never Trusts the Node)

- **Why**: A dishonest node can set `receipt_level: 1` without sending tokens, or put its own fake `client_nonce` inside `receipt.wiazania`, or generate a fresh Ed25519 keypair and self-sign any output.
- **DO NOT**:
  - Set `poziom_dowodu` or gateway `proof_level` to `receipt.poziom()`.
  - Read `client_nonce` from `receipt.wiazania.client_nonce` when verifying M1!
  - Assume `Receipt::verify_self()` proves *which* node signed the receipt (it only proves the key embedded *inside* the receipt signed the text).
- **DO**:
  - Compute `poziom_sprawdzony(weryfikacja, m1_sprawdzone, deklarowany)` (`1` ONLY when receipt verification succeeded AND non-empty token vectors were actually verified via `zweryfikuj_m1` against the client's own `order.nonce`). Report `poziom_deklarowany_przez_node` separately.
  - Always pass the client's own `&order.nonce` to `zweryfikuj_m1`.
  - Enforce `--expect-signer` (`podpisal_oczekiwany`) in both offline verification and live `--role agent` / `simon_api.py` (`signer_pinned`).

---

## Rule 3: Zero Overclaiming in UI, Verdicts, Comments & Docs

- **Why**: Hackathon judges and the Team Captain cross-check every sentence against the code and committed `.jsonl`/`.json` data files.
- **DO NOT**:
  - Write `"ALLOW TICKET (100% Authentic)"`, `"MITM Attack Detected"`, or `"SIMULATED P2P TOPOLOGY"` (on live monitor pages).
  - Fabricate a fake `"ed25519:operator_sig_..."` string or `"status": "APPROVED"` in browser UI previews where no private key exists.
  - Write unbacked throughput figures (`61.8 tok/s`, `199.1 tok/s`, `8/8 CANARY-7 pass`) or hardcode total test counts (`192 tests`) in `README.md`, `LABLAB-SUBMISSION.md`, or `docs/`.
- **DO**:
  - State only what was verified: `"SIGNATURE & DIGEST VALID — Proves signer key and exact text; does not prove which model weights executed."`
  - For browser capability grant previews, use `signature: null` and `status: "UNSIGNED_PREVIEW"`.
  - Cite only metrics backed by committed data files in `docs/` (e.g., `docs/industry/run-catalog-3090-mi300x-2026-10-15.jsonl`: 14/15 published, 1 held, median 1.6 s [1.56 s RTX 3090, 1.67 s MI300X]; `docs/amd-data/c1_concurrency_20261013T113218Z.json`: 64 streams, 510/510 receipts verified).

---

## Rule 4: Strict Rule-Binding, Unicode Normalization & Zero Workspace Path Leaks

- **Why**: LLM tool-calling guardrails that only check enum membership allow the model to swap failure modes, urgencies, or actions across findings, and ASCII substring checks are bypassed by Unicode homoglyphs/format characters.
- **DO NOT**:
  - Ever include `/home/agent/SIMPN_ARGON_HANDOWER` or `/home/agent/SIMON` in any repository file (`verify_track.sh` automatically fails if any workspace path appears in your diff!).
  - Validate `propose_work_order` only against static enums.
  - Interpolate raw CSV strings (`product_id`, `type`) into prompts or tool outputs without stripping non-alphanumeric characters.
- **DO**:
  - Bind proposals to `rules.findings(row)` (exact failure modes with no duplicates, urgency of the most urgent finding `findings[0]`, and catalog `(action_code, part_id)` for `findings[0]["mode"]`).
  - Normalize free text with `unicodedata.normalize("NFKC")`, strip Unicode `Cf` format characters (zero-width spaces, soft hyphens, bidi overrides), replace hyphens with spaces, collapse whitespace, and check length *after* normalization.

---

## Rule 5: Adversarial P2P & Gossipsub State Machine Discipline

- **Why**: Inside a company VPN (`docs/STRESS-TESTS.md`), any peer on gossipsub can broadcast arbitrary `JobResult` or `RegisterMsg` payloads, or flood a node with duplicate/burst requests.
- **DO NOT**:
  - Mutate coordinator state (`mark_degraded`, `complete`, `register`) on an unverified gossipsub message.
  - Leave failed jobs stuck in `rejestr.assigned` (always call `complete_job(&res.job_id)` when an authentic failure is processed).
  - Accept unbounded `Vec<u32>` token arrays over P2P or `/tokenize` without enforcing `MAX_M1_TOKENS` (`65_536`).
- **DO**:
  - Verify job assignment (`rejestr.assigned.get(&res.job_id) == Some(&res.node_id)`) AND verify the node's Ed25519 signature (`JobResult::verify_from_node(&registered.pubkey)`) before degrading a node or completing a job.
  - Write unit tests with both **attack cases** (forged/unassigned/wrong-key messages rejected) AND a **control case** (authentic message from the assigned node succeeds).

---

## Rule 6: Serde `Value::Null` Compatibility, `simulated` Audit Rejection & Constant-Time Auth

- When validating JSON tool arguments (`cap.rs`), treat `Value::Null` (missing optional `args`) as an empty map `{}` while rejecting scalars and arrays (`Value::String`, `Value::Array`, `Value::Number`, `Value::Bool`).
- When parsing execution audits (`m3::ocena_json`), reject any JSON object where `"simulated"` is present and not `Value::Bool(false)`.
- When comparing secret tokens (`simon_api.py`), compare fixed-length SHA-256 digests (`hmac.compare_digest(sha256(got), sha256(expected))`) so secret length is never leaked.

---

## Rule 7: Mobile 390px Layout & Accessibility in SvelteKit (`ui/`)

- Every grid child and flex container displaying hex digests, keys, or JSON must include `min-w-0` and `break-all` / `whitespace-pre-wrap` so the page never overflows a `390px` phone screen.
- Every `<button>` must have `type="button"`, interactive toggle buttons must have `aria-pressed={...}`, form controls must have associated `<label for="...">`, and dynamic verdict banners must use `aria-live="polite"`.
- Always run `cargo clippy --workspace --all-targets -- -D warnings` (with `--all-targets` so test code is linted!).

---

## Rule 8: Zero Mermaid Syntax Errors in Documentation & Architecture Diagrams

- **Why**: Mermaid diagrams render across GitHub, VS Code, and SvelteKit UI. Semicolons inside sequence diagram notes/messages, unescaped HTML-like angle brackets, unquoted labels with parentheses/brackets, or unescaped arrow tokens break Mermaid rendering with syntax errors.
- **DO NOT**:
  - Put semicolons `;` inside `sequenceDiagram` `Note over ...:` text or messages (in Mermaid, `;` is a statement delimiter and truncates the statement!).
  - Put unescaped arrows `->`, `-->`, `--`, `->>` inside Note text.
  - Put unescaped angle-bracket placeholders `<pubkey>` or `<node_id>` (they are parsed as HTML tags).
  - Use unquoted flowchart labels with parentheses, brackets, or commas: `Node[Label (info)]`.
  - Use double pipes `||` inside pipe-delimited flowchart edge labels: `-->|"foo || bar"|`.
- **DO**:
  - Use commas or dashes in sequence notes and messages: `Note over Node: Check replay, check rate, acquire semaphores`.
  - Use square brackets or parentheses for identifiers: `[pubkey]`, `(node_id)`.
  - Quote all flowchart node labels: `Node["Label (info)"]`.
  - Run `python3 scripts/check_mermaid.py` on all modified markdown files before staging commits.

