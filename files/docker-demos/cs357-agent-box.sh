#!/usr/bin/env bash
# cs357-agent-box.sh: open Oh My Pi and OpenCode in a locked-down container that can see only the
# directory you run this from, with a small local model as the default for both agents. When you
# exit, containers and other run resources are removed; Docker may keep build cache. Needs only Docker and a network connection; no API key.
#
#   cd some-project && bash /path/to/cs357-agent-box.sh                Herdr inside the box
#   bash /path/to/cs357-agent-box.sh bash                              a shell inside the box
#   NO_MODEL=1 bash /path/to/cs357-agent-box.sh                        Herdr with no runtime network
#   bash /path/to/cs357-agent-box.sh omp                         start Oh My Pi
#   bash /path/to/cs357-agent-box.sh opencode                    start OpenCode
#   MODEL=qwen3:1b bash /path/to/cs357-agent-box.sh              a different local model
#   NET=none bash /path/to/cs357-agent-box.sh                    the box can reach the model and nothing else
#   URSINUSAI_API_KEY set in your shell                          use https://ursinus.ai/api/v1 instead of the local model
#   URSINUSAI_MODEL=name                                         with that key, choose the model (default: the first one listed)
#   PASS_KEYS=1 bash /path/to/cs357-agent-box.sh                 also pass hosted-model API keys set in your shell
#
# The current directory is mounted read-write at /workspace, and it is the only host path the
# container gets. An agent can change or delete anything in it, so use a clean git tree.
# With no Ursinus AI key the local model is used. A key reaches the container by name only, but an
# agent inside can read any key it is given. Set it with read -rs, then export, not on a shared screen.
# Small local models are slow on a CPU and make mistakes with tools; that is part of the lesson.
# Agent settings live in memory and vanish on exit.
#
# Teardown removes the containers, network, volume, temporary files and the image built for this
# run, and the base images if they were not already on your machine. It also runs on Ctrl-C or an
# error. Your directory is left as it is.
set -u

DOCKER=${DOCKER:-docker}
MODEL=${MODEL:-llama3.2:1b}
OLLAMA_IMAGE=ollama/ollama:latest
BASE=oven/bun:1.4.4-debian@sha256:93d5032fe06d163427822dc1598f420363759bb18155c9cc90eb1be05a64a19e
TAG=cs357-agent-box-$$
IMAGE=$TAG:local
SERVER=$TAG-ollama
VOLUME=$TAG-models
NETWORK=$TAG-net
KEYS="OPENROUTER_API_KEY ANTHROPIC_API_KEY OPENAI_API_KEY GEMINI_API_KEY"

HERE=$(pwd -P)
LAUNCHER_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P) || exit 1
DOCKERFILE=$LAUNCHER_DIR/AgentBox.Dockerfile
case "$LAUNCHER_DIR/" in
  "$HERE/"*) echo "Keep the launcher and Dockerfile outside the shared project." >&2; exit 1 ;;
esac
if [ -L "${BASH_SOURCE[0]}" ] || [ -L "$DOCKERFILE" ]; then
  echo "Use regular files for the launcher and Dockerfile." >&2
  exit 1
fi
if [ ! -f "$DOCKERFILE" ]; then
  echo "Put AgentBox.Dockerfile beside cs357-agent-box.sh before running it." >&2
  exit 1
fi
if [ "$(id -u)" = 0 ]; then
  echo "Run this launcher as your ordinary workstation user, without sudo." >&2
  exit 1
fi
if [ "$HERE" = "/" ] || [ "$HERE" = "$(cd "$HOME" && pwd -P)" ]; then
  echo "Refusing to share $HERE. cd into a single project directory first. Nothing was changed."
  exit 1
fi
if [ -n "${URSINUSAI_API_KEY:-}" ] && [ "${NET:-}" = "none" ]; then
  echo "NET=none cannot reach ursinus.ai. Unset one of them. Nothing was changed."
  exit 1
