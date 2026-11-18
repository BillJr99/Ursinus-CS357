#!/usr/bin/env bash
set -euo pipefail
test "$(id -u)" -ne 0
test "$PWD" = /workspace
test -z "$(find / -name outside-cs357-demo.txt -print -quit 2>/dev/null || true)"
if touch /etc/cs357-demo 2>/dev/null; then echo 'Unexpected write to /etc'; exit 1; fi
echo "Only the project is mounted. The container filesystem is read-only."
jq -e '.permission["*"] == "ask"' "$OPENCODE_CONFIG" >/dev/null
grep -q 'approvalMode: always-ask' "$HOME/.omp/agent/config.yml"
git status --short
herdr --version
opencode --version
omp --version
herdr server >/tmp/herdr-demo-server.log 2>&1 &
trap 'herdr server stop >/dev/null 2>&1 || true' EXIT
for attempt in $(seq 1 30); do
  if herdr pane list >/tmp/herdr-panes.json 2>/dev/null; then break; fi
  sleep 0.2
done
herdr workspace create --cwd /workspace --label 'Agent project' >/tmp/workspace.json
first=$(herdr pane list | jq -r '.result.panes[-1].pane_id')
herdr pane split "$first" --direction right --cwd /workspace >/tmp/split.json
second=$(herdr pane list | jq -r --arg first "$first" '.result.panes[] | select(.pane_id != $first) | .pane_id' | tail -1)
herdr pane run "$first" opencode
herdr pane run "$second" omp
for attempt in $(seq 1 30); do
  herdr pane list >/tmp/herdr-panes.json
  if jq -e '[.result.panes[].agent] | index("opencode") != null and index("omp") != null' /tmp/herdr-panes.json >/dev/null; then break; fi
  sleep 0.5
done
jq -r '.result.panes[] | select(.agent != null) | [.agent, .cwd] | @tsv' /tmp/herdr-panes.json
herdr pane read "$first" --source visible --lines 15
herdr pane read "$second" --source visible --lines 15
jq -e '[.result.panes[].agent] | index("opencode") != null and index("omp") != null' /tmp/herdr-panes.json >/dev/null
printf '\nReviewed from the container shell.\n' >> notes.txt
git status --short
git diff -- notes.txt
