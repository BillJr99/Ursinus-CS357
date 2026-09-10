---
layout: assignment
permalink: /Assignments/Overview
title: "CS357: Foundations of Artificial Intelligence - Overview"

info:
  coursenum: CS357
  purpose: "To get your local AI stack and your coding agent working before the labs depend on them, capture a baseline snapshot of your thinking about AI that you will revisit at the end of the semester, and launch your team."
  tilt:
    task: "Install and verify a working local AI environment and coding agent, and write a short baseline reflection on AI agency and trust."
    criteria: "I grade this on a complete setup-verification transcript and a specific, personal reflection in equal measure.  Please read the rubric below for the details."
  points: 100
  goals:
    - To install and verify a working local AI environment including Ollama, a pulled model, a Python API call, and a coding agent answering from that same local model
    - To demonstrate baseline command-line, git, and Python-environment fluency by navigating a shell, cloning and committing to a repository, and creating a reproducible environment with uv
    - To articulate personal baseline beliefs about AI agency, trust, and delegation with specific examples
  rubric:
    - weight: 40
      description: Environment Setup and Verification
      preemerging: Little or no evidence that the environment was attempted
      beginning: Some components installed, but the verification transcript is missing or incomplete
      progressing: Ollama installed and verified with a transcript, with a minor omission such as a missing model listing, missing version information, or a missing coding-agent check, or the command-line and git checkpoint is incomplete
      proficient: The transcript shows all four Ollama steps completed with verbatim terminal output, the output of ollama --version, ollama list showing at least one model, the curl /api/tags JSON response, and the Python script output including a non-empty "content" field, plus the fifth step, the output of opencode --version and one answered prompt from your local model, plus the operating system name and version; the command-line and git checkpoint (Part 1.5) is also complete, showing the shell-navigation commands, a git commit/push transcript (command line or GitHub Desktop), and the uv environment creation; any failed step includes the verbatim error message, a stated hypothesis, and what was tried
    - weight: 40
      description: Reflection Essay
      preemerging: The reflection is missing or does not address the prompts
      beginning: The reflection addresses some prompts superficially without naming specific tools or moments
      progressing: The reflection addresses all four sections with specific examples, but the connection between the two delegation examples is not analyzed or the "What I Want to Build" section is vague
      proficient: All four sections are present and addressed with concrete specifics, a named AI tool and a described moment of surprise in "My AI Experience," a personal definition of agency distinct from any course reading in "What Agent Means to Me," a pair of delegation examples where the contrast between the two is explicitly analyzed, and a "What I Want to Build" description naming what the system would do, who would use it, and what working would look like
    - weight: 20
      description: Submission
      preemerging: An incomplete submission is provided
      beginning: The submission is provided but is disorganized, the transcript and the reflection are hard to tell apart, or one is missing
      progressing: All required components are present in a single file, with a minor omission such as an unlabeled transcript section or missing OS information
      proficient: A single well-organized PDF or Markdown file with each component clearly labeled, the five-step setup transcript with version and OS details, the Part 1.5 command-line and git checkpoint, and the four-section reflection, with the collaboration, AI-disclosure, and time questions answered at the end
  readings:
    - rtitle: "Welcome Activity"
      rlink: "https://www.billmongan.com/Ursinus-CS357-Overview"
    - rtitle: "Required setup (Route A): the Your AI Workbench activity, on your course development environment - Host Ollama, the Course Container, Git, and GitHub"
      rlink: "Activities/liascript-devenvironment.md"
      liapage: true
    - rtitle: "Required setup: the Your AI Workbench activity, Step 0 (the shell in ten minutes), covering the terminal skills every later lab assumes and the read-before-you-run habit"
      rlink: "Activities/liascript-devenvironment.md"
      liapage: true
    - rtitle: "The Shell, in Full: pipes, redirection, background jobs, and PATH, if the shell is new to you"
      rlink: "../Tutorials/Shell"
    - rtitle: "Mitchell, Prologue and Chapter 1"

tags:
  - intro
  - ai
  - agents

---

