<!--
author:   William Mongan
language: en
narrator: US English Male

comment: Render with https://liascript.github.io/course/?https://github.com/BillJr99/Ursinus-CS357-Fall2026/blob/gh-pages/_pages/Activities/liascript-iterationloops.md or locally via https://www.billmongan.com/LiaScript/?https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/_pages/Activities/liascript-iterationloops.md

import: https://raw.githubusercontent.com/LiaTemplates/Pyodide/master/README.md

link:   https://cdn.jsdelivr.net/gh/BillJr99/Ursinus-Boilerplate-Assets@main/css/liascript-custom.css?v=2025-08-23-4
        https://fonts.googleapis.com/css2?family=Lexend+Deca&display=swap

-->

# The Karpathy Loop and the Gauntlet Loop: Iterating With an Agent

In *Coding Agents: OpenCode, Spec-First Development, Hooks, and Reading the Diff*, you wrote a specification before any code existed and watched an agent implement it.  Today you put that work inside a loop, and you set the loop up so the agent runs it.

Two loops do the job.  The **Karpathy loop** moves in small steps, each one verified by a check that already exists.  The **Gauntlet loop** writes the check first, as a rubric, and then attacks each candidate until no material defect remains.  Both are configuration plus a command.  You leave today with the files that configure them, the commands that run them, and one gauntlet round scored against a rubric you wrote.

---

## Directions and Group Roles

Work in your POGIL team with your rotated roles (**Manager**, **Recorder**, **Presenter**, **Reflector**).  Read each model as a team, then answer the Critical Thinking Questions on your own before discussing.  The Recorder posts the team's answers to the Class Activity Questions discussion board; the Presenter reports out wherever you disagreed.  After class, complete the Reflection Prompt in your notebook.

---

## Key Concepts

| Term | Plain-English Definition | Example You'll See Today |
|------|--------------------------|--------------------------|
| **Karpathy loop** | Ask for one small change, run the check, commit or restore, repeat.  The agent never gets more than one verifiable step ahead of you | Model 1: two increments to `normalize_title`, each one a commit |
| **Gate** | A point where the loop cannot continue until a person or a deterministic check says so | The plan gate and the check gate in Model 1 |
| **Rubric** | The written check: what must be true, how to verify it, and whether a failure is material.  You write it before the agent runs | Section 6: the same rubric in a qualitative form and a quantitative one |
| **Material defect** | A flaw that could change correctness, usefulness, compliance, interpretation, feasibility, safety, or a user's decision.  Style preferences usually are not | Default `max_results` of 10 when the spec says 5 |
| **Permission block** | The `permission` section of `opencode.json`, which decides what opencode may do without stopping to ask you | Section 2: `git` allowed, `rm` denied, everything else asked |
| **Auto mode** | opencode's `--auto` flag, which approves anything you did not explicitly deny | Section 8, with the isolation it requires |
| **Handoff directory** | The `.ai/` files that hold the loop's state between turns and between agents | Section 4: where the Karpathy loop writes down what it just did |
| **Gauntlet loop** | Parse the task, clear the fog, write the rubric, generate Candidate 0, critique it adversarially, revise, verify, and stop when no material defect remains | Model 3: one round against your `spec.md` |
| **Source of truth** | The authoritative basis the work is judged against: your requirements, your spec, your approved decisions, then evidence, then the agent's own criteria, in that order | `spec.md` and the rubric outrank anything the agent decides on its own |
| **Fog** | An unresolved decision, dependency, ambiguity, or missing fact that could materially change the work.  Fog is cleared, never disguised as a settled assumption | "Score is a float from 0 to 1": scored how? |
| **Converged result** | A candidate for which the latest critique finds no material defect that warrants revision | The stopping condition of every gauntlet preset |

### Before You Start

**You need:** your `cs357-work` repository with the `spec.md`, `AGENTS.md`, and `system_prompt.txt` from the OpenCode Studio lab, plus opencode and Ollama from *Your AI Workbench*.  Sections 2 and 6 write two new files into that repository, and Model 3 runs against your own `spec.md`.  Check with:

```bash
git -C ~/cs357-work status
```

**Working without a terminal.** Everything today can be done by prompting, in the opencode desktop application or in the terminal interface.  Each command comes with the prompt that does the same job.  Two settings make the prompt-only route work, and both are easy to miss: in the desktop application, turn on **File -> Settings -> Show Agent** so the agent selector appears beside the model dropdown, and in the terminal interface press **Tab** to cycle agents and type `/model` to pick the model.

---

## Today's 75 Minutes

We have seventy-five minutes together.  Here is how they are meant to go, so you can tell when a section is running long and say so.

