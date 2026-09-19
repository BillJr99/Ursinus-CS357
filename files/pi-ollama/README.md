# CS357: The Pi Coding Agent in a Container, Against Your Own Ollama

A coding agent that runs inside a container, edits exactly one folder, and gets
its model from the Ollama server on your own machine. No API key, no cloud, and
a blast radius you chose on purpose.

The full walk-through, with every line of the launcher explained, is the
[Terminal and Filesystem Isolation tutorial](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/FilesystemIsolation).
This README is the quickstart.

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | The recipe for the image. **The portable route**: build once, then run with two commands that are the same on every platform |
| `launcher.py` | Reconciles Ollama's real context allocation with what the agent is told, then starts it. `COPY`ed into the image |
| `recovery.mjs` | Records interrupted turns and failed compactions, and adds the `/smo-recover` command |
| `run-pi-ollama.sh` | The no-build route: one self-contained file, bash. Installs everything on every launch, **as root** |
| `run-pi-ollama.ps1` | The same no-build route, PowerShell |

Two routes, and the difference between them is the whole security lesson:

| | `Dockerfile` route | `run-pi-ollama.sh` / `.ps1` route |
|---|---|---|
| Setup | `docker build` once | None |
| Privileged work | At build time, once | On every launch |
| Who the agent runs as | The image's `agent` user, or you. **Never root** | **Your own uid**, unless you ask for `PI_RUN_AS=root` |
| Works offline | Yes, after the build | No: needs `apt-get` and `npm` every time |
| Start-up | Seconds | A minute or two |

Prefer the Dockerfile route. The script exists because one file you can read
top to bottom is worth something, and because it is the honest demonstration of
what "convenient" costs: even at its default setting it has to become root for
a moment, and only a build step can avoid that entirely.

## Step 0: Start Ollama so the container can reach it

Two settings, both required, both easy to miss.

```bash
OLLAMA_CONTEXT_LENGTH=8192 OLLAMA_HOST=0.0.0.0 ollama serve
```

```powershell
$env:OLLAMA_CONTEXT_LENGTH = "8192"
$env:OLLAMA_HOST = "0.0.0.0"
ollama serve
```

`OLLAMA_HOST=0.0.0.0` lets the container reach the server at all; by default
Ollama listens only on `127.0.0.1`, which a container cannot see. Anything that
can reach your machine on port 11434 can now use your models, so do this on
your own laptop, not on shared campus wifi.

`OLLAMA_CONTEXT_LENGTH=8192` matters just as much. Ollama's default is 4096
tokens on any machine under 24 GiB, and this launcher **refuses to start** below
8192. That refusal is deliberate, and the tutorial explains why a context window
too small to hold the task is a correctness problem rather than a speed problem.

## Step 1: Put the skill in your project

The launcher will not start without it. It looks in three places, in order, and
stops at the first `SKILL.md` it finds:

```
.skills/small-model-orchestrator/SKILL.md
.pi/skills/small-model-orchestrator/SKILL.md
.agents/skills/small-model-orchestrator/SKILL.md   <-- use this one
```

**Extract the `.skill` file into `.agents/skills/`.**  A `.skill` file is a zip
archive with the skill directory at its top level, so unzipping it into
`.agents/skills/` produces `.agents/skills/small-model-orchestrator/SKILL.md`,
which is the third path the launcher looks for.  Use that one because it is also
one of the directories opencode reads, so a single skills directory serves both
tools and you never have to remember which project uses which convention.  The
other two paths still work if you set one of them up earlier.
From the root of the project you want the agent to work on:

```bash
mkdir -p .agents/skills
curl -fsSL -o smo.skill https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/files/small-model-orchestrator.skill
unzip -q smo.skill -d .agents/skills/ && rm smo.skill
ls .agents/skills/small-model-orchestrator/SKILL.md
```

```powershell
New-Item -ItemType Directory -Force -Path .agents\skills | Out-Null
curl.exe -fsSL -o smo.zip https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/files/small-model-orchestrator.skill
Expand-Archive -Path smo.zip -DestinationPath .agents\skills -Force; Remove-Item smo.zip
Get-Item .agents\skills\small-model-orchestrator\SKILL.md
```

`Expand-Archive` needs the file to end in `.zip`, which is why the PowerShell
version downloads it under that name.  The contents are identical.

> **Check the shape, not just that it downloaded.**  `SKILL.md` must sit at
> `.agents/skills/small-model-orchestrator/SKILL.md`.  If your unzip tool created an
> extra folder level, so that the path is
> `.agents/skills/small-model-orchestrator/small-model-orchestrator/SKILL.md`, move the
> inner directory up one level or the launcher will not find it.

> If you skip this step the launcher stops with
> `small-model-orchestrator/SKILL.md was not found under .skills, .pi/skills, or .agents/skills`.
> That is the error telling you it did exactly what it promised, not a broken install.

## Step 2a: The Dockerfile route (recommended)

Build once, from this directory. The command is identical everywhere:

```
docker build -t course-pi-ollama .
```

