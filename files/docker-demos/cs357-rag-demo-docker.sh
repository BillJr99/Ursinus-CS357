#!/usr/bin/env bash
# cs357-rag-demo-docker.sh: run the CS357 RAG and MCP demo in throwaway containers, then remove them.
# Needs only Docker and a network connection. It downloads about 3 GB, all of it removed at the end.
#
#   bash cs357-rag-demo-docker.sh
#   MODEL=llama3.2:3b RUNS=5 bash cs357-rag-demo-docker.sh     a different chat model, more repeats
#   PAUSE=1 bash cs357-rag-demo-docker.sh                      wait for Enter between steps
#
# Teardown removes this run's containers, volume and temporary folder. It removes an image only
# if that image was not already on your machine before the run. It also runs on Ctrl-C or an error.
set -u

DOCKER=${DOCKER:-docker}
MODEL=${MODEL:-llama3.2:1b}
RUNS=${RUNS:-3}
PAUSE=${PAUSE:-0}
OLLAMA_IMAGE=ollama/ollama:latest
PYTHON_IMAGE=python:3.12-slim
TAG=cs357-rag-$$
SERVER=$TAG-ollama
VOLUME=$TAG-models

if ! $DOCKER info >/dev/null 2>&1; then
  echo "Docker is not running, or this user cannot reach it. Nothing was changed."
  exit 1
fi

$DOCKER image inspect "$OLLAMA_IMAGE" >/dev/null 2>&1 && HAD_OLLAMA=1 || HAD_OLLAMA=0
$DOCKER image inspect "$PYTHON_IMAGE" >/dev/null 2>&1 && HAD_PYTHON=1 || HAD_PYTHON=0
WORK=$(mktemp -d "$HOME/.cs357-rag-demo.XXXXXX") || exit 1

teardown() {
  trap - EXIT INT TERM
  echo
  echo "=== Tearing down"
  $DOCKER rm -f "$SERVER" >/dev/null 2>&1
  $DOCKER volume rm "$VOLUME" >/dev/null 2>&1
  [ "$HAD_OLLAMA" = 0 ] && $DOCKER rmi "$OLLAMA_IMAGE" >/dev/null 2>&1
  [ "$HAD_PYTHON" = 0 ] && $DOCKER rmi "$PYTHON_IMAGE" >/dev/null 2>&1
  rm -rf "$WORK"
  echo "Containers left from this run: $($DOCKER ps -aq --filter "name=$TAG" | wc -l | tr -d ' ')"
  echo "Volumes left from this run:    $($DOCKER volume ls -q --filter "name=$TAG" | wc -l | tr -d ' ')"
  echo "Done."
}
trap teardown EXIT
trap 'exit 130' INT TERM

step() {
  echo
  echo "=== $1"
  if [ "$PAUSE" = 1 ]; then read -r -p "Press Enter to run it. " _ </dev/tty; fi
}

cat > "$WORK/rag_demo.py" <<'PYEOF'
# rag_demo.py: the co-op corpus from Thursday, with a real embedding model.
# Needs Ollama running and `ollama pull nomic-embed-text:v1.5`. Standard library only.
import json, math, sys, urllib.request

CORPUS = {
    "hours.md": "The co-op workshop is open Tuesday and Thursday from 4pm to 8pm, and Saturday from 10am to 2pm.\n\nThe workshop is closed on college holidays. Volunteers post closures on the front door.",
    "membership.md": "A semester membership costs $15 and includes unlimited stand time. Students with a college ID pay $10.\n\nEvery member completes a 30-minute orientation before using a repair stand.",
    "tools.md": "Truing stands and wheel tools stay in the workshop. Members may borrow a pump or a tire lever overnight for a $5 deposit.\n\nThe parts washer uses citrus degreaser only. Never pour solvent into the parts washer.",
    "safety.md": "Safety glasses are required whenever anyone is cutting a cable or a chain.\n\nReport any injury to the shift volunteer, who records it in the incident binder before the shift ends.",
}

def embed(texts):
    body = json.dumps({"model": "nomic-embed-text:v1.5", "input": texts}).encode()
    req = urllib.request.Request("http://localhost:11434/api/embed", body,
                                 {"Content-Type": "application/json"})
    return json.load(urllib.request.urlopen(req, timeout=120))["embeddings"]

def cosine(u, v):
    return sum(a * b for a, b in zip(u, v)) / (math.sqrt(sum(a * a for a in u)) * math.sqrt(sum(b * b for b in v)))

