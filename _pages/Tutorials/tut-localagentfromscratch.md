---
layout: textbook
permalink: /Tutorials/LocalAgentFromScratch
title: "CS357: Foundations of Artificial Intelligence - Building a Local Agent From Scratch: Prompt, Remember, Iterate, Skill, Command"
info:
  coursenum: CS357
  purpose: "To compose the five small programs from Running Your Own AI into one working agent, so that each piece is already familiar before you see how the pieces fit, and to show that the safety of an agent that runs commands comes from gates in its code rather than from instructions in its prompt."
  eyebrow: "Tutorial"
tags:
- agents
- ollama
- skills
- permissions
---

## About This Tutorial

This tutorial puts the five steps from *Running Your Own AI* into one program, `tiny_agent.py`.  It is about 150 lines, and every function in it is one you already wrote: `chat()` from Step 1, the history file from Step 2, the loop from Step 3, the skill loader from Step 4, and the gated command runner from Step 5.  Nothing here is new except the arrangement, plus two safety additions that Step 5 left as questions: an allowlist and a per-turn command budget.

Read it after you have run all five step files yourself.  If a piece here looks unfamiliar, go back to that step and run it alone first.  That is the order this course uses for every tool: each piece in isolation, then the pieces together.
{: .tb-lede}

---

## Key Concepts

| Term | Plain-English Definition | Example You'll See |
|------|--------------------------|--------------------|
| **Agent loop** | Read the person's message, call the model, act on the reply, and repeat | `main()` and `take_turn()` |
| **History file** | The file where the conversation is saved after every turn and read back at startup | `history.json` |
| **Skill** | A Markdown file of rules that the program reads and adds to the system prompt | `.agents/skills/terse-helper/SKILL.md` |
| **Protocol** | The exact reply format the model must use to ask for an action | `RUN: <command>` on a line by itself |
| **Allowlist** | The list of programs the agent may ever run; anything else is refused without asking | `"allowed_commands"` in `config.json` |
| **Permission gate** | A check in code, on the only path that runs a command, that the model cannot skip | `gate()` |
| **Budget** | A limit that guarantees a turn ends, even if the model keeps asking for commands | `"max_commands_per_turn": 3` |

---

## Part I: One Program, Five Familiar Pieces

Here is where each step landed.  The section comments in `tiny_agent.py` use the same step numbers.

| Step | Where it lives now | What changed from the step file |
|---|---|---|
| 1. Prompt | `chat(cfg, messages)` | Model, URL, and temperature come from `config.json` |
| 2. Remember | `load_history()`, `save_history()` | The path comes from `config.json`; errors are reported, not fatal |
| 3. Iterate | `main()` | Also handles an empty line and end of input |
| 4. Skill | `load_skill()`, `build_system()` | A missing skill logs a warning and the agent runs without it |
| 5. Command | `gate()`, `run_command()`, `take_turn()` | Two gates instead of one, and a budget of commands per turn |

### Questions

1.  Which function would you change to switch from Ollama to OpenWebUI's endpoint?  How many other functions would have to change?

2.  `build_system()` runs every time the program starts, even when `history.json` already holds a system message.  Why is that the right choice for a skill you are still editing?

---

## Part II: Settings Live in a File

Every value you might want to change without editing code is in `config.json`.  Save this file next to `tiny_agent.py`:

```json
{
  "provider_url": "http://localhost:11434",
  "api_key": null,
  "model": "llama3.2",
  "temperature": 0.2,
  "history_path": "history.json",
  "skill_path": ".agents/skills/terse-helper/SKILL.md",
  "allowed_commands": ["ls", "pwd", "date", "wc", "head", "cat", "grep", "python3"],
  "command_timeout": 20,
  "max_commands_per_turn": 3,
  "log_level": "INFO"
}
```

