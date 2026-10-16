---
name: simon-mermaid-validator
description: >-
  Mandatory Mermaid diagram syntax rules, linting, and pre-commit verification
  for all SIMON documentation, architecture specs, and team briefs across all tracks.
---

# SIMON Mermaid Diagram Guardrails & Pre-Commit Verification (`simon-mermaid-validator`)

Activate this skill on **EVERY track** whenever editing, adding, or reviewing Markdown documentation containing Mermaid diagrams (e.g. `docs/ARCHITECTURE.md`, `01_ARCHITECTURE_AND_DATA_FLOWS.md`, `08_TEAM_SYNC_ARCHITECTURE_AND_WAVE_BRIEF.md`, `ROADMAP.md`, `README.md`).

---

## 1. Governing Rules for Mermaid Diagrams

Mermaid diagrams render in GitHub, GitLab, VS Code, and browser UI documentation. However, subtle syntax differences between renderers cause silent rendering failures or parse errors. Follow these strict rules:

### Rule 1: Sequence Diagrams — No Semicolons in Notes or Messages
- **Why**: In Mermaid `sequenceDiagram`, the semicolon `;` acts as a statement delimiter.
- **DO NOT**:
  - `Note over Node: Check replay ring; check rate limit; acquire semaphores`
- **DO**:
  - Use commas or dashes: `Note over Node: Check replay ring, check rate limit, acquire semaphores`

### Rule 2: Sequence Diagrams — No Embedded Arrow Tokens in Notes or Messages
- **Why**: Suffixes or words like `->`, `-->`, `--`, `->>` inside Note text are parsed as message transmission arrows, confusing participant matching.
- **DO NOT**:
  - `Note over Agent: verify_self() + zweryfikuj_m1(order.nonce) -> reports proof level`
- **DO**:
  - Use descriptive words: `Note over Agent: verify_self() + zweryfikuj_m1(order.nonce) yields proof level`

### Rule 3: Sequence Diagrams — No Angle Bracket Tag Placeholders
- **Why**: Unescaped angle brackets (`<pubkey>`, `<node_id>`) are treated as HTML tags. Unknown or unclosed tags cause parser crashes.
- **DO NOT**:
  - `Client->>Agent: Spawn subprocess with --expect-signer <pubkey>`
- **DO**:
  - Use brackets or parentheses: `Client->>Agent: Spawn subprocess with --expect-signer [pubkey]`

### Rule 4: Flowcharts — Always Quote Labels Containing Special Characters
- **Why**: Parentheses `()`, square brackets `[]`, braces `{}`, or commas `,` inside unquoted flowchart node labels break node shape parsing.
- **DO NOT**:
  - `Node1[Plant Node 1 (RTX 3090, 24 GB)]`
- **DO**:
  - Always quote the label: `Node1["Plant Node 1 (RTX 3090, 24 GB)"]`

### Rule 5: Flowcharts — No Double Pipes in Edge Labels
- **Why**: Mermaid flowcharts delimit edge text with pipes: `A -->|label| B`. Including double pipes (`||`) immediately terminates the edge label, leaving trailing text as a syntax error.
- **DO NOT**:
  - `A -->|"SHA256(DOMAIN || 0x00 || bytes)"| B`
- **DO**:
  - `A -->|"SHA256(DOMAIN + 0x00 + bytes)"| B`

### Rule 6: Supported Diagram Types Only
Use only standard, widely supported Mermaid diagram types:
- `flowchart TD` / `flowchart TB` / `flowchart LR` / `flowchart RL`
- `sequenceDiagram`
- `stateDiagram-v2` / `stateDiagram`
- `classDiagram`
- `erDiagram`
- `xychart-beta`

---

## 2. Pre-Commit Verification Commands

Before staging any markdown commit containing Mermaid diagrams, run:

```bash
# 1. Validate all mermaid diagrams in changed files
python3 /home/agent/SIMPN_ARGON_HANDOWER/scripts/check_mermaid.py <changed_markdown_files...>

# 2. Or validate all markdown files across the entire workspace
python3 /home/agent/SIMPN_ARGON_HANDOWER/scripts/check_mermaid.py
```

The script performs both rule-based structural checks and full AST parsing via headless Node.js `mermaid.parse()`.
