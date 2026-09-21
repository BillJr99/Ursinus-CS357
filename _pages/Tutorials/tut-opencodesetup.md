---
layout: textbook
permalink: /Tutorials/OpenCodeSetup
title: 'CS357: Foundations of Artificial Intelligence - End-to-End OpenCode Setup'
info:
  coursenum: CS357
  purpose: "To stand up a complete opencode installation on any operating system: the configuration file at both scopes, a model provider, a project contract, permission gates, a skill, a plugin, and GitHub reached two different ways."
  eyebrow: "Tutorial"
  numbering: false
tags:
- opencode
- tooling
- setup
---

## About This Tutorial

Every lab this semester runs through **opencode**, and every piece of it is configured in one file.  This page walks the whole setup once, end to end, on macOS, Windows, WSL2, and Linux: install the agent, write `opencode.json` at both scopes, point it at a model, give the project a contract, close the permission gates, add a skill, add a plugin, and reach GitHub through both the command line and a tool server.  You leave with a working bench and a file you can read.

Each section says briefly **what the element is and why it exists**, then gives the full implementation.  The arguments live elsewhere: *Your AI Workbench* builds the container, *Coding Agents* takes apart gates and the GitHub loop, *Skills* designs a skill worth writing, and *MCP* explains what a tool server buys you.  This page is the reference you come back to when something is not loading.
{: .tb-lede}

## Key Concepts

Anchor these before you start.  Every one of them appears below, and most of the failures on this page are a confusion between two of them.

| Term | Plain-English Definition | Where You'll Meet It |
|---|---|---|
| **`opencode.json`** | The one configuration file.  It holds providers, permissions, extra instruction files, plugins, and tool servers.  The name is exact; a file called `config.json` is ignored in silence | Part I, and every part after it |
| **Scope** | Whether a setting applies to one project or to every project, decided by which of two directories the file sits in.  The two are merged, not replaced | Part I, §2 |
| **Provider** | Where models come from: an adapter package, an address, and a list of models.  The course's provider is Ollama on your own machine | Part I, §3 |
| **`AGENTS.md`** | Standing instructions for a project, read automatically from its root.  A system prompt you keep in version control | Part II, §4 |
| **`instructions`** | A list in `opencode.json` naming *additional* files to load.  Not a replacement for `AGENTS.md`, which is discovered on its own | Part II, §4 |
| **Permission** | A gate the harness enforces before a tool runs, as opposed to a rule the model is merely asked to follow | Part II, §5 |
| **Skill** | A directory holding a `SKILL.md`, loaded on demand when its description matches the situation.  There is no install command | Part III, §6 |
| **Plugin** | Code that runs at defined moments and can refuse a tool call outright.  Where a skill adds instructions, a plugin adds behavior | Part III, §7 |
| **MCP server** | A process that advertises operations as named tools, so your rules match a tool name rather than a command line | Part IV, §8 |
| **Bind mount** | The one directory of your machine a container can see.  It is the agent's entire reachable world, which is what makes it a blast radius you chose | Part V, §11 |
| **Auto mode** | Running with the permission prompts off.  Defensible **only** inside a container, never on your host | Part V, §12 |
{: .tb-full}

### Before You Start

You need opencode installed or installable, Ollama running on your machine from *Your AI Workbench*, and a text editor.  A GitHub account is needed only for Part IV.  Nothing here costs money and nothing requires a paid model provider.

Allow about an hour if you are starting from nothing, and rather less if you already did the Workbench session, since Part I will mostly be confirmation.

---

## Two tables you will use in every section

Nearly every problem in this page is one of two questions: where does the file go, and which of the three faces of opencode can do the thing I want?  Read these twice now and the rest of the page is mechanical.

**Where `opencode.json` lives.**  opencode reads it from two places, and which one you pick decides **which projects the setting applies to**, not whether it works.

| System | Project scope | Global scope |
|---|---|---|
| macOS, Linux, WSL2 Ubuntu | `opencode.json` at the repository root | `~/.config/opencode/opencode.json` |
| Windows, PowerShell | `opencode.json` at the repository root | `%USERPROFILE%\.config\opencode\opencode.json` |
{: .tb-full}

On Windows the fastest way to that folder is **Win+R**, paste `%USERPROFILE%\.config\opencode`, press Enter.  If the folder does not exist yet, you create it below.

The two files are **merged, not replaced**.  A project file does not have to restate your global settings; it adds to them, and where both define the same key the project wins.  That single fact is why every instruction on this page can say "append this block" instead of "rewrite your file."
{: .tb-key data-title="Why this matters"}

**The three faces of opencode, and what each one can actually do.**  You will see the desktop application, the terminal interface (the TUI), and the configuration file described as three ways to do the same thing.  They are not.  Each owns a different job, and most of this page happens in the file.

| Route | What it does |
|---|---|
| **The configuration file** | **Defines** things: providers, permissions, MCP servers, plugins, extra instruction files.  Everything in this tutorial is defined here |
| **The TUI** | `/connect` stores a **credential**; `/model` **selects** a model; **Tab** cycles agents.  There is no `opencode auth login` |
| **The desktop application** | **Selects** a model, and **File > Settings > Show Agent** reveals the agent selector.  It reads the same configuration file |
{: .tb-full}

