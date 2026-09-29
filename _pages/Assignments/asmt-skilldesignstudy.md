---
layout: assignment
permalink: /Assignments/SkillDesignStudy
title: "CS357: Foundations of Artificial Intelligence - Written Assignment: Skill Design Study"

info:
  coursenum: CS357
  purpose: "To turn a prompt you would otherwise retype into a skill an agent loads on its own, by writing one skill with a persona, a guided interview, and a worked example, installing and running it in opencode, and refining it until it does what you meant."
  tilt:
    task: "Write one skill of your own, install it in opencode, confirm it fires on the right request and stays quiet on the wrong one, then run and refine it at least three times, logging each response and each change you made in response to it."
    criteria: "I grade this on the design of the skill (persona, guided interview, worked example, and rules), on whether it is installed and running in opencode, on the refinement log, and on your reflection.  The rubric below spells out each row."
  points: 100
  goals:
    - To write a skill as a SKILL.md directory that opencode loads by name, with a description that fires on the intended request and not on others
    - To give a skill a persona that changes what it says, not only how it sounds
    - To have a skill interview its user with guided, menued questions before it produces anything, and to show it the format with a worked example
    - To state a skill's behavior as numbered, checkable rules, including optional guardrails and an optional structured-output rule
    - To refine a skill iteratively, logging each response and the change it prompted, until the skill does what you meant
  rubric:
    - weight: 35
      description: "Skill Design: Persona, Interview, and Rules"
      preemerging: No SKILL.md is submitted, or the skill is the tutorial's commit-tidy skill resubmitted unchanged
      beginning: A SKILL.md is submitted, but it is missing two or more of the persona, the guided interview, the worked example, and the numbered rules, or its rules are vague ("be helpful") rather than checkable
      progressing: The skill has a persona, an interview instruction, a worked example, and numbered rules, but one of them is thin, for example a persona that changes only the tone, interview questions without lettered options or a default, or an example that does not match the rules
      proficient: The skill's persona names who it is, what it knows, and who it serves, and changes the content of its replies; it interviews the user with numbered, menued questions (lettered options and a stated default, a few per round) and deepens on the answers before producing anything; SKILL.md contains a worked example of the interview turn and of the final output that matches the rules; the rules are numbered and each one is checkable by reading a reply; any guardrail or structured-output rule is stated as a rule, and the writeup says whether the skill is meant for a human or for an agent calling it
    - weight: 20
      description: Installed and Running in opencode
      preemerging: The skill is not installed, or no run is reported
      beginning: The skill is installed, but it never loads (for example, the directory name does not match the name field) and the writeup does not say what was tried
      progressing: The skill loads and fires on its intended request, but the negative test (a request it should ignore) is missing, or the description field is not quoted
      proficient: The skill is committed at .agents/skills/<name>/SKILL.md, loads in opencode, fires on a stated request and stays quiet on a stated out-of-scope request, and the writeup quotes the description field verbatim with both outcomes
    - weight: 30
      description: Refinement Log
      preemerging: No log is submitted
      beginning: Fewer than three iterations are logged, or the log shows responses without the change made in reply to them
      progressing: At least three iterations are logged with verbatim response excerpts and the change made each time, but the reasons are thin, or several things changed at once so the effect of each cannot be seen
      proficient: At least three iterations are logged; each names what was wrong in the verbatim response, the one change made to SKILL.md in reply, why that change should help, and what the next run showed, including any change that made things worse; the final iteration shows the skill doing what the student intended
    - weight: 15
      description: Reflection, Writeup, and Submission
      preemerging: An incomplete submission is provided
      beginning: The submission is missing the final SKILL.md, the log, or the reflection answers
      progressing: All parts are present, with one minor omission such as the model or opencode version
      proficient: A single PDF contains the final SKILL.md, the trigger tests, the refinement log, the reflection answers, the model name and version and the opencode version, and a link to the committed skill directory; if the optional Ollama run was done, its transcript is included
  readings:
    - rtitle: "Skills: Design One, Then Measure It Activity"
      rlink: "Activities/liascript-skills.md"
      liapage: true
    - rtitle: "Lab: OpenCode Studio, whose project and typed kickoff interview this assignment packages into a skill"
      rlink: "Assignments/OpenCodeStudio"
    - rtitle: "Prompt Engineering Activity"
      rlink: "Activities/liascript-promptengineering.md"
      liapage: true
    - rtitle: "Agent Skills and Plugins Tutorial"
      rlink: "../Tutorials/AgentSkills"

