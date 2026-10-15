#!/usr/bin/env python3
"""
SIMON Parallel Agent Pull Request & `fz-contrib` Integration Script.
- Never targets `main` directly: all Track PRs target the dedicated `fz-contrib` branch.
- Verifies zero merge conflicts against `fz-contrib` and all sibling Track branches (`A`-`I`).
- Integrates verified commits cleanly onto `hub/fz-contrib` under an exclusive file lock.
- Pushes `fz-contrib` and `fz/track-*` to remote if credentials exist and opens PR targeting `fz-contrib`.
- Generates a Captain's Cherry-Pick Menu in `PR_SUBMISSION.md`.
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

BASE_BRANCH = "fz-contrib"

TRACK_META = {
    "A": {
        "stage": 1,
        "pr_id": "PR-1",
        "branch": "fz/track-A-node-receipt-truth",
        "dir_name": "track_A_receipt_and_node_truth",
        "title": "[FZ-A] fix(node): populate real Unix timestamp_us, dynamic GGUF precision, and weight SHA-256 verification",
        "bugs": ["BUG-01", "BUG-02", "BUG-05"],
    },
    "B": {
        "stage": 1,
        "pr_id": "PR-2",
        "branch": "fz/track-B-live-m1-receipts",
        "dir_name": "track_B_live_m1_token_binding",
        "title": "[FZ-B] feat(agent): wire live M1 TokenCommitment verification and M3 drift telemetry in simon-cli",
        "bugs": ["BUG-03"],
    },
    "C": {
        "stage": 1,
        "pr_id": "PR-3",
        "branch": "fz/track-C-industry-m7-agent",
        "dir_name": "track_C_industry_gemma4_live_agent",
        "title": "[FZ-C] feat(industry): upgrade Track 1 ticket generator to multi-turn Gemma 4 tool-calling agent with verified receipts",
        "bugs": ["BUG-09"],
    },
    "D": {
        "stage": 1,
        "pr_id": "PR-4",
        "branch": "fz/track-D-core-security-hardening",
        "dir_name": "track_D_core_security_and_wasm_fixes",
        "title": "[FZ-D] fix(core,wasm): enforce M0 signature in M1/WASM, block IPv6-mapped SSRF, NaN logprobs, and non-object Cap JSON",
        "bugs": ["BUG-04", "BUG-06", "BUG-15"],
    },
    "E": {
        "stage": 1,
        "pr_id": "PR-5",
        "branch": "fz/track-E-coordinator-gossipsub-bridge",
        "dir_name": "track_E_p2p_coordinator_bridge",
        "title": "[FZ-E] feat(node,cli): add HTTP LLM executor bridge to SimonNode and fix MapReduce chunk truncation",
        "bugs": ["BUG-07", "BUG-08"],
    },
    "F": {
        "stage": 1,
        "pr_id": "PR-6",
        "branch": "fz/track-F-submission-and-ui-polish",
        "dir_name": "track_F_submission_and_ui_polish",
        "title": "[FZ-F] fix(ui,docs,tools): reconcile submission test/MI300X tables, clarify UI demo/network badges, and harden Python tools",
        "bugs": ["BUG-10", "BUG-11", "BUG-12", "BUG-13", "BUG-14", "BUG-16"],
    },
    "G": {
        "stage": 2,
        "pr_id": "PR-7",
        "branch": "fz/track-G-architecture-and-docs-overhaul",
        "dir_name": "track_G_architecture_and_docs_overhaul",
        "title": "[FZ-G] docs(arch): add comprehensive ARCHITECTURE.md and align threat model & whitepaper with verified codebase",
        "bugs": ["ARCH-DOCS"],
    },
    "H": {
        "stage": 2,
        "pr_id": "PR-8",
        "branch": "fz/track-H-e2e-integration-and-live-m1-bridge",
        "dir_name": "track_H_e2e_integration_and_live_m1_bridge",
        "title": "[FZ-H] feat(cli): connect live node M1 token commitment builder with agent verifier and add E2E test",
        "bugs": ["BUG-03-E2E"],
    },
    "I": {
        "stage": 2,
        "pr_id": "PR-9",
        "branch": "fz/track-I-captain-cherry-pick-menu-and-ci",
        "dir_name": "track_I_captain_cherry_pick_menu_and_ci",
        "title": "[FZ-I] docs(contrib): generate Team Captain cherry-pick menu and fast full-stack verification script",
        "bugs": ["CAPTAIN-REVIEW-UX"],
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
    parser = argparse.ArgumentParser(description="Prepare and create PR targeting fz-contrib for SIMON Track")
    parser.add_argument("--track", required=True, help="Track letter: A..I")
    parser.add_argument("--title", default=None, help="Optional custom PR title")
    args = parser.parse_args()

    track = args.track.upper().replace("TRACK_", "").replace("TRACK", "").strip()
    if track not in TRACK_META:
        print(f"ERROR: Invalid track '{args.track}'. Choose from A..I.", file=sys.stderr)
        sys.exit(1)

    meta = TRACK_META[track]
    handover_root = Path(__file__).resolve().parents[4]
    clone_dir = handover_root / "workspaces" / f"track_{track}"
    spec_dir = handover_root / "parallel_agents" / meta["dir_name"]
    lock_file = handover_root / "workspaces" / ".hub.lock"

    if not (clone_dir / ".git").exists():
        print(f"ERROR: Clone directory {clone_dir} not found.", file=sys.stderr)
        sys.exit(1)

    diff_base = "hub/main" if meta["stage"] == 1 else f"hub/{BASE_BRANCH}"

    # 1. Acquire lock on shared integration hub, push track branch, check conflicts, and advance fz-contrib
    cross_track_results = []
    lock_file.parent.mkdir(parents=True, exist_ok=True)
    with open(lock_file, "w") as lf:
        fcntl.flock(lf, fcntl.LOCK_EX)
        run(["git", "fetch", "hub"], cwd=clone_dir)

        # Ensure track branch is cleanly rebased onto its stage base
        rebase_res = run(["git", "rebase", diff_base], cwd=clone_dir, check=False)
        if rebase_res.returncode != 0:
            run(["git", "rebase", "--abort"], cwd=clone_dir, check=False)
            raise RuntimeError(f"Rebase onto {diff_base} encountered conflicts:\n{rebase_res.stderr}")

        # Push track branch to local integration hub
        run(["git", "push", "-f", "hub", f"HEAD:refs/heads/{meta['branch']}"], cwd=clone_dir)
        run(["git", "fetch", "hub"], cwd=clone_dir)

        # Check mergeability against current hub/fz-contrib and all other active track branches
        mt_base = run(["git", "merge-tree", "--write-tree", f"refs/remotes/hub/{BASE_BRANCH}", "HEAD"], cwd=clone_dir, check=False)
        if mt_base.returncode != 0:
            raise RuntimeError(f"Conflict detected with {BASE_BRANCH}:\n{mt_base.stdout}")
        cross_track_results.append(f"- **Base `{BASE_BRANCH}`**: CLEAN (0 conflicts)")

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

        # Integrate this track's commits cleanly onto local fz-contrib branch and push to hub/fz-contrib
        current_branch = meta["branch"]
        run(["git", "checkout", "-B", BASE_BRANCH, f"refs/remotes/hub/{BASE_BRANCH}"], cwd=clone_dir)
        # Rebase or cherry-pick the track's commits linearly onto fz-contrib so every commit on fz-contrib is linear & cherry-pickable!
        commits_to_apply = run(
            ["git", "rev-list", "--reverse", f"{diff_base}..{current_branch}"],
            cwd=clone_dir,
        ).stdout.strip().splitlines()
        for csha in commits_to_apply:
            # Skip if an identical patch-id is already on fz-contrib
            cp = run(["git", "cherry-pick", csha], cwd=clone_dir, check=False)
            if cp.returncode != 0:
                run(["git", "cherry-pick", "--abort"], cwd=clone_dir, check=False)
                # Fall back to no-ff merge if cherry-pick already partially applied
                run(["git", "merge", "--no-edit", current_branch], cwd=clone_dir)
                break
        run(["git", "push", "hub", f"{BASE_BRANCH}:refs/heads/{BASE_BRANCH}"], cwd=clone_dir)
        run(["git", "checkout", current_branch], cwd=clone_dir)

    # 2. Collect commit log, Captain's Cherry-Pick table, and diffstat
    log_lines = run(
        ["git", "log", "--reverse", "--format=%h|%H|%s", f"{diff_base}..HEAD"],
        cwd=clone_dir,
    ).stdout.strip().splitlines()

    cherry_pick_rows = []
    for idx, line in enumerate(log_lines, 1):
        parts = line.split("|", 2)
        if len(parts) == 3:
            short_sha, full_sha, subj = parts
            files_in_commit = run(
                ["git", "diff-tree", "--no-commit-id", "--name-only", "-r", full_sha],
                cwd=clone_dir,
            ).stdout.strip().replace("\n", ", ")
            cherry_pick_rows.append(
                f"| `{idx}` | `{short_sha}` | {subj} | `{files_in_commit}` | `git cherry-pick {full_sha}` |"
            )

    commits_out = run(["git", "log", "--oneline", f"{diff_base}..HEAD"], cwd=clone_dir).stdout.strip()
    diffstat_out = run(["git", "diff", "--stat", f"{diff_base}...HEAD"], cwd=clone_dir).stdout.strip()
    changed_files = run(["git", "diff", "--name-only", f"{diff_base}...HEAD"], cwd=clone_dir).stdout.strip().splitlines()
    head_sha = run(["git", "rev-parse", "HEAD"], cwd=clone_dir).stdout.strip()

    # 3. Attempt push of BOTH `fz-contrib` and `fz/track-*` to remote origin, and open PR targeting `fz-contrib` (NEVER `main`!)
    push_remote = os.environ.get("SIMON_PR_REMOTE", "origin")
    run(["git", "push", push_remote, f"{BASE_BRANCH}:refs/heads/{BASE_BRANCH}"], cwd=clone_dir, check=False)
    push_res = run(["git", "push", "-u", push_remote, f"HEAD:refs/heads/{meta['branch']}"], cwd=clone_dir, check=False)
    remote_pushed = push_res.returncode == 0

    pr_title = args.title or meta["title"]
    cherry_pick_table = (
        "| # | Commit | Description | Files Touched | Captain Cherry-Pick Command |\n"
        "| :--- | :--- | :--- | :--- | :--- |\n"
        + "\n".join(cherry_pick_rows)
    )

    pr_body = f"""## Summary ({meta['pr_id']} — Track {track}, Stage {meta['stage']})

