# 02 — Line-by-Line Codebase Audit: Rust Workspace (`crates/*`)

This document contains the complete, file-by-file, line-by-line audit of the Rust workspace in `/home/agent/SIMON`. Every struct, function, cryptographic domain, and security flaw is documented with exact line references.

---

## 1. Root `Cargo.toml` (`/home/agent/SIMON/Cargo.toml`, Lines 1–31)
* **`L1-3`:** Workspace resolver `"2"`, members: `crates/simon-core`, `crates/simon-node`, `crates/simon-harness`, `crates/simon-cli`, `crates/simon-verify-wasm`.
* **`L5-9`:** Workspace package metadata (`version = "0.1.0"`, `edition = "2021"`, `license = "MIT"`, `authors = ["Karol (Szpili)"]`).
* **`L11-25`:** Shared dependencies: `ed25519-dalek = "2"` (`rand_core`), `rand = "0.8"`, `sha2 = "0.10"`, `hex = "0.4"`, `serde = "1"`, `serde_json = "1"`, `time = "0.3"`, `thiserror = "1"`, `reqwest = "0.12"` (`json`, `rustls-tls`).
* **`L27-30`:** `[profile.release]` (`opt-level = 3`, `lto = true`, `codegen-units = 1`).
* **Audit Findings:**
  * No `zeroize` crate for wiping secret keys from RAM.
  * No RFC 8785 JSON Canonicalization Scheme (`serde_json_canonicalizer`) dependency, despite comments claiming canonical JSON.

---

## 2. Crate: `crates/simon-core/`

### 2.1 `crates/simon-core/Cargo.toml` (Lines 1–26)
* **`L9-15`:** Core dependencies (`ed25519-dalek`, `sha2`, `hex`, `serde`, `serde_json`, `thiserror`).
* **`L21-22`:** `[target.'cfg(not(target_arch = "wasm32"))'.dependencies]` gates `rand` so `simon-core` compiles cleanly to `wasm32-unknown-unknown` without JS RNG shims.

### 2.2 `crates/simon-core/src/lib.rs` (Lines 1–75)
* **`L17-33`:** Exports `crypto`, `cap`, `limity`, `m3`, `protokol`, `przeplyw`, `web`, `obserwacja`, `pomiar`, `receipt`, plus non-WASM `rejestr` (`L29-30`) and `tozsamosc` (`L31-32`).
* **`L39`:** `pub const PROTOCOL_VERSION: &str = "simon/v1";` — unused inside `simon-core` or `simon-verify-wasm` (never included in `Receipt::digest()`).
* **`L41-53`:** `pub enum SimonError` (`BadSignature`, `ReceiptMismatch(String)`, `UnregisteredKey`, `Serde`, `Crypto(String)`).
* **`L67-74` (`content_digest`):**
  ```rust
  pub fn content_digest<T: Serialize>(value: &T) -> Result<String, SimonError> {
      let json = serde_json::to_string(value)?;
      let mut h = Sha256::new();
      h.update(json.as_bytes());
      Ok(hex::encode(h.finalize()))
  }
  ```
* **Flaw (`L57-66`):** Comment claims keys are sorted ("JSON z posortowanymi kluczami"). In reality, `serde_json::to_string` only sorts keys for `serde_json::Value::Object` (`BTreeMap`). For `#[derive(Serialize)]` Rust structs (`Receipt`, `WiazaniaM1`, `Zezwolenie`), fields are serialized in **Rust struct declaration order**, not alphabetical order.

### 2.3 `crates/simon-core/src/crypto.rs` (Lines 1–112)
* **`L15-25`:** `Keypair` (omits `Debug`, `Clone`, `Serialize`), `PublicKey([u8; 32])`, `Signature([u8; 64])`.
* **`L53-55` (`Keypair::sign_digest`):** Signs `digest_hex.as_bytes()` — i.e. the **64-byte ASCII hex string** of the SHA-256 hash, rather than the raw 32-byte digest.
* **`L72-78` (`PublicKey::verify_digest`):**
  * **Flaw 1:** Calls `key.verify(digest_hex.as_bytes(), &s)` instead of `key.verify_strict(...)`, permitting Ed25519 small-order/cofactor malleability.
  * **Flaw 2:** No top-level domain separation in `sign_digest`/`verify_digest`; relies on callers to include domain tags in their JSON (which `Receipt::digest()` and `Zezwolenie::digest()` omit!).