tags:
  - skills
  - prompting
  - written
  - ai

---

In this assignment you write one skill, install it in opencode, run it, and refine it until it does what you meant.  A skill is an instruction you would otherwise retype at the start of a conversation, saved as a file that an agent loads on its own when your request matches its trigger.  The skill you write gives the model a persona, has it interview you with guided questions before it produces anything, and shows it a worked example of what a good exchange looks like.  Then you run it, read what it actually does, change one thing, and run it again, keeping a log as you go.  See the course schedule for the assigned and due dates.

---

## Before You Start

**This builds on** the *Prompt Engineering as Agent Design* session and the *Skills: Design One, Then Measure It* session.  Both are taught before this is due.

**It also builds on the OpenCode Studio lab**, which is due before this assignment.  Work inside the project you configured there, or any repository with an `AGENTS.md`.

You need opencode, configured against your local model as in Week 1, Step 8.2.  Confirm it is working before anything else:

```bash
opencode --version
```

Then start `opencode`, type `/model`, and confirm your provider appears.  The OpenCode desktop app is equally fine: pick your model from its model picker instead of typing `/model`.

> **Time budget.** The Stage 1 tutorial takes about fifteen minutes.  Writing the first version of your skill takes under an hour.  Budget most of your time for Stage 3, the run-and-refine loop, because that is where the skill gets good.

---

## What a Skill Is

A skill is a directory containing a `SKILL.md` file, and that really is the whole mechanism: there is no registry and no install command, because the tool simply walks the filesystem, finds the directory, reads the front matter, and offers the skill to the model. One happy consequence is that you can read exactly what you installed before you ever run it, which is not true of most things you install.

Both opencode and pi walk up from your working directory to the repository root, then fall back to your home directory:

| | Project-level | User-level |
|---|---|---|
| **opencode** | `.opencode/skills/`, `.claude/skills/`, `.agents/skills/` | `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/` |
| **pi** | `.pi/skills/`, `.agents/skills/` | `~/.pi/agent/skills/`, `~/.agents/skills/` |

**On Windows.**  The same paths, with backslashes and `%USERPROFILE%` in place of `~`: `.opencode\skills\`, `.claude\skills\`, and `.agents\skills\` inside a project, and `%USERPROFILE%\.config\opencode\skills\`, `%USERPROFILE%\.claude\skills\`, and `%USERPROFILE%\.agents\skills\` globally.  Win+R and pasting a folder path opens any of them.  Because a skill is a directory rather than a registry entry, copying the folder there in File Explorer is a complete installation.

Use `.agents/skills/`, which both read, so your skills are not welded to one tool.  Put it in the **project** path, at the root of the repository you are working in, which is what this assignment asks for and what the deliverable links to.  opencode also reads `~/.config/opencode/skills/` globally, and that is the right home for a skill you want in every project later; it is not what you submit here, because a project path is the one a reviewer can clone and check.

Two rules about the front matter account for almost every failure you are likely to hit.

1. **The directory name must match the `name:` field**, so `.agents/skills/commit-tidy/SKILL.md` goes with `name: commit-tidy`. When they disagree the skill never loads, and nothing tells you so.
2. **The `description` is the matching surface rather than documentation.** The model reads it to decide *when* to invoke the skill, which means it has to state a trigger in the words a user would actually type instead of naming a topic.

That second rule decides whether a skill ever runs at all, and it is worth seeing the difference side by side:

```text
Topic   (never fires):  "Session setup helper."
Trigger (fires):        "Use at the start of any session, or whenever the user asks to
                         start, resume, continue, or pick up work on this project."
```

> **Common misconception:** a skill on disk is not followed automatically on every turn the way a system prompt is. Being on disk *surfaces* a skill. The agent *invokes* it by recognizing the situation, or because you name it. For always-on behavior, `AGENTS.md` is the right instrument. For composable behavior you invoke selectively, a skill is correct.

## Stage 1: Install and Invoke a Skill I Wrote (Tutorial, Ungraded)

Run this once, end to end, before you write anything of your own. It takes about fifteen minutes, none of it is submitted, and it exists so that the mechanics are behind you before any of your work is being graded on them.

**Step 1.** Work in the `opencode-studio` project from the OpenCode Studio lab, or any repository with an `AGENTS.md`. Create the directory and the file:

```bash
mkdir -p .agents/skills/commit-tidy
cat > .agents/skills/commit-tidy/SKILL.md <<'EOF'
---
name: commit-tidy
description: Use whenever the user asks to write, fix, improve, or reword a git commit message.
---

