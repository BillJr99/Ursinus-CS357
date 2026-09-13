#!/usr/bin/env python3
"""Snapshot PLAN.md before a versioned revision and append a revision marker."""
from __future__ import annotations
import argparse
import re
import shutil
import sys
import traceback
from datetime import datetime, timezone
from pathlib import Path

def version_plan(root: Path, reason: str, evidence: str = "") -> tuple[int, Path]:
    workspace = root.resolve() / ".small-model-orchestrator"
    plan = workspace / "PLAN.md"
    snapshots = workspace / "snapshots"
    snapshots.mkdir(parents=True, exist_ok=True)
    text = plan.read_text(encoding="utf-8")
    m = re.search(r"(?m)^Version:\s*(\d+)\s*$", text)
    current = int(m.group(1)) if m else 1
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    snapshot = snapshots / f"PLAN.v{current}.{stamp}.md"
    shutil.copyfile(plan, snapshot)
    new_version = current + 1
    if m:
        text = text[:m.start(1)] + str(new_version) + text[m.end(1):]
    else:
        text = f"Version: {new_version}\n" + text
    entry = (
        f"\n- {datetime.now(timezone.utc).isoformat()}: v{current} → v{new_version}; "
        f"reason: {reason}; evidence: {evidence or 'not specified'}\n"
    )
    if "## Revision log" in text:
        text += entry
    else:
        text += "\n## Revision log\n" + entry
    plan.write_text(text, encoding="utf-8")
    return new_version, snapshot

def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--root", default=".")
    p.add_argument("--reason", required=True)
    p.add_argument("--evidence", default="")
    a = p.parse_args()
    try:
        version, snapshot = version_plan(Path(a.root), a.reason, a.evidence)
        print(f"plan_version.py: plan is now v{version}; snapshot={snapshot}")
        return 0
    except Exception as e:
        print(f"plan_version.py: {e}", file=sys.stderr)
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
