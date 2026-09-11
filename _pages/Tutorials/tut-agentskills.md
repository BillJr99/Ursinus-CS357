---
layout: default-standard
permalink: /Tutorials/AgentSkills
title: "CS357: Foundations of Artificial Intelligence - Agent Skills and Plugins: What They Are, How They Are Stored, and How to Publish One"
info:
  coursenum: CS357
  purpose: "To explain what an agent skill is, how it differs from a system prompt, a context file, a plugin, and a tool, where opencode and pi find skills on disk, how to write one that fires reliably, how to publish one so a classmate can install it, and what a claim protocol has to specify when two agents share a medium."
tags:
- skills
- agents
- opencode
- pi
---

# CS357: Foundations of Artificial Intelligence - Agent Skills and Plugins: What They Are, How They Are Stored, and How to Publish One

## Purpose

To explain what an agent skill is, how it differs from a system prompt, a context file, a plugin, and a tool, where opencode and pi find skills on disk, how to write one that fires reliably, how to publish one so a classmate can install it, and what a claim protocol has to specify when two agents share a medium.

## About This Tutorial

A skill is a named, reusable instruction set that an agent loads and follows.  This tutorial is the reference for writing one.  It covers the spectrum from a prompt to a packaged skill, where opencode and pi look for skills on disk, the authoring principles your skills are graded against, how to publish a skill repository, and the claim protocol two agents need when they hand work to each other through a shared medium.  You use all of it in the [Skill Design Study]({{ site.baseurl }}/Assignments/SkillDesignStudy), where you author, install, and invoke two skills of your own, and in the Local Agent Lab's optional extension, where an AI tool generates one for you and you find where it is wrong.  The claim-protocol section at the end is also the reading behind the handoff design document the syllabus assigns.

---

## Key Concepts

Start with the vocabulary.  Every term in this table appears in the lab.  Return to the table whenever a term looks unfamiliar.

| Term | Plain-English Definition | Example You'll See |
|------|--------------------------|--------------------|
| **Skill** | A named instruction set that an agent can invoke on demand, scoped to a specific purpose | A "code-review" skill that instructs the agent to always check for hardcoded secrets before approving a diff |
| **Plugin / extension** | Harness-specific executable code that adds new capability to the agent itself (a pi TypeScript extension, an opencode plugin). Distinct from a skill, which is instructions any harness can read | `pi install npm:@billjr99/pi-openai-compat` adds provider support; no skill could do that |
| **System prompt** | An always-on, always-active instruction injected before every conversation turn | "You are a helpful coding assistant. Always explain your reasoning." Loaded automatically, not invokable by name |
| **`opencode.json`** | OpenCode's configuration file, at `~/.config/opencode/opencode.json` (global) or `opencode.json` in a project root. It holds model routing and **permissions**; skills are directories on disk, not entries in it | The `permission.skill` block that decides which skills an agent may load |
| **`SKILL.md`** | The file that *is* the skill, inside a directory named for it. YAML front matter carries `name` and `description`; the body is the instruction text | `.agents/skills/safety-check/SKILL.md`, discovered by both opencode and pi |
| **Tool (function call)** | A piece of code the agent can execute, a real function that runs in the host environment and returns structured data | `read_file("main.py")` runs in the shell and returns the file's contents; it is not an instruction template |
| **Description-as-trigger** | There is no separate trigger field. The agent decides whether to load a skill by matching your request against the skill's `description`, which makes the description the matching surface rather than documentation | "Use when the user asks to delete, remove, overwrite, or drop anything" fires; "Safety utilities" does not |
| **Superpowers** | A community skill bundle for agent CLIs, distributed as a Git repository of skill directories | Cloned into a discovery path: `git clone https://github.com/obra/superpowers.git ~/.agents/skills/superpowers` |
| **caveman** | A community skill (`JuliusBrussee/caveman`, MIT) that compresses the agent's output by forcing terse, article-free responses. Three intensity levels, `lite`, `full`, and `ultra`, the last intended for token-budget-constrained pipelines. It reverts to normal communication for security warnings and irreversible actions, which is a design decision worth reading before you install it | `opencode skills install git+https://github.com/JuliusBrussee/caveman.git`, and the compression condition in the lab's deliberation-harness experiment |
| **Token meter** | Reading the token counts a provider actually reports, rather than estimating them from word counts. Ollama returns `prompt_eval_count` and `eval_count` on every non-streaming call, so the measurement costs nothing | `tools/token_meter.py` in the deliberation-harness starter, whose numbers land in `summary.json` |
| **Amortized training cost** | A request's share of the one-time carbon cost of training the model that serves it: the training total divided by an assumed number of lifetime requests. Additive to the request's own operational cost | `config/energy-profiles.json`. The denominator is an assumption, and the term moves by orders of magnitude with it |

