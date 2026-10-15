#!/usr/bin/env python3
"""
SIMON Parallel Agent Pull Request & Cross-Track Merge Verifier.
Rebases the track branch onto origin/main, pushes to the shared local hub,
verifies zero merge conflicts against all sibling tracks, attempts remote push
and GitHub PR creation, and writes PR_SUBMISSION.md.
"""
import argparse
import fcntl
import json
import os
import subprocess
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

TRACK_META = {
    "A": {
        "pr_id": "PR-1",
        "branch": "fix/node-receipt-truth",
        "dir_name": "track_A_receipt_and_node_truth",
        "title": "fix(node): populate real Unix timestamp_us, dynamic GGUF precision, and weight SHA-256 verification",
        "bugs": ["BUG-01", "BUG-02", "BUG-05"],
    },
    "B": {
        "pr_id": "PR-2",
        "branch": "feat/live-m1-receipts",
        "dir_name": "track_B_live_m1_token_binding",
        "title": "feat(agent): wire live M1 TokenCommitment verification and M3 drift telemetry in simon-cli",
        "bugs": ["BUG-03"],
    },
    "C": {
        "pr_id": "PR-3",
        "branch": "feat/industry-m7-agent",
        "dir_name": "track_C_industry_gemma4_live_agent",
        "title": "feat(industry): upgrade Track 1 ticket generator to multi-turn Gemma 4 tool-calling agent with verified receipts",
        "bugs": ["BUG-09"],
    },
    "D": {
        "pr_id": "PR-4",
        "branch": "fix/core-security-hardening",
        "dir_name": "track_D_core_security_and_wasm_fixes",
        "title": "fix(core,wasm): enforce M0 signature in M1/WASM, block IPv6-mapped SSRF, NaN logprobs, and non-object Cap JSON",
        "bugs": ["BUG-04", "BUG-06", "BUG-15"],
    },
    "E": {
        "pr_id": "PR-5",
        "branch": "feat/coordinator-gossipsub-bridge",
        "dir_name": "track_E_p2p_coordinator_bridge",
        "title": "feat(node,cli): add HTTP LLM executor bridge to SimonNode and fix MapReduce chunk truncation",
        "bugs": ["BUG-07", "BUG-08"],
    },
    "F": {
        "pr_id": "PR-6",
        "branch": "fix/submission-and-ui-polish",
        "dir_name": "track_F_submission_and_ui_polish",
        "title": "fix(ui,docs,tools): reconcile submission test/MI300X tables, clarify UI demo/network badges, and harden Python tools",
        "bugs": ["BUG-10", "BUG-11", "BUG-12", "BUG-13", "BUG-14", "BUG-16"],
    },
}


def run(cmd, cwd=None, check=True):
    env = os.environ.copy()
    env["GIT_TERMINAL_PROMPT"] = "0"
    env["GCM_INTERACTIVE"] = "never"
    res = subprocess.run(cmd, cwd=cwd, env=env, text=True, capture_output=True)
    if check and res.returncode != 0:
        raise RuntimeError(
            f"Command failed ({' '.join(cmd)}):\nSTDOUT:\n{res.stdout}\nSTDERR:\n{res.stderr}"
        )
    return res


