# OpenCode in Herdr TUI: Docker teaching example

This optional CS357 example installs OpenCode **2.3.0** and Herdr **TUI 0.9.5** in a Linux amd64 image. Herdr opens a terminal pane running `opencode --standalone --auto`. It is the TUI product, not the separate Herdr desktop application.

**Use only a disposable project without secrets.** This deliberately permissive example automatically approves operations except configured deny patterns. An `rm` deny does not prevent deletion by other means. The project bind mount is read/write, so changes affect your host files immediately. Read the [instructor notes](INSTRUCTOR-NOTES.md), including the security limits, before running it.

## Get the source

Extract `opencode-herdr.zip` into its own directory, or obtain this entire `opencode-herdr` directory from the course repository. Keep the dotfile `.dockerignore`. The directory contains the Dockerfile, two configurations, the pane launcher, POSIX and PowerShell build/run scripts, and these notes. Build from this directory, not an entire project or course repository.

Docker must be installed and running. Windows requires Docker Desktop in **Linux containers** mode. These commands download tools during the image build. They do not install a model or configure a provider.

## POSIX shell: Linux and macOS

Open a terminal in the extracted `opencode-herdr` directory:

```sh
bundle=$(pwd -P)
sh "$bundle/build.sh"
# Change to the disposable project you intend the agent to see:
cd ../disposable-project
sh "$bundle/run.sh"
```

Create or choose `disposable-project` beforehand. It is not included in the download. The build script uses its own directory as the build context and your numeric UID/GID for the nonroot `coder` account. Run as a regular user, not root. A UID/GID collision with an existing image account intentionally fails the build; do not work around it with privileged mode or `chmod 777`.

Equivalent commands, with `bundle` still naming the extracted source:

```sh
docker build --platform linux/amd64 \
  --build-arg "CODER_UID=$(id -u)" --build-arg "CODER_GID=$(id -g)" \
  -t cs357-herdr-opencode:nov17-candidate "$bundle"
docker run --rm -it --init --platform linux/amd64 \
  --cap-drop ALL --security-opt no-new-privileges \
  --mount "type=bind,src=$(pwd -P),dst=/workspace" \
  cs357-herdr-opencode:nov17-candidate
```

## PowerShell: syntax-reviewed, not executed on Windows

Open PowerShell in the extracted `opencode-herdr` directory:

```powershell
$bundle = (Get-Location).ProviderPath
& "$bundle\build.ps1"
Set-Location '..\disposable-project'
& "$bundle\run.ps1"
```

Equivalent single-line commands avoid backtick continuation issues:

```powershell
docker build --platform linux/amd64 -t cs357-herdr-opencode:nov17-candidate $bundle
$project = (Get-Location).ProviderPath
docker run --rm -it --init --platform linux/amd64 --cap-drop ALL --security-opt no-new-privileges --mount "type=bind,src=$project,dst=/workspace" cs357-herdr-opencode:nov17-candidate
```

Docker Desktop must permit sharing the chosen project path. Use ordinary filesystem paths without commas because Docker's `--mount` fields are comma-delimited. Paths with spaces are quoted. Follow your institution's approved PowerShell script policy; do not globally disable execution-policy protections for this example.

## What starts and what persists

`build.sh` and `build.ps1` create the image. `run.sh` and `run.ps1` attach the **current project directory** at `/workspace` and start Herdr. `WORKDIR /workspace` alone would not attach any host files. The source directory and the mounted project are separate choices.

Herdr's prefix is `Ctrl+B`; press `Ctrl+B` then `?` for keybinding help. Its configured pane executable starts OpenCode, including in new panes. For a diagnostic Bash shell, override the command after the image name:

```sh
docker run --rm -it --init --platform linux/amd64 \
  --cap-drop ALL --security-opt no-new-privileges \
  --mount "type=bind,src=$(pwd -P),dst=/workspace" \
  cs357-herdr-opencode:nov17-candidate bash
```

No credentials are included or mounted. A model exercise needs a separately chosen and authorized provider, network access, costs, and any scoped credentials. The earlier local-Ollama recipe in the deck is a separate setup, not configured by this bundle. This image does not include `gh` or the `requests`/`pytest` dependencies used elsewhere in the deck. Do not assume it replaces the full course image.

`--rm` discards the container's internal state when it stops, **not** the bind-mounted project. Detaching the Herdr client does not guarantee that background work has stopped. Review the host's `git status` and `git diff` before keeping changes; Git does not recover every untracked or uncommitted deletion.

## Verification scope

The source candidate was verified on **2026-11-17**, Linux amd64 with Docker Engine **29.10.0**. Its Dockerfile, configuration, launchers, and scripts are copied unchanged here. The earlier raw seed had not been build-tested; this version incorporates corrections and a successful real build.

Verified on the source candidate: Docker build and Herdr binary hash check, nonroot identity, OpenCode configuration loading and schema validation, Herdr integration installation/status, host-visible fixture bind writes and Git commands, actual OpenCode pane output, and the default Herdr command through a real PTY. Runtime checks used `--network none`, no provider credentials, and no model prompts. Build downloads used the network.

**Not verified:** model-originated permission enforcement, provider authentication/completions, Windows/PowerShell execution, native ARM, macOS or ARM emulation, pending-permission UI, restore/resume behavior, or live working/blocked transitions. An exploratory direct permission API probe denied even Git; its cause is unresolved and it is not evidence of successful enforcement. Intended deny behavior is supported by loaded configuration and the official documented contract, not an end-to-end model test.

Apple Silicon and other ARM machines require working amd64 emulation for this asset/checksum pair. No claim of cross-platform execution follows from the script examples. The base digest and tool versions are pinned, but apt repositories, the Dockerfile frontend, and npm transitive dependencies remain time-dependent, so this is not a fully locked supply chain.

See [INSTRUCTOR-NOTES.md](INSTRUCTOR-NOTES.md) for the implementation walkthrough, security discussion, and official source URLs. Those notes are public companion material, not hidden or instructor-only content.
