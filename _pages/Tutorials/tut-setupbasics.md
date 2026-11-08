---
layout: textbook
permalink: /Tutorials/SetupBasics
title: 'CS357: Foundations of Artificial Intelligence - Setup Basics'
info:
  coursenum: CS357
  purpose: "Terminal basics, Python and pip, tokens, and the optional tools for the course setup."
  eyebrow: "Tutorial"
  numbering: false
tags:
- setup
- reference
---
*Terminal basics, Python and pip, tokens, using OpenCode and Oh My Pi, and the optional tools for your course setup.*

The Overview assignment links here at each point you need one of these.  Words like "Step 4" and "Part 1.5" refer to that assignment, and A1 through A6 are in the [Course Container tutorial]({{ site.baseurl }}/Tutorials/CourseContainer).


## Opening a terminal, moving around, and saving a file

Every setup step happens at a terminal, and several ask you to save a file.  Here is how, on every system this course supports.  Come back to this section whenever a step says "open a terminal," "`cd`," or "save it."

**1. Open a terminal.**

| System | How to open it | What the prompt looks like |
|---|---|---|
| macOS | Press Cmd+Space, type `Terminal`, press Enter (Terminal also lives in **Applications > Utilities**) | `you@laptop ~ %` |
| Windows, PowerShell | Open the Start menu, type `PowerShell`, press Enter (not "Command Prompt").  On Windows 11, right-clicking the Start button and choosing **Terminal** opens PowerShell too | `PS C:\Users\you>` |
| Windows, WSL2 Ubuntu | Open the Start menu, type `Ubuntu`, press Enter (A1 of the optional Route A setup installs it) | `you@laptop:~$` |
| Linux | Press Ctrl+Alt+T, or open Terminal from the applications menu | `you@laptop:~$` |
| VS Code, on any system | Press Ctrl+\` (backtick), or **View > Terminal**.  It opens in the folder you have open | one of the above |

**2. Find where you are, and move.**  The terminal always has a current folder, and every relative path is measured from it.  These commands work the same in every shell above, including PowerShell:

```bash
pwd               # print the folder you are in
ls                # list what is here (ls -la also shows hidden files; in PowerShell, plain ls)
cd ~              # go to your home folder
mkdir -p ~/cs357  # make a folder for this course (in PowerShell: mkdir ~/cs357)
cd ~/cs357        # go into it
cd ..             # go up one level
```

> **What `~` means on each system.**  `~` is your home folder:
>
> - `/Users/you` on macOS
> - `C:\Users\you` in PowerShell
> - `/home/you` in WSL2 Ubuntu; from WSL2, your Windows files are under `/mnt/c/Users/you`
>
> Do all of this course's work in `~/cs357`, or in the `cs357-work` clone from A2 on Route A, so that every `cd ~/cs357` in the setup lands in the same place.  Press **Tab** to complete a name you have started typing, and the up arrow to recall the previous command.

**3. Save a file.**  When a step says "save this as `ollama_check.py`," first `cd` into the folder the file belongs in, then use one of these:

| Editor | Where it works | How to save `ollama_check.py` |
|---|---|---|
| **nano** | macOS, Linux, WSL2, and inside the course container | Run `nano ollama_check.py`, paste the contents (Cmd+V on macOS; right-click or Ctrl+Shift+V in Ubuntu), press **Ctrl+O** then **Enter** to write the file, then **Ctrl+X** to exit |
| **vim** | Every Unix system | Run `vim ollama_check.py`, press **i** to enter insert mode, paste, press **Esc**, then type `:wq` and press **Enter** to write and quit.  If you get stuck, press **Esc**, type `:q!`, and press **Enter** to leave without saving |
| **VS Code** | Any system | From the folder, run `code .` to open it (or **File > Open Folder**), then **File > New File**, paste, and press **Ctrl+S** (Cmd+S on macOS) to save under the name the step gives.  Type the name with its extension, `ollama_check.py`, and check that the editor did not add `.txt` |
| **Notepad** | PowerShell without nano | Run `notepad ollama_check.py`, click **Yes** to create the file, paste, save, and close Notepad |

For a one-line file in PowerShell, `Set-Content notes.txt "model: llama3.2"` writes it directly.

**4. Confirm it landed.**  Run `ls` and see the file's name; run `cat ollama_check.py` and see its contents.  If `ls` does not show it, you saved into a different folder than the one you are in, and `pwd` tells you which one that is.

## Where am I typing?

Most setup failures come from running a command in the wrong place.  Before every command, read your prompt.

| Your prompt looks like | You are on | What `localhost` means there |
|---|---|---|
| `you@laptop ~ %`, `you@laptop:~$`, or `PS C:\Users\you>` | Your **host**: macOS, Linux, WSL2 Ubuntu, or PowerShell | Your laptop, where Ollama listens |
| `student@a1b2c3d4e5f6:/workspace$` | Inside the **course container** | The container itself, where nothing listens |

> **The address rule.**  Every command on this page that names Ollama's address is written as `localhost:11434`.  On your host, leave it as written.  Inside the container, replace `localhost` with `host.docker.internal`, because `localhost` inside a container means the container.  That is the only substitution on this page, and it applies only inside the container.  Running Ollama itself as a Docker container does not change the rule: with its port published (`-p 11434:11434`), `localhost:11434` on your host still reaches it.

> **Windows.**  Use PowerShell (Windows 10 and 11 include it; open it from the Start menu) or WSL2 Ubuntu, not the old Command Prompt.  Every command in the setup and in the labs is written for PowerShell or a Unix shell.  In PowerShell, `python3` is spelled `python`.  When a transcript from inside the container is what you have, include the container prompt in your copy-paste so it is visible where each command ran.

## Installing Python and pip

Step 4 runs a Python script, Part 1.5 installs `uv`, and every lab assumes a working Python somewhere.  Whether you need to install one on your host depends on your route:

| | Route A | Route B |
|---|---|---|
| **Do you need Python on your host?** | Not for this page: the container carries Python 3.11 and every course library, and `uv` in Part 1.5, Step 3 brings its own Python.  Install one anyway if you want to run scripts outside the container, or if you land on the `python -m venv` fallback there | Yes, before Step 4: Python 3 and its package installer, pip |
| **Which version** | Whatever the table below gives you | 3.11 or later, to match the container's Python; an older Python 3 runs this page's script, but the labs' libraries are tested against 3.11 |

**Do.**  First check what you already have.  Open a terminal (*Opening a terminal* above) and run both commands:

```bash
python3 --version
python3 -m pip --version
```

In PowerShell, spell them `python --version` and `python -m pip --version`.  If both print a version, and the first is 3.11 or later, you are done with this section.  Otherwise, install Python for your system from the row below; every row brings pip with it.

| System | How to install Python (pip comes with it) | Then |
|---|---|---|
| **macOS, with Homebrew** | `brew install python@3.12`.  If you do not have [Homebrew](https://brew.sh/), install it first with the one-line command on its home page; it is also the easiest way to install uv in Part 1.5 | Open a new terminal window |
| **macOS, without Homebrew** | Download the macOS installer from [python.org/downloads](https://www.python.org/downloads/) and run it | Open a new terminal window |
| **Windows, PowerShell** | Download the Windows installer from [python.org/downloads](https://www.python.org/downloads/), run it, and on its first screen check the box that adds Python to `PATH` before you click **Install Now**.  Or, in PowerShell, `winget install --id Python.Python.3.12 -e` | Open a new PowerShell window, so the updated `PATH` loads |
| **WSL2 Ubuntu, or Linux** | `sudo apt update && sudo apt install python3 python3-pip python3-venv`.  Ubuntu ships Python 3 but not pip or `venv`, which is why all three packages are named | Nothing; the commands work in the same window |

> **What pip is, and why every pip command on this page starts with `python3 -m`.**
>
> pip is Python's package installer, the tool that fetches libraries such as `requests` from the [Python Package Index](https://pypi.org/) and puts them where `import` can find them.  It has shipped inside Python since version 3.4, so installing Python installs pip.
>
> A machine can hold several Pythons, though.  Apple's developer tools add one, Homebrew adds another, and each `uv` environment has its own.  A bare `pip install` may therefore target a different Python than the `python3` you run scripts with.  Writing `python3 -m pip install requests` runs pip *from inside* the Python you name, so the library lands where that Python will look for it.
>
> That one detail is the whole cause of the `ModuleNotFoundError` in Step 4's troubleshooting, and the reason this page writes every pip command the long way.
>
> Natively, pip also belongs inside a *virtual environment*, a per-project copy of the library folder.  *Route B: installing `requests`* in Step 4 shows how to make and activate one, and every native `pip install` on this page assumes you have.

**What you should see.**  In a new terminal, `python3 --version` prints `Python 3.12.x` (or whatever you installed), and `python3 -m pip --version` prints a pip version followed by the path of the Python it belongs to.  Check that the path points at the Python you just installed.

**Paste.**  On Route B, both version lines, next to your operating system name in Stage 0.

> **Troubleshooting.**
>
> - `python3: command not found`, or `'python' is not recognized`, right after installing means the terminal predates the install.  Open a new one.
> - On Windows, typing `python` opens the Microsoft Store when Python is not installed yet.  Close the Store and run the installer above.  If the Store keeps opening afterwards, open **Manage app execution aliases** from the Start menu and turn off the `python.exe` and `python3.exe` entries.
> - `No module named pip` means pip was skipped.  `python3 -m ensurepip --upgrade` restores it on macOS and Windows; `sudo apt install python3-pip` does on Ubuntu.
> - On a fresh Mac, typing `python3` may offer to install Apple's Command Line Tools instead.  That copy of Python 3 runs Step 4, but it is several versions old, so install a current one from the table anyway.
> - If Homebrew says your macOS version is unsupported or a pre-release, run `brew update` first and retry.
> - `error: externally-managed-environment` on Ubuntu or Debian is handled under Step 4.
>
> See the Stage 0 rows in the Overview assignment's Troubleshooting section.

> **Note.**  `uv`, which Part 1.5 installs, can also fetch a Python of its own (`uv python install 3.12`) and run scripts with it (`uv run python ollama_check.py`).  Install a system Python first anyway, so that `python3` works in every terminal and every editor, and so that the `python -m venv` fallback has something to run.

## Making a token, and putting it in your environment

A6 needs a GitHub token, and so does every tool you point at GitHub afterwards: `gh` inside the container, the GitHub tool server in the MCP session, and any agent you let file an issue on your behalf.  None of them should ever read that token out of a file you commit.  This section is where the token comes from and where it lives; come back whenever a page says "set `GH_TOKEN`" or writes something like `{env:GITHUB_PAT}` in a configuration file.

**Do, the token.**  Go to [github.com/settings/personal-access-tokens/new](https://github.com/settings/personal-access-tokens/new), which is the direct link for the menu path A6 spells out, and make a **fine-grained** token:

| Field | What to choose | Why |
|---|---|---|
| Repository access | *Only select repositories*, then the one repository you mean | A token that reaches one repository can damage one repository |
| Repository permissions | The narrowest set that does the job.  **Contents: Read and write** pushes code; add **Issues** and **Pull requests**, read and write, only if an agent will open them for you | Permissions you did not grant are failures you cannot cause |
| Expiration | At or beyond the end of the semester | An expired token in week ten is a lab you cannot finish |

> **Watch out!**  The token is displayed once.  Copy it before you leave that page, because the only repair is to delete it and make another.

**Do, the variable.**  A configuration file should name a variable; your shell should hold the value.  Set it for this terminal, and then set it for good so a new window still has it:

| System | For this terminal | To make it stick |
|---|---|---|
| macOS (zsh), Linux, WSL2 Ubuntu | `export GITHUB_PAT=github_pat_yourtokenhere` | Add that same line to `~/.zshrc` on macOS, or `~/.bashrc` on Linux and WSL2, then open a new terminal |
| Windows, PowerShell | `$env:GITHUB_PAT = "github_pat_yourtokenhere"` | `[Environment]::SetEnvironmentVariable("GITHUB_PAT", "github_pat_yourtokenhere", "User")`, then open a new PowerShell window so it loads |
| The course container, compose route | Nothing extra: set it on your host | The `environment:` block in `docker-compose.yml` passes it through by name on every `docker compose run` |
| The course container, VS Code route | `export GITHUB_PAT=github_pat_yourtokenhere` at the container prompt | VS Code does not read the compose file, so this one lasts the session unless you add a `remoteEnv` entry to `devcontainer.json` |

**What you should see.**  Nothing, which is the point.  Check that the variable is set without printing what is in it:

```bash
[ -n "$GITHUB_PAT" ] && echo set
```

In PowerShell, `if ($env:GITHUB_PAT) { "set" }`.

> **Why not just `echo` it?**  Because a token you print is a token in your scrollback, your shell history, and any screenshot you paste into the course channel.  This is the same instinct as Part 1.5, where you print `id_ed25519.pub` and never `id_ed25519`.

> **And never paste one into an LLM.**  Not into a chat window, not into an agent prompt, not into a file you then ask an agent to read.  Text you send to a hosted model rests in that provider's logs, and it may be retained, reviewed, or trained on; deleting the conversation does not reach any of that.  Scrollback you can clear.  This you cannot.
>
> This course makes the mistake easy, which is the reason to say it here rather than later.  You will have a terminal with a live token in its environment and an agent in the next pane, and the natural move when something breaks is to paste the config and ask why.  Paste the *variable name*, never its value, and redact before you send.
>
> If it happens anyway, it is a two-minute problem and not a crisis: revoke the token at [github.com/settings/personal-access-tokens](https://github.com/settings/personal-access-tokens), issue a new one, update the variable.  Treat "I pasted it" as "it is compromised," because from the outside those are the same thing.  [MCP, REST, and OAuth 2.0 Together]({{ site.baseurl }}/Tutorials/MCPOAuth) shows how a token sitting in a context window gets extracted by an injected instruction, and the *Coding Agents* session builds a hook that rejects such a message before the model ever sees it.

**Which name to use.**  Different tools read different variables, and that is worth one table rather than one guess:

| What reads it | Variable |
|---|---|
| `gh`, the GitHub CLI | `GH_TOKEN`, or `GITHUB_TOKEN` |
| An `opencode.json` or `.mcp.json` configuration | Whatever name you wrote inside the `{env:...}` reference |
| A server you write yourself | Whatever name your own `os.environ` call asks for |

Give a token the name of the thing it can reach, so `GITHUB_SCRATCH_PAT` for one scoped to a throwaway scratchpad repository and `GITHUB_PAT` for the one that reaches `cs357-work`.  Two tokens under two names is the correct end state, not a mess to tidy up: share one name between them and the wider token will quietly satisfy the narrower use, which is exactly the blast-radius argument A6 makes about the container credential, arriving one layer down as a naming convention.

**If an environment variable is awkward.**  opencode can also read the value out of a file, which survives a new terminal and a reboot without editing a shell profile:

```json
"headers": { "Authorization": "Bearer {file:~/.secrets/github-scratch-pat}" }
```

Make it with `mkdir -p ~/.secrets`, put the token in `~/.secrets/github-scratch-pat`, and run `chmod 600 ~/.secrets/github-scratch-pat` so only you can read it.  The configuration still holds a reference rather than a value, so the rule survives intact.

**If you would rather do neither.**  Pasting the token straight into `opencode.json` works, and it is the right call at midnight when nothing else does.  Two conditions.  Put the file in `.gitignore` *before* the token goes in, not after, because a commit that contains a token has leaked it whether or not the next commit removes it.  And expect GitHub's push protection to reject the push anyway, which is that lesson arriving from the other direction.  For work you hand in, use the variable or the file.

**Where the configuration file goes.**  opencode reads `opencode.json` from the project directory as well as from `~/.config/opencode/`, and the choice is about scope rather than convenience.  A configuration that belongs to one repository belongs in that repository, where its tools load when you are working there and nowhere else; a configuration you want everywhere goes in the home-directory copy.  Step 5b comes back to this, and the MCP session leans on it hard.

## Using OpenCode and Oh My Pi

Suppose you want a coding agent to count the words in a paragraph, and you want it to use a tool you wrote rather than guess.  To get there, each agent needs a model to think with and a way to reach your tool.  After that, it helps to know the features that change how you work with it.  Let's set up both agents the same way, so that you can compare them.

This section assumes you have finished Step 1 and Step 5 of the Overview assignment.  It is optional, and nothing graded depends on it.  The examples use `llama3.2`, so substitute the model you pulled.  On Route A, replace `localhost` with `host.docker.internal` in every address.

### The tool we will connect

MCP, the Model Context Protocol, is a standard way for an agent to discover and call tools.  Save this as `word_count_server.py` in your project:

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("word-tools")

@mcp.tool()
def word_count(text: str) -> int:
    """Count the words in a piece of text."""
    return len(text.split())

if __name__ == "__main__":
    mcp.run()
```

