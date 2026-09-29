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

Three settings deserve a sentence each.  `provider_url` can be overridden by the `OLLAMA_URL` environment variable, so the same file works inside a container, and `api_key` stays `null` for local Ollama; set it only when `provider_url` points at a hosted Ollama server that needs a key.  `allowed_commands` is the first gate, described in Part IV.  `log_level` accepts `DEBUG`, `INFO`, `WARNING`, or `ERROR`; at `INFO`, every command the agent runs or refuses is logged.

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
        r = requests.post(f"{cfg['provider_url']}/api/chat", headers=({"Authorization": f"Bearer {cfg['api_key']}"} if cfg.get("api_key") else {}), json={
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
