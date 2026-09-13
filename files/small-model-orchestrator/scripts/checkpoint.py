#!/usr/bin/env python3
"""Validate and atomically publish a bounded, durable task checkpoint."""
import argparse
import datetime
import json
import os
from pathlib import Path
import sys
import tempfile
import traceback


def validate(data, limits):
    required = {"task_id", "objective", "constraints", "status", "verified", "unresolved",
                "evidence", "next_action", "verifier", "in_flight"}
    if not isinstance(data, dict) or set(data) != required:
        raise ValueError(f"Checkpoint must contain exactly: {', '.join(sorted(required))}")
    for key in ("task_id", "objective", "status", "next_action", "verifier", "in_flight"):
        if not isinstance(data[key], str) or not data[key].strip():
            raise ValueError(f"{key} must be a nonempty string")
        if len(data[key]) > limits["maxFieldCharacters"]:
            raise ValueError(f"{key} exceeds maxFieldCharacters")
    if data["status"] not in {"IN_PROGRESS", "VERIFIED", "BLOCKED", "STAGNATED"}:
        raise ValueError("Invalid checkpoint status")
    for key in ("constraints", "verified", "unresolved", "evidence"):
        if not isinstance(data[key], list) or len(data[key]) > limits["maxListItems"]:
            raise ValueError(f"{key} must be a bounded list")
        if any(not isinstance(item, str) or not item.strip()
               or len(item) > limits["maxFieldCharacters"] for item in data[key]):
            raise ValueError(f"{key} items must be nonempty bounded strings")
    return data


def render(data):
    lines = ["# Resume checkpoint", "",
             "Updated: " + datetime.datetime.now(datetime.timezone.utc).isoformat(), ""]
    for key, value in data.items():
        lines.extend(["## " + key, ""])
        lines.extend(["- " + item for item in value] if isinstance(value, list) else [value])
        lines.append("")
    return "\n".join(lines).encode("utf-8")


def write_checkpoint(root, data, limits):
    """Do not replace the last good checkpoint until validation and fsync succeed."""
    payload = render(validate(data, limits))
    if len(payload) > limits["maxBytes"]:
        raise ValueError("Checkpoint exceeds maxBytes; shorten summaries and use evidence paths")
    directory = Path(root).resolve() / ".small-model-orchestrator"
    directory.mkdir(parents=True, exist_ok=True)
    target = directory / "RESUME.md"
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=directory, prefix=".resume-", delete=False) as handle:
            temporary = Path(handle.name)
            handle.write(payload)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, target)
        temporary = None
        if os.name == "posix":
            directory_fd = os.open(directory, os.O_RDONLY)
            try:
                os.fsync(directory_fd)
            finally:
                os.close(directory_fd)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    return target


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True)
    parser.add_argument("--config", type=Path, default=Path(__file__).resolve().parents[1] / "assets/checkpoint-config.json")
    parser.add_argument("action", choices=["write", "show"])
    args = parser.parse_args()
    limits = json.loads(args.config.read_text())
    for key in ("maxBytes", "maxFieldCharacters", "maxListItems"):
        if type(limits.get(key)) is not int or limits[key] <= 0:
            raise ValueError(f"{key} must be a positive integer")
    if args.action == "show":
        target = Path(args.root) / ".small-model-orchestrator/RESUME.md"
        with target.open("rb") as handle:
            payload = handle.read(limits["maxBytes"] + 1)
        if len(payload) > limits["maxBytes"]:
            raise ValueError("Checkpoint exceeds maxBytes; inspect bounded ranges and repair it")
        print(payload.decode("utf-8"))
    else:
        raw = sys.stdin.buffer.read(limits["maxBytes"] * 2 + 1)
        if len(raw) > limits["maxBytes"] * 2:
            raise ValueError("Input exceeds checkpoint input limit")
        target = write_checkpoint(args.root, json.loads(raw), limits)
        print(f"Checkpoint saved: {target}")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"[checkpoint] {e}", file=sys.stderr)
        traceback.print_exc()
        sys.exit(1)