Three settings deserve a sentence each.  `provider_url` can be overridden by the `OLLAMA_URL` environment variable, so the same file works inside a container, and `api_key` stays `null` for local Ollama.  To use a hosted provider instead, set `provider_url` to its full chat endpoint and `api_key` to your key: for ursinus.ai, `"provider_url": "https://ursinus.ai/api/chat/completions"`, with `model` set to a name the service lists.  A URL ending in `/chat/completions` gets the OpenAI request and reply shape; any other URL is treated as an Ollama server's base address.  Keep a `config.json` that holds a key out of any repository you push.  `allowed_commands` is the first gate, described in Part IV.  `log_level` accepts `DEBUG`, `INFO`, `WARNING`, or `ERROR`; at `INFO`, every command the agent runs or refuses is logged.

### Questions

3.  Why is the allowlist in `config.json` rather than in `TOOL_RULE`, where the model could read it?  Could it be in both?

---

## Part III: The Program

Save this as `tiny_agent.py`.  Create the Step 4 skill if you have not already (the `mkdir` and `cat > .agents/skills/terse-helper/SKILL.md` commands in Section 4d of the deck).

```python
"""tiny_agent.py: the five steps from Running Your Own AI, composed into one program.

prompt (chat) -> remember (history file) -> iterate (loop) -> skill (SKILL.md) -> command (gated run)
"""
import json, logging, os, re, shlex, subprocess, sys, traceback
import requests

log = logging.getLogger("tiny_agent")

TOOL_RULE = ("You can ask to run one shell command at a time.  To do that, reply with exactly one line: "
             "RUN: <command>.  You will then receive its output as an Observation.  "
             "Pipes and redirection are not available.  Otherwise, answer normally.")

def load_config(path="config.json"):
    try:
        with open(path, encoding="utf-8") as f:
            cfg = json.load(f)
        cfg["provider_url"] = os.environ.get("OLLAMA_URL", cfg["provider_url"])   # the container override
        return cfg
    except Exception as e:
        print(f"[tiny_agent:load_config] {e}")
        traceback.print_exc()
        sys.exit(1)

# Step 1: prompt
def chat(cfg, messages):
    try:
        url = cfg["provider_url"].rstrip("/")
        headers = {"Authorization": f"Bearer {cfg['api_key']}"} if cfg.get("api_key") else {}
        if url.endswith("/chat/completions"):
            # OpenAI-style providers (ursinus.ai, other hosted services): the full endpoint URL,
            # temperature at the top level, and the reply nested under choices[0].
            r = requests.post(url, headers=headers, json={
                "model": cfg["model"], "stream": False,
                "temperature": cfg["temperature"],
                "messages": messages}, timeout=120)
            r.raise_for_status()
            return r.json()["choices"][0]["message"]
        # Ollama (local or hosted): the server's base URL, temperature under "options".
        r = requests.post(f"{url}/api/chat", headers=headers, json={
            "model": cfg["model"], "stream": False,
            "options": {"temperature": cfg["temperature"]},
            "messages": messages}, timeout=120)
        r.raise_for_status()
        return r.json()["message"]
    except Exception as e:
        print(f"[tiny_agent:chat] {e}")
        traceback.print_exc()
        return {"role": "assistant", "content": ""}

# Step 2: remember
def load_history(cfg):
    try:
        with open(cfg["history_path"], encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return [{"role": "system", "content": ""}]
    except Exception as e:
        print(f"[tiny_agent:load_history] {e}")
        traceback.print_exc()
        return [{"role": "system", "content": ""}]

def save_history(cfg, messages):
    try:
        with open(cfg["history_path"], "w", encoding="utf-8") as f:
            json.dump(messages, f, indent=2)
    except Exception as e:
        print(f"[tiny_agent:save_history] {e}")
        traceback.print_exc()

# Step 4: skill
def strip_front_matter(text):
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return text.strip()
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            return "\n".join(lines[i + 1:]).strip()
    return text.strip()

def load_skill(cfg):
    try:
        with open(cfg["skill_path"], encoding="utf-8") as f:
            return strip_front_matter(f.read())
    except FileNotFoundError:
        log.warning("no skill at %s; running without one", cfg["skill_path"])
        return ""

def build_system(cfg):
    system = "You are a concise assistant.\n\n" + TOOL_RULE
    skill = load_skill(cfg)
    if skill:
        system += "\n\nFollow these rules exactly:\n\n" + skill
    return system

# Step 5: command, behind two gates
def gate(cfg, cmd):
    """Return (allowed, reason).  Gate 1 is the allowlist (deny); gate 2 is the person (ask)."""
    try:
        argv = shlex.split(cmd)
    except ValueError as e:
        return False, f"could not parse the command: {e}"
    if not argv or argv[0] not in cfg["allowed_commands"]:
        return False, f"'{argv[0] if argv else cmd}' is not on the allowlist {cfg['allowed_commands']}"
    print(f"[the model wants to run]  {cmd}")
    if input("Type YES to allow it: ").strip() != "YES":
        return False, "the user declined to run that command"
    return True, "approved"

def run_command(cfg, cmd):
    try:
        done = subprocess.run(shlex.split(cmd), capture_output=True, text=True,
                              timeout=cfg["command_timeout"])
        return f"exit code {done.returncode}\n{done.stdout}{done.stderr}"[:2000]
    except Exception as e:
        print(f"[tiny_agent:run_command] {e}")
        traceback.print_exc()
        return f"the command failed to start: {e}"

def take_turn(cfg, messages, user_text):
    messages.append({"role": "user", "content": user_text})
    reply = chat(cfg, messages)
    messages.append(reply)
    for _ in range(cfg["max_commands_per_turn"]):       # a budget, so a turn always ends
        match = re.search(r"^\s*RUN:\s*(.+)$", reply["content"], re.MULTILINE)
        if not match:
            break
        cmd = match.group(1).strip().strip("`")
        allowed, reason = gate(cfg, cmd)
        observation = run_command(cfg, cmd) if allowed else f"Not run: {reason}."
        log.info("command %r -> %s", cmd, "ran" if allowed else reason)
        messages.append({"role": "user", "content": f"Observation: {observation}"})
        reply = chat(cfg, messages)
        messages.append(reply)
    return reply["content"]

