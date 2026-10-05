---
layout: textbook
permalink: /Tutorials/Pydantic
title: 'CS357: Foundations of Artificial Intelligence - Structured Data With Pydantic, One Concept at a Time'
info:
  coursenum: CS357
  purpose: "To check every piece of structured data that crosses between a model and your code (tool arguments, structured replies, skill files, memory, agent steps, MCP calls, and RAG answers) with one small library, one concept at a time."
  eyebrow: "Tutorial"
  numbering: false
tags:
- pydantic
- tool-use
- structured-output
---

## About This Tutorial

A model hands your program text.  Your program needs data: a date it can subtract, a tool name it can look up, a boolean it can trust.  Pydantic is the small library that turns one into the other or refuses, and this tutorial uses it to put a check at every place the two meet.
{: .tb-lede}

Each part adds one idea in one runnable cell.  Part I turns a tool's arguments into a class and checks a call against it.  Part II builds a registry that runs only validated calls, then sends the same schema to the model as structured output.  Part III applies the idea to files an agent reads: a skill's front matter and a memory file.  Part IV puts the check on every step of an agent loop.  Part V does the same for an MCP write tool, and Part VI for a RAG answer, where a valid answer can still be unfaithful.  Every cell runs without a model, because each one replaces the model with a few written-out replies; the cells marked "Runs on your machine" make the same calls against Ollama.

## Key Concepts

| Term | Plain-English Definition | Where You'll Meet It |
|:-----|:------------------------|:------------------------|
| **Model (Pydantic)** | A Python class, written with type annotations, that describes the shape a piece of data must have.  It is unrelated to a language model; the word is shared by accident | Every cell: `class DaysUntilArgs(BaseModel)` |
| **Validation** | Checking data against a model.  Valid data comes back as a typed Python object; invalid data raises `ValidationError`, which says which field failed and why | `model_validate` in Part I |
| **JSON Schema** | A standard JSON description of a data shape.  Tool schemas and Ollama's `format` field both use it, and Pydantic generates it from a model | `model_json_schema()` in Parts I and II |
| **Structured output** | Asking the model for a reply in a fixed shape, either by describing the shape in the prompt or by sending the schema so the server constrains what the model can produce | Part II |
| **Semantic validity** | Whether valid data is also *correct*.  A schema can require a date; it cannot require the right date | Parts IV and VI |

**Before you start.**  Run `pip install pydantic pyyaml` once in your course container.  The "Runs on your machine" cells also need Ollama running with `llama3.2`, and Part II's second one needs `pip install ollama`.

---

# Part I: A Tool's Arguments Are a Class

## 1.  From a Hand-Written Schema to a Model

In *Tool Use and Function Calling* you wrote each tool's schema by hand: a name, a description, and a JSON description of its parameters.  A Pydantic model is the same information written once, as a class, so that the schema and the check come from one place.

## Code Cell: The Schema

```python
# P1: one tool's arguments, written as a Pydantic model
from datetime import date
from pydantic import BaseModel, Field

class DaysUntilArgs(BaseModel):
    """Arguments for days_until: the number of days from today until the given ISO date."""
    target_iso: date = Field(description="The target date in YYYY-MM-DD format")

print(DaysUntilArgs.model_json_schema())
```

You should see one dictionary, the JSON Schema for the class:

```text
{'description': 'Arguments for days_until: the number of days from today until the given ISO date.', 'properties': {'target_iso': {'description': 'The target date in YYYY-MM-DD format', 'format': 'date', 'title': 'Target Iso', 'type': 'string'}}, 'required': ['target_iso'], 'title': 'DaysUntilArgs', 'type': 'object'}
```

Read the cell one line at a time.  `class DaysUntilArgs(BaseModel)` declares a shape.  `target_iso: date` says the one field must be a date, not merely a string.  `Field(description=...)` is the sentence the model will read when it decides how to fill the field, so it is part of the prompt.  `model_json_schema()` turns the class into the schema you used to type by hand.  Find `'required': ['target_iso']` and `'format': 'date'` in the output: both came from the one annotation line.

## Code Cell: The Check

The same class now checks a call.  The first argument is what a well-behaved model sends; the second is a string that is not a date, the kind of thing a model passes when it copies the user's words instead of converting them.