| Minutes | What we do |
|---|---|
| 0-12 | Part I: why iteration beats one big prompt, and Model 1's two-step loop |
| 12-32 | Part II: the four files, one increment, the `.ai/` directory, and Model 2's broken run |
| 32-58 | Part III: the rubric written two ways, one gauntlet round, and the code cell |
| 58-70 | Part IV: which loop when, unattended loops, and auto mode |
| 70-75 | Report-out.  Exercises and the reflection are take-home |

---

# Part I: Two Loops, One Habit

## 1.  Why Iteration Beats One Big Prompt

That session left you with a specification and an agent that could implement it.  What it did not settle is **how much to ask for at once**.  The tempting answer is everything: hand over `spec.md`, say "implement this," and see what comes back.

Iteration beats that for one reason.  It shrinks the thing you have to judge, and it gives you something to judge it *against*.  A single increment is checked by a test you already wrote.  A large result has no check at all until you invent one after the fact, which is exactly when you are most inclined to accept what you are looking at.

Andrej Karpathy, who named vibe coding, makes the point (as the *AI-Assisted Development* tutorial records) that people are better at writing specifications than at reviewing arbitrary output, and models are better at producing output than at writing specifications.  Both loops today keep you on the side of that trade you are better at.  They differ in where the check comes from.

| | Karpathy loop | Gauntlet loop |
|---|---|---|
| **The check** | A test or command you already have | A rubric you write first from the source of truth |
| **The unit** | One increment | One candidate, one critique |
| **What decides** | The check passes or it does not | The rubric's material criteria, all of them |
| **When it stops** | The spec is met, or you restore and rethink | No material defect remains, or the preset's round limit is reached |
| **Fits** | Code with a runnable check | Prompts, plans, documents, and code without a complete test suite |

## Model 1: A Two-Step Karpathy Loop

The task: `tools/titles.py` in `cs357-work` has a stub `normalize_title(s)` and two failing tests you wrote first, in the spec-first order from *Coding Agents*.  Each increment is one command, one check, and one commit.

**Increment 1.**  Make the first test pass, and nothing else.

```bash
opencode run "Make tools/test_titles.py::test_collapses_whitespace pass.  Edit tools/titles.py only.  Do not add helpers, entry points, or tests."
python -m pytest tools/test_titles.py -q
git commit -am "normalize_title: collapse whitespace"
```

Or ask opencode to do it:

```text
Make tools/test_titles.py::test_collapses_whitespace pass.  Edit tools/titles.py only.
Do not add helpers, entry points, or tests.  Then run python -m pytest
tools/test_titles.py -q and show me the result.  If it passes, commit with the
message "normalize_title: collapse whitespace".  If it does not, stop and tell me.
```

The check reports one pass and one failure.  Commit anyway.  The failing test belongs to the next increment, and a red test you have not asked for yet is not a defect.

**Increment 2.**  Make the second test pass.  This is where the loop earns its keep:

```bash
opencode run "Make tools/test_titles.py::test_slug_form pass.  Before editing, list the files you will change and why, then stop."
```

The agent proposes editing `tools/titles.py` to lowercase and hyphenate, and then proposes adding a `slugify()` helper and a `__main__` block so the tool can run from the shell.  Nobody asked for either.  You reject both at the plan gate, before any file changes:

```text
Only the first sentence of that plan.  Do not add slugify or a __main__ block.
```

The agent changes one line.  The check reports two passing tests.  You commit.

Notice the size of what you had to judge: two one-sentence plans and two test runs.  The agent never got more than one increment ahead of you, and the one time it tried, the plan gate caught it before any code existed.

### Critical Thinking Questions

1.  After Increment 1 the check reported one failure and you committed anyway.  Explain why that commit was correct, and state the rule that tells you when a red test is an unfinished increment rather than a defect.

    *Hint: What did you ask for in Increment 1?  Does the failing test belong to that increment or the next one?*

2.  In Increment 2 the agent proposed a `slugify()` helper and a `__main__` block.  Predict what would have had to happen before you could reject them if there had been no plan gate, and say what that costs compared with the one sentence you typed.

3.  Suppose you had asked for both increments in one prompt.  Name the beat of the loop that disappears, and describe the specific mistake that beat exists to catch.

Which artifact in Model 1 caught the scope creep, and what did catching it there cost?

[(X)] The plan, at the cost of one sentence typed before any file changed
[( )] The test run, because the extra helper would have broken `test_slug_form`
[( )] The commit, because the change could be reverted afterward
[( )] The commit message, because "one line changed" would not have been true

---

# Part II: Setting Up the Karpathy Loop

## 2.  The Four Files

The loop is four files and one command repeated.  Two of the files you already have.