Adding a provider, a plugin, or an MCP server is a file edit on every platform and in both faces.  Neither the desktop application nor the TUI has a form for it.  Knowing that in advance saves you hunting through a settings pane for something that was never there.
{: .tb-pitfall data-title="Common Misconception"}

---

# Part I: The Agent and Its File

Everything opencode does is configured in one file.  This part installs the agent, creates that file at the right scope for your machine, and points it at a model, which is the minimum that makes the rest of the page meaningful.

## 1.  Install opencode

**What it is.**  A single program that reads your project, proposes edits and shell commands, and stops at whatever gates you leave open.  The desktop application and the terminal command are the same agent with two front ends, so install the command-line version even if you prefer the window: every lab asks for terminal output.

| System | Install |
|---|---|
| **macOS, Linux, WSL2 Ubuntu** | `curl -fsSL https://opencode.ai/install | bash` |
| **Already have Node.js** | `npm i -g opencode-ai` |
| **Windows, PowerShell** | `winget install --id sst.opencode`, or `choco install opencode`, or `scoop install opencode` |
| **The course container** | Nothing.  It is in the image |
{: .tb-full}

Verify, in a **new** terminal so the updated `PATH` is loaded:

```bash
opencode --version
```

If that prints `command not found` right after a successful install, the installer put the binary in `~/.local/bin`, which is not on your `PATH` yet.  `export PATH="$HOME/.local/bin:$PATH"` fixes the current session; the same line in `~/.bashrc` or `~/.zshrc` makes it stick.  On Windows, open a new PowerShell window.
{: .tb-warning data-title="Watch out"}

