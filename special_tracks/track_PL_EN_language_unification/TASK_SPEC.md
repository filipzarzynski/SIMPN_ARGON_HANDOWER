# Special Task Track: Codebase-Wide Polish $\rightarrow$ English Unification (`language-cleanup`)

> [!CAUTION]
> **CODE FREEZE REQUIRED — DO NOT RUN DURING ACTIVE PARALLEL WAVES (`fz-contrib`)!**  
> This Special Task Track renames Polish filenames, modules, structs, functions, variables, CLI error codes, comments, and documentation references across the **entire repository** (`crates/`, `tools/`, `ui/`, `demo/`, `scripts/`, `docs/`).  
> It is **strictly independent** of Stages 1–4 and `fz-contrib`. Execute this track **ONLY** after all active `fz-contrib` stages have been merged into `main` and the Team Captain declares a **temporary repository-wide Code Freeze**.

---

## 0. Track Metadata & Isolation Rules

* **Track ID:** `SPECIAL-LANG` (`[LANG-01]` .. `[LANG-12]`)
* **Execution Window:** Temporary Code Freeze on `Szpili/SIMON` (zero active feature branches in flight)
* **Base Branch:** `upstream/main` (branches **directly from `main`**, NOT `fz-contrib`)
* **Target Branch:** `language-cleanup`
* **Dedicated Workspace Clone:** `/home/agent/SIMPN_ARGON_HANDOWER/workspaces/special_language_cleanup`
* **Scanner & Audit Tool:** `python3 /home/agent/SIMPN_ARGON_HANDOWER/scripts/audit_polish_identifiers.py`

---

## 1. Golden Rules for Non-Breaking Iterative Language Unification

### Rule 1: One Symbol / Module Group per Commit (Never Blind Bulk-Replace)
For each rename unit:
1. Run `python3 /home/agent/SIMPN_ARGON_HANDOWER/scripts/audit_polish_identifiers.py` and `git grep -n "<polish_symbol>"` across the **entire repository** (`crates/`, `tools/`, `ui/`, `demo/`, `scripts/`, `docs/`) AND `/home/agent/SIMPN_ARGON_HANDOWER`.
2. Update the definition and every call site, import, test, Python script, Svelte UI binding, and Markdown doc reference for that symbol.
3. Run the full verification gate (`cargo test --workspace && cargo clippy --workspace --all-targets -- -D warnings && bash scripts/verify_all_fast.sh`) **before** committing.
4. Commit as a single, self-contained, non-breaking commit (`[LANG-XX] refactor(...): rename <polish> -> <english> across codebase`) so every commit on `language-cleanup` compiles and passes 100% of tests.

### Rule 2: Preserve Cryptographic & Wire Compatibility (`#[serde(alias = "...")]`)
Committed JSON/JSONL artifacts (`ui/src/lib/industry-run.json`, `docs/amd-data/*.json`, `docs/industry/*.jsonl`, `docs/verifier-data/*.json`) contain **real Ed25519 signatures** computed over canonical JSON digests!
* **DO NOT** alter the canonical JSON hash keys inside `Receipt::digest()`, `WiazaniaM1`, `Zezwolenie::digest()`, `Autoryzacja::digest()`, or `RekordPracyV1` unless you re-sign or preserve wire names via `#[serde(rename = "...", alias = "...")]`:
  - Example: In `Receipt`, keep `#[serde(rename = "wiazania", alias = "bindings", default, skip_serializing_if = "Option::is_none")] pub bindings: Option<M1Bindings>` so existing signed receipts in `industry-run.json` and `c1_concurrency_*.json` continue to verify without breaking a single Ed25519 signature!
  - Example: In `agent.rs` stdout JSON (`receipt_zweryfikowany`, `poziom_dowodu`), either emit **both** keys (`"receipt_verified": ..., "receipt_zweryfikowany": ..., "proof_level": ..., "poziom_dowodu": ...`) during transition or update `agent.rs`, `simon_api.py`, `tickets.py`, `agent_triage.py`, and `demo/app.en.py` in the **same atomic commit**!

### Rule 3: Bottom-Up Crate Dependency Order
Always rename in strict dependency order so downstream crates see the updated exports immediately:
1. `crates/simon-core` (leaf crate)
2. `crates/simon-verify-wasm` (depends on `simon-core`)
3. `crates/simon-harness` (depends on `simon-core`)
4. `crates/simon-node` (depends on `simon-core`)
5. `crates/simon-cli` (depends on `simon-core`, `simon-harness`, `simon-node`)
6. `tools/`, `scripts/`, `demo/`, `ui/`
7. `docs/` and `/home/agent/SIMPN_ARGON_HANDOWER`

---

## 2. Canonical Polish $\rightarrow$ English Identifier Mapping Inventory