| File | What it does for the loop | Where it comes from |
|---|---|---|
| `spec.md` | The source of truth.  Every increment traces to one of its criteria | OpenCode Studio lab, Part 2 |
| `system_prompt.txt` | The prohibitions: what the agent must never touch | OpenCode Studio lab, Part 2 |
| `AGENTS.md` | The loop's rules, so you do not retype them every turn | You write it now |
| `opencode.json` | The permission block, so the tool enforces what the rules only request | You write it now |

**`AGENTS.md`** puts the loop in a file instead of in the chat.  A message you typed twenty turns ago is gone; this survives a restart.

```markdown
# Agent Contract

## The loop
- One increment per run.  An increment is one criterion from spec.md.
- Before editing, list the files you will change and why, then stop and wait.
- After editing, run the check and report its exact output.  Do not summarize it.

## Track your own work in git
- Commit every increment whose check passes.  The message names the criterion.
- When the check fails, restore the working tree and say so.  Never leave a
  failed increment half-applied for the next run to trip over.
- Append one entry to .ai/SESSION.md after every commit or restore.

## Report in plain sentences
- Say what you changed, what the check said, what you committed, and what is next.
- Name files and behavior, not line numbers.  Do not paste a patch.
- If you could not do something, say which part and why, before anything else.

## Never
- Do not edit spec.md, rubric.md, rubric.json, or system_prompt.txt.
- Do not edit a test to make it pass.
- Do not add helpers, entry points, or dependencies nobody asked for.
```

**`opencode.json`** is the part a rule alone cannot do.  `AGENTS.md` asks the agent not to touch `spec.md`; the permission block makes the tool refuse.  Values are `allow`, `ask`, or `deny`, keys are tool names, patterns use `*` and `?`, and the last matching rule wins.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "*": "ask",
    "bash": {
      "*": "ask",
      "git *": "allow",
      "python -m pytest*": "allow",
      "rm *": "deny"
    }
  }
}
```

Read it from the top.  Ask about everything.  Allow any `git` command and the check, because you will run both dozens of times and approving each one teaches you nothing.  Deny `rm` outright.  Everything else stops and asks, which is the setting you want all term.

Or ask opencode to do it:

```text
Write AGENTS.md at the project root with these rules: one increment per run, list
files before editing and stop, run the check and report its exact output, commit
every increment whose check passes with a message naming the criterion, restore the
working tree when a check fails, and append to .ai/SESSION.md after every commit or
restore.  Add a reporting rule: plain sentences saying what changed, what the check
said, what was committed, and what is next, naming files and behavior rather than
line numbers, and never pasting a patch.  Forbid editing spec.md, rubric.md,
rubric.json, system_prompt.txt, and any test.  Then write opencode.json with a
permission block that asks by default, allows "git *" and "python -m pytest*" under
bash, and denies "rm *".  Show me both files before you write them.
```

> **Checkpoint.**  Reopen the project after writing `opencode.json`, in the desktop application or by restarting `opencode` in that directory.  opencode reads the config from the folder it is working in, and a session that was already open does not pick up a file that did not exist when it started.

## 3.  Running One Increment

With the four files in place, an increment is one command:

```bash
opencode run "Make <the next check> pass.  Edit <the one file> only.  List the files you will change first, then stop."
```

Or ask opencode to do it: type the same sentence into the message bar.  The `run` subcommand and the message bar reach the same agent with the same contract; the only difference is where the transcript ends up.

Then the check, then the commit or the restore.  The agent can run all three for you, because `git` and `pytest` are already allowed:

```text
Run the check.  If it passes, commit with a message naming the criterion.  If it
fails, restore the working tree and tell me what the failure said.
```

### What the agent should tell you

The contract asked for plain sentences rather than a patch, and this is the shape it produces.  Four facts, in this order: what changed, what the check said, what was committed, what is next.

```text
Changed tools/titles.py so normalize_title lowercases the result and joins words
with hyphens.  No other file touched.

Check: python -m pytest tools/test_titles.py -q, 2 passed, 0 failed.

Committed as 4a91c2e "normalize_title: lowercase and hyphenate".