### 2.4 `crates/simon-core/src/tozsamosc.rs` (Lines 1–364)
* **Purpose:** Persistent client Ed25519 identity loader/creator (`~/.local/share/simon/identity/client.key`) that refuses silent key regeneration on corruption (`M5.2a`).
* **`L137-163` (`wczytaj`):** Checks `0o077` permission mask (`sprawdz_prawa`, `L166-186`), parses `PlikTozsamosci`, checks `key_type == "ed25519"` and `secret_encoding == "hex"`. (**Note:** `plik.version` at `L44` is never checked!).
* **`L188-239` (`zaloz`):**
  * **Security Flaw (TOCTOU Private Key Leak, `L220-229`):** `fs::File::create(&tymczasowy)` (`L221`) creates `.client.key.<pid>.tmp` with default `umask` (`0o644`, world-readable), writes the plaintext hex `secret_key` (`L222`), flushes to disk (`L223`), and **only at `L228`** calls `chmod 0o600` before `fs::rename`. Should use `OpenOptionsExt::mode(0o600)` at creation.

### 2.5 `crates/simon-core/src/cap.rs` (Lines 1–486)
* **Purpose:** Capability ceiling (`Sufit`, `Akcja`, `Parametr`, `Ograniczenie`) and single-use operator capability grants (`Zezwolenie`).
* **`L91-180` (`waliduj`):**
  * **Bug (`L97-120`):** `let obj = parametry.as_object();` does **not** return `Err(Odmowa::ZlyTyp)` when `parametry` is not a JSON Object (e.g., `Value::Array`, `Value::String`, `Value::Null`). If an action has 0 required parameters, passing `"args": "malicious_string"` returns **`Ok(())`**!
* **`L202-316` (`Zezwolenie` & `sprawdz`):**
  * `odcisk_parametrow_akcji` (`L221-227`) hashes `{"domena": "SIMON/GRANT-PARAMS/v1", "akcja": akcja, "parametry": parametry}`.
  * **Stub (`L214`):** `Zezwolenie::budzet: Option<i64>` is signed in the struct but **never checked** in `sprawdz()` (`L272-316`). Even `budzet: Some(0)` or `Some(-10)` passes!
  * **Stateless Check (`L272-316`):** `sprawdz()` checks `k.uzyte.iter().any(|u| u == &z.id)` on an immutable slice `&'a [String]`; caller must manually record `z.id` after `sprawdz()` returns.

### 2.6 `crates/simon-core/src/protokol.rs` (Lines 1–144)
* **Purpose:** Message size limit (`MAX_WIADOMOSC_BAJTOW = 1 MiB`), sliding-window anti-replay (`OknoNonce`), and token-bucket rate limiter (`Kubelek`).
* **Flaws:**
  1. **`OknoNonce::przyjmij` off-by-one (`L44` vs `L56`):** `L44` rejects `nonce <= m.saturating_sub(self.okno)`, while `L56` retains `*n >= m.saturating_sub(self.okno)`, keeping one dead element in the `BTreeSet`.
  2. **`Kubelek::zezwol` non-monotonic timestamp bug (`L91-93`):** Overwrites `self.ostatni_us = teraz_us` even when `teraz_us < self.ostatni_us`. Passing a smaller timestamp followed by the current timestamp double-credits the elapsed time `dt`, minting free rate-limit tokens!