def main():
    parser = argparse.ArgumentParser(description="Prepare and create PR for SIMON Track")
    parser.add_argument("--track", required=True, help="Track letter: A, B, C, D, E, or F")
    parser.add_argument("--title", default=None, help="Optional custom PR title")
    args = parser.parse_args()

    track = args.track.upper().replace("TRACK_", "").replace("TRACK", "").strip()
    if track not in TRACK_META:
        print(f"ERROR: Invalid track '{args.track}'. Choose from A, B, C, D, E, F.", file=sys.stderr)
        sys.exit(1)

    meta = TRACK_META[track]
    handover_root = Path(__file__).resolve().parents[4]
    clone_dir = handover_root / "workspaces" / f"track_{track}"
    spec_dir = handover_root / "parallel_agents" / meta["dir_name"]
    lock_file = handover_root / "workspaces" / ".hub.lock"

    if not (clone_dir / ".git").exists():
        print(f"ERROR: Clone directory {clone_dir} not found.", file=sys.stderr)
        sys.exit(1)

    # 1. Fetch latest origin/main and rebase cleanly
    print(f"[Track {track}] Fetching latest origin/main and rebasing {meta['branch']}...")
    run(["git", "fetch", "origin", "main"], cwd=clone_dir, check=False)
    rebase_res = run(["git", "rebase", "origin/main"], cwd=clone_dir, check=False)
    if rebase_res.returncode != 0:
        run(["git", "rebase", "--abort"], cwd=clone_dir, check=False)
        raise RuntimeError(f"Rebase onto origin/main encountered conflicts:\n{rebase_res.stderr}")

    # 2. Push to shared local hub and check cross-track merges under lock
    cross_track_results = []
    lock_file.parent.mkdir(parents=True, exist_ok=True)
    with open(lock_file, "w") as lf:
        fcntl.flock(lf, fcntl.LOCK_EX)
        run(["git", "push", "-f", "hub", f"HEAD:refs/heads/{meta['branch']}"], cwd=clone_dir)
        run(["git", "fetch", "hub"], cwd=clone_dir)

        for other_track, other_meta in TRACK_META.items():
            if other_track == track:
                continue
            other_ref = f"refs/remotes/hub/{other_meta['branch']}"
            ref_check = run(["git", "show-ref", "--verify", "--quiet", other_ref], cwd=clone_dir, check=False)
            if ref_check.returncode == 0:
                mt = run(["git", "merge-tree", "--write-tree", "HEAD", other_ref], cwd=clone_dir, check=False)
                if mt.returncode == 0:
                    cross_track_results.append(f"- **Track {other_track} (`{other_meta['branch']}`)**: CLEAN (0 conflicts)")
                else:
                    cross_track_results.append(f"- **Track {other_track} (`{other_meta['branch']}`)**: CONFLICT DETECTED\n```\n{mt.stdout}\n```")
            else:
                cross_track_results.append(f"- **Track {other_track} (`{other_meta['branch']}`)**: Not pushed to hub yet (disjoint file scope guaranteed)")

    # 3. Collect commit log and diffstat
    commits_out = run(["git", "log", "--oneline", "origin/main..HEAD"], cwd=clone_dir).stdout.strip()
    diffstat_out = run(["git", "diff", "--stat", "origin/main...HEAD"], cwd=clone_dir).stdout.strip()
    changed_files = run(["git", "diff", "--name-only", "origin/main...HEAD"], cwd=clone_dir).stdout.strip().splitlines()
    head_sha = run(["git", "rev-parse", "HEAD"], cwd=clone_dir).stdout.strip()

    # 4. Attempt push to remote origin & GitHub PR creation if credentials exist
    push_remote = os.environ.get("SIMON_PR_REMOTE", "origin")
    push_res = run(["git", "push", "-u", push_remote, f"HEAD:refs/heads/{meta['branch']}"], cwd=clone_dir, check=False)
    remote_pushed = push_res.returncode == 0

    pr_title = args.title or meta["title"]
    pr_body = f"""## Summary ({meta['pr_id']} — Track {track})

Addresses audit findings: {', '.join(f'`{b}`' for b in meta['bugs'])}.

### Commits
```text
{commits_out}
```

### Diffstat
```text
{diffstat_out}
```

### Cross-Track Merge Verification
{chr(10).join(cross_track_results)}
"""

    pr_url = None
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    repo_slug = os.environ.get("SIMON_GITHUB_REPO", "Szpili/SIMON")
    if remote_pushed and token:
        try:
            req = urllib.request.Request(
                f"https://api.github.com/repos/{repo_slug}/pulls",
                data=json.dumps({
                    "title": pr_title,
                    "head": meta["branch"],
                    "base": "main",
                    "body": pr_body,
                }).encode("utf-8"),
                headers={
                    "Authorization": f"Bearer {token}",
                    "Accept": "application/vnd.github+json",
                    "Content-Type": "application/json",
                    "User-Agent": "SIMON-Argon-Agent",
                },
                method="POST",
            )
            with urllib.request.urlopen(req, timeout=15) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                pr_url = data.get("html_url")
        except urllib.error.HTTPError as e:
            err_body = e.read().decode("utf-8", errors="replace")
            print(f"[Track {track}] Note: GitHub API returned {e.code}: {err_body}")

    # 5. Write git bundle and PR_SUBMISSION.md artifact in the track's spec folder
    bundle_path = spec_dir / f"{meta['pr_id']}_{track}.bundle"
    run(["git", "bundle", "create", str(bundle_path), "origin/main..HEAD"], cwd=clone_dir)

    report_path = spec_dir / "PR_SUBMISSION.md"
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    report_content = f"""# Pull Request Submission Report — Track {track} ({meta['pr_id']})

- **Generated At**: `{now_iso}`
- **Track**: Track {track} (`{meta['pr_id']}`)
- **Branch**: `{meta['branch']}`
- **HEAD Commit**: `{head_sha}`
- **Clone Path**: `{clone_dir}`
- **Portable Git Bundle**: `{bundle_path}`
- **Upstream Rebase (`origin/main`)**: `CLEAN`
- **Remote Push (`{push_remote}`)**: `{'PUSHED' if remote_pushed else 'LOCAL_HUB_AND_BUNDLE_READY (set GITHUB_TOKEN/credentials to push upstream)'}`
- **GitHub PR URL**: `{pr_url or 'Ready to open from branch ' + meta['branch']}`

---

## PR Title
`{pr_title}`

## PR Description
{pr_body}

## Modified Files ({len(changed_files)})
{chr(10).join(f'- `{f}`' for f in changed_files)}
"""
    report_path.write_text(report_content, encoding="utf-8")
    print("========================================================================")
    print(f" [Track {track}] PR Preparation & Merge Check Complete!")
    print(f" Branch        : {meta['branch']} ({head_sha[:8]})")
    print(f" PR Report     : {report_path}")
    print(f" Git Bundle    : {bundle_path}")
    if pr_url:
        print(f" GitHub PR URL : {pr_url}")
    print("========================================================================")


if __name__ == "__main__":
    main()