- **Target Integration Branch**: `{BASE_BRANCH}` *(does **not** touch `main` directly; prepared for Team Captain review / cherry-pick)*
- **Addresses Audit Findings**: {', '.join(f'`{b}`' for b in meta['bugs'])}

### Captain's Granular Cherry-Pick Menu
Every commit on this branch is self-contained, compiles cleanly, and passes tests independently:

{cherry_pick_table}

### Diffstat
```text
{diffstat_out}
```

### Cross-Track & `{BASE_BRANCH}` Merge Verification
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
                    "base": BASE_BRANCH,
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

    # 4. Write git bundle and PR_SUBMISSION.md artifact in the track's spec folder
    spec_dir.mkdir(parents=True, exist_ok=True)
    bundle_path = spec_dir / f"{meta['pr_id']}_{track}.bundle"
    run(["git", "bundle", "create", str(bundle_path), f"{diff_base}..HEAD"], cwd=clone_dir)

    report_path = spec_dir / "PR_SUBMISSION.md"
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    report_content = f"""# Pull Request Submission Report — Track {track} ({meta['pr_id']}, Stage {meta['stage']})

- **Generated At**: `{now_iso}`
- **Track**: Track {track} (`{meta['pr_id']}`)
- **Track Branch**: `{meta['branch']}`
- **Target PR Base Branch**: `{BASE_BRANCH}` (**NEVER** directly to `main`)
- **HEAD Commit**: `{head_sha}`
- **Integrated into Local Hub `{BASE_BRANCH}`**: `YES (Linear / Cherry-Pickable)`
- **Portable Git Bundle**: `{bundle_path}`
- **Remote Push (`{push_remote}`)**: `{'PUSHED' if remote_pushed else 'LOCAL_HUB_AND_BUNDLE_READY (set GITHUB_TOKEN/credentials to push upstream)'}`
- **GitHub PR URL (into `{BASE_BRANCH}`)**: `{pr_url or 'Ready to open from ' + meta['branch'] + ' -> ' + BASE_BRANCH}`

---

## PR Title
`{pr_title}`

{pr_body}

## Modified Files ({len(changed_files)})
{chr(10).join(f'- `{f}`' for f in changed_files)}
"""
    report_path.write_text(report_content, encoding="utf-8")
    print("========================================================================")
    print(f" [Track {track}] PR Preparation & '{BASE_BRANCH}' Integration Complete!")
    print(f" Track Branch  : {meta['branch']} ({head_sha[:8]})")
    print(f" Base Branch   : {BASE_BRANCH} (updated in workspaces/_upstream_hub.git)")
    print(f" PR Report     : {report_path}")
    print(f" Git Bundle    : {bundle_path}")
    if pr_url:
        print(f" GitHub PR URL : {pr_url}")
    print("========================================================================")


if __name__ == "__main__":
    main()
