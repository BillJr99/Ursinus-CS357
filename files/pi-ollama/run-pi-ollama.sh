#!/usr/bin/env bash
set -euo pipefail
# CS357: run the pi coding agent in a disposable container against host Ollama.
#
#   bash run-pi-ollama.sh [--recover|--continue|--resume]
#
# Edit the configuration variables below; no external launcher config is needed.
# Only the project is bind-mounted read/write.
# Sessions and diagnostics survive under <project>/.pi; runtime is disposable.
#
# HOW THIS RUNS, AND WHAT IT COSTS.  By default the agent runs as YOUR user
# account (PI_RUN_AS=user).  The container starts as root only long enough to
# install packages into a stock node image, then drops to your uid and gid and
# cannot take them back.  Files it writes into your project stay yours.
#
# It is NOT rootless even so, and the distinction matters: the container still
# STARTS as root, so anything an apt or npm package runs during install runs
# with that privilege.  For a container that is never root at any point, build
# the Dockerfile beside this file once.  README.md has those commands.
#
#   PI_RUN_AS=root bash run-pi-ollama.sh    <-- opt in to staying root
#
# Choose root only if you need the agent itself to install system packages.
# Container root is UID 0 on your host too, so the agent can then leave
# root-owned files in your project that you need sudo to edit, and a container
# escape is an escape from a root process.  See the tutorial:
# https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/FilesystemIsolation
#
# Before the first run, give Ollama a context window this script can work with:
#
#   OLLAMA_CONTEXT_LENGTH=8192 OLLAMA_HOST=0.0.0.0 ollama serve
#
# Ollama's default is 4096 tokens on machines under 24 GiB, and this launcher
# refuses to start below 8192.  That refusal is deliberate; see the tutorial.
PROJECT_DIR="${PI_PROJECT_DIR:-$PWD}"
BASE_IMAGE="${PI_BASE_IMAGE:-node:24-bookworm}"
PI_PACKAGE="${PI_PACKAGE:-@earendil-works/pi-coding-agent@0.85.1}"
# User configuration. Environment variables can override these defaults.
PI_RUN_AS="${PI_RUN_AS:-user}" # user or root; package bootstrap always runs as root
PI_USER_UID="${PI_USER_UID:-$(id -u)}" # used only in user mode
PI_USER_GID="${PI_USER_GID:-$(id -g)}" # used only in user mode
PI_OLLAMA_MODEL="${PI_OLLAMA_MODEL:-llama3.2}" # the course model; see the tutorial for stepping up
PI_OLLAMA_URL="${PI_OLLAMA_URL:-http://host.docker.internal:11434}"
PI_FALLBACK_CONTEXT="${PI_FALLBACK_CONTEXT:-8192}" # assumed only when Ollama does not report one
PI_MAX_CONTEXT="${PI_MAX_CONTEXT:-0}" # 0: no extra client ceiling, so a bigger server wins
PI_MAX_OUTPUT_TOKENS="${PI_MAX_OUTPUT_TOKENS:-8192}"
PI_KEEP_RECENT_TOKENS="${PI_KEEP_RECENT_TOKENS:-4096}"
PI_REASONING="${PI_REASONING:-auto}" # auto, on, off
PI_THINKING_LEVEL="${PI_THINKING_LEVEL:-medium}" # off, low, medium, high
PI_REQUEST_TIMEOUT="${PI_REQUEST_TIMEOUT:-300}" # startup request seconds
case "$PI_RUN_AS" in
    root|user) ;;
    *) echo "PI_RUN_AS must be root or user." >&2; exit 2 ;;
esac
if [[ ! "$PI_USER_UID" =~ ^[0-9]+$ || ! "$PI_USER_GID" =~ ^[0-9]+$ ]]; then
    echo "PI_USER_UID and PI_USER_GID must be numeric." >&2
    exit 2
fi
if [[ "$PI_RUN_AS" == user && "$PI_USER_UID" =~ ^0+$ ]]; then
    echo "User mode requires a nonzero PI_USER_UID, and this shell is uid 0." >&2
    echo "Set PI_USER_UID and PI_USER_GID to the account that owns the project," >&2
    echo "or run with PI_RUN_AS=root if you really do want the agent to be root." >&2
    exit 2