Then, from the project directory you want the agent to work on:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  --add-host=host.docker.internal:host-gateway \
  --security-opt=no-new-privileges --cap-drop ALL --pids-limit=1024 \
  -v "$PWD:/workspace" -w /workspace \
  -e PI_OLLAMA_MODEL=llama3.2 \
  course-pi-ollama
```

```powershell
docker run --rm -it `
  --add-host=host.docker.internal:host-gateway `
  --security-opt=no-new-privileges --cap-drop ALL --pids-limit=1024 `
  -v "${PWD}:/workspace" -w /workspace `
  -e PI_OLLAMA_MODEL=llama3.2 `
  course-pi-ollama
```

Three differences between those two, all of them real:

- **Line continuation** is `\` in bash and a backtick in PowerShell.
- **`$PWD` needs braces in PowerShell**, as `${PWD}`, or the `:` that follows is
  read as part of the variable name.
- **`--user` is on the bash version only.** On Linux and macOS, a container
  writing into a bind mount writes with the container's uid, so without this flag
  the agent leaves files in your project owned by whoever it ran as. Passing your
  own uid and gid makes the files yours. Docker Desktop on Windows translates
  ownership at the mount instead, so the flag has nothing to do there.

## Step 2b: The no-build route

One file, no image. It runs as **your** user account by default:

```bash
bash run-pi-ollama.sh
```

```powershell
.\run-pi-ollama.ps1
```

The container starts as root, installs the packages a stock `node` image lacks,
then drops to your uid and gid and cannot take the privilege back. Files it
writes into your project stay yours.

This is **not rootless**, and the difference is worth holding onto: the container
still *starts* as root, so anything an `apt` or `npm` package chooses to run
during installation runs with that privilege. Only the Dockerfile route is never
root at any point.

If you genuinely need the agent to install system packages itself, opt in:

```bash
PI_RUN_AS=root bash run-pi-ollama.sh
```

```powershell
$env:PI_RUN_AS = "root"; .\run-pi-ollama.ps1
```

Both print a warning when you do. On Linux and macOS that choice is what leaves
root-owned files in your project; on Windows, Docker Desktop translates ownership
at the mount, so the file-ownership half of the problem is not yours. The other
half is: the agent would hold full privileges inside the container.

## Resuming after an interruption

| Command | What it does |
|---|---|
| `--recover` / `-Mode Recover` | Start a fresh session from the `RESUME.md` checkpoint |
| `--continue` / `-Mode Continue` | Reopen the last session |
| `--resume` / `-Mode Resume` | Choose from saved sessions |
| `/smo-recover` | The same fresh-session recovery, from inside the agent |

Sessions and diagnostics live under `<project>/.pi/`; the task checkpoint lives
under `<project>/.small-model-orchestrator/`. The container is disposable and
those directories are not, which is the point.

## Settings

Every setting is an environment variable, read by both routes.

| Variable | Default | Meaning |
|---|---|---|
| `PI_OLLAMA_MODEL` | `llama3.2` | The course model. See the tutorial for stepping up |
| `PI_OLLAMA_URL` | `http://host.docker.internal:11434` | Your host's Ollama |
| `PI_FALLBACK_CONTEXT` | `8192` | Assumed **only** when Ollama does not report an allocation |
| `PI_MAX_CONTEXT` | `0` | An extra client-side ceiling; 0 means none |
| `PI_RUN_AS` | `user` | `user` or `root`. Script route only |
| `PI_REASONING` | `auto` | `auto`, `on`, `off` |
| `PI_THINKING_LEVEL` | `medium` | `off`, `low`, `medium`, `high` |
| `PI_PROJECT_DIR` | current directory | What the agent may change |

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Ollama is reachable, but 'llama3.2' is not installed` | The model was never pulled | `ollama pull llama3.2` |
| Connection refused, or the launcher hangs at "Loading/checking" | Ollama is bound to `127.0.0.1` | Restart it with `OLLAMA_HOST=0.0.0.0` |
| `Detected 4096 tokens: too small for this skill` | Ollama's default window | Restart with `OLLAMA_CONTEXT_LENGTH=8192` |
| `SKILL.md was not found` | Step 1 was skipped | Install the skill into `.agents/skills/` |
| `host.docker.internal` does not resolve, on Linux | Docker Engine does not provide it | Keep `--add-host=host.docker.internal:host-gateway` |
| New files in the project are owned by root | You set `PI_RUN_AS=root` on Linux or macOS | `sudo chown -R "$(id -u):$(id -g)" .`, then drop the setting |
| PowerShell: `-v "$PWD:/workspace"` mounts the wrong path | `$PWD:` parsed as one name | Write `${PWD}` |

Prove the network before you debug anything else:

```bash
docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl \
  -s http://host.docker.internal:11434/v1/models
```

JSON means the network is fine and the problem is configuration.

## Keeping the two copies of the launcher in sync

`launcher.py` and `recovery.mjs` are the same code as the heredocs inside
`run-pi-ollama.sh`. If you edit one, edit the other. This checks:

```bash
diff <(sed -n "/^cat > \/opt\/pi-launcher\/launcher.py <<'PY_LAUNCHER_EOF'$/,/^PY_LAUNCHER_EOF$/p" run-pi-ollama.sh | sed '1d;$d') <(sed '2,5d' launcher.py)
```

No output means they match.
