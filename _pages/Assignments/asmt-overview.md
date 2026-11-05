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
      proficient: The transcript shows all four Ollama steps completed with verbatim terminal output, the output of ollama --version, ollama list showing at least one model, the curl /api/tags JSON response, and the Python script output including a non-empty "content" field, plus the fifth step, the output of opencode --version and one answered prompt from your local model, plus the operating system name and version; the command-line and git checkpoint (Part 1.5) is also complete, showing the shell-navigation commands, the output of gh auth status, a git commit/push transcript (command line or GitHub Desktop), and the uv environment creation; any failed step includes the verbatim error message, a stated hypothesis, and what was tried
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
      proficient: A single well-organized PDF or Markdown file with each component clearly labeled, the five-step setup transcript with version and OS details, the Part 1.5 command-line and git checkpoint, and the four-section reflection, with the collaboration and time questions answered at the end
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

In this warmup you'll install your local AI stack and your coding agent, and write a short baseline reflection on your experiences with AI.  I have kept the stakes low here on purpose.  It exists to make sure your tools work before the labs depend on them, and to capture a snapshot of your thinking that you'll come back to at the end of the semester.

There are no wrong answers in the reflection.  This is a starting point, and I am not evaluating what you know.

Two administrative notes.  Your team charter is **not** part of this assignment; it is handed out separately once teams are announced (see the [Project Thread]({{ site.baseurl }}/Projects/PBLThread#the-team-charter)).  And see the course schedule for this onboarding assignment's due date; it is assessed within the Class Activities and Participation category.

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

> **Taking Route A?**  The *Optional Route A Setup* section in Part 1 sends you to the [Course Container tutorial]({{ site.baseurl }}/Tutorials/CourseContainer), which installs Docker and builds the course container, with direct links to the container files, and every later step says what Route A lets you skip.  The *Your AI Workbench* class session walks the same steps with you.

> **How to use this page.**  First, pick your route in *Which route should I take?* at the top of Part 1.  Then follow your route's path below, top to bottom.  Every step opens with an *at a glance* box that says where you type, what each route does there, and what you paste, and every step ends with a **Next** line that tells you where to go.  If you only read the boxes and the Next lines, you will still land in the right place.

| Route A path (recommended) | Route B path |
|---|---|
| *Optional Route A Setup*, A1 through A6 | Skip the optional section |
| Steps 1 and 2, on your host | Steps 1 and 2 |
| Step 3 on your host, plus its Route A bridge check from inside the container | Step 3 |
| Step 4 inside the container; nothing to install | Step 4, after installing Python, pip, and `requests` |
| Step 5 from 5b; opencode is already installed | Step 5, after installing opencode |
| Part 1.5, Steps 1 through 3; `gh` is already in the image, and Step 2 pushes from the container with your A6 credential | Part 1.5, Steps 1 through 3 |
| Part 2, the reflection | Part 2, the reflection |

### The setup map

This assignment is nine stages plus two optional ones.  Each stage ends with one command whose output you paste into your submission, so you can always tell whether a stage is done.  Work down the table in order, and use the last column to find the steps.

| Stage | What you do | The command that proves it | What you paste | Where the steps are |
|---|---|---|---|---|
| 0 | Open a terminal, learn to move around and save a file, tell your host prompt from a container prompt, note your operating system, and, on Route B, install Python and pip | `pwd`, and on Route B `python3 --version` | Your operating system name and version, your route (A or B), and on Route B the Python and pip version lines | Part 1, *Opening a terminal*, *Where am I typing?*, and *Installing Python and pip* |
| A | Optional, Route A only: install Docker, create `cs357-work`, add the container files, build, enter, and verify | `docker compose run --rm cs357`, then the checks in A5 | The container prompt and the A5 output | Part 1, *Optional Route A Setup* |
| 1 | Install Ollama and pull a model | `ollama list` | The output of `ollama --version` and `ollama list` | Part 1, Step 1 |
| 2 | Chat with the model once | `ollama run llama3.2 "..."` | The model's reply | Part 1, Step 2 |
| 3 | Confirm the REST API answers | `curl http://localhost:11434/api/tags` | The JSON | Part 1, Step 3 |
| 4 | Call the model from Python | `python3 ollama_check.py` | The printed JSON, including a `"content"` field | Part 1, Step 4 |
| W | Optional, either route: install OpenWebUI, the chat interface over Ollama | Browse to `http://localhost:3000` (Docker) or `http://localhost:8080` (pip) | Nothing required; a screenshot of the model dropdown is welcome | Part 1, *Optional: Install OpenWebUI* |
| 5 | Confirm the coding agent talks to that model | `opencode --version` | The version string and one answered prompt | Part 1, Step 5 |
| 6 | Navigate a shell and search a file | `grep -n "localhost" notes.txt` | The commands and their output | Part 1.5, Step 1 |
| 7 | Install and authenticate `gh`, then commit and push | `gh auth status`, then `git log --oneline` | The `gh auth status` block and the log | Part 1.5, Step 2 |
| 8 | Create a reproducible Python environment | `uv run python -c "import requests; print(requests.__version__)"` | The printed version | Part 1.5, Step 3 |
| 9 | Write the baseline reflection | none | Four labeled sections | Part 2 |

> **Do the stages in this order.**  Start Stage 1 first, because the download runs in the background.  On Route A, start the Stage A image build at the same time; both are downloads.  While they download, write the reflection (Stage 9); it needs no tools.  Then finish Stages 2 through 5, and do Stages 6 through 8 last, since they use what you just installed.

> **If a stage fails, document it and move on.**  A documented failure earns full credit for that stage: quote the error verbatim, state your hypothesis about the cause, and say what you tried.  "It worked eventually" earns nothing.  Work down the Troubleshooting table at the end of this page before you post in the course channel.

> **You've succeeded when** the four boxes in the Part 1A checklist and the three in the Part 1B checklist are checked, all four in the Part 1.5 checklist are checked, and your reflection has four labeled sections.  On Route A, the Route A checklist is checked as well.

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
| What you install | Ollama, Docker Desktop, and the course container, by following *Optional Route A Setup* below (the same steps the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md) walks through in class) | [Ollama](https://ollama.com/download), Python 3 with pip (see *Installing Python and pip* below), the Python `requests` library, and opencode from [opencode.ai](https://opencode.ai/) |

> **Deciding your route.**  You do not have to decide yet, but decide early:
>
> 1.  Steps 1 through 3 are identical on both routes, so start Step 1's download now.
> 2.  If Docker Desktop installs and `docker run hello-world` succeeds (that is A1, the first thing the optional section asks), take **Route A**: do the *Optional Route A Setup* section, start its image build while the Step 1 model pull runs, and then Steps 3, 4, and 5 and Part 1.5 Step 2 each say what Route A lets you skip.
> 3.  If Docker will not run on your machine, take **Route B**, skip the optional section, and say so in your transcript.
>
> I recommend Route A because every later lab assumes it and it is what we build together in the *Your AI Workbench* session.  Route B is complete and supported too.  On Route A, the A5 checks and the Step 3 bridge check belong in your transcript as well.

### Before Step 1: Orientation (read once, come back as needed)

Four short references before the steps begin.  Every *at a glance* box below says "your host terminal" or "the container prompt"; the first two sections are where those words are defined, and every step that says "open a terminal," "`cd`," or "save it" means the first of them.  The third installs Python and pip, which Route B needs before Step 4.  The fourth makes a GitHub token and puts it somewhere your tools can find it; A6 is the first place you need it, and the MCP session and several labs send you back here.

- [Opening a terminal, moving around, and saving a file]({{ site.baseurl }}/Tutorials/SetupBasics#opening-a-terminal-moving-around-and-saving-a-file)
- [Where am I typing?]({{ site.baseurl }}/Tutorials/SetupBasics#where-am-i-typing)
- [Installing Python and pip]({{ site.baseurl }}/Tutorials/SetupBasics#installing-python-and-pip)
- [Making a token, and putting it in your environment]({{ site.baseurl }}/Tutorials/SetupBasics#making-a-token-and-putting-it-in-your-environment)

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

**Do A1 through A6 in the [Course Container tutorial]({{ site.baseurl }}/Tutorials/CourseContainer)**, and then come back here for the checklist.

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
| **Install** | Nothing; the container already has the `requests` library | Python 3 with pip, from *Installing Python and pip* in the orientation, then `requests` by one of the three ways in *Route B: installing `requests`* just below |
| **Where to save `ollama_check.py`** | `/workspace`, which is your `cs357-work` clone | `~/cs357` |
| **Address in the script** | Replace `localhost` with `host.docker.internal` | Leave `localhost` as written |

#### Route B: installing `requests`

The script imports `requests`, a library that is not part of Python.  Three tools can install Python packages, and this is the first place on the page where you choose one.  The table names what each is for, because the choice matters more than the command:

| Tool | The command | What it does, and when to use it |
|---|---|---|
| **pip, inside a virtual environment** | macOS, Linux, or WSL2: `cd ~/cs357`, `python3 -m venv .venv`, `source .venv/bin/activate`, then `python3 -m pip install requests`.  PowerShell: `cd ~/cs357`, `python -m venv .venv`, `.\.venv\Scripts\Activate.ps1`, then `python -m pip install requests` | A virtual environment is a private copy of Python's library folder for one project, kept in `.venv`, so that the library lands there rather than in the system Python.  Activating it (the prompt gains a `(.venv)` prefix) makes `python3` and `pip` mean that copy for the rest of the terminal session, so activate it again in every new terminal.  Installing without one works on macOS and Windows but is a habit to unlearn: it stops with `error: externally-managed-environment` on Ubuntu, Debian, and a fresh WSL2 Ubuntu, and it mixes every project's libraries together.  If PowerShell refuses to run the activation script, run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` once, then retry |
| **uv** | `cd ~/cs357`, `uv init`, `uv add requests`, then run the script with `uv run python ollama_check.py` | Creates a project with its own environment in `~/cs357/.venv`, records `requests` in `pyproject.toml`, and runs the script inside that environment.  This is exactly what Part 1.5, Step 3 does, so doing it here means Step 3 is already done; install uv from the table in that step first |
| **pipx** | `pipx install requests` | Stops with `No apps associated with package requests`, and that is the right answer: pipx installs *programs* (each in its own private environment, with the command on your `PATH`), not libraries for your scripts to import.  It is the right tool for `pipx install uv`, and the wrong one for `requests` |

Whichever tool you choose, run the script from the same terminal, with the environment still activated on the pip route, so that the Python that runs it is the one that received the library.  Both pip's `.venv` and uv's `.venv` are ordinary folders in `~/cs357`; if that folder becomes a git repository in Part 1.5, add `.venv` to its `.gitignore`, because an environment is rebuilt from `pyproject.toml` rather than committed.

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

> **Troubleshooting.**
>
> - `ModuleNotFoundError: No module named 'requests'` means the install landed in a different Python than the one you ran.  Use `python3 -m pip install requests`, or `python -m pip` on Windows, from the same terminal, then rerun.
> - `error: externally-managed-environment` on Ubuntu, Debian, and therefore a fresh WSL2 Ubuntu, is the operating system refusing to let pip change its own Python.  It means you skipped the virtual environment in the pip row above.  Create and activate it, so the prompt gains a `(.venv)` prefix, then rerun the `pip install` and the script from that same terminal.  Or jump ahead to Part 1.5, Step 3, and let `uv` manage it.
> - `Activate.ps1 cannot be loaded because running scripts is disabled` in PowerShell is the execution policy.  The pip row has the one-time fix.
> - A `ConnectionError` inside the container means the address rule was not applied.
> - `can't open file ... No such file or directory` means you are in a different directory than the one you saved into.  `ls`, or `dir` on Windows, shows which.

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

**Next:** Step 5, or the optional OpenWebUI install first.

---

### Optional: Install OpenWebUI, the chat interface over Ollama

OpenWebUI gives you a browser chat over the same model, and the No-code paths in later labs use it.  The install is in [Setup Basics]({{ site.baseurl }}/Tutorials/SetupBasics#optional-install-openwebui-the-chat-interface-over-ollama).

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
| **Already have Node.js** (20 or newer; check with `node --version`) | | `npm i -g opencode-ai` |
| **Native Windows, in PowerShell** | | `choco install opencode` or `scoop install opencode` |

> **Note.**  That page also offers a **desktop app**, in beta for macOS, Windows, and Linux, if you would rather work in a window than a terminal.  It drives the same agent, but install the command-line version even if you try the desktop one, because this assignment and every lab ask for terminal output.

#### 5b. Point it at your model (both routes)

opencode reads one configuration file, and the file name matters: it is `opencode.json`, never `config.json`.  opencode silently ignores a file with the wrong name.

Where you put it decides **which projects it applies to**.  A copy in a project directory configures that repository and nothing else; a copy in your home directory configures everything you open.  Pick the row for what you want, and note that the address also changes with it, because `localhost` means something different inside a container:

| Where the file goes | What it configures | The `baseURL` inside it |
|---|---|---|
| `/workspace/opencode.json`, the root of your `cs357-work` repository (Route A) | That repository.  It is also the copy that survives `docker compose run --rm`, since the container's home directory does not | `http://host.docker.internal:11434/v1` |
| Any other project directory, as `opencode.json` at its root | That project | Match it to where opencode runs |
| `~/.config/opencode/opencode.json` on macOS, Linux, or WSL | Every project you open | `http://localhost:11434/v1` |
| `%USERPROFILE%\.config\opencode\opencode.json` on Windows | Every project you open | `http://localhost:11434/v1` |

For today either choice works, since the only thing being configured is a model provider you want everywhere.  The distinction starts to matter in the *MCP* session, where a configuration can attach a whole tool server to a project: a server that belongs to one repository costs you context in every other one if you put it in the home-directory copy.

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

Then start `opencode`, type `/models`, and confirm your Ollama provider is listed.  Ask it one question ("what files are in this directory?" is enough).

> **What you should see:** a version string, a `/models` list that names your Ollama provider, and an answer to your question.  A small local model answers slowly and sometimes oddly; that is the model, not your setup.

**Paste.**  The version string, and the question with the agent's answer.

> **Troubleshooting:** an empty provider list means the file name or location is wrong.  Check the name first, then the location from the table, then that the JSON parses with `python3 -m json.tool opencode.json`.  See the Stage 5 rows in Troubleshooting.

> **You've succeeded when** the three boxes below are checked.  That is Part 1B.

#### Part 1B Checklist

- [ ] `opencode --version` returns a version string
- [ ] `/models` lists your Ollama provider
- [ ] The agent answered one prompt from your local model

> **Optional.**  [Connect a hosted endpoint]({{ site.baseurl }}/Tutorials/SetupBasics#optional-5d-connect-a-hosted-endpoint-if-you-are-given-one), if you are given one, or [install herdr]({{ site.baseurl }}/Tutorials/SetupBasics#optional-install-herdr-while-you-are-here).

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

### Step 2. Authenticate to GitHub with `gh`, then commit and push

| Part 1.5, Step 2 at a glance | |
|---|---|
| **Where you type** | Your host terminal for 2a through 2c (the credential lives on your host); your host terminal, or on Route A the container prompt, for 2d and 2e |
| **Route A** | Do 2a through 2c on your host; for 2d and 2e, use `cs357-work` from A2 and push from the container with your A6 token |
| **Route B** | Do 2a through 2e |
| **You paste** | The `gh auth status` output and the `git log --oneline` output |

> **If you built the course container (Route A).**
>
> You already have a repository: `cs357-work` from A2, cloned over HTTPS, with a scoped token from A6.  So for 2d, skip creating or cloning anything.  For 2e, make your commit and push **from the container prompt** in `/workspace`; the token authenticates the push, and `git log --oneline` there is your transcript.
>
> Still do 2a through 2c on your host.  The labs drive git and `gh` from a host terminal too, and that is where the credential belongs.
>
> If you built the container in class, the practice loop in Step 7 of the [Development Environment activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-devenvironment.md), which creates `hello_agent.py`, runs it against host Ollama, commits, and pushes, is exactly this checkpoint.  Its transcript satisfies it.

You will push to GitHub every week this semester, so set authentication up once, now.  GitHub stopped accepting your account password over HTTPS years ago, which leaves two credentials that work: an SSH key, and a token.  The fastest way to get either one is **`gh`, the GitHub CLI**, which creates the key, uploads it to your account, and hands git a credential, in one sign-in.

Install it even if you already have a working key, and install it even if you prefer clicking.  Two days from now the *Coding Agents* session runs its entire loop through `gh`, an issue becomes the task and a pull request becomes the attempt, and the *Agents That Talk, Observability, and Handoff Protocols* session later uses the same commands as a message bus between two agents.  This is the step where you get it.

| Sub-step | What you do | Command | Paste it? |
|---|---|---|---|
| 2a | Install the GitHub CLI | `gh --version` | No |
| 2b | Sign in, letting `gh` make and upload an SSH key | `gh auth login` | No |
| 2c | Confirm | `gh auth status`, then `ssh -T git@github.com` | **Yes**, the status block |
| 2d | Get the repository onto your machine | `gh repo clone <your-username>/<your-repo>` | No |
| 2e | Commit and push | `git add`, `git commit`, `git push -u origin main`, then `git log --oneline` | **Yes**, the log |

**2a. Install the GitHub CLI.**  One row for your system:

| System | How to install `gh` |
|---|---|
| **macOS, with Homebrew** | `brew install gh` |
| **Windows, PowerShell** | `winget install --id GitHub.cli`, then open a new PowerShell window so `PATH` picks it up |
| **WSL2 Ubuntu, Debian, Ubuntu** | Follow the four-line apt recipe on [cli.github.com](https://cli.github.com/), which adds GitHub's package repository.  Do not use plain `apt install gh` alone: the version Ubuntu ships lags far enough behind to be missing commands the labs use |
| **Other Linux** | Your package manager (`dnf install gh`, `pacman -S github-cli`), or the release archive from [cli.github.com](https://cli.github.com/) |
| **The course container (Route A)** | Nothing.  `gh` is in the image, and `gh --version` at the container prompt proves it |

Confirm with `gh --version`.

**2b. Sign in.**  Before you generate anything, look for a key you already trust, because `gh` will offer to use it rather than making a second one:

```bash
ls -al ~/.ssh
```

Then:

```bash
gh auth login
```

Answer the prompts: **GitHub.com**, then **SSH** as the protocol, then let it **generate a new SSH key** if `ls` showed none (give the key a passphrase; that passphrase is what keeps the key useless to somebody who copies the file), then **Login with a web browser**, which prints a one-time code to paste into the page it opens.

That single exchange replaces three manual steps: `ssh-keygen`, printing the public half, and pasting it into GitHub's settings.  It also uploads the key under a name you can revoke later, which is the part people forget to do by hand.

> **Note.**  If you would rather git push over HTTPS than over SSH, run `gh auth setup-git` afterwards.  It installs `gh` as git's credential helper, so `git push` stops asking who you are.  You do not need it on the SSH path.

**2c. Confirm it.**

```bash
gh auth status
ssh -T git@github.com
```

> **What you should see:** `gh auth status` names github.com, your account, the protocol, and the token's scopes.  `ssh -T` asks you to accept GitHub's host fingerprint the first time, which you answer `yes`, and then greets you by username.  It does not open a shell, and the line saying GitHub does not provide shell access is the success case, not an error.  **Paste the `gh auth status` block.**

> **Watch out!**  Tokens expire and sessions lapse.  When a `gh` command fails later in the semester with a 401, a 403, or a flat refusal to authenticate, `gh auth status` tells you which, `gh auth login` signs you back in, and `gh auth refresh -s <scope>` adds a permission you did not originally grant.  You will want that last one in the *Coding Agents* session.

**2d. Get the repository onto your machine.**  Use your course GitHub Classroom repository, the `cs357-work` repository from A2 (Route A students already have it; skip to 2e), or a throwaway repository.  If it exists on GitHub already:

```bash
cd ~/cs357
gh repo clone <your-username>/<your-repo>
cd <your-repo>
git remote -v
```

> **What you should see:** cloning creates a *new folder* named after the repository inside whatever directory you ran it from, which is why you `cd` into it on the next line.  `git remote -v` prints an address twice, once for fetch and once for push, and that is your evidence the working copy is wired to GitHub.  `gh repo clone` picks the protocol you authorized in 2b, so you never paste a URL.  A repository with no commits clones with a warning that it is empty; the commit below is about to fix that.

If nothing exists on GitHub yet, make it and clone it in one command:

```bash
gh repo create <your-repo> --private --clone
cd <your-repo>
```

**2e. Commit and push.**  Git versions files, so the repository needs a file before there is anything to commit.  Make one the way you made `notes.txt`:

```bash
printf '# CS357 scratch repository\n' > README.md
git add README.md
git commit -m "first commit"
git push -u origin main
```

> **What you should see:** `git commit` prints a line beginning `[main` with your message, and `git push` ends with `main -> main`.  Then run `git log --oneline` and **paste its output**, which shows your commit.

> **Troubleshooting.**
>
> - `git commit` without `-m` drops you into an editor.  If that editor turns out to be `vim`, `:q!` leaves it.
> - `git push` complains if your default branch is not named `main`.  `git branch -M main` fixes it.
> - A repository that still has an HTTPS remote from an earlier clone can be switched in place rather than recloned: `git remote set-url origin git@github.com:<your-username>/<your-repo>.git`, then check with `git remote -v`.
> - On native Windows, PowerShell ships OpenSSH, so these commands work as written.  If `ssh-add` reports that the agent is not running, start it once from an elevated PowerShell with `Set-Service -Name ssh-agent -StartupType Manual` followed by `Start-Service ssh-agent`.
>
> See the Stage 7 rows in Troubleshooting.

**2f. Or ask the agent to do it.**

Everything in 2d and 2e is a command line, and you now have a program sitting in the next terminal whose job is composing command lines.  Try it once, here, where you already know what the right answer looks like:

> "Create a private GitHub repository called `cs357-scratch` using `gh`, clone it into this folder, add a README that says what it is, commit, and push.  Show me `git log --oneline` when you are done."

> "Run `gh auth status` and tell me what it says.  If I am not signed in, stop and say so rather than trying to fix it yourself."

The permission gate asks before each shell command, so you see exactly what the agent composed before it runs, which is the whole reason to do this the first time on a throwaway repository.  Neither prompt is graded.  They are here because the command line is how you learn what an operation *is*, and the prompt is how you will actually work once you know, and this course would rather you met both in week one.

> **Other ways to do this.**  [Set up SSH by hand, or use another way to create and push the repository]({{ site.baseurl }}/Tutorials/SetupBasics#alternative-do-it-by-hand-with-ssh-keygen).

### Step 3. Reproducible Python with uv

| Part 1.5, Step 3 at a glance | |
|---|---|
| **Where you type** | Your host terminal, on both routes |
| **Route A** | Do it on the host; the container already bundles the course packages, and `uv` is your tool for everything outside it |
| **Route B** | Do it |
| **You paste** | The output of all four commands |

**Do.**  Install [uv](https://docs.astral.sh/uv/), the fast, modern Python environment manager we standardize on this term, using the row for your system:

| System | Install uv | Then |
|---|---|---|
| **macOS, with Homebrew** | `brew install uv` | Nothing; Homebrew's directory is already on your `PATH` |
| **macOS, Linux, or WSL2 Ubuntu** | The standalone installer: the one-line `curl` command in the first block below the table | Open a new terminal, or run `source $HOME/.local/bin/env`, so that `~/.local/bin` is on your `PATH` |
| **Windows, PowerShell** | The standalone installer: the one-line `powershell` command in the second block below the table, or `winget install --id=astral-sh.uv -e` | Open a new PowerShell window |
| **Any system, through pipx** | `pipx install uv`.  pipx itself comes from `brew install pipx` on a Mac, `sudo apt install pipx` on Ubuntu or WSL2, or `python -m pip install --user pipx` on Windows, each followed by `pipx ensurepath` | Open a new terminal, so that pipx's `~/.local/bin` is on your `PATH` |
| **Any system, through pip** | `python3 -m pip install uv` (PowerShell: `python -m pip install uv`) | Nothing, though on Ubuntu this meets the same `externally-managed-environment` refusal as Step 4, so use the `curl` or pipx row there |

The two standalone installer lines, which do not fit in a table cell:

```bash
# macOS, Linux, or WSL2 Ubuntu
curl -LsSf https://astral.sh/uv/install.sh | sh
```

```powershell
# Windows, in PowerShell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Confirm the install with `uv --version`.

> **pip, pipx, or uv?**  All three install packages from the [Python Package Index](https://pypi.org/), and they divide the work cleanly.  **pip** installs a library into one particular Python, for that Python's scripts to import.  **pipx** installs a *program* written in Python (uv, `ruff`, `black`, `jupyter`) into a private environment of its own and puts its command on your `PATH`, so tools never fight over versions.  **uv** does both jobs per project, and pins what it installed in `pyproject.toml` so a teammate can rebuild the same environment; that reproducibility is why the course standardizes on it.

Then, in your `~/cs357` directory, create a project, an environment, and the one dependency the labs start with:

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

> **Troubleshooting:** `uv: command not found` means the installer's directory is not on your PATH yet; restart the terminal, or run `source $HOME/.local/bin/env`.  On a Mac, if `brew install uv` complains that your macOS version is unsupported, run `brew update` and retry.  If you cannot install uv, fall back to `python3 -m venv .venv`, `source .venv/bin/activate`, and `python3 -m pip install requests` (PowerShell: `python -m venv .venv`, `.\.venv\Scripts\Activate.ps1`, `python -m pip install requests`), and note in your submission that you used the fallback.  See the Stage 8 rows in Troubleshooting.

**Next:** the Part 1.5 checklist, then Part 2.  The reference list below is there when you need it, not required reading.

---

> **Reference.**  [Command-Line Survival]({{ site.baseurl }}/Tutorials/SetupBasics#command-line-survival-reference-use-as-needed-not-required-reading-cover-to-cover) is there when you need it.

### Part 1.5 Checklist

- [ ] A shell transcript showing directory creation, navigation, and a `grep`/`rg` search
- [ ] A `gh auth status` transcript showing you are signed in to GitHub
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
| 0 | `python3: command not found` on macOS or Linux, or `python` opens the Microsoft Store on Windows | Python is not installed, or the terminal window predates the install | Install it from *Installing Python and pip* in Part 1's orientation, then open a new terminal.  On Windows, if the Store keeps opening afterwards, turn off the `python.exe` and `python3.exe` entries under **Manage app execution aliases** |
| 0 | `No module named pip` | Python was installed without its package installer | `python3 -m ensurepip --upgrade` on macOS and Windows; `sudo apt install python3-pip` on Ubuntu and WSL2 |
| 0 | `python3 -m pip --version` names a different Python than the one you just installed | Several Pythons on the machine, and `PATH` finds an older one first | `which python3` (PowerShell: `Get-Command python`) shows which one wins; open a new terminal after the install, and always write `python3 -m pip` rather than a bare `pip` |
| 0 | On a Mac, Homebrew says your macOS version is unsupported or a pre-release, and `brew install` fails | Your copy of Homebrew predates your macOS upgrade | `brew update`, then rerun the install.  Homebrew needs macOS Sonoma (14) or later |
| A | `Cannot connect to the Docker daemon` | Docker Desktop is installed but not running | Start the application. On Linux, `sudo systemctl start docker`, and confirm your user is in the `docker` group |
| A | Docker Desktop is running, but `docker` is not a command inside WSL2 Ubuntu | Docker's WSL integration is off for that distribution | In Docker Desktop, **Settings -> Resources -> WSL Integration**, switch the **Ubuntu** toggle on, **Apply & Restart**, then open a new Ubuntu terminal |
| A | `docker compose build` cannot find the Dockerfile | A browser saved it as `Dockerfile.txt`, or you are not in the `.devcontainer/` folder | `ls -la .devcontainer` and rename the file if needed; run `docker compose` from inside `.devcontainer/`, because the `..` in the compose file is relative to it |
| A | Inside the container, `/workspace` is empty | On Windows, the clone lives on a drive or share Docker Desktop has not been granted, or `docker compose` ran from the wrong folder | Keep `cs357-work` under your user profile or, better, inside your WSL2 home directory; run `docker compose` from `.devcontainer/` |
| A | `fatal: detected dubious ownership in repository at '/workspace'` | The repository's owner (your host account) is not the user running git in the container (`student`) | `git config --global --add safe.directory /workspace` inside the container, then rerun the command; once per session on the compose route |
| A | `permission denied` writing files in `/workspace` (Linux hosts) | The container's `student` UID does not match your host UID | `docker compose run --rm --user "$(id -u):$(id -g)" cs357` |
| A | The build fails partway with a network error | A flaky connection during the large download layers | Rerun `docker compose build`; completed layers are cached, so it resumes from the failed step |
| A | `promptfoo` refuses to start and says Node.js must be 22.22.0 or newer | An image built before the course container pinned Node 24; Debian's own Node package is older than promptfoo now allows | Re-fetch the current Dockerfile and rebuild, as *Appendix: Updating Your Container* describes.  Fetching matters: the Dockerfile lives in your repository, so rebuilding without it just rebuilds the same image |
| 1 | `ollama: command not found` after installing | The installer put the binary somewhere not on your `PATH` | Restart your terminal. If it persists, find the binary (`ls /usr/local/bin/ollama`) and add its directory to `PATH`. This is the `PATH` idea from Step 0 of the Workbench session |
| 1 | `ollama: command not found`, and you installed Ollama with Docker | There is no host binary on this route; the program lives inside the container | Prefix the command: `docker exec ollama ollama list` (`docker ps` confirms the container name), and add `-it` for the interactive `ollama run` |
| 1 | The model download stalls or fails partway | Network interruption on a 2 GB transfer | Rerun `ollama pull llama3.2`; it resumes rather than restarting |
| 1 | Out of disk space partway through the build | The course image plus models is roughly 8 to 10 GB | Clear space and rerun `docker compose build`; completed layers are cached and the build resumes |
| 2 | Responses are very slow | A small model on CPU-only hardware | Expected. `llama3.2` is the right choice for that machine. Note the speed in your transcript; it is a real observation, not a failure |
| 3 | The `curl` to `/api/tags` says connection refused | The Ollama *server* is not running, which is separate from Ollama being installed | Start the desktop app, or run `ollama serve` in its own terminal and leave it open |
| 4 | Inside the container, `localhost:11434` refuses the connection | Correct behavior: `localhost` inside a container means the container | Use `http://host.docker.internal:11434`, but only for commands run inside a container; from your host, `localhost` stays correct. On Linux, start via the course compose file so that hostname resolves |
| 4 | `ModuleNotFoundError: No module named 'requests'` | The library is not installed in the Python you are running | `python -m pip install requests`, then rerun the script from the same terminal |
| 4 | `error: externally-managed-environment` from `pip install` | Ubuntu and Debian protect the system Python from pip, and you installed outside a virtual environment | `python3 -m venv ~/cs357/.venv`, `source ~/cs357/.venv/bin/activate`, then rerun the install and the script in that terminal; or use `uv` from Part 1.5, Step 3 |
| 4 | PowerShell: `Activate.ps1 cannot be loaded because running scripts is disabled on this system` | The default execution policy blocks the activation script | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` once, then rerun `.\.venv\Scripts\Activate.ps1` |
| 5 | `opencode` reports no provider or no models | Almost always the config **file name**: it must be `opencode.json`, not `config.json` | Fix the name, then check the location (`/workspace/opencode.json` in the container, `~/.config/opencode/opencode.json` natively), then check that the JSON parses with `python3 -m json.tool` |
| 5 | `opencode: command not found` inside the container | An older build of the course image, from before the agent was added | Rerun `docker compose build` from your `.devcontainer/` folder; cached layers make it quick |
| 5 | `opencode: command not found` on Route B, right after the installer succeeded | The installer put the binary in `~/.local/bin`, which is not on your `PATH` yet | `export PATH="$HOME/.local/bin:$PATH"` for this session, and add the same line to `~/.bashrc` to make it stick |
| 7 | `gh: command not found`, or `'gh' is not recognized` | Not installed, or the terminal predates the install | Install it from the 2a table, then open a new terminal.  Inside the course container it is already there; if it is not, your image predates this change and *Appendix: Updating Your Container* has the rebuild |
| 7 | `gh auth status` says you are not logged in, or a `gh` command returns 401 | The sign-in lapsed or the token expired | `gh auth login` signs you back in.  Tokens do expire, so expect this once or twice a semester rather than never |
| 7 | `gh issue create` or `gh pr create` returns 403 while `gh auth status` looks fine | The token authenticates but lacks that permission; A6's Contents-only scope does not cover issues or pull requests | `gh auth refresh -s <scope>` adds it, or edit the fine-grained token to include **Issues** and **Pull requests**, read and write.  A 403 is a permissions answer, not a sign-in problem, which is why the status looks healthy |
| 7 | You ran `gh auth login` at the container prompt | It works, and it puts a credential inside the filesystem that runs your agent code | Log out with `gh auth logout`, and pass `GH_TOKEN` in from your host shell instead, as A6 describes |
| 7 | `ssh-keygen` is not recognized on Windows | OpenSSH is not installed or the window predates it | Open a new PowerShell window; if it persists, install the GitHub CLI (Step 2a) and let `gh auth login` make the key, or install GitHub Desktop, which bundles Git for Windows |
| 7 | `git push` rejected, "authentication failed" | GitHub no longer accepts account passwords over HTTPS | `gh auth login` and then `gh auth setup-git` gives git a credential over HTTPS.  Or move the remote to SSH: `git remote set-url origin git@github.com:<user>/<repo>.git`.  A fine-grained token scoped to that one repository, with Contents: read and write, is the fallback if you must stay on HTTPS, and is the default inside the container (A6) |
| 7 | `git@github.com: Permission denied (publickey)` | The key is not loaded in the agent, or its public half was never added to GitHub | `gh auth status` tells you what `gh` thinks it has.  By hand: `ssh-add -l` lists loaded keys and `ssh-add ~/.ssh/id_ed25519` loads yours; confirm the contents of `id_ed25519.pub` appear under Settings -> SSH and GPG keys; then retest with `ssh -T git@github.com` |
| 7 | GitHub Desktop says authentication failed, or cannot push | Not signed in, or the repository exists on GitHub but was never published from Desktop | File > Options > Accounts, sign in with the browser, then Publish repository; if the repository already exists online, use Add local repository and set the remote under Repository > Repository settings |
| 8 | `uv: command not found` | Not installed, or not on `PATH` yet | Install it from the table in Part 1.5, Step 3 (`brew install uv` on a Mac with Homebrew, the `curl` or PowerShell installer elsewhere), then open a new terminal or run `source $HOME/.local/bin/env`; if it still fails, use the documented `python -m venv` fallback and say so |
| 8 | `brew install uv` says your macOS version is unsupported | Homebrew is older than your macOS | `brew update`, then rerun `brew install uv` |
| 8 | `uv add` complains that no `pyproject.toml` was found | You skipped `uv init` | Run `uv init` in the same directory, then rerun `uv add requests` |

---

## Self-Check Before You Submit

Hold your submission against the rubric's `proficient` column:

- [ ] One file, PDF or Markdown, with each component **clearly labeled**.
- [ ] Setup transcript covers all five steps, including the coding-agent check, and states your **OS and version numbers**.  On Route A, it also shows the container prompt and the A5 output.
- [ ] Transcript output is **copied verbatim**, not retyped or paraphrased.
- [ ] Any failure is quoted exactly, with a hypothesis and what you tried.
- [ ] Part 1.5: shell navigation and a search, a `gh auth status` block, a `git log --oneline` showing a pushed commit, and the uv (or documented fallback) output.
- [ ] Reflection has **four** labeled sections and is about a page.
- [ ] The reflection says what you actually think, not what you expect the course to want.
- [ ] Which route you took (A or B) is stated, and a Route A transcript shows the container prompt.
- [ ] Collaboration, AI-disclosure, and hours questions answered at the end.

---

## Deliverables

Submit a single PDF or markdown file containing:
- Your tool setup transcript (all five steps, including `opencode --version` and one answered prompt, plus version and OS info; on Route A, the container prompt and the A5 output as well)
- Your command-line and git checkpoint transcript (Part 1.5: navigation, `gh auth status`, git commit/push, uv environment)
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

> **Updating your container later.**  See [Updating Your Container]({{ site.baseurl }}/Tutorials/CourseContainer#appendix-updating-your-container).