fi
PI_LAUNCH_MODE="new"
if (( $# > 1 )); then
    echo "Usage: bash run-pi-ollama.sh [--recover|--continue|--resume]" >&2
    exit 2
fi
case "${1:-}" in
    "") ;;
    --recover) PI_LAUNCH_MODE="recover" ;;
    --continue) PI_LAUNCH_MODE="continue" ;;
    --resume) PI_LAUNCH_MODE="resume" ;;
    --help|-h)
        echo "Usage: bash run-pi-ollama.sh [--recover|--continue|--resume]"
        echo "--recover starts fresh from RESUME.md; --continue reopens the last session."
        echo "Edit settings at the top of this script. PI_PROJECT_DIR selects the project."
        echo "Runs as your user by default. PI_RUN_AS=root keeps root; the Dockerfile route is never root."
        exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
esac
if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Project directory does not exist: $PROJECT_DIR" >&2
    exit 1
fi
PROJECT_DIR="$(cd -- "$PROJECT_DIR" && pwd -P)"
command -v docker >/dev/null || { echo "Docker is required." >&2; exit 1; }
echo "[launcher] Project RW mount: $PROJECT_DIR"
echo "[launcher] Runtime: $PI_PACKAGE; mode: $PI_LAUNCH_MODE; run as: $PI_RUN_AS"
echo "[launcher] Model: $PI_OLLAMA_MODEL at $PI_OLLAMA_URL"
if [[ "$PI_RUN_AS" == root ]]; then
    echo "[launcher] WARNING: you asked for root. The agent keeps full privileges." >&2
    echo "[launcher] Container root is UID 0 on your host, so files this agent" >&2
    echo "[launcher] creates under $PROJECT_DIR may come back owned by root." >&2
    echo "[launcher] Drop this setting to run as $(id -u):$(id -g) instead." >&2
else
    echo "[launcher] Setup runs as root, then the agent drops to $PI_USER_UID:$PI_USER_GID."
    echo "[launcher] Not rootless: the container still starts as root. See README.md."
