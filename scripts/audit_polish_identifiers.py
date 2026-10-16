#!/usr/bin/env python3
"""
SIMON Codebase-Wide Polish Identifier & Text Scanner (Special Task Track Helper)

Scans Rust, Python, TypeScript/Svelte, and shell files for Polish filenames,
identifiers, diacritics, and comments, and prints a dependency-ordered report
for iterative atomic refactoring on the `language-cleanup` branch.
"""

import argparse
import re
import subprocess
import sys
from pathlib import Path

POLISH_DIACRITICS_RE = re.compile(r"[ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]")

KNOWN_POLISH_IDENTIFIERS = [
    "tozsamosc", "TozsamoscWezla", "wczytaj_lub_stworz", "zapisz_z_uprawnieniami_0600",
    "WiazaniaM1", "wiazania", "z_wiazaniem_m1", "zweryfikuj_m1", "zgodny_z_wyjsciem",
    "podpisal_oczekiwany", "poziom", "odcisk_wyjscia", "odcisk_tokenizera",
    "odcisk_promptu", "lancuch_tokenow", "odcisk_probkowania",
    "Sufit", "SchematParametru", "TypParametru", "Zezwolenie", "OdwolaneZezwolenia",
    "odcisk_parametrow", "sprawdz_argumenty", "zweryfikuj_i_zuzyj",
    "KomorkaLogprob", "KrokLogprob", "AudytWykonania", "WerdyktM3", "ProgM3", "ocena",
    "protokol", "Kubelek", "RejestrPowtorek", "pomiar", "obserwacja", "limity",
    "przeplyw", "rejestr", "RekordPracyV1", "StatusWeryfikacji",
    "sprawdz_url_bezpieczny", "sprawdz_ip_publiczne",
    "weryfikuj_receipt", "weryfikuj_m1", "weryfikuj_m3",
    "Autoryzacja", "RejestrZuzytychAutoryzacji", "zweryfikuj_autoryzacje",
    "podpis_zgadza_sie", "zajmij",
    "kandydaci_dla_modelu", "wybierz_kandydata_vrf",
    "wspolne", "Zachowanie", "ZachowanieEvent", "zbuduj_swarm", "wypisz_adresy",
    "wyciagnij_id_tokenow", "tokenizuj_tekst", "domyslny_odcisk_tokenizera",
    "uruchom", "obsluz", "policz", "wyjscie", "odczytaj_moje_fakty",
    "wykryj_runtime", "wykryj_precyzje_z_nazwy_modelu", "zbuduj_podpisany_receipt",
    "limit_peera", "obsluz_odpowiedz", "zweryfikuj_receipt", "poziom_sprawdzony",
    "wyodrebnij_output", "obsluz_rejestracje", "obsluz_wynik", "przetworz_zlecenie",
    "obsluz_zlecenie", "wartownik_stalych", "_znormalizuj",
]


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit Polish identifiers and strings across SIMON.")
    parser.add_argument("repo", nargs="?", default=".", help="Path to SIMON repository root")
    parser.add_argument("--symbol", help="Grep all occurrences of a single Polish symbol across the repo")
    parser.add_argument("--verify-zero", action="store_true", help="Exit non-zero if any Polish code identifiers remain")
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    if not (repo / ".git").exists():
        print(f"ERROR: {repo} is not a git repository.", file=sys.stderr)
        return 1

    if args.symbol:
        res = subprocess.run(
            ["git", "-C", str(repo), "grep", "-n", args.symbol],
            capture_output=True,
            text=True,
        )
        print(res.stdout or f"Zero occurrences of '{args.symbol}' found.")
        return 0

    tracked = subprocess.run(
        ["git", "-C", str(repo), "ls-files"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.splitlines()

    code_exts = {".rs", ".py", ".ts", ".svelte", ".sh"}
    symbol_counts: dict[str, int] = {sym: 0 for sym in KNOWN_POLISH_IDENTIFIERS}
    diacritic_files: list[tuple[str, int]] = []

    for rel in tracked:
        p = repo / rel
        if not p.is_file() or p.suffix not in code_exts:
            continue
        try:
            text = p.read_text(encoding="utf-8")
        except Exception:
            continue

        d_lines = sum(1 for line in text.splitlines() if POLISH_DIACRITICS_RE.search(line))
        if d_lines > 0:
            diacritic_files.append((rel, d_lines))

        for sym in KNOWN_POLISH_IDENTIFIERS:
            if re.search(rf"\b{re.escape(sym)}\b", text):
                symbol_counts[sym] += 1

    active_symbols = [(sym, cnt) for sym, cnt in symbol_counts.items() if cnt > 0]

    print("================================================================================")
    print(f" SIMON Polish-to-English Unification Audit ({repo})")
    print("================================================================================")
    print(f" Code files with Polish diacritics (comments/strings): {len(diacritic_files)}")
    print(f" Tracked Polish code identifiers still present        : {len(active_symbols)} / {len(KNOWN_POLISH_IDENTIFIERS)}")
    print("--------------------------------------------------------------------------------")
    for sym, cnt in active_symbols:
        print(f"  - {sym:<34} : referenced in {cnt:>2} code file(s)")
    print("================================================================================")

    if args.verify_zero and (active_symbols or diacritic_files):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