```python
# P2: validate what the model asked for, before anything runs
import traceback
from datetime import date, timedelta
from pydantic import BaseModel, Field, ValidationError

class DaysUntilArgs(BaseModel):
    """Arguments for days_until: the number of days from today until the given ISO date."""
    target_iso: date = Field(description="The target date in YYYY-MM-DD format")

good = {"target_iso": (date.today() + timedelta(days=62)).isoformat()}   # what a well-behaved model sends
bad = {"target_iso": "the last day of classes"}                          # a string, but not a date

for args in (good, bad):
    try:
        parsed = DaysUntilArgs.model_validate(args)
        print("OK  ", type(parsed.target_iso).__name__, (parsed.target_iso - date.today()).days, "days away")
    except ValidationError as e:
        print(f"[pydantic_tut:p2] {e}")
        traceback.print_exc()
```

You should see one success and one refusal (the traceback that follows on stderr names files on your own machine):

```text
OK   date 62 days away
[pydantic_tut:p2] 1 validation error for DaysUntilArgs
target_iso
  Input should be a valid date or datetime, invalid character in year [type=date_from_datetime_parsing, input_value='the last day of classes', input_type=str]
    For further information visit https://errors.pydantic.dev/2.13/v/date_from_datetime_parsing
```

`model_validate` does two jobs at once.  The good call comes back as a real `date`, which is why the next line can subtract today from it.  The bad call never reaches any function; the error names the field, the rule, and the value that broke it.

### Questions to Work Through

1.  The model passed `"the last day of classes"` for `target_iso`.  Whose bug is that: the model's, the description's, or the validator's?

    *Hint:* The model was trying to help by passing what the user said.  The description is the only thing that tells it the format, and the validator is the backstop when the description fails.  Which of the three can you change without retraining anything?

2.  Remove `: date` from `target_iso` (leave `str`) and run the check again.  What passes now that did not before, and where would the failure show up instead?

---

# Part II: Validated Tool Calls and Structured Output

## 2.  The Registry Runs Only Checked Calls

The tool registry from *Tool Use and Function Calling* maps a tool name to a function, and it is a security boundary: a name that is not in it cannot run.  Here each entry also carries the argument model, the tool list the model sees is generated from those models, and every call is validated before its function runs.  The three calls are written out by hand in the shape Ollama returns them, so the cell needs no model.

## Code Cell: A Validated Registry

```python
# P3: a two-tool registry in which every call is validated before it runs
import json
import traceback
from datetime import date, timedelta
from pydantic import BaseModel, Field, ValidationError

class GetTodayArgs(BaseModel):
    """Returns today's date in ISO format (YYYY-MM-DD). Call this whenever you need to know the current date before computing a duration or deadline."""

class DaysUntilArgs(BaseModel):
    """Returns the number of days from today until the given ISO date. The result is positive if the date is in the future and negative if it has passed."""
    target_iso: date = Field(description="The target date in YYYY-MM-DD format")

def get_today(args: GetTodayArgs) -> str:
    return date.today().isoformat()

def days_until(args: DaysUntilArgs) -> str:
    return str((args.target_iso - date.today()).days)

# name -> (argument model, function).  The registry is still the security boundary.
REGISTRY = {"get_today": (GetTodayArgs, get_today),
            "days_until": (DaysUntilArgs, days_until)}

# The TOOLS list the model sees is GENERATED from the models, not typed by hand.
TOOLS = [{"type": "function",
          "function": {"name": name,
                       "description": model.__doc__,
                       "parameters": model.model_json_schema()}}
         for name, (model, _) in REGISTRY.items()]

def run_tool_call(call):
    """Validate one tool call, run it, and return the text for the tool-role message."""
    name = call["function"]["name"]
    if name not in REGISTRY:
        return f"error: unknown tool {name!r}"
    model, fn = REGISTRY[name]
    try:
        args = model.model_validate(call["function"]["arguments"] or {})
    except ValidationError as e:
        print(f"[pydantic_tut:p3] {e}")
        traceback.print_exc()
        # The error goes BACK to the model as the observation, so the loop can recover.
        return f"error: invalid arguments for {name}: {e.errors()[0]['msg']}. Send target_iso as YYYY-MM-DD."
    return fn(args)

print(json.dumps(TOOLS[1], indent=2))

# Three tool calls in the shape Ollama returns them (written by hand here: no model needed).
in_62_days = (date.today() + timedelta(days=62)).isoformat()
calls = [
    {"function": {"name": "days_until", "arguments": {"target_iso": in_62_days}}},
    {"function": {"name": "days_until", "arguments": {"days": "seven"}}},
    {"function": {"name": "send_email", "arguments": {"to": "everyone"}}},
]
for c in calls:
    print("->", run_tool_call(c))
```