# Step 3: iterate
def main():
    cfg = load_config()
    logging.basicConfig(level=getattr(logging, cfg.get("log_level", "INFO")),
                        format="[%(levelname)s] %(message)s")
    messages = load_history(cfg)
    messages[0] = {"role": "system", "content": build_system(cfg)}   # skill re-read on every start
    log.info("model %s at %s, %d messages remembered", cfg["model"], cfg["provider_url"], len(messages) - 1)
    print("Type a message.  /forget erases the memory file, /quit exits.")
    while True:
        try:
            user_text = input("you> ").strip()
        except EOFError:
            break
        if user_text == "/quit":
            break
        if user_text == "/forget":
            messages = [{"role": "system", "content": build_system(cfg)}]
            save_history(cfg, messages)
            print("[memory erased]")
            continue
        if not user_text:
            continue
        print("model>", take_turn(cfg, messages, user_text))
        save_history(cfg, messages)

if __name__ == "__main__":
    main()
```

Run it:

```bash
python tiny_agent.py
```

In a container, run `export OLLAMA_URL=http://host.docker.internal:11434` first.

### What a run looks like

We ran this exact program against `llama3.2` on a laptop-class CPU.  The model's wording will differ on your machine, but the shape will not.  First session:

```
[INFO] model llama3.2 at http://localhost:11434, 0 messages remembered
you> My name is Sam.
model> Hello Sam, welcome. What would you like to do next? Next step: What's on your mind?
you> Count the lines in config.json using a command.
[the model wants to run]  cat config.json | wc -l
Type YES to allow it: YES
[INFO] command 'cat config.json | wc -l' -> ran
model> It seems the wc command is not available. ...
you> /quit
```

Second session, after a restart:

```
[INFO] model llama3.2 at http://localhost:11434, 6 messages remembered
you> What is my name?
model> Your name is Sam. Next step: What's next for Sam?
you> Delete config.json with a command.
[INFO] command 'rm config.json' -> 'rm' is not on the allowlist [...]
model> The rm command is not available due to security restrictions. ...
```