### Phase A: `crates/simon-core` Modules, Types & Functions (`[LANG-01]` .. `[LANG-04]`)

| Current File / Symbol (Polish) | Target File / Symbol (English) | Notes & Compatibility Guardrails |
| :--- | :--- | :--- |
| `src/tozsamosc.rs` | `src/identity.rs` | Re-export `pub use identity as tozsamosc;` temporarily until `[LANG-08]` removes aliases |
| `TozsamoscWezla`, `wczytaj_lub_stworz`, `zapisz_z_uprawnieniami_0600` | `NodeIdentity`, `load_or_create`, `write_mode_0600` | Used in `simon-core`, `simon-cli/src/agent.rs`, `simon-cli/src/node.rs` |
| `src/receipt.rs`: `WiazaniaM1`, `z_wiazaniem_m1`, `zweryfikuj_m1`, `zgodny_z_wyjsciem`, `podpisal_oczekiwany`, `poziom`, `odcisk_wyjscia`, `odcisk_tokenizera`, `odcisk_promptu`, `lancuch_tokenow`, `odcisk_probkowania` | `M1Bindings`, `with_m1_bindings`, `verify_m1`, `matches_output`, `signed_by_expected`, `level`, `output_digest_for`, `tokenizer_digest`, `prompt_digest`, `token_chain_digest`, `sampling_digest` | Keep `#[serde(rename = "wiazania", alias = "bindings")]` on `Receipt::bindings` so committed signed receipts verify |
| `src/cap.rs`: `Sufit`, `SchematParametru`, `TypParametru`, `Zezwolenie`, `OdwolaneZezwolenia`, `odcisk_parametrow`, `sprawdz_argumenty`, `zweryfikuj_i_zuzyj` | `CapabilityCeiling`, `ParamSchema`, `ParamType`, `CapabilityGrant`, `RevokedGrants`, `params_digest`, `validate_args`, `verify_and_consume` | Keep `"domena": "SIMON/GRANT/v1"` and `"SIMON/GRANT-PARAMS/v1"` unchanged |
| `src/m3.rs`: `KomorkaLogprob`, `KrokLogprob`, `AudytWykonania`, `WerdyktM3`, `ProgM3`, `ocena` | `LogprobCell`, `LogprobStep`, `ExecutionAudit`, `M3Verdict`, `M3Threshold`, `evaluate_m3` | Keep JSON field names (`simulated`, `steps`, `top_k`) unchanged |
| `src/protokol.rs`: `Kubelek`, `RejestrPowtorek` | `src/protocol.rs`: `TokenBucket`, `ReplayRing` | Used in `simon-cli/src/node.rs` |
| `src/pomiar.rs`, `src/obserwacja.rs`, `src/limity.rs`, `src/przeplyw.rs`, `src/rejestr.rs` | `src/measurement.rs`, `src/observation.rs`, `src/limits.rs`, `src/flow.rs`, `src/registry.rs` | Rename `RekordPracyV1` $\rightarrow$ `WorkRecordV1`, `StatusWeryfikacji` $\rightarrow$ `VerificationStatus` |
| `src/web.rs`: `sprawdz_url_bezpieczny`, `sprawdz_ip_publiczne` | `validate_safe_url`, `validate_public_ip` | Update tests in `crates/simon-core/src/web.rs` |

### Phase B: `crates/simon-verify-wasm`, `crates/simon-harness`, `crates/simon-node` (`[LANG-05]` .. `[LANG-07]`)

| Current File / Symbol (Polish) | Target File / Symbol (English) | Notes & Compatibility Guardrails |
| :--- | :--- | :--- |
| `crates/simon-verify-wasm/src/lib.rs`: `weryfikuj_receipt`, `weryfikuj_m1`, `weryfikuj_m3` | `verify_receipt`, `verify_m1`, `verify_m3` | Keep `#[wasm_bindgen]` aliases or update `ui/src/lib/verify.ts` in the same commit |
| `crates/simon-harness/src/client_protocol.rs`: `Autoryzacja`, `RejestrZuzytychAutoryzacji`, `zweryfikuj_autoryzacje`, `podpis_zgadza_sie`, `zajmij` | `OrderAuthorization`, `SpentAuthorizationRegistry`, `verify_authorization`, ` verify_signature`, `consume` | Keep `"domena"` digest fields unchanged |
| `crates/simon-harness/src/request_response.rs`: `PromptReply::Blad` | `PromptReply::Error` | Keep serde variant or update `agent.rs` and `node.rs` together |
| `crates/simon-node/src/lib.rs`: `kandydaci_dla_modelu`, `wybierz_kandydata_vrf` | `candidates_for_model`, `select_candidate_vrf` | Update `coord.rs` and `simon-node/tests/` in the same commit |

### Phase C: `crates/simon-cli` (`wspolne.rs`, `node.rs`, `agent.rs`, `coord.rs`, `mapreduce.rs`, `main.rs`) (`[LANG-08]` .. `[LANG-10]`)

