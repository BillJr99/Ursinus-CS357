#!/usr/bin/env python3
"""Initialize .small-model-orchestrator from bundled templates."""
from __future__ import annotations
import argparse
import shutil
import sys
import traceback
from datetime import datetime, timezone
from pathlib import Path

FILES = [
    "TASK.md", "CONTRACT.md", "PLAN.md", "STATE.md", "EVIDENCE.md",
    "FAILURES.md", "EXPERIMENTS.md", "GAUNTLET.md", "LESSONS.md", "EXECUTION.md",
]

def bootstrap(root: Path, force: bool = False) -> Path:
    skill_root = Path(__file__).resolve().parent.parent
    template_root = skill_root / "assets" / "templates"
    workspace = root.resolve() / ".small-model-orchestrator"
    workspace.mkdir(parents=True, exist_ok=True)
    (workspace / "snapshots").mkdir(exist_ok=True)
    (workspace / "artifacts").mkdir(exist_ok=True)

    for name in FILES:
        src = template_root / name
        dst = workspace / name
        if not src.exists():
            raise FileNotFoundError(f"Missing bundled template: {src}")
        if dst.exists() and not force:
            continue
        shutil.copyfile(src, dst)

    execution = workspace / "EXECUTION.md"
    with execution.open("a", encoding="utf-8") as f:
        f.write(f"\n## {datetime.now(timezone.utc).isoformat()} — workspace bootstrap\n")
        f.write(f"- Root: `{root.resolve()}`\n")
        f.write(f"- Force: `{force}`\n")
    return workspace

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".", help="Project root")
    parser.add_argument("--force", action="store_true", help="Overwrite state templates")
    args = parser.parse_args()
    try:
        workspace = bootstrap(Path(args.root), args.force)
        print(f"bootstrap_workspace.py: initialized {workspace}")
        return 0
    except Exception as e:
        print(f"bootstrap_workspace.py: {e}", file=sys.stderr)
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
