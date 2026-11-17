# Instructor / speaker notes: OpenCode, Herdr TUI, and Docker

Companion to Section 1, *Recap and Recovery*, in the coding-agents deck. These are ordinary public Markdown notes, not a hidden LiaScript speaker channel. Keep the slide discussion brief and use the downloadable source for the implementation. Follow the [README](README.md) for complete POSIX and PowerShell commands and verification limits.

## Teaching purpose and sequence

The example separates three decisions: which tools the image contains, which host directory the container can reach, and which operations the agent harness approves. Herdr arranges terminal panes. OpenCode runs the coding-agent loop. Docker supplies the process environment and mounts. None of those roles makes automatic approval safe for hostile code.

1. Begin with a disposable project, not a home directory or a live assignment. Ask students to identify the host directory they are about to expose before running anything.
2. Open `Dockerfile` and distinguish build-time installation from runtime startup. Open the build script and identify its build context.
3. Open the run script and trace the current host directory to `/workspace`. Ask: if the agent edits a mounted file, when does the host see the change?
4. Open `opencode.json` and `demo-pane`. Compare the explicit Git allowance with the `rm` deny rules. Ask students whether allowing Git still permits destructive operations. Do not execute destructive examples.
5. Relate this example to Section 4b's model-rule/gate distinction, but identify the version boundary: this bundle uses OpenCode **V2**, while the deck's older `permission.bash` examples illustrate the V1 form. Do not paste the V1 object into this V2 image.
6. Return to plan review and change review. This is an optional setup example, not a requirement to replace an already working course environment. The image does not include every dependency used later in the deck.

A written prediction about build context, mounted files, and deletion bypasses is sufficient for this discussion. A live model call is not needed to explain or inspect the setup.

## Walk through the Dockerfile

Read the complete [Dockerfile](Dockerfile) alongside these notes rather than projecting it as one slide.

- `FROM` selects digest-pinned `node:22-bookworm-slim`. Node/npm support the OpenCode CLI installation. Debian tools include Bash, certificates, curl, Git, Python 3, ripgrep, and procps.
- `RUN` executes **during image construction**. It installs `@opencode/cli@2.3.0`, downloads Herdr TUI `v0.9.5`'s Linux x86_64 asset, checks its SHA-256, and makes it executable. The hash is an observed checksum of the official release download, not an independently audited signature guarantee. The `rm` in apt cleanup is a Docker build command, not an agent tool invocation governed by OpenCode's later runtime config.
- The account commands rename the base image's `node` user/group to `coder` and create its directories. POSIX build arguments match the host user's UID/GID so ordinary Linux bind mounts can be writable. The defaults are 1000:1000; Windows examples retain those defaults. Nonroot execution and UID matching do not make a writable project safe from the agent.
- `COPY` installs the supplied system OpenCode config, Herdr config, and executable pane wrapper. `.dockerignore` admits only the Dockerfile, itself, and those three runtime source files into the build context. It does not control a later runtime mount.
- `USER coder` precedes `RUN herdr integration install opencode`. This ensures the integration lands in the runtime user's home, whose OpenCode config directory already exists. Installing it as root would configure the wrong user.
- `WORKDIR /workspace` sets the default working directory inside the image. It does not copy or mount a host project.
- `CMD ["herdr"]` selects the default program when a container starts. A command after the image name, such as `bash`, overrides it.

## Trace the pane startup

[herdr.toml](herdr.toml) disables onboarding and points `terminal.default_shell` to `/usr/local/bin/demo-pane`. That setting takes an executable path, not a string containing a command and flags. New panes use their current working directory; automatic agent restore is disabled in this config, but restore/resume behavior was not tested.

[demo-pane](demo-pane) checks for `HERDR_PANE_ID`. In a Herdr pane, unless `DEMO_AUTOSTART=0`, it replaces itself with `opencode --standalone --auto`. `--standalone` uses a private OpenCode server. Actual 2.3.0 help describes `--auto` as “Auto-approve permissions that are not explicitly denied.” The fallback opens Bash without loading shell startup files, so this does not replace a student's `.bashrc`.

The verified TUI displayed `Build auto`, `/workspace`, and OpenCode 2.3.0. That startup evidence does not establish a model connection or a successful permission-denial interaction. A displayed default/free-model label is not proof of a provider response.

## Explain V2 permissions and policies

Use the complete [opencode.json](opencode.json), which has two distinct ordered arrays:

- `permissions` uses `action`, `resource`, and `effect`. The `shell` wildcard allows shell commands; `git *` explicitly allows Git even though the broad allowance already includes it. Later `rm *`, `/bin/rm *`, and `/usr/bin/rm *` rules deny those spellings. The documented permission rule is last match wins, and the trailing shell wildcard also covers the argument-free command.
- `policies` contains hard-deny statements using action `tool.use` and resources such as `shell:rm *`. These tighten access rather than granting it. The system configuration is root-owned, and its policies outrank ordinary project configuration.

