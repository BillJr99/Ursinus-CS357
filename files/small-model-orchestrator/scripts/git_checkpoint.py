#!/usr/bin/env python3
"""Git inspection/snapshot/branch/checkpoint helper. Uses standard library only."""
from __future__ import annotations
import argparse
import re
import subprocess
import sys
import traceback
from datetime import datetime, timezone
from pathlib import Path

STATE_DIR = ".small-model-orchestrator/"
FALLBACK_IDENTITY = ["-c", "user.name=small-model-orchestrator",
                     "-c", "user.email=small-model-orchestrator@localhost"]

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

def git_ok(root: Path, *args: str) -> bool:
    return subprocess.run(["git", "-C", str(root.resolve()), *args],
                          capture_output=True).returncode == 0

def head(root: Path) -> str:
    if not git_ok(root, "rev-parse", "--verify", "HEAD"):
        return "(no commits)"
    return run_git(root, "rev-parse", "--short", "HEAD").strip()

def identity_args(root: Path) -> list[str]:
    """Use the configured identity when present; otherwise a local fallback."""
    if git_ok(root, "config", "user.name") and git_ok(root, "config", "user.email"):
        return []
    return FALLBACK_IDENTITY

def exclude_state_dir(root: Path) -> None:
    """Keep task state out of commits without changing tracked files."""
    exclude = Path(run_git(root, "rev-parse", "--git-path", "info/exclude").strip())
    if not exclude.is_absolute():
        exclude = root.resolve() / exclude
    exclude.parent.mkdir(parents=True, exist_ok=True)
    text = exclude.read_text(encoding="utf-8") if exclude.exists() else ""
    if STATE_DIR not in text.splitlines():
        with exclude.open("a", encoding="utf-8") as f:
            f.write(("" if text.endswith("\n") or not text else "\n") + STATE_DIR + "\n")

def inspect(root: Path) -> str:
    branch = run_git(root, "branch", "--show-current").strip() or "(detached)"
    status = run_git(root, "status", "--short")
    return f"HEAD={head(root)}\nBRANCH={branch}\nSTATUS:\n{status}"

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

def start(root: Path, task_id: str, allow_dirty: bool = False) -> str:
    """Create or reuse branch smo/<task_id>; refuse to carry unexplained changes."""
    if not re.fullmatch(r"[A-Za-z0-9._-]+", task_id):
        raise ValueError("task id may contain only letters, digits, '.', '_' and '-'")
    exclude_state_dir(root)
    branch = f"smo/{task_id}"
    current = run_git(root, "branch", "--show-current").strip()
    if current == branch:
        return f"already on {branch}; HEAD={head(root)}"
    dirty = run_git(root, "status", "--porcelain").strip()
    if dirty and not allow_dirty:
        patch = snapshot(root)
        raise RuntimeError(
            f"working tree has pre-existing changes (snapshot: {patch}). "
            "Ask the user how to proceed, or rerun with --allow-dirty if they approve."
        )
    if head(root) == "(no commits)":
        raise RuntimeError("repository has no commits; make a baseline commit first")
    base = head(root)
    if git_ok(root, "rev-parse", "--verify", f"refs/heads/{branch}"):
        run_git(root, "switch", branch)
        return f"switched to existing {branch}; HEAD={head(root)}; previous branch={current or '(detached)'}"
    run_git(root, "switch", "-c", branch)
    return f"created {branch} from {current or '(detached)'} at base={base}"

def checkpoint_commit(root: Path, message: str) -> str:
    exclude_state_dir(root)
    run_git(root, "add", "-A")
    if not run_git(root, "diff", "--cached", "--name-only").strip():
        return f"nothing to commit; HEAD={head(root)}"
    staged = run_git(root, "diff", "--cached", "--stat").rstrip()
    run_git(root, *identity_args(root), "commit", "-m", message)
    return f"commit={head(root)}\n{staged}"

def log(root: Path, count: int = 15) -> str:
    if head(root) == "(no commits)":
        return "(no commits)"
    return run_git(root, "log", "--oneline", f"-n{count}")

def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--root", default=".")
    p.add_argument("--allow-dirty", action="store_true",
                   help="with --start: carry existing uncommitted changes onto the task branch")
    group = p.add_mutually_exclusive_group(required=True)
    group.add_argument("--inspect", action="store_true")
    group.add_argument("--snapshot", action="store_true")
    group.add_argument("--start", metavar="TASK_ID", help="create or switch to branch smo/TASK_ID")
    group.add_argument("--commit", metavar="MESSAGE")
    group.add_argument("--log", action="store_true")
    a = p.parse_args()
    try:
        root = Path(a.root)
        if a.inspect:
            print(inspect(root))
        elif a.snapshot:
            print(f"git_checkpoint.py: snapshot={snapshot(root)}")
        elif a.start:
            print(f"git_checkpoint.py: {start(root, a.start, a.allow_dirty)}")
        elif a.log:
            print(log(root))
        else:
            print(f"git_checkpoint.py: {checkpoint_commit(root, a.commit)}")
        return 0
    except Exception as e:
        print(f"git_checkpoint.py: {e}", file=sys.stderr)
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