---

## The Spectrum of Agent Instruction

There are four ways to give an agent standing guidance, and they differ in scope, trigger, and encoding.  Compare them to guiding a colleague.  A team handbook that everyone always consults is a system prompt.  A note left on one project folder is a context file.  A checklist to follow whenever they perform a code review is a skill.  A calculator they can press to get an answer is a tool.  The analogy stops at the calculator: a real tool runs code and returns data the agent did not have, while the other three only shape how the agent behaves.

| Instruction Form | Scope | Always Active? | Invoked How? | Encoded As |
|-----------------|-------|----------------|--------------|------------|
| System prompt | Global, every conversation turn | Yes | Automatically | Text injected before the conversation |
| Context file (`AGENTS.md`, `CLAUDE.md`) | Project, read at startup | Yes | Automatically at launch | Markdown file in the project root |
| Skill | Named, surfaced on demand | No | By name, or by the agent matching its `description` | A directory containing `SKILL.md`, found on the filesystem |
| Tool (function call) | Named, executes real code | No | By name, returns data | Code function registered with the agent runtime |

### Skill Versus Tool

The distinction that matters most is skill versus tool.  A skill is an instruction template: it tells the agent how to behave in a situation.  A tool is executable code: the agent calls it and gets back structured data.  A skill says "when reviewing a diff, follow steps 1-4."  A tool says "call `run_tests()` and here is the exit code."  You can combine them.  A safety skill can instruct the agent to always call a `list_files` tool before deletion, then pause for confirmation.  The instruction is the skill; the file listing is the tool.

> **Watch out.** Many students assume that adding a skill to `opencode.json` makes the agent follow those instructions on every turn, like a system prompt.  It does not.  Registration surfaces a skill (makes it available), but the agent invokes it only when it recognizes the situation or when you name the skill in your prompt ("use the code-review skill").  If you want always-on behavior, use a context file or a system prompt.  If you want composable, named behavior you can invoke selectively, use a skill.

---

## How Skills Are Stored: Directories, Not Config Entries

Both tools you might use in this course have settled on the same design, and it differs from how skills worked a year ago: a skill is a directory containing a `SKILL.md` file, discovered from the filesystem.  It is not an entry in a JSON array, and there is no `instructions` string to escape into a config file.

```text
my-project/
`-- .agents/
    `-- skills/
        |-- safety-check/
        |   `-- SKILL.md          <- the skill IS this directory
        `-- code-review/
            |-- SKILL.md
            `-- checklist.md      <- supporting files live alongside it
```

The directory name is the skill name.  Anything else in the directory (reference docs, templates, helper scripts) is available to the agent once the skill is loaded.  That is what makes a skill more than a long prompt.

### Where the Tools Look

Both walk up from your working directory to the repository root, then fall back to your home directory:

| | Project-level | User-level |
|---|---|---|
| **opencode** | `.opencode/skills/`, `.claude/skills/`, `.agents/skills/` | `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/` |
| **pi** | `.pi/skills/`, `.agents/skills/` | `~/.pi/agent/skills/`, `~/.agents/skills/` |

Notice the overlap.  Both tools read `.agents/skills/`, so one directory of skills works in either tool with no porting step.  Use it for everything you write in this course unless you have a specific reason not to.  You get portability for free, and "it only works in my tool" is a real cost when a teammate uses the other one.

### The `SKILL.md` Front Matter

The `SKILL.md` front matter is short.  opencode recognizes:

```markdown
---
name: safety-check
description: Pause and require explicit confirmation before any destructive file operation. Use when the user asks to delete, remove, overwrite, truncate, or drop anything.
---

## Guarded operations

...the instructions the agent follows once this skill is loaded...
```

- `name` is required.  It must be 1 to 64 characters of lowercase alphanumerics with single hyphens, and it must match the directory name.  A mismatch is the most common reason a skill silently does not load.
- `description` is required, and it does more work than it looks like (see below).
- `license`, `compatibility`, and `metadata` are optional.

> **Watch out.** The description is the trigger.  There is no `when` field, and this trips people up.  The agent decides whether to pull in a skill by reading its `description` against what you are currently doing.  The description is not documentation; it is the matching surface.  "Safety utilities" will not fire.  "Use when the user asks to delete, remove, overwrite, truncate, or drop anything" will.  Write the description as *when to use this*, in the words a user would type, and your skills will fire when you expect them to.

### What `opencode.json` Still Holds

Permissions live in `opencode.json`, and skills no longer do.  The config file still exists; it holds different things:

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "experimental-*": "deny"
    }
  }
}
```

### Installing Someone Else's Skills

pi installs extensions and skills from npm or a Git host.  Add `-l` to scope the install to the current project instead of your home directory:

```bash
pi install npm:@someone/pi-tools
pi install git:github.com/someone/their-skills
pi install git:github.com/someone/their-skills -l   # project-local
```

For opencode, a skill directory is installed by being in one of the discovery paths.  Cloning a repository of skills into `.agents/skills/` (or symlinking it there) is the whole installation.  That is simpler than a package manager, and it means you can read exactly what you installed before you run it.  Do read it.  A skill is instructions your agent will follow, and installing one you have not read is the same category of decision as running a script you have not read.

---

## A Worked Example: What Happens When a Skill Fires

You are in a session and you type:

```text
Please review my latest changes.
```

The agent:

1.  Has already discovered every `SKILL.md` in the paths above at startup, and knows each one's `name` and `description`.
2.  Matches your request against those descriptions and finds `code-review`.
3.  Reads that skill's `SKILL.md` in full, plus any supporting files it references, and treats the contents as scoped guidance for this task.
4.  Follows the instructions: reads the changed files, classifies findings by severity, ends with a verdict.
5.  Drops the skill's instructions afterwards.  They are not persistent, which is exactly the difference between a skill and a system prompt.

Step 2 is the one to remember.  Nothing pattern-matched a trigger phrase you configured.  The model read your request, read the descriptions, and decided.  That has a consequence you test in the lab's safety-guardrail skill: a skill is guidance the model chooses to follow, not a gate the model cannot pass.  If you need a rule that holds even when the model decides otherwise, the rule belongs in code.

### Question to Work Through

A classmate says: "I wrote a safety-check skill, so now the agent will always ask for confirmation before deleting anything, just like a system prompt does."  Name the two separate things wrong with that claim.

---

## Skill Authoring Principles

A vague or open-ended skill is applied inconsistently.  The agent interprets its instructions differently on each invocation, and you cannot predict or test its behavior.  Three principles make skills reliable.

### One Clear Purpose

A skill that tries to do "code review, plus security scanning, plus documentation generation" will do all three poorly.  Split compound behaviors into separate skills.  If you cannot name the skill's purpose in ten words or fewer, split it.

### Explicit Constraints

Do not write "be careful."  Write "never proceed without listing all affected files first."  Do not write "check for security issues."  Write "check for hardcoded strings matching the regex `[A-Z]{2,}_KEY|password|secret|token`."  Concrete constraints can be tested; abstract ones cannot.

### Concrete Output Format

Specify exactly what the agent should produce: which headings, which labels, which order.  A skill that produces consistently formatted output is automatable; you can pipe its output to another tool.  A skill with free-form output is not.

### The Menued-Question Pattern

One common skill shape is the menued-question pattern, sometimes called a grill-me or interview-me skill.  The skill asks you numbered multiple-choice questions, each with a recommended default, before the agent builds anything.  The point is to collect decisions up front so the agent does not fill the gaps with guesses.  The charter interview in the lab's deliberation-harness pathway works the same way: it collects your decisions before the controller does any work.

> **Watch out.** Students often write skills that say "follow best practices for X."  This phrase is not a skill instruction; it is a deference to an undefined standard.  The agent will infer "best practices" from its training data, which may not match your project's conventions at all.  Replace "follow best practices" with the specific practices you want: the exact linting rule, the exact naming convention, the exact checklist item.  A skill you authored and a skill that says "use best practices" will produce very different results on the same input.

---

## Publishing a Skill So Someone Else Can Install It

Because a skill is a directory, publishing one means publishing a repository with that directory in it:

```text
cs357-skills/                       <- repository root
|-- README.md                       <- what these are, and how to install them
|-- safety-check/
|   `-- SKILL.md
|-- code-review/
|   `-- SKILL.md
`-- obsidian-memory/
    `-- SKILL.md
```

A classmate installs the bundle by cloning it into a discovery path:

```bash
git clone https://github.com/your-username/cs357-skills.git ~/.agents/skills/cs357
# or, for one project only:
git clone https://github.com/your-username/cs357-skills.git .agents/skills/cs357
```

For pi, the same repository installs with `pi install git:github.com/your-username/cs357-skills`.

Two details decide whether this works for someone else:

- The directory name is the skill name, and it has to match `name:` in the front matter.  Rename the directory during install and the skill stops loading, with no error message saying so.
- `README.md` at the repository root is for humans; `SKILL.md` inside each directory is for the agent.  Do not merge them.  A `README.md` that explains your design decisions is what a reviewer reads.  A `SKILL.md` that opens with a paragraph of rationale is a skill whose instructions the agent has to dig for.

The Skill Design Study asks you to package one skill as a `.skill` archive and post it to the course discussion.  That archive is a zip of one skill directory with `SKILL.md` at its top level, which is exactly the layout above, one folder deep.

> **Checkpoint.** A skill is a directory with a `SKILL.md`, found by path and fired by its description.  It is guidance the model follows by choice, so anything that must hold no matter what belongs in code.