fi
CONTAINER_SCRIPT="$(cat <<'CONTAINER_SCRIPT_EOF'
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq --no-install-recommends ca-certificates git python3 python3-pytest ripgrep util-linux >/dev/null
python3 --version
python3 -m pytest --version
rm -rf /var/lib/apt/lists/*
mkdir -p /opt/pi /opt/pi-launcher
npm install --prefix /opt/pi --ignore-scripts --no-audit --no-fund "$PI_PACKAGE" >/dev/null
PI_HOME="/tmp/pi-home"
mkdir -p "$PI_HOME/.pi/agent"
cat > /opt/pi-launcher/launcher.py <<'PY_LAUNCHER_EOF'
#!/usr/bin/env python3
"""Configure the disposable Pi process using the existing Ollama server."""
import datetime
import json
import os
from pathlib import Path
import re
import sys
import traceback
import urllib.error
import urllib.request
import uuid


def positive_int(value):
    """Return a positive integer, rejecting JSON booleans and fractional values."""
    return value if type(value) is int and value > 0 else None


def request_json(base, endpoint, payload=None, timeout=120):
    data = None if payload is None else json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(base + endpoint, data=data,
                                 headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as response:
        result = json.load(response)
    if not isinstance(result, dict):
        raise ValueError(f"{endpoint}: expected a JSON object")
    if result.get("error"):
        raise RuntimeError(f"{endpoint}: {result['error']}")
    return result


def model_key(name):
    """Normalize only Ollama's omitted default tag, preserving registry ports."""
    return name if ":" in name.rsplit("/", 1)[-1] else name + ":latest"


def active_context(data, model, digest):
    """Prefer an exact model name; use an unambiguous digest alias as fallback."""
    rows = [row for row in data.get("models", []) if isinstance(row, dict)]
    matches = [row for row in rows if any(
        isinstance(row.get(key), str) and model_key(row[key]) == model_key(model)
        for key in ("name", "model"))]
    if not matches and digest:
        matches = [row for row in rows if row.get("digest") == digest]
    contexts = [positive_int(row.get("context_length")) for row in matches]
    contexts = [value for value in contexts if value is not None]
    return min(contexts) if contexts else None


def model_limits(show):
    """Read the text architecture's limit, never a vision/projector limit."""
    info = show.get("model_info") or {}
    architecture = info.get("general.architecture")
    maximum = positive_int(info.get(f"{architecture}.context_length")) if architecture else None
    if maximum is None:
        candidates = [positive_int(value) for key, value in info.items()
                      if key.endswith(".context_length")
                      and not any(part in key.lower() for part in ("vision", "clip", "projector"))]
        candidates = [value for value in candidates if value is not None]
        maximum = min(candidates) if candidates else None
    match = re.search(r"(?m)^\s*num_ctx\s+(\d+)\s*$", show.get("parameters") or "")
    configured = positive_int(int(match.group(1))) if match else None
    return maximum, configured


def choose_context(active, maximum, configured, fallback, ceiling=None):
    """A fallback is an explicit operator assumption, not runtime detection."""
    if active:
        value, source = active, "Ollama /api/ps active allocation"
    else:
        value, source = fallback, "configured fallback (allocation not reported)"
        if configured:
            value = min(value, configured)
            source += "; capped by model num_ctx"
    for cap in (maximum, ceiling):
        if cap:
            value = min(value, cap)
    return value, source


def token_budgets(context, config):
    """Keep output and recent history well below the real context capacity.

    Trigger at C-R; retain K <= C/8. R reserves both response and tool growth.
    This is headroom, not a proof that arbitrary tool output will fit.
    """
    output = min(config["maxOutputTokens"], context // 4)
    reserve = min(context // 2, max(output + 2048, (context * 3) // 8))
    recent = min(config["keepRecentTokens"], context // 8)
    if context < 8192 or output < 1024:
        raise ValueError(f"Detected {context} tokens: too small for this skill. "
                         "Configure a larger context on the Ollama server, then restart.")
    return output, reserve, recent


def load_config():
    """Read settings passed from the editable variables at the top of run-pi.sh."""
    numeric = {"fallbackContextWindow": "PI_FALLBACK_CONTEXT", "maxOutputTokens": "PI_MAX_OUTPUT_TOKENS",
               "keepRecentTokens": "PI_KEEP_RECENT_TOKENS", "requestTimeoutSeconds": "PI_REQUEST_TIMEOUT"}
    config = {}
    for key, variable in numeric.items():
        value = os.environ.get(variable, "")
        if not re.fullmatch(r"[0-9]+", value) or int(value) <= 0:
            raise ValueError(f"{variable} must be a positive integer")
        config[key] = int(value)
    ceiling = os.environ.get("PI_MAX_CONTEXT", "")
    if not re.fullmatch(r"[0-9]+", ceiling):
        raise ValueError("PI_MAX_CONTEXT must be a nonnegative integer; 0 disables the ceiling")
    config["maxContextWindow"] = int(ceiling) or None
    config.update(model=os.environ.get("PI_OLLAMA_MODEL", ""), ollamaUrl=os.environ.get("PI_OLLAMA_URL", ""),
                  reasoning=os.environ.get("PI_REASONING", ""), thinkingLevel=os.environ.get("PI_THINKING_LEVEL", ""))
    if config.get("reasoning") not in ("auto", "on", "off"):
        raise ValueError("reasoning must be auto, on, or off")
    if config.get("thinkingLevel") not in ("off", "low", "medium", "high"):
        raise ValueError("thinkingLevel must be off, low, medium, or high")
    for key in ("model", "ollamaUrl"):
        if not isinstance(config.get(key), str) or not config[key]:
            raise ValueError(f"{key} must be a nonempty string")
    return config


def recover_prompt(root):
    checkpoint = root / ".small-model-orchestrator/RESUME.md"
    if not checkpoint.is_file() or checkpoint.stat().st_size == 0:
        raise ValueError("No RESUME.md checkpoint exists. Use --resume to inspect saved sessions, "
                         "or start normally and ask Pi to reconstruct from CONTRACT.md and STATE.md.")
    return ("Use the small-model-orchestrator skill to resume the interrupted task. "
            "Read .small-model-orchestrator/RESUME.md in bounded ranges, then verify its task "
            "identity and relevant disk state. Preserve the contract and permission boundaries. "
            "Treat any in-flight mutation as having UNKNOWN completion until independently checked. "
            "Do not replay the old transcript, rerun successful mutations, or assume a partial "
            "generated file is complete. Continue the next unverified action with its verifier.")


def main():
    root = Path(os.environ.get("PI_WORKSPACE", "/workspace")).resolve()
    config = load_config()
    model = config["model"]
    base = config["ollamaUrl"].rstrip("/")
    timeout = config["requestTimeoutSeconds"]
    mode = os.environ.get("PI_LAUNCH_MODE", "new")
    # Validate recovery before making a model request.
    recovery = recover_prompt(root) if mode == "recover" else None
    tags = request_json(base, "/api/tags", timeout=timeout)
    installed = [row for row in tags.get("models", [])
                 if isinstance(row, dict) and model_key(row.get("name", "")) == model_key(model)]
    if not installed:
        raise ValueError(f"Ollama is reachable, but {model!r} is not installed.")
    digest = installed[0].get("digest")
    show = {}
    maximum, configured = None, None
    try:
        show = request_json(base, "/api/show", {"model": model}, timeout)
        maximum, configured = model_limits(show)
    except Exception as e:
        print(f"[model metadata detection] {e}", file=sys.stderr)
        traceback.print_exc()
        print("[bootstrap] Model limits unavailable; trying active allocation, then configured fallback.", flush=True)
    capabilities = show.get("capabilities")
    reasoning = config["reasoning"] == "on" or (
        config["reasoning"] == "auto" and "thinking" in (capabilities or []))
    thinking = config["thinkingLevel"] if reasoning else "off"
    if config["reasoning"] == "auto" and not reasoning:
        print("[bootstrap] Ollama did not advertise thinking; Pi thinking is off. "
              "Set PI_REASONING=on only if you have verified this model supports it.", flush=True)
    # Probe the SAME OpenAI endpoint used by Pi. Do not set num_ctx on this probe:
    # doing so could measure a different runner configuration than Pi later uses.
    probe = {"model": model, "messages": [{"role": "user", "content": "Reply OK."}],
             "max_tokens": 1, "stream": False}
    if reasoning:
        probe["reasoning_effort"] = "none" if thinking == "off" else thinking
    print(f"[bootstrap] Loading/checking {model}; timeout {timeout}s...", flush=True)
    request_json(base, "/v1/chat/completions", probe, timeout)
    active = None
    try:
        active = active_context(request_json(base, "/api/ps", timeout=timeout), model, digest)
    except Exception as e:
        print(f"[context detection] {e}", file=sys.stderr)
        traceback.print_exc()
    context, source = choose_context(active, maximum, configured,
                                     config["fallbackContextWindow"], config.get("maxContextWindow"))
    if not active:
        print(f"[bootstrap] WARNING: using {context}-token fallback. This is not a verified "
              "allocation; lower PI_FALLBACK_CONTEXT if your server allocates less.", flush=True)
    output, reserve, recent = token_budgets(context, config)
    skill = next((root / path for path in (
        ".agents/skills/small-model-orchestrator",
        ".pi/skills/small-model-orchestrator") if (root / path / "SKILL.md").is_file()), None)
    if skill is None:
        raise ValueError("small-model-orchestrator/SKILL.md was not found under .agents/skills or .pi/skills")
    home = Path(os.environ["HOME"]) / ".pi/agent"
    home.mkdir(parents=True, exist_ok=True)
    sessions = root / ".pi/sessions"
    sessions.mkdir(parents=True, exist_ok=True)
    model_entry = {"id": model, "name": f"{model} (Ollama, {context} context)",
                   "contextWindow": context, "maxTokens": output, "reasoning": reasoning,
                   "input": ["text"], "compat": {"supportsDeveloperRole": False,
                   "supportsReasoningEffort": True, "maxTokensField": "max_tokens"}}
    models = {"providers": {"ollama": {"baseUrl": base + "/v1", "api": "openai-completions",
                                       "apiKey": "ollama", "models": [model_entry]}}}
    settings = {"defaultProvider": "ollama", "defaultModel": model,
                "defaultThinkingLevel": thinking,
                "compaction": {"enabled": True, "reserveTokens": reserve, "keepRecentTokens": recent}}
    # A project settings file can override generated global settings. Refuse
    # conflicting budgets rather than silently returning to an unsafe window.
    project_settings = root / ".pi/settings.json"
    if project_settings.is_file():
        project = json.loads(project_settings.read_text())
        compaction = project.get("compaction", {})
        for key, value in (("enabled", True), ("reserveTokens", reserve), ("keepRecentTokens", recent)):
            if key in compaction and compaction[key] != value:
                raise ValueError(f".pi/settings.json overrides compaction.{key}; "
                                 "review/remove that override before launching.")
        if compaction.get("modelOverrides"):
            raise ValueError("Review/remove project compaction.modelOverrides before using detected budgets.")
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ") + "-" + uuid.uuid4().hex[:8]
    run_dir = root / ".pi/launcher-runs" / stamp
    run_dir.mkdir(parents=True)
    diagnostics = {"model": model, "activeContext": active, "modelMaximum": maximum,
                   "modelNumCtx": configured, "contextWindow": context, "contextSource": source,
                   "allocationVerified": active is not None, "maxTokens": output,
                   "reserveTokens": reserve, "keepRecentTokens": recent, "reasoning": reasoning,
                   "thinkingLevel": thinking, "launchMode": mode}
    for name, value in (("models.json", models), ("settings.json", settings)):
        (home / name).write_text(json.dumps(value, indent=2) + "\n")
        (run_dir / name).write_text(json.dumps(value, indent=2) + "\n")
    (run_dir / "detected.json").write_text(json.dumps(diagnostics, indent=2) + "\n")
    print(f"[bootstrap] Context {context} ({source}); model maximum {maximum or 'unknown'}", flush=True)
    print(f"[bootstrap] Thinking {thinking}; output {output}; compact near {context-reserve}; keep recent {recent}", flush=True)
    print(f"[bootstrap] Sessions: {sessions}; diagnostics: {run_dir}", flush=True)
    print("[bootstrap] Recovery: /smo-recover in Pi, or bash run-pi-ollama.sh --recover after exit.", flush=True)
    binary = os.environ.get("PI_BIN", "/opt/pi/node_modules/.bin/pi")
    args = [binary, "--approve", "--no-skills", "--skill", str(skill),
            "--model", f"ollama/{model}", "--thinking", thinking,
            "--session-dir", str(sessions), "--extension", "/opt/pi-launcher/recovery.mjs",
            "--append-system-prompt", "Use the small-model-orchestrator skill for substantial tasks. "
            "Keep .small-model-orchestrator/RESUME.md current before and after consequential work. "
            "Context is finite; keep raw output on disk and use bounded reads."]
    if mode == "continue":
        args.append("--continue")
    elif mode == "resume":
        args.append("--resume")
    elif recovery:
        args.append(recovery)
    os.execv(binary, args)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"[pi launcher] {e}", file=sys.stderr)
        traceback.print_exc()
        sys.exit(1)

PY_LAUNCHER_EOF
cat > /opt/pi-launcher/recovery.mjs <<'JS_RECOVERY_EOF'
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";

export default function recovery(pi) {
  function record(ctx, kind, details) {
    try {
      const directory = path.join(ctx.cwd, ".pi", "recovery-events");
      fs.mkdirSync(directory, { recursive: true });
      const target = path.join(directory, `${Date.now()}-${crypto.randomUUID()}.json`);
      fs.writeFileSync(target, JSON.stringify({ kind, time: new Date().toISOString(),
        session: ctx.sessionManager.getSessionFile(), ...details }, null, 2) + "\n", { flag: "wx" });
    } catch (e) {
      console.error("[Pi recovery record]", e);
      console.error(e.stack);
    }
  }

  pi.on("turn_end", async (event, ctx) => {
    if (["length", "error", "aborted"].includes(event.message?.stopReason)) {
      record(ctx, "interrupted-turn", { stopReason: event.message.stopReason,
        error: event.message.errorMessage || null, turnIndex: event.turnIndex,
        toolResults: (event.toolResults || []).map(r => ({ toolCallId: r.toolCallId, isError: r.isError })) });
      ctx.ui.notify("Interrupted turn recorded. Check disk state before retrying. Use /smo-recover if context recovery fails.", "warning");
    }
  });

  pi.on("session_compact_failed", async (event, ctx) => {
    record(ctx, "compaction-failed", { reason: event.reason, error: event.errorMessage || null,
      aborted: event.aborted });
    if (!event.aborted) ctx.ui.notify("Compaction failed. /smo-recover starts a fresh session from RESUME.md.", "warning");
  });

  pi.registerCommand("smo-recover", {
    description: "Start a fresh session from the durable task checkpoint",
    handler: async (_args, ctx) => {
      await ctx.waitForIdle();
      const checkpoint = path.join(ctx.cwd, ".small-model-orchestrator", "RESUME.md");
      if (!fs.existsSync(checkpoint) || fs.statSync(checkpoint).size === 0) {
        ctx.ui.notify("No RESUME.md checkpoint. Inspect the saved session and reconstruct task state first.", "error");
        return;
      }
      const parentSession = ctx.sessionManager.getSessionFile();
      record(ctx, "fresh-session-requested", { checkpoint });
      await ctx.newSession({ parentSession, withSession: async (newContext) => {
        await newContext.sendUserMessage("Use small-model-orchestrator to resume the interrupted task. " +
          "Read .small-model-orchestrator/RESUME.md in bounded ranges, verify task identity and disk state, " +
          "and continue the next unverified action. Treat in-flight mutations as UNKNOWN until checked. " +
          "Preserve the contract and permissions. Do not reload the old transcript or replay successful mutations.");
      }});
    }
  });
}

JS_RECOVERY_EOF
if [[ "$PI_RUN_AS" == user ]]; then
    chown -R "$PI_USER_UID:$PI_USER_GID" "$PI_HOME"
    exec setpriv --reuid="$PI_USER_UID" --regid="$PI_USER_GID" --clear-groups \
        --bounding-set=-all --inh-caps=-all --ambient-caps=-all \
        env HOME="$PI_HOME" PATH="/opt/pi/node_modules/.bin:$PATH" \
        python3 /opt/pi-launcher/launcher.py
fi
exec env HOME="$PI_HOME" PATH="/opt/pi/node_modules/.bin:$PATH" \
    python3 /opt/pi-launcher/launcher.py
CONTAINER_SCRIPT_EOF
)"
exec docker run --rm -it --user 0:0 \
    --add-host=host.docker.internal:host-gateway \
    --security-opt=no-new-privileges --pids-limit=1024 \
    --mount "type=bind,src=$PROJECT_DIR,dst=/workspace" --workdir /workspace \
    -e "PI_PACKAGE=$PI_PACKAGE" -e "PI_RUN_AS=$PI_RUN_AS" \
    -e "PI_USER_UID=$PI_USER_UID" -e "PI_USER_GID=$PI_USER_GID" \
    -e "PI_OLLAMA_URL=$PI_OLLAMA_URL" -e "PI_FALLBACK_CONTEXT=$PI_FALLBACK_CONTEXT" \
    -e "PI_MAX_CONTEXT=$PI_MAX_CONTEXT" -e "PI_MAX_OUTPUT_TOKENS=$PI_MAX_OUTPUT_TOKENS" \
    -e "PI_KEEP_RECENT_TOKENS=$PI_KEEP_RECENT_TOKENS" -e "PI_REASONING=$PI_REASONING" \
    -e "PI_THINKING_LEVEL=$PI_THINKING_LEVEL" -e "PI_REQUEST_TIMEOUT=$PI_REQUEST_TIMEOUT" \
    -e "PI_OLLAMA_MODEL=$PI_OLLAMA_MODEL" -e "PI_LAUNCH_MODE=$PI_LAUNCH_MODE" \
    "$BASE_IMAGE" bash -lc "$CONTAINER_SCRIPT"