Install the library in your project's environment with `uv add 'mcp[cli]<2'` or `python3 -m pip install 'mcp[cli]<2'`.  The docstring becomes the tool's description, and the description is what the model reads when it decides whether to call the tool.

A small local model may see this tool and still call it badly.  When we tested `llama3.2:1b`, opencode sent the arguments in the wrong shape, and Oh My Pi printed the call as text instead of making it.  Both agents had found the tool, so the setup was right.  If this happens to you, try a larger model.
{: .tb-warning data-title="Watch out"}

### OpenCode

**A local model and the MCP server.**  Save this as `opencode.json` in your project:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama",
      "options": { "baseURL": "http://localhost:11434/v1" },
      "models": { "llama3.2": { "name": "llama3.2", "tools": true } }
    }
  },
  "model": "ollama/llama3.2",
  "mcp": {
    "word-tools": {
      "type": "local",
      "command": ["python3", "word_count_server.py"],
      "enabled": true
    }
  }
}
```

Run `opencode mcp list` from that folder.  If it says that no servers are configured, run it a second time, because the first listing in a new folder can come back empty.  Use the `python3` from your project's environment in `command` if the library is installed there.

**A custom provider.**  Any service with an OpenAI-compatible address can be added next to `ollama` inside `provider`.  The file names the variable that holds your key and never holds the key itself:

```json
"ursinus": {
  "npm": "@ai-sdk/openai-compatible",
  "name": "Ursinus AI",
  "options": {
    "baseURL": "https://ursinus.ai/api/v1",
    "apiKey": "{env:URSINUSAI_API_KEY}"
  },
  "models": { "MODEL-NAME": { "name": "Ursinus model", "tools": true } }
}
```

Replace `MODEL-NAME` with a model your key can use, and choose it with `/models` inside opencode.  The [End-to-End OpenCode Setup]({{ site.baseurl }}/Tutorials/OpenCodeSetup) tutorial goes further on providers, permission gates, skills, and plugins.

**Plan before you build.**  Press **Tab** to switch between the two main agents.  **Build** can change your files, and **Plan** is restricted to analysis, so you can discuss an approach first and press Tab again when you are ready for it to act.

**Other features you will use.**

| To do this | Use |
|---|---|
| Point the agent at a file | Type `@` and part of the file name |
| Hand a task to a helper agent | Mention it, such as `@general` or `@explore` |
| Run a shell command and show the agent its output | Start the message with `!`, as in `!ls -la` |
| Have it write an `AGENTS.md` for this project | `/init` |
| Take back its last change, or restore it | `/undo` and `/redo`, in a git repository |
| Choose a model | `/models` |
| Shrink a long conversation | `/compact` |
| Start over, or return to earlier work | `/new` and `/sessions` |
| Save the conversation | `/export` |
| Share it by link | `/share`, and read it first, because anyone with the link can see it |
| Make your own command | Save a prompt as `.opencode/commands/review.md`, using `$ARGUMENTS` for what you type after `/review` |

### Oh My Pi

**A local model.**  Oh My Pi keeps its models in `~/.omp/agent/models.yml`:

```yaml
providers:
  ollama:
    baseUrl: http://localhost:11434/v1
    api: openai-completions
    auth: none
    models:
      - id: "llama3.2"
        name: "llama3.2"
        reasoning: false
        input: [text]
        contextWindow: 16384
        maxTokens: 4096