You write git commit messages.

## Rules
1. The subject line is 50 characters or fewer.
2. The subject line uses the imperative mood: "Add", not "Added" or "Adds".
3. The subject line does not end in a period.
4. A blank line separates the subject from the body, when a body is present.
5. Reply with the commit message only: no code fence, no greeting, no commentary.
EOF
```

**Step 2: confirm it loads.** Start opencode in that directory and list your skills. If `commit-tidy` does not appear, the directory name and the `name:` field disagree, or the front matter is malformed. Fix that before continuing; nothing below works until the skill loads.

**Step 3: make it fire.** Type a request that matches the description, such as: `Write a commit message for a change that adds retry logic to the search client.` Watch the skill load, and check the reply against the five rules.

**Step 4: make it stay quiet.** Type something out of scope, such as `What does git rebase do?`, and confirm the skill does not fire. Testing the negative case matters as much as testing the positive one, because a skill that triggers on everything trains you to ignore it, and an ignored skill is worse than no skill at all.

**Step 5: break it on purpose.** Change the `description` to the single word `Commits.`, restart opencode, and repeat Step 3; it will not fire. Change it back when you have seen that, at which point you have met both of the failure modes your own skill has to avoid.

---

## Stage 2: Write Your Skill

Pick one job you would like an agent to do the same way every time.  Good choices are jobs where the agent should *ask before it acts*: planning a study schedule, scoping a project task, drafting a cover letter, preparing for a meeting, writing a test plan.  A job that needs information only you have is a job that benefits from an interview.

Create the directory and file, named for your skill:

```bash
mkdir -p .agents/skills/study-planner
# then create .agents/skills/study-planner/SKILL.md in your editor
```

Build `SKILL.md` in the five pieces below, in this order.

### (a) The trigger: the `description`

Write the `description` first, in the words a user would actually type, as a situation rather than a topic.  "Study planning helper" never fires.  "Use when the user asks to plan, schedule, or organize their studying for an exam, a course, or a week" does.  Write down now one request that should fire the skill and one that should not; you test both in Stage 3.

### (b) The persona

A persona tells the model who is answering.  A good one changes *what* the skill says, not only how it sounds, because it conditions the model on the vocabulary, priorities, and habits of an expert in that role.  Name three things: who the skill is, what it knows, and who it serves.

```text
You are an academic success coach who has helped hundreds of first- and second-year
college students plan their studying.  You know spaced practice, retrieval practice,
and how long real students can focus.  You serve a student who is busy, a little
behind, and needs a plan they will actually follow.
```

Compare what a bare "make me a study plan" produces with what the same request produces under this persona.  The bare model tends to hand back a generic week of two-hour blocks; the coach asks what the exam covers and front-loads retrieval practice.  That difference in content, not just in tone, is what a persona is for.

### (c) The interview: guided, menued questions

Tell the skill to interview the user before it produces anything, and to make the interview easy to answer.  Menued questions (a short numbered list, each with lettered options and a default) get better answers than open questions, because the user can reply with a few letters and the options themselves show what the skill needs to know.  Tell it to go deeper on the answers: when a reply is vague or surprising, ask one follow-up about it before moving on.

Write the interview as instructions, for example:

```text
## Interview
Before producing anything, interview the user.
- Ask at most three numbered questions per round, never one long wall of text.
- Give every question lettered options and a stated default.
- After each round, ask one follow-up about any answer that is vague or surprising.
- Stop interviewing when you can state the goal, the constraints, and what "done" means,
  then read those three back and ask the user to confirm before you continue.
```

### (d) The worked example (few-shot)

A description of the format is weaker than a demonstration of it.  Put one worked example inside `SKILL.md`: one interview round as it should look, and the shape of the final output.  The model imitates examples closely, so the example becomes the format; make sure it follows your own rules exactly, because it will copy mistakes too.

```text
## Example of an interview round
Before I build your plan, three questions.

1. What are you preparing for?
   a) a midterm   b) a final   c) something else (tell me)          [default: a]
2. How many days do you have?
   a) under 3     b) 3 to 7    c) more than a week                  [default: b]
3. How much time can you give it on a typical day?
   a) under 1 hour   b) 1 to 2 hours   c) more than 2 hours         [default: b]

