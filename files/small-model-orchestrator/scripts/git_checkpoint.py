#!/usr/bin/env python3
"""Git inspection/snapshot/checkpoint helper. Uses standard library only."""
from __future__ import annotations
import argparse
import subprocess
import sys
import traceback
from datetime import datetime, timezone
from pathlib import Path

def run_git(root: Path, *args: str, check: bool = True) -> str:
    proc = subprocess.run(
        ["git", "-C", str(root.resolve()), *args],
        text=True, capture_output=True
    )
    if check and proc.returncode != 0:
        raise RuntimeError(
            f"git {' '.join(args)} failed ({proc.returncode}): {proc.stderr.strip()}"
        )
    return proc.stdout

def inspect(root: Path) -> str:
    head = run_git(root, "rev-parse", "HEAD").strip()
    branch = run_git(root, "branch", "--show-current").strip() or "(detached)"
    status = run_git(root, "status", "--short")
    return f"HEAD={head}\nBRANCH={branch}\nSTATUS:\n{status}"

def snapshot(root: Path) -> Path:
    workspace = root.resolve() / ".small-model-orchestrator" / "snapshots"
    workspace.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    patch = workspace / f"git-{stamp}.patch"
    content = []
    content.append("# git status --short\n" + run_git(root, "status", "--short"))
    content.append("\n# git diff\n" + run_git(root, "diff"))
    content.append("\n# git diff --staged\n" + run_git(root, "diff", "--staged"))
    content.append("\n# untracked\n" + run_git(root, "ls-files", "--others", "--exclude-standard"))
    patch.write_text("".join(content), encoding="utf-8")
    return patch

def checkpoint_commit(root: Path, message: str) -> str:
    run_git(root, "add", "-A")
    run_git(root, "commit", "-m", message)
    return run_git(root, "rev-parse", "HEAD").strip()

def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--root", default=".")
    group = p.add_mutually_exclusive_group(required=True)
    group.add_argument("--inspect", action="store_true")
    group.add_argument("--snapshot", action="store_true")
    group.add_argument("--commit", metavar="MESSAGE")
    a = p.parse_args()
    try:
        root = Path(a.root)
        if a.inspect:
            print(inspect(root))
        elif a.snapshot:
            print(f"git_checkpoint.py: snapshot={snapshot(root)}")
        else:
            print(f"git_checkpoint.py: commit={checkpoint_commit(root, a.commit)}")
        return 0
    except Exception as e:
        print(f"git_checkpoint.py: {e}", file=sys.stderr)
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