You should see the generated schema for `days_until`, then one result per call:

```text
{
  "type": "function",
  "function": {
    "name": "days_until",
    "description": "Returns the number of days from today until the given ISO date. The result is positive if the date is in the future and negative if it has passed.",
    "parameters": {
      "description": "Returns the number of days from today until the given ISO date. The result is positive if the date is in the future and negative if it has passed.",
      "properties": {
        "target_iso": {
          "description": "The target date in YYYY-MM-DD format",
          "format": "date",
          "title": "Target Iso",
          "type": "string"
        }
      },
      "required": [
        "target_iso"
      ],
      "title": "DaysUntilArgs",
      "type": "object"
    }
  }
}
-> 62
[pydantic_tut:p3] 1 validation error for DaysUntilArgs
target_iso
  Field required [type=missing, input_value={'days': 'seven'}, input_type=dict]
    For further information visit https://errors.pydantic.dev/2.13/v/missing
-> error: invalid arguments for days_until: Field required. Send target_iso as YYYY-MM-DD.
-> error: unknown tool 'send_email'
```

Three calls, three outcomes.  The first runs and returns 62.  The second sends `days` instead of `target_iso` and is refused, and the line `return f"error: invalid arguments ..."` sends that refusal *back to the model* as the tool's result, which is what lets an agent loop recover on its next turn.  The third names a tool that was never registered, so it cannot run at all.  Rejecting a call and telling the model why are different things; only the second lets the loop continue.

> This version is the tool use deck's `agent()` with one line changed: `REGISTRY[name](**args)` becomes `run_tool_call(c)`.  It sends real requests to the Ollama server on your own laptop at `localhost:11434`, which a web page has no route to, so it is not run here and no output is shown.  Run it in your course container and read the `[tool]` lines it prints.
{: .tb-warning data-title="Runs on your machine, not here"}

```python
# P3 on your machine: the tool use deck's agent() with validated dispatch (needs Ollama on localhost:11434)
import traceback
import requests
from datetime import date
from pydantic import BaseModel, Field, ValidationError

class GetTodayArgs(BaseModel):
    """Returns today's date in ISO format (YYYY-MM-DD). Call this whenever you need to know the current date before computing a duration or deadline."""

class DaysUntilArgs(BaseModel):
    """Returns the number of days from today until the given ISO date. The result is positive if the date is in the future and negative if it has passed."""
    target_iso: date = Field(description="The target date in YYYY-MM-DD format")

def get_today(args: GetTodayArgs) -> str:
    return date.today().isoformat()

def days_until(args: DaysUntilArgs) -> str:
    return str((args.target_iso - date.today()).days)

REGISTRY = {"get_today": (GetTodayArgs, get_today),
            "days_until": (DaysUntilArgs, days_until)}
TOOLS = [{"type": "function",
          "function": {"name": name, "description": model.__doc__,
                       "parameters": model.model_json_schema()}}
         for name, (model, _) in REGISTRY.items()]

def run_tool_call(call):
    """Validate one tool call, run it, and return the text for the tool-role message."""
    name = call["function"]["name"]
    if name not in REGISTRY:
        return f"error: unknown tool {name!r}"
    model, fn = REGISTRY[name]
    try:
        args = model.model_validate(call["function"]["arguments"] or {})
    except ValidationError as e:
        print(f"[pydantic_tut:p3real] {e}")
        traceback.print_exc()
        return f"error: invalid arguments for {name}: {e.errors()[0]['msg']}. Send target_iso as YYYY-MM-DD."
    return fn(args)

def agent(question, max_steps=4):
    msgs = [{"role": "user", "content": question}]
    for _ in range(max_steps):
        try:
            r = requests.post("http://localhost:11434/api/chat", json={
                "model": "llama3.2", "stream": False, "tools": TOOLS,
                "options": {"temperature": 0.0, "seed": 42},
                "messages": msgs}, timeout=120).json()["message"]
        except Exception as e:
            print(f"[pydantic_tut:p3real] {e}")
            traceback.print_exc()
            return ""
        msgs.append(r)
        calls = r.get("tool_calls") or []
        if not calls:
            return r["content"]
        for c in calls:
            result = run_tool_call(c)                 # was: REGISTRY[name](**args)
            print(f"[tool] {c['function']['name']}({c['function']['arguments']}) -> {result}")
            msgs.append({"role": "tool", "content": result})
    return "step budget exceeded"

if __name__ == "__main__":
    print(agent("How many days until December 7?"))
```