Reply with three letters, for example "a b b".

## Example of the final output
Goal: Midterm in CS357, Thursday.   Constraint: about 90 minutes a day.
Day 1: 30 min retrieval quiz on Weeks 1-3 ...
```

### (e) The rules

End the skill with numbered rules, each one something you could check by reading a reply.  "Be helpful" is not a rule, because nothing settles it.  "Never produce the plan before the user has confirmed the read-back" is, because a reply either does that or it does not.  Guardrails go here too, stated just as concretely: "If the user asks you to complete a graded assignment for them, decline and offer to plan the work instead."

**Optional: structured output.**  Your skill is meant for a person, and a skill that replies in readable prose is completely fine.  Sometimes, though, a skill is invoked by another *agent* rather than by a human, and then the caller has to parse the reply.  In that case you can add a rule that fixes the output's shape, for example "End your final reply with a JSON object with exactly the keys `goal` (string), `days` (integer), and `sessions` (array of strings), and nothing after it."  Naming the keys and ruling out everything else is what makes the output reliable enough for a program to read.  Add this only if you have a programmatic caller in mind, and say in your writeup which audience your skill is for.

---

## Stage 3: Install It, Run It, and Refine It

**Step 1: install and load.**  Your skill lives at `.agents/skills/<name>/SKILL.md` in the project, with the directory name matching the `name:` field.  Restart opencode and confirm the skill is listed.

**Step 2: test the trigger.**  Type the request you wrote down that should fire the skill, and confirm it loads.  Then type the request that should not, and confirm it stays quiet.  Record both outcomes and quote your `description` verbatim.

**Step 3: run, read, change one thing, run again.**  Use the skill for real, answering its questions the way a real user would.  Read the whole response against what you meant and against your own rules.  Pick the one thing most wrong with it, change one thing in `SKILL.md` to fix it, restart opencode, and run the same request again.  Change one thing at a time; if you change three, you will not know which one helped.

Keep a log of at least three iterations, more if the skill needs them, and stop when it does what you meant:

| Iteration | What was wrong (quote the response) | The one change made to SKILL.md | Why that change should help | What the next run showed |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

Changes that make things worse belong in the log too.  A persona that made the skill preachy, or an example it copied too literally, is exactly the kind of finding this assignment is for.

> **Common misconception:** a skill that works once is finished.  Run it at least twice on your final version.  Two runs of the same request will not match word for word, and seeing how much they differ tells you which rules are holding and which are luck.

---

## Optional: Run Your Skill from Python Against Ollama

opencode is not the only way to use a skill.  Because a skill is just text, you can load it yourself and hand it to a model directly.  This is optional and carries no points, but it shows you what the agent is doing under the hood: the body of `SKILL.md` becomes the system message.

With Ollama running and your model pulled (`ollama pull llama3.2`), save this as `run_skill.py` in the project root and run `python3 run_skill.py .agents/skills/study-planner/SKILL.md`:

```python
import sys
import traceback

import requests

OLLAMA_URL = "http://localhost:11434/api/chat"
MODEL = "llama3.2"


def load_skill(path):
    """Read SKILL.md and return its body, without the front matter."""
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    if text.startswith("---"):
        # The front matter sits between the first two --- lines.
        text = text.split("---", 2)[2]
    return text.strip()


def chat(messages):
    """Send the conversation so far to Ollama and return the reply text."""
    response = requests.post(
        OLLAMA_URL,
        json={"model": MODEL, "messages": messages, "stream": False},
        timeout=300,
    )
    response.raise_for_status()
    return response.json()["message"]["content"]


def main():
    try:
        skill = load_skill(sys.argv[1])
    except Exception as e:
        print(f"[run_skill:load_skill] {e}")
        traceback.print_exc()
        return

    messages = [{"role": "system", "content": skill}]
    print("Type your request.  Type 'quit' to stop.")
    while True:
        user = input("> ").strip()
        if user.lower() == "quit":
            break
        messages.append({"role": "user", "content": user})
        try:
            reply = chat(messages)
        except Exception as e:
            print(f"[run_skill:chat] {e}")
            traceback.print_exc()
            break
        messages.append({"role": "assistant", "content": reply})
        print(reply)


if __name__ == "__main__":
    main()