```

Make it the default in `~/.omp/agent/config.yml`:

```yaml
modelRoles:
  default: "ollama/llama3.2"
```

Check it with `omp models ollama`.  On Route A, your home directory disappears when the container exits, so keep these files in your repository by running `export PI_CODING_AGENT_DIR=/workspace/.omp-agent` first and saving them there.  Add `.omp-agent/` to `.gitignore`, because Oh My Pi writes its session history there as well.

**A custom provider.**  Add another entry under `providers`.  Here, `apiKey` is the *name* of the variable, not the key:

```yaml
  ursinus:
    baseUrl: https://ursinus.ai/api/v1
    api: openai-completions
    apiKey: URSINUSAI_API_KEY
    models:
      - id: "MODEL-NAME"
        name: "Ursinus model"
        reasoning: false
        input: [text]
        contextWindow: 128000
        maxTokens: 4096
```

**The MCP server.**  Save this as `.omp/mcp.json` in your project, then type `/mcp list` inside Oh My Pi to confirm it, or `/mcp test word-tools` to try the connection:

```json
{
  "mcpServers": {
    "word-tools": {
      "command": "python3",
      "args": ["word_count_server.py"]
    }
  }
}
```

**Plan mode.**  Type `/plan`, or press Alt+Shift+P, to turn it on.  You can also start with a request, as in `/plan add input checking to my script`.  The agent stays read-only while it works out a plan, and then you review the plan before anything changes.  `/plan-review` reopens that review.

**Loop mode.**  `/loop` sends the same prompt again each time the agent finishes.  This is useful when "keep going until it works" is a real instruction, but an unbounded loop keeps spending time and tokens, so give it a limit:

| Command | What it does |
|---|---|
| `/loop 5 Fix the next failing test.` | Runs the prompt five times |
| `/loop 10m Improve the docstrings.` | Keeps going for ten minutes |
| `/loop 20 --until 'pytest -q' Fix the next failing test.` | Runs up to twenty times, and stops when `pytest -q` succeeds |
| `/loop 20 --while 'grep -q TODO notes.md' Finish the next TODO.` | Continues only while the command succeeds |
| `/loop` | Turns loop mode off when it is on |

Why would we check with a command instead of asking the model whether it is done?  The exit status of `pytest` does not depend on the model's opinion of its own work!

**Other features you will use.**

| To do this | Use |
|---|---|
| Give it one objective to pursue on its own | `/goal`, or `/guided-goal` to be interviewed first.  If it says goal mode is off, turn it on in `/settings` |
| Switch models for this session | `/model`, or Alt+P |
| Change how hard it thinks | `/effort`, or Shift+Tab |
| Ask a side question without derailing the task | `/btw` |
| Line up your next message while it works | `/queue`, or Ctrl+Q |
| See its task list | `/todo` |
| See what is using up the context window | `/context` |
| See which tools it can use | `/tools` |
| Shrink a long conversation | `/compact`, or `/handoff` to write a summary for later |
| Go back to an earlier message and try another path | `/branch`, then `/tree` to move between paths |
| Start over, or return to earlier work | `/new` and `/resume` |
| Review, stage, and commit changes | `/git` |
| Work in a separate git worktree | `/wt` |
| Find and install skills | `/skills` |
| Have a second model review each turn | `/advisor` |
| See every shortcut | `/hotkeys` |

Run one small task through both agents, then ask which differences came from the model and which came from the agent around it.  Keep the model the same for that comparison, or you will not be able to tell.

---

## Optional: Install OpenWebUI, the chat interface over Ollama

OpenWebUI is a self-hosted web front end that sits in front of your Ollama server: a private chat window over the model you pulled in Step 1, with tools, knowledge bases, and an API of its own.  Nothing in this assignment needs it.  The Local Agent lab's no-code path and several later tutorials assume it is installed, so doing it now, while the model is fresh, saves you the first fifteen minutes of that lab.

| Optional OpenWebUI at a glance | |
|---|---|
| **Where you type** | Your host terminal, on both routes.  On Route A, OpenWebUI is its own container beside the course container, not inside it |
| **What you install** | OpenWebUI by one of two routes: Docker (recommended if Docker Desktop is already running) or pip (no Docker required) |
| **You paste** | Nothing is required.  A screenshot of the model dropdown showing `llama3.2` is welcome |

**Do.**  Confirm Ollama is running (`ollama list` shows `llama3.2`), then install by **one** route.

Route 1, Docker.  Each flag does one job: `-p 3000:8080` publishes the container's port 8080 on your host's port 3000; `--add-host=host.docker.internal:host-gateway` lets the container reach Ollama on your host (required on Linux, harmless elsewhere); `-v open-webui:/app/backend/data` keeps your account, models, and chat history in a named volume that survives restarts.

```bash
docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data --name open-webui --restart always \
  ghcr.io/open-webui/open-webui:main