### 2.7 `crates/simon-core/src/receipt.rs` (Lines 1–524)
* **Purpose:** Cryptographic receipt (`Receipt`), Level 1 input/token-chain commitment (`WiazaniaM1`), and `SamplingCommitment`.
* **Key Domains & Functions:**
  * `odcisk_wyjscia(job_id, output)` (`L135-141`): `{"domena": "SIMON/OUTPUT/v1", "job_id": job_id, "output": output}`.
  * `odcisk_promptu` (`L148-159`): `"SIMON/PROMPT/v1"`.
  * `lancuch_tokenow` (`L164-173`): `"SIMON/CHAIN/v1"`.
  * `odcisk_parametrow` (`L178-193`) AND `SamplingCommitment::odcisk` (`L221-225`): Both use `"SIMON/SAMPLING/v1"` with different schemas (5 milli-scaled fields vs 11 micro-scaled fields).
  * `odcisk_tokenizera` (`L246-253`): `SHA256("SIMON/TOKENIZER/v1" || 0x00 || bytes)`.
* **Critical Flaws in `receipt.rs`:**
  1. **`Receipt::zweryfikuj_m1` (`L299-330`) NEVER calls `self.verify_self()`!** Calling `zweryfikuj_m1` on an unsigned or forged receipt returns `Ok(())`.
  2. **`Receipt::zweryfikuj_m1` does NOT check `prompt_tokens == prompt_token_ids.len()` or `completion_tokens == output_token_ids.len()`**, allowing a node to commit to 2 tokens in `WiazaniaM1` while claiming `completion_tokens: 100_000` in `Receipt`.
  3. **`Receipt::zweryfikuj_m1` does NOT check `receipt_level == 1` or `schema_version == 2`**.
  4. **`activation_hash` (`L63`):** Completely unverified placeholder (`"toploc:NIE_POLICZONY"`).

### 2.8 `crates/simon-core/src/m3.rs` (Lines 1–383)
* **Purpose:** M3 teacher-forced top-$k$ trajectory evaluator (`ocena`, `ocena_json`, `odcisk_audytu`, `decyzja`).
* **Critical Flaws:**
  1. **`HardFail` Is Unreachable Dead Code (`L233-249`):** `decyzja()` ignores `progi.twardy_poza` (`0.05`) and unconditionally returns `Decyzja::SoftFail` on any failure (`NAPRAWA 2026-10-06` after `FP-RESULT.md` failed). Yet the doc comment at `L230` still claims it returns `HardFail`.
  2. **IEEE-754 `f64::NAN` Bypass (`L105-115`):**
     `let margin = match top1_lp { Some(t1) => (t1 - *lp).max(0.0), None => 0.0 };`
     In Rust, `(f64::NAN).max(0.0)` returns `0.0`! Thus passing `NaN` as a logprob produces `margin == 0.0 <= 0.25`, passing the step (`w_topk += 1`) while poisoning `sredni_nll` with `NaN`!
  3. **Unchecked `topk` Ordering (`L93-101`):** Assumes `kr.topk` is sorted descending by logprob and has no duplicate token IDs.
  4. **`sredni_nll` (`L66, L156`) Is Never Checked:** Computed as a "second signal" (`krytyk bunny`) but never compared against any threshold.
  5. **`odcisk_audytu` (`L165-180`) Drops All Logprobs:** Hashes only `(indeks, node_token, topk_token_ids)`, omitting the logprobs that determine `margin`.

### 2.9 `crates/simon-core/src/pomiar.rs` (Lines 1–70)
* **Purpose:** `podejrzanie_identyczna(a, b, tolerancja)` (`L21-32`) detects if two throughput measurements are within `0.1%` (`TOLERANCJA_PROFILI = 0.001`). Standalone helper, unused in production code.

### 2.10 `crates/simon-core/src/obserwacja.rs` (Lines 1–142)
* **Purpose:** Client-signed monotonic timing record (`ClientObservationV1`) under domain `"SIMON/OBSERVATION/v1"`.
* **Bug (`L82-86`):** `ClientObservationV1::sign()` does not set `self.client_pubkey = klucz.public()` before computing `self.digest()` (unlike `Receipt::sign()` and `Zezwolenie::podpisz()`).