## 3.  Structured Output: The Schema Goes Out, the Check Comes Back

A tool call is one kind of structured reply.  Any reply can be structured: you can ask the model to answer in a fixed shape.  Asking in the prompt ("answer in JSON") only encourages the shape.  Sending the schema in Ollama's `format` field lets the server constrain which tokens the model may produce, so the reply fits the schema.  Either way, the same model checks the reply on the way back.

## Code Cell: Prompt Only, Then `format`

The stand-in server below returns the two replies you would typically get: a friendly sentence before the JSON when you only asked, and bare JSON when you sent the schema.

```python
# P4: structured output.  The schema goes TO the model; the reply comes BACK through the same model.
import traceback
from typing import Literal
from pydantic import BaseModel, Field, ValidationError

class Sentiment(BaseModel):
    sentiment: Literal["positive", "neutral", "negative"]
    confidence: float = Field(ge=0.0, le=1.0)

schema = Sentiment.model_json_schema()      # this dict is what goes in the "format" field

def fake_ollama_chat(body):
    """A stand-in for POST /api/chat that returns two canned replies in Ollama's shape."""
    if "format" in body:   # constrained: the server only lets schema-valid JSON out
        content = '{"sentiment": "negative", "confidence": 0.93}'
    else:                  # unconstrained: "please answer in JSON"
        content = 'Sure! Here is the JSON:\n{"sentiment": "negative", "confidence": 0.93}'
    return {"message": {"role": "assistant", "content": content}}

prompt = "Classify the sentiment of: 'The product broke after one day.'"
requests_to_try = [
    ("prompt only  ", {"model": "llama3.2", "messages": [{"role": "user", "content": prompt + " Answer in JSON."}]}),
    ("format=schema", {"model": "llama3.2", "messages": [{"role": "user", "content": prompt}], "format": schema}),
]
for label, body in requests_to_try:
    raw = fake_ollama_chat(body)["message"]["content"]
    try:
        result = Sentiment.model_validate_json(raw)
        print(label, "->", result)
    except ValidationError as e:
        print(f"[pydantic_tut:p4] {label.strip()}: {e.errors()[0]['type']}: {e.errors()[0]['msg']}")
        traceback.print_exc()
```

You should see the prompt-only reply refused at its first character, and the `format` reply accepted:

```text
[pydantic_tut:p4] prompt only: json_invalid: Invalid JSON: expected value at line 1 column 1
format=schema -> sentiment='negative' confidence=0.93
```

`Literal[...]` restricts a field to a fixed set of strings, and `Field(ge=0.0, le=1.0)` restricts a number to a range.  Neither one makes the label *right*.  A reply can fit the schema and still call a broken product positive; that is semantic validity, and no schema checks it.

> The same request against a live Ollama, using the `ollama` package.  If your code uses `requests` instead, the only change to your payload is one key, `"format": Sentiment.model_json_schema()`, beside `"options"`.
{: .tb-warning data-title="Runs on your machine, not here"}