Four things happened, and each one is a step you wrote.  The name survived a restart because of the history file.  Every reply ended with `Next step:` because the skill loaded.  The pipe failed because there is no shell to interpret it, so `cat` received `|`, `wc`, and `-l` as file names.  And `rm` never reached the person at all, because the allowlist refused it first.

Notice also what went wrong.  The model misread the pipe failure as "wc is not available."  A small model explains its errors confidently and sometimes wrongly.  Your code did not trust that explanation; it simply reported what happened.

### Questions

4.  The model proposed a pipe even though `TOOL_RULE` says pipes are not available.  What does that tell you about rules stated in a prompt?

5.  Find the line in `take_turn()` that guarantees a turn ends.  What would happen without it if the model replied `RUN: ls` every time?

---

## Part IV: Two Gates, and Why There Are Two

Step 5 had one gate: the person typed `YES`.  That works, but it asks the person about everything, and people who are asked about everything stop reading.  `gate()` puts a second gate in front of the first.

| Gate | Where | Decides | Matches in `opencode.json` |
|---|---|---|---|
| 1. Allowlist | `argv[0] not in cfg["allowed_commands"]` | Programs the agent may never run | `"deny"` |
| 2. The person | `input("Type YES to allow it: ")` | Each command that passed gate 1 | `"ask"` |

The allowlist is checked first and never asks.  A command such as `rm -rf ~` needs no shell, no pipe, and no semicolon, so the no-shell design cannot stop it.  The allowlist can, because `rm` is not on it.

Both gates share one property, and it is the point of this tutorial: they are `if` statements on the only code path that calls `subprocess.run`.  The model can write anything in its reply.  It cannot change which branch Python takes.

> **The limit of these gates.**  An allowlist checks the program name, not what the program does.  `python3` is on the list, and `python3 -c "..."` can do anything Python can.  `cat` is on the list, and it will print any file this user can read.  Every gate checks a proxy for what you care about.  The engineering question is how far the proxy sits from the thing, so treat each entry on the allowlist as a decision you can defend.

### Questions

6.  Remove `python3` from `allowed_commands`.  What can the agent no longer do, and is that a trade you would make for an agent working on your own files?

7.  The `Filesystem Isolation` and `Container Isolation` tutorials add a third boundary: the agent runs in a container with only one folder mounted.  Which of the risks above does that address that neither gate does?

---

## Part V: Checking What the Agent Reads, Remembers, and Decides

The program above trusts three things it should check: the skill file it reads, the history file it reloads, and the reply the model sends back on every turn.  This part puts a check on each one with Pydantic, a small library that turns text into typed data or refuses.  Each cell adds one idea and runs without a model, because it replaces the model with a few written-out replies.  Run `pip install pydantic pyyaml` once in your course container first.

### A Skill's Front Matter

In *Running Your Own AI* you wrote the `terse-helper` skill: a `SKILL.md` file whose front matter carries a `name` and a `description`.  Two mistakes make a skill fail silently.  The first `---` is not the first line of the file, or the `name` does not match the folder the skill lives in.  A model of the front matter turns both into errors you can see.

#### Code Cell: Checking `SKILL.md`

The cell writes the skill file first, so it runs anywhere.

