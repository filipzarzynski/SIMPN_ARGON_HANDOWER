# Track D — Fix All Core Security Vulnerabilities in `simon-core` & `simon-verify-wasm` (`PR-4`)

**Stage:** Stage 1 (Wave 1A — Urgent)  
**Target PR Base Branch:** `fz-contrib` (**NEVER** `main`)  
**Dedicated Track Branch:** `fz/track-D-core-security-hardening`  
**Dedicated Clone Subfolder:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/track_D`  
**Exclusive Permitted Files:**
* `crates/simon-core/src/receipt.rs`
* `crates/simon-core/src/m3.rs`
* `crates/simon-core/src/cap.rs`
* `crates/simon-core/src/web.rs`
* `crates/simon-core/src/tozsamosc.rs`
* `crates/simon-core/src/obserwacja.rs`
* `crates/simon-core/src/protokol.rs`
* `crates/simon-core/tests/tamper_matrix.rs`
* `crates/simon-verify-wasm/src/lib.rs`

*(100% file-disjoint from `simon-cli`, `simon-harness`, `simon-node`, `tools/`, and `ui/`!)*

---

## Step-by-Step Implementation Instructions (Commit Each Fix with `[FZ-D<N>]`)

### Fix D1 (`[FZ-D1]`): Require Valid Ed25519 Signature Inside `Receipt::zweryfikuj_m1` (`crates/simon-core/src/receipt.rs:299-330`) & `simon-verify-wasm` (`crates/simon-verify-wasm/src/lib.rs:131-174`)
* **Bug:** `Receipt::zweryfikuj_m1` only checks `self.wiazania` fields and **never calls `self.verify_self()`**! Consequently, both `Receipt::zweryfikuj_m1` and `simon_verify_wasm::weryfikuj_m1` return `Ok(())` / `{"ok": true}` for an unsigned (`signature: None`) or forged receipt!
* **Fix:**
  1. At the very top of `Receipt::zweryfikuj_m1` (`receipt.rs:306`), call `self.verify_self()?;`.
  2. Also verify `w.receipt_level >= RECEIPT_LEVEL_M1` and `w.schema_version == SCHEMA_VERSION_M1`.
  3. Update any existing test in `crates/simon-core/tests/tamper_matrix.rs` or `receipt.rs` that called `zweryfikuj_m1` on an unsigned `Receipt` so it signs the receipt first, AND add a dedicated test `zweryfikuj_m1_odrzuca_niepodpisany_receipt` in `crates/simon-core/tests/tamper_matrix.rs` and `crates/simon-verify-wasm/src/lib.rs` proving that `signature: None` is rejected.

### Fix D2 (`[FZ-D2]`): Fix SSRF / IPv6 Bypass in `crates/simon-core/src/web.rs` (`Lines 44–61, 88–96`)
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
  3. Add unit tests in `web.rs` for `::ffff:127.0.0.1`, `fc00::1`, `fe80::1`, `[::1]`, and `.example.com`.

### Fix D3 (`[FZ-D3]`): Fix IEEE-754 `f64::NAN` Bypass & Unsorted `topk` in `crates/simon-core/src/m3.rs` (`Lines 82–161`)
* **Bug:** `(t1 - *lp).max(0.0)` returns `0.0` when `t1` or `*lp` is `f64::NAN`, causing `margin <= p.max_margin` (`0.0 <= 0.25`) to evaluate to `true`!
* **Fix:**
  1. Before evaluating a step `kr`, check if any `(_, lp)` in `kr.topk` has `!lp.is_finite()`. If any logprob is `NaN` or `Infinite`, count the step as `poza_topk += 1` (`poza_lista.push(kr.indeks)`) and `continue`.
  2. Sort a local copy of `kr.topk` descending by logprob (`posortowane.sort_by(|a, b| b.1.total_cmp(&a.1))`) before computing `top1_lp`, `pozycja`, and `margin` so unsorted `topk` inputs cannot falsify rank or margin.
  3. Add unit tests in `m3.rs` verifying `f64::NAN` and unsorted `topk` handling.

### Fix D4 (`[FZ-D4]`): Fix Non-Object JSON Bypass & Enforce `budzet` in `crates/simon-core/src/cap.rs` (`Lines 91–180, 272–316`) + Harden `tozsamosc.rs`, `obserwacja.rs`, `protokol.rs`
* **Bug & Fix in `cap.rs`:**
  1. Replace `let obj = parametry.as_object();` (`L97`) with:
     ```rust
     let Some(o) = parametry.as_object() else {
         return Err(Odmowa::ZlyTyp("parametry".to_string()));
     };
     let obj = Some(o);
     ```
  2. In `sprawdz()` (`L272-316`), if `let Some(b) = z.budzet { if b <= 0 { return Err(OdmowaZ::Wygaslo); } }`.
* **Bug & Fix in `tozsamosc.rs` (`L215-230`):**
  * On `#[cfg(unix)]`, open `&tymczasowy` using `std::fs::OpenOptions::new().write(true).create(true).truncate(true).mode(0o600).open(&tymczasowy)` so secret keys are never briefly world-readable before `chmod`.
* **Bug & Fix in `obserwacja.rs` (`L82-86`):**
  * Add `self.client_pubkey = klucz.public();` on the first line of `ClientObservationV1::sign`.
* **Bug & Fix in `protokol.rs` (`L56, L90-101`):**
  * In `Kubelek::zezwol`, set `self.ostatni_us = self.ostatni_us.max(teraz_us);` so non-monotonic timestamps cannot mint extra tokens. In `OknoNonce::przyjmij` (`L56`), use `*n > granica` matching `L44`.

---

## Granular Commit Plan (Cherry-Pickable by Team Captain)
1. `[FZ-D1] fix(core,wasm): enforce Ed25519 signature verification inside Receipt::zweryfikuj_m1`
2. `[FZ-D2] fix(core): block IPv4-mapped IPv6, ULA, and link-local SSRF bypasses in web.rs`
3. `[FZ-D3] fix(core): reject NaN/Inf logprobs and sort topk descending in m3::ocena`
4. `[FZ-D4] fix(core): harden cap.rs JSON object check, tozsamosc 0600 file creation, obserwacja sign, and protokol clock`

---

## Verification & PR Delivery
```bash
bash .agents/skills/simon-verify-suite/scripts/verify_track.sh D --final
python3 .agents/skills/simon-pr-delivery/scripts/prepare_and_create_pr.py --track D
```
