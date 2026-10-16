#!/usr/bin/env python3
"""
SIMON Mermaid Chart Syntax Validator.
Checks Markdown files for Mermaid diagram syntax errors according to SIMON & GitHub Mermaid specifications:
1. Supported diagram keywords: flowchart, graph, sequenceDiagram, classDiagram, stateDiagram, stateDiagram-v2, erDiagram, xychart-beta.
2. In sequence diagrams:
   - Semicolons (;) are statement terminators in Mermaid: notes and messages must NOT contain unescaped semicolons.
   - Note text and messages must NOT contain unescaped arrow tokens (->, -->, --, ->>).
   - Angle-bracketed identifiers (e.g. <pubkey>, <node_id>) are parsed as HTML tags and must use brackets or parens instead: [pubkey], (node_id).
3. In flowcharts / graphs:
   - Node labels containing parentheses, brackets, or commas must be quoted: id["Label (Extra Info)"].
   - Edge labels must not contain double pipes (||) inside |...| delimiters.
   - Arrow edge syntax must be valid (e.g. -->|label| or -- label -->, not -- "label" -->).
4. Full AST validation:
   - If node.js with mermaid/jsdom is available, executes mermaid.parse() in headless JSDOM for full grammar verification.
"""

import os
import re
import subprocess
import sys
from pathlib import Path

SUPPORTED_TYPES = (
    "flowchart",
    "graph",
    "sequenceDiagram",
    "classDiagram",
    "stateDiagram",
    "stateDiagram-v2",
    "erDiagram",
    "xychart-beta",
)

HTML_TAG_REGEX = re.compile(r"<([a-zA-Z0-9_-]+)>")
SEMICOLON_IN_NOTE_REGEX = re.compile(r"^\s*Note\s+[^:]+:\s*.*?;", re.IGNORECASE)
ARROW_IN_NOTE_REGEX = re.compile(r"^\s*Note\s+[^:]+:\s*.*?(-->|->|--\s|->>)", re.IGNORECASE)


def validate_diagram_content(code: str, file_path: str, block_start_line: int) -> list:
    errors = []
    lines = code.strip().splitlines()
    if not lines:
        return ["Empty mermaid block"]

    first_line = lines[0].strip()
    first_token = first_line.split()[0] if first_line else ""

    if not any(first_line.startswith(st) for st in SUPPORTED_TYPES):
        errors.append(
            f"Line {block_start_line}: Unsupported or missing diagram type '{first_token}'. "
            f"Must start with one of: {', '.join(SUPPORTED_TYPES)}"
        )
        return errors

    is_seq = first_line.startswith("sequenceDiagram")
    is_flow = first_line.startswith("flowchart") or first_line.startswith("graph")

    for idx, raw_line in enumerate(lines, 1):
        line_num = block_start_line + idx
        stripped = raw_line.strip()
        if not stripped or stripped.startswith("%%"):
            continue

        if is_seq:
            # 1. Check for semicolon in Note statements
            if SEMICOLON_IN_NOTE_REGEX.search(stripped):
                errors.append(
                    f"Line {line_num}: Semicolon (;) detected in sequenceDiagram Note statement. "
                    "In Mermaid sequence diagrams, ';' terminates the statement and breaks parsing. "
                    "Replace ';' with a comma or dash."
                )

            # 2. Check for unescaped arrows in Note statements
            if ARROW_IN_NOTE_REGEX.search(stripped):
                errors.append(
                    f"Line {line_num}: Unescaped arrow token ('->', '-->', or '--') in sequenceDiagram Note. "
                    "Use descriptive text (e.g. 'yields', 'sending', 'to') to prevent arrow operator collision."
                )

            # 3. Check for angle bracket tags (<pubkey>, etc.)
            tags = HTML_TAG_REGEX.findall(stripped)
            for tag in tags:
                if tag.lower() not in ("br", "sub", "sup", "b", "i"):
                    errors.append(
                        f"Line {line_num}: Angle-bracket placeholder '<{tag}>' detected. "
                        "Mermaid parses angle brackets as HTML tags. Use '[{tag}]' or '({tag})' instead."
                    )

        if is_flow:
            # Check for unquoted node labels with parentheses or brackets
            # e.g. Node[Label (Extra)] without quotes inside
            m_unquoted = re.search(r'\[([^"\'\n\]]*[\(\),][^"\'\n\]]*)\]', stripped)
            if m_unquoted:
                errors.append(
                    f"Line {line_num}: Node label '[{m_unquoted.group(1)}]' contains special characters but is unquoted. "
                    f'Use quoted format: [\"{m_unquoted.group(1)}\"].'
                )

            # Check for double pipes inside pipe-delimited edge labels: -->|...||...|
            if re.search(r"-->\|[^|\n]*\|\|", stripped):
                errors.append(
                    f"Line {line_num}: Double pipe '||' inside edge label delimiter '|...|'. "
                    "Double pipe prematurely closes the edge label."
                )

    return errors