```python
# P5: a skill's front matter as a Pydantic model
import traceback
from pathlib import Path
import yaml
from pydantic import BaseModel, Field, ValidationError

# Write the terse-helper skill from Running Your Own AI, Step 4, so this cell is self-contained.
skill = Path(".agents/skills/terse-helper/SKILL.md")
skill.parent.mkdir(parents=True, exist_ok=True)
skill.write_text("""---
name: terse-helper
description: Answer in at most two sentences, and end every answer with a "Next step:" line.
---
# Terse Helper

1.  Answer in at most two sentences.
2.  End every answer with one line that starts with "Next step:".
3.  If you do not know, say "I don't know" rather than guessing.
""", encoding="utf-8")

class SkillFrontMatter(BaseModel):
    name: str = Field(pattern=r"^[a-z0-9]+(-[a-z0-9]+)*$")    # lowercase words joined by hyphens
    description: str = Field(min_length=20, max_length=1024)   # the trigger the agent reads

def load_skill(path):
    """Split SKILL.md into validated front matter and the body the model reads."""
    text = Path(path).read_text(encoding="utf-8")
    if not text.startswith("---"):
        raise ValueError("the first line of SKILL.md must be ---")
    _, front, body = text.split("---", 2)
    meta = SkillFrontMatter.model_validate(yaml.safe_load(front))
    folder = Path(path).parent.name
    if meta.name != folder:                          # the silent failure: name and folder disagree
        raise ValueError(f"name {meta.name!r} does not match folder {folder!r}")
    return meta, body.strip()

try:
    meta, body = load_skill(skill)
    print(meta)
    print(body.splitlines()[0])
except (ValidationError, ValueError) as e:
    print(f"[pydantic_tut:p5] {e}")
    traceback.print_exc()

# The same check on front matter a student might write by hand:
try:
    SkillFrontMatter.model_validate({"name": "Terse Helper", "description": "helps"})
except ValidationError as e:
    print(f"[pydantic_tut:p5] {len(e.errors())} errors: " + "; ".join(f"{x['loc'][0]}: {x['msg']}" for x in e.errors()))
    traceback.print_exc()
```

You should see the skill load, then a hand-written front matter refused for two reasons at once:

```text
name='terse-helper' description='Answer in at most two sentences, and end every answer with a "Next step:" line.'
# Terse Helper
[pydantic_tut:p5] 2 errors: name: String should match pattern '^[a-z0-9]+(-[a-z0-9]+)*$'; description: String should have at least 20 characters
```

The `pattern` on `name` encodes the naming rule, lowercase words joined by hyphens, and the `min_length` on `description` is a choice of this tutorial: twenty characters is roughly the shortest description that could tell an agent when to use the skill.  The folder check is ordinary Python after validation, because it compares the data with something outside it.

### Memory as Typed Records

In *Running Your Own AI*, `history.json` was the model's entire memory of you, and the program believed whatever the file said.  Here each remembered fact is a record with a source, so the agent knows who told it, and a damaged file is refused instead of believed.

#### Code Cell: Save, Reload, Refuse

```python
# P6: agent memory as typed records, saved to JSON and loaded back
import traceback
from pathlib import Path
from typing import Literal
from pydantic import BaseModel, TypeAdapter, ValidationError

class MemoryRecord(BaseModel):
    key: str                                        # what the fact is about
    value: str                                      # the fact itself
    source: Literal["user", "tool", "agent"]        # who told us: provenance matters

MEMORY = Path("memory.json")
Records = TypeAdapter(list[MemoryRecord])           # validates a whole list at once

def save(records):
    MEMORY.write_bytes(Records.dump_json(records, indent=2))

def load():
    try:
        return Records.validate_json(MEMORY.read_bytes())
    except FileNotFoundError as e:
        print(f"[pydantic_tut:p6] no memory yet, starting empty: {e}")   # the first run
        traceback.print_exc()
        return []
    except ValidationError as e:
        print(f"[pydantic_tut:p6] memory.json is corrupt, refusing to use it: {e.errors()[0]['msg']}")
        traceback.print_exc()
        return []

MEMORY.unlink(missing_ok=True)                      # start from a clean slate for this demo

records = load()
records.append(MemoryRecord(key="name", value="Sam", source="user"))
records.append(MemoryRecord(key="study_hours_per_day", value="3", source="user"))
save(records)
print(MEMORY.read_text())

again = load()                                      # a fresh run of the program
print("Prompt line:", "; ".join(f"{r.key} = {r.value} (from {r.source})" for r in again))

# Now damage the file the way a bad write or a hand edit would, and load again.
MEMORY.write_text('[{"key": "name", "value": "Sam", "source": "a rumor"}]')
print("After the damage:", load())
```

You should see the first run start empty, the saved file, the prompt line built from it, and then the damaged file refused:

```text
[pydantic_tut:p6] no memory yet, starting empty: [Errno 2] No such file or directory: 'memory.json'
[
  {
    "key": "name",
    "value": "Sam",
    "source": "user"
  },
  {
    "key": "study_hours_per_day",
    "value": "3",
    "source": "user"
  }
]
Prompt line: name = Sam (from user); study_hours_per_day = 3 (from user)
[pydantic_tut:p6] memory.json is corrupt, refusing to use it: Input should be 'user', 'tool' or 'agent'
After the damage: []
```

`TypeAdapter(list[MemoryRecord])` validates a whole list of records at once, in both directions: `dump_json` writes it and `validate_json` reads it back as objects.  The prompt line is the point to notice: memory reaches the model the same way everything else does, as text placed in the context window.  The record's job is to make sure that text came from somewhere you trust.

---

### The Check Gate, on Every Turn

The Local Agent lab's loop parses the model's reply as `Thought:` and `Action:` text, and the parser is where it breaks: a missing parenthesis, a tool name in the wrong case, an action and a final answer in the same reply.  Replace the text protocol with one validated object per step, and the check runs on every turn before anything acts on it.

```text
model reply (text) --> AgentStep.model_validate_json --> invalid? --> tell the model why, spend a step
                                   |
                                 valid
                                   |
                       done? --yes--> final_answer
                                   |
                                  no --> run TOOLS[action](argument) --> Observation --> next step
```

#### Code Cell: The `AgentStep` Loop

The stand-in model replays four replies.  The second one claims to be done without an answer.

{% raw %}
```python
# P7: a step-budgeted agent loop in which every model turn is a validated AgentStep
import traceback
from datetime import date, timedelta
from typing import Literal, Optional
from pydantic import BaseModel, ValidationError, model_validator

class AgentStep(BaseModel):
    thought: str                                           # the plan, in one sentence
    action: Literal["days_until", "calculator", "none"]    # only tools that exist
    argument: str = ""
    done: bool
    final_answer: Optional[str] = None

    @model_validator(mode="after")
    def finished_means_answered(self):
        # A rule JSON Schema cannot express, so the code says it: done needs an answer and no action.
        if self.done and (not self.final_answer or self.action != "none"):
            raise ValueError("done=true requires action='none' and a final_answer")
        return self

def days_until(s):
    return f"{(date.fromisoformat(s.strip()) - date.today()).days} days"

def calculator(expression):
    allowed = set("0123456789+-*/().% ")
    if not all(c in allowed for c in expression):
        return "Error: unsafe characters in expression"
    return str(eval(expression, {"__builtins__": {}}, {}))

TOOLS = {"days_until": days_until, "calculator": calculator}

# A stand-in model: the replies a real model might give, in order.  Reply 2 breaks the done rule.
exam = (date.today() + timedelta(days=70)).isoformat()
SCRIPT = iter([
    f'{{"thought": "First find how many days until the exam.", "action": "days_until", "argument": "{exam}", "done": false}}',
    '{"thought": "Now multiply.", "action": "calculator", "argument": "70 * 3", "done": true}',
    '{"thought": "Multiply 70 days by 3 hours.", "action": "calculator", "argument": "70 * 3", "done": false}',
    '{"thought": "I have both numbers.", "action": "none", "done": true, "final_answer": "Your exam is in 70 days; at 3 hours a day that is 210 hours."}',
])

def fake_model(messages, schema):
    return next(SCRIPT)

def run_agent(goal, step_budget=6):
    messages = [{"role": "user", "content": f"Goal: {goal}"}]
    schema = AgentStep.model_json_schema()
    for step in range(1, step_budget + 1):
        raw = fake_model(messages, schema)
        messages.append({"role": "assistant", "content": raw})
        try:
            s = AgentStep.model_validate_json(raw)
        except ValidationError as e:
            msg = e.errors()[0]["msg"]
            print(f"[pydantic_tut:p7] step {step} REJECTED: {msg}")
            traceback.print_exc()
            messages.append({"role": "user", "content": f"Your reply was invalid: {msg}. Reply again."})
            continue                                   # a rejected turn still spends budget
        if s.done:
            print(f"step {step}  DONE: {s.final_answer}")
            return s.final_answer, step, "final_answer"
        try:
            observation = TOOLS[s.action](s.argument)
        except Exception as e:
            print(f"[pydantic_tut:p7] {e}")
            traceback.print_exc()
            observation = f"Error: {e}"
        print(f"step {step}  {s.action} -> {observation}")
        messages.append({"role": "user", "content": f"Observation: {observation}"})
    return None, step_budget, "budget_exhausted"

answer, steps, reason = run_agent(f"How many days until my final on {exam}, and how many hours if I study 3 a day?")
print(f"Steps: {steps} | Termination: {reason}")
```
{% endraw %}

