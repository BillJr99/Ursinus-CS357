#!/usr/bin/env bash
# CS357 gauntlet-round sample kit, reference fix.
# Stands in for the agent's refine turn. Run from inside gauntlet-sample/.
set -euo pipefail

cat > artifact/search.py <<'KITEOF'
"""Search a small JSON knowledge base and print ranked results as JSON."""
import argparse
import json
import sys
import traceback

KB_PATH = "kb/knowledge_base.json"


def load_kb(path):
    """Return the list of documents stored at path."""
    with open(path, encoding="utf-8") as f:
        try:
            return json.load(f)
        except json.JSONDecodeError as e:
            print(f"[search:load_kb] knowledge base is not valid JSON: {e}", file=sys.stderr)
            traceback.print_exc()
            raise


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
    parser.add_argument("--max-results", type=int, default=5)
    args = parser.parse_args(argv)
    if not args.query.strip():
        print("[search:main] query must not be empty", file=sys.stderr)
        return 2
    if not 1 <= args.max_results <= 20:
        print("[search:main] --max-results must be between 1 and 20", file=sys.stderr)
        return 2
    try:
        results = search(args.query, args.max_results)
    except FileNotFoundError:
        print(f"[search:main] knowledge base not found at {KB_PATH}", file=sys.stderr)
        return 3
    print(json.dumps(results, indent=2))
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

    def test_max_results_limit(self):
        code, out = run(["agent", "--max-results", "2"])
        self.assertEqual(code, 0)
        self.assertLessEqual(len(json.loads(out)), 2)

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
git -c user.name=student -c user.email=student@example.com commit -qm "Candidate 1: address every material failure"
git tag candidate-1

echo "Candidate 1 committed and tagged. Re-run every check, not only the ones you revised."
