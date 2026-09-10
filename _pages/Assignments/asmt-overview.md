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
    - rtitle: "Setup (Route A): the Your AI Workbench activity, which we build together in class - Host Ollama, the Course Container, Git, GitHub, and your first coding agent; its Step 0 is the shell in ten minutes and the read-before-you-run habit every later lab assumes"
      rlink: "Activities/liascript-devenvironment.md"
      liapage: true
    - rtitle: "The Shell, in Full: pipes, redirection, background jobs, and PATH, if the shell is new to you"
      rlink: "../Tutorials/Shell"

tags:
  - intro
  - ai
  - agents

---

In this warmup you'll install your local AI stack and your coding agent, and write a short baseline reflection on your experiences with AI.  I have kept the stakes low here on purpose.  It exists to make sure your tools work before the labs depend on them, and to capture a snapshot of your thinking that you'll come back to at the end of the semester.  (Your team charter is **not** part of this assignment; it is handed out separately once teams are announced; see the [Project Thread]({{ site.baseurl }}/Projects/PBLThread#the-team-charter-a-signed-team-contract).)  There are no wrong answers in the reflection.  This is a starting point, and I am not evaluating what you know.  See the course schedule for this onboarding assignment's due date; it is assessed within the Class Activities and Participation category.

---

## Before You Start

This is the first thing you install for this course.  I have put it early on purpose, so that a broken setup costs you this assignment rather than a lab.

> **Pace yourself: most of this is downloading.**  The model pull alone is about 2 GB, and the container image is larger.  Start the downloads on good wifi and write the reflection while they run.  Do not leave this for the night before; the downloads will not go any faster because you are in a hurry, and I can't help you at 11 PM.

| You need | Why |
|---|---|
| A laptop you can install software on | Ollama, and on Route A Docker Desktop, are installed on your own machine |
| A GitHub account | Part 1.5 pushes a repository there, and Route A keeps your `cs357-work` repository there all semester |
| About 10 GB of free disk | The model is about 2 GB and the course container image is larger |

If any of those is a problem, say so this week rather than in week four.  There is a lab-machine route, and it takes some scheduling.

> **Taking Route A?**  Everything you need is on this page.  The *Optional Route A Setup* section in Part 1 installs Docker and builds the course container, with direct links to the container files, and every later step says what Route A lets you skip.  The *Your AI Workbench* class session walks the same steps with you.

> **How to use this page.**  First, pick your route in *Which route should I take?* at the top of Part 1.  Then follow your route's path below, top to bottom.  Every step opens with an *at a glance* box that says where you type, what each route does there, and what you paste, and every step ends with a **Next** line that tells you where to go.  If you only read the boxes and the Next lines, you will still land in the right place.

| Route A path (recommended) | Route B path |
|---|---|
| *Optional Route A Setup*, A1 through A6 | Skip the optional section |
| Steps 1 and 2, on your host | Steps 1 and 2 |
| Step 3 on your host, plus its Route A bridge check from inside the container | Step 3 |
| Step 4 inside the container; nothing to install | Step 4, after installing `requests` |
| Step 5 from 5b; opencode is already installed | Step 5, after installing opencode |
| Part 1.5, Steps 1 through 3; Step 2 pushes from the container with your A6 credential | Part 1.5, Steps 1 through 3 |
| Part 2, the reflection | Part 2, the reflection |

### The setup map

This assignment is nine stages plus one optional one.  Each stage ends with one command whose output you paste into your submission, so you can always tell whether a stage is done.  Work down the table in order, and use the last column to find the steps.

| Stage | What you do | The command that proves it | What you paste | Where the steps are |
|---|---|---|---|---|
| 0 | Open a terminal, learn to move around and save a file, tell your host prompt from a container prompt, and note your operating system | `pwd` | Your operating system name and version, and your route (A or B) | Part 1, *Opening a terminal* and *Where am I typing?* |
| A | Optional, Route A only: install Docker, create `cs357-work`, add the container files, build, enter, and verify | `docker compose run --rm cs357`, then the checks in A5 | The container prompt and the A5 output | Part 1, *Optional Route A Setup* |
| 1 | Install Ollama and pull a model | `ollama list` | The output of `ollama --version` and `ollama list` | Part 1, Step 1 |
| 2 | Chat with the model once | `ollama run llama3.2 "..."` | The model's reply | Part 1, Step 2 |
| 3 | Confirm the REST API answers | `curl http://localhost:11434/api/tags` | The JSON | Part 1, Step 3 |
| 4 | Call the model from Python | `python3 ollama_check.py` | The printed JSON, including a `"content"` field | Part 1, Step 4 |
| 5 | Confirm the coding agent talks to that model | `opencode --version` | The version string and one answered prompt | Part 1, Step 5 |
| 6 | Navigate a shell and search a file | `grep -n "localhost" notes.txt` | The commands and their output | Part 1.5, Step 1 |
| 7 | Authenticate to GitHub, then commit and push | `git log --oneline` | The `ssh -T` greeting and the log | Part 1.5, Step 2 |
| 8 | Create a reproducible Python environment | `uv run python -c "import requests; print(requests.__version__)"` | The printed version | Part 1.5, Step 3 |
| 9 | Write the baseline reflection | none | Four labeled sections | Part 2 |

> **Do the stages in this order.**  Start Stage 1 first, because the download runs in the background.  On Route A, start the Stage A image build at the same time; both are downloads.  While they download, write the reflection (Stage 9); it needs no tools.  Then finish Stages 2 through 5, and do Stages 6 through 8 last, since they use what you just installed.

> **If a stage fails, document it and move on.**  A documented failure earns full credit for that stage: quote the error verbatim, state your hypothesis about the cause, and say what you tried.  "It worked eventually" earns nothing.  Work down the Troubleshooting table at the end of this page before you post in the course channel.

> **You've succeeded when** the four boxes in the Part 1A checklist and the three in the Part 1B checklist are checked, all three in the Part 1.5 checklist are checked, and your reflection has four labeled sections.  On Route A, the Route A checklist is checked as well.

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

Part 1A must work before Part 1B can: the coding agent in Part 1B is pointed at the model you pull in Part 1A, so do them in order.  Before either half comes a decision (which route) and, on Route A, an optional setup section that builds the course container.

### Which route should I take?

A route decides *where* Steps 1 through 5 run.  The commands are the same on both routes, and neither route is the "real" one.

| | Route A (recommended): host Ollama plus the course container | Route B: native install |
|---|---|---|
| Who it is for | Anyone whose laptop can run Docker Desktop | Anyone whose laptop cannot run Docker, or anyone using a lab machine |
| Where Ollama runs | On your host, natively | On your host, natively |
| Where Steps 1-3 run | Your host terminal | Your host terminal |
| Where Steps 4-5 run | Inside the course container | Your host terminal |
| What you install | Ollama, Docker Desktop, and the course container, by following *Optional Route A Setup* below (the same steps the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md) walks through in class) | [Ollama](https://ollama.com/download), the Python `requests` library, and opencode from [opencode.ai](https://opencode.ai/) |

> **Deciding your route.**  You do not have to decide yet, but decide early:
>
> 1.  Steps 1 through 3 are identical on both routes, so start Step 1's download now.
> 2.  If Docker Desktop installs and `docker run hello-world` succeeds (that is A1, the first thing the optional section asks), take **Route A**: do the *Optional Route A Setup* section, start its image build while the Step 1 model pull runs, and then Steps 3, 4, and 5 and Part 1.5 Step 2 each say what Route A lets you skip.
> 3.  If Docker will not run on your machine, take **Route B**, skip the optional section, and say so in your transcript.
>
> I recommend Route A because every later lab assumes it and it is what we build together in the *Your AI Workbench* session.  Route B is complete and supported too.  On Route A, the A5 checks and the Step 3 bridge check belong in your transcript as well.

### Before Step 1: Orientation (read once, come back as needed)

Two short references before the steps begin.  Every *at a glance* box below says "your host terminal" or "the container prompt"; these two sections are where those words are defined, and every step that says "open a terminal," "`cd`," or "save it" means the first of them.

#### Opening a terminal, moving around, and saving a file

Every step on this page happens at a terminal, and several ask you to save a file.  Here is how, on every system this course supports.  Come back to this section whenever a step says "open a terminal," "`cd`," or "save it."

**1. Open a terminal.**

| System | How to open it | What the prompt looks like |
|---|---|---|
| macOS | Press Cmd+Space, type `Terminal`, press Enter | `you@laptop ~ %` |
| Windows, PowerShell | Open the Start menu, type `PowerShell`, press Enter (not "Command Prompt") | `PS C:\Users\you>` |
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
> Do all of this course's work in `~/cs357`, or in the `cs357-work` clone from A2 on Route A, so that every `cd ~/cs357` on this page lands in the same place.  Press **Tab** to complete a name you have started typing, and the up arrow to recall the previous command.

**3. Save a file.**  When a step says "save this as `ollama_check.py`," first `cd` into the folder the file belongs in, then use one of these:

| Editor | Where it works | How to save `ollama_check.py` |
|---|---|---|
| **nano** | macOS, Linux, WSL2, and inside the course container | Run `nano ollama_check.py`, paste the contents (Cmd+V on macOS; right-click or Ctrl+Shift+V in Ubuntu), press **Ctrl+O** then **Enter** to write the file, then **Ctrl+X** to exit |
| **vim** | Every Unix system | Run `vim ollama_check.py`, press **i** to enter insert mode, paste, press **Esc**, then type `:wq` and press **Enter** to write and quit.  If you get stuck, press **Esc**, type `:q!`, and press **Enter** to leave without saving |
| **VS Code** | Any system | From the folder, run `code .` to open it (or **File > Open Folder**), then **File > New File**, paste, and press **Ctrl+S** (Cmd+S on macOS) to save under the name the step gives.  Type the name with its extension, `ollama_check.py`, and check that the editor did not add `.txt` |
| **Notepad** | PowerShell without nano | Run `notepad ollama_check.py`, click **Yes** to create the file, paste, save, and close Notepad |

For a one-line file in PowerShell, `Set-Content notes.txt "model: llama3.2"` writes it directly.

**4. Confirm it landed.**  Run `ls` and see the file's name; run `cat ollama_check.py` and see its contents.  If `ls` does not show it, you saved into a different folder than the one you are in, and `pwd` tells you which one that is.

#### Where am I typing?

Most setup failures on this page come from running a command in the wrong place.  Before every command, read your prompt.

| Your prompt looks like | You are on | What `localhost` means there |
|---|---|---|
| `you@laptop ~ %`, `you@laptop:~$`, or `PS C:\Users\you>` | Your **host**: macOS, Linux, WSL2 Ubuntu, or PowerShell | Your laptop, where Ollama listens |
| `student@a1b2c3d4e5f6:/workspace$` | Inside the **course container** | The container itself, where nothing listens |

> **The address rule.**  Every command on this page that names Ollama's address is written as `localhost:11434`.  On your host, leave it as written.  Inside the container, replace `localhost` with `host.docker.internal`, because `localhost` inside a container means the container.  That is the only substitution on this page, and it applies only inside the container.  Running Ollama itself as a Docker container does not change the rule: with its port published (`-p 11434:11434`), `localhost:11434` on your host still reaches it.

> **Windows.**  Use PowerShell (Windows 10 and 11 include it; open it from the Start menu) or WSL2 Ubuntu, not the old Command Prompt.  Every command on this page and in the labs is written for PowerShell or a Unix shell.  In PowerShell, `python3` is spelled `python`.  When a transcript from inside the container is what you have, include the container prompt in your copy-paste so it is visible where each command ran.

---

### Optional Route A Setup: Docker and the Course Container

**This section is optional.  It is Route A.**  If you are on Route B, skip to Step 1.  If you are on Route A, do A1 through A6 once, on your host, and every lab this semester runs in what you build here: one Docker container with the whole course toolchain preinstalled, bind-mounted onto a directory that is a **git repository with a GitHub remote**, so everything you write inside the container is versioned and pushed like normal work.

| Runs inside the container | Stays on your host |
|---|---|
| Python 3.11 with the course libraries: retrieval, classical ML, NLP, and explainability | **Ollama**, the model server, installed natively for speed |
| Node.js with **promptfoo**, the evaluation lab's harness | Your SSH key for GitHub (Part 1.5) |
| **opencode**, the coding agent, and **herdr**, the agent multiplexer | Docker Desktop itself, and your `cs357-work` clone on disk |
| `git`, `curl`, and `zip`, so you commit, probe, and package from inside | Your browser, your other courses, and everything else |

Your containerized code reaches Ollama at `http://host.docker.internal:11434`.  Two ideas carry the whole design:

| Design idea | What it means for you |
|---|---|
| **The image is the environment** | One course Dockerfile, built once, gives everyone a byte-for-byte identical lab environment.  "Works on my machine" stops being a sentence anyone says |
| **The mount is the only door** | The container can see exactly one directory of your machine, the workspace you mount into it.  For a course where you run agent code that takes actions, that boundary is the blast-radius principle, enforced by architecture |

The [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md) is the in-class version of these same six steps, and [Docker from Zero]({{ site.baseurl }}/Tutorials/Docker) explains the concepts from first principles whenever a step below feels like magic.

> **Budget about an hour, most of it downloads.**  Start the A4 image build as soon as you reach it and do Step 1 while it runs.

#### A1. Install Docker Desktop

| A1 at a glance | |
|---|---|
| **Where you type** | Your host terminal (PowerShell as Administrator for the Windows step) |
| **Route A** | Do it |
| **Route B** | Skip this whole section and go to Step 1 |
| **You paste** | The `Hello from Docker!` line |

If Docker is already on your machine from another course or project, skip to the verification at the end of A1.  If Docker cannot be installed on your machine at all (unsupported hardware, an administrator lock, or too little disk), take Route B now; nothing is wasted.

> **Disk note.**  Docker Desktop plus the course image (the ML libraries are hefty) needs roughly **8-10 GB** free, on top of Ollama's models.  Clear space now, not mid-download.

> **Windows only: install Ubuntu on WSL2 first.**  Docker Desktop on Windows does not run containers on Windows itself; it runs them inside **WSL2**, the Windows Subsystem for Linux.  Installing the Linux side first prevents most of the Windows trouble on this page.  Open **PowerShell as Administrator** and run:
>
> ```powershell
> wsl --install -d Ubuntu
> ```
>
> Reboot if it asks.  Then launch **Ubuntu** from the Start menu and set the UNIX username and password it prompts for; these are new, and separate from your Windows account.  If `wsl --install` is not recognized, your Windows is too old for the one-liner: update Windows, or follow Microsoft's [manual WSL2 install steps](https://learn.microsoft.com/en-us/windows/wsl/install-manual).  Do the rest of this page from the **Ubuntu** terminal: `~` means what it says, paths are ordinary Linux paths, and a repository kept in your WSL2 home directory bind-mounts far faster than one on the Windows side.

**Do.**  Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) (macOS/Windows) or [Docker Engine](https://docs.docker.com/engine/install/) (Linux), and start it.

**Windows only, after Docker Desktop is installed: check two settings.**  Open Docker Desktop's **Settings** (the gear icon) and verify both rows of this table:

| Docker Desktop setting | Where to find it | Must be |
|---|---|---|
| Use the WSL 2 based engine | **Settings -> General** | Checked |
| WSL Integration for Ubuntu | **Settings -> Resources -> WSL Integration** | The **Ubuntu** toggle switched **on**, then **Apply & Restart** |

> **Watch out!**  The second setting is the one students most often miss, and its symptom is confusing: Docker Desktop looks perfectly healthy in its own window, but `docker` is not a command inside Ubuntu.

**Verify.**  From a terminal (the Ubuntu terminal on Windows):

```bash
docker run hello-world
```

> **What you should see:**
> ```
> Hello from Docker!
> This message shows that your installation appears to be working correctly.
> ```
>
> A working Docker is your evidence that Route A is available to you.

**Paste.**  The `Hello from Docker!` line.

> **Troubleshooting:** `Cannot connect to the Docker daemon` means Docker Desktop is installed but not running; start the application and wait for the whale icon to settle.  `docker: command not found` inside Ubuntu, while Docker Desktop is plainly running, is the WSL Integration setting in the table above.  See the Stage A rows in Troubleshooting.

**Next:** A2.

---

#### A2. Create and clone your `cs357-work` repository

| A2 at a glance | |
|---|---|
| **Where you type** | Your host terminal |
| **Route A** | Do it |
| **Route B** | Skip |
| **You paste** | The two lines of `git remote -v` |

Your lab work lives in a private GitHub repository named `cs357-work`, the directory you will mount into the container and push to all semester.

**Do.**

1.  On [github.com](https://github.com/): **New repository** -> name `cs357-work` -> **Private** -> check **Add a README file**.
2.  Clone it, from the Ubuntu terminal on Windows or the Terminal on macOS and Linux:

```bash
cd ~
git clone https://github.com/YOURUSERNAME/cs357-work.git
cd cs357-work
git remote -v
```

> **Watch out!**  Keep the clone under your home folder.  Docker Desktop shares that location with containers by default, and a clone on a second drive or a network share is the most common cause of an empty bind mount later.

> **What you should see:**
> ```
> origin  https://github.com/YOURUSERNAME/cs357-work.git (fetch)
> origin  https://github.com/YOURUSERNAME/cs357-work.git (push)
> ```
>
> The clone is a git repository that already knows its GitHub remote, the versioned half of the environment.  The address is HTTPS on purpose: inside the container you will authenticate with a repository-scoped token (A6), and that token works over HTTPS.  The SSH key you make in Part 1.5 stays on your host, where it belongs.

**Paste.**  The two `git remote -v` lines.

> **Troubleshooting:** `git: command not found` means git is not installed on your host yet; on macOS, running `git` once offers to install the developer tools, on Ubuntu `sudo apt install git`, and on Windows the Ubuntu terminal already has it.  A prompt for a username and password means the repository is private and your host has no GitHub credential yet; Part 1.5 Step 2 sets one up, so for now make the repository, come back to this clone after Step 2, or use the GitHub Desktop alternative there.

**Next:** A3.

---

#### A3. Add the course container files

| A3 at a glance | |
|---|---|
| **Where you type** | Your host terminal, inside the `cs357-work` clone |
| **Route A** | Do it |
| **Route B** | Skip |
| **You paste** | The `ls -la .devcontainer` listing and the `git commit` line |

The course container is defined by three small files, which you keep in a `.devcontainer/` folder inside your clone.  Read them; each one is commented line by line.

| File | What it does |
|---|---|
| [Dockerfile]({{ site.baseurl }}/files/devcontainer/Dockerfile) | The recipe for the course image; every package is commented with the lab that uses it |
| [docker-compose.yml]({{ site.baseurl }}/files/devcontainer/docker-compose.yml) | One-command build/run, the workspace bind mount, and the Linux `host.docker.internal` fix |
| [devcontainer.json]({{ site.baseurl }}/files/devcontainer/devcontainer.json) | VS Code Dev Containers configuration |
| [README.md]({{ site.baseurl }}/files/devcontainer/README.md) (optional) | The quickstart version of this section |

**Do.**  The commands below fetch all three into the right place.  Run them from your clone:

```bash
cd ~/cs357-work
mkdir -p .devcontainer
cd .devcontainer
curl -fsSL -o Dockerfile https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/files/devcontainer/Dockerfile
curl -fsSL -o docker-compose.yml https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/files/devcontainer/docker-compose.yml
curl -fsSL -o devcontainer.json https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/files/devcontainer/devcontainer.json
cd ..
ls -la .devcontainer
```

> **What you should see:** the three files, under exactly those names, so that your repository looks like this:
> ```
> cs357-work/
>   .devcontainer/
>     Dockerfile
>     docker-compose.yml
>     devcontainer.json
>   README.md
> ```

> **Watch out!**  If you saved the files from a browser instead, check the names, because browsers sometimes save `Dockerfile` as `Dockerfile.txt`, and Docker will not find it under that name.

Open the Dockerfile and *read it*; it is exactly the anatomy from Docker from Zero Section 5 (`FROM`, `RUN`, `ENV`, `WORKDIR`, `CMD`), and every `pip` line names its lab.  Then commit the files; they are part of your work:

```bash
git add .devcontainer
git commit -m "Add course dev container configuration"
```

**Paste.**  The `ls -la .devcontainer` listing and the `[main ...] Add course dev container configuration` line.

> **Troubleshooting:** `curl: command not found` on native Windows means you are in Command Prompt; use PowerShell or the Ubuntu terminal.  If `git commit` asks who you are, run `git config user.name "Your Name"` and `git config user.email "you@example.com"` in this folder and commit again; A6 says why per-repository is the right scope.

**Next:** A4.

---

#### A4. Build and enter the container

| A4 at a glance | |
|---|---|
| **Where you type** | Your host terminal to build; the **container prompt** once you are in |
| **Route A** | Do it |
| **Route B** | Skip |
| **You paste** | The container prompt, `student@...:/workspace$` |

Build and enter by either front door.  Both use the same Dockerfile, and you can switch anytime.

| Front door | Pick it if | How you enter |
|---|---|---|
| **Option A: VS Code Dev Containers** | You already use VS Code | Install the **Dev Containers** extension, open the `cs357-work` folder, and run **Dev Containers: Reopen in Container** from the command palette.  Terminals you open in VS Code are now inside the container |
| **Option B: plain Docker Compose** | You use any other editor, or want to see every step | Run the three commands below from the `.devcontainer/` folder |

**Do, for Option B:**

```bash
cd ~/cs357-work/.devcontainer
docker compose build
docker compose run --rm cs357
```

> **Budget note.**  The first build downloads the ML libraries and takes a while; start it and go do Step 1 in another terminal.  Rebuilds are nearly instant thanks to layer caching.

> **What you should see:** when the build finishes, a prompt like
> ```
> student@a1b2c3d4e5f6:/workspace$
> ```
>
> You are the non-root user `student`, in `/workspace`, which *is* your `cs357-work` clone (`ls -la` shows `.git`, `.devcontainer`, and `README.md`).  Exit anytime with `exit` or Ctrl-D; `--rm` deletes the container but never your files, which live in the mounted repo on your disk.

**Paste.**  The container prompt.  Include it in every container transcript on this page, so it is visible where each command ran.

> **Troubleshooting:** a build that cannot find the Dockerfile is the `Dockerfile.txt` problem from A3, or you ran `docker compose` from somewhere other than `.devcontainer/`.  An empty `/workspace` on Windows means the clone lives somewhere Docker Desktop does not share; see the Stage A rows in Troubleshooting.  A build that dies with a network error resumes from the failed step when you rerun `docker compose build`.

**Next:** A5.

---

#### A5. Verify the tools inside the container

| A5 at a glance | |
|---|---|
| **Where you type** | The container prompt |
| **Route A** | Do it |
| **Route B** | Skip |
| **You paste** | The output of the three checks (and `herdr --version` if you include it) |

Three commands, each proving one tool is in the image.  The fourth thing the container must do, reach Ollama on your host, is Step 3's Route A subsection, because it needs the Ollama you install in Step 1.

| Check | Command | What you should see | What it proves |
|---|---|---|---|
| 1 | `promptfoo --version` | `0.x.x` | Node.js and promptfoo are wired correctly (the evaluation lab's harness) |
| 2 | `python3 -c "import spacy; nlp = spacy.load('en_core_web_sm'); print('spacy OK:', nlp('Agents plan and act.')[0].pos_)"` | `spacy OK: NOUN` | The NLP model the explainability directions use is loaded |
| 3 | `opencode --version` | `opencode x.x.x` | The coding agent is baked into the image, so Step 5 has nothing left to install |
| optional | `herdr --version` | a version string | **herdr**, an agent-aware terminal multiplexer a later lab uses, is in the image too; this one is not graded |

**Do.**  At the container prompt, the three graded checks, ready to paste:

```bash
promptfoo --version
python3 -c "import spacy; nlp = spacy.load('en_core_web_sm'); print('spacy OK:', nlp('Agents plan and act.')[0].pos_)"
opencode --version
```

**Paste.**  All three outputs, with the container prompt visible.

> **Troubleshooting:** `command not found` for any of the three means an older build of the course image; rerun `docker compose build` from your `.devcontainer/` folder, and cached layers make it quick.  `permission denied` writing files in `/workspace` on a Linux host means the container's `student` user does not match your host UID; run the container with `docker compose run --rm --user "$(id -u):$(id -g)" cs357`.

**Next:** A6.

---

#### A6. Git identity and a push credential inside the container

| A6 at a glance | |
|---|---|
| **Where you type** | The container prompt, in `/workspace` |
| **Route A** | Do it |
| **Route B** | Skip |
| **You paste** | Nothing yet; the push in Part 1.5 Step 2 is the evidence |

The container ships with `git` but knows nothing about you, and it cannot push without a credential.

> **Why this matters.**  This is the one place in the course where your own machine and the container are set up **differently on purpose**: on your host you will use an SSH key (Part 1.5 Step 2); inside the container the default is a token scoped to one repository, because from Step 5 onward this container runs *agent code* that acts on your files, and a credential you place inside it is a credential that code can use.

**Do, identity.**  Set your identity **per repository**, so it is stored in `/workspace/.git/config`, on your disk, inside the mount, and survives container teardown:

```bash
cd /workspace
git config user.name "Your Name"
git config user.email "you@example.com"
```

> **Note.**  The VS Code route copies your host `~/.gitconfig` into the container automatically, so Option A students often find this already done.

**Do, credential.**  Create a fine-grained personal access token (PAT):

1.  GitHub -> **Settings -> Developer settings -> Personal access tokens -> Fine-grained tokens -> Generate new token**.
2.  Scope it tightly: *Only select repositories* -> `cs357-work`; Repository permissions -> **Contents: Read and write**; expiration at or beyond the end of the semester.
3.  Copy the token (shown once).  When `git push` prompts for a password, paste the token.
4.  Cache it for a work session so you are not retyping:

```bash
git config credential.helper 'cache --timeout=7200'
```

The two credentials you could use inside the container, side by side:

| | Scoped token (recommended) | Mounted SSH key |
|---|---|---|
| **Blast radius** | One repository, `cs357-work`, and nothing else | Every repository your key can reach |
| **How it authenticates** | Pasted at the HTTPS password prompt, cached for the session | Your host's `~/.ssh` mounted read-only, with the `git@github.com:...` remote form |
| **When to choose it** | By default, and whenever you are not sure | Only if you already use SSH keys with GitHub and accept the trade-off below |

> **Alternative, only if you already use SSH keys with GitHub.**  Add one line to the `volumes:` list in `docker-compose.yml`:
>
> ```yaml
>     volumes:
>       - "..:/workspace"
>       - "~/.ssh:/home/student/.ssh:ro"
> ```
>
> `:ro` makes the mount read-only (the container can use the keys, not modify them), and you would use the `git@github.com:...` remote form.  Mounting `~/.ssh` deliberately widens the container's view of your machine: you are handing everything that runs inside (including, later, *agent code*) a credential that can push to **every** repository your key reaches.  Step 6 of the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md) says more about why the two environments differ.

> **What you should see:** `git config user.name` prints your name.  The credential proves itself at the first push, in Part 1.5 Step 2.

> **Troubleshooting:** `fatal: detected dubious ownership in repository at '/workspace'` is git noticing that the repository's owner (your host account) is not the user running the command (`student`).  Run `git config --global --add safe.directory /workspace` inside the container and rerun the command that failed.  The container's `~/.gitconfig` is recreated on every `docker compose run --rm`, so expect to run this once per session; the VS Code route keeps one long-lived container, so once is usually enough.

**Next:** the Route A checklist, then Step 1.

> **You've succeeded when** every box below is checked.  Then go to Step 1; on Route A, Steps 1 through 3 run on your host, not in the container.

#### Route A Checklist

- [ ] `docker run hello-world` printed `Hello from Docker!`
- [ ] `git remote -v` shows your `cs357-work` repository
- [ ] `Dockerfile`, `docker-compose.yml`, and `devcontainer.json` are in `.devcontainer/` and committed
- [ ] The `student@...:/workspace$` prompt appears
- [ ] `promptfoo --version`, the spacy check, and `opencode --version` all print output

---

### Step 1. Install Ollama, pull a small model, and confirm both

| Step 1 at a glance | |
|---|---|
| **Where you type** | Your host terminal (on Route A too: Ollama stays on the host) |
| **Route A** | Do it |
| **Route B** | Do it |
| **You paste** | The `ollama --version` line and the `ollama list` table |

**Do.**  Install [Ollama](https://ollama.com/download) for your operating system.  Then open a new terminal and run:

```bash
ollama --version
ollama pull llama3.2
ollama list
```

> **What you should see:** a version string, a download that ends in `success`, and a table from `ollama list` with a `llama3.2:latest` row.  The pull is about 2 GB and is the longest wait on this page.  On Route A, the A4 image build can run at the same time.

**Paste.**  The `ollama --version` line and the `ollama list` table.

> **Troubleshooting:** `command not found` or `not recognized` means your terminal predates the install; open a new one.  See the Stage 1 rows in Troubleshooting.

**Next:** Step 2.

---

### Step 2. Run a CLI sanity check

| Step 2 at a glance | |
|---|---|
| **Where you type** | Your host terminal |
| **Route A** | Do it |
| **Route B** | Do it |
| **You paste** | The command and the model's reply |

**Do.**

```bash
ollama run llama3.2 "Say hello in five words."
```

> **What you should see:** one short line of text from the model.  The exact words vary.  On CPU-only hardware the first reply can take a minute, which is normal.

**Paste.**  The command and the reply.

> **Troubleshooting:** a connection error means the Ollama server is not running, which is separate from Ollama being installed.  See the Stage 3 rows in Troubleshooting.

**Next:** Step 3.

---

### Step 3. Verify the REST API responds

| Step 3 at a glance | |
|---|---|
| **Where you type** | Your host terminal; on Route A, then the container prompt for the bridge check |
| **Route A** | Do it on the host, then also run the bridge check below from inside the container |
| **Route B** | Do it |
| **You paste** | The JSON (and, on Route A, the bridge check's output) |

**Do.**

```bash
curl http://localhost:11434/api/tags
```

> **What you should see:** a JSON object that begins
> ```
> {"models":[{"name":"llama3.2:latest", ...
> ```

**Paste.**  The JSON.  Trim it to the first few lines if it is long.

> **Troubleshooting:** `Connection refused` means the server is not running.  Start the Ollama desktop app, or run `ollama serve` in a second terminal and leave that terminal open.

#### Route A: also check the bridge from inside the container

**Do.**  Keep Ollama running on the host, enter the container (A4), and send one line of Python straight through the container wall to the model server on your host:

```bash
python3 -c "import requests; print(requests.get('http://host.docker.internal:11434/api/tags').json())"
```

> **What you should see:** yours will show your models and digests:
> ```
> {'models': [{'name': 'llama3.2:latest', 'model': 'llama3.2:latest', 'modified_at': '...', 'size': 2019393189, 'digest': '...', 'details': {...}}]}
> ```
>
> If you see a `models` list containing `llama3.2`, the whole architecture works: containerized Python -> `host.docker.internal` -> native Ollama.

> **Why this matters.**  Try `curl http://localhost:11434/api/tags` from the same container prompt and watch it fail; `localhost` inside the container is *the container*, not your machine, and that failure is correct behavior.  The image also sets `OLLAMA_HOST=http://host.docker.internal:11434`, so tools that read that variable find the host server automatically; in your own code, use the `host.docker.internal` URL whenever a lab handout says `localhost:11434`.

**Paste.**  The one-liner's output, with the container prompt visible.

> **Troubleshooting:** a connection error here has two usual suspects: Ollama is not actually running on the host right now, or, on Linux, the container was started without the course compose file, whose `extra_hosts` mapping (`host.docker.internal:host-gateway`) makes the hostname resolve at all.  See the Stage 4 rows in Troubleshooting.

**Next:** Step 4.

---

### Step 4. Call the model from Python

| Step 4 at a glance | |
|---|---|
| **Where you type** | The container prompt on Route A; your host terminal on Route B |
| **Route A** | Skip the install; run the script inside the container with `host.docker.internal` |
| **Route B** | Install `requests`, then run the script |
| **You paste** | The printed JSON, including a `"content"` field |

This is the first step where the route matters.  Read your column, then do the part both routes share.

| | Route A | Route B |
|---|---|---|
| **Before you start** | Finish A1 through A5 if you have not, then enter the container (A4) | Nothing |
| **Install** | Nothing; the container already has the `requests` library | `python3 -m pip install requests` (in PowerShell: `python -m pip install requests`) |
| **Where to save `ollama_check.py`** | `/workspace`, which is your `cs357-work` clone | `~/cs357` |
| **Address in the script** | Replace `localhost` with `host.docker.internal` | Leave `localhost` as written |

#### Both routes: save and run the script

**Do.**  Save the script below as `ollama_check.py` in the folder from your column.  Python runs files, so put the lines in a file rather than typing them at a prompt.  *Opening a terminal, moving around, and saving a file* above walks through nano, vim, VS Code, and Notepad; any of them does the job.

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

> **Note.**  On Windows in PowerShell the command is `python ollama_check.py`.  VS Code's Run button (the triangle in the top right, with the Python extension installed) runs the same command in its integrated terminal, and either transcript is fine for your submission.

> **What you should see:** a JSON object with a `"message"` block whose `"content"` field holds the model's answer.

**Paste.**  The printed JSON.

> **Troubleshooting:** `ModuleNotFoundError: No module named 'requests'` means the install landed in a different Python than the one you ran; use `python3 -m pip install requests` (or `python -m pip` on Windows) from the same terminal, then rerun.  A `ConnectionError` inside the container means the address rule was not applied.  `can't open file ... No such file or directory` means you are in a different directory than the one you saved into; `ls` (or `dir`) shows which.

> **You've succeeded when** the four boxes below are checked.  That is Part 1A.

#### Part 1A Checklist

- [ ] `ollama --version` returns a version string
- [ ] `ollama list` shows at least one downloaded model
- [ ] The `curl` command to `/api/tags` returns JSON (not a connection error)
- [ ] Your Python script prints a response that includes a `"content"` field

> **Only if you installed Ollama as a Docker container.**  The course expects Ollama installed natively, as in Step 1.  If you installed it as a Docker container instead, the `ollama` command does not exist on your host, and every `ollama ...` command on this page runs *inside* that container.  Reach it with `docker exec`, naming the container.  The conventional name, and the one `docker run --name ollama` gives you, is `ollama`; `docker ps` shows what yours is actually called.  The word appears twice for a reason: the first is the container, the second is the program inside it.
>
> ```bash
> docker exec ollama ollama --version
> docker exec ollama ollama pull llama3.2
> docker exec ollama ollama list
> ```
>
> Add `-it` when the command is interactive, as the chat in Step 2 is: `docker exec -it ollama ollama run llama3.2 "Say hello in five words."`.  Steps 3 and 4 are unaffected as long as you published the port with `-p 11434:11434`, because `localhost:11434` on your host then reaches the server inside the container.  A transcript from this route is fully accepted; leave the `docker exec` prefix visible in what you paste, so I can see where the command ran.

**Next:** Step 5.

---

### Step 5. Confirm your coding agent is installed and talking to that same local model

| Step 5 at a glance | |
|---|---|
| **Where you type** | The container prompt on Route A; your host terminal on Route B |
| **Route A** | Skip 5a (opencode is in the image); do 5b and 5c |
| **Route B** | Install opencode in 5a, then do 5b and 5c |
| **You paste** | The version string, and one question with the agent's answer |

The agent is **opencode**, and every install route lives at [opencode.ai](https://opencode.ai/).  The Week 2 lab depends on this step, so it is here rather than discovered later.

#### 5a. Install it

| | Route A | Route B |
|---|---|---|
| **Install** | Nothing.  opencode is already in the course image, and A5 printed its version.  Skip to 5b | One of the three commands in the rows below, for your system |
| **macOS, Linux, or WSL** | | `curl -fsSL https://opencode.ai/install \| bash` |
| **Already have Node.js** | | `npm i -g opencode-ai` |
| **Native Windows, in PowerShell** | | `choco install opencode` or `scoop install opencode` |

> **Note.**  That page also offers a **desktop app**, in beta for macOS, Windows, and Linux, if you would rather work in a window than a terminal.  It drives the same agent, but install the command-line version even if you try the desktop one, because this assignment and every lab ask for terminal output.

#### 5b. Point it at your model (both routes)

opencode reads one configuration file, and the file name matters: it is `opencode.json`, never `config.json`.  opencode silently ignores a file with the wrong name.

| Where opencode runs | Where the file goes | The `baseURL` inside it |
|---|---|---|
| Inside the course container (Route A) | `/workspace/opencode.json`, at the root of your repository | `http://host.docker.internal:11434/v1` |
| Natively on macOS, Linux, or WSL (Route B) | `~/.config/opencode/opencode.json` | `http://localhost:11434/v1` |
| Natively on Windows (Route B) | `%USERPROFILE%\.config\opencode\opencode.json` | `http://localhost:11434/v1` |

**Do.**  The smallest working file registers Ollama and nothing else.  Create the folder if it does not exist, save this as `opencode.json` in the location from the table, and use the `baseURL` from the table:

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

> **Note.**  Step 8 of the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md) walks through the same file in more detail, including an optional second provider you can add later.

#### 5c. Verify it (both routes)

**Do.**

```bash
opencode --version
```

Then start `opencode`, type `/model`, and confirm your Ollama provider is listed.  Ask it one question ("what files are in this directory?" is enough).

> **What you should see:** a version string, a `/model` list that names your Ollama provider, and an answer to your question.  A small local model answers slowly and sometimes oddly; that is the model, not your setup.

**Paste.**  The version string, and the question with the agent's answer.

> **Troubleshooting:** an empty provider list means the file name or location is wrong.  Check the name first, then the location from the table, then that the JSON parses with `python3 -m json.tool opencode.json`.  See the Stage 5 rows in Troubleshooting.

> **You've succeeded when** the three boxes below are checked.  That is Part 1B.

#### Part 1B Checklist

- [ ] `opencode --version` returns a version string
- [ ] `/model` lists your Ollama provider
- [ ] The agent answered one prompt from your local model

#### Optional: install herdr while you are here

> **This is not graded and is not on the checklist above.**  It is here because installing it now costs one command, and a later lab assumes it is on your bench.

**herdr** is an agent-aware terminal multiplexer.  It keeps agents running after you close your laptop or drop an SSH connection, and it shows you which agent is blocked, working, or done, so you are not cycling through terminal panes to find the one waiting on you.

| Where | How to install |
|---|---|
| **Route A** | Already in the course image, alongside opencode.  Confirm with `herdr --version` |
| **Route B: macOS, Linux, WSL** | `curl -fsSL https://herdr.dev/install.sh \| sh` |
| **Route B: macOS with Homebrew** | `brew install herdr` |
| **Route B: native Windows** | `powershell -ExecutionPolicy Bypass -c "irm https://herdr.dev/install.ps1 \| iex"` |

The installer downloads one binary, checks its SHA-256, and puts it in `~/.local/bin`.  If you include `herdr --version` in your transcript, I will read it, but its absence costs you nothing.

**Next:** *Capturing Part 1*, then Part 1.5.

---

### Capturing Part 1

Copy-paste or screenshot the output of all five steps, including the output of `ollama --version` and your operating system name and version.  On Route A, also include the container prompt and the A5 output, and say which route you took.

> **If any step fails:** document the error message verbatim, state your hypothesis about the cause, and describe what you tried.  A well-documented failure with a follow-up plan earns full credit for that step.  Do not delete error output or write "it eventually worked" without showing what changed.

---

## Part 1.5: Command-Line and Git Checkpoint

Every lab this semester runs from a terminal, lives in a git repository, and depends on a reproducible Python environment.  This checkpoint makes sure those tools work *before* the labs depend on them, the same philosophy as the Ollama setup above.  You do not need to be a shell wizard; you need to be able to move around, version your work, and stand up an environment without guesswork.  If any command below is unfamiliar, the **Command-Line Survival** resources at the end of this section will get you there.

Complete each step and capture the terminal output.

### Step 1. Navigate and search

| Part 1.5, Step 1 at a glance | |
|---|---|
| **Where you type** | Your host terminal; on Route A, the container prompt in `/workspace` works too |
| **Route A** | Do it |
| **Route B** | Do it |
| **You paste** | Every command with its output |

**Do.**  Create a working directory for this course, enter it, and list its contents:

```bash
mkdir -p ~/cs357 && cd ~/cs357 && pwd && ls -la
```

The directory is empty when you make it, so create a file for the search to find.  Redirecting a couple of lines into a file is the quickest way; typing them into an editor (`nano notes.txt`, or any of the ways in *Opening a terminal, moving around, and saving a file*) or copying in a file you already have works just as well:

```bash
printf 'model: llama3.2\nhost: http://localhost:11434\nagent: opencode\n' > notes.txt
cat notes.txt
```

> **Watch out!**  `touch notes.txt` creates the file but leaves it empty, and a search over an empty file matches nothing, so put a line or two inside it.  In native PowerShell, the equivalent is `Set-Content notes.txt "model: llama3.2"`, since `printf` and `grep` are Unix shell tools, and `Select-String` is the PowerShell search command.  Running these from WSL2 or Git Bash keeps the commands as written.

Then search that file with `grep` (or `ripgrep`, the `rg` command, if installed):

```bash
grep -n "localhost" notes.txt
```

> **What you should see:** `pwd` prints a path ending in `cs357`, `ls -la` lists `.` and `..`, `cat` prints your three lines, and `grep` prints
> ```
> 2:host: http://localhost:11434
> ```

**Paste.**  Every command above with its output.

**Next:** Step 2.

---

### Step 2. Authenticate to GitHub with an SSH key, then commit and push

| Part 1.5, Step 2 at a glance | |
|---|---|
| **Where you type** | Your host terminal for 2a through 2d (the key lives on your host); your host terminal, or on Route A the container prompt, for 2e and 2f |
| **Route A** | Do 2a through 2d on your host; for 2e and 2f, use `cs357-work` from A2 and push from the container with your A6 token |
| **Route B** | Do 2a through 2f |
| **You paste** | The `ssh -T` greeting and the `git log --oneline` output |

> **If you built the course container (Route A).**  You already have a repository: `cs357-work` from A2, cloned over HTTPS, with a scoped token from A6.  So for 2e, skip creating or cloning anything, and for 2f make your commit and push **from the container prompt** in `/workspace`; the token authenticates the push, and `git log --oneline` there is your transcript.  Still do 2a through 2d on your host, because the labs drive git from a host terminal too and the SSH key is the credential that belongs there.  If you built the container in class, the practice loop in Step 7 of the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md) (create `hello_agent.py`, run it against host Ollama, commit, push) is exactly this checkpoint, and its transcript satisfies it.

You will push to GitHub every week this semester, so set authentication up once, now, with a key.  GitHub no longer accepts your account password over HTTPS, and a key is the option that keeps working without a prompt on every push.  SSH (Secure Shell) is the protocol; the key is a file pair, one half private and one half public.  Follow 2a through 2f in order; the map below shows the whole path, and the alternatives after it are optional and replace specific sub-steps.

| Sub-step | What you do | Command | Paste it? |
|---|---|---|---|
| 2a | Check for a key you already have | `ls -al ~/.ssh` | No |
| 2b | Create one if you have none | `ssh-keygen -t ed25519 -C "you@example.com"` | No |
| 2c | Register the public half with GitHub | `cat ~/.ssh/id_ed25519.pub`, then paste at [github.com/settings/keys](https://github.com/settings/keys) | No |
| 2d | Test it | `ssh -T git@github.com` | **Yes**, the greeting |
| 2e | Get the repository onto your machine | `git clone git@github.com:<your-username>/<your-repo>.git` | No |
| 2f | Commit and push | `git add`, `git commit`, `git push -u origin main`, then `git log --oneline` | **Yes**, the log |

**2a. Check for a key you already have.**  A key you already trust is better than a second one, so look before you generate:

```bash
ls -al ~/.ssh
```

If `id_ed25519.pub` (or `id_rsa.pub`) is listed and you know its passphrase, skip to 2c.

**2b. Create one.**  Use the email address tied to your GitHub account:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

Press Enter to accept the default location, and set a passphrase rather than leaving it empty; the passphrase is what keeps the key useful to you and useless to someone who copies the file.  Then load it into the agent so you type that passphrase once per session rather than once per push:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**2c. Register the public key with GitHub.**  Print the `.pub` file, which is the *public* half:

```bash
cat ~/.ssh/id_ed25519.pub
```

> **Watch out!**  Never paste or send the file without the extension, which is the private key.  Only the `.pub` line goes to GitHub.

On GitHub, go to **Settings -> SSH and GPG keys -> New SSH key** (the direct link is [github.com/settings/keys](https://github.com/settings/keys)).  Title it after the machine it lives on, so you can revoke exactly one laptop later; leave the key type as **Authentication Key**; paste the whole line, and save.

**2d. Test it.**

```bash
ssh -T git@github.com
```

> **What you should see:** the first connection asks you to accept GitHub's host fingerprint; answer `yes`.  Success is a greeting that names your GitHub username.  It does not open a shell, and the message that GitHub does not provide shell access is the expected result, not an error.  **Paste this output.**

**2e. Get the repository onto your machine.**  Use your course GitHub Classroom repository, the `cs357-work` repository you created in A2 (Route A students already have it; skip to 2f), or a throwaway GitHub repository.  Which command starts you off depends on whether the repository already exists on GitHub:

| The repository | What you run |
|---|---|
| Already exists on GitHub | **Clone** it (the commands below) |
| Does not exist yet | Create it on GitHub first (**+ > New repository**, with no README, which keeps the two histories from conflicting), then `git init` and `git remote add` (the second block below) |

If it already exists on GitHub, clone it.  Cloning downloads the full repository, sets `origin` to the address you cloned from, and leaves you in a working copy that is already connected, so no `git remote add` follows.  Copy the address from the green **Code** button on the repository page, choosing the **SSH** tab so you get the `git@github.com:` form that the key you just registered authenticates:

```bash
cd ~/cs357
git clone git@github.com:<your-username>/<your-repo>.git
cd <your-repo>
git remote -v
```

> **What you should see:** `git clone` creates a *new folder* named after the repository, inside whatever directory you run it from, which is why you `cd` into it on the next line.  `git remote -v` should print your SSH address twice, once for fetch and once for push, which is your evidence that the working copy is wired to GitHub.  A repository with no commits yet clones with a warning that it is empty; that is fine, since the commit below is about to fill it.

If nothing exists on GitHub yet, create the repository there first, then initialize locally and attach the remote by hand:

```bash
git init
git remote add origin git@github.com:<your-username>/<your-repo>.git
```

**2f. Commit and push.**  Git versions files, so the repository needs at least one file before there is anything to commit.  Create it the way you created `notes.txt` above:

```bash
printf '# CS357 scratch repository\n' > README.md
git add README.md
git commit -m "first commit"
git push -u origin main
```

> **What you should see:** `git commit` prints a line beginning `[main` with your message, and `git push` ends with `main -> main`.  Then run `git log --oneline` and **paste its output**, which shows your commit.

> **Troubleshooting:** `git commit` without `-m` drops you into an editor, and `:q!` leaves it if that editor turns out to be `vim`.  `git push` complains if your default branch is not named `main`, which `git branch -M main` fixes.  If the repository already has an HTTPS remote, switch it in place rather than starting over: `git remote set-url origin git@github.com:<your-username>/<your-repo>.git`, then verify with `git remote -v`.  On native Windows, PowerShell ships OpenSSH, so the commands above work as written; if `ssh-add` reports that the agent is not running, start it once from an elevated PowerShell with `Set-Service -Name ssh-agent -StartupType Manual` followed by `Start-Service ssh-agent`.  See the Stage 7 rows in Troubleshooting.

> **Route A and credentials inside the container.**  The key you just made lives on your host, which is where it belongs.  Inside the course container, A6 above recommends a fine-grained personal access token (PAT) scoped to `cs357-work` instead, because that container will soon be running agent code, and a credential placed inside it is a credential that code can use.  That is why A2 clones `cs357-work` over HTTPS: the token authenticates HTTPS pushes.  Step 6 of the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md) goes deeper, and A6 shows the read-only `~/.ssh` mount if you would rather use your key there.

#### Alternatives to the command line for Step 2 (choose at most one)

Each of these replaces specific sub-steps; verify with `ssh -T git@github.com` either way.

| Tool | Replaces | Best for | Verify with |
|---|---|---|---|
| **GitHub CLI** (`gh`) | 2b and 2c (key generation and upload), and the `git clone` in 2e | Native Windows; the one I would take there | `ssh -T git@github.com` |
| **VS Code** | The `git clone` in 2e | Anyone already working in VS Code | `git log --oneline` in the integrated terminal |
| **GitHub Desktop** | 2e and 2f | Anyone who would rather not type git commands yet | `git log --oneline` from Repository > Open in terminal |

**The GitHub CLI.**  The [GitHub CLI](https://cli.github.com/), the `gh` command, does the whole exchange in 2b through 2c for you.  Install it (`winget install --id GitHub.cli` in PowerShell, `brew install gh` on macOS, or your package manager on Linux), then run `gh auth login`, choose **GitHub.com**, choose **SSH** as the protocol, and answer yes when it offers to generate a new SSH key and upload it to your account.  That one prompt replaces `ssh-keygen`, the `cat` of the `.pub` file, and the paste into Settings.  Verify with `ssh -T git@github.com` and paste that output; `gh repo clone <your-username>/<your-repo>` then clones over the protocol you just authorized, in place of the `git clone` in 2e.

**VS Code, for the clone in 2e.**  It drives the same git underneath, so the result is identical.  With no folder open, the Source Control view (Ctrl+Shift+G, or Cmd+Shift+G on macOS) offers a **Clone Repository** button; from anywhere, the Command Palette (Ctrl+Shift+P, or Cmd+Shift+P) runs **Git: Clone**.  Either one asks for the repository address, where you paste the same SSH URL, then asks which local folder to put it in, `~/cs357` here, and offers to open the clone when it finishes.  Say yes: the integrated terminal (Ctrl+\`) then opens already inside the repository, which is where you run `git log --oneline` for your transcript.  The palette also offers **Clone from GitHub**, which lets you pick from a list of your repositories instead of pasting a URL, though it signs you in to GitHub inside VS Code and authenticates as that account rather than with your key.

**GitHub Desktop, for 2e and 2f.**  If you would rather not type git commands yet, [GitHub Desktop](https://desktop.github.com/) is a supported option and handles authentication for you: install it, sign in, use File > New repository (or Add local repository) on your `cs357` folder, commit from the Changes tab, and Publish repository to push.  Then paste the output of `git log --oneline` from Repository > Open in terminal, which is the same transcript the command-line route produces.  Set the key up anyway, because the labs and the coding agent drive git from a terminal.

The two GitHub downloads are easy to confuse on native Windows without WSL2:

| | GitHub CLI (`gh`) | GitHub Desktop |
|---|---|---|
| **What it is** | The command-line tool, a separate install | The graphical client |
| **What it bundles** | Nothing else | Git for Windows, which is where `ssh-keygen` and Git Bash come from |
| **How it authenticates** | `gh auth login`, over SSH or HTTPS | Its own sign-in, handled for you |
| **Installing both** | Common, and they coexist happily | |

The Ubuntu or WSL2 route gives you the standard Unix tooling instead, and every command on this page then works as written.

**Next:** Step 3.

---

### Step 3. Reproducible Python with uv

| Part 1.5, Step 3 at a glance | |
|---|---|
| **Where you type** | Your host terminal, on both routes |
| **Route A** | Do it on the host; the container already bundles the course packages, and `uv` is your tool for everything outside it |
| **Route B** | Do it |
| **You paste** | The output of all four commands |

**Do.**  Install [uv](https://docs.astral.sh/uv/), the fast, modern Python environment manager we standardize on this term.  Then, in your `~/cs357` directory, create a project, an environment, and the one dependency the labs start with:

```bash
cd ~/cs357
uv init
uv venv
uv add requests
uv run python -c "import requests; print(requests.__version__)"
```

> **Note.**  `uv init` writes a `pyproject.toml`, which is what `uv add` records the dependency in; without it, `uv add` stops with a message about a missing project.

> **What you should see:** `uv add` prints `Installed` lines that include `requests`, and the last command prints a version number such as `2.32.3`.

**Paste.**  The output of all four commands.

> **Troubleshooting:** `uv: command not found` means the installer's directory is not on your PATH yet; restart the terminal.  If you cannot install uv, fall back to `python -m venv` and `pip install requests`, and note in your submission that you used the fallback.  See the Stage 8 rows in Troubleshooting.

**Next:** the Part 1.5 checklist, then Part 2.  The reference list below is there when you need it, not required reading.

---

### Command-Line Survival: reference (use as needed, not required reading cover-to-cover)

| Resource | What it is for |
|---|---|
| [The Shell, in Full]({{ site.baseurl }}/Tutorials/Shell) | The course's own shell tutorial, from the first prompt through pipes, PATH, and processes |
| [tldr pages](https://tldr.sh/) | Plain-language, example-first cheat sheets for any command (`tldr tar`) |
| [explainshell](https://explainshell.com/) | Paste any command line and see each flag explained |
| [ShellCheck](https://www.shellcheck.net/) | Catches bugs in shell scripts before they bite |
| `curl` and [HTTPie](https://httpie.io/) plus [jq](https://jqlang.github.io/jq/) | You will hit JSON APIs (Ollama, MCP) all semester; `curl ... \| jq` is your friend |

> **You've succeeded when** the three boxes below are checked.  That is Part 1.5.

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
| A | `Cannot connect to the Docker daemon` | Docker Desktop is installed but not running | Start the application. On Linux, `sudo systemctl start docker`, and confirm your user is in the `docker` group |
| A | Docker Desktop is running, but `docker` is not a command inside WSL2 Ubuntu | Docker's WSL integration is off for that distribution | In Docker Desktop, **Settings -> Resources -> WSL Integration**, switch the **Ubuntu** toggle on, **Apply & Restart**, then open a new Ubuntu terminal |
| A | `docker compose build` cannot find the Dockerfile | A browser saved it as `Dockerfile.txt`, or you are not in the `.devcontainer/` folder | `ls -la .devcontainer` and rename the file if needed; run `docker compose` from inside `.devcontainer/`, because the `..` in the compose file is relative to it |
| A | Inside the container, `/workspace` is empty | On Windows, the clone lives on a drive or share Docker Desktop has not been granted, or `docker compose` ran from the wrong folder | Keep `cs357-work` under your user profile or, better, inside your WSL2 home directory; run `docker compose` from `.devcontainer/` |
| A | `fatal: detected dubious ownership in repository at '/workspace'` | The repository's owner (your host account) is not the user running git in the container (`student`) | `git config --global --add safe.directory /workspace` inside the container, then rerun the command; once per session on the compose route |
| A | `permission denied` writing files in `/workspace` (Linux hosts) | The container's `student` UID does not match your host UID | `docker compose run --rm --user "$(id -u):$(id -g)" cs357` |
| A | The build fails partway with a network error | A flaky connection during the large download layers | Rerun `docker compose build`; completed layers are cached, so it resumes from the failed step |
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
| 7 | `git push` rejected, "authentication failed" | GitHub no longer accepts account passwords over HTTPS | Set up the SSH key in Part 1.5, Step 2, then point the remote at it: `git remote set-url origin git@github.com:<user>/<repo>.git`.  A fine-grained personal access token scoped to that one repository, with Contents: read and write, is the fallback if you must stay on HTTPS, and is the default inside the container (A6) |
| 7 | `git@github.com: Permission denied (publickey)` | The key is not loaded in the agent, or its public half was never added to GitHub | `ssh-add -l` lists loaded keys and `ssh-add ~/.ssh/id_ed25519` loads yours; confirm the contents of `id_ed25519.pub` appear under Settings -> SSH and GPG keys; then retest with `ssh -T git@github.com` |
| 7 | GitHub Desktop says authentication failed, or cannot push | Not signed in, or the repository exists on GitHub but was never published from Desktop | File > Options > Accounts, sign in with the browser, then Publish repository; if the repository already exists online, use Add local repository and set the remote under Repository > Repository settings |
| 8 | `uv: command not found` | Not installed, or not on `PATH` yet | Follow the uv install docs, restart the terminal, and if it still fails use the documented `python -m venv` fallback and say so |
| 8 | `uv add` complains that no `pyproject.toml` was found | You skipped `uv init` | Run `uv init` in the same directory, then rerun `uv add requests` |

---

## Self-Check Before You Submit

Hold your submission against the rubric's `proficient` column:

- [ ] One file, PDF or Markdown, with each component **clearly labeled**.
- [ ] Setup transcript covers all five steps, including the coding-agent check, and states your **OS and version numbers**.  On Route A, it also shows the container prompt and the A5 output.
- [ ] Transcript output is **copied verbatim**, not retyped or paraphrased.
- [ ] Any failure is quoted exactly, with a hypothesis and what you tried.
- [ ] Part 1.5: shell navigation and a search, a `git log --oneline` showing a pushed commit, and the uv (or documented fallback) output.
- [ ] Reflection has **four** labeled sections and is about a page.
- [ ] The reflection says what you actually think, not what you expect the course to want.
- [ ] Which route you took (A or B) is stated, and a Route A transcript shows the container prompt.
- [ ] Collaboration, AI-disclosure, and hours questions answered at the end.

---

## Deliverables

Submit a single PDF or markdown file containing:
- Your tool setup transcript (all five steps, including `opencode --version` and one answered prompt, plus version and OS info; on Route A, the container prompt and the A5 output as well)
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