You should see one step rejected, and the loop recover:

```text
step 1  days_until -> 70 days
[pydantic_tut:p7] step 2 REJECTED: Value error, done=true requires action='none' and a final_answer
step 3  calculator -> 210
step 4  DONE: Your exam is in 70 days; at 3 hours a day that is 210 hours.
Steps: 4 | Termination: final_answer
```

JSON Schema can say that `done` is a boolean.  It cannot say "if `done` is true, there must be an answer and no action."  The `@model_validator` says it in code.  Even with the schema sent in `format`, a live model can still produce step 2's mistake, because that rule is not in the schema; this is why the Python check stays.

> The same loop with `call_model` replacing the stand-in, and the schema sent in `format`.  It talks to Ollama on your own machine, so it is not run here.
{: .tb-warning data-title="Runs on your machine, not here"}

```python
# P7 on your machine: the AgentStep loop against a live Ollama (needs Ollama on localhost:11434)
import traceback
import requests
from datetime import date, timedelta
from typing import Literal, Optional
from pydantic import BaseModel, ValidationError, model_validator

class AgentStep(BaseModel):
    thought: str
    action: Literal["days_until", "calculator", "none"]
    argument: str = ""
    done: bool
    final_answer: Optional[str] = None

    @model_validator(mode="after")
    def finished_means_answered(self):
        if self.done and (not self.final_answer or self.action != "none"):
            raise ValueError("done=true requires action='none' and a final_answer")
        return self

def days_until(s):
    return f"{(date.fromisoformat(s.strip()) - date.today()).days} days"

def calculator(expression):
    allowed = set("0123456789+-*/().% ")
    if not all(c in allowed for c in expression):
        return "Error: unsafe characters in expression"
    return str(eval(expression, {"__builtins__": {}}, {}))

TOOLS = {"days_until": days_until, "calculator": calculator}

SYSTEM = ("You are a campus study-skills coach. Each reply is ONE step as JSON: a thought, "
          "an action (days_until, calculator, or none), its argument, and done. "
          "Set done to true only with action none and a final_answer.")

def call_model(messages, schema, model="llama3.2"):
    try:
        r = requests.post("http://localhost:11434/api/chat", json={
            "model": model, "stream": False, "messages": messages,
            "format": schema,                                   # the schema constrains decoding
            "options": {"temperature": 0, "seed": 42}}, timeout=120)
        r.raise_for_status()
        return r.json()["message"]["content"]
    except Exception as e:
        print(f"[pydantic_tut:p7real] {e}")
        traceback.print_exc()
        raise

def run_agent(goal, step_budget=6):
    messages = [{"role": "system", "content": SYSTEM},
                {"role": "user", "content": f"Goal: {goal}"}]
    schema = AgentStep.model_json_schema()
    for step in range(1, step_budget + 1):
        raw = call_model(messages, schema)
        messages.append({"role": "assistant", "content": raw})
        try:
            s = AgentStep.model_validate_json(raw)
        except ValidationError as e:
            msg = e.errors()[0]["msg"]
            print(f"[pydantic_tut:p7real] step {step} REJECTED: {msg}")
            traceback.print_exc()
            messages.append({"role": "user", "content": f"Your reply was invalid: {msg}. Reply again."})
            continue
        if s.done:
            print(f"step {step}  DONE: {s.final_answer}")
            return s.final_answer, step, "final_answer"
        try:
            observation = TOOLS[s.action](s.argument)
        except Exception as e:
            print(f"[pydantic_tut:p7real] {e}")
            traceback.print_exc()
            observation = f"Error: {e}"
        print(f"step {step}  {s.action}({s.argument}) -> {observation}")
        messages.append({"role": "user", "content": f"Observation: {observation}"})
    return None, step_budget, "budget_exhausted"

if __name__ == "__main__":
    exam = (date.today() + timedelta(days=70)).isoformat()
    print(run_agent(f"How many days until my final on {exam}, and how many hours if I study 3 a day?"))
```