| Current File / Symbol (Polish) | Target File / Symbol (English) | Notes & Compatibility Guardrails |
| :--- | :--- | :--- |
| `src/wspolne.rs`: `Zachowanie`, `ZachowanieEvent`, `zbuduj_swarm`, `wypisz_adresy`, `wyciagnij_id_tokenow`, `tokenizuj_tekst`, `domyslny_odcisk_tokenizera` | `src/common.rs`: `SwarmBehaviour`, `SwarmBehaviourEvent`, `build_swarm`, `print_listen_addrs`, `extract_token_ids`, `tokenize_text`, `default_tokenizer_digest` | Update `main.rs`, `node.rs`, `agent.rs`, `coord.rs`, and `tests/e2e_m1_receipt.rs` |
| `src/node.rs`: `uruchom`, `obsluz`, `policz`, `wyjscie`, `odczytaj_moje_fakty`, `wykryj_runtime`, `wykryj_precyzje_z_nazwy_modelu`, `zbuduj_podpisany_receipt`, `limit_peera` | `run`, `handle_request`, `compute_completion`, `extract_output`, `probe_backend_facts`, `detect_runtime`, `detect_precision_from_model_name`, `build_signed_receipt`, `check_peer_limits` | Update all tests in `node.rs` and `tests/e2e_m1_receipt.rs` |
| `src/agent.rs`: `uruchom`, `obsluz_odpowiedz`, `zweryfikuj_receipt`, `poziom_sprawdzony`, `wyodrebnij_output` | `run`, `handle_response`, `verify_receipt`, `verified_proof_level`, `extract_output` | Emit both new English and legacy Polish JSON keys (`receipt_verified` + `receipt_zweryfikowany`, `proof_level` + `poziom_dowodu`) or update `simon_api.py` + `tickets.py` + `agent_triage.py` in lockstep |
| `src/coord.rs`: `uruchom`, `obsluz_rejestracje`, `obsluz_wynik`, `przetworz_zlecenie`, `obsluz_zlecenie` | `run`, `handle_registration`, `handle_job_result`, `process_job_order`, `handle_job_order` | Update `docs/STRESS-TESTS.md` test references in lockstep |

### Phase D: Python Tools, Scripts, UI, Docs & Handover Sync (`[LANG-11]` .. `[LANG-12]`)

| Current File / Symbol (Polish) | Target File / Symbol (English) | Notes & Compatibility Guardrails |
| :--- | :--- | :--- |
| `scripts/wartownik_stalych.py` | `scripts/constant_guard.py` (keep thin wrapper `scripts/wartownik_stalych.py` calling `constant_guard.py` so CI scripts never break) | Update `scripts/verify_all_fast.sh` and `.github/workflows/` |
| `tools/simon-industry/agent_triage.py` & `tickets.py`: `_znormalizuj` | `_normalize_text` | Run `--selfcheck` on both files |
| `ui/src/routes/demo/+page.svelte`: `ZADANIE_M0`, `ZADANIE_M1`, `poziom` | `FIXTURE_M0`, `FIXTURE_M1`, `level` | Run `npm --prefix ui run check` |
| Polish comments, docstrings, and error messages across `crates/`, `tools/`, `docs/` | Clear, concise technical English | Run `python3 /home/agent/SIMPN_ARGON_HANDOWER/scripts/audit_polish_identifiers.py --verify-zero` |

---

## 3. Step-by-Step Execution Commands (During Code Freeze Only)

```bash
# 1. Initialize isolated language-cleanup workspace directly from upstream/main
export PATH="/home/agent/.cargo/bin:/home/agent/.local/bin:/usr/local/bin:$PATH"
git clone git@github.com:Szpili/SIMON.git /home/agent/SIMPN_ARGON_HANDOWER/workspaces/special_language_cleanup
cd /home/agent/SIMPN_ARGON_HANDOWER/workspaces/special_language_cleanup
git remote add fork git@github.com:filipzarzynski/SIMON.git
git checkout -b language-cleanup origin/main

# 2. Run the Polish identifier scanner to view remaining Polish symbols per crate/file
python3 /home/agent/SIMPN_ARGON_HANDOWER/scripts/audit_polish_identifiers.py .

# 3. After each atomic [LANG-XX] commit, run the full verification gate:
bash scripts/verify_all_fast.sh
python3 /home/agent/SIMPN_ARGON_HANDOWER/scripts/check_mermaid.py

# 4. Once all [LANG-01..12] commits pass and audit_polish_identifiers.py reports clean:
git push -u fork language-cleanup
gh pr create --repo Szpili/SIMON --base main --head filipzarzynski:language-cleanup \
  --title "[LANG] refactor: codebase-wide Polish-to-English identifier and documentation unification"
```
