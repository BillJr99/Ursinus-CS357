---
layout: textbook
permalink: /Tutorials/FullStackWithAgents
title: 'CS357: Foundations of Artificial Intelligence - From Requirements to Deployment with a Coding Agent'
info:
  coursenum: CS357
  purpose: "To take one small full-stack app from a conversation about requirements to a tested, reviewed, continuously integrated deployment on Cloudflare, built by a coding agent inside a container, with a human deciding at every gate."
  eyebrow: "Tutorial"
  numbering: false
tags:
- agentic-development
- opencode
- oh-my-pi
- cloudflare
- testing
- ci
---
## About This Tutorial

Ask a coding agent to "build me a questions board for class" and it will. It will pick the database, the fields, the length limit, and what happens when two people vote at once, and it will hand you a working app that answers questions nobody asked it. The code is rarely the problem. The problem is that every decision got made without you.

This tutorial builds one small app the other way around. You decide what it should do, the agent asks you about everything you left out, the agent writes each piece test first while you watch, a reviewer skill checks the result, GitHub runs the tests on every push, and nothing reaches the internet until you approve it. The app is a **Questions Board**: students post a question during class, upvote the ones they want answered, and the most-wanted question rises to the top. It has a web page, an API, and a database, and it runs on Cloudflare's free tier.

The path runs **a workbench (a container that sees one folder) → requirements (a charter, an interview, a spec) → building one slice at a time (red, then green) → review and refactoring → a clean test and continuous integration → a gated deploy → teardown**. Everything works with either of the two coding agents this course uses, **OpenCode** and **Oh My Pi**, and the places where they differ are called out where they matter.
{: .tb-lede}

## Key Concepts

| Term | Plain-English Definition | Where You'll Meet It |
|------|--------------------------|----------------------|
| **Human in the loop** | A person approves each step that matters before it happens, rather than reviewing the result afterward | The agent stops after every slice and waits for you; deploy and teardown never run without your yes |
| **Project charter** | A one-page agreement on what the project is for, who it serves, what is out of scope, and who decides what | `CHARTER.md`, written before any code, and read by the agent first |
| **`AGENTS.md`** | The always-on instructions both agents read at the start of every session in a project | The loop, the commands, and the rules (for example, delete files only with `git rm`) |
| **Grilling** | An interview in which the agent asks you numbered questions, one round at a time, until every decision has an answer | Matt Pocock's `grilling` skill turns "build me a questions board" into `docs/spec.md` |
| **Seam** | The public boundary a test checks behavior at, without reaching inside | Here, the Worker's `fetch` handler, called the way a browser calls it |
| **Red, then green** | Write one test, watch it fail (red), write the least code that makes it pass (green), repeat | The `tdd` skill's loop, one slice at a time |
| **Cloudflare Worker** | A function that runs on Cloudflare's network in response to web requests | `src/index.js` answers `/api/*` |
| **D1** | Cloudflare's SQLite database, bound to a Worker by name | `env.DB` in the Worker; the table comes from `migrations/0001_create_questions.sql` |
| **Workers Assets** | Static files (HTML, CSS, images) served from the same Worker | `public/index.html` is the page |
| **Migration** | A numbered SQL file that changes the database schema; you add new ones and never edit old ones | `npx wrangler d1 migrations apply DB --local` (your copy) or `--remote` (the real one) |
| **Continuous integration (CI)** | A service that runs your tests on every push and pull request, on a clean machine | `.github/workflows/ci.yml` on GitHub Actions |
| **Environment protection** | A GitHub setting that pauses a workflow until a named reviewer approves it | The `production` environment that the deploy workflow waits on |
| **Teardown** | Deleting everything a deployment created, on purpose and in order | The `cloudflare-teardown` skill: the Worker, then the database |

### Before You Start

- Docker, and the [Docker tutorial]({{ site.baseurl }}/Tutorials/Docker) behind you.
- Git and a GitHub account.
- A model your agent can use: an OpenRouter key, or one of the providers from [OpenCode Setup]({{ site.baseurl }}/Tutorials/OpenCodeSetup).
- A free Cloudflare account, but only for Part IV. Everything before that runs on your own machine with no account at all.
- Helpful background, which this page links instead of repeating: [Agent Skills]({{ site.baseurl }}/Tutorials/AgentSkills), [Container Isolation]({{ site.baseurl }}/Tutorials/ContainerIsolation), and [Hosting with Cloudflare]({{ site.baseurl }}/Tutorials/Cloudflare).

## The Loop, and Who Decides

Every step below has an owner. The agent does most of the typing, and you make every decision that changes what the app is or where it lives.

| Step | The agent | You |
|---|---|---|
| Charter | Reads it | Write it |
| Interview | Asks questions, recommends answers | Answer, and approve `docs/spec.md` |
| Seams | Proposes which interfaces get tested | Agree or change them |
| Each slice | Writes a failing test, shows it failing, makes it pass | Read the test and the diff; say "next" |
| Review | Runs the review skill, proposes refactors | Accept or reject each one |
| Pull request | Opens it | Merge only when CI is green |
| Deploy | Shows the exact commands | Approve the run |
| Teardown | Shows what will be deleted | Approve each deletion |

> The point of the table is not that the agent is untrustworthy. It is that a decision you never saw is a decision you cannot defend: to a teammate, to a community partner, or to yourself in two weeks when the app does something surprising.  Iterating in small slices keeps each decision small enough to actually read.
{: .tb-key data-title="Why this matters"}

---

# Part I: The Workbench

## 1.  A Folder and a Repository

Everything this project is lives in one folder, under git from the first minute:

```bash
mkdir questions-board && cd questions-board
git init -b main
```

Create an empty private repository on GitHub named `questions-board` and connect it (`git remote add origin ...`), but don't push yet; there is nothing to push.

## 2.  The Dev Container: Both Agents, One Folder

The agent runs inside a container that can see this one folder and nothing else on your machine. [Container Isolation]({{ site.baseurl }}/Tutorials/ContainerIsolation) explains each flag; this box adds what a web project needs: Node 22 (Wrangler requires 22.12 or newer), git, OpenCode, and Oh My Pi, at pinned versions.

Save this as `devbox/Dockerfile`:

```dockerfile
# The dev container: Node 22 (for Wrangler), git, OpenCode, and Oh My Pi. It sees one folder.
FROM node:22-bookworm
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*
# Pinned versions, so the box you build next month behaves like the one in the tutorial.
RUN npm install -g --no-audit --no-fund opencode-ai@1.19.5 bun@1.4.4
RUN BUN_INSTALL=/opt/omp bun install -g "@oh-my-pi/pi-coding-agent@18.20.0" \
 && ln -sfn /opt/omp/install/global/node_modules/@oh-my-pi/pi-coding-agent/dist/cli.js /usr/local/bin/omp \
 && chmod -R a+rX /opt/omp
RUN mkdir -p /work && chmod 777 /work
WORKDIR /work
CMD ["bash"]
```

Save this as `devbox/devbox.sh`, and make it executable with `chmod +x devbox/devbox.sh`:

```bash
#!/usr/bin/env bash
# devbox.sh: open the project in the dev container. Usage, from the project folder:
#   devbox/devbox.sh            a shell
#   devbox/devbox.sh opencode   OpenCode
#   devbox/devbox.sh omp        Oh My Pi
# The container sees only this folder (at /work). Pass a model key and, only when you
# mean to deploy, Cloudflare credentials, through the environment: e.g.
#   OPENROUTER_API_KEY=... devbox/devbox.sh opencode
set -euo pipefail
cd "$(dirname "$0")/.."
docker build -q -t cs357-devbox devbox >/dev/null
pass=()
for v in OPENROUTER_API_KEY ANTHROPIC_API_KEY OPENAI_API_KEY CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID; do
  if [ -n "${!v:-}" ]; then pass+=(-e "$v"); fi
done
exec docker run --rm -it --read-only \
  --tmpfs /tmp:exec --tmpfs /home/dev:exec,mode=1777 \
  --cap-drop=ALL --security-opt no-new-privileges --pids-limit 512 --memory 2g \
  --user "$(id -u):$(id -g)" -e HOME=/home/dev \
  -e GIT_AUTHOR_NAME="$(git config user.name)" -e GIT_AUTHOR_EMAIL="$(git config user.email)" \
  -e GIT_COMMITTER_NAME="$(git config user.name)" -e GIT_COMMITTER_EMAIL="$(git config user.email)" \
  "${pass[@]}" -p 127.0.0.1:8787:8787 \
  -v "$PWD:/work" -w /work cs357-devbox "$@"
```

Then open a shell in the box and check what is installed:

```bash
devbox/devbox.sh
node --version; git --version; opencode --version; omp --version
```

> **You should see** `v22.23.5`, `git version 2.39.5`, `1.19.5`, and `omp/18.20.0` (newer patch versions of Node are fine).  Type `exit` to leave.

A few things about this box are worth noticing before an agent ever runs in it:

- **One folder.** Your project is mounted at `/work`. Your home directory, your SSH keys, and every other project are not in the container at all.
- **Your user, not root.** Files the agent creates belong to you on the host, and it cannot install system software while it runs (`--cap-drop=ALL`, `no-new-privileges`, a read-only root filesystem).
- **No Docker inside.** The agent cannot start containers of its own, which is why the clean-test skill in Part IV has a fallback for inside the box.
- **Secrets only when you pass them.** `devbox.sh` forwards a model key and Cloudflare credentials only if they are set when you start it. Anything you pass, the agent can read; leave the Cloudflare ones out until you mean to deploy.
- **Port 8787** is forwarded to your machine's `localhost` only, so you can open the app in your browser while the agent runs it.

## 3.  Two Agents, One Project

Both agents read the same context file and the same skills folder, so one set of project files works in either. They differ in where permissions live and in how a rule list is read.

| | OpenCode | Oh My Pi |
|---|---|---|
| Start it in the box | `devbox/devbox.sh opencode` | `devbox/devbox.sh omp` |
| Always-on instructions | `AGENTS.md` | `AGENTS.md` |
| Project skills | `.agents/skills/<name>/SKILL.md` | `.agents/skills/<name>/SKILL.md` |
| Use a skill | Name it in your prompt: "use the grilling skill" | The same, or type `/skill:grilling` |
| Permission file | `opencode.json` | `.omp/config.yml` |
| Which rule wins | The **last** rule that matches | The **first** rule that matches |
| Default when nothing matches | What `"*"` says (here: ask) | What `tools.approvalMode` says (here: `always-ask`) |
| Check what it loaded | `opencode debug config`, `opencode debug skill` | `omp config list --scope=project`, `omp skill list` |
{: .tb-full}

> The same list of rules does opposite things in the two agents.  In `opencode.json` a broad `"git *": "allow"` goes first and the narrower `"git push *": "ask"` after it, because the last match wins.  In `.omp/config.yml` the narrow rule must come first, because the first match wins.  When you port a permission block from one agent to the other, reverse it and test it.
{: .tb-warning data-title="Watch out"}

## 4.  Permissions: Git Yes, `rm` No

The agent may change files, but every move and delete has to go through git, so `git status` shows it and `git restore` can undo it. `git mv` and `git rm` are allowed with the rest of git; plain `mv`, `rm`, and `rmdir` are refused. Deploying, deleting anything on Cloudflare, and pushing always ask.

Save this as `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "*": "ask",
    "read": "allow",
    "edit": "ask",
    "external_directory": "deny",
    "skill": { "*": "allow" },
    "bash": {
      "*": "ask",
      "git *": "allow",
      "git push *": "ask",
      "npm test*": "allow",
      "npx vitest *": "allow",
      "npm ci": "allow",
      "ls *": "allow",
      "cat *": "allow",
      "rm *": "deny",
      "mv *": "deny",
      "rmdir *": "deny",
      "npx wrangler deploy*": "ask",
      "npx wrangler delete*": "ask",
      "npx wrangler d1 delete*": "ask"
    }
  }
}
```

And this as `.omp/config.yml`:

```yaml
# Oh My Pi project settings. Same intent as opencode.json, written for Oh My Pi's rules:
# the FIRST matching pattern wins here (opencode uses the LAST), so denials come first.
tools:
  approvalMode: always-ask
bash:
  patterns:
    - { match: "rm *", approval: deny }
    - { match: "mv *", approval: deny }
    - { match: "rmdir *", approval: deny }
    - { match: "npx wrangler deploy*", approval: prompt }
    - { match: "npx wrangler delete*", approval: prompt }
    - { match: "npx wrangler d1 delete*", approval: prompt }
    - { match: "git push *", approval: prompt }
    - { match: "git *", approval: allow }
    - { match: "npm test*", approval: allow }
    - { match: "npx vitest *", approval: allow }
    - { match: "npm ci", approval: allow }
```

