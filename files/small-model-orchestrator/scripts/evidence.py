#!/usr/bin/env python3
"""Append a timestamped evidence record to the project workspace."""
from __future__ import annotations
import argparse
import sys
import traceback
from datetime import datetime, timezone
from pathlib import Path

def clean(value: str) -> str:
    return value.replace("|", r"\|").replace("\n", " ")

def append_evidence(root: Path, evidence_id: str, kind: str, claim: str,
                    observation: str, source: str, result: str) -> Path:
    path = root.resolve() / ".small-model-orchestrator" / "EVIDENCE.md"
    if not path.exists():
        raise FileNotFoundError(f"Evidence ledger not initialized: {path}")
    timestamp = datetime.now(timezone.utc).isoformat()
    row = "| " + " | ".join(clean(x) for x in [
        timestamp, evidence_id, kind, claim, observation, source, result
    ]) + " |\n"
    with path.open("a", encoding="utf-8") as f:
        f.write(row)
    return path

def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--root", default=".")
    p.add_argument("--id", required=True)
    p.add_argument("--type", required=True)
    p.add_argument("--claim", required=True)
    p.add_argument("--observation", required=True)
    p.add_argument("--source", required=True)
    p.add_argument("--result", required=True)
    a = p.parse_args()
    try:
        path = append_evidence(Path(a.root), a.id, a.type, a.claim,
                               a.observation, a.source, a.result)
        print(f"evidence.py: appended to {path}")
        return 0
    except Exception as e:
        print(f"evidence.py: {e}", file=sys.stderr)
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