```python
# P4 on your machine: the same request against a live Ollama (pip install ollama)
import traceback
from typing import Literal
from ollama import chat
from pydantic import BaseModel, Field, ValidationError

class Sentiment(BaseModel):
    sentiment: Literal["positive", "neutral", "negative"]
    confidence: float = Field(ge=0.0, le=1.0)

try:
    response = chat(
        model="llama3.2",
        messages=[{"role": "user", "content": "Classify the sentiment of: 'The product broke after one day.'"}],
        format=Sentiment.model_json_schema(),          # the schema travels in the request
        options={"temperature": 0, "seed": 42},
    )
    result = Sentiment.model_validate_json(response.message.content)   # and is checked on return
    print(result)
except ValidationError as e:
    print(f"[pydantic_tut:p4real] {e}")
    traceback.print_exc()
except Exception as e:
    print(f"[pydantic_tut:p4real] {e}")
    traceback.print_exc()
```

### Questions to Work Through

3.  In the validated registry, the refused call returns a string instead of raising.  Trace what the agent loop does with that string on its next turn, and what would happen to the loop if `run_tool_call` raised instead.

4.  The `format` reply passed validation.  Name one way it could still be wrong, and say what kind of check would catch it.

    *Hint:* Compare the label with the sentence being classified.  Is that a question about the shape of the reply or about its meaning?

---

# Part III: Files an Agent Reads, as Typed Records

## 4.  A Skill's Front Matter

In *Running Your Own AI* you wrote the `terse-helper` skill: a `SKILL.md` file whose front matter carries a `name` and a `description`.  Two mistakes make a skill fail silently.  The first `---` is not the first line of the file, or the `name` does not match the folder the skill lives in.  A model of the front matter turns both into errors you can see.

## Code Cell: Checking `SKILL.md`

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

## 5.  Memory as Typed Records

In *Running Your Own AI*, `history.json` was the model's entire memory of you, and the program believed whatever the file said.  Here each remembered fact is a record with a source, so the agent knows who told it, and a damaged file is refused instead of believed.

## Code Cell: Save, Reload, Refuse

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

# Part IV: Every Agent Step Is a Validated Object

## 6.  The Check Gate, on Every Turn

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

## Code Cell: The `AgentStep` Loop

The stand-in model replays four replies.  The second one claims to be done without an answer.

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

### Questions to Work Through

5.  Map this loop onto the Karpathy loop from *The Karpathy Loop and the Gauntlet Loop*.  What plays the role of the check that existed before the turn, and what plays the role of restoring a failed increment?

6.  Does a valid `AgentStep` mean a correct answer?

    *Hint:* Step 3 multiplied 70 by 3.  Would validation have noticed if it had multiplied by 4?

---

# Part V: MCP Tool Arguments

## 7.  A Write Tool That Checks Its Own Arguments

In the *MCP: Connecting Agents to Tools and Your Obsidian Vault* activity, the vault server's `append_daily_note` writes only when `confirm` is true.  That gate is only as strict as the type it checks: in Python, the *string* `"false"` is true, because it is not empty.  A strict model closes that gap, refuses keys the tool never declared, and generates the schema the server advertises.

## Code Cell: Strict Arguments

```python
# P8: an MCP write tool's arguments as a strict Pydantic model
import traceback
from pydantic import BaseModel, ConfigDict, Field, StrictBool, ValidationError

class AppendDailyNoteArgs(BaseModel):
    """Append a line to today's daily note. Writes only when confirm is true."""
    model_config = ConfigDict(extra="forbid")          # unknown keys are an error, not ignored
    text: str = Field(min_length=1, max_length=500)
    confirm: StrictBool = False                        # only a real JSON true counts

for args in ({"text": "Tried the vault server in class.", "confirm": True},
             {"text": "Tried the vault server in class.", "confirm": "false"},
             {"text": "x", "confirm": True, "path": "../../.bashrc"}):
    try:
        a = AppendDailyNoteArgs.model_validate(args)
        print("OK      ", a)
    except ValidationError as e:
        print("REFUSED ", "; ".join(f"{x['loc'][0]}: {x['msg']}" for x in e.errors()))
        traceback.print_exc()

# What a server's tool list would advertise for this tool, generated rather than typed by hand:
print(AppendDailyNoteArgs.model_json_schema())
```

You should see one call accepted and two refused, then the generated schema:

```text
OK       text='Tried the vault server in class.' confirm=True
REFUSED  confirm: Input should be a valid boolean
REFUSED  path: Extra inputs are not permitted
{'additionalProperties': False, 'description': "Append a line to today's daily note. Writes only when confirm is true.", 'properties': {'text': {'maxLength': 500, 'minLength': 1, 'title': 'Text', 'type': 'string'}, 'confirm': {'default': False, 'title': 'Confirm', 'type': 'boolean'}}, 'required': ['text'], 'title': 'AppendDailyNoteArgs', 'type': 'object'}
```

`StrictBool` accepts only a real `true` or `false`.  `extra="forbid"` turns an undeclared key such as `path` into an error instead of silently ignoring it, and it shows up in the schema as `'additionalProperties': False`, so a client reading the tool list learns the rule too.

---

# Part VI: RAG Records: Valid Is Not Faithful

## 8.  What Was Retrieved, and What Was Answered

The *RAG Knowledge Base* activity's pipeline retrieves chunks and asks the model to answer only from them, citing what it used.  Two records make that contract checkable: one for each retrieved chunk, and one for the answer, which must either cite something or say it abstained.  A bag-of-words count stands in for the embedding so the cell runs anywhere.

## Code Cell: Retrieval, Answer, Citation Check

```python
# P9: the RAG deck's pipeline with a toy embedding, and Pydantic records for what was
# retrieved and what the model answered.
import math
import re
import traceback
from pydantic import BaseModel, Field, ValidationError, model_validator

DOCS = [   # the RAG deck's five campus documents
    "Parking: First-year resident students may not bring vehicles to campus without a hardship waiver.",
    "Library: The Myrin Library is open 8am to midnight Monday through Thursday during the semester.",
    "Dining: Wismer Center serves continuous dining from 7am to 8pm on weekdays.",
    "Advising: Each student is assigned a faculty advisor; registration requires advisor approval.",
    "Athletics: The Floy Lewis Bakes Center is open to all students with a valid ID.",
]
STOP = {"a", "an", "the", "to", "on", "of", "is", "can", "may", "with", "and", "from", "all", "keep", "bring", "what", "does", "time"}
SYN = {"car": "vehicles", "cars": "vehicles"}   # the kind of thing a real embedding learns

def toy_embed(text):
    """Bag of words: a stand-in for a real embedding.  Same text in, same vector out."""
    words = [SYN.get(w, w) for w in re.findall(r"[a-z0-9-]+", text.lower()) if w not in STOP]
    v = {}
    for w in words:
        v[w] = v.get(w, 0) + 1
    return v

def cosine(u, v):
    dot = sum(u[w] * v.get(w, 0) for w in u)
    nu = math.sqrt(sum(x * x for x in u.values()))
    nv = math.sqrt(sum(x * x for x in v.values()))
    return dot / (nu * nv) if nu and nv else 0.0

class RetrievedChunk(BaseModel):
    id: str
    score: float = Field(ge=0.0, le=1.0)
    text: str

class RAGAnswer(BaseModel):
    answer: str
    citations: list[str]        # chunk ids, such as ["doc0"]
    abstained: bool

    @model_validator(mode="after")
    def abstain_or_cite(self):
        if not self.abstained and not self.citations:
            raise ValueError("an answer that does not abstain must cite at least one chunk")
        return self

# --- Indexing phase (once) ---
INDEX = [(f"doc{i}", toy_embed(d), d) for i, d in enumerate(DOCS)]

# --- Query phase (per question) ---
def retrieve(question, k=2):
    q = toy_embed(question)
    ranked = sorted(INDEX, key=lambda row: -cosine(q, row[1]))[:k]
    return [RetrievedChunk(id=i, score=round(cosine(q, v), 3), text=t) for i, v, t in ranked]

def check_citations(ans, hits):
    """The model may cite only chunks it was actually given."""
    given = {h.id for h in hits}
    bad = [c for c in ans.citations if c not in given]
    return "citations OK" if not bad else f"UNFAITHFUL: cited {bad}, was given {sorted(given)}"

# Three replies a model might give, written by hand so the checks are visible.
for question, model_reply in [
    ("Can a first-year student keep a car on campus?",
     '{"answer": "No, not without a hardship waiver [doc0].", "citations": ["doc0"], "abstained": false}'),
    ("What time does the bookstore close?",
     '{"answer": "not in my documents", "citations": [], "abstained": true}'),
    ("What time does the bookstore close?",
     '{"answer": "The bookstore closes at 5pm.", "citations": ["doc3"], "abstained": false}'),
]:
    hits = retrieve(question)
    print("Q:", question)
    for h in hits:
        print(f"   {h.id}  {h.score:.3f}  {h.text[:60]}")
    try:
        ans = RAGAnswer.model_validate_json(model_reply)
        print("   ->", ans.answer, "|", check_citations(ans, hits))
    except ValidationError as e:
        print(f"[pydantic_tut:p9] {e.errors()[0]['msg']}")
        traceback.print_exc()
```