---

## Key Concepts Summary

| Term | Definition |
|------|------------|
| **Skill** | A named, composable instruction set an agent can invoke on demand, scoped to a specific purpose |
| **Plugin / extension** | Executable integration specific to one harness (a pi TypeScript extension, for example), as opposed to a skill, which is instructions any harness can read |
| **System prompt** | Always-on instructions injected before every conversation turn |
| **`opencode.json`** | OpenCode's configuration file: model routing and `permission.skill` rules. Skills themselves are directories on disk |
| **`SKILL.md`** | The file that is the skill, in a directory named for it, under `.agents/skills/` for portability across opencode and pi |
| **Tool (function call)** | Executable code the agent calls at runtime; returns structured data |
| **Description-as-trigger** | The agent loads a skill by matching your request against its `description`; there is no separate trigger field |
| **Superpowers** | A community skill bundle; installed by cloning its repository into a skills discovery path |
| **caveman** | A community skill that compresses agent output to terse, article-free responses at three intensity levels; the compression condition in the lab's deliberation-harness experiment |
| **Token meter** | Measured token counts read off the provider's response, plus the conversion to grams CO2eq, in `tools/token_meter.py` |
| **Assumptions audit** | A structured comparison of two artifacts to surface the implicit beliefs each author encoded |

---

## The Handoff Skill and the Claim Protocol

A safety skill gives one agent a conscience, and a memory skill gives it a way to leave something behind for its own next session.  That second one is a handoff to yourself, and it is easy, because there is only ever one writer.  Real agent systems are not like that.  A worker finishes a task and a reviewer picks it up, and the two never share a context window.  Everything one knows, the other has to read.

The channel between them is a durable medium: something outside both agents that survives either of them crashing.  The *Coding Agents* session makes the case for one such medium in detail, GitHub, where an issue carries the task, a pull request carries the attempt, and a review comment carries the correction.  Step 5 of that session's worked loop is the whole idea in one line: the review comment *is* the inter-agent message, written by one agent and consumed by another that never saw the first one's context.

### Choosing a Medium

Three media do the job.  Which one you pick matters less than whether your protocol survives the switch.

| Medium | The channel is | Best if |
|---|---|---|
| **GitHub** | Issues, pull requests, and review comments in a repo both agents can reach | You want the pattern from the *Coding Agents* session, and you already have `gh` working |
| **Obsidian vault** | `vault/handoff/inbox/` and `vault/handoff/done/`, under the same zone rules as a vault memory skill | You want to extend a vault skill you already built, and your sync is already working |
| **A plain shared folder** | Two directories on disk. No Git, no accounts, no network | You want the no-code version, or you do not have a second agent runtime handy |

The plain-folder route is not the lesser option.  Strip away the tooling and every one of these is the same thing: a place to put work, a place to put finished work, and a rule about who may move what between them.  If your protocol only works because GitHub happens to serialize writes for you, you have not written a protocol.

### The Claim Protocol

This is the part that does not exist in a single-writer skill, and the part where most designs fail.

Two agents are looking at the same pending item.  Nothing stops both of them from starting it.  If both finish, you have paid twice for one task and you may have two contradictory results.  If both write to the same place, one of them silently loses.  The claim protocol is the set of rules that prevents this.  In *Observability, Traceability, and Handoff Protocols*, you wrote the start, stop, restart, and handoff protocol as a skill; the claim protocol here is the same one.  A handoff `SKILL.md` must specify, in enforceable terms:

1.  **How an agent claims an item** before working on it: moving or renaming the file, or writing a `claimed_by` and `claimed_at` field into it.  Whatever you choose, the claim must be visible to the *other* agent through the medium alone.
2.  **What a second agent does when it sees a claimed item.**  Skip it, wait, or take it?
3.  **What makes a claim stale.**  An agent that claims an item and then dies leaves the item claimed forever.  How long is too long, and who is allowed to break the claim?
4.  **What "done" looks like** in the medium, so the next agent can tell finished work from abandoned work.

State each rule as a path and a condition, not as a sentiment.  "Agents should coordinate" is not a protocol.

### Questions to Work Through

1.  Which of your protocol's rules are enforced by the medium itself, and which hold only because both agents chose to follow them?
2.  If your second agent were running a different model, which rule would be the first to break?
3.  What does your protocol do if an agent claims an item and then writes a *wrong* result to `done`?

> **Checkpoint.** Two agents pointed at the same unclaimed item at the same time do not have a "correct" outcome.  Either your claim protocol held, in which case you should be able to say what mechanism held it, or you produced the double work or the lost write.  The second outcome is a passing result if you diagnose it: show the evidence, name the rule that would have prevented it, and say whether that rule is enforceable in your medium or only advisory.
