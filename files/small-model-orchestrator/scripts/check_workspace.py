#!/usr/bin/env python3
"""Check the persistent orchestration workspace for required artifacts and obvious incompleteness."""
from __future__ import annotations
import argparse
import sys
import traceback
from pathlib import Path

REQUIRED = [
    "TASK.md", "CONTRACT.md", "PLAN.md", "STATE.md", "EVIDENCE.md",
    "FAILURES.md", "EXPERIMENTS.md", "GAUNTLET.md", "LESSONS.md", "EXECUTION.md",
]

def check(root: Path) -> int:
    ws = root.resolve() / ".small-model-orchestrator"
    problems = []
    for name in REQUIRED:
        p = ws / name
        if not p.exists():
            problems.append(f"MISSING {name}")
        elif p.stat().st_size == 0:
            problems.append(f"EMPTY {name}")
    for d in ("snapshots", "artifacts"):
        if not (ws / d).is_dir():
            problems.append(f"MISSING DIRECTORY {d}")
    if problems:
        print("check_workspace.py: INCOMPLETE")
        for problem in problems:
            print(f"- {problem}")
        return 1
    print("check_workspace.py: workspace structure present")
    return 0

def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--root", default=".")
    a = p.parse_args()
    try:
        return check(Path(a.root))
    except Exception as e:
        print(f"check_workspace.py: {e}", file=sys.stderr)
        traceback.print_exc()
        return 2

if __name__ == "__main__":
    raise SystemExit(main())
