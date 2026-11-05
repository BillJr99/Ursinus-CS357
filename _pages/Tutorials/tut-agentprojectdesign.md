---
layout: textbook
permalink: /Tutorials/AgentProjectDesign
title: 'CS357: Foundations of Artificial Intelligence - Designing a Project for Agents'
info:
  coursenum: CS357
  purpose: "How a repository keeps an agent coherent: the charter, observability, traceability, handoffs, menu-driven questions, and gates."
  eyebrow: "Tutorial"
  numbering: false
tags:
- agents
- opencode
---
*How a repository keeps an agent coherent across sessions.*

The repository is the durable memory for the project.  Conversation history only goes into the context window, and it does not survive from one session to the next.  The ideas below follow from that, and the [OpenCode Studio lab]({{ site.baseurl }}/Assignments/OpenCodeStudio) builds each one.


## Key Concepts

| Term | Plain-English Definition | Where you build it |
|------|--------------------------|--------------------|
| **Charter** | The constitution of a project: mission, ranked values, definition of done, and the guardrails an agent may never cross.  Written once, amended deliberately, reread at the start of every session | `CHARTER.md`, Part 1 |
| **Agent contract** | A file at the root of a repository stating the rules any agent must follow inside it | `AGENTS.md`, Parts 0 and 2 |
| **Observability** | Can I see what it did?  Bought by writing things down: a plan, a commit history, and a session entry as three separate records | `.ai/SESSION.md` and the commit log, Parts 4 and 5 |
| **Traceability** | Being able to answer, weeks later, *why* something is the way it is: which goal it served, what was decided, and what was rejected | The four-link chain, Part 6 |
| **Handoff** | A deliberate stop in which an agent writes down enough state that a *different* agent can continue safely | `KICKOFF_PROMPT.txt` and the cold session, Part 6 |
| **Durable memory** | A file the agent appends what it learned to, loaded into every session by the tool, so knowledge outlives the conversation that produced it | `.ai/MEMORY.md`, Parts 0 and 4 |
| **Menu-driven questions** | The grill-me or interview-me pattern: a bounded set of numbered multiple-choice questions, each with a recommended default, asked before any file is touched, whose answers become part of the spec | Asked of the agent directly, Part 4 |
| **Gate** | A check the harness runs on the real arguments of a tool call, before the tool executes.  A rule lives in the prompt and the model may drop it; a gate lives in the tool path and the model cannot skip it | `opencode.json`, Part 3 |

## The charter: deciding once instead of every time

`AGENTS.md` tells an agent what it may *touch*.  A **charter** tells it what the project is *for*, and that answers a different and harder class of question.

Watch the difference.  Halfway through a task, an agent notices that making the tests pass quickly would mean loosening an assertion.  Nothing in `AGENTS.md` forbids editing a test.  So the agent either stops and asks you, interrupting, and it will ask again tomorrow, or it guesses.  A charter that ranks **correctness above speed** answers the question without either.

That is the whole trick.  A charter is where you make a decision **once**, in writing, so that neither you nor any agent has to relitigate it at three in the afternoon.  The [course template]({{ site.baseurl }}/files/agent-templates/CHARTER.md) has six sections that earn their place:

| Section | What it decides |
|---|---|
| **Project mission** | One sentence about the product, not the technology |
| **Engineering philosophy** | Five values, **ranked**, so conflicts resolve without you |
| **Definition of success** | A concrete, observable test for "done", so nobody has to have an opinion about it |
| **Repository layout** | Zones, as paths: read-only, workspace, off-limits |
| **Git policy** | When to commit, what never gets committed |
| **Documentation authority** | Which wins when documents and memory disagree |

The ranking takes the longest and earns the most.  A list of five values in no particular order resolves nothing.  A ranked list resolves cases its author never anticipated, which is precisely the situation an agent will put you in.  Keep this rule from the template verbatim:

> The agent shall never work from memory when project documentation exists.  Before every session, reread the charter, the current task, and the session log.  If project documentation conflicts with remembered context, prior chat context, or assumptions, **the documentation wins.**  If the documentation is incomplete, update it rather than relying on memory.

## Observability, isolation, reversibility