**Predict, then try.** Start either agent in the box and ask it to delete a scratch file with `rm`, then with `git rm`. Which one runs without asking? What does the agent do when a command is refused?

> A permission rule matches the command text, not the intent.  `find . -delete` and `node -e "require('fs').rmSync(...)"` delete files without ever typing `rm`, so `"*": "ask"` (OpenCode) and `always-ask` (Oh My Pi) are what catch them.  The container is the backstop behind both: the worst a confused agent can do is damage this one folder, and git can put that back.
{: .tb-warning data-title="Watch out"}

---

# Part II: Requirements Before Code

## 5.  The Charter

Write the charter yourself. It is short on purpose: what the app is for, who it serves, what "done" means, what is out of scope, and who decides what. Save it as `CHARTER.md`:

```markdown
# Project Charter: Questions Board

## Purpose

A small web page where a class posts questions during a session and upvotes the ones it most wants answered, so the instructor can take the most-wanted question first.

## Users

- **Students** post a question and upvote others. No sign-in.
- **The instructor** reads the list, most upvoted first.

## Success criteria

1. A question posted on one device appears on another after a refresh.
2. The list is ordered by votes, then by age.
3. Every behavior above has a test, and the tests pass in CI on every push.
4. The app deploys to Cloudflare with one approved workflow run, and tears down with one command.

## Scope

In: posting, listing, upvoting, one page, one database table.

Out (non-goals): accounts, editing or deleting questions, moderation, real-time updates. Each is a reasonable next step and none is part of this charter.

## Constraints

- Cloudflare free tier only: one Worker, one D1 database.
- No personal data. Questions are anonymous and the page says so.
- Every change goes through a pull request with green CI before it reaches `main`.

## Roles and decision rights

| Who | Decides | Never does |
|---|---|---|
| **You (the human)** | What to build, the spec, which tests matter, whether to merge, deploy, or tear down | Hand the agent a token it doesn't need |
| **The coding agent** | How to make the next failing test pass, inside the rules in `AGENTS.md` | Deploy, tear down, push to `main`, or delete files without your explicit yes |

## Definition of done for each slice

A failing test came first, it passes now, the whole suite passes, the change is committed with a message that says why, and you have read the diff.

## Risks

| Risk | What we do about it |
|---|---|
| The agent builds something other than what you meant | Run the grilling interview first; write the answers into `docs/spec.md` |
| Tests that pass by construction | The `tdd` skill's rules: expected values come from the spec, not from the code |
| A leaked Cloudflare token | A scoped token, stored only as a GitHub secret or passed to one container run; never in a file |
| A forgotten deployment | The teardown skill, and a check of the dashboard afterward |
```

> The non-goals line is the one students skip and the one that saves the most time.  An agent that knows "no accounts, no editing, no real-time updates" stops proposing them.  The roles table is what makes the rest of this tutorial enforceable: it is the agent's written job description.
{: .tb-key data-title="Why this matters"}

## 6.  `AGENTS.md`: The Loop, Written Down

`AGENTS.md` turns the loop above into instructions both agents read every session. Save it at the root of the project:

```markdown
# AGENTS.md: Questions Board

Read `CHARTER.md` first. It says what this app is for and what you may and may not decide.

## How we work: one slice at a time, a human at every gate

1. **Interview before building.** For a new feature, run the `grilling` skill (or `/grill-me`). Write the agreed behavior into `docs/spec.md` and stop for the human to approve it.
2. **Agree the seams.** Propose which public interfaces get tested and wait for a yes (the `tdd` skill requires this).
3. **Red, then green, one slice at a time.** Write one failing test, run it and show it failing, write the least code that passes it, run the whole suite. Then stop and summarize the slice for the human.
4. **Commit each green slice** with a message that says why. Small commits are the undo button.
5. **Review, then refactor.** After a few slices, or before a pull request, run the `code-review` skill against `main`. Refactor only with the suite green before and after; use `improve-codebase-architecture` for anything bigger than a rename.
6. **CI decides.** Push a branch and open a pull request; `.github/workflows/ci.yml` must pass before merging. Never push to `main` yourself.
7. **Deploy and tear down only on an explicit yes**, with the `cloudflare-deploy` and `cloudflare-teardown` skills.

## Commands

| What | Command |
|---|---|
| Install dependencies | `npm ci` |
| Run the tests | `npm test` |
| Run one test file | `npx vitest run test/api.test.js` |
| Run locally | `npm run db:local && npx wrangler dev --ip 0.0.0.0` |
| Test in a clean throwaway container | the `docker-test` skill |

## Rules

- Files: create and edit them with your edit tool. Move or delete a tracked file only with `git mv` or `git rm`, so every change shows up in `git status` and can be undone. Plain `rm`, `mv`, and `rmdir` are denied.
- Never write a token, key, or password into any file, commit, or log. Cloudflare credentials arrive only as the environment variables `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`.
- Never weaken a test to make it pass. If a test is wrong, say so and ask.
- Stay inside this folder.

## Where things are

- Spec: `docs/spec.md`. Decisions: `docs/adr/`. Issues: `docs/issues/` (local Markdown files; this is the issue tracker the Pocock skills ask about). Domain words: `GLOSSARY.md`.
- Coding standards: plain JavaScript modules, no build step, no dependencies beyond those in `package.json`. SQL lives in the Worker next to the route that uses it; schema changes are new files in `migrations/`, never edits to old ones.
```

Two small files go with it. The skills below expect a glossary of the project's words and a place to record decisions:

```markdown
# Glossary

- **Question**: one anonymous post, 1 to 280 characters.
- **Vote**: one upvote on a question. Votes only go up.
- **Board**: the list of all questions, most voted first, ties by age.
```

```bash
mkdir -p docs/adr docs/issues
```

## 7.  Skills: Borrowed and Written