### 2.11 `crates/simon-core/src/limity.rs` (Lines 1–159)
* **Purpose:** Per-job resource budget tracker (`Limity`, `Budzet`, `Przekroczenie`: `Deadline`, `Tokeny`, `Bajty`, `KrokiNarzedzi`, `Anulowane`). Clean cooperative state machine using `saturating_add`/`saturating_sub`, but **never instantiated or called in `simon-cli` or `simon-node`**.

### 2.12 `crates/simon-core/src/przeplyw.rs` (Lines 1–108)
* **Purpose:** Information Flow Control (IFC) matrix mapping `Zaufanie` (`Operator`, `ClientInput`, `PeerText`, `RetrievedText`, `ToolText`, `ModelDerived`) $\times$ `Sink` (`ArgumentAkcji`, `InstrukcjaKolejnegoZlecenia`, `SystemPrompt`, `Log`) $\rightarrow$ `bool`. Only used in unit tests (`crates/simon-core/tests/`), not wired into `simon-cli`.

### 2.13 `crates/simon-core/src/rejestr.rs` (Lines 1–300)
* **Purpose:** Append-only JSONL work ledger (`Rejestr`, `RekordPracyV1`).
* **Flaws (`L145-160`):** `Rejestr::dopisz()` never verifies `receipt_signature`, deduplicates only on caller-provided `receipt_hash` (not `job_id`), and uses no file locking (`flock`) or `fsync`.

### 2.14 `crates/simon-core/src/web.rs` (Lines 1–167)
* **Purpose:** URL/DNS policy validator (`dozwolony_web`, `dozwolony_dns`) and container digest allowlist (`dozwolony_code`).
* **Critical SSRF Flaws (`L44-61, L88-96`):**
  1. **IPv4-mapped IPv6 Bypass (`L49`):** `prywatny_ip("::ffff:127.0.0.1")` and `prywatny_ip("::ffff:169.254.169.254")` parse as `IpAddr::V6(v6)` where `v6.is_loopback() || v6.is_unspecified()` is **`false`**! Thus `dozwolony_dns` allows cloud metadata (`::ffff:169.254.169.254`) and localhost (`::ffff:127.0.0.1`)!
  2. **IPv6 Unique Local (`fc00::/7`, `fd00::/8`) & Link-Local (`fe80::/10`) Bypass:** Not checked in `prywatny_ip`.
  3. **Bracketed IPv6 (`"[::1]"`):** Fails `IpAddr::from_str`, returning `prywatny_ip("[::1]") == false`.
  4. **Suffix Matching Bug (`L26` vs `L59`):** Doc comment at `L26` instructs passing `".example.com"`, which `format!(".{w}")` at `L59` turns into `"..example.com"`.

---

## 3. Crate: `crates/simon-verify-wasm/`

### 3.1 `crates/simon-verify-wasm/src/lib.rs` (Lines 1–308)
* **Exported WASM Functions:** `weryfikuj` (`L72-119`), `odcisk_wyjscia` (`L123-126`), `weryfikuj_m1` (`L131-174`), `ocena_m3` (`L178-191`).
* **Critical Security Bugs:**
  1. **`weryfikuj_m1` (`L131-174`) Never Verifies the Ed25519 Signature:** Calls `r.zweryfikuj_m1(...)` without `r.verify_self()`. An unsigned receipt passes!
  2. **`weryfikuj` (`L72-119`) Only Calls `r.verify_self()` (`L84`):** Never verifies `r.signer` against an expected node key (`verify_for_node`), and if `output` is `None` (as on `/network`), `ok` defaults to `true` (`L91-94`).
  3. **`ocena_m3` (`L178-191`) Bypasses `m3::decyzja`:** Calls `m3::ocena_json` directly, skipping the `min_krokow >= 8` (`InsufficientEvidence`) and `receipt_level >= 1` (`BrakPodstaw`) checks.

---

## 4. Crate: `crates/simon-harness/`