```

Route 2, pip.  The install downloads a large dependency set; expect several minutes.  The last command starts the server in your terminal; leave that terminal open.  When the startup banner shows `Uvicorn running on http://0.0.0.0:8080`, the server is up.

```bash
python3 -m venv owui
source owui/bin/activate        # PowerShell: .\owui\Scripts\Activate.ps1
python3 -m pip install open-webui
open-webui serve
```

> **If `pip` says `externally-managed-environment`.**  Your operating system manages its own Python (common on Ubuntu, Debian, WSL, and Homebrew), so it refuses packages installed directly into it, because they could break the tools that depend on it.  Nothing is wrong with your machine, and the virtual environment is the fix: run the first two lines, and then install again.  Do not use `--break-system-packages`.

> **If `python3 -m venv` says `ensurepip is not available`.**  On Ubuntu, Debian, and WSL, virtual environments come in a separate package.  Run `sudo apt install python3-venv`, delete the partial folder with `rm -rf owui`, and then start again from the `venv` line.  If that package name is not found, use the version-specific name the error message gives you, such as `python3.14-venv`.

**Then, in the browser** (`http://localhost:3000` for Docker, `http://localhost:8080` for pip):

1. **Create an admin account** (name, email, password).  It exists only in your local OpenWebUI database; the email is a local username.
2. In the **model selector at the top left**, confirm `llama3.2:latest` appears.  OpenWebUI finds a local Ollama server on its own.
3. Send one message ("Say hello in one sentence.") and read the reply.
4. **Create an API key**: click your initials (bottom left), then **Settings**, **Account**, **API Keys**, **Create new key**.  Keep it somewhere you will find again.  It authenticates you to a server on your own machine; it is not a payment credential.  The Local AI session and the Local Agent lab both use it.