Next: test_rejects_empty_title does not exist yet, so the empty-string case has no
check to make pass.  Write that test before the next increment.
```

Read what that report does and does not ask of you.  It names a file and a behavior, so you can tell whether the agent did the thing you asked.  It quotes the check verbatim, so "it works" is never the evidence.  It names the commit, so you can go look if you want to.  And it ends by telling you what the loop is blocked on, which is the sentence that decides the next prompt.

Notice that you can accept or reject this increment without reading a line of the code.  The check is the evidence, and the commit is the record.  If the report and the check disagree, believe the check.

The whole run reads back the same way, because the agent committed as it went:

```bash
git log --oneline
```

```text
4a91c2e normalize_title: lowercase and hyphenate
7f30bd1 normalize_title: collapse whitespace
```

One line per increment, each one a criterion that passed its check.  That is the progress report for the session, and it costs nothing to produce because the loop built it along the way.

## 4.  Where the Loop's State Lives

Every increment produces two things: a commit, and a sentence about what happened.  The commit lives in `git`.  The sentence lives in the `.ai/` handoff directory from the *Governing Coding Agents* tutorial, which you created in Part 1 of the OpenCode Studio lab.

| File | The question it answers | When the Karpathy loop writes it |
|---|---|---|
| `.ai/CONTEXT.md` | "What is this project, and what do I read first?" | Almost never |
| `.ai/CURRENT_TASK.md` | "What exactly is in flight, and what is the next immediate action?" | When you pick the next increment |
| `.ai/SESSION.md` | "What just happened, what was verified, and what is the Next Safe Action?" | After every commit or restore |
| `.ai/FUTURE_WORK.md` | "Which good ideas are deliberately deferred?" | When you reject a plan for scope, as in Increment 2 |

Every `SESSION.md` entry ends with a **Next Safe Action**, which in the Karpathy loop is simply the next increment.  Here is the entry for Model 1's second increment, so you can see how short it is:

```markdown
## 2026-09-17 increment 2: normalize_title lowercases and hyphenates
- Verified by: python -m pytest tools/test_titles.py -q (2 passed)
- Rejected from plan: slugify() helper and __main__ block (moved to FUTURE_WORK.md)
- Next Safe Action: write test_rejects_empty_title before asking for the empty-string case
```

## Model 2: A Run Handed Everything at Once

Same repository, same `spec.md`, and a prompt with no increment, no gate, and no permission block in front of it.  The line numbers are for the questions.

```text
[1] you>    Implement spec.md end to end. Run the tests. Commit when they pass.
            I'll be back in an hour.
[2] agent>  Plan: edit artifact/search.py, artifact/test_search.py, spec.md (clarify the
            max_results default), requirements.txt (add rapidfuzz for scoring). Proceeding.
[3] agent>  Wrote artifact/search.py (212 lines). Wrote artifact/test_search.py (6 tests).
[4] agent>  pytest: 5 passed, 1 failed (test_missing_kb_exit_3)
[5] agent>  test_missing_kb_exit_3 expected exit 3 but got a traceback. Updated the test to
            expect SystemExit(1), which matches the implementation.
[6] agent>  pytest: 6 passed.
[7] agent>  Updated spec.md: max_results default is now 10 to match the implementation.
[8] agent>  git commit -am "Implement search feature per spec"
            [main 4f1c2e9] 4 files changed, 268 insertions(+), 9 deletions(-)
