# Track D — Fix All Core Security Vulnerabilities in `simon-core` & `simon-verify-wasm` (`PR-4`)

**Branch Name:** `fix/core-security-hardening`  
**Worktree Path:** `/home/agent/SIMPN_ARGON_HANDOWER/worktrees/track_D`  
**Owned Files:**
* `crates/simon-core/src/receipt.rs`
* `crates/simon-core/src/m3.rs`
* `crates/simon-core/src/cap.rs`
* `crates/simon-core/src/web.rs`
* `crates/simon-core/src/tozsamosc.rs`
* `crates/simon-core/src/obserwacja.rs`
* `crates/simon-core/src/protokol.rs`
* `crates/simon-core/tests/tamper_matrix.rs`
* `crates/simon-verify-wasm/src/lib.rs`

*(100% disjoint from `simon-cli`, `simon-harness`, `simon-node`, `tools/`, and `ui/`!)*

---

## Step-by-Step Implementation Instructions (8 Concrete Security Fixes)

### Fix D1: Require Valid Ed25519 Signature Inside `Receipt::zweryfikuj_m1` (`crates/simon-core/src/receipt.rs:299-330`) & `simon-verify-wasm` (`crates/simon-verify-wasm/src/lib.rs:131-174`)
* **Bug:** `Receipt::zweryfikuj_m1` only checks `self.wiazania` fields and **never calls `self.verify_self()`**! Consequently, `simon_verify_wasm::weryfikuj_m1` returns `{"ok": true}` for an unsigned or forged receipt.
* **Fix:**
  1. At the very top of `Receipt::zweryfikuj_m1` (`receipt.rs:306`), call `self.verify_self()?;`.
  2. Also verify `w.receipt_level >= RECEIPT_LEVEL_M1` and `w.schema_version == SCHEMA_VERSION_M1`.
  3. Add unit test `zweryfikuj_m1_odrzuca_niepodpisany_receipt` in `crates/simon-core/tests/tamper_matrix.rs` and `crates/simon-verify-wasm/src/lib.rs`.

### Fix D2: Fix SSRF / IPv6 Bypass in `crates/simon-core/src/web.rs` (`Lines 44–61, 88–96`)
* **Bug:**
  * `prywatny_ip` (`web.rs:44-52`) only checks `v6.is_loopback() || v6.is_unspecified()` for IPv6, allowing IPv4-mapped IPv6 (`::ffff:127.0.0.1`, `::ffff:169.254.169.254`), IPv6 ULA (`fc00::/7`), IPv6 Link-Local (`fe80::/10`), and bracketed IPv6 (`"[::1]"`).
  * `host_dozwolony` (`web.rs:55-61`) formats `format!(".{w}")`, breaking patterns that already start with `"."` (`".example.com"`).
* **Fix:**
  1. In `prywatny_ip(s: &str) -> bool`:
     * Strip surrounding `'['` and `']'` (`let czysty = s.trim_start_matches('[').trim_end_matches(']');`).
     * Call `ip.to_canonical()` so `::ffff:a.b.c.d` converts to `IpAddr::V4` before checking!
     * For `IpAddr::V4(v4)`: check `v4.is_private() || v4.is_loopback() || v4.is_link_local() || v4.is_unspecified() || v4.is_broadcast() || v4.is_multicast() || v4.is_documentation() || (v4.octets()[0] == 100 && (v4.octets()[1] & 0b1100_0000) == 64)` (CGNAT `100.64.0.0/10`).
     * For `IpAddr::V6(v6)`: check `v6.is_loopback() || v6.is_unspecified() || v6.is_multicast() || ((v6.segments()[0] & 0xfe00) == 0xfc00) || ((v6.segments()[0] & 0xffc0) == 0xfe80)`.
  2. In `host_dozwolony`: normalize `w = wzorzec.to_ascii_lowercase()`, strip any leading `.` (`let bez_kropki = w.trim_start_matches('.');`), and check `h == bez_kropki || h.ends_with(&format!(".{bez_kropki}"))`.

### Fix D3: Fix IEEE-754 `f64::NAN` Bypass & Unsorted `topk` in `crates/simon-core/src/m3.rs` (`Lines 82–161`)
* **Bug:** `(t1 - *lp).max(0.0)` returns `0.0` when `t1` or `*lp` is `f64::NAN`, causing `margin <= p.max_margin` (`0.0 <= 0.25`) to evaluate to `true`!
* **Fix:**
  1. Before evaluating a step `kr`, check if any `(_, lp)` in `kr.topk` has `!lp.is_finite()`. If any logprob is `NaN` or `Infinite`, count the step as `poza_topk += 1` (`poza_lista.push(kr.indeks)`).
  2. Compute `top1_lp` as the maximum finite logprob across `kr.topk` (or sort a local copy of `kr.topk` descending by logprob using `total_cmp`) so unsorted `topk` inputs cannot falsify rank or margin.

### Fix D4: Fix Non-Object JSON Bypass & Enforce `budzet` in `crates/simon-core/src/cap.rs` (`Lines 91–180, 272–316`)
* **Bug:**
  1. In `waliduj()` (`cap.rs:97`), `let obj = parametry.as_object();` does not return `Err(Odmowa::ZlyTyp)` when `parametry` is not a JSON Object!
  2. In `sprawdz()` (`cap.rs:272-316`), `z.budzet` (`Option<i64>`) is never checked (even `Some(0)` or `Some(-5)` passes).
* **Fix:**
  1. Replace `let obj = parametry.as_object();` (`L97`) with:
     ```rust
     let Some(o) = parametry.as_object() else {
         return Err(Odmowa::ZlyTyp("parametry".to_string()));
     };
     ```
  2. In `sprawdz()`, if `let Some(b) = z.budzet { if b <= 0 { return Err(OdmowaZ::Wygaslo); } }`.

### Fix D5: Fix TOCTOU World-Readable Key Creation in `crates/simon-core/src/tozsamosc.rs` (`Lines 215–230`)
* **Bug:** `fs::File::create(&tymczasowy)` (`L221`) creates the secret key temp file with default `umask` (`0o644`), writes the plaintext secret key, and only calls `chmod 0o600` at `L228`.
* **Fix:** On `#[cfg(unix)]`, open `&tymczasowy` using `std::fs::OpenOptions::new().write(true).create(true).truncate(true).mode(0o600).open(&tymczasowy)`.

### Fix D6: Fix `ClientObservationV1::sign` Public Key Assignment (`crates/simon-core/src/obserwacja.rs:82-86`)
* **Bug:** `ClientObservationV1::sign` does not set `self.client_pubkey = klucz.public()` before calling `self.digest()?`.
* **Fix:** Add `self.client_pubkey = klucz.public();` on the first line of `ClientObservationV1::sign`.

### Fix D7: Fix Non-Monotonic Clock Token Minting in `Kubelek::zezwol` (`crates/simon-core/src/protokol.rs:90-101`)
* **Bug:** `self.ostatni_us = teraz_us;` overwrites `self.ostatni_us` even when `teraz_us < self.ostatni_us`, causing the next call to double-credit elapsed time.
* **Fix:** Only update `self.ostatni_us = teraz_us;` when `teraz_us > self.ostatni_us` (`self.ostatni_us = self.ostatni_us.max(teraz_us);`). Also fix `OknoNonce::przyjmij` (`L56`) to use `*n > granica` matching `L44`.

---

## Verification Commands
```bash
cargo test -p simon-core
cargo test -p simon-verify-wasm
```
