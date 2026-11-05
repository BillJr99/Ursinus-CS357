---
layout: textbook
permalink: /Tutorials/CourseContainer
title: 'CS357: Foundations of Artificial Intelligence - The Course Container'
info:
  coursenum: CS357
  purpose: "The six steps that build the course container, and how to update it later."
  eyebrow: "Tutorial"
  numbering: false
tags:
- setup
- docker
---
*The six steps that build the course container, and how to update it later.*

This is Route A of the Overview assignment.  Do A1 through A6 once, on your host, and then return to the [Overview assignment]({{ site.baseurl }}/Assignments/Overview).  Every lab this semester runs in what you build here.  [Docker from Zero]({{ site.baseurl }}/Tutorials/Docker) explains what each piece is doing, and [Setup Basics]({{ site.baseurl }}/Tutorials/SetupBasics) has the terminal and token references.


## A1. Install Docker Desktop

| A1 at a glance | |
|---|---|
| **Where you type** | Your host terminal (PowerShell as Administrator for the Windows step) |
| **Route A** | Do it |
| **Route B** | Skip this whole section and go to Step 1 |
| **You paste** | The `Hello from Docker!` line |

If Docker is already on your machine from another course or project, skip to the verification at the end of A1.  If Docker cannot be installed on your machine at all (unsupported hardware, an administrator lock, or too little disk), take Route B now; nothing is wasted.

> **Disk note.**  Docker Desktop plus the course image (the ML libraries are hefty) needs roughly **8-10 GB** free, on top of Ollama's models.  Clear space now, not mid-download.

> **Windows only: install Ubuntu on WSL2 first.**  Docker Desktop on Windows does not run containers on Windows itself; it runs them inside **WSL2**, the Windows Subsystem for Linux.  Installing the Linux side first prevents most of the Windows trouble in this setup.  Open **PowerShell as Administrator** and run:
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

> **Troubleshooting:** `Cannot connect to the Docker daemon` means Docker Desktop is installed but not running; start the application and wait for the whale icon to settle.  `docker: command not found` inside Ubuntu, while Docker Desktop is plainly running, is the WSL Integration setting in the table above.  See the Stage A rows in the Overview assignment's Troubleshooting section.

**Next:** A2.

---

## A2. Create and clone your `cs357-work` repository

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

## A3. Add the course container files

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

Open the Dockerfile and *read it*; it is exactly the anatomy from Docker from Zero Section 5 (`FROM`, `ARG`, `RUN`, `ENV`, `WORKDIR`, `CMD`), and every `pip` line names its lab.  Then commit the files; they are part of your work:

```bash
git add .devcontainer
git commit -m "Add course dev container configuration"
```

**Paste.**  The `ls -la .devcontainer` listing and the `[main ...] Add course dev container configuration` line.

> **Troubleshooting:** `curl: command not found` on native Windows means you are in Command Prompt; use PowerShell or the Ubuntu terminal.  If `git commit` asks who you are, run `git config user.name "Your Name"` and `git config user.email "you@example.com"` in this folder and commit again; A6 says why per-repository is the right scope.

**Next:** A4.

---

## A4. Build and enter the container

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

**Paste.**  The container prompt.  Include it in every container transcript in the Overview, so it is visible where each command ran.

> **Troubleshooting:** a build that cannot find the Dockerfile is the `Dockerfile.txt` problem from A3, or you ran `docker compose` from somewhere other than `.devcontainer/`.  An empty `/workspace` on Windows means the clone lives somewhere Docker Desktop does not share; see the Stage A rows in the Overview assignment's Troubleshooting section.  A build that dies with a network error resumes from the failed step when you rerun `docker compose build`.

**Next:** A5.

---

## A5. Verify the tools inside the container

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
| optional | `node --version` | `v24.21.0` | The image pins an exact Node release, because promptfoo requires 22.22 or newer; worth running first whenever promptfoo misbehaves.  Not graded |
| optional | `herdr --version` | a version string | **herdr**, an agent-aware terminal multiplexer a later lab uses, is in the image too; this one is not graded |
| optional | `gh --version` | `gh version 2.x.x` | **gh**, the GitHub CLI the *Coding Agents* session runs its whole loop through, is in the image as well, so Route A has nothing to install.  Part 1.5, Step 2 is where it is graded, not here |

**Do.**  At the container prompt, the three graded checks, ready to paste:

```bash
promptfoo --version
python3 -c "import spacy; nlp = spacy.load('en_core_web_sm'); print('spacy OK:', nlp('Agents plan and act.')[0].pos_)"
opencode --version
```

**Paste.**  All three outputs, with the container prompt visible.

> **Troubleshooting.**
>
> - `ExperimentalWarning: DecompressInterceptor is experimental` above the promptfoo version is harmless noise from promptfoo's own dependencies, not a problem with your setup.  The version string underneath it is what counts.
> - If promptfoo refuses to start and says your Node.js is too old, your image predates the Node 24 update.  *Appendix: Updating Your Container* has the fix.
> - `command not found` for any of the three means an older build of the course image.  Rerun `docker compose build` from your `.devcontainer/` folder.
> - `permission denied` writing files in `/workspace` on a Linux host means the container's `student` user does not match your host UID.  Run the container with `docker compose run --rm --user "$(id -u):$(id -g)" cs357`.

**Next:** A6.

---

## A6. Git identity and a push credential inside the container

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
2.  Scope it tightly: *Only select repositories* -> `cs357-work`; Repository permissions -> **Contents: Read and write**; expiration at or beyond the end of the semester.  If you already know you will let an agent open issues or pull requests for you, which the *Coding Agents* session has you do two days from now, add **Issues: Read and write** and **Pull requests: Read and write** while you are here.  Adding them later means `gh auth refresh -s <scope>` or a new token, and the symptom that sends you looking is a bare 403.
3.  Copy the token (shown once).  When `git push` prompts for a password, paste the token.
4.  Cache it for a work session so you are not retyping:

```bash
git config credential.helper 'cache --timeout=7200'
```

> **The token you just made is now something you can leak.**  Keep it out of any message you send to a model, including the agent you are about to run in this container.  [Making a token, and putting it in your environment]({{ site.baseurl }}/Tutorials/SetupBasics#making-a-token-and-putting-it-in-your-environment) says what to do if it gets out.

**Do, `gh`.**  The image also carries `gh`, and it knows even less about you than git does.  Give it the token you just made, as an environment variable, from the host shell you start the container in:

```bash
export GH_TOKEN=github_pat_yourtokenhere      # on your host, before docker compose run
```

The `environment:` block in `docker-compose.yml` passes `GH_TOKEN` through by name, so the value stays in your shell and never enters a file.  [Making a token, and putting it in your environment]({{ site.baseurl }}/Tutorials/SetupBasics#making-a-token-and-putting-it-in-your-environment) is where the variable and its platform spellings live.  Confirm inside the container with `gh auth status`.

> **Do not run `gh auth login` in the container, and do not mount `~/.config/gh` into it.**  Both work, and both are the wrong shape here.  `gh auth login` stores a credential with whatever reach your account has, inside a filesystem that is about to run agent code; mounting your host `gh` configuration hands that same code the token that can push to every repository you own.  The variable above carries exactly one repository-scoped token and disappears when the container does, which is the A6 argument in one more place.

> **Note.**  `gh auth setup-git` makes `git push` over HTTPS use that same token, which replaces the credential-cache line above.  It is a fine trade on your host.  Inside the container, either works.

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

Return to the Overview's Route A checklist.  On Route A, Steps 1 through 3 run on your host, not in the container.


## Appendix: Updating Your Container

Working in a container means your environment is a file rather than a machine.  When a tool the course depends on changes underneath us, and sooner or later one always does, nobody has to reinstall anything by hand or compare laptops to work out whose setup drifted.  The Dockerfile in your repository *is* the environment, so a corrected Dockerfile plus a rebuild puts the whole class back on an identical, working stack.  When an update is announced, fetch the current file and rebuild:

```bash
cd ~/cs357-work/.devcontainer
curl -fsSL -o Dockerfile https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/files/devcontainer/Dockerfile
git add Dockerfile && git commit -m "Update course container"
docker compose build
docker compose run --rm cs357
```

You need that first `curl` because the Dockerfile lives in *your* repository, not in a registry somewhere, so rebuilding without fetching the new one just rebuilds the image you already have.

Expect the rebuild to take roughly as long as your original build did.  A change near the top of the file invalidates every layer beneath it, so the large library downloads run again.

If you work through VS Code Dev Containers, run **Dev Containers: Rebuild Container** from the command palette.  Plain **Reopen in Container** reuses the old image and will not pick up the change.

Once you are back at the container prompt, rerun the A5 checks to confirm the update landed, then run `docker image prune` to reclaim the disk the replaced image was still holding.