```

Every line after [1] is the agent doing what it was told.  That is the problem.

### Critical Thinking Questions

4.  Identify the first line at which a gate from Section 2 would have stopped this run, and name the gate.  Then identify the first line at which the run became **irreversible without `git`** and say what you would have to do to recover.

    *Hint: The plan in [2] names four files.  Compare it with the "Never" section of the `AGENTS.md` in Section 2 and with your own `system_prompt.txt`.*

5.  Lines [5] and [7] each change something other than `artifact/search.py`.  For each, say which rule it violates and which level of the source-of-truth hierarchy it silently overrode.  Which of the two is worse, and why?

    *Hint: One rewrites a check to match the code.  The other rewrites the specification to match the code.  Which one will the next reader believe?*

6.  Line [6] reports six passing tests.  Explain why "6 passed" is weaker evidence here than "2 passed" was in Model 1.

7.  Write the `permission` block that would have stopped line [7] at the tool rather than at the rule.  Then list the increments you would ask for instead of line [1], in order, one check each.

    *Hint: Your `spec.md` has five testing criteria.  Is one increment per criterion the right grain, or is the first increment smaller than that?*

In Model 2, which single gate, had it existed, would have prevented the most damage?

[( )] A check gate after [3], because the 212-line file was never verified
[(X)] A plan gate after [2], because the plan already named `spec.md` and `requirements.txt`, both forbidden, before any file changed
[( )] A commit gate before [8], because nothing is lost until it is committed
[( )] A test gate at [4], because one failure should have ended the run

> **Common Misconception:** "The agent committed, so the work is safe in `git`."  A commit preserves the state the agent produced, including the rewritten test and the rewritten spec.  `git revert` gets you back, but only if you notice, and the run was designed so that you would not be there to notice.  Reversibility is a property of the loop, not of the tool.

---

# Part III: Setting Up the Gauntlet Loop

## 5.  The Seven Steps

The Karpathy loop assumes a check already exists.  Often it does not: a document, a plan, a prompt, or a spec whose tests nobody has written.  The Gauntlet loop supplies the check by writing it first.  The procedure, in the order you run it:

1.  **Parse the task.**  Write down the objective, every explicit constraint and exclusion, the required output format, the scope, and any instruction that must remain unchanged.  Do not weaken a constraint to make the task easier.
2.  **Clear material fog.**  List every unresolved question that could change the result.  For each, choose the smallest fix: ask a targeted question, inspect the supplied context, run a small reversible experiment, or record an explicit assumption when the decision is low-risk and reversible.  When the fog is the codebase's to clear, plan mode is the cheap fix: opencode's `plan` agent reads and proposes but may not edit.
3.  **Write the rubric.**  Convert the source of truth into criteria with a stable identifier, an unambiguous pass condition, a verification method, and a materiality judgment.  Prefer criteria a program could decide.  Do not invent criteria to make the rubric look thorough.
4.  **Generate Candidate 0.**  The strongest first attempt you can make under the rubric.  Never make it weak on purpose so the loop looks productive later.
5.  **Critique adversarially.**  Attack the candidate against the rubric: failed criteria, unsupported claims, hidden assumptions, contradictions, counterexamples, false claims of verification.  Tie every finding to a criterion and label it material or not.
6.  **Revise.**  Fix every material defect inside the artifact, not as an appended caveat.  Never move a criterion to let a deficient candidate pass.
7.  **Verify and stop.**  Re-score the revised candidate against every criterion, not only the ones you changed.  Stop when the latest critique finds no material defect, or when the preset's round limit is reached.

The presets set the round limit and the depth of the critique: **quick** is at most one round, checking requirements, correctness, and clarity; **standard** is at most three rounds, adding reasoning, assumptions, edge cases, and feasibility; **rigorous** is at most five rounds, adding counterexamples, evidence quality, and independent verification.  A stricter preset is never permission to ignore the requested length, format, or scope.

## 6.  The Rubric, Two Ways

Step 3 is the one that makes the rest work, so write it in a file rather than in your head.  Two forms do the job, and the choice is about what you are checking rather than about rigor.

**Qualitative,** `rubric.md`.  Use it when a criterion needs a judgment that a person makes and a sentence can describe.  Levels, not points.

```markdown
# Rubric: search artifact

Accept when: every material criterion is at Meets.

| ID | Criterion | Meets | Approaching | Does not meet | Material | How to verify |
|----|-----------|-------|-------------|---------------|----------|---------------|
| K1 | Results sorted by score | Scores non-increasing | Sorted except ties | Unsorted | Yes | Query with three known matches |
| K4 | Missing knowledge base | Exit 3, message names the path | Exit 3, vague message | Traceback | Yes | Rename the file, run once |
| K6 | Default max_results | Returns 5 with no flag | n/a | Any other count | Yes | Run without the flag |
| K8 | No eval, exec, or network | grep finds nothing | n/a | Any hit | Yes | grep the source |
| N1 | Docstring style | "Returns" | "Return" | Absent | No | Read the file |
```

**Quantitative,** `rubric.json`.  Use it when the criteria are mechanical, you will score more than one candidate, and you want a number you can compare across rounds.

```json
{
  "threshold": 0.85,
  "criteria": [
    {"id": "K1", "requirement": "results sorted by score descending", "weight": 3, "material": true},
    {"id": "K4", "requirement": "missing knowledge base exits 3", "weight": 3, "material": true},
    {"id": "K6", "requirement": "default max_results is 5", "weight": 2, "material": true},
    {"id": "K8", "requirement": "no eval, exec, or network", "weight": 4, "material": true},
    {"id": "N1", "requirement": "docstrings say Returns", "weight": 1, "material": false}
  ]
}
```

Two rules keep either form honest.  A non-material criterion may fail without blocking convergence, which is why materiality is recorded per criterion rather than decided by whoever is reading the output.  And the weighted score is a summary, not the stopping rule: a candidate above the threshold with one material criterion failed has not converged.

One row of fog belongs beside the rubric.  Your spec says `score` is a float from 0 to 1 and never says how it is computed.  That is fog: two implementations can satisfy every criterion and rank documents differently.  The smallest fix is an explicit, recorded assumption ("any monotone relevance score normalized to [0, 1]; ranking quality is out of scope for this lab"), because the decision is low-risk and reversible.  Write it in `.ai/CONTEXT.md` so it outranks whatever the agent decides on its own.

Or ask opencode to do it:

```text
Read spec.md and system_prompt.txt.  Write rubric.md with one row per testing
criterion and per prohibition: ID, criterion, Meets, Approaching, Does not meet,
Material, and how to verify.  Then write rubric.json with the same IDs, a weight,
and a material flag for each, plus a threshold.  Do not invent criteria that are
not in spec.md or system_prompt.txt.  List anything in spec.md too vague to verify
instead of guessing at it.
```

## Model 3: One Gauntlet Round, Run With opencode

Use the **standard** preset, so the round limit is three and this is round one.

**Step 4, Candidate 0.**  Generate the strongest first attempt:

```bash
opencode run --agent plan "Read spec.md and rubric.md.  Propose an implementation of artifact/search.py.  Do not edit anything."
opencode run "Implement that plan in artifact/search.py and artifact/test_search.py only."
```

**Step 5, critique.**  A fresh session is the better critic, because the session that wrote the code is invested in it:

```bash
opencode run "Score artifact/search.py against every criterion in rubric.md.  For each: the ID, the level, material or not, and the evidence you ran.  Do not fix anything."
```

**Step 6, revise.**  One message naming every material failure and nothing else:

```bash
opencode run "Address only these material failures: K4, K6.  Do not change spec.md, rubric.md, rubric.json, system_prompt.txt, or any test."
```

**Step 7, verify.**  Re-score everything, not only what you changed, because a revision can break a criterion that passed:

```bash
opencode run "Re-score artifact/search.py against every criterion in rubric.md and report the table again."
```

The round repeats, so it is worth a script:

```bash
#!/usr/bin/env bash
# gauntlet.sh: run the gauntlet until it converges or the round limit is reached.
ROUNDS=${1:-3}
for ((r=1; r<=ROUNDS; r++)); do
  echo "== round $r =="
  opencode run "Score artifact/search.py against every criterion in rubric.md.  End your reply with exactly CONVERGED or REVISE." | tee "round_$r.txt"
  grep -q CONVERGED "round_$r.txt" && { echo "converged in $r round(s)"; exit 0; }
  opencode run "Address only the material failures you just reported.  Change nothing else."