These are harness checks for the tool paths and patterns they cover. They are not operating-system prohibitions on deleting files. Actual configuration/schema loading was verified. **No model-originated allow/deny enforcement test was run.** An exploratory direct permission API probe denied even Git; the cause is unresolved. Do not call that probe a passing test or infer that the API is necessarily broken.

## Image build versus runtime mount

The build scripts use the bundle directory as their build context even if invoked elsewhere. The run scripts instead mount the shell's **current directory**. This lets the same image work with different disposable projects without rebuilding it.

A bind mount attaches a host path at container startup. Existing image content beneath the target path is hidden while the mount is attached. The default bind is read/write: saves and deletions affect the host immediately, not when the container exits. `--rm` removes the stopped container, not its mounted project. Adding `readonly` to the mount prevents project edits and is suitable for a read-only inspection exercise.

The source path belongs to the Docker daemon host. The examples assume local Linux Docker or Docker Desktop, which mediates native host paths; a remote Docker daemon is different. The launchers select `linux/amd64` because the Herdr binary and checksum are architecture-specific. ARM/macOS emulation remains untested. PowerShell commands were syntax-reviewed only, not run on Windows.

## Security limits to say aloud

1. **The `rm` patterns are not a deletion ban.** Python or Node code, file edit/write/patch tools, another executable, shell indirection, or moving/replacing files can destroy content without invoking a matched command. Compound-command inspection does not make a general OS sandbox.
2. **Git is allowed broadly.** `git clean -fdx` can remove untracked and ignored files; `git reset --hard` can discard uncommitted tracked changes. Pushes, hooks, aliases, and Git configuration can also have effects beyond read-only inspection. A Git repository is not a backup of everything in the directory.
3. **The read/write bind exposes host files to the container user.** Nonroot `coder` can modify files that its mapped user permissions allow. Root-owned OpenCode config resists ordinary project overrides of these patterns, but another process can bypass OpenCode entirely.
4. **Mount only the disposable project.** Do not mount your home, `.ssh`, `.config`, host OpenCode authentication state, secrets, or the Docker socket. There are no credentials in the bundle. Avoid secrets in project files as well as mounted credential directories.
5. **Network access permits exfiltration.** The supplied teaching run has network access; capability dropping and `no-new-privileges` do not prevent sending readable files elsewhere. The source candidate's runtime checks used `--network none`, while build downloads used the network. Do not imply those offline checks establish online safety.
6. **Approval policy and containment are separate.** Prefer a narrow read-only allowlist and an appropriately restricted environment for a safety exercise. This permissive example demonstrates the risks of unattended execution; it is unsuitable for hostile repositories, prompts, or production data. Keep a backup and review the actual changes.

## Evidence and limits

The earlier raw seed was not build-tested. The corrected source candidate was actually built and exercised on 2026-11-17, Linux amd64, Docker Engine 29.10.0. The teaching copy preserves its Dockerfile, configuration, scripts, and wrapper byte for byte. Integration checks on this copy are local structure, link-target, syntax, schema, whitelist, and source-hash checks, not a second Docker execution campaign.

The source candidate passed nonroot identity, fixture-only host-visible bind writes and Git commands, configuration/schema loading, integration installation/status, actual OpenCode pane output, and a real-PTY test of the default Herdr command. No provider credentials or model prompts were used. Permission enforcement from a model, authentication/completions, pending-permission UI, restore/resume semantics, live working/blocked transitions, Windows execution, native ARM, and macOS/ARM emulation remain untested. Pins do not lock apt, Dockerfile frontend, or npm transitive resolution completely.

## Official sources

Source contracts checked for the candidate on 2026-11-17:

- Dockerfile instructions: https://docs.docker.com/reference/dockerfile/
- Bind mounts: https://docs.docker.com/engine/storage/bind-mounts/
- Container run options: https://docs.docker.com/reference/cli/docker/container/run/
- OpenCode installation: https://opencode.ai/docs/
- OpenCode CLI: https://opencode.ai/docs/cli/ (2.3.0 executable help additionally confirmed `--auto`)
- OpenCode configuration: https://opencode.ai/docs/config/
- OpenCode JSON schema: https://opencode.ai/config.json
- OpenCode permissions: https://opencode.ai/docs/permissions/
- OpenCode policies: https://opencode.ai/docs/policies/
- Herdr TUI installation: https://herdr.dev/tui/docs/install/
- Pinned Herdr TUI release: https://github.com/herdrdev/herdr/releases/tag/v0.9.5
- Tagged installer source: https://raw.githubusercontent.com/herdrdev/herdr/v0.9.5/distribution/install.sh (the Dockerfile uses the pinned binary instead of executing this installer)
- Herdr OpenCode integration: https://herdr.dev/docs/integrations/#opencode
- Herdr configuration: https://herdr.dev/docs/configuration/

The downloadable bundle deliberately omits test fixtures, fixture Git metadata, debug/API probes, evidence logs, and local credential state. The instructor can review the separate verification handoff before authorizing publication.