The desktop application is a separate download from [opencode.ai](https://opencode.ai/), in beta for macOS, Windows, and Linux.  You can take either route through this page.

---

## 2.  Create `opencode.json`

**What it is.**  One JSON file holding everything below: which model you talk to, what the agent may do without asking, which extra files it reads, which plugins load, and which tool servers it can reach.  The name is exact.  It is `opencode.json`, never `config.json`, and a file with the wrong name is ignored in silence, which produces the single most common failure on this page: an agent that starts fine and lists no models.

Start with the global file, so every project inherits a working model.

**macOS, Linux, WSL2 Ubuntu:**

```bash
mkdir -p ~/.config/opencode
cat > ~/.config/opencode/opencode.json <<'JSON'
{
  "$schema": "https://opencode.ai/config.json"
}
JSON
```

**Windows, PowerShell:**

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\opencode" | Out-Null
Set-Content -Path "$env:USERPROFILE\.config\opencode\opencode.json" -Encoding utf8 -Value @'
{
  "$schema": "https://opencode.ai/config.json"
}
'@
```

The `$schema` line is optional and worth keeping.  It tells an editor what keys are legal, so a typo in `permission` or `provider` is underlined while you type instead of discovered at runtime.

**Check that it parses**, every time you edit it by hand, because opencode treats a malformed file the same way it treats a missing one:

```bash
python3 -m json.tool ~/.config/opencode/opencode.json
```

In PowerShell that is `python -m json.tool "$env:USERPROFILE\.config\opencode\opencode.json"`, or `Get-Content ... | ConvertFrom-Json`, which prints an error and nothing else if the JSON is broken.

A project file is the same file at the root of a repository, and it is the right home for anything that belongs to *that project*: a tool server for its issues, a permission rule about its build command, a contract file. Anything you want everywhere goes in the global copy.  Because the two merge, the project file only carries the difference.

---

## 3.  Add a model provider

**What it is.**  A provider tells opencode where models come from.  The course runs on **Ollama** on your own machine, so nothing you type in a lab leaves your laptop and nothing costs money.

A provider entry has three parts, and knowing their names makes every example below readable: `npm` is the adapter package that speaks the endpoint's dialect, `options` holds the address and any credential, and `models` lists what that endpoint serves.

Append this to `opencode.json`, as a sibling of `$schema`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "llama3.2": { "name": "llama3.2 (local)" }
      }
    }
  }
}
```

**The address rule.**  Use `http://localhost:11434/v1` when opencode runs on the same machine as Ollama.  Use `http://host.docker.internal:11434/v1` when opencode runs **inside the course container**, because `localhost` inside a container means the container, where nothing is listening.  That substitution is the only difference between the two, and it is the same rule *Your AI Workbench* teaches for every other address.
{: .tb-key data-title="Why this matters"}

A provider key and a model key join with a slash to make the identifier the rest of opencode uses, so the block above defines **`ollama/llama3.2`**.  That is what `--model` takes and what an agent definition's `model` field expects.

**Confirm it.**  Start `opencode`, type `/model`, and look for your provider.  In the desktop application, the model dropdown in the message bar does the same job.

An empty model list is almost always one of three things, in this order: the file is named `config.json`, the file is in neither of the two locations from the table at the top, or the JSON does not parse.  Check the name first; it is the most common and the least obvious.
{: .tb-warning data-title="Watch out"}

### An external provider, if you ever add one

Nothing in this course requires a paid provider, and you should not add one to complete an assignment.  The shape is here because you will meet it, and because it is where the credential rule bites.  Any OpenAI-compatible service wires up the same way; only the address, the key, and the model names change.

```json
{
  "provider": {
    "acmeai": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Acme AI (example, not a real service)",
      "options": {
        "baseURL": "https://api.acme.example/v1",
        "apiKey": "{env:ACME_API_KEY}"
      },
      "models": {
        "acme-medium": { "name": "Acme Medium" }
      }
    }
  }
}
```

Notice what the file holds: the **name** of a variable, never its value.  Set the value in your shell (`export ACME_API_KEY=...`, or `$env:ACME_API_KEY = "..."` in PowerShell), or write it to a file and reference that instead with `{file:~/.secrets/acme-key}` after `chmod 600`.  A configuration file that contains a key is a key you have committed, and a commit that contains a key has leaked it even if the next commit removes it.

### Authenticating a provider, when it needs it

Providers fall into three groups, and which group yours is in decides where the credential goes.  This is the part students most often get wrong, because the answer is different for the provider the course actually uses than for the ones they have seen elsewhere.

| The provider | How it authenticates | Where the credential lives |
|---|---|---|
| **Ollama, and anything else local** | It does not.  There is no account and no key | Nowhere.  This is the whole point of running locally |
| **A service with an API key** | An `apiKey` in `options`, written as a `{env:...}` or `{file:...}` reference | Your shell environment, or a file you `chmod 600`.  Never the config |
| **A service with a sign-in** | `/connect` in the TUI, then pick the service, or **Other** for one not listed | opencode's own credential store, outside `opencode.json` |
{: .tb-full}

**Local models need no authentication at all.**  If you are following this course as written, section 3 is already finished and you can skip to section 4.  An `apiKey` field is not required for Ollama, and adding a fake one to make the block "look complete" is a habit worth not forming.

**For a key-based service**, set the variable before you start opencode:

```bash
export ACME_API_KEY=your-key-here          # macOS, Linux, WSL2
```

```powershell
$env:ACME_API_KEY = "your-key-here"        # Windows, this session
[Environment]::SetEnvironmentVariable("ACME_API_KEY", "your-key-here", "User")   # and for good
```

Check that it is set **without printing it**, because a key you echo is a key in your scrollback, your shell history, and any screenshot you paste into the course channel:

```bash
[ -n "$ACME_API_KEY" ] && echo set
```

In PowerShell, `if ($env:ACME_API_KEY) { "set" }`.

**For a sign-in service**, there is no `opencode auth login` command.  Start the TUI, run `/connect`, and choose the service from the list, or scroll to **Other** if it is not there.  opencode stores what it gets in its own credential file, `~/.local/share/opencode/auth.json` on macOS, Linux, and WSL2, and under your user profile on Windows.  The property that matters is not the exact path: it is that the credential is **not** in `opencode.json` and therefore not in your repository, which is what makes the configuration file safe to commit.

Whichever group you are in, the file you commit holds a reference and never a value.  That rule is what lets a classmate clone your repository, get your whole provider setup, and get none of your credentials.
{: .tb-key data-title="Why this matters"}


**Never paste a key, token, or password into a chat with an agent**, including this one.  Text you send to a hosted model rests in that provider's logs, and unlike your terminal scrollback you cannot clear it.  If it happens, treat the credential as compromised: revoke it, issue a new one, update the variable.  That takes two minutes and is not a crisis.  *MCP, REST, and OAuth 2.0 Together* shows how a token in a context window gets extracted, and the *Coding Agents* session has a hook that rejects such a message before the model ever sees it.
{: .tb-warning data-title="Watch out"}

---

### Questions to Work Through

1.  You put a provider in your global `opencode.json` and a different one in a project's `opencode.json`.  Which models does `/model` list when you open that project, and why is the answer not "only the project's"?

    *Hint:* The word in §2 is *merged*.  Ask what merging means when both files define the same key, and then when they define different ones.

2.  A classmate's agent starts, reports no models, and their JSON is valid.  Name the two remaining causes in the order you would check them, and say why that order.

    *Hint:* One of the two is invisible in an editor and takes a second to check; the other requires knowing which of two directories they used.  Cheap checks first.

3.  Ollama needs no API key.  Explain what that implies about where your prompts go, and name the one thing in this tutorial that does still need a credential.

    *Hint:* §3's table has three rows for a reason.  Which row is the course in, and which row is Part IV in?

---

# Part II: Telling It What To Do

A working agent with no instructions will do something reasonable and occasionally something you did not want.  This part gives the project a contract and then backs that contract with gates the model cannot talk its way past.

## 4.  Write `AGENTS.md`

**What it is.**  A Markdown file at the root of your project holding the standing instructions you would otherwise retype every session: what this project is, what counts as good work in it, and what the agent must not decide on its own.  It is a system prompt you keep in version control, which means it is reviewable, diffable, and shared with anyone who clones the repository.

**macOS, Linux, WSL2:**

```bash
cat > AGENTS.md <<'MD'
# cs357-work

My CS357 lab workspace.

- The model server is on the host at http://localhost:11434 (llama3.2).
- Python 3, standard library plus `requests`. Ask before adding a dependency.
- Every script handles network errors and prints a located message, e.g. [lab1:chat].
- Small, readable functions with docstrings.
MD
```

**Windows, PowerShell:**

```powershell
Set-Content -Path AGENTS.md -Encoding utf8 -Value @'
# cs357-work

My CS357 lab workspace.

- The model server is on the host at http://localhost:11434 (llama3.2).
- Python 3, standard library plus `requests`. Ask before adding a dependency.
- Every script handles network errors and prints a located message, e.g. [lab1:chat].
- Small, readable functions with docstrings.
'@
```

**How opencode finds it, and how that differs from `instructions`.**  opencode reads `AGENTS.md` from the project root **on its own**; you never name it in the configuration.  The `instructions` key names *additional* files to load alongside it, and it accepts paths and globs:

```json
{
  "instructions": ["CHARTER.md", ".ai/MEMORY.md"]
}
```

So the two mechanisms are not alternatives.  `AGENTS.md` is discovered; everything else you want in context has to be listed.  The OpenCode Studio lab uses both, which is why the distinction is worth having straight before you start it.
{: .tb-key data-title="Why this matters"}

If you open the **wrong folder** in the desktop application, the parent of your project rather than the project itself, opencode reads no `AGENTS.md` at all and nothing tells you.  Open the repository folder directly; on the command line, `cd` into it before starting.
{: .tb-pitfall data-title="Common Misconception"}

---

## 5.  Close the permission gates

**What it is.**  A rule in `AGENTS.md` is advice the model may ignore.  A **permission** entry is a gate the harness enforces before the tool runs, so the model does not get a vote.  That difference is most of what makes running an agent on your own files reasonable.

```json
{
  "permission": {
    "*": "ask",
    "bash": {
      "*": "ask",
      "git *": "allow",
      "rm *": "deny"
    },
    "edit": "ask"
  }
}
```

Values are `allow`, `ask`, or `deny`.  Keys are tool names: `bash`, `edit`, `read`, `webfetch`, `external_directory`, and `skill`.  A tool's value may itself be a map of command patterns using `*` and `?`.

**The rule that decides everything is that the last matching rule wins.**  Read the block top to bottom: ask about everything, then inside `bash` ask about everything, then allow anything starting with `git`, then refuse anything starting with `rm`.  Reverse the last two lines of that inner map and `"*": "ask"` swallows the git rule, leaving you to approve every `git status` for the rest of the semester.
{: .tb-key data-title="Why this matters"}

Git is the one family allowed to run unattended, and that is deliberate rather than lazy.  Git is how the project stays reversible, so an agent that must ask before committing is an agent that commits less often, which is exactly backwards.

**Confirm it.**  Ask the agent to create a scratch file and watch it stop and ask.  Then ask it to run `git status` and watch it not stop.  Two prompts, and you have tested the gate in both directions.

**This block is the default, and it stays on.**  Every lab, every project, every session on your own machine runs with permissions configured like this.  You will hear about a mode that skips the prompts; it belongs inside the container in Part V and nowhere else, for reasons that part makes concrete.  On your host, the answer to "this is a lot of prompts" is a better `permission` block, one that allows the specific commands you have decided are safe, not a flag that allows all of them.
{: .tb-key data-title="Why this matters"}

An already-running session does not pick up a file you just edited.  Quit and restart opencode after changing `permission`, or you will conclude the rule does not work when it simply has not been read.
{: .tb-warning data-title="Watch out"}

---

### Questions to Work Through

4.  `AGENTS.md` is never named in `opencode.json`, but `CHARTER.md` has to be.  State the rule that explains both facts in one sentence.

    *Hint:* One file is found; the others are listed.  Which is which, and what happens to a file that is neither?

5.  Take the permission block from §5 and move `"git *": "allow"` above `"*": "ask"` inside the `bash` map.  Predict what changes, then say which sentence in §5 told you.

    *Hint:* The phrase is *last matching rule wins*.  Walk `git status` down the block in both orderings and see which rule it lands on.

6.  Your `AGENTS.md` says "never delete files" and your permission block does not mention `rm`.  A model that has read the contract deletes a file anyway.  Was the model broken?

    *Hint:* §5's first paragraph distinguishes a rule from a gate.  Which one did you write, and what is the other one for?

---

# Part III: Extending It

Skills and plugins are the two ways to add capability.  The distinction is worth holding onto: a skill adds instructions the model may load, and a plugin adds code that runs whether the model likes it or not.

## 6.  Add a skill

**What it is.**  A named instruction set the agent loads **on demand**, when it recognizes the situation the skill's description names.  A skill is a directory containing a `SKILL.md`, and that is the entire mechanism: there is no registry and no install command, because opencode walks the filesystem, reads each `SKILL.md`, and offers the skill to the model.

Installing one is therefore putting a folder in a place opencode looks.  Any shell, any file manager, any OS.

| | Project-level | User-level |
|---|---|---|
| **macOS, Linux, WSL2** | `.opencode/skills/`, `.claude/skills/`, `.agents/skills/` | `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/` |
| **Windows** | `.opencode\skills\`, `.claude\skills\`, `.agents\skills\` | `%USERPROFILE%\.config\opencode\skills\`, `%USERPROFILE%\.claude\skills\`, `%USERPROFILE%\.agents\skills\` |
{: .tb-full}

Use `.agents/skills/`, which both opencode and pi read, so your skills are not welded to one tool.  It is the universal path; the other two exist because Claude Code and opencode each arrived at the idea separately.

This page installs into the **project** path, at the root of the repository you are working in, and that is the form to learn first.  The skill then sits beside the `opencode.json` and `AGENTS.md` it belongs with, it goes into version control with them, and a mistake in it is scoped to one project.  opencode also reads a global path, `~/.config/opencode/skills/`, beside the global config from §3, and that is where a skill you want in every project belongs.  The file is identical either way; only the directory changes.

**macOS, Linux, WSL2:**

```bash
mkdir -p .agents/skills/commit-message
cat > .agents/skills/commit-message/SKILL.md <<'MD'
---
name: commit-message
description: Write a git commit message from staged changes. Use when the user asks for a commit message or runs git commit without one.
---

Read the staged files with `git status --short`, then open them.  Write a subject line under
seventy characters saying what changed and why, then a blank line, then the
reasoning if it is not obvious.  Do not describe the change line by line.
MD
```

**Windows, PowerShell:**

```powershell
New-Item -ItemType Directory -Force -Path .agents\skills\commit-message | Out-Null
Set-Content -Path .agents\skills\commit-message\SKILL.md -Encoding utf8 -Value @'
---
name: commit-message
description: Write a git commit message from staged changes. Use when the user asks for a commit message or runs git commit without one.
---

Read the staged files with `git status --short`, then open them.  Write a subject line under
seventy characters saying what changed and why, then a blank line, then the
reasoning if it is not obvious.  Do not describe the change line by line.
'@
```

Two rules cause almost every failure.  **The directory name must match the `name:` field**, or the skill silently never loads.  And **the `description` is the trigger**: the model reads it to decide whether this situation is that situation, so a description naming the occasion works and one naming the topic does not.
{: .tb-warning data-title="Watch out"}

Skills are read at startup, so restart opencode and ask it to list the skills it can see.  Which skills an agent may load is itself a gate, through the `skill` key in the permission block, which takes the same three values and the same last-matching-rule-wins ordering as the `bash` map in §5:

```json
{
  "permission": {
    "skill": { "*": "ask", "commit-message": "allow", "experimental-*": "deny" }
  }
}
```

`ask` prompts you before the skill loads.  While every skill on disk is one you wrote, `"*": "allow"` is reasonable and saves you a keystroke.  The moment you install one from someone else, switch the wildcard to `"ask"` and allow your own by name, as above: a skill is instructions the model will follow, and a `deny` you forgot to write is not a gate.  [Agent Skills and Plugins]({{ site.baseurl }}/Tutorials/AgentSkills) covers what to read before installing someone else's.

---

## 7.  Add a plugin

**What it is.**  Where a skill adds instructions, a plugin adds **behavior**: JavaScript or TypeScript that runs at defined moments, such as before a tool call, and can refuse it outright.  A plugin is how you enforce something a permission pattern cannot express.

The simplest way to add one is the `plugin` array, which takes a package name or a Git URL.  This one pulls models automatically so you are not hand-editing the `models` map every time you `ollama pull` something new:

```json
{
  "plugin": [
    "git+https://github.com/BillJr99/opencode-auto-models.git"
  ]
}
```

Plugins you write yourself are files instead, discovered from disk the way skills are:

| | Path |
|---|---|
| **macOS, Linux, WSL2** | `.opencode/plugins/` in a project, `~/.config/opencode/plugins/` globally |
| **Windows** | `.opencode\plugins\` in a project, `%USERPROFILE%\.config\opencode\plugins\` globally |
{: .tb-full}

Restart opencode after adding a plugin.  The *Coding Agents* session writes one from scratch and explains the hook interface.

---

### Questions to Work Through

7.  A skill is a directory and a plugin is a file named in an array.  Both change what the agent does.  Give the sharpest one-sentence difference you can, then say which one the model can decline to use.

    *Hint:* §6 says a skill loads *on demand*, when its description matches.  Who decides that a plugin runs?

8.  Your skill does not fire.  You have restarted opencode and the `SKILL.md` parses.  Name the two remaining causes.

    *Hint:* §6 flags both as the ones that cause almost every failure.  One is about a name matching; the other is about what the description is describing.

---

# Part IV: Reaching Outside

An agent that can only edit local files is a text editor with opinions.  This part connects it to GitHub, twice, because the two routes differ in exactly the way your permission rules care about.

## 8.  Reach GitHub, two ways

**What it is.**  Your agent needs to file issues, open pull requests, and read review comments, because that is where the work lives.  There are two routes to the same operations, and the course uses both deliberately.

### Route one: `gh` through the shell

The [GitHub CLI](https://cli.github.com/) is a command-line program, so an agent reaches it the way it reaches any command: through its shell tool, where your permission rules already apply.

| System | Install |
|---|---|
| **macOS** | `brew install gh` |
| **Windows, PowerShell** | `winget install --id GitHub.cli` |
| **WSL2, Debian, Ubuntu** | The apt recipe on [cli.github.com](https://cli.github.com/); the distribution's own `gh` package lags far enough to be missing commands |
| **Other Linux** | `dnf install gh`, `pacman -S github-cli`, or the release archive |
| **The course container** | Nothing.  It is in the image |
{: .tb-full}

```bash
gh auth login      # GitHub.com, then SSH, then let it generate and upload a key
gh auth status     # what you are signed in as, and with which scopes
```

Two failures look alike and are not.  A **401** is about identity: the session lapsed or the token expired, and `gh auth login` fixes it.  A **403** is about permission: you are authenticated and the token lacks that scope, and `gh auth refresh -s <scope>` or an edited fine-grained token fixes it.  Reading the number first saves you re-authenticating a token that was fine.
{: .tb-key data-title="Why this matters"}

Give the agent a token scoped to one repository, never your personal one, and never mount `~/.config/gh` into a container that runs agent code: that token can push to everything you can.

### Route two: the GitHub MCP server

A tool server advertises each operation as its own named tool, so the agent calls `github_create_issue` rather than composing a command line.  The practical difference is what your rules can match: a tool name has one spelling, while a command line has many.

```json
{
  "mcp": {
    "github": {
      "type": "remote",
      "url": "https://api.githubcopilot.com/mcp/",
      "oauth": false,
      "headers": {
        "Authorization": "Bearer {env:GITHUB_SCRATCH_PAT}"
      }
    }
  }
}
```

The hosted server is an HTTPS endpoint, so it works anywhere the network does, **including inside the course container**.  There is also a local server that runs as a `docker run` command, and that one needs a Docker CLI, which the course container does not have.  Configure the local form on your host and use the hosted form from inside the container.
{: .tb-pitfall data-title="Common Misconception"}

Put this block in the **project** `opencode.json` of the repository the server serves.  A tool server in your global file is advertised in every project you open afterwards, and every advertised tool spends context whether or not you use it.

Name the variable after what its token can reach.  `GITHUB_SCRATCH_PAT` for a token scoped to a throwaway repository, `GITHUB_PAT` for the one that reaches your coursework.  Two tokens under one name means the wider one quietly satisfies the narrower use, which is the whole argument for scoping it in the first place.

---

### Questions to Work Through

9.  You want to deny merging a pull request.  Write the `bash` pattern for the `gh` route, then say why the tool-server route needs no pattern at all.

    *Hint:* Count the ways a command line can spell the same operation, including inside a script the agent writes.  Then count the spellings of a tool name.

10.  You get a 403 from `gh issue create` and `gh auth status` looks healthy.  Say what is wrong and what you would run, then say what a 401 would have meant instead.

    *Hint:* One number is about who you are, the other about what you may do.  Only one of them is fixed by signing in again.

---

# Part V: Running It Isolated

Everything so far assumed you approve actions as they come, and on your own machine that does not change: §5's permission block is the standing configuration for all normal work.

This part is about the one exception. There is a mode where the agent runs to completion without stopping, which is what you want for a long refactor or an overnight task, and it is also the mode where a mistake costs the most. Those two facts are the same fact. So the mode is not something you turn on when the prompts get tiring; it is something you turn on **after** you have built a boundary that makes the prompts unnecessary. That boundary is a container, and building it is most of this part.

## 9.  Why a container is the price of skipping the prompts

Part II's argument was that a gate beats a rule because the harness enforces it. Turning the gates off does not return you to "the model behaves well." It returns you to "nothing between the model and your filesystem." The permission prompt was doing real work, and if you remove it you have to put something else in its place.

A container is that something else. Instead of deciding per action whether it is safe, you decide **once**, in advance, what the agent can reach at all, and then stop deciding. That is a better trade than it sounds, because the per-action decision is the one you get wrong at hour three when every prompt looks like the last one.

The boundary is the mount. A container with one bind mount can read and write exactly that directory and nothing else: not your SSH keys, not your other repositories, not your documents, not the rest of your disk. Everything the agent could damage is therefore everything you deliberately handed it, and that directory is a git repository with a GitHub remote, which means every change is a change you can read and revert.
{: .tb-key data-title="Why this matters"}

Three properties make the arrangement work, and it is worth naming them because they are the same three the Workbench session introduces. **Isolation**: the mount bounds what it can reach. **Observability**: the work lands as commits you read. **Reversibility**: `git checkout` and a push you can revert. Remove any one and the arrangement stops being reasonable. Yolo mode inside a container with no git history is not isolation, it is just a faster way to lose work.

## 10.  Build the image

The course container already carries opencode, and if you are on Route A you can skip to §11 and use it. This is the minimal standalone version, which is worth building once because it is short enough to read in full.

```dockerfile
# Dockerfile.agent
FROM node:24-bookworm-slim

# git so the agent can commit its own work; ripgrep because agents reach for it
# constantly; ca-certificates so HTTPS works at all.
RUN apt-get update && apt-get install -y --no-install-recommends \
        git ripgrep ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g opencode-ai

# The model lives on the host, not in here. Code inside the container reaches it
# across the container wall at this address.
ENV OLLAMA_HOST=http://host.docker.internal:11434

# Never run an agent as root. If something does go wrong inside the container,
# it goes wrong as an ordinary user.
RUN useradd --create-home --shell /bin/bash agent
USER agent

WORKDIR /workspace
CMD ["opencode"]
```

```bash
docker build -f Dockerfile.agent -t course-agent .
```

Notice what is **not** in the image: no API key, no token, no `~/.ssh`, no `~/.config/gh`. The model is local and needs no credential, which is the property that makes this container safe to hand a running agent. An image that needs a secret is an image that can leak one.
{: .tb-warning data-title="Watch out"}

## 11.  Point it at one directory, and only one

The container sees your project because you mount it, and it sees nothing else because you do not.

```bash
cd ~/cs357-work        # a git repository, with a GitHub remote

docker run -it --rm \
  --add-host=host.docker.internal:host-gateway \
  -v "$PWD:/workspace" \
  -w /workspace \
  --cap-drop ALL --security-opt no-new-privileges \
  course-agent
```

In PowerShell the line continuations are backticks rather than backslashes, and `$PWD` works the same way:

```powershell
docker run -it --rm `
  --add-host=host.docker.internal:host-gateway `
  -v "${PWD}:/workspace" `
  -w /workspace `
  --cap-drop ALL --security-opt no-new-privileges `
  course-agent
```

Each flag earns its place. `--rm` deletes the container on exit, so an experiment cleans up after itself and your files survive because they were never in the container to begin with. `-v "$PWD:/workspace"` is the only door. `-w /workspace` makes that directory the agent's world from the first keystroke. `--add-host` makes `host.docker.internal` resolve on Linux, where Docker Engine does not provide it for free. `--cap-drop ALL` and `--security-opt no-new-privileges` remove kernel capabilities the agent has no use for.

**Everything from the earlier parts comes along.** The directory you mounted is the directory that holds `opencode.json`, `AGENTS.md`, and `.agents/skills/`, so the provider, the contract, the permission block, and your skills are all present inside the container without being installed into it. That is the payoff of putting them in the project rather than in a home directory: they travel with the repository, into the container, and onto a classmate's machine when they clone it.
{: .tb-key data-title="Why this matters"}

One address changes. Inside the container, the provider's `baseURL` must be `http://host.docker.internal:11434/v1`, because `localhost` means the container. If your project `opencode.json` is written for your host, either change it for container use or keep the container's address in the project file and the host's in your global file, which is exactly the kind of split the merge rule from §2 exists to support.

## 12.  Turn the gates off, deliberately

Now, and only now, running without prompts is a defensible choice.

**Only inside this container.**  Everything in this section assumes the `docker run` from §11: one bind mount, no credentials, a clean git tree.  Outside that boundary, on your host, the permission block from §5 stays exactly as it is.  If you find yourself typing `--auto` in a terminal that is not a container prompt, stop: you have removed the gate without adding the boundary that replaced it, which is strictly worse than either arrangement on its own.
{: .tb-warning data-title="Watch out"}

```bash
opencode --auto
```

Or in the project's `opencode.json`, which is the route the desktop application needs since it has no flag to pass:

```json
{
  "permission": {
    "*": "allow"
  }
}
```

**A `deny` still holds.** The flag approves what is not explicitly denied, so a `deny` rule survives it. That makes `deny` the right tool for anything you never want attempted, even in this mode, and it is worth keeping a short list of those even inside a container:

```json
{
  "permission": {
    "*": "allow",
    "bash": {
      "rm -rf *": "deny",
      "git push --force*": "deny"
    }
  }
}
```

The first protects the mount's contents from the one command that empties it faster than you can react. The second protects the history on GitHub, which is the copy the container cannot reach and therefore the one thing here that is genuinely irreversible.

**Commit before you start, and read the action log after.** The whole arrangement rests on git: a clean tree before the run makes `git status` afterwards a complete list of what the agent did, and `git checkout -- .` an instant undo. Start from a dirty tree and you have given up the observability half of the trade while keeping all of the risk.
{: .tb-warning data-title="Watch out"}

The workflow, end to end, is four commands:

```bash
git status                      # start clean
docker run ... course-agent     # the run above
opencode run "<the job>" --auto 2>&1 | tee agent-run.log   # inside the container
# ...agent works, you go and do something else...
less agent-run.log              # the action log that run wrote
```

Then review, commit, and push from the container or the host, whichever you prefer. The push is how the work leaves the blast radius.

### Questions to Work Through

11.  The container has no credential of any kind and the agent can still push to GitHub if you set one up. Explain how both can be true, and what you would have to add to the `docker run` line to make pushing work.

    *Hint:* §10 says there is no token in the image. Part IV said a token can arrive as an environment variable. What does that imply about where the decision lives, and what does adding it cost you in blast radius?

12.  A classmate runs `opencode --auto` on their host rather than in a container, reasoning that they have a clean git tree so anything bad is revertible. Name the property they still do not have, and give one concrete thing that git would not undo.

    *Hint:* Three properties are named in §9. Git gives two of them. Which one is missing, and what lives outside the repository on their machine?

13.  You mount `$HOME` instead of `$PWD`, on the grounds that it is more convenient. Walk through what the agent can now reach, and name three specific things from earlier in this tutorial that are suddenly in scope.

    *Hint:* §2, §6, and Part IV each put something in a home directory. All three are now inside the boundary.

---

# Part VI: Synthesis and Practice

## 13.  Confirm the whole bench

One command per section.  If every line produces output, your setup is complete.

| Check | Command | What it proves |
|---|---|---|
| Install | `opencode --version` | The agent is on your `PATH` |
| Configuration | `python3 -m json.tool <your opencode.json>` | The file parses |
| Provider | `/model` in the TUI, or the dropdown in the desktop app | opencode found your models |
| Contract | Ask "what is this project?" | `AGENTS.md` was read |
| Permissions | Ask for a scratch file, then for `git status` | The first stops, the second does not |
| Skill | Restart, then ask what skills it can see | Discovery found your directory |
| Plugin | Restart and watch for load errors | The `plugin` entry resolved |
| GitHub CLI | `gh auth status` | You are signed in, with scopes listed |
| GitHub MCP | Ask the agent to list its tools | `github_*` tools are advertised |
| Isolation | `docker run ... course-agent`, then `ls /workspace` | The mount carried your project in |
| The boundary | `ls ~` at the container prompt | It is the container's home, not yours.  Your files are not there |
{: .tb-full}

## Exercises

1.  **Two scopes, one provider.**  Put a provider in your global config and a second, differently named provider in a project's config.  Open that project, run `/model`, and record which models appear.  Then open a different project and run it again.  Write one sentence explaining the difference in terms of merging.

2.  **Break it on purpose, three ways.**  Starting from a working setup, cause each of these failures and record the symptom: rename `opencode.json` to `config.json`; delete a closing brace; put a skill directory under a name that does not match its `name:` field.  You now recognize all three on sight, which is the point.

3.  **Prove the gate.**  With the §5 block in place, ask the agent for a scratch file and then for `git status`.  Capture both.  Then move `"git *": "allow"` above the inner `"*": "ask"`, restart, and repeat.  Explain what changed using the last-matching-rule rule.

4.  **A skill that fires, and one that does not.**  Write two skills with identical bodies and different descriptions: one naming an occasion ("use when the user asks for a commit message"), one naming a topic ("about git"). Ask for a commit message and record which loads.  This is the description-as-trigger idea, tested rather than asserted.

5.  **Find the boundary by hand.**  Start the container from §11, and at its prompt try to read something outside the mount: `cat ~/.ssh/id_ed25519`, `ls ~/Documents`, `cat /etc/hostname`.  Record which succeed and which fail, and explain the pattern.  The third one succeeding is not a hole; say why.

6.  **Both routes to one operation.**  Create a GitHub issue twice, once with `gh issue create` through the shell and once through the MCP server's tool.  Then write the permission rule that would deny each, and say which rule you would rather maintain.

## Reflection Prompt

Take ten minutes in your notebook, at three levels.

**Personal level:**  This page asked you to give a program permission to run commands on your machine, and then to write down exactly which ones.  Before this course, what did you actually grant to the software you installed, and how would you know?  Name one tool you use whose permissions you have never inspected.

**Technical level:**  The distinction between a rule the model is asked to follow and a gate the harness enforces appears everywhere once you see it: file permissions, API scopes, database grants, firewall rules.  Describe one system you have used where the two were confused, and what the consequence was.

**Societal level:**  Every credential in this tutorial is scoped deliberately: one repository rather than an account, an environment variable rather than a file, a local model rather than a hosted one.  Those choices cost convenience.  Who should bear the cost of least privilege in systems ordinary people use, and what happens when the secure path is also the slower one?

## Where This Goes Next

*Your AI Workbench* builds the container this runs in and sets up the credentials that belong on your host rather than inside it.  *Coding Agents* takes the permission block apart, writes a plugin, and drives the full issue-to-pull-request loop.  *Skills: Design One, Then Measure It* is about writing a skill worth loading rather than installing one.  *MCP* builds a tool server from nothing, so the configuration in Part IV stops being a magic incantation.  *Docker from Zero* and *Terminal and Filesystem Isolation for Agent Safety* are where the container in Part V is built from first principles, including what a mount does and does not isolate.  This page stays here as the thing you check when a piece of it stops loading.

## Further Reading

- **opencode documentation**, [opencode.ai/docs](https://opencode.ai/docs/): the configuration reference, the provider list, and the permissions page.  When this tutorial and the documentation disagree, the documentation is newer.
- **Your AI Workbench**, the Week 1 session, which builds the container this runs inside and sets up the credentials that belong on your host rather than in the container.
- **Coding Agents**, the Week 1 Thursday session, which takes the permission block apart, writes a plugin from scratch, and drives the full issue-to-pull-request loop.
- **Skills: Design One, Then Measure It**, the Week 2 Thursday session, on writing a skill worth loading rather than merely installing one.
- **MCP: Connecting Agents to Tools and Your Obsidian Vault**, the Week 5 session, which builds a tool server so that Part IV's configuration stops being an incantation.