```

The `messages` list is the whole conversation, sent again on every turn; that is how the model "remembers" your earlier answers to its interview.  Notice what this script does *not* do: it never decides whether the skill should fire, because you loaded it by hand.  That trigger decision is the part opencode adds.  If you try this, include a short transcript and one sentence on whether the skill behaved the same as it did in opencode.

---

### Troubleshooting: The Skill Never Fires

Work down this list. The first four cover nearly every case, and the full version, with the cross-tool details, is in [Agent Skills and Plugins]({{ site.baseurl }}/Tutorials/AgentSkills).

1. The directory name and the `name:` field differ. They must match exactly, including case and hyphens.
2. The `description` names a topic instead of a situation. "Docstring helper" never fires. "Use when the user asks to write, add, or fix a docstring for a function" does. Put the words a user types into the description.
3. The skill is in the wrong place. opencode walks up from your working directory looking for `.agents/skills/`, so start it inside the project that holds the directory, or move the skill to `~/.agents/skills/`.
4. You started opencode before the file existed. Skills are read at startup, so restart the session.
5. The front matter is malformed. Both `---` lines must be present, `name:` and `description:` must each be on one line, or use the `>` block form for a long description, and no blank line may precede the first `---`.
6. A `permission` block in `opencode.json` is denying the `skill` tool. Check the permission settings you wrote in the OpenCode Studio lab. A skill matched by a `deny` pattern is hidden from the agent rather than reported to you, and a `"*": "ask"` wildcard will prompt rather than load silently.
7. `SKILL.md` is not spelled in capitals. `Skill.md` and `skill.md` are not read.
8. Two skills share a name. Names must be unique across every discovery path at once, so a skill in `~/.agents/skills/` can quietly win over the one you just wrote in the project.

If the trigger still fails after all eight, report the failure honestly, say which of the eight you ruled out, and name the skill explicitly in your request so you can still run and refine it.  Say in your writeup that your log covers the skill's instructions rather than its trigger.

---

## Frequently Asked Questions

**Q: Can I submit the `commit-tidy` skill from the Stage 1 tutorial?**
A: No.  Stage 1 is a tutorial and is not graded.  Use it as a model for the shape.

**Q: Does my skill need structured output?**
A: No.  A skill written for a person, replying in readable prose, is fine and is the default.  Add a structured-output rule only if you imagine another agent calling your skill and parsing its reply, and say so in your writeup.

**Q: How many iterations are enough?**
A: At least three logged ones, and as many more as it takes for the skill to do what you meant.  A log that stops at three while the skill is still wrong is less convincing than one that shows five and a skill that works.

**Q: My change made the skill worse.  Should I leave it out of the log?**
A: No.  Log it, say why you think it backfired, and show what you did next.  That is some of the most useful evidence in the assignment.

**Q: Which model should I use?**
A: Whichever one your opencode is configured against.  Name it and its version in your writeup.

---

## Deliverables

Submit a single PDF containing:
- The final `SKILL.md`, and a one-line note on whether it is written for a human user or for an agent caller
- The trigger tests: your `description` quoted verbatim, one request that fired the skill, and one that correctly did not
- The refinement log (at least three iterations), with verbatim response excerpts
- A transcript of one full run of the final version
- Your reflection answers
- Software version information: the model name and version, and the opencode version
- A link to the skill directory committed on GitHub at `.agents/skills/<name>/SKILL.md`
- Optional: the Ollama transcript and your one-sentence comparison

---

## Reflection Prompts

- Which of your changes made the biggest difference to what the skill did, and why do you think that one mattered most?
- Did the persona change *what* the skill said, or only how it sounded?  Point to a line in a response that shows it.
- You typed a kickoff interview by hand in the OpenCode Studio lab.  What did packaging it as a skill actually buy you, and what did it cost?

---

## Self-Check Before You Submit

- [ ] The skill is my own, its directory name matches its `name:` field, and it is committed at `.agents/skills/<name>/SKILL.md`.
- [ ] The `description` states a situation in a user's words, and I tested one request that fires it and one that does not.
- [ ] The skill has a persona that changes the content of its replies.
- [ ] It interviews the user with numbered questions, lettered options, and a default, and asks a follow-up on vague answers.
- [ ] `SKILL.md` includes a worked example that follows its own rules.
- [ ] Every rule is numbered and checkable by reading a reply.
- [ ] If I added structured output, I said who the programmatic caller is.
- [ ] The log has at least three iterations, one change each, with verbatim excerpts, including any change that made things worse.
- [ ] The model name and version and the opencode version are stated.