Step 8.5 of *Your AI Workbench* named the three properties that make delegating to an agent safe.  They bear restating here because the lab makes you responsible for two of them:

| Property | The question it answers | How you buy it |
|---|---|---|
| **Observability** | Can I see what it did? | By writing things down: the plan, the commit history, and the session log, kept separate |
| **Isolation** | Can I bound what it reaches? | By boundaries the system enforces rather than boundaries you ask for.  You inherited most of this from the container your workbench runs in, and Part 3 adds one boundary of your own |
| **Reversibility** | Can I undo it? | By never having exactly one copy of anything that matters.  In the lab, that means committing *before* the agent runs |

> **Common Misconception:** "Reversibility means I can undo anything, so I can be less careful about the other two."  Reversibility is bounded by observability.  You can only revert a change you *noticed*, and the dangerous agent failure is not the dramatic one.  It is the small wrong edit that lands in a file you do not reread for a month, by which time you have written three things on top of it.  Git will happily let you undo it; nothing will tell you that you should.

## Traceability: the chain that answers "why is it like this?"

Your charter, your task file, your commit history, and your session log form one loop, and each piece does a job the others cannot:

```text
CHARTER.md            why this project exists, and what always wins   (rarely changes)
.ai/CURRENT_TASK.md   what is being worked on right now               (changes per session)
the plan              what the agent intends to do, before it does it (per session)
the commit            what actually changed, and when                 (per increment)
.ai/SESSION.md        what happened, and what was deliberately not    (append-only)
docs/DECISION_LOG.md  what was chosen, and what was rejected, and why (per decision)
```

Read that column from bottom to top and you have **traceability**: long after you have forgotten the details, a line of your artifact still traces back to a commit, which traces to a session entry, which traces to a task, which traces to a charter goal.  Nobody has to remember anything, and "why is it like this?" gets a written answer instead of an argument.  Part 6 walks that chain for real, and it is entirely normal for it to break the first time, since naming the broken link precisely is worth as much to me as an unbroken chain.

## Handoffs: stopping so that someone else can start

A handoff is a deliberate stop in which enough state is written down that a *different* agent, with none of your context, can continue safely.  Every session entry in the lab ends with a **Next Safe Action**.  Not "next steps", which is a wish list.  One concrete action that is safe to take with no further context.  It is the handoff, written before it is needed.

The test in Part 6 is blunt: close everything, start a session that has never seen the project, hand it only the kickoff prompt and the repository, and require it to restate the mission, the active task, and the next safe action **before** it acts.  Every question it has to ask you out loud is a missing section in a document.

## Menu-driven questions: the grill-me pattern

This is the idea that makes everything above legible, and it is the one students tell me they carry furthest past this course.

An agent handed an underspecified request has two bad options.  It can guess, which produces work you did not want, or it can ask open-ended questions, which you answer carelessly because open-ended questions are expensive to answer.  The first half of the fix is a bounded question set: ask me up to five questions that would change how you approach this, then stop.  (The Coding Agents session showed you this shape in Section 4, and *Prompt Engineering as Agent Design* names it the plan-first protocol.)  A **menu** is the second half.  Each question comes with lettered options and a stated default, so answering takes three keystrokes rather than three paragraphs.

This pattern has a name in practice: the grill-me or interview-me style.  The agent asks a short list of numbered multiple-choice questions, each with a recommended default, before it builds anything, and your answers become part of the spec instead of assumptions buried in the code.  In Part 4 you ask for it directly, in a prompt you type.  In the *Skill Design Study* you package that same request as a skill and measure whether packaging it changed the result.

Three things follow from the menu form, and they are the reasons it earns its place with a small local model:

1. **The question set is bounded**, so the session does not turn into an interview that you abandon halfway.
2. **The answers are cheap enough that you actually give them**, which is the difference between a clarification protocol that runs and one that exists only in the system prompt.
3. **The answer space is closed**, so what gets written into `.ai/CURRENT_TASK.md` is comparable across sessions and parseable by you later.  An open-ended answer produces prose that only its author can interpret; a menu answer produces a record.

## Four places an instruction can live

The OpenCode Studio lab is organized around one distinction, and it is worth stating before you meet it four times. An instruction to an agent can live in four places, and they are not interchangeable:

| Where it lives | Persists across sessions? | Can the model ignore it? | Where you build one |
|---|---|---|---|
| A prompt you type | No. You retype it | Yes | Part 4, the interview |
| A rule in `AGENTS.md` | Yes, the tool loads it | Yes | Parts 0 and 2 |
| A skill | Yes, and it loads on a trigger you wrote | Yes, and it may also never fire | The *Skill Design Study* |
| A gate | Yes | **No.** The tool decides before the model runs | Part 3 |

Read the third column down. Only the last row changes kind. The first three are all requests, differing in how much typing they save you and how reliably they arrive; the fourth is a refusal that happens whatever the model decided. Most of this lab is spent finding out, empirically, which of your own rules belong in which row.

What the lab deliberately leaves out: a second human writer and a second simultaneous agent.  Both arrive later, and the closing section names exactly where.  Enforcement in code is not left out entirely: Part 3 builds exactly one gate, and the closing section names where the rest arrives.

---


## Yolo mode, and the one place it belongs

You have now used `--auto` twice, so it is worth naming what you were using.  **Yolo mode** is what people call running an agent with its permission gates switched off, approving its own actions and never stopping to ask.  opencode has no flag by that name.  It spells the idea two ways, and the two differ in how long they last.

The flag is `--auto`, which auto-approves every permission that is not explicitly denied, for that one command:

```bash
opencode run --auto "clean up the build"
```

The desktop application has no such flag, and its closest equivalent is you: approving every prompt as it arrives, or choosing the always-allow answer on a prompt when the app offers one, which keeps that kind of call approved for the rest of the session.

The configuration-file equivalent is a permissive `permission` block, which applies to every session until you change it back:

```json
{
  "permission": {
    "*": "allow"
  }
}
```

That block is a file edit in both faces: you can make it in an editor, or ask opencode to make it, and in the desktop application it takes effect once you reopen the folder.  The flag is the safer of the two, because it expires when the command does.  A permissive block is a decision you will forget you made, which is the failure the charter exists to prevent.

Neither belongs on work you care about.  The rule the lab teaches is that yolo mode is legitimate in exactly one situation: inside a scoped container, on a clean git tree, when you are deliberately measuring what an ungated agent does, which is what you just did in Part 3.  Remove any of those three conditions and the properties from the Background section fail together.  You lose observability, because nothing pauses to show you a command before it runs.  You lose reversibility, unless the tree was clean and `git checkout --` can take you back.  You lose isolation, unless a container is drawing the boundary the permission block has stopped drawing.

One asymmetry is worth keeping in mind.  A `deny` rule still holds under `--auto`, because the flag approves only what is not explicitly denied.  If there is an operation you never want attempted, write it as `deny` rather than trusting `ask` to save you, since `--auto` silences `ask` and leaves `deny` standing.


## Running it somewhere else: `serve` and `--attach`

Everything so far assumes the agent runs in the terminal in front of you.  It does not have to.  opencode separates the agent from its interface, so the run can live on the machine that holds your repository while you drive it from another device.

Start the server on the machine with the repository:

```bash
export OPENCODE_SERVER_PASSWORD=something-long
opencode serve --hostname 0.0.0.0 --port 4096
```

Then drive it from anywhere that can reach that address:

```bash
opencode run --attach http://100.92.14.7:4096 --agent builder "Implement spec.md."
```

`opencode web` starts the same API together with a browser interface, so a second laptop or a phone browser at that address picks up the session instead of a terminal.  That browser is also the no-code way to drive a remote run: once the server is up, everything you would have passed to `opencode run --attach`, including the choice of `builder`, is a message and a selector in the page.  Starting the server itself has no desktop equivalent, because it is a long-running process on the machine that holds the repository, so that one command needs a terminal there.  The address in the example is a tailnet address; *Agentic CLI Tools* Section 9a covers how a machine behind a home router or the campus network gets one, and why a port forward is the wrong way to arrange it.

Two cautions carry straight over from Part 3.  The password is not optional, because an unauthenticated agent server is an open shell on whatever its working directory contains.  And a long run you started from a phone is an unattended run, which means the `permission` block and the container are doing the supervising rather than you.