fi
if ! $DOCKER info >/dev/null 2>&1; then
  echo "Docker is not running, or this user cannot reach it. Nothing was changed."
  exit 1
fi

$DOCKER image inspect "$BASE" >/dev/null 2>&1 && HAD_BASE=1 || HAD_BASE=0
$DOCKER image inspect "$OLLAMA_IMAGE" >/dev/null 2>&1 && HAD_OLLAMA=1 || HAD_OLLAMA=0
WORK=$(mktemp -d "$HOME/.cs357-agent-box.XXXXXX") || exit 1

teardown() {
  trap - EXIT INT TERM
  echo
  echo "=== Tearing down"
  $DOCKER rm -f "$TAG" "$SERVER" >/dev/null 2>&1
  [ "$NETWORK" = none ] || $DOCKER network rm "$NETWORK" >/dev/null 2>&1
  $DOCKER volume rm "$VOLUME" >/dev/null 2>&1
  $DOCKER rmi -f "$IMAGE" >/dev/null 2>&1
  [ "$HAD_BASE" = 0 ] && $DOCKER rmi "$BASE" >/dev/null 2>&1
  [ "$HAD_OLLAMA" = 0 ] && $DOCKER rmi "$OLLAMA_IMAGE" >/dev/null 2>&1
  rm -rf "$WORK"
  echo "Containers left from this run: $($DOCKER ps -aq --filter "name=$TAG" | wc -l | tr -d ' ')"
  echo "Images left from this run:     $($DOCKER images -q "$TAG" | wc -l | tr -d ' ')"
  echo "Volumes left from this run:    $($DOCKER volume ls -q --filter "name=$TAG" | wc -l | tr -d ' ')"
  echo "Networks left from this run:   $($DOCKER network ls -q --filter "name=$TAG" | wc -l | tr -d ' ')"
  echo "Done."
}
trap teardown EXIT
trap 'exit 130' INT TERM

if [ "${NO_MODEL:-}" = 1 ]; then
  PROVIDER_NAME="Offline launch check"
  BASE_URL=http://127.0.0.1:11434/v1
  CONTEXT=16384
  OPENCODE_KEY=
  OMP_AUTH='auth: none'
  NETWORK=none
  unset URSINUSAI_API_KEY
elif [ -n "${URSINUSAI_API_KEY:-}" ]; then
  PROVIDER_NAME="Ursinus AI"
  BASE_URL=https://ursinus.ai/api/v1
  CONTEXT=128000
  OPENCODE_KEY=', "apiKey": "{env:URSINUSAI_API_KEY}"'
  OMP_AUTH='apiKey: URSINUSAI_API_KEY'
  MODEL=${URSINUSAI_MODEL:-}
  if [ -z "$MODEL" ]; then
    echo "=== Asking Ursinus AI which models this key can use"
    MODEL=$($DOCKER run --rm -e URSINUSAI_API_KEY --entrypoint bun "$BASE" -e '
      const r = await fetch("https://ursinus.ai/api/v1/models", {headers: {Authorization: "Bearer " + process.env.URSINUSAI_API_KEY}});
      if (!r.ok) { console.error("Ursinus AI answered " + r.status); process.exit(1); }
      const ids = (await r.json()).data.map(m => m.id);
      console.error("Available: " + ids.join(", "));
      console.log(ids[0]);
    ') || { echo "Could not list models with that key."; exit 1; }
  fi
  echo "=== Using Ursinus AI, model $MODEL"
  $DOCKER network create "$NETWORK" >/dev/null || exit 1
else
  PROVIDER_NAME="Local Ollama"
  BASE_URL=http://ollama:11434/v1
  CONTEXT=16384
  OPENCODE_KEY=
  OMP_AUTH='auth: none'
  echo "=== Starting the local model $MODEL"
  if [ "${NET:-}" = "none" ]; then $DOCKER network create --internal "$NETWORK" >/dev/null || exit 1
  else $DOCKER network create "$NETWORK" >/dev/null || exit 1; fi
  $DOCKER pull -q "$OLLAMA_IMAGE" >/dev/null || exit 1
  $DOCKER run -d --name "$SERVER" -e OLLAMA_CONTEXT_LENGTH=16384 -v "$VOLUME:/root/.ollama" "$OLLAMA_IMAGE" >/dev/null || exit 1
  for i in $(seq 1 30); do
    $DOCKER exec "$SERVER" ollama list >/dev/null 2>&1 && break
    sleep 2
  done
  $DOCKER exec "$SERVER" ollama pull "$MODEL" >/dev/null 2>&1 || { echo "Could not pull $MODEL."; exit 1; }
  $DOCKER network connect --alias ollama "$NETWORK" "$SERVER" || exit 1
fi

cat > "$WORK/opencode.json" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "local": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "$PROVIDER_NAME",
      "options": { "baseURL": "$BASE_URL"$OPENCODE_KEY },
      "models": { "$MODEL": { "name": "$MODEL", "tools": true } }
    }
  },
  "model": "local/$MODEL",
  "permission": { "*": "ask" }
}
EOF
cat > "$WORK/models.yml" <<EOF
providers:
  local:
    baseUrl: $BASE_URL
    api: openai-completions
    $OMP_AUTH
    models:
      - id: "$MODEL"
        name: "$MODEL"
        reasoning: false
        input: [text]
        contextWindow: $CONTEXT
        maxTokens: 4096
