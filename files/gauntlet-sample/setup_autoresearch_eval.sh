#!/usr/bin/env bash
# CS357 autoresearch sample kit: the held-out metric the loop optimizes against.
# Run from inside gauntlet-sample/, after setup_gauntlet_sample.sh.
# Writes eval/ and commits nothing: the loop, not this script, changes the artifact.
set -euo pipefail

mkdir -p eval

cat > eval/queries.json <<'KITEOF'
[
  {"query": "agent that remembers earlier requests",                 "source": "kb/docs/03.md"},
  {"query": "agent that asks permission first",                      "source": "kb/docs/06.md"},
  {"query": "what port does the local server use",                   "source": "kb/docs/04.md"},
  {"query": "how is an agent checked for quality",                   "source": "kb/docs/08.md"},
  {"query": "extra instructions the agent picks up when needed",     "source": "kb/docs/07.md"},
  {"query": "how do I stop it before it does something irreversible","source": "kb/docs/06.md"},
  {"query": "agent that uses outside capabilities",                  "source": "kb/docs/01.md"},
  {"query": "the basic definition of an agent",                      "source": "kb/docs/02.md"},
  {"query": "giving the model examples in the prompt",               "source": "kb/docs/05.md"},
  {"query": "serving a model on my own machine",                     "source": "kb/docs/04.md"},
  {"query": "agent scoring against an answer key",                   "source": "kb/docs/08.md"},
  {"query": "perceive plan act",                                     "source": "kb/docs/02.md"}
]
KITEOF

cat > eval/score.py <<'KITEOF'
"""Score artifact/search.py against the held-out query set.

Prints one number: mean reciprocal rank over eval/queries.json.  Pass -v to see
the rank of every query.  The artifact runs as a subprocess, so this measures
behavior rather than implementation, and any scoring approach is fair game.

The loop may not edit this file or eval/queries.json.  That is what makes the
number a check rather than a suggestion.
"""
import json
import subprocess
import sys
import traceback

QUERIES = "eval/queries.json"
ARTIFACT = "artifact/search.py"
DEPTH = 8


def rank_of(expected, results):
    """Return the 1-based rank of expected in results, or 0 if it is absent."""
    for i, result in enumerate(results, start=1):
        if result.get("source") == expected:
            return i
    return 0


def main():
    """Run every query through the artifact and print the mean reciprocal rank."""
    try:
        with open(QUERIES, encoding="utf-8") as f:
            cases = json.load(f)
    except Exception as e:
        print(f"[score:main] cannot read {QUERIES}: {e}")
        traceback.print_exc()
        return 2

    total = 0.0
    for case in cases:
        try:
            proc = subprocess.run(
                [sys.executable, ARTIFACT, case["query"], "--max-results", str(DEPTH)],
                capture_output=True, text=True, timeout=30,
            )
            results = json.loads(proc.stdout) if proc.returncode == 0 else []
        except Exception as e:
            print(f"[score:main] query {case['query']!r} failed: {e}")
            traceback.print_exc()
            results = []
        rank = rank_of(case["source"], results)
        reciprocal = 1.0 / rank if rank else 0.0
        total += reciprocal
        if "-v" in sys.argv:
            print(f"  rank {rank or '-':>2}  rr {reciprocal:.3f}  {case['query']}")

    print(f"{total / len(cases):.3f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
KITEOF

cat > eval/BEST.md <<'KITEOF'
# Best score so far

Target: 0.80 mean reciprocal rank on eval/queries.json.  Budget: 5 iterations.

Record one line per kept iteration.  An iteration that scores worse than the best
line here is restored, not committed.

| Iteration | What changed | MRR | Kept? |
|---|---|---|---|
| baseline | candidate-1 as the gauntlet left it | 0.667 | yes |
KITEOF

chmod +x eval/score.py 2>/dev/null || true

echo "Metric harness ready."
echo "  python3 eval/score.py      prints one number"
echo "  python3 eval/score.py -v   prints the rank of every query"
echo "Baseline should print 0.667.  The target in eval/BEST.md is 0.80."