You should see three questions, each with its two retrieved chunks and a verdict:

```text
Q: Can a first-year student keep a car on campus?
   doc0  0.474  Parking: First-year resident students may not bring vehicles
   doc3  0.144  Advising: Each student is assigned a faculty advisor; regist
   -> No, not without a hardship waiver [doc0]. | citations OK
Q: What time does the bookstore close?
   doc0  0.000  Parking: First-year resident students may not bring vehicles
   doc1  0.000  Library: The Myrin Library is open 8am to midnight Monday th
   -> not in my documents | citations OK
Q: What time does the bookstore close?
   doc0  0.000  Parking: First-year resident students may not bring vehicles
   doc1  0.000  Library: The Myrin Library is open 8am to midnight Monday th
   -> The bookstore closes at 5pm. | UNFAITHFUL: cited ['doc3'], was given ['doc0', 'doc1']
```

The third reply passes validation: it is well-formed and it cites a chunk.  It is still unfaithful, because it cites `doc3`, which the retriever never gave it.  The citation check catches it because it compares the answer with the retrieval, which is something a schema alone cannot do.  Notice also the bookstore scores of 0.000: retrieval returns `k` chunks even when none of them is relevant.

### Questions to Work Through

7.  The car question matches `doc0` only because of the one synonym entry, `car` to `vehicles`.  Remove it and predict the scores.  What does a real embedding do that this stand-in cannot?

8.  Add a rule to `RAGAnswer` or to `retrieve` that would have made the bookstore question abstain on its own.  Which one is the right place for it, and why?

    *Hint:* One of the two knows the scores.

---

## Exercises

Everything below is optional.  Nothing here is collected and nothing here is graded; each exercise ends with a check you can apply yourself.

1.  **A model of your own.**  Write `FinalExamArgs` with a `course` field that must match `^[A-Z]{2,4}\d{3}$` and a `date` field, and register it beside `days_until` in the validated registry.

    *You've succeeded when:* a call with `course="CS357"` runs, a call with `course="cs 357"` comes back as an error string the model could act on, and the generated tool list shows the pattern.

2.  **Forbid what you did not declare.**  Add `model_config = ConfigDict(extra="forbid")` to `DaysUntilArgs` in the registry cell and send `{"target_iso": "...", "verbose": true}`.

    *You've succeeded when:* you can say what the call did before the change, what it does after, and which behavior you want from a tool a model calls.

3.  **A score threshold.**  Change `retrieve` so that chunks scoring below a threshold you choose are dropped, and the bookstore question returns no chunks.

    *You've succeeded when:* the car question still retrieves `doc0`, the bookstore question retrieves nothing, and you can state in one sentence how you chose the threshold.

---

## Reflection Prompt

**Technical level:** Every check in this tutorial guarantees a shape.  Name the one place in your own project where a reply could have the right shape and the wrong meaning, and say what would catch it.

**Personal level:** Which of these checks would you have skipped if you were in a hurry, and what would it have cost you to find the bug later?

**Societal level:** A validated, well-cited, confident answer is more persuasive than a messy one, whether or not it is right.  Who bears the cost when a system's polish outruns its correctness?

---

## Further Reading

- Pydantic documentation, "Models" and "Validators" (online): https://docs.pydantic.dev
- [Ollama Structured Outputs](https://docs.ollama.com/capabilities/structured-outputs), on schema-constrained JSON.
- [Instructor with Pydantic and Ollama](https://python.useinstructor.com/integrations/ollama/), validation with automatic retry.
- [Agent Frameworks](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/AgentFrameworks), Part V, where Pydantic AI generates tool schemas from type hints the same way.