done
echo "round limit reached without convergence"
```

Or ask opencode to do it: run the four prompts above in sequence in the message bar, and keep a count yourself.  The script only automates the counting and the stop condition, so the prompt-only route reaches the same place with you holding the round number.

If the verify step finds no material failure, the result has converged and you stop, with two rounds of budget unspent.  If not, round two starts from the failing criteria, not from a fresh read of everything.

### Critical Thinking Questions

8.  Before you run the critique, predict which criteria Candidate 0 will fail.  Then run it.  Which failures did you not predict, and what does that say about accepting an agent's output without a rubric?

9.  The docstring criterion is labeled non-material.  Write the one condition under which it would become material, and name who gets to set that condition.

10.  Your critique of Candidate 1 finds nothing.  Is that a failed critique or a converged result, and how would you tell the difference?

11.  A teammate proposes editing K6 to read "default is 5 or 10" so that Candidate 0 passes.  Explain, using the source-of-truth hierarchy, why the rubric cannot be changed for that reason, and state the one circumstance in which changing a criterion is legitimate.

Candidate 1 clears the weighted threshold, and K4 is still at "Does not meet."  What is the correct call?

[( )] Converged, because the weighted score cleared the threshold
[(X)] Not converged, because K4 is material, and clearing the threshold does not override a failed material criterion
[( )] Converged, because one failing criterion out of five is within tolerance
[( )] Not converged, but only until you lower K4's weight so the score reflects reality

## Code Cell

A rubric a program can score is a rubric you can re-run on every candidate without re-reading the spec.  The cell below loads the quantitative rubric from Section 6, scores a candidate's observed behavior, and applies both stopping rules.  Change the `candidate` values to what your Candidate 1 does and run it again.

```python
# The rubric is the file from Section 6.  The candidate is what you observed by
# running the verification methods, not what the code looks like.

RUBRIC = {
    "threshold": 0.85,
    "criteria": [
        {"id": "K1", "requirement": "results sorted by score descending", "weight": 3, "material": True},
        {"id": "K4", "requirement": "missing knowledge base exits 3",     "weight": 3, "material": True},
        {"id": "K6", "requirement": "default max_results is 5",           "weight": 2, "material": True},
        {"id": "K8", "requirement": "no eval, exec, or network",          "weight": 4, "material": True},
        {"id": "N1", "requirement": "docstrings say Returns",             "weight": 1, "material": False},
    ],
}

candidate = {
    "K1": True,
    "K4": False,      # traceback, exit 1
    "K6": False,      # default is 10
    "K8": True,
    "N1": False,      # says "Return"
}