Skills are directories under `.agents/skills/`, so both agents find them (see [Agent Skills]({{ site.baseurl }}/Tutorials/AgentSkills) for how loading works). This project uses six from Matt Pocock's [skills repository](https://github.com/mattpocock/skills) (MIT licensed) and three it writes for itself.

| Skill | From | What it does here |
|---|---|---|
| `grilling` | Pocock | Interviews you in rounds of numbered questions, each with a recommended answer, until every decision is settled |
| `grill-me` | Pocock | A one-line shortcut that starts `grilling` |
| `tdd` | Pocock | The red-then-green loop: agree the seams, one test at a time, no tests that pass by construction |
| `code-review` | Pocock | Reviews a branch two ways, against your standards (with Fowler's code smells as a baseline) and against the spec |
| `improve-codebase-architecture` | Pocock | Looks for refactors that make modules deeper and easier to test, then interviews you about the one you pick |
| `codebase-design` | Pocock | The shared vocabulary (module, interface, depth, seam) the other skills use |
| `cloudflare-deploy` | This project | Installs and checks Wrangler, gates on tests and credentials, deploys only on your yes |
| `cloudflare-teardown` | This project | Deletes the Worker and the database, in order, each on your yes |
| `docker-test` | This project | Runs the suite from a fresh copy of the committed code in a throwaway container |
{: .tb-full}

**Install Pocock's skills, pinned.** Copy them at one commit rather than "latest", so the skill you read is the skill that runs. Read each `SKILL.md` before you trust it; they are instructions your agent will follow.

```bash
P=https://raw.githubusercontent.com/mattpocock/skills/5863806dd4e15c63174bee4e7515a4256792ecfa
for f in productivity/grilling/SKILL.md productivity/grill-me/SKILL.md \
         engineering/tdd/SKILL.md engineering/tdd/tests.md engineering/tdd/mocking.md \
         engineering/code-review/SKILL.md \
         engineering/codebase-design/SKILL.md engineering/codebase-design/DEEPENING.md engineering/codebase-design/DESIGN-IT-TWICE.md \
         engineering/improve-codebase-architecture/SKILL.md engineering/improve-codebase-architecture/HTML-REPORT.md; do
  d=.agents/skills/$(basename "$(dirname "$f")")
  mkdir -p "$d" && curl -fsSL "$P/skills/$f" -o "$d/$(basename "$f")"
done
curl -fsSL "$P/LICENSE" -o .agents/skills/LICENSE-mattpocock-skills.txt
```

Pocock's own installer (`npx skills@latest add mattpocock/skills -a opencode`) does the same job and keeps the skills updatable; the loop above trades updates for knowing exactly what you installed. Some of his skills mention running `/setup-matt-pocock-skills` to choose an issue tracker. You don't need it here: `AGENTS.md` already tells them the tracker is `docs/issues/`.

**Write the three project skills.** Save each file at the path in its heading.

`.agents/skills/cloudflare-deploy/SKILL.md`:

```markdown
---
name: cloudflare-deploy
description: Install Wrangler and deploy this app to Cloudflare Workers with its D1 database. Use when the user asks to deploy, publish, ship, go live, or put the app on Cloudflare, or asks to install or check the Cloudflare tools.
---

# Deploy to Cloudflare

Deploying changes something outside this folder that strangers can reach. Every step that touches Cloudflare needs the human's explicit yes in this conversation, given after you have shown exactly what will run.

## 1. Tools (safe to run without asking)

Run `bash .agents/skills/cloudflare-deploy/scripts/check-tools.sh`. It checks Node (Wrangler needs 22.12 or newer), installs the project's pinned Wrangler with `npm ci` when `node_modules` is missing, and prints `npx wrangler --version`. If Node is missing or too old, stop and tell the human; do not install Node yourself.

## 2. Gate: tests and credentials

- Run `npm test`. If anything fails, stop. A red suite is never deployed.
- Check that `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are set **without printing them**: `test -n "$CLOUDFLARE_API_TOKEN" && test -n "$CLOUDFLARE_ACCOUNT_ID" && echo "credentials present"`. If either is missing, stop and ask the human to start the session with them. Never ask the human to paste a token into the chat, and never write one to a file.
- Run `npx wrangler whoami` to confirm the token works.

## 3. First deploy only: create the database

If `wrangler.jsonc` still has the all-zero `database_id`:

1. Show the human: `npx wrangler d1 create questions-board`. Wait for yes.
2. Copy the `database_id` it prints into `wrangler.jsonc` (edit tool), and commit with `git commit -am "Point at the real D1 database"`.

## 4. Deploy (ask first, every time)

Show the human these two commands and what each does, then wait for yes:

```bash
npx wrangler d1 migrations apply DB --remote   # creates or updates the table in the real database
npx wrangler deploy                            # uploads the Worker and the page
```

## 5. Check it, and report

`curl -s https://<the URL wrangler printed>/api/questions` should print `[]` (or the live questions). Report the URL, the Wrangler version, and the commit that was deployed. Remind the human that `cloudflare-teardown` removes everything.

## Prefer the pipeline

For a team project, deploy through the `Deploy` workflow in `.github/workflows/deploy.yml` instead: it runs the same steps after a reviewer approves the run in GitHub, and the token lives only in GitHub's secret store.
```

`.agents/skills/cloudflare-deploy/scripts/check-tools.sh`:

```bash
#!/usr/bin/env bash
# Checks Node, installs the project's pinned Wrangler if needed, and prints the versions.
set -euo pipefail
if ! command -v node >/dev/null; then echo "Node.js is not installed. Wrangler needs Node 22.12 or newer." >&2; exit 1; fi
need=22.12.0
have=$(node -p 'process.versions.node')
if [ "$(printf '%s\n%s\n' "$need" "$have" | sort -V | head -1)" != "$need" ]; then
  echo "Node $have is too old; Wrangler needs $need or newer." >&2; exit 1
fi
[ -d node_modules/wrangler ] || npm ci --no-audit --no-fund
echo "node $have"
npx wrangler --version
```

`.agents/skills/cloudflare-teardown/SKILL.md`:

```markdown
---
name: cloudflare-teardown
description: Remove this app's Worker and D1 database from Cloudflare. Use when the user asks to tear down, take down, delete, remove, or clean up the deployment, or to stop paying for or exposing the app.
---

# Tear down the Cloudflare deployment

Teardown deletes the live app and every question stored in its database. It cannot be undone. Ask before each step, and show the exact command.

1. Confirm the credentials are present without printing them: `test -n "$CLOUDFLARE_API_TOKEN" && test -n "$CLOUDFLARE_ACCOUNT_ID" && echo "credentials present"`.
2. Show what exists: `npx wrangler deployments list` (it reads the Worker name from `wrangler.jsonc`), `npx wrangler d1 list`, and the preview `npx wrangler delete --name questions-board --dry-run`. Tell the human what will be deleted.
3. Offer a backup of the questions first: `npx wrangler d1 export questions-board --remote --output=questions-backup.sql`. The backup file is data; do not commit it.
4. After a yes, delete the Worker: `npx wrangler delete --name questions-board`.
5. After a second yes, delete the database: `npx wrangler d1 delete questions-board`.
6. Check: `npx wrangler d1 list` no longer shows it, and the old URL no longer answers. Set `database_id` in `wrangler.jsonc` back to all zeros and commit, so the next deploy creates a fresh database.

Stop at the first error and report it. Never delete anything this skill does not name.
```

`.agents/skills/docker-test/SKILL.md`, with its two scripts:

```markdown
---
name: docker-test
description: Run the whole test suite in a clean, throwaway container from a fresh copy of the committed project. Use before opening a pull request, before deploying, or when the user asks for a clean, isolated, or reproducible test run, or says "it works on my machine".
---

# Test in a throwaway container

A clean run catches what a long working session hides: a file you forgot to commit, a package you installed by hand, a test that passes only because of leftover local data.

- **With Docker available** (your own machine): `bash .agents/skills/docker-test/scripts/test-in-docker.sh`. It copies the committed files (`git archive HEAD`) into a new `node:22-bookworm` container, runs `npm ci` and `npm test`, and deletes the container afterward. Uncommitted changes are deliberately left out, so commit first.
- **Inside the dev container** (no Docker there, on purpose): `bash .agents/skills/docker-test/scripts/test-clean-copy.sh`, which does the same from a fresh copy under `/tmp`.

Report the pass and fail counts. If the clean run fails and your normal run passes, find out what the difference is before doing anything else.
```

```bash
#!/usr/bin/env bash
# Runs the committed project's tests in a throwaway container. Nothing is left behind.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git archive --format=tar HEAD | docker run --rm -i node:22-bookworm bash -c \
  'mkdir /app && cd /app && tar -x && npm ci --no-audit --no-fund >/dev/null && npm test'
```

```bash
#!/usr/bin/env bash
# The same clean run without Docker: a fresh copy of the committed project under /tmp.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
dir=$(mktemp -d)
trap 'cd /; chmod -R u+w "$dir"; command rm -rf "$dir"' EXIT
git -C "$root" archive --format=tar HEAD | tar -x -C "$dir"
cd "$dir" && npm ci --no-audit --no-fund >/dev/null && npm test
```

Make the scripts executable (`chmod +x .agents/skills/*/scripts/*.sh`), then commit everything so far:

```bash
git add -A && git commit -m "Charter, agent instructions, permissions, and skills"
```

**Check that both agents see all nine.** In the box, `opencode debug skill` and `omp skill list` should each list `grilling`, `grill-me`, `tdd`, `code-review`, `improve-codebase-architecture`, `codebase-design`, `cloudflare-deploy`, `cloudflare-teardown`, and `docker-test` (OpenCode adds a built-in `customize-opencode` of its own).

## 8.  The Interview

Start your agent in the box and give it the one-line idea, then hand it to the interview:

```text
I want a questions board for class: students post questions and upvote them, most
votes on top. Read CHARTER.md and AGENTS.md, then use the grilling skill to interview
me until we agree on exactly what to build. Write the result to docs/spec.md and stop.
```

The first round looks something like this (the wording varies by model):

```text
❓ Q1 - Question length: Should questions have a maximum length? A limit keeps the
   board readable and the database small.
➡️ Yes, 280 characters, and refuse empty ones.

❓ Q2 - Ordering: When two questions have the same votes, which comes first?
➡️ The older one, so early questions are not buried.

❓ Q3 - Repeat votes: Can one person upvote the same question twice? Preventing it
   needs some notion of identity, which the charter rules out.
➡️ Allow it for now; record "one vote per person" as a possible next charter.
```

Answer each one; "yes" accepts the recommendation. The next round asks only what your answers just unblocked. The interview is over when the agent has nothing left to ask, and then it writes the spec. Here is the one this tutorial built:

```markdown
# Spec: Questions Board

Written from the grilling session; the human approved it before any code.

## Behaviors

1. `GET /api/questions` returns every question as JSON: `id`, `text`, `votes`, `created_at`, ordered by votes (highest first), then by id (oldest first).
2. `POST /api/questions` with `{"text": "..."}` trims the text and stores it with 0 votes. It answers `201` with the stored question.
3. Text that is empty after trimming, or longer than 280 characters, is refused with `400` and an `error` message.
4. `POST /api/questions/<id>/upvote` adds one vote and answers with the updated question, or `404` if there is no such question.
5. Any other `/api/` path answers `404` with JSON. Everything outside `/api/` is the static page.

## Seams under test

The Worker's `fetch` handler, called the way a browser would call it. Tests never query the database directly to check a result.
```

**Read the spec before you approve it.** It is the contract every test in Part III comes from. Commit it, and record any decision worth remembering as an ADR. This project recorded one, the choice of database:

```markdown
# ADR 0001: Store questions in Cloudflare D1, not Supabase

**Status:** accepted

**Context.** The app needs one small table. Supabase (hosted Postgres with an HTTP API) and Cloudflare D1 (SQLite next to the Worker) both have free tiers.

**Decision.** D1. It is configured in the same `wrangler.jsonc`, deploys and tears down with the same tool, and runs locally inside the tests with no account or network.

**Consequences.** Supabase would add a second account, a second secret (`wrangler secret put SUPABASE_KEY`), and tests that need a mock or a live project. If the app later needs Postgres features or row-level security, revisit this.
```

---

# Part III: One Slice at a Time

## 9.  The Scaffold

Some files are configuration, not behavior, and it is fine for you or the agent to write them directly. Ask the agent to create them, or save them yourself:

`package.json` pins every tool, so the box, your laptop, and CI run the same versions:

```json
{
  "name": "questions-board",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "wrangler dev",
    "test": "vitest run",
    "db:local": "wrangler d1 migrations apply DB --local",
    "db:remote": "wrangler d1 migrations apply DB --remote",
    "deploy": "wrangler deploy"
  },
  "devDependencies": {
    "@cloudflare/vitest-plugin": "1.8.1",
    "vitest": "5.1.0",
    "wrangler": "4.161.0"
  }
}
```

`wrangler.jsonc` describes the Worker, the page, and the database binding:

```jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "questions-board",
  "main": "src/index.js",
  "compatibility_date": "2026-11-01",
  // The page in public/ is served as static files; only /api/* reaches the Worker code.
  "assets": { "directory": "./public", "binding": "ASSETS", "run_worker_first": ["/api/*"] },
  "d1_databases": [
    {
      "binding": "DB",
      "database_name": "questions-board",
      // Replaced by the cloudflare-deploy skill with the id that `wrangler d1 create` prints.
      "database_id": "00000000-0000-0000-0000-000000000000",
      "migrations_dir": "migrations"
    }
  ]
}
```

`migrations/0001_create_questions.sql`, the schema, with the length rule enforced by the database too:

```sql
CREATE TABLE questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  text TEXT NOT NULL CHECK (length(text) BETWEEN 1 AND 280),
  votes INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

`vitest.config.js` and `test/apply-migrations.js` run the tests inside the real Workers runtime, with a fresh local D1 that has the same migrations applied. (Cloudflare renamed this test package in 2026: it is now `@cloudflare/vitest-plugin`, and older guides still say `@cloudflare/vitest-pool-workers`.)

```js
import path from "node:path";
import { cloudflareTest, readD1Migrations } from "@cloudflare/vitest-plugin";
import { defineConfig } from "vitest/config";

export default defineConfig(async () => {
  // The same migrations the deploy applies, so tests run against the real schema.
  const migrations = await readD1Migrations(path.join(import.meta.dirname, "migrations"));
  return {
    plugins: [
      cloudflareTest({
        wrangler: { configPath: "./wrangler.jsonc" },
        miniflare: { bindings: { TEST_MIGRATIONS: migrations } },
      }),
    ],
    test: { setupFiles: ["./test/apply-migrations.js"] },
  };
});
```

```js
import { applyD1Migrations } from "cloudflare:test";
import { env } from "cloudflare:workers";

// Safe to run more than once: only migrations not yet applied are run.
await applyD1Migrations(env.DB, env.TEST_MIGRATIONS);
```

`.gitignore`:

```text
node_modules/
.wrangler/
.dev.vars
```

Then install, which also writes `package-lock.json`, and commit the lock file:

```bash
npm install
git add -A && git commit -m "Scaffold: Worker config, schema, test runner"
```

## 10.  Red, Then Green

Now the agent builds behavior, and the `tdd` skill sets the rhythm. Prompt it:

```text
Use the tdd skill. Propose the seams from docs/spec.md and wait for me. Then build
behavior 1 only: write one failing test, run it, show me the failure, then write the
least code that passes. Stop after the slice.
```

It should propose one seam, the Worker's `fetch` handler, and wait. After your yes, each slice follows the same shape. Here is what a red run looks like, from the slice that adds upvoting, before the route exists:

```text
     ✓ starts with no questions
     ✓ adds a question and lists it
     ✓ refuses an empty question and one over 280 characters
     × lists the most upvoted question first
     ✓ answers 404 for a question that does not exist
 FAIL  test/api.test.js > questions board API > lists the most upvoted question first
AssertionError: expected undefined to be 1 // Object.is equality
      Tests  1 failed | 4 passed (5)
```

**Look closely at the last passing test.** "Answers 404 for a question that does not exist" passed *before the upvote route existed*, because any unknown path already answers 404. **What does that test prove, and what doesn't it?** This is why the loop insists on watching each new test fail first: a test that has never been red has never shown that it can catch anything.

After every green slice, the agent stops. Read the test and the diff, then say "commit it and do the next behavior." Five slices later, the suite and the Worker look like this:

```js
import { env, exports } from "cloudflare:workers";
import { beforeEach, describe, it, expect } from "vitest";

const api = (path, init) => exports.default.fetch(`https://board.test${path}`, init);
const ask = (text) => api("/api/questions", {
  method: "POST",
  headers: { "content-type": "application/json" },
  body: JSON.stringify({ text }),
});

describe("questions board API", () => {
  // Each test starts from an empty board, so no test depends on another one running first.
  beforeEach(async () => {
    await env.DB.exec("DELETE FROM questions");
  });

  it("starts with no questions", async () => {
    const r = await api("/api/questions");
    expect(r.status).toBe(200);
    expect(await r.json()).toEqual([]);
  });

  it("adds a question and lists it", async () => {
    const created = await ask("  What is a Worker?  ");
    expect(created.status).toBe(201);
    expect(await created.json()).toMatchObject({ text: "What is a Worker?", votes: 0 });
    const listed = await (await api("/api/questions")).json();
    expect(listed.map((q) => q.text)).toEqual(["What is a Worker?"]);
  });

  it("refuses an empty question and one over 280 characters", async () => {
    expect((await ask("   ")).status).toBe(400);
    expect((await ask("x".repeat(281))).status).toBe(400);
    expect((await ask("x".repeat(280))).status).toBe(201);
  });

  it("lists the most upvoted question first", async () => {
    const first = await (await ask("first")).json();
    const second = await (await ask("second")).json();
    const voted = await api(`/api/questions/${second.id}/upvote`, { method: "POST" });
    expect((await voted.json()).votes).toBe(1);
    const listed = await (await api("/api/questions")).json();
    expect(listed.map((q) => q.id)).toEqual([second.id, first.id]);
  });

  it("answers 404 for a question that does not exist", async () => {
    expect((await api("/api/questions/999/upvote", { method: "POST" })).status).toBe(404);
  });
});
```

```js
// The Questions Board API. Static files in public/ are served by Workers Assets; this code
// answers only /api/* (see "run_worker_first" in wrangler.jsonc).

const MAX_LENGTH = 280;

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

async function listQuestions(env) {
  const { results } = await env.DB.prepare(
    "SELECT id, text, votes, created_at FROM questions ORDER BY votes DESC, id ASC",
  ).all();
  return json(results);
}

async function addQuestion(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: "send JSON like {\"text\": \"...\"}" }, 400);
  }
  const text = typeof body?.text === "string" ? body.text.trim() : "";
  if (text.length === 0 || text.length > MAX_LENGTH) {
    return json({ error: `text must be 1 to ${MAX_LENGTH} characters` }, 400);
  }
  const row = await env.DB.prepare(
    "INSERT INTO questions (text) VALUES (?) RETURNING id, text, votes, created_at",
  ).bind(text).first();
  return json(row, 201);
}

async function upvote(id, env) {
  const row = await env.DB.prepare(
    "UPDATE questions SET votes = votes + 1 WHERE id = ? RETURNING id, text, votes, created_at",
  ).bind(id).first();
  return row ? json(row) : json({ error: "no such question" }, 404);
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === "/api/questions") {
      if (request.method === "GET") return listQuestions(env);
      if (request.method === "POST") return addQuestion(request, env);
      return json({ error: "method not allowed" }, 405);
    }
    const vote = url.pathname.match(/^\/api\/questions\/(\d+)\/upvote$/);
    if (vote && request.method === "POST") return upvote(Number(vote[1]), env);
    return json({ error: "not found" }, 404);
  },
};
```

```text
 Test Files  1 passed (1)
      Tests  5 passed (5)
```

Notice the `beforeEach` at the top of the tests. Without it, the tests share one database within the file, and "lists the most upvoted question first" fails because questions from earlier tests are still on the board. That failure came up while building this tutorial; it is exactly the kind of order dependence the `tdd` skill warns about, and the fix is to make every test start from a known state.

## 11.  The Page

The page is one static file that calls the API. Ask the agent for it, or save it as `public/index.html`:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Questions Board</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 40rem; margin: 2rem auto; padding: 0 1rem; }
    form { display: flex; gap: .5rem; } input { flex: 1; padding: .5rem; } button { padding: .5rem .8rem; }
    li { display: flex; justify-content: space-between; gap: 1rem; padding: .5rem 0; border-bottom: 1px solid #ddd; }
  </style>
</head>
<body>
  <h1>Questions Board</h1>
  <form id="ask">
    <input id="text" maxlength="280" placeholder="Ask a question" required>
    <button>Ask</button>
  </form>
  <p id="problem" role="alert"></p>
  <ul id="list"></ul>
  <script>
    const list = document.getElementById("list");
    const problem = document.getElementById("problem");
    async function load() {
      const questions = await (await fetch("/api/questions")).json();
      list.replaceChildren(...questions.map((q) => {
        const li = document.createElement("li");
        const text = document.createElement("span");
        text.textContent = q.text;
        const vote = document.createElement("button");
        vote.textContent = "▲ " + q.votes;
        vote.onclick = async () => { await fetch(`/api/questions/${q.id}/upvote`, { method: "POST" }); load(); };
        li.append(text, vote);
        return li;
      }));
    }
    document.getElementById("ask").onsubmit = async (e) => {
      e.preventDefault();
      const box = document.getElementById("text");
      const r = await fetch("/api/questions", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ text: box.value }) });
      problem.textContent = r.ok ? "" : (await r.json()).error;
      if (r.ok) { box.value = ""; load(); }
    };
    load();
  </script>
</body>
</html>
```

**Why does the page use `textContent` and never `innerHTML`** to show a question? (Think about what a student could type into the box.)

## 12.  Run It Yourself

Inside the box:

```bash
npm run db:local
npx wrangler dev --ip 0.0.0.0
```

Open `http://localhost:8787` on your own machine, or try the API from a second terminal:

```bash
curl -s localhost:8787/api/questions
curl -s -X POST -H 'content-type: application/json' -d '{"text":"How does D1 run locally?"}' localhost:8787/api/questions
curl -s -X POST localhost:8787/api/questions/1/upvote
curl -s -X POST -H 'content-type: application/json' -d '{"text":"   "}' localhost:8787/api/questions
curl -s localhost:8787/api/nope
```

> **You should see** `[]`; then the new question with `"votes":0`; then the same question with `"votes":1`; then `{"error":"text must be 1 to 280 characters"}`; then `{"error":"not found"}`.  The database lives in `.wrangler/` in your folder, which `.gitignore` keeps out of git.

## 13.  Review, Then Refactor

Refactoring is deliberately not part of the red-green loop. It gets its own step, with the whole suite green before and after.

```text
Use the code-review skill to review everything since the scaffold commit against
AGENTS.md's coding standards and docs/spec.md. Report findings; change nothing yet.
```

The review comes back in two columns. **Standards** checks the code against `AGENTS.md`, plus a baseline of Fowler's code smells (a mysterious name, duplicated code, a primitive standing in for a domain idea), each labeled as a judgment call. **Spec** checks the behavior against `docs/spec.md`, line by line. For this app it may point out that the same column list appears in three SQL statements, or ask whether the 280-character limit should live in one place instead of two (the Worker and the schema).

Decide each finding yourself. For a small one, tell the agent: "Do finding 2, run the suite, and stop." For anything structural, run `improve-codebase-architecture`, which produces a short report of candidate refactors and then interviews you about the one you choose. **Which finding here would you decline, and why?** A review is a list of options, not a list of orders.

---

# Part IV: Ship It

## 14.  A Clean Run

A long working session hides things: a file you never committed, a package you installed by hand, data left over in `.wrangler/`. Before anything leaves your machine, test the committed code from scratch:

```text
Use the docker-test skill.
```

On your own machine the skill runs `test-in-docker.sh`, which pipes `git archive HEAD` into a fresh `node:22-bookworm` container, runs `npm ci` and `npm test`, and deletes the container. Inside the box, where there is no Docker, it runs `test-clean-copy.sh` against a fresh copy under `/tmp` instead. Either way you should see `Tests  5 passed (5)`. **If the clean run fails and your normal run passes, what are the likely differences?**

## 15.  Continuous Integration on GitHub

CI is the same clean run, on GitHub's machines, on every push and every pull request. Save this as `.github/workflows/ci.yml`:

```yaml
name: CI
on:
  push:
  pull_request:
permissions:
  contents: read
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm test
```

Push a branch and open a pull request:

```bash
git switch -c first-release
git push -u origin first-release
```

The **CI** check appears on the pull request and turns green when the tests pass. Then make it a rule: in the repository's **Settings → Branches**, add a protection rule for `main` that requires the `test` check from the CI workflow to pass before merging. Now neither you nor the agent can merge red code, and the agent never pushes to `main` at all (`AGENTS.md` and the permission files both say so).

> This is the human-near-the-loop version of review.  The agent does the work on a branch, the pull request shows you the whole diff with the test results beside it, and the merge button is yours.
{: .tb-key data-title="Why this matters"}

## 16.  Deploy, With a Gate

You need a Cloudflare account now, and an API token that can do exactly two things: edit Workers scripts and edit D1. In the Cloudflare dashboard, **My Profile → API Tokens → Create Token**, start from the **Edit Cloudflare Workers** template, add **D1: Edit**, limit it to your account, and give it an expiry. Your account ID is on the Workers overview page.

**The first deploy, from the box.** The database has to exist before the Worker can bind to it, and its ID has to land in `wrangler.jsonc`. Start the box with the credentials this one time:

```bash
CLOUDFLARE_API_TOKEN=... CLOUDFLARE_ACCOUNT_ID=... OPENROUTER_API_KEY=... devbox/devbox.sh opencode
```

Then ask for the `cloudflare-deploy` skill. Follow along in the skill's file: it checks the tools, runs the tests, confirms the credentials are present without printing them, and then shows you `npx wrangler d1 create questions-board` and waits. After your yes it copies the new `database_id` into `wrangler.jsonc` and commits. It then shows you the two commands that change the live world, `npx wrangler d1 migrations apply DB --remote` and `npx wrangler deploy`, and waits again. It finishes by calling the live URL and reporting what it deployed.

Before you approve anything, you can see exactly what would be uploaded with `npx wrangler deploy --dry-run --outdir /tmp/out`:

```text
Total Upload: 2.03 KiB / gzip: 0.90 KiB
Your Worker has access to the following bindings:
Binding                           Resource
env.DB (questions-board)          D1 Database
env.ASSETS                        Assets
--dry-run: exiting now.
```

**Every later deploy, from GitHub.** Once the database exists, deploys belong in a pipeline where the token never touches your laptop or the agent. In the repository's **Settings → Secrets and variables → Actions**, add `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`. In **Settings → Environments**, create `production` and add yourself (or your team) as a **required reviewer**. Then save `.github/workflows/deploy.yml`:

{% raw %}
```yaml
name: Deploy
# Runs only when someone starts it from the Actions tab, and then waits for a reviewer:
# the "production" environment's required reviewers are the human gate.
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm test
      - run: npx wrangler d1 migrations apply DB --remote
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
      - run: npx wrangler deploy
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
```
{% endraw %}

Start it from the **Actions** tab (**Deploy → Run workflow**). It runs the tests and then stops at "Waiting for review" until a required reviewer clicks **Approve and deploy**. That click is the human gate, and it is recorded with your name on it.

## 17.  Teardown

A deployment you forget about is still on the internet. When the project is over, or before you redeploy from scratch, ask for the `cloudflare-teardown` skill. It shows what exists (including a preview with `npx wrangler delete --name questions-board --dry-run`), offers to back up the questions with `npx wrangler d1 export`, then deletes the Worker and the database, each after its own yes, and resets `database_id` so the next deploy starts clean. Afterward, check the Cloudflare dashboard yourself, and delete the API token if you made it for this project alone.

---

## Where the Two Agents Differ

| Concern | OpenCode | Oh My Pi |
|---|---|---|
| Install | `npm install -g opencode-ai@1.19.5` | `bun install -g @oh-my-pi/pi-coding-agent@18.20.0` (needs Bun 1.4.4 or newer) |
| Context file | `AGENTS.md` | `AGENTS.md` (also reads `CLAUDE.md`) |
| Skills folder | `.agents/skills/` (also `.opencode/skills/`, `.claude/skills/`) | `.agents/skills/` |
| Use a skill | Name it in the prompt | Name it in the prompt, or `/skill:<name>` |
| Permissions file | `opencode.json`, key `permission` | `.omp/config.yml`, keys `tools.approvalMode` and `bash.patterns` |
| Rule order | Last match wins | First match wins |
| Compound commands | Test your own rules with a compound line before you rely on them | Checks each part of `a && b` against `deny` and `prompt` rules, so `cd x && rm -rf y` is still caught by `rm *` |
| Skill gating | `permission.skill` can allow, ask, or deny each skill | `--skills=<globs>` filters which skills load |
| Project rules vs your own | Project config overrides global | A project may tighten your global `bash.patterns` but never loosen them |
{: .tb-full}

## Questions to Work Through

1. The `tdd` skill forbids "tautological" tests. Write one for this app that would pass by construction, and explain why it can never fail.
2. The charter rules out accounts, so a student can upvote a question many times. Write the next charter's non-goal or goal for this, and list the questions you would expect the `grilling` skill to ask you about it.
3. `opencode.json` denies `rm *`. Name two commands that would still delete a file, and say which part of this setup stops each one.
4. Why does the deploy workflow run the tests again, when CI already ran them on the pull request?
5. Swap D1 for Supabase. Which files change, which new secret appears, and what happens to the tests? (Start from `docs/adr/0001-d1-over-supabase.md`.)

## Further Reading

- [Matt Pocock's skills](https://github.com/mattpocock/skills), especially `grilling`, `tdd`, and `code-review`
- [Cloudflare D1](https://developers.cloudflare.com/d1/) and [Workers static assets](https://developers.cloudflare.com/workers/static-assets/)
- [Testing Workers with Vitest](https://developers.cloudflare.com/workers/testing/vitest-integration/)
- [OpenCode permissions](https://opencode.ai/docs/permissions/)
- [Oh My Pi](https://www.npmjs.com/package/@oh-my-pi/pi-coding-agent)
- [ShipIt: Build, Test, CI, and Publish One Artifact]({{ site.baseurl }}/Tutorials/ShipIt), this course's general guide to builds and CI
- Kent Beck, *Test-Driven Development: By Example*, for the original red-green-refactor loop