> **Troubleshooting.**
>
> - An empty model dropdown means OpenWebUI cannot reach Ollama.  On the Docker route, confirm the `--add-host` flag was present, then open **Admin Panel**, **Settings**, **Connections** and set the Ollama URL to `http://host.docker.internal:11434`.  Not `localhost`, which inside the container means the container itself; see *The address rule* above.  On the pip route the URL is `http://localhost:11434`, and `ollama serve` must be running.
> - If `http://localhost:3000` refuses to connect on the Docker route, run `docker ps`.  When the container is missing, `docker logs open-webui` says why.  A port conflict means something else owns 3000, so re-run with `-p 3001:8080` and browse to 3001.
> - If `pip install open-webui` fails with a resolver or build error, it is almost always a Python version issue.  Delete `owui`, create a 3.11 environment with `python3.11 -m venv owui && source owui/bin/activate`, and install inside it.


## Optional 5d: connect a hosted endpoint, if you are given one

> **This is not graded and is not on the Overview checklist.**  It is here for when you are given access to a hosted, OpenAI-compatible endpoint (an address ending in something like `/api/v1`, plus an API key).  Your local Ollama provider stays exactly as 5b left it; this adds a second provider beside it.

1.  **Install the auto-models plugin by asking the agent.**  In `opencode`, with any model selected (the free default is enough), type the prompt `install this opencode plugin https://github.com/BillJr99/opencode-auto-models`.  Read the change it proposes to `opencode.json` before you approve it.  Then type `/quit` and start `opencode` again, because plugins load only at startup.  The plugin asks each provider which models it serves, so you never type model names by hand.
2.  **Name the endpoint in `opencode.json`.**  Add a second entry to the `provider` map you wrote in 5b, holding only the address: no key, and no `models` map, since the plugin fills that in.  `myendpoint` is a placeholder ID; you type the same word again in the next step.

    ```json
    "myendpoint": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "My Endpoint",
      "options": { "baseURL": "https://YOUR-ENDPOINT/api/v1" }
    }
    ```

    Check that the file still parses with `python3 -m json.tool opencode.json`, then `/quit` and restart.