### 4.1 `crates/simon-harness/src/transport.rs` (Lines 1–290)
* Defines `SimonBehaviour` (`gossipsub`, `kad`, `identify`, `ping`), `spawn_swarm`, and `deterministic_job_id(order_id)` (`"job-" + sha256_hex(order_id)`).
* **Key Reality:** `simon-cli` **never uses `transport.rs`**! And `deterministic_job_id` here (68 chars) disagrees with `simon-cli/src/agent.rs:497` and `coord.rs:153` (`"job-" + &order_id[..16]`, 20 chars).

### 4.2 `crates/simon-harness/src/request_response.rs` (Lines 1–181)
* Defines `PromptRequest`, `PromptResponse`, `PromptError`, `PromptReply`, and CBOR protocol `ProtokolPromptu` (`"/simon/prompt/1"`). Also defines `ProtokolWyniku` (`"/simon/result/1"`), which is dead code.
* **Note:** `PromptRequest` has no client signature or `Autoryzacja` field.

### 4.3 `crates/simon-harness/src/client_protocol.rs` (Lines 1–699)
* Defines `BurnProof`, `Autoryzacja`, `JobOrder`, `RejestrZuzytychAutoryzacji`, `OrderAccepted`, `OrderCompleted`, and `RejestrKoordynatorow`.
* **Flaws:**
  1. **Integer Overflow in `Autoryzacja::czy_wazna` (`L190-192`):** `teraz_unix <= self.wazne_do + TOLERANCJA_ZEGARA_SECS` uses unchecked `+` instead of `saturating_add`; panics in debug or wraps in release if `wazne_do == u64::MAX`.
  2. **`JobOrder::zweryfikuj_autoryzacje` (`L324-353`)** does not check `self.order_id_sie_zgadza()` or `self.is_funded()`.

### 4.4 `crates/simon-harness/src/acp_server.rs` (Lines 1–463)
* **Three Fatal Bugs in `AcpServer`:**
  1. **`przyjmij` (`L221-258`) leaves `order.autoryzacja = None`**, so `coord.rs:120` will reject every `JobOrder` broadcast by `AcpServer`!
  2. **`obsluz_event` (`L284-315`) calls `OrderAccepted::winner(&kandydaci)` without `RejestrKoordynatorow` or `podpis_zgadza_sie()`**, allowing an unsigned attacker message to win coordinator selection.
  3. **`zakoncz` (`L403-414`) computes raw `SHA256(tresc_wyniku)` instead of domain-separated `odcisk_wyjscia(job_id, output)`**, making `AcpServer` 100% incompatible with receipts signed by `node.rs`! (Masked in `tests/acp_server.rs:14-22` because the test helper also used raw SHA-256).

---

## 5. Crate: `crates/simon-node/`

### 5.1 `crates/simon-node/src/lib.rs` (Lines 1–249)
* **Purpose:** In-memory node `Registry` (`register`, `kandydaci_dla_modelu`, `assign`, `complete`, `evict`).
* **Flaws:**
  1. **Unsigned `RegisterMsg` (`L40-60`):** No signature field; any peer on gossipsub can register fake nodes or hijack IDs.
  2. **`kandydaci_dla_modelu` (`L147-177`) Violates `RULES #2`:** While `L151` checks `n.capability.usable()` (`attested.is_some()`), lines `153-165` read `model_hash` and `max_ctx` from **`n.capability.declared`**, NOT `n.capability.attested`!
  3. **Unauthenticated Job Cancellation (`L201-229`):** In `complete()`, if `result.ok == false`, it removes the job from `self.assigned` without requiring a receipt or signature.

---

## 6. Crate: `crates/simon-cli/`

### 6.1 `crates/simon-cli/src/main.rs` (Lines 1–748)
* CLI parser and offline subcommands (`verify` / `--verify-receipt`, `audyt`, `guard`).
* **Flaw (`L346-503`):** `weryfikuj_offline` (`simon verify`) calls `r.verify_self()` (`L380`) and has **no `--expect-signer` / `--expect-node-key` flag**, so it only verifies that the receipt is self-signed by whatever key is inside `r.signer`.