CHUNKS = [(f"{name[:-3]}-{i}", name, p) for name in sorted(CORPUS)
          for i, p in enumerate(CORPUS[name].split("\n\n"))]
VECTORS = embed([c[2] for c in CHUNKS])

def search(question, k=3):
    q = embed([question])[0]
    scored = sorted(((cosine(q, v), c) for v, c in zip(VECTORS, CHUNKS)), key=lambda x: -x[0])
    return scored[:k]

if __name__ == "__main__":
    question = sys.argv[1]
    hits = search(question)
    for score, (cid, name, text) in hits:
        print(f"# {score:.3f} {cid:<13} {text[:60]}", file=sys.stderr)
    context = "\n\n".join(f"[{name}] {text}" for _, (_, name, text) in hits)
    print("Answer using ONLY the passages below. Name the source file for each fact.\n"
          "If the passages do not contain the answer, say: I could not find that in your notes.\n\n"
          f"Passages:\n{context}\n\nQuestion: {question}")
PYEOF

cat > "$WORK/notes_server.py" <<'PYEOF'
# notes_server.py: Thursday's retriever, served as a real MCP tool over stdio.
from mcp.server.fastmcp import FastMCP
from rag_demo import search

mcp = FastMCP("coop-notes")

@mcp.tool()
def search_notes(question: str, k: int = 3) -> list[dict]:
    """Search the bike co-op notes. Returns the k closest passages, each with its source file."""
    return [{"score": round(s, 3), "id": cid, "source": name, "text": text}
            for s, (cid, name, text) in search(question, k)]

if __name__ == "__main__":
    mcp.run()
PYEOF

cat > "$WORK/mcp_raw.py" <<'PYEOF'
# mcp_raw.py: speak MCP by hand, so the three messages are visible.
import json, subprocess, sys

server = subprocess.Popen([sys.executable, "notes_server.py"], text=True,
                          stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

def send(msg):
    server.stdin.write(json.dumps(msg) + "\n")
    server.stdin.flush()

def rpc(id_, method, params):
    send({"jsonrpc": "2.0", "id": id_, "method": method, "params": params})
    reply = json.loads(server.stdout.readline())
    print(f"--> {method}\n<-- {json.dumps(reply['result'])[:420]}\n")

rpc(1, "initialize", {"protocolVersion": "2025-06-18", "capabilities": {},
                      "clientInfo": {"name": "by-hand", "version": "0"}})
send({"jsonrpc": "2.0", "method": "notifications/initialized"})
rpc(2, "tools/list", {})
rpc(3, "tools/call", {"name": "search_notes",
                      "arguments": {"question": "Who do I tell if I get hurt?", "k": 1}})
server.terminate()
PYEOF

python_run() {
  $DOCKER run --rm --network "container:$SERVER" -e PYTHONDONTWRITEBYTECODE=1 \
    -v "$WORK:/app" -w /app "$PYTHON_IMAGE" bash -c "$1"
}

ask() {
  local question=$1 name=$2 i
  step "Retrieve: $question"
  python_run "python3 rag_demo.py \"$question\" > $name.txt" || exit 1
  sed -n '/^Passages:/,$p' "$WORK/$name.txt"
  for i in $(seq 1 "$RUNS"); do
    echo
    echo "--- $MODEL, answer $i of $RUNS"
    $DOCKER exec -i "$SERVER" ollama run "$MODEL" < "$WORK/$name.txt" 2>/dev/null
  done
}

echo "=== Downloading images and models (the first run takes several minutes)"
$DOCKER pull -q "$OLLAMA_IMAGE" || exit 1
$DOCKER pull -q "$PYTHON_IMAGE" || exit 1
$DOCKER run -d --name "$SERVER" -v "$VOLUME:/root/.ollama" "$OLLAMA_IMAGE" >/dev/null || exit 1
for i in $(seq 1 30); do
  $DOCKER exec "$SERVER" ollama list >/dev/null 2>&1 && break
  sleep 2
done
$DOCKER exec "$SERVER" ollama pull nomic-embed-text:v1.5 >/dev/null 2>&1 || { echo "Could not pull the embedding model."; exit 1; }
$DOCKER exec "$SERVER" ollama pull "$MODEL" >/dev/null 2>&1 || { echo "Could not pull $MODEL."; exit 1; }

ask "Who do I tell if I get hurt?" hurt
ask "Does the co-op sell new bikes?" bikes

step "The same retriever as an MCP tool, three messages by hand"
python_run "pip install -q --disable-pip-version-check --root-user-action=ignore 'mcp[cli]<2' && python3 mcp_raw.py"