In this warmup you'll install your local AI stack and your coding agent, and write a short baseline reflection on your experiences with AI.  I have kept the stakes low here on purpose.  It exists to make sure your tools work before the labs depend on them, and to capture a snapshot of your thinking that you'll come back to at the end of the semester.  (Your team charter is **not** part of this assignment; it is handed out separately once teams are announced; see the [Project Thread]({{ site.baseurl }}/Projects/PBLThread#the-team-charter-a-signed-team-contract).)  There are no wrong answers in the reflection.  This is a starting point, and I am not evaluating what you know.  See the course schedule for this onboarding assignment's due date; it is assessed within the Class Activities and Participation category.

---

## Before You Start

This is the first thing you install for this course.  I have put it early on purpose, so that a broken setup costs you this assignment rather than a lab.

**Pace yourself: most of this is downloading.**  The model pull alone is about 2 GB, and the container image is larger.  Start the downloads on good wifi and write the reflection while they run.  Do not leave this for the night before; the downloads will not go any faster because you are in a hurry, and I can't help you at 11 PM.

**You need:** a laptop you can install software on, a GitHub account, and about 10 GB of free disk.  If any of those is a problem, say so this week rather than in week four.  There is a lab-machine route, and it takes some scheduling.

### The setup map

This assignment is nine stages.  Each stage ends with one command whose output you paste into your submission, so you can always tell whether a stage is done.  Work down the table in order, and use the last column to find the steps.

| Stage | What you do | The command that proves it | What you paste | Where the steps are |
|---|---|---|---|---|
| 0 | Open a terminal, learn to move around and save a file, tell your host prompt from a container prompt, and note your operating system | `pwd` | Your operating system name and version, and your route (A or B) | Part 1, *Opening a terminal* and *Where am I typing?* |
| 1 | Install Ollama and pull a model | `ollama list` | The output of `ollama --version` and `ollama list` | Part 1A, Step 1 |
| 2 | Chat with the model once | `ollama run llama3.2 "..."` | The model's reply | Part 1A, Step 2 |
| 3 | Confirm the REST API answers | `curl http://localhost:11434/api/tags` | The JSON | Part 1A, Step 3 |
| 4 | Call the model from Python | `python3 ollama_check.py` | The printed JSON, including a `"content"` field | Part 1A, Step 4 |
| 5 | Confirm the coding agent talks to that model | `opencode --version` | The version string and one answered prompt | Part 1B, Step 5 |
| 6 | Navigate a shell and search a file | `grep -n "localhost" notes.txt` | The commands and their output | Part 1.5, Step 1 |
| 7 | Authenticate to GitHub, then commit and push | `git log --oneline` | The `ssh -T` greeting and the log | Part 1.5, Step 2 |
| 8 | Create a reproducible Python environment | `uv run python -c "import requests; print(requests.__version__)"` | The printed version | Part 1.5, Step 3 |
| 9 | Write the baseline reflection | none | Four labeled sections | Part 2 |

**Do the stages in this order.**  Start Stage 1 first, because the download runs in the background.  While it downloads, write the reflection (Stage 9); it needs no tools.  Then finish Stages 2 through 5, and do Stages 6 through 8 last, since they use what you just installed.

**If a stage fails, document it and move on.**  A documented failure earns full credit for that stage: quote the error verbatim, state your hypothesis about the cause, and say what you tried.  "It worked eventually" earns nothing.  Work down the Troubleshooting table at the end of this page before you post in the course channel.

> **You've succeeded when** the four boxes in the Part 1A checklist and the three in the Part 1B checklist are checked, all three in the Part 1.5 checklist are checked, and your reflection has four labeled sections.

---

## What a Strong Submission Looks Like

A strong submission has these qualities:

1.  **The transcript is complete and honest.**  It shows the actual terminal output (version numbers, model names, the API response), copied faithfully.  If something broke, quote the error verbatim and tell me what you tried.  I won't give credit for a fabricated or paraphrased transcript.
2.  **The reflection is personal and specific.**  It names a real AI tool you used, describes a real moment of surprise or confusion, and takes an actual position on agency and trust.  I am not looking for a dictionary definition or a summary of the syllabus.  A strong reflection reads like a journal entry from someone thinking carefully.

A weak submission has a transcript that says "it worked" without showing output and a reflection that restates prompts without answering them.

---

## Part 1: Tool Setup

Part 1 has two halves, and you must do both:

| | What you stand up | Steps | What the transcript shows |
|---|---|---|---|
| **Part 1A** | The local model stack: Ollama, a pulled model, the REST API, and a Python call against it | Steps 1-4 | Four pieces of terminal output |
| **Part 1B** | The coding agent: opencode, talking to that same local model | Step 5 | A version string and one answered prompt |

Part 1A must work before Part 1B can: the coding agent in Part 1B is pointed at the model you pull in Part 1A, so do them in order.

### Which route should I take?

A route decides *where* Steps 1 through 5 run.  The commands are the same on both routes, and neither route is the "real" one.

| | Route A (recommended): host Ollama plus the course container | Route B: native install |
|---|---|---|
| Who it is for | Anyone whose laptop can run Docker Desktop | Anyone whose laptop cannot run Docker, or anyone using a lab machine |
| Where Ollama runs | On your host, natively | On your host, natively |
| Where Steps 1-3 run | Your host terminal | Your host terminal |
| Where Steps 4-5 run | Inside the course container | Your host terminal |
| What you install | Ollama, Docker Desktop, and the course container, by following the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md) | [Ollama](https://ollama.com/download), the Python `requests` library, and opencode from [opencode.ai](https://opencode.ai/) |

**You do not have to decide yet.**  Steps 1 through 3 are identical on both routes, so start them now.  Decide at Step 4.  If Docker Desktop installs and `docker run hello-world` succeeds, take Route A and complete the Development Environment activity through its Step 5 before you return here.  If Docker will not run on your machine, take Route B and say so in your transcript.

I recommend Route A because every later lab assumes it and it is what we build together in the *Your AI Workbench* session.  Route B is complete and supported too.  On Route A, the activity's own container verification output (the `/api/tags` one-liner, `promptfoo --version`, and the spacy model check) belongs in your transcript as well.

### Opening a terminal, moving around, and saving a file

Every step on this page happens at a terminal, and several ask you to save a file.  Here is how, on every system this course supports.  Come back to this section whenever a step says "open a terminal," "`cd`," or "save it."

**1. Open a terminal.**

| System | How to open it | What the prompt looks like |
|---|---|---|
| macOS | Press Cmd+Space, type `Terminal`, press Enter | `you@laptop ~ %` |
| Windows, PowerShell | Open the Start menu, type `PowerShell`, press Enter (not "Command Prompt") | `PS C:\Users\you>` |
| Windows, WSL2 Ubuntu | Open the Start menu, type `Ubuntu`, press Enter (Step 2 of the Development Environment activity installs it) | `you@laptop:~$` |
| Linux | Press Ctrl+Alt+T, or open Terminal from the applications menu | `you@laptop:~$` |
| VS Code, on any system | Press Ctrl+` (backtick), or **View > Terminal**.  It opens in the folder you have open | one of the above |

**2. Find where you are, and move.**  The terminal always has a current folder, and every relative path is measured from it.  These commands work the same in every shell above, including PowerShell:

```bash
pwd               # print the folder you are in
ls                # list what is here (ls -la also shows hidden files; in PowerShell, plain ls)
cd ~              # go to your home folder
mkdir -p ~/cs357  # make a folder for this course (in PowerShell: mkdir ~/cs357)
cd ~/cs357        # go into it
cd ..             # go up one level
```

`~` is your home folder: `/Users/you` on macOS, `C:\Users\you` in PowerShell, and `/home/you` in WSL2 Ubuntu.  From WSL2, your Windows files are under `/mnt/c/Users/you`.  Do all of this course's work in `~/cs357`, or in the `cs357-work` clone from the activity on Route A, so that every `cd ~/cs357` on this page lands in the same place.  Press **Tab** to complete a name you have started typing, and the up arrow to recall the previous command.

**3. Save a file.**  When a step says "save this as `ollama_check.py`," first `cd` into the folder the file belongs in, then use one of these:

- **nano**, on macOS, Linux, WSL2, and inside the course container.  Run `nano ollama_check.py`, paste the contents (Cmd+V on macOS; right-click or Ctrl+Shift+V in Ubuntu), press **Ctrl+O** then **Enter** to write the file, then **Ctrl+X** to exit.
- **vim**, present on every Unix system.  Run `vim ollama_check.py`, press **i** to enter insert mode, paste, press **Esc**, then type `:wq` and press **Enter** to write and quit.  If you get stuck, press **Esc**, type `:q!`, and press **Enter** to leave without saving.
- **VS Code**, on any system.  From the folder, run `code .` to open it (or **File > Open Folder**), then **File > New File**, paste, and press **Ctrl+S** (Cmd+S on macOS) to save under the name the step gives.  Type the name with its extension, `ollama_check.py`, and check that the editor did not add `.txt`.
- **PowerShell without nano.**  Run `notepad ollama_check.py`, click **Yes** to create the file, paste, save, and close Notepad.  For a one-line file, `Set-Content notes.txt "model: llama3.2"` writes it directly.

**4. Confirm it landed.**  Run `ls` and see the file's name; run `cat ollama_check.py` and see its contents.  If `ls` does not show it, you saved into a different folder than the one you are in, and `pwd` tells you which one that is.

### Where am I typing?

Most setup failures on this page come from running a command in the wrong place.  Before every command, read your prompt.

| Your prompt looks like | You are on | What `localhost` means there |
|---|---|---|
| `you@laptop ~ %`, `you@laptop:~$`, or `PS C:\Users\you>` | Your **host**: macOS, Linux, WSL2 Ubuntu, or PowerShell | Your laptop, where Ollama listens |
| `student@a1b2c3d4e5f6:/workspace$` | Inside the **course container** | The container itself, where nothing listens |

**The address rule.**  Every command on this page that names Ollama's address is written as `localhost:11434`.  On your host, leave it as written.  Inside the container, replace `localhost` with `host.docker.internal`, because `localhost` inside a container means the container.  That is the only substitution on this page, and it applies only inside the container.  Running Ollama itself as a Docker container does not change the rule: with its port published (`-p 11434:11434`), `localhost:11434` on your host still reaches it.

**Windows.**  Use PowerShell (Windows 10 and 11 include it; open it from the Start menu) or WSL2 Ubuntu, not the old Command Prompt.  Every command on this page and in the labs is written for PowerShell or a Unix shell.  In PowerShell, `python3` is spelled `python`.  When a transcript from inside the container is what you have, include the container prompt in your copy-paste so it is visible where each command ran.

---

### Part 1A: The Local Model Stack (Steps 1-4)

Run Steps 1 through 3 on your host on both routes.  Run Step 4 on your host on Route B, or inside the container on Route A.  Capture the output of every command.

**Step 1. Install Ollama, pull a small model, and confirm both.**

*Do.*  Install [Ollama](https://ollama.com/download) for your operating system.  Then open a new terminal and run:

```bash
ollama --version
ollama pull llama3.2
ollama list
```

*Expected.*  A version string, a download that ends in `success`, and a table from `ollama list` with a `llama3.2:latest` row.  The pull is about 2 GB and is the longest wait on this page.

*Paste.*  The `ollama --version` line and the `ollama list` table.

*If it fails.*  `command not found` or `not recognized` means your terminal predates the install; open a new one.  See the Stage 1 rows in Troubleshooting.

**Step 2. Run a CLI sanity check.**

*Do.*

```bash
ollama run llama3.2 "Say hello in five words."
```

*Expected.*  One short line of text from the model.  The exact words vary.  On CPU-only hardware the first reply can take a minute, which is normal.

*Paste.*  The command and the reply.

*If it fails.*  A connection error means the Ollama server is not running, which is separate from Ollama being installed.  See the Stage 3 rows in Troubleshooting.

**Step 3. Verify the REST API responds.**

*Do.*

```bash
curl http://localhost:11434/api/tags
```

*Expected.*  A JSON object that begins `{"models":[{"name":"llama3.2:latest", ...`.

*Paste.*  The JSON.  Trim it to the first few lines if it is long.

*If it fails.*  `Connection refused` means the server is not running.  Start the Ollama desktop app, or run `ollama serve` in a second terminal and leave that terminal open.

**Step 4. Call the model from Python.**

This is the first step where the route matters.

*Do, on Route A.*  Complete the Development Environment activity through its Step 5, enter the container, and run everything below at the container prompt with `host.docker.internal` in place of `localhost`.  The container already has the `requests` library installed.

*Do, on Route B.*  Install the `requests` library into the Python you will run:

```bash
python3 -m pip install requests
```

On Windows, in PowerShell, that is `python -m pip install requests`.

*Then, on either route*, save the script below as `ollama_check.py` in your `~/cs357` folder (or in `/workspace` inside the container).  Python runs files, so put the lines in a file rather than typing them at a prompt.  *Opening a terminal, moving around, and saving a file* above walks through nano, vim, VS Code, and Notepad; any of them does the job.

```python
import requests, json

response = requests.post(
    "http://localhost:11434/api/chat",
    json={
        "model": "llama3.2",
        "messages": [{"role": "user", "content": "What is 2 + 2?"}],
        "stream": False
    }
)
print(json.dumps(response.json(), indent=2))
```

Run it from the directory the file lives in:

```bash
cd ~/cs357
python3 ollama_check.py
```

On Windows in PowerShell the command is `python ollama_check.py`.  VS Code's Run button (the triangle in the top right, with the Python extension installed) runs the same command in its integrated terminal, and either transcript is fine for your submission.

*Expected.*  A JSON object with a `"message"` block whose `"content"` field holds the model's answer.

*Paste.*  The printed JSON.

*If it fails.*  `ModuleNotFoundError: No module named 'requests'` means the install landed in a different Python than the one you ran; use `python3 -m pip install requests` (or `python -m pip` on Windows) from the same terminal, then rerun.  A `ConnectionError` inside the container means the address rule was not applied.  `can't open file ... No such file or directory` means you are in a different directory than the one you saved into; `ls` (or `dir`) shows which.

#### Part 1A Checklist

- [ ] `ollama --version` returns a version string
- [ ] `ollama list` shows at least one downloaded model
- [ ] The `curl` command to `/api/tags` returns JSON (not a connection error)
- [ ] Your Python script prints a response that includes a `"content"` field

#### If you installed Ollama as a Docker container

The course expects Ollama installed natively, as in Step 1.  If you installed it as a Docker container instead, the `ollama` command does not exist on your host, and every `ollama ...` command on this page runs *inside* that container.  Reach it with `docker exec`, naming the container.  The conventional name, and the one `docker run --name ollama` gives you, is `ollama`; `docker ps` shows what yours is actually called.  The word appears twice for a reason: the first is the container, the second is the program inside it.

```bash
docker exec ollama ollama --version
docker exec ollama ollama pull llama3.2
docker exec ollama ollama list
```

Add `-it` when the command is interactive, as the chat in Step 2 is: `docker exec -it ollama ollama run llama3.2 "Say hello in five words."`.  Steps 3 and 4 are unaffected as long as you published the port with `-p 11434:11434`, because `localhost:11434` on your host then reaches the server inside the container.  A transcript from this route is fully accepted; leave the `docker exec` prefix visible in what you paste, so I can see where the command ran.

---

### Part 1B: Your Coding Agent (Step 5)

**Step 5. Confirm your coding agent is installed and talking to that same local model.**

The agent is **opencode**, and every install route lives at [opencode.ai](https://opencode.ai/).  The Week 2 lab depends on this step, so it is here rather than discovered later.

*5a. Install it.*

- **On Route A**, it is already in the course image, so there is nothing to install.
- **On Route B**, install it yourself: `curl -fsSL https://opencode.ai/install | bash` on macOS, Linux, or WSL; `npm i -g opencode-ai` if you already have Node.js; or `choco install opencode` or `scoop install opencode` in PowerShell on native Windows.

That page also offers a **desktop app**, in beta for macOS, Windows, and Linux, if you would rather work in a window than a terminal.  It drives the same agent, but install the command-line version even if you try the desktop one, because this assignment and every lab ask for terminal output.

*5b. Point it at your model.*  opencode reads one configuration file, and the file name matters: it is `opencode.json`, never `config.json`.  opencode silently ignores a file with the wrong name.

| Where opencode runs | Where the file goes | The `baseURL` inside it |
|---|---|---|
| Inside the course container (Route A) | `/workspace/opencode.json`, at the root of your repository | `http://host.docker.internal:11434/v1` |
| Natively on macOS, Linux, or WSL (Route B) | `~/.config/opencode/opencode.json` | `http://localhost:11434/v1` |
| Natively on Windows (Route B) | `%USERPROFILE%\.config\opencode\opencode.json` | `http://localhost:11434/v1` |

The smallest working file registers Ollama and nothing else.  Create the folder if it does not exist, save this as `opencode.json` in the location from the table, and use the `baseURL` from the table:

```json
{
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "options": { "baseURL": "http://localhost:11434/v1" },
      "models": { "llama3.2": { "name": "llama3.2 (raw Ollama)" } }
    }
  }
}
```

Step 8 of the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md) walks through the same file in more detail, including an optional second provider you can add later.

*5c. Verify it.*

```bash
opencode --version
```

Then start `opencode`, type `/model`, and confirm your Ollama provider is listed.  Ask it one question ("what files are in this directory?" is enough).

*Expected.*  A version string, a `/model` list that names your Ollama provider, and an answer to your question.  A small local model answers slowly and sometimes oddly; that is the model, not your setup.

*Paste.*  The version string, and the question with the agent's answer.

*If it fails.*  An empty provider list means the file name or location is wrong.  Check the name first, then the location from the table, then that the JSON parses with `python3 -m json.tool opencode.json`.

#### Part 1B Checklist

- [ ] `opencode --version` returns a version string
- [ ] `/model` lists your Ollama provider
- [ ] The agent answered one prompt from your local model

#### Optional: install herdr while you are here

**This is not graded and is not on the checklist above.**  It is here because installing it now costs one command, and a later lab assumes it is on your bench.

**herdr** is an agent-aware terminal multiplexer.  It keeps agents running after you close your laptop or drop an SSH connection, and it shows you which agent is blocked, working, or done, so you are not cycling through terminal panes to find the one waiting on you.

- **Route A:** already in the course image, alongside opencode.  Confirm with `herdr --version`.
- **Route B (macOS, Linux, WSL):** `curl -fsSL https://herdr.dev/install.sh | sh`
- **Route B (macOS, Homebrew):** `brew install herdr`
- **Route B (native Windows):** `powershell -ExecutionPolicy Bypass -c "irm https://herdr.dev/install.ps1 | iex"`

The installer downloads one binary, checks its SHA-256, and puts it in `~/.local/bin`.  If you include `herdr --version` in your transcript, I will read it, but its absence costs you nothing.

---

### Capturing Part 1

Copy-paste or screenshot the output of all five steps, including the output of `ollama --version` and your operating system name and version.

**If any step fails:** document the error message verbatim, state your hypothesis about the cause, and describe what you tried.  A well-documented failure with a follow-up plan earns full credit for that step.  Do not delete error output or write "it eventually worked" without showing what changed.

---

## Part 1.5: Command-Line and Git Checkpoint

Every lab this semester runs from a terminal, lives in a git repository, and depends on a reproducible Python environment.  This checkpoint makes sure those tools work *before* the labs depend on them, the same philosophy as the Ollama setup above.  You do not need to be a shell wizard; you need to be able to move around, version your work, and stand up an environment without guesswork.  If any command below is unfamiliar, the **Command-Line Survival** resources at the end of this section will get you there.

**Route A note.**  Do the git steps of this checkpoint **from inside the course container**, against the `cs357-work` GitHub repository you created in the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md).  The activity's practice section (create `hello_agent.py`, run it against host Ollama, commit, push) is exactly this checkpoint, so its transcript satisfies the navigation and git items below.  Set up the SSH key in Step 2 on your host anyway, because that is where it belongs.  The `uv` step runs on your host on both routes; the container already bundles the course packages, and `uv` is your reproducible-environment tool for everything outside the container.

Complete each step and capture the terminal output.

**Step 1. Navigate and search.**

*Do.*  Create a working directory for this course, enter it, and list its contents:

```bash
mkdir -p ~/cs357 && cd ~/cs357 && pwd && ls -la
```

The directory is empty when you make it, so create a file for the search to find.  Redirecting a couple of lines into a file is the quickest way; typing them into an editor (`nano notes.txt`, or any of the ways in *Opening a terminal, moving around, and saving a file*) or copying in a file you already have works just as well:

```bash
printf 'model: llama3.2\nhost: http://localhost:11434\nagent: opencode\n' > notes.txt
cat notes.txt
```

`touch notes.txt` creates the file but leaves it empty, and a search over an empty file matches nothing, so put a line or two inside it.  In native PowerShell, the equivalent is `Set-Content notes.txt "model: llama3.2"`, since `printf` and `grep` are Unix shell tools, and `Select-String` is the PowerShell search command.  Running these from WSL2 or Git Bash keeps the commands as written.

Then search that file with `grep` (or `ripgrep`, the `rg` command, if installed):

```bash
grep -n "localhost" notes.txt
```

*Expected.*  `pwd` prints a path ending in `cs357`, `ls -la` lists `.` and `..`, `cat` prints your three lines, and `grep` prints `2:host: http://localhost:11434`.

*Paste.*  Every command above with its output.

**Step 2. Authenticate to GitHub with an SSH key, then commit and push.**

You will push to GitHub every week this semester, so set authentication up once, now, with a key.  GitHub no longer accepts your account password over HTTPS, and a key is the option that keeps working without a prompt on every push.  SSH (Secure Shell) is the protocol; the key is a file pair, one half private and one half public.  Follow 2a through 2f in order.  The alternatives after them are optional and replace specific sub-steps; choose at most one.

*2a. Check for a key you already have.*  A key you already trust is better than a second one, so look before you generate:

```bash
ls -al ~/.ssh
```

If `id_ed25519.pub` (or `id_rsa.pub`) is listed and you know its passphrase, skip to 2c.

*2b. Create one.*  Use the email address tied to your GitHub account:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

Press Enter to accept the default location, and set a passphrase rather than leaving it empty; the passphrase is what keeps the key useful to you and useless to someone who copies the file.  Then load it into the agent so you type that passphrase once per session rather than once per push:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

*2c. Register the public key with GitHub.*  Print the `.pub` file, which is the *public* half.  Never paste or send the file without the extension, which is the private key:

```bash
cat ~/.ssh/id_ed25519.pub
```

On GitHub, go to **Settings -> SSH and GPG keys -> New SSH key** (the direct link is [github.com/settings/keys](https://github.com/settings/keys)).  Title it after the machine it lives on, so you can revoke exactly one laptop later; leave the key type as **Authentication Key**; paste the whole line, and save.

*2d. Test it.*

```bash
ssh -T git@github.com
```

The first connection asks you to accept GitHub's host fingerprint; answer `yes`.  Success is a greeting that names your GitHub username.  It does not open a shell, and the message that GitHub does not provide shell access is the expected result, not an error.  **Paste this output.**

*2e. Get the repository onto your machine.*  Use your course GitHub Classroom repository, the `cs357-work` repository you created in the Development Environment activity, or a throwaway GitHub repository.  Which command starts you off depends on whether the repository already exists on GitHub: **clone** when it does, and `git init` only when it does not.

If it already exists on GitHub, clone it.  Cloning downloads the full repository, sets `origin` to the address you cloned from, and leaves you in a working copy that is already connected, so no `git remote add` follows.  Copy the address from the green **Code** button on the repository page, choosing the **SSH** tab so you get the `git@github.com:` form that the key you just registered authenticates:

```bash
cd ~/cs357
git clone git@github.com:<your-username>/<your-repo>.git
cd <your-repo>
git remote -v
```

`git clone` creates a *new folder* named after the repository, inside whatever directory you run it from, which is why you `cd` into it on the next line.  `git remote -v` should print your SSH address twice, once for fetch and once for push, which is your evidence that the working copy is wired to GitHub.  A repository with no commits yet clones with a warning that it is empty; that is fine, since the commit below is about to fill it.

If nothing exists on GitHub yet, create the repository there first (**+ > New repository**, with no README, which keeps the two histories from conflicting), then initialize locally and attach the remote by hand:

```bash
git init
git remote add origin git@github.com:<your-username>/<your-repo>.git
```

*2f. Commit and push.*  Git versions files, so the repository needs at least one file before there is anything to commit.  Create it the way you created `notes.txt` above:

```bash
printf '# CS357 scratch repository\n' > README.md
git add README.md
git commit -m "first commit"
git push -u origin main
```

*Expected.*  `git commit` prints a line beginning `[main` with your message, and `git push` ends with `main -> main`.  Then run `git log --oneline` and **paste its output**, which shows your commit.

*If it fails.*  `git commit` without `-m` drops you into an editor, and `:q!` leaves it if that editor turns out to be `vim`.  `git push` complains if your default branch is not named `main`, which `git branch -M main` fixes.  If the repository already has an HTTPS remote, switch it in place rather than starting over: `git remote set-url origin git@github.com:<your-username>/<your-repo>.git`, then verify with `git remote -v`.  On native Windows, PowerShell ships OpenSSH, so the commands above work as written; if `ssh-add` reports that the agent is not running, start it once from an elevated PowerShell with `Set-Service -Name ssh-agent -StartupType Manual` followed by `Start-Service ssh-agent`.

**Alternatives for Step 2.  Choose at most one, and verify with `ssh -T git@github.com` either way.**

- **The GitHub CLI, and the one I would take on native Windows.**  The [GitHub CLI](https://cli.github.com/), the `gh` command, does the whole exchange in 2b through 2c for you.  Install it (`winget install --id GitHub.cli` in PowerShell, `brew install gh` on macOS, or your package manager on Linux), then run `gh auth login`, choose **GitHub.com**, choose **SSH** as the protocol, and answer yes when it offers to generate a new SSH key and upload it to your account.  That one prompt replaces `ssh-keygen`, the `cat` of the `.pub` file, and the paste into Settings.  Verify with `ssh -T git@github.com` and paste that output; `gh repo clone <your-username>/<your-repo>` then clones over the protocol you just authorized, in place of the `git clone` in 2e.
- **VS Code, for the clone in 2e.**  It drives the same git underneath, so the result is identical.  With no folder open, the Source Control view (Ctrl+Shift+G, or Cmd+Shift+G on macOS) offers a **Clone Repository** button; from anywhere, the Command Palette (Ctrl+Shift+P, or Cmd+Shift+P) runs **Git: Clone**.  Either one asks for the repository address, where you paste the same SSH URL, then asks which local folder to put it in, `~/cs357` here, and offers to open the clone when it finishes.  Say yes: the integrated terminal (Ctrl+`) then opens already inside the repository, which is where you run `git log --oneline` for your transcript.  The palette also offers **Clone from GitHub**, which lets you pick from a list of your repositories instead of pasting a URL, though it signs you in to GitHub inside VS Code and authenticates as that account rather than with your key.
- **GitHub Desktop, for 2e and 2f.**  If you would rather not type git commands yet, [GitHub Desktop](https://desktop.github.com/) is a supported option and handles authentication for you: install it, sign in, use File > New repository (or Add local repository) on your `cs357` folder, commit from the Changes tab, and Publish repository to push.  Then paste the output of `git log --oneline` from Repository > Open in terminal, which is the same transcript the command-line route produces.  Set the key up anyway, because the labs and the coding agent drive git from a terminal.

**Telling the two GitHub downloads apart on native Windows without WSL2.**  `gh` is the command-line tool, a separate install rather than something GitHub Desktop brings along, though installing both is common and they coexist happily.  GitHub Desktop is the graphical client; it bundles Git for Windows, which is where `ssh-keygen` and Git Bash come from, and it handles its own authentication.  The Ubuntu or WSL2 route gives you the standard Unix tooling instead, and every command on this page then works as written.

**Route A and credentials inside the container.**  The key you just made lives on your host, which is where it belongs.  Inside the course container, Step 6 of the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md) recommends a fine-grained personal access token (PAT) scoped to `cs357-work` instead, because that container will soon be running agent code, and a credential placed inside it is a credential that code can use.  That is why the activity clones `cs357-work` over HTTPS: the token authenticates HTTPS pushes.  Step 6 also shows the read-only `~/.ssh` mount if you would rather use your key there, and says plainly what you are handing over when you do.

**Step 3. Reproducible Python with uv.**

*Do.*  Install [uv](https://docs.astral.sh/uv/), the fast, modern Python environment manager we standardize on this term.  Then, in your `~/cs357` directory, create a project, an environment, and the one dependency the labs start with:

```bash
cd ~/cs357
uv init
uv venv
uv add requests
uv run python -c "import requests; print(requests.__version__)"
```

`uv init` writes a `pyproject.toml`, which is what `uv add` records the dependency in; without it, `uv add` stops with a message about a missing project.

*Expected.*  `uv add` prints `Installed` lines that include `requests`, and the last command prints a version number such as `2.32.3`.

*Paste.*  The output of all four commands.

*If it fails.*  `uv: command not found` means the installer's directory is not on your PATH yet; restart the terminal.  If you cannot install uv, fall back to `python -m venv` and `pip install requests`, and note in your submission that you used the fallback.

### Command-Line Survival: reference (use as needed, not required reading cover-to-cover)

- [The Shell, in Full]({{ site.baseurl }}/Tutorials/Shell): the course's own shell tutorial, from the first prompt through pipes, PATH, and processes.
- [tldr pages](https://tldr.sh/): plain-language example-first cheat sheets for any command (`tldr tar`).
- [explainshell](https://explainshell.com/): paste any command line and see each flag explained.
- [ShellCheck](https://www.shellcheck.net/): catches bugs in shell scripts before they bite.
- `curl` and [HTTPie](https://httpie.io/) plus [jq](https://jqlang.github.io/jq/): you will hit JSON APIs (Ollama, MCP) all semester; `curl ... | jq` is your friend.

### Part 1.5 Checklist

- [ ] A shell transcript showing directory creation, navigation, and a `grep`/`rg` search
- [ ] A `git log --oneline` transcript showing at least one commit pushed to a remote (command line or GitHub Desktop)
- [ ] A `uv` (or documented fallback) transcript importing `requests`

---

## Part 2: Baseline Reflection

Write approximately one page addressing all four prompts below.  This is captured now so you can compare it to your thinking at the end of the semester.  There are no wrong answers.

**Reflection Template** (use these as section headings; write a paragraph under each):

### My AI Experience So Far

Describe which AI tools you use, for what purposes, and how often.  Then describe one specific moment when an AI output surprised you, either because it was better than you expected, or because it failed in an unexpected way.  Name the tool, describe the task, and describe the surprise.

### What "Agent" Means to Me Right Now

Write your own definition of what makes a system an "agent" rather than just a program or a tool.  You do not need to match any textbook definition; write what you actually think.  After the semester, we will return to this and see how your thinking changed.

### What I Would and Would Not Delegate

Name one task you would happily hand to an AI agent and one you would not.  For each, write one or two sentences explaining the specific reason: what is it about that task that makes delegation feel appropriate or inappropriate?  The difference between your two examples is more interesting than either example alone.

### What I Want to Build

Describe one thing you hope to be able to build or do by the end of the semester that you cannot do today.  Be as concrete as you can: what would it do, who would use it, and what would "working" look like?

---

## Troubleshooting

Work down this table before you post in the course channel.  The Stage column matches the setup map at the top of the page.  If none of it helps, post the exact command you ran and its full output.

| Stage | Symptom | Likely cause | Fix |
|---|---|---|---|
| 0 | On Windows, `'ollama' is not recognized`, or `curl` prints something odd | You are in Command Prompt or an old PowerShell window from before the install | Open a fresh PowerShell window so the updated `PATH` loads, and use PowerShell for every command on this page |
| 0 | `python3: command not found` on Windows | Windows Python installs as `python` | Use `python` wherever this page says `python3` |
| 0 | `Cannot connect to the Docker daemon` | Docker Desktop is installed but not running | Start the application. On Linux, `sudo systemctl start docker`, and confirm your user is in the `docker` group |
| 0 | Docker Desktop is running, but `docker` is not a command inside WSL2 Ubuntu | Docker's WSL integration is off for that distribution | In Docker Desktop, **Settings -> Resources -> WSL Integration**, switch the **Ubuntu** toggle on, **Apply & Restart**, then open a new Ubuntu terminal |
| 1 | `ollama: command not found` after installing | The installer put the binary somewhere not on your `PATH` | Restart your terminal. If it persists, find the binary (`ls /usr/local/bin/ollama`) and add its directory to `PATH`. This is the `PATH` idea from Step 0 of the Workbench session |
| 1 | `ollama: command not found`, and you installed Ollama with Docker | There is no host binary on this route; the program lives inside the container | Prefix the command: `docker exec ollama ollama list` (`docker ps` confirms the container name), and add `-it` for the interactive `ollama run` |
| 1 | The model download stalls or fails partway | Network interruption on a 2 GB transfer | Rerun `ollama pull llama3.2`; it resumes rather than restarting |
| 1 | Out of disk space partway through the build | The course image plus models is roughly 8 to 10 GB | Clear space and rerun `docker compose build`; completed layers are cached and the build resumes |
| 2 | Responses are very slow | A small model on CPU-only hardware | Expected. `llama3.2` is the right choice for that machine. Note the speed in your transcript; it is a real observation, not a failure |
| 3 | The `curl` to `/api/tags` says connection refused | The Ollama *server* is not running, which is separate from Ollama being installed | Start the desktop app, or run `ollama serve` in its own terminal and leave it open |
| 4 | Inside the container, `localhost:11434` refuses the connection | Correct behavior: `localhost` inside a container means the container | Use `http://host.docker.internal:11434`, but only for commands run inside a container; from your host, `localhost` stays correct. On Linux, start via the course compose file so that hostname resolves |
| 4 | `ModuleNotFoundError: No module named 'requests'` | The library is not installed in the Python you are running | `python -m pip install requests`, then rerun the script from the same terminal |
| 5 | `opencode` reports no provider or no models | Almost always the config **file name**: it must be `opencode.json`, not `config.json` | Fix the name, then check the location (`/workspace/opencode.json` in the container, `~/.config/opencode/opencode.json` natively), then check that the JSON parses with `python3 -m json.tool` |
| 5 | `opencode: command not found` inside the container | An older build of the course image, from before the agent was added | Rerun `docker compose build` from your `.devcontainer/` folder; cached layers make it quick |
| 5 | `opencode: command not found` on Route B, right after the installer succeeded | The installer put the binary in `~/.local/bin`, which is not on your `PATH` yet | `export PATH="$HOME/.local/bin:$PATH"` for this session, and add the same line to `~/.bashrc` to make it stick |
| 7 | `ssh-keygen` is not recognized on Windows | OpenSSH is not installed or the window predates it | Open a new PowerShell window; if it persists, install GitHub Desktop (which bundles Git for Windows) or the GitHub CLI and use the alternative in Step 2 |
| 7 | `git push` rejected, "authentication failed" | GitHub no longer accepts account passwords over HTTPS | Set up the SSH key in Part 1.5, Step 2, then point the remote at it: `git remote set-url origin git@github.com:<user>/<repo>.git`.  A fine-grained personal access token scoped to that one repository, with Contents: read and write, is the fallback if you must stay on HTTPS |
| 7 | `git@github.com: Permission denied (publickey)` | The key is not loaded in the agent, or its public half was never added to GitHub | `ssh-add -l` lists loaded keys and `ssh-add ~/.ssh/id_ed25519` loads yours; confirm the contents of `id_ed25519.pub` appear under Settings -> SSH and GPG keys; then retest with `ssh -T git@github.com` |
| 7 | GitHub Desktop says authentication failed, or cannot push | Not signed in, or the repository exists on GitHub but was never published from Desktop | File > Options > Accounts, sign in with the browser, then Publish repository; if the repository already exists online, use Add local repository and set the remote under Repository > Repository settings |
| 8 | `uv: command not found` | Not installed, or not on `PATH` yet | Follow the uv install docs, restart the terminal, and if it still fails use the documented `python -m venv` fallback and say so |
| 8 | `uv add` complains that no `pyproject.toml` was found | You skipped `uv init` | Run `uv init` in the same directory, then rerun `uv add requests` |

---

## Self-Check Before You Submit

Hold your submission against the rubric's `proficient` column:

- [ ] One file, PDF or Markdown, with each component **clearly labeled**.
- [ ] Setup transcript covers all five steps, including the coding-agent check, and states your **OS and version numbers**.
- [ ] Transcript output is **copied verbatim**, not retyped or paraphrased.
- [ ] Any failure is quoted exactly, with a hypothesis and what you tried.
- [ ] Part 1.5: shell navigation and a search, a `git log --oneline` showing a pushed commit, and the uv (or documented fallback) output.
- [ ] Reflection has **four** labeled sections and is about a page.
- [ ] The reflection says what you actually think, not what you expect the course to want.
- [ ] Which route you took (A or B) is stated.
- [ ] Collaboration, AI-disclosure, and hours questions answered at the end.

---

## Deliverables

Submit a single PDF or markdown file containing:
- Your tool setup transcript (all five steps, including `opencode --version` and one answered prompt, plus version and OS info)
- Your command-line and git checkpoint transcript (Part 1.5: navigation, git commit/push, uv environment)
- Your baseline reflection (one page, four sections)

---

## Frequently Asked Questions

**Q: I don't have a machine that can run Ollama.  What should I do?**
A: Use a lab machine or contact the instructor before the due date.  Do not wait until the night before; lab access may require scheduling.  Document which machine you used in your transcript.

**Q: My Python API call returns an error or the model responds very slowly.  Is that okay?**
A: Slow is okay for a small model on older hardware.  An error is okay as long as you document it fully: copy the full error message, describe what you tried, and state whether it was eventually resolved.  A partial success with complete documentation earns full credit for that step.

**Q: The reflection prompts ask about "agency" and "trust"; do I need to use the textbook definitions?**
A: No.  This is a baseline, and not a knowledge test.  Write what you actually think before the course shapes your view.  The textbook will be there later; this snapshot of your prior thinking is valuable precisely because it is unfiltered.

---

Please also answer the following questions in your submission:

- If collaboration with a buddy was permitted, did you work with a buddy on this assignment?  If so, who?  If not, do you certify that this submission represents your own original work?  Please identify any and all portions of your submission that were not originally written by you.
- Approximately how many hours it took you to finish this assignment (I will not judge you for this at all...I am simply using it to gauge if the assignments are too easy or hard)?