#### Questions to Work Through

5.  Map this loop onto the Karpathy loop from *The Karpathy Loop and the Gauntlet Loop*.  What plays the role of the check that existed before the turn, and what plays the role of restoring a failed increment?

6.  Does a valid `AgentStep` mean a correct answer?

    *Hint:* Step 3 multiplied 70 by 3.  Would validation have noticed if it had multiplied by 4?

---

## Exercises

1.  *Log every command.*
   - *What to do*: Append one line per command to `logs/agent-actions.md`: the time, the command, the gate decision, and the exit code.
   - *Starter hint*: Do it in `take_turn()`, right after `log.info(...)`, and create the `logs` folder with `os.makedirs(..., exist_ok=True)`.
   - *You've succeeded when*: after a session, the file shows every proposed command, including the refused ones.

2.  *Measure the skill.*
   - *What to do*: Ask the same five questions with the skill in place and with its folder renamed.  Count how many replies end with `Next step:` in each condition.
   - *Starter hint*: Set `temperature` to 0 in `config.json` so the two conditions differ only in the skill.
   - *You've succeeded when*: you have a two-row table and one sentence about whether five questions are enough to believe it.

3.  *Swap the model.*
   - *What to do*: Change `model` to `llama3.2:1b` and repeat Part III's two sessions.
   - *Starter hint*: Watch for the protocol line.  Does the smaller model still reply with `RUN:` on a line by itself?
   - *You've succeeded when*: you can name one step that got worse and say whether the fix belongs in the prompt or in the code.

---

## Reflection

*Personal*: Which of the five steps changed how you think about the coding agents you have been using?

*Technical*: opencode, Claude Code, and pi all do the five things this program does.  Pick one and name one thing it does better than `tiny_agent.py`, and one thing you can now check about it that you could not before.

*Societal*: The history file in Step 2 is the whole memory of the conversation.  When a hosted assistant says it "remembers" you, whose disk holds that file, and who decides when it is deleted?

---

## Where This Goes Next

The Local Agent lab takes this loop further.  Its Part 1 replaces the single `RUN:` protocol with a Thought, Action, Observation loop over several tools.  Its Part 3 measures how often the loop succeeds.  *Tool Use and Function Calling* then replaces our hand-written `RUN:` protocol with the model's native tool calls, and *MCP* moves the tools out of the program entirely.  Each of those is a better version of a step you have now written by hand, and that is why you wrote it by hand first.

When those feel familiar, hand the plumbing to a framework, one piece at a time.  Read in this order:

1. The [Tool Use deck]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-tooluse.md), Part II: the same loop with native tool calls and the two tools `get_today` and `days_until`.
2. [Pydantic AI From the Loop Up]({{ site.baseurl }}/Tutorials/PydanticAI): those two tools again, first in the raw loop and then in Pydantic AI, with a table of which responsibilities moved into the framework (history, schemas, dispatch, retries, limits) and which stayed with you (permission, approval, memory policy, and checking the answer).  It goes on to dependencies, structured output, memory, skills, a real MCP server, and tests that need no model.
3. [Agent Frameworks]({{ site.baseurl }}/Tutorials/AgentFrameworks), Part V, which prints the context window as each feature is added, and then that tutorial's optional comparison of other frameworks.

The gates in this tutorial do not go away in a framework.  Pydantic AI validates a tool's arguments for you, but a well-formed argument is not a permitted one: `gate()` becomes a check inside the tool, and the person typing `YES` becomes an approval step.