3.  **Store the key with `/connect`.**  Type `/connect`, scroll to **Other**, enter the same provider ID (`myendpoint`), and paste your API key at the key prompt.  `/connect` asks only for the ID and the key, never the address, which is why step 2 comes first.
4.  **Pick a model.**  Type `/models` and choose from the list under your endpoint's name.

> **Watch out.**  The `/connect` key prompt is the one place to paste the key.  Never paste it into an ordinary prompt, where it is sent to the model.  If `/models` shows your endpoint with no models, the ID you typed in `/connect` does not match the key in the `provider` block, or you have not restarted since installing the plugin.  The [End-to-End OpenCode Setup tutorial]({{ site.baseurl }}/Tutorials/OpenCodeSetup) walks the same route in more detail.


## Optional: install herdr while you are here

> **This is not graded and is not on the Overview checklist.**  It is here because installing it now costs one command, and a later lab assumes it is on your bench.

**herdr** is an agent-aware terminal multiplexer.  It keeps agents running after you close your laptop or drop an SSH connection, and it shows you which agent is blocked, working, or done, so you are not cycling through terminal panes to find the one waiting on you.

| Where | How to install |
|---|---|
| **Route A** | Already in the course image, alongside opencode.  Confirm with `herdr --version` |
| **Route B: macOS, Linux, WSL** | `curl -fsSL https://herdr.dev/install.sh \| sh` |
| **Route B: macOS with Homebrew** | `brew install herdr` |
| **Route B: native Windows** | `powershell -ExecutionPolicy Bypass -c "irm https://herdr.dev/install.ps1 \| iex"` |