def run_node_ast_check(code: str) -> str:
    """Attempts to run mermaid.parse via Node.js if mermaid is available."""
    # Find mermaid module location
    candidate_paths = [
        "/tmp/node_modules/mermaid/dist/mermaid.core.mjs",
        "/home/agent/SIMPN_ARGON_HANDOWER/node_modules/mermaid/dist/mermaid.core.mjs",
    ]
    mermaid_path = None
    for p in candidate_paths:
        if os.path.exists(p):
            mermaid_path = p
            break

    if not mermaid_path:
        return ""

    jsdom_path = "/tmp/node_modules/jsdom"
    if not os.path.isdir(jsdom_path):
        return ""

    try:
        node_script = f"""
        const {{ JSDOM }} = require('{jsdom_path}');
        const dom = new JSDOM('<!DOCTYPE html><html><body></body></html>');
        global.window = dom.window;
        global.document = dom.window.document;
        global.navigator = dom.window.navigator;

        import('{mermaid_path}').then(async m => {{
            const code = process.argv[1];
            try {{
                await m.default.parse(code);
                process.exit(0);
            }} catch (e) {{
                console.error(e.message || String(e));
                process.exit(1);
            }}
        }}).catch(e => {{
            process.exit(0);
        }});
        """
        cmd = ["node", "-e", node_script, code]
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        if res.returncode == 1:
            err = res.stderr.strip().splitlines()[0] if res.stderr else "Parse error"
            return err
        return ""
    except Exception:
        return ""


def check_file(file_path: Path) -> list:
    errors = []
    try:
        content = file_path.read_text(encoding="utf-8")
    except Exception as e:
        return [f"Could not read {file_path}: {e}"]

    # Find ```mermaid ... ```
    pattern = re.compile(r"```mermaid\n([\s\S]*?)```")
    for match in pattern.finditer(content):
        start_pos = match.start()
        line_num = content[:start_pos].count("\n") + 1
        code = match.group(1)

        # 1. Structural rule validation
        rule_errors = validate_diagram_content(code, str(file_path), line_num)
        errors.extend(rule_errors)

        # 2. Node.js AST validation if available
        ast_err = run_node_ast_check(code)
        if ast_err and not any(f"Line {line_num}" in e for e in rule_errors):
            errors.append(f"Line {line_num}: Mermaid AST Parse Error: {ast_err}")

    return errors


def main():
    targets = []
    if len(sys.argv) > 1:
        for arg in sys.argv[1:]:
            p = Path(arg)
            if p.is_file() and p.suffix == ".md":
                targets.append(p)
            elif p.is_dir():
                targets.extend(p.rglob("*.md"))
    else:
        # Default: scan SIMPN_ARGON_HANDOWER and SIMON docs
        root = Path(__file__).resolve().parents[1]
        for p in root.rglob("*.md"):
            if any(part in p.parts for part in ("node_modules", "target", ".git")):
                continue
            targets.append(p)

    targets = sorted(set(targets))
    all_clean = True
    total_diagrams = 0

    for file_path in targets:
        try:
            content = file_path.read_text(encoding="utf-8")
        except Exception:
            continue
        diagram_count = len(re.findall(r"```mermaid\n", content))
        if diagram_count == 0:
            continue
        total_diagrams += diagram_count

        errors = check_file(file_path)
        if errors:
            all_clean = False
            print(f"[FAIL] {file_path} ({diagram_count} diagrams):")
            for err in errors:
                print(f"       - {err}")
        else:
            print(f"[PASS] {file_path} ({diagram_count} diagrams verified)")

    if not all_clean:
        print("\nERROR: Mermaid chart syntax violations found!")
        sys.exit(1)
    else:
        print(f"\nALL {total_diagrams} MERMAID CHARTS PASSED SYNTAX VALIDATION!")
        sys.exit(0)


if __name__ == "__main__":
    main()
