#!/usr/bin/env bash
# CS357 gauntlet-round sample kit, step 1 of 2: build the practice repo
# (sample spec + small knowledge base), committed as the state before the agent ran.
set -euo pipefail
mkdir -p gauntlet-sample/kb gauntlet-sample/artifact
cd gauntlet-sample
git init -q .

cat > spec.md <<'KITEOF'
# Feature Spec: search over a small knowledge base

## Author and date
[Your name], [today]

## Feature summary
One paragraph: what this does and who runs it.

## Entry point / signature
`python artifact/search.py "<query>" [--max-results N]`

## Inputs
| Name | Type | Required | Default | Constraints |
|---|---|---|---|---|
| query | string | yes | none | 1 to 200 characters, non-empty after strip |
| max_results | int | no | 5 | 1 to 20 inclusive |

## Outputs
JSON to stdout: a list of objects, each with `title` (string), `score` (float, 0 to 1),
and `source` (string, a path).  The list is sorted by score descending.

## Error cases (at least two, all handled and tested)
- Empty or whitespace-only query: exit 2 with a message on stderr, no traceback
- max_results out of range: exit 2 with a message naming the valid range
- Knowledge base file missing: exit 3 with a message naming the expected path
- No matches: exit 0 with an empty JSON list, which is not an error

## Testing criteria (at least three; the test suite must cover every one you list)
1. A query with matches returns results sorted by score descending
2. max_results limits the number returned
3. An empty query exits 2
4. A missing knowledge base exits 3
5. A query with no matches returns [] and exits 0

## Files the agent may create or edit
artifact/search.py, artifact/test_search.py

## Files the agent must NOT touch
spec.md, AGENTS.md, CHARTER.md, .ai/, docs/, transcripts/
KITEOF

cat > kb/knowledge_base.json <<'KITEOF'
[
  {
    "title": "Agents and tools",
    "body": "An agent calls tools to act on the world; tools extend what agents can do.",
    "source": "kb/docs/01.md"
  },
  {
    "title": "What is an agent",
    "body": "An agent perceives, plans, and acts in a loop.",
    "source": "kb/docs/02.md"
  },
  {
    "title": "Agent memory",
    "body": "Agents forget between requests unless memory is written down.",
    "source": "kb/docs/03.md"
  },
  {
    "title": "Local models with Ollama",
    "body": "Ollama serves local models on port 11434.",
    "source": "kb/docs/04.md"
  },
  {
    "title": "Prompt patterns",
    "body": "Personas and few-shot examples shape a model's output.",
    "source": "kb/docs/05.md"
  },
  {
    "title": "Agent safety gates",
    "body": "A gate in the tool path stops an agent before an irreversible action.",
    "source": "kb/docs/06.md"
  },
  {
    "title": "Agents and skills",
    "body": "Skills are instructions an agent loads on demand.",
    "source": "kb/docs/07.md"
  },
  {
    "title": "Evaluating agents",
    "body": "Agents are evaluated against an answer key of checks.",
    "source": "kb/docs/08.md"
  }
]
KITEOF

printf '__pycache__/\n' > .gitignore
git add .
git -c user.name=student -c user.email=student@example.com commit -qm "spec and knowledge base (before the agent run)"

# Step 2: the agent's first attempt, committed and tagged as candidate-0.
mkdir -p artifact
cat > artifact/search.py <<'KITEOF'
"""Search a small JSON knowledge base and print ranked results as JSON."""
import argparse
import json
import sys

KB_PATH = "kb/knowledge_base.json"


def load_kb(path):
    """Return the list of documents stored at path."""
    with open(path, encoding="utf-8") as f:
        try:
            return json.load(f)
        except json.JSONDecodeError as e:
            print(json.dumps({"error": str(e)}))
            return []


def score(query, doc):
    """Return the fraction of query terms that appear in the document."""
    terms = query.lower().split()
    text = (doc["title"] + " " + doc["body"]).lower()
    hits = sum(1 for t in terms if t in text)
    return hits / len(terms)


def search(query, max_results):
    """Return up to max_results matching documents, best first."""
    docs = load_kb(KB_PATH)
    results = []
    for doc in docs:
        s = score(query, doc)
        if s > 0:
            results.append({"title": doc["title"], "score": round(s, 3), "source": doc["source"]})
    results.sort(key=lambda r: r["score"], reverse=True)
    return results[:max_results]


def main(argv=None):
    """Parse arguments, run the search, and return the process exit code."""
    parser = argparse.ArgumentParser(description="Search the knowledge base.")
    parser.add_argument("query")
    parser.add_argument("--max-results", type=int, default=10)
    args = parser.parse_args(argv)
    if not args.query.strip():
        print("[search:main] query must not be empty", file=sys.stderr)
        return 2
    if not 1 <= args.max_results <= 20:
        print("[search:main] --max-results must be between 1 and 20", file=sys.stderr)
        return 2
    print(json.dumps(search(args.query, args.max_results), indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
KITEOF

cat > artifact/test_search.py <<'KITEOF'
"""Tests for artifact/search.py, one per testing criterion in spec.md."""
import io
import json
import os
import sys
import unittest
from contextlib import redirect_stdout

sys.path.insert(0, os.path.dirname(__file__))
import search  # noqa: E402


def run(argv):
    """Return (exit_code, stdout) for one call to search.main."""
    buf = io.StringIO()
    with redirect_stdout(buf):
        code = search.main(argv)
    return code, buf.getvalue()


class SearchTests(unittest.TestCase):
    def test_sorted_desc(self):
        code, out = run(["agent tools"])
        scores = [r["score"] for r in json.loads(out)]
        self.assertEqual(code, 0)
        self.assertEqual(scores, sorted(scores, reverse=True))

    def test_empty_query_exit_2(self):
        code, _ = run(["   "])
        self.assertEqual(code, 2)

    def test_missing_kb_exit_3(self):
        saved = search.KB_PATH
        search.KB_PATH = "kb/does_not_exist.json"
        try:
            code, _ = run(["agent"])
            self.assertEqual(code, 3)
        finally:
            search.KB_PATH = saved

    def test_no_matches_empty(self):
        code, out = run(["zebra"])
        self.assertEqual(code, 0)
        self.assertEqual(json.loads(out), [])


if __name__ == "__main__":
    unittest.main()
KITEOF

git add .
git -c user.name=student -c user.email=student@example.com commit -qm "Candidate 0: agent's first implementation"
git tag candidate-0

echo "Kit ready in gauntlet-sample/."
echo "  git log --oneline   shows the two states"
echo "  git show --stat candidate-0   shows what the agent added"
echo "Run the checks from inside gauntlet-sample/."