The installer downloads one binary, checks its SHA-256, and puts it in `~/.local/bin`.  If you include `herdr --version` in your transcript, I will read it, but its absence costs you nothing.


## Alternative: do it by hand, with `ssh-keygen`

`gh auth login` automates a three-step exchange that is worth seeing once, and if `gh` will not install on your machine you need it anyway.  Nothing below is required if 2b succeeded.

**Check for a key you already have.**

```bash
ls -al ~/.ssh
```

If `id_ed25519.pub` (or `id_rsa.pub`) is listed and you know its passphrase, skip to registering it.

**Create one.**  Use the email address tied to your GitHub account:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

Press Enter to accept the default location, and set a passphrase rather than leaving it empty.  Then load it into the agent so you type that passphrase once per session rather than once per push:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**Register the public half with GitHub.**  Print the `.pub` file, which is the *public* one:

```bash
cat ~/.ssh/id_ed25519.pub
```

> **Watch out!**  Never paste or send the file without the extension, which is the private key.  Only the `.pub` line goes to GitHub.

On GitHub, go to **Settings -> SSH and GPG keys -> New SSH key** (the direct link is [github.com/settings/keys](https://github.com/settings/keys)).  Title it after the machine it lives on, so you can revoke exactly one laptop later; leave the key type as **Authentication Key**; paste the whole line, and save.  Then test with `ssh -T git@github.com` and continue from 2d, using `git clone git@github.com:<your-username>/<your-repo>.git` in place of `gh repo clone`.

## Other alternatives for 2d and 2e (choose at most one)

| Tool | Replaces | Best for | Verify with |
|---|---|---|---|
| **VS Code** | The clone in 2d | Anyone already working in VS Code | `git log --oneline` in the integrated terminal |
| **GitHub Desktop** | 2d and 2e | Anyone who would rather not type git commands yet | `git log --oneline` from Repository > Open in terminal |

**VS Code, for the clone in 2d.**  It drives the same git underneath, so the result is identical.

With no folder open, the Source Control view (Ctrl+Shift+G, or Cmd+Shift+G on macOS) offers a **Clone Repository** button.  From anywhere, the Command Palette (Ctrl+Shift+P, or Cmd+Shift+P) runs **Git: Clone**.  Either one asks for the repository address, where you paste the same SSH URL, then asks which local folder to put it in, `~/cs357` here, and offers to open the clone when it finishes.

Say yes.  The integrated terminal (Ctrl+\`) then opens already inside the repository, which is where you run `git log --oneline` for your transcript.

The palette also offers **Clone from GitHub**, which lets you pick from a list of your repositories instead of pasting a URL.  Note that it signs you in to GitHub inside VS Code and authenticates as that account rather than with your key.

**GitHub Desktop, for 2d and 2e.**  If you would rather not type git commands yet, [GitHub Desktop](https://desktop.github.com/) is a supported option and handles authentication for you: install it, sign in, use File > New repository (or Add local repository) on your `cs357` folder, commit from the Changes tab, and Publish repository to push.  Then paste the output of `git log --oneline` from Repository > Open in terminal, which is the same transcript the command-line route produces.

> **Watch out!**  GitHub Desktop is not a substitute for 2a.  It bundles Git for Windows, not `gh`, and signing in to Desktop does not sign in `gh`.  Do 2a and 2b anyway, because the *Coding Agents* session and every agent you run afterwards drive GitHub from a terminal.

The two GitHub downloads are easy to confuse on native Windows without WSL2:

| | GitHub CLI (`gh`) | GitHub Desktop |
|---|---|---|
| **What it is** | The command-line tool, a separate install | The graphical client |
| **What it bundles** | Nothing else | Git for Windows, which is where `ssh-keygen` and Git Bash come from |
| **How it authenticates** | `gh auth login`, over SSH or HTTPS | Its own sign-in, handled for you |
| **Does it give you the other one?** | No, and it does not need to | No.  Desktop cannot run `gh issue create` |
| **Installing both** | Common, and they coexist happily | |

The Ubuntu or WSL2 route gives you the standard Unix tooling instead, and every command on this page then works as written.

> **Route A and credentials inside the container.**  The credential you just made lives on your host, which is where it belongs.  Inside the course container, A6 recommends a fine-grained personal access token scoped to `cs357-work` instead, because that container will soon be running agent code, and a credential placed inside it is a credential that code can use.  That is why A2 clones `cs357-work` over HTTPS: the token authenticates HTTPS pushes.  Step 6 of the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md) goes deeper, and A6 shows the read-only `~/.ssh` mount if you would rather use your key there.


## Command-Line Survival: reference (use as needed, not required reading cover-to-cover)

| Resource | What it is for |
|---|---|
| [The Shell, in Full]({{ site.baseurl }}/Tutorials/Shell) | The course's own shell tutorial, from the first prompt through pipes, PATH, and processes |
| [tldr pages](https://tldr.sh/) | Plain-language, example-first cheat sheets for any command (`tldr tar`) |
| [explainshell](https://explainshell.com/) | Paste any command line and see each flag explained |
| [ShellCheck](https://www.shellcheck.net/) | Catches bugs in shell scripts before they bite |
| `curl` and [HTTPie](https://httpie.io/) plus [jq](https://jqlang.github.io/jq/) | You will hit JSON APIs (Ollama, MCP) all semester; `curl ... \| jq` is your friend |