### 6.2 `crates/simon-cli/src/wspolne.rs` (Lines 1–179)
* Builds the actual libp2p Swarm (`Zachowanie`: `gossipsub`, `prompt_rr`, `ping`, `identify` — **no Kademlia `kad`, no mDNS, no Relay**).
* Derives domain-separated P2P Ed25519 key via `SHA256("simon-p2p-identity-v1" || seed)` (`klucz_p2p_z_seeda`, `L109-117`).
* **Flaw (`L50-57`):** Unlike `simon-harness/src/transport.rs:61` (which sets 4 MB `max_transmit_size`), `wspolne.rs` uses the default 64 KB gossipsub limit.

### 6.3 `crates/simon-cli/src/node.rs` (Lines 1–978)
* Worker node (`simon --role node`).
* **Critical Findings & Bugs:**
  1. **Startup Registration Race (`L127`):** Publishes `RegisterMsg` to `TOPIC_NODE_REGISTER` once immediately after `zbuduj_swarm`, before the `--bootstrap` connection/mesh is established (~1.5s), failing with `InsufficientPeers` and never retrying.
  2. **Self-Attestation Bypass (`L120-123`):** Sets `attested: Some(json!({"model_hash": model_deklarowany, "max_ctx": max_ctx}))` on its own `RegisterMsg`.
  3. **Zero Weight Hashing (`L87-95, L501-539`):** Queries `GET /v1/models` on `--model-url`; if unreachable or missing, falls back to trusting the `--model-hash` CLI flag string!
  4. **Broken `/tokenize` Context Gate on `llama-server` (`L646-704`):** `odczytaj_realny_ctx` sends `POST /tokenize {"prompt": prompt}` expecting `{"count": N}` (vLLM format). `llama-server` expects `{"content": prompt}` and returns `{"tokens": [...]}`—so on `llama-server`, `/tokenize` always fails and falls back to the client's char estimate!
  5. **Hardcoded/Broken Receipt Metadata (`zbuduj_podpisany_receipt`, `L710-755`):**
     * `started_at_us: teraz` and `finished_at_us: teraz` (`L721-724, L740-741`) both use the post-inference timestamp, so duration is always `0 µs`!
     * `precision: Precision::Fp16` (`L731`) is hardcoded regardless of actual model quantization/dtype (`Q4_0`, `BF16`, `AWQ`).
     * `activation_hash: "toploc:NIE_POLICZONY"` (`L733`) is hardcoded.
     * `wiazania: None` (`L744`) is hardcoded (Proof Level 0 only).
     * `wykryj_runtime` (`L608-639`) only checks `/api/version` (Ollama) and `/version` (vLLM), returning `"nieznany/1"` on `llama-server` (which uses `/props`).

### 6.4 `crates/simon-cli/src/agent.rs` (Lines 1–1076)
* Client agent (`simon --role agent`). Supports single prompt, 2-stage pipeline (`--then-bootstrap`), chat/tools (`--request-file`), and hierarchical Map-Reduce (`--file`).
* **Critical Findings:**
  1. **Throws Away `JobOrder` (`L460-511`):** `zbuduj_zlecenie` builds a `JobOrder` and signs `Autoryzacja`, verifies its own signature (`L490`), and then discards `order` without publishing to gossipsub.
  2. **Does Not Verify Node Public Key (`zweryfikuj_receipt`, `L729-751`):** Calls `r.verify_self()` (`L738`) instead of `r.verify_for_node(...)`, accepting any self-signed `r.signer`.

### 6.5 `crates/simon-cli/src/coord.rs` (Lines 1–184)
* Coordinator (`simon --role coord`).
* Uses an ephemeral key (`Keypair::generate()` at `L31`), does not check `order.order_id_sie_zgadza()` (`L120`), publishes `OrderAccepted` with `"vrf-mvp"`, and **never assigns or forwards jobs to nodes**.

### 6.6 `crates/simon-cli/src/mapreduce.rs` (Lines 1–162)
* Clean, well-tested UTF-8 character chunking (`podziel_na_kawalki`) and first-fit reduction grouping (`grupuj_do_budzetu`).