EOF
cat > "$WORK/config.yml" <<EOF
modelRoles:
  default: "local/$MODEL"
tools:
  approvalMode: always-ask
EOF
cat > "$WORK/box-start" <<'EOF'
#!/bin/bash
mkdir -p "$HOME/.omp/agent"
export XDG_RUNTIME_DIR="$HOME/.run"
export TMPDIR="$HOME/.tmp"
mkdir -m 700 -p "$XDG_RUNTIME_DIR" "$TMPDIR"
export SHELL=/bin/bash
export TERM="${TERM:-xterm-256color}"
cp /opt/agents/seed/models.yml /opt/agents/seed/config.yml "$HOME/.omp/agent/"
exec "$@"
EOF
chmod 755 "$WORK/box-start"
chmod 644 "$WORK/opencode.json" "$WORK/models.yml" "$WORK/config.yml"

echo "=== Building the agent box"
cp "$DOCKERFILE" "$WORK/Dockerfile" || exit 1
$DOCKER build -t "$IMAGE" "$WORK" || exit 1

KEY_ARGS=()
if [ "${PASS_KEYS:-}" = 1 ] && [ "${NO_MODEL:-}" != 1 ]; then
  for k in $KEYS; do
    if [ -n "${!k:-}" ]; then KEY_ARGS+=(-e "$k"); fi
  done
fi
if [ -t 0 ]; then TTY=-it; else TTY=-i; fi

echo "=== In the box, using $MODEL ($PROVIDER_NAME). Only $HERE is visible, at /workspace. Type exit to leave."
$DOCKER run --rm "$TTY" --name "$TAG" --hostname agent-box --read-only \
  --tmpfs /tmp \
  --tmpfs /home/bun:exec,mode=1777 \
  --cap-drop=ALL --security-opt no-new-privileges \
  --pids-limit 512 --memory 2g \
  --user "$(id -u):$(id -g)" -e HOME=/home/bun \
  -e OPENCODE_CONFIG=/opt/agents/seed/opencode.json \
  ${URSINUSAI_API_KEY:+-e URSINUSAI_API_KEY} \
  --network "$NETWORK" --entrypoint /opt/agents/seed/box-start \
  ${KEY_ARGS[@]+"${KEY_ARGS[@]}"} \
  -v "$HERE:/workspace" -w /workspace \
  "$IMAGE" "$@"