def score(candidate, rubric):
    earned = total = 0
    material_failed = []
    for c in rubric["criteria"]:
        ok = bool(candidate.get(c["id"], False))
        total += c["weight"]
        earned += c["weight"] if ok else 0
        if not ok and c["material"]:
            material_failed.append(c["id"])
        tag = "meets" if ok else ("DOES NOT MEET" if c["material"] else "does not meet (non-material)")
        print(f"{c['id']}  w={c['weight']}  {tag:<28} {c['requirement']}")
    ratio = earned / total if total else 0.0
    print(f"\nweighted score {earned}/{total} = {ratio:.2f}, threshold {rubric['threshold']}")
    if material_failed:
        print("revise: material criteria failed: " + ", ".join(material_failed))
    elif ratio < rubric["threshold"]:
        print("revise: below threshold on non-material criteria")
    else:
        print("converged")

score(candidate, RUBRIC)
```
@Pyodide.eval

Read the last branch carefully.  A material failure blocks convergence no matter how high the score climbs, and the threshold only decides cases where everything material already passes.  That ordering is the whole reason the rubric records materiality per criterion instead of leaving it to whoever is reading the output.

---

# Part IV: Synthesis and Practice

## 7.  Which Loop, When

Use the Karpathy loop when a runnable check already exists or can be written in a minute, and the work decomposes into increments: implementing a spec with tests, refactoring, fixing a named bug.  Use the Gauntlet loop when the check does not exist yet or is not a program: a document, a plan, a prompt, a specification itself, or code whose tests you do not trust.

The two nest.  A gauntlet round's revision step is a Karpathy increment with the critique as its plan, and a Karpathy loop's first move on an untested feature is a quick gauntlet on the spec, to find the fog before the agent finds it for you.

## 8.  Loops That Run Themselves

Loops that remove you from the gate entirely exist, and this deck is where the course describes them: the agent finishes, a script restarts it, and it keeps going while you sleep.  Each iteration begins with a fresh context window, and the memory lives on disk: the codebase, a running `TODO` file, and the `git` history.

| Pattern | What it is | How it stops | Safety model |
|---|---|---|---|
| **Ralph loop** (Geoffrey Huntley) | A brute-force `while` loop that re-runs the same prompt file, iteration after iteration | A human stops it, or a "task complete" check in the prompt trips | Deliberately minimal: the test suite plus `git revert` |
| **autoresearch** (Karpathy's variant) | The same loop pointed at ML research instead of code | A target validation metric is reached | The metric is the guardrail; a worse score is discarded |
| **gnhf** ("good night, have fun") | An overnight orchestrator that splits a goal into small steps, each in a fresh context | A step budget, or the goal's acceptance check | Success commits; failure runs `git reset --hard` with backoff; worktrees isolate parallel agents |
| **firstmate** (a "crew") | An agent distro that turns one general agent into a coordinated crew | You end the primary session | One primary session delegates to sub-agents with narrower scope |

Every one of them is the Karpathy loop with the human gate replaced by a deterministic one, and every one of them is only as safe as that gate.  The controls that must exist before you let a loop run itself:

1.  A step budget, so a stuck loop cannot run up a bill.
2.  An acceptance check the loop cannot edit: held-out tests, a metric, or a rubric kept outside the files the agent may touch.  Model 2 line [5] is what happens when the agent can edit the check.
3.  Per-step rollback on a dedicated branch, so a failed iteration leaves nothing behind.
4.  Fresh context each iteration, with the state in `.ai/` and `git` rather than in a conversation.
5.  A human gate before merge.  The loop may commit to its branch all night; it does not merge to `main`.

### Auto mode, and the isolation it requires

A loop that stops to ask permission is not unattended, so these patterns need the permission prompts off.  opencode does that two ways.  The flag is `--auto`:

```bash
opencode --auto
opencode run --auto "Work the next item in TODO.md, run the check, and commit if it passes."
```

The configuration equivalent turns the whole permission block to `allow`:

```json
{ "permission": "allow" }
```

Two facts about the flag are worth having exactly right.  An explicit `deny` rule still applies under `--auto`, so a denied `rm *` stays denied.  And the desktop application has no flag to pass, so the configuration is the only route there.

**Do not run this on your own machine.**  An agent acting without prompts acts on the real filesystem, the real network, and the real credentials of whatever host it runs on, and it does so while you are asleep.  The only responsible place for auto mode is a container or a virtual machine you are willing to discard: no credentials you care about, no directories outside the project, and a snapshot to roll back to.

For everything in this course, leave the permission block at `ask`.  You are seeing auto mode so that you recognize it in somebody's setup instructions and know what it turns off, not so that you adopt it this semester.

Why does a Ralph loop start each iteration with a *fresh* context window instead of carrying the full conversation forward?

[( )] To reduce the number of API calls, since a fresh context uses fewer total tokens over the whole run
[( )] Because the model is legally required to discard prior context between runs
[(X)] Because the task's memory lives on disk (codebase, `TODO` file, `git` history), so each iteration can re-read exactly what it needs and avoid the context-overflow failure that plagues one very long session
[( )] Because a fresh context makes the agent more creative by preventing it from repeating earlier ideas

## 9.  Exercises

1.  *Set up and run the Karpathy loop.*

    - *What to do:* Write the `AGENTS.md` and `opencode.json` from Section 2 into your `cs357-work` repository.  Then implement your `spec.md` in at least three increments, each one a single `opencode run` or message-bar prompt, one check, and one commit or restore.  After each commit, append a `SESSION.md` entry in the shape of Section 4's example.
    - *You've succeeded when:* `git log --oneline` shows one commit per increment with a message naming its criterion, every agent report names what changed, what the check said, and what is next, each `SESSION.md` entry names the verifying command, at least one plan was rejected or narrowed before it ran, and your permission block stopped at least one command you had to approve by hand.

2.  *Write both rubrics and run one gauntlet round.*

    - *What to do:* Write `rubric.md` and `rubric.json` for your own `spec.md`, with at least eight criteria covering every testing criterion and every prohibition in `system_prompt.txt`.  Generate Candidate 0, run the critique, revise, and verify, using the commands in Model 3 or the prompts beside them.  Paste your criteria into the code cell and score both candidates.
    - *You've succeeded when:* Every finding maps to a criterion by ID, the code cell prints a weighted score and a verdict for Candidate 0 and Candidate 1, and you can say in one sentence whether the result converged or which criteria remain.

3.  *Write the permission file two ways.*

    - *What to do:* Write the `ask` block from Section 2 and the auto-mode configuration from Section 8 side by side.  For each, list what the tool would stop and what it would not.  Then write one paragraph naming the isolation you would require before running the second one, and one command it would allow that you would not want to discover the next morning.
    - *You've succeeded when:* Your two lists differ on at least three specific commands, you can state what `--auto` does *not* override, and the isolation paragraph names the credentials and directories at risk rather than only saying "use a VM."

---

## Reflection Prompt

*Personal:* Model 2's prompt is the one most people write the first time an agent works.  Have you written it, in this course or elsewhere?  What did you get back, and which of the four files from Section 2 would you now put in front of it?

*Technical:* In your notebook: the Karpathy loop's check comes from a test that exists; the Gauntlet loop's check comes from a rubric you wrote.  Pick one feature of your project and say which loop you would run first, what its first increment or first criterion would be, and where the fog is.

*Societal:* An unattended loop commits all night against a rubric it cannot edit.  If it ships a defect no criterion encoded, who is accountable: the person who wrote the rubric, the person who started the loop, or the team that merged the branch in the morning?  Argue for one and name the control from Section 8 that was missing.

-> Coming Up Next: Both loops today assumed you could tell a passing criterion from a failing one.  In *Hallucinations and Evaluating Agent Outputs*, we take up the harder case: an output that looks right, cites something, and is wrong, where no criterion you wrote catches it and the judge has to be built by hand.  Bring three prompts where a model gave you a confidently wrong answer; the rubric discipline from Model 3 is what we will apply to them.

---

## Further Reading

- This course: [AI-Assisted Development and Vibe Coding](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/VibeCoding), the three supervision levels and the spec-first development this deck builds on.
- This course: [Governing Coding Agents: Charters, Handoffs, and Durable Memory](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/AgentGovernance), the Karpathy rules beside a production charter, and the `.ai/` handoff directory in full.
- This course: [Coding Agents: OpenCode, Spec-First Development, Hooks, and Reading the Diff](https://www.billmongan.com/LiaScript/?https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/_pages/Activities/liascript-codingagents.md), Section 2c on plan mode and Part IIb on the permission block and plugin hooks.
- This course: [Lab: OpenCode Studio](https://www.billmongan.com/Ursinus-CS357-Fall2026/Assignments/OpenCodeStudio), the `spec.md`, `system_prompt.txt`, and rubric that Model 3 runs against.
- opencode permissions and CLI: https://opencode.ai/docs/permissions/ and https://opencode.ai/docs/cli/, the source for the `permission` block, the pattern rules, and the `--auto` flag.
- Andrej Karpathy, [`llm-wiki.md`](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) (gist, April 2026): the pattern behind keeping the agent's memory in files it maintains and you curate.
- Andrej Karpathy.  "Software 2.0."  *Medium* (2017).
- Geoffrey Huntley.  "everything is a ralph loop." https://ghuntley.com/loop/, the origin and rationale of the fresh-context brute-force loop; see also https://ralph-wiggum.ai/.
- **gnhf** ("good night, have fun"), overnight autonomous orchestrator: https://github.com/kunchenguid/gnhf.
- **firstmate**, an agent distro for running a crew: https://github.com/kunchenguid/firstmate.
