---
layout: assignment
permalink: /Assignments/ToolsMCP
title: "CS357: Foundations of Artificial Intelligence - Lab: Tools and MCP"

info:
  coursenum: CS357
  points: 100
  goals:
    - To give an agent real tools using native function calling, and to know which side of the boundary your code owns
    - To make an agent reason explicitly, and to measure whether the reasoning paid for itself
    - To both author and consume an MCP server, and to articulate what the protocol standardizes
    - To constrain model output so that downstream code can parse it reliably rather than hopefully
  rubric:
    - weight: 30
      description: "Tool Use"
      preemerging: "No working tool call, or the model is asked for a tool but nothing executes."
      beginning: "A tool is called, but the schema is untyped or the result is not fed back to the model as a tool-role message."
      progressing: "A typed tool is registered and invoked end to end, with a transcript showing the round trip."
      proficient: "A typed tool is registered and invoked end to end, the transcript shows request and execution and the fed-back result, and the writeup names precisely what your code is responsible for that the model is not. On the no-code and low-code routes, the exported chat transcript or Langflow run showing the tool firing stands in for the code transcript; the requirement to name the boundary precisely is unchanged and carries the row."
    - weight: 20
      description: "Structured Output"
      preemerging: "Output is parsed ad hoc from prose; no technique demonstrated."
      beginning: "A structured-output technique is used but no failure case is shown, so the reliability claim is untested."
      progressing: "One technique is demonstrated with a before-and-after: naive parsing breaks on a real response, the constrained version does not."
      proficient: "As progressing, and the writeup distinguishes which techniques guarantee validity by construction from those that merely encourage it, with the evidence to back the distinction."
    - weight: 25
      description: "Reasoning, Measured"
      preemerging: "No reasoning variant, or no comparison."
      beginning: "A reasoning variant exists but is compared informally, without a fixed task set or a fixed seed."
      progressing: "Plain and reasoning versions run over at least eight fixed tasks at a fixed seed, with an accuracy delta reported."
      proficient: "As progressing, plus the token and latency cost of the reasoning, and a defensible sentence on when that cost was earned and when it was not. On a no-code route, wall-clock time and response length are acceptable stand-ins for latency and token counts, provided the measurement method is stated."
    - weight: 20
      description: "MCP"
      preemerging: "No MCP work."
      beginning: "An MCP server or client is configured but no discover-and-invoke round trip is shown."
      progressing: "A transcript shows tool discovery followed by a successful invocation. For the Obsidian vault option, the transcript shows discovery, one read, and one gated append that was refused and then confirmed."
      proficient: "As progressing, and the writeup states what MCP standardizes that a hand-rolled tools list does not, and, for the consume option or a community vault server, names the trust question raised by running someone else's tool definitions. Consuming a server through a client's configuration file earns this row on the same terms as consuming it from code, and the Obsidian vault option, whether written or configured, earns this row on the same terms as the create and use options."
    - weight: 5
      description: "Writeup and Reproducibility"
      preemerging: "No writeup, or one that cannot be followed."
      beginning: "A writeup exists but a reader could not reproduce the runs from it."
      progressing: "Model, parameters, and commands are recorded well enough to reproduce."
      proficient: "Fully reproducible, with an AI-use disclosure naming what was AI-assisted and how it was verified."

tags:
  - lab

---

# Lab: Tools and MCP

The Local Agent Lab built an agent that perceives, plans, and acts in a loop, but the only action it could take was producing text.  In this lab you give that agent hands.  You register a typed tool the model can call, you constrain the model's output so your code can parse it reliably, you measure whether making the agent reason paid for itself, and you connect the agent to tools over MCP (the Model Context Protocol, the standard the rest of the ecosystem is settling on).  You leave with an agent that can act on the world and with evidence, in transcripts and tables, of when it chose to act and what that cost.

The three capabilities here used to be part of the Local Agent Lab, where they were due before the sessions that teach them.  They now stand on their own, so every part of this lab is something you have already seen in class: the *Tool Use and Function Calling* session, the *MCP: Connecting Agents to Tools and Your Obsidian Vault* session, and the structured-output reading attached to both.

---

## Choose Your Path

The three capabilities and the writeup are the same on every route.  What differs is whether you build the wiring or configure it.

| Route | What you build | What you need | Pick this if |
|-------|----------------|---------------|--------------|
| **Code** | A typed tool registered with the model, with an executor loop you own; two runners over a fixed task set at a fixed seed; a small MCP server you author, or an existing server you consume from code | Ollama with a model that supports tool calling, Python 3 with `requests` | You are heading for the Local Agent Lab's MCP and OAuth direction, or you want the clearest view of the boundary between what your code owns and what the model owns |
| **No-code** | In **Open WebUI**: enable a built-in or community tool on a model and observe the invocation inline; compare a plain model against a reasoning-prompted one across your eight fixed tasks, both in the chat interface; add an MCP server to Open WebUI's tool settings and show discovery, then invocation.  Low-code variant in **Langflow**: a **Tool** node wired to an **Agent** node; the same reasoning comparison as two flows; an MCP server configured in a client's config file, with discovery and invocation shown | Open WebUI alone for the no-code variant; Open WebUI or Langflow for the low-code variant | You want your attention on *when the model chooses to call a tool*, which is the hard part, rather than on the plumbing; or you think better in a diagram and want the visual trace of which path executed |

The rubric is the same on every path.  Every route must show structured output (Part 2), and every route needs a transcript.  On the no-code route, export the chat rather than pasting a screenshot of the answer: the tool invocation record is the evidence, not the reply.

> **Watch out.** Do not read the No-code row as "the version without the hard part."  The hard part of this lab is explaining why the model called the tool when it did and not when it did not, and that question is identical on every route.  The code route buys you a clearer view of the boundary between what your code owns and what the model owns.  The no-code route buys you more time looking at the decision itself.

---

## Before You Start

This lab builds on:

- the *Tool Use and Function Calling* session
- the *MCP: Connecting Agents to Tools and Your Obsidian Vault* session
- the structured-output reading attached to both
- the agent loop you built in the Local Agent Lab (this lab gives that agent hands)

You also need, by route:

- **Code route:** Ollama running with a model that supports tool calling, and Python 3 with the `requests` library.
- **No-code route:** Open WebUI running.  For the Langflow low-code variant, Langflow running as well.
- **Obsidian vault option (any route):** a vault folder (a folder of Markdown notes) that your server or tool can reach.

On the code route, install what the walkthrough uses and pull a tool-calling model.  `pip` installs a Python package; `ollama pull` downloads a model so Ollama can serve it locally.

```bash
pip install requests                                  # the HTTP client the walkthrough uses
python3 -c "import requests; print('requests ok')"   # confirm Python can import it
ollama pull llama3.2                                  # a model that supports tool calling
```

Then confirm Ollama is answering.  `curl -s` fetches a URL quietly, and `head -c 120` keeps only the first 120 characters so the model list does not flood your terminal.

```bash
curl -s http://localhost:11434/api/tags | head -c 120
```

> **You should see.** The start of a JSON object listing your installed models, including `llama3.2`.  The exact names and dates will differ:

```text
{"models":[{"name":"llama3.2:latest","model":"llama3.2:latest","modified_at":"2026-09-01T10:14:22
```

> **If it fails.** An empty response or `Connection refused` means the Ollama server is not running; start it and retry.  A list that does not include `llama3.2` means the pull did not finish.

> **Watch out.** Check this now rather than at hour four: not every local model does native function calling well.  A model that does not will produce prose describing a tool call instead of emitting one.  Test with a trivial tool before you build anything real.  If your model will not emit tool calls, say so in your writeup, switch models, and note what you observed.  That observation is worth more than a clean run on a model you did not choose deliberately.

Start the reasoning comparison early.  Eight tasks times two conditions is mostly wall-clock waiting, and it is the one part of this lab you cannot compress on the last night.

> **Time budget.** Roughly 6 to 8 hours: about 2 hours for tool use plus structured output, 2 to 3 for the reasoning comparison (most of it waiting on runs), and 2 to 3 for MCP.  The reasoning comparison is the one to start early, because eight tasks times two conditions is a lot of wall-clock time if you leave it to the last night.

**What you will have at the end:** an agent that can act on the world, a demonstrated technique for making its output parseable, a measured answer to "did making it reason pay for itself," and working experience with the protocol the rest of the ecosystem is standardizing on.

---

## The Three Capabilities: Pick at Least One of Each

Every submission must show that you can make an agent use a tool, make an agent reason, and work with MCP.  Each capability comes in more than one flavor: build it from scratch (you own the wiring) or drive it from a framework, a served model, or an existing server (you own the configuration).  You may do more than one flavor of a capability if it interests you, but one of each capability is the floor.  Fold your chosen options into your writeup with the transcript evidence each one asks for.

> **Do this.** Complete, at minimum:
> 1. **At least one** Tool Use option (Part 1: Option 1A or 1B).
> 2. **At least one** Reasoning option (Part 3: Option 3A or 3B).
> 3. **At least one** MCP option (Part 4: Option 4A, 4B, or 4C).
> 4. **The structured-output demonstration, required for everyone** (Part 2).  It is part of your Tool Use work, and it carries its own rubric row.

| Capability | Options | Rubric row |
|------------|---------|------------|
| Tool Use | 1A From Scratch, 1B From a Framework | Tool Use (30) |
| Structured Output | One technique, before and after (required) | Structured Output (20) |
| Reasoning | 3A From Scratch, 3B Use a Reasoning Model | Reasoning, Measured (25) |
| MCP | 4A Create, 4B Use, 4C Obsidian Vault | MCP (20) |

---

## Part 1: Tool Use (30 points)

Give your agent a real, typed tool using **native function calling** (not the week-1 regex parse).  A tool call is a structured request the model emits, naming a function and its arguments, that your code executes and feeds back to the model.  Pick at least one of the two options below, then follow the walkthrough steps, which build Option 1A end to end on the code route.  If you choose Option 1B, do Steps 1.1 through 1.3 and then hand the same tools to the framework instead of writing the loop in Step 1.4.  Part 2 explains why a tool call is only as reliable as the schema behind it; read Steps 2.1 and 2.2 first if you want that context before you build.

### Option 1A: From Scratch, Expose a Function to the Model

Define a Python function, describe it as a JSON schema in a `tools` list, and let the model emit a structured `tool_calls` request that your code executes and feeds back as a `tool`-role message.  Do this against Ollama's `/api/chat` *or* Open WebUI's OpenAI-compatible `/api/chat/completions`; the schema is identical across both (see the [Tool Use and Function Calling activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-tooluse.md), Parts II-2b).

> **Paste into your submission.** Your tool schema, a transcript showing the model requesting the tool and your program executing it, and one sentence on what your code (not the model) is responsible for.

### Option 1B: From a Framework, Give an Agent Tools You Did Not Wire

Hand the same tool to an agent through a framework so the framework owns the tool-calling loop.  Register a Python function as a tool with **smolagents** (Hugging Face's lightweight agent library, the gentlest starting point), LangChain/DeepAgents, or Agno, and let it drive invocation (see the [Agent Frameworks activity]({{ site.baseurl }}/Tutorials/AgentFrameworks), including how to point the framework at your local Ollama/Open WebUI model).  If you are new to frameworks, prefer smolagents: it is a much thinner wrapper than LangChain, so less of the loop is hidden and the code you write stays close to the from-scratch version.

> **Paste into your submission.** The tool registration, a run transcript, and two things the framework hid from you that you had to do by hand in the from-scratch version.

### Step 1.1: Create the Folder and Plan the Three Files

In the walkthrough you define three tools in the OpenAI function-calling JSON schema format (the standard way to describe a tool's name, purpose, and parameters as a JSON object) and call them from your local model through Ollama's `/api/chat` endpoint.  Everything runs locally; you need no external API keys or cloud services.

> **Do this.**
> 1. Create a folder named `tools-lab/` and do all of the following work inside it.
> 2. Plan on three files, built in this order:

| File | Holds | Step |
|------|-------|------|
| `tool_definitions.py` | The `TOOLS` list: each tool's name, description, and JSON Schema | Step 1.2 |
| `tool_impl.py` | The Python functions themselves plus the `REGISTRY` that maps a name to a function | Step 1.3 |
| `agent.py` | The loop that calls the model, dispatches tool calls, and feeds results back | Step 1.4 |

> **Why this matters.** Splitting the files this way is the point of the exercise, not bookkeeping.  The model only ever sees `tool_definitions.py`, never the code in `tool_impl.py`.  Separate files make that boundary visible.  If you would rather work in a single file or a notebook, that is fine; keep the three parts in clearly separated, labeled sections.

### Step 1.2: Define the Tools in `tool_definitions.py`

Each tool is a JSON object with a `name`, a `description` (the only thing the model reads to decide whether to use this tool), and a `parameters` block written in JSON Schema.

> **Do this.**
> 1. Create `tool_definitions.py` in `tools-lab/`.
> 2. Paste the `TOOLS` list below into it.
> 3. Confirm Python can load it.  This one-line command imports the list and prints how many tools it holds:
>
> ```bash
> python3 -c "from tool_definitions import TOOLS; print(len(TOOLS))"
> ```

```python
TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "calculator",
            "description": (
                "Evaluates a simple arithmetic expression and returns the numeric result. "
                "Use this whenever the user asks for a calculation, not for counting words."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "expression": {
                        "type": "string",
                        "description": (
                            "A valid Python arithmetic expression using only numbers and "
                            "operators +, -, *, /, **, and parentheses. "
                            "Example: '(3 + 4) * 2' or '2 ** 10'."
                        )
                    }
                },
                "required": ["expression"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_current_time",
            "description": (
                "Returns the current local date and time as a string. "
                "Call this whenever the user asks what time or date it is."
            ),
            "parameters": {
                "type": "object",
                "properties": {},
                "required": []
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "word_count",
            "description": (
                "Counts the number of words in the provided text and returns the integer count. "
                "Use this when the user asks how many words are in a passage or sentence."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "text": {
                        "type": "string",
                        "description": "The text whose words should be counted."
                    }
                },
                "required": ["text"]
            }
        }
    },
]
```

> **You should see.** The number `3`.  A `SyntaxError` means a bracket or comma went missing in the paste.

### Step 1.3: Implement the Tools and the Registry in `tool_impl.py`

The executor pattern keeps a **registry** (a plain Python dictionary mapping tool names to their implementations).  Your agent loop never calls a tool directly from the model's request; it looks the name up in the registry first.  This is the security boundary: only tools you explicitly register can ever run.

> **Do this.**
> 1. Create `tool_impl.py` in `tools-lab/`.
> 2. Paste the code below into it.
> 3. Call one tool through the registry by hand, the same way the agent loop will:
>
> ```bash
> python3 -c "from tool_impl import REGISTRY; print(REGISTRY['calculator']('(3 + 4) * 2'))"
> ```

```python
import ast
import operator
import datetime

# Safe arithmetic evaluator - no eval() of arbitrary code
_SAFE_OPS = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
    ast.Pow: operator.pow,
    ast.USub: operator.neg,
}

def _safe_eval(node):
    if isinstance(node, ast.Constant):
        return node.value
    if isinstance(node, ast.BinOp):
        return _SAFE_OPS[type(node.op)](_safe_eval(node.left), _safe_eval(node.right))
    if isinstance(node, ast.UnaryOp):
        return _SAFE_OPS[type(node.op)](_safe_eval(node.operand))
    raise ValueError(f"Unsupported node type: {type(node)}")

def calculator(expression: str) -> str:
    try:
        tree = ast.parse(expression, mode="eval")
        result = _safe_eval(tree.body)
        return str(result)
    except Exception as e:
        return f"error: {e}"

def get_current_time() -> str:
    return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def word_count(text: str) -> str:
    return str(len(text.split()))

REGISTRY = {
    "calculator": calculator,
    "get_current_time": get_current_time,
    "word_count": word_count,
}
```

> **You should see.** The string `14`.  Every tool returns a string, because the result goes back to the model as message text.

> **Watch out.** `calculator` parses the expression with Python's `ast` module (a library that safely parses code into a tree of operations) rather than calling `eval()`.  This is intentional: `eval()` on a model-supplied string is an arbitrary code execution vulnerability.  The `_safe_eval` function only handles numeric literals and the arithmetic operators, so the model cannot inject `import os; os.system(...)` or any other dangerous expression.

### Step 1.4: Write the Agent Loop in `agent.py`

The loop sends the conversation and the `TOOLS` list to the model.  When the model answers with `tool_calls`, the loop looks each name up in `REGISTRY`, runs it, and appends the result as a `tool`-role message so the model can read it on the next turn.  When the model answers with plain content, the loop returns it.

> **Do this.**
> 1. Create `agent.py` in `tools-lab/`.
> 2. Paste the code below into it.  The first two lines import `TOOLS` from `tool_definitions.py` and `REGISTRY` from `tool_impl.py`.
> 3. Make sure Ollama is running (the health check in Before You Start) before you go to Step 1.5.

```python
from tool_definitions import TOOLS   # what the model sees
from tool_impl import REGISTRY       # what your code runs
import json
import requests

def agent(question: str, max_steps: int = 5) -> str:
    msgs = [{"role": "user", "content": question}]

    for step in range(max_steps):
        try:
            response = requests.post(
                "http://localhost:11434/api/chat",
                json={
                    "model": "llama3.2",
                    "stream": False,
                    "tools": TOOLS,
                    "options": {"temperature": 0.0, "seed": 42},
                    "messages": msgs,
                },
                timeout=120,
            ).json()["message"]
        except Exception as e:
            import traceback; traceback.print_exc()
            return f"request error: {e}"

        msgs.append(response)
        calls = response.get("tool_calls") or []

        if not calls:
            # Model chose to answer directly - no tool needed
            return response.get("content", "")

        for call in calls:
            name = call["function"]["name"]
            args = call["function"].get("arguments") or {}
            if name in REGISTRY:
                result = REGISTRY[name](**args)
            else:
                result = f"unknown tool: {name}"
            print(f"[tool] {name}({args}) -> {result}")
            # Tool result goes back as a 'tool' role message
            msgs.append({"role": "tool", "content": result})

    return "step budget exceeded"

# Test all three tools
print(agent("What is (144 / 12) ** 2?"))
print(agent("What time is it right now?"))
print(agent("How many words are in the sentence: 'The quick brown fox jumps over the lazy dog'?"))
```

### Step 1.5: Run It and Read the Transcript

This is the part most people find satisfying: the model asks for a tool, your code runs it, and the model uses the answer.

> **Do this.**
> 1. From inside `tools-lab/`, run the agent.  `python3 agent.py` executes the file, which fires the three test questions at the bottom:
>
> ```bash
> python3 agent.py
> ```
>
> 2. Save the full terminal output.  This is the transcript Option 1A asks for, and it must show all three parts of the round trip: the request, the execution, and the result fed back.

> **You should see.** One `[tool]` line per question, printed by your loop when it executes the call, followed by the model's final answer in prose.  The arithmetic and word-count results are exact; the time and the model's wording will differ:

```text
[tool] calculator({'expression': '(144 / 12) ** 2'}) -> 144.0
(144 / 12) ** 2 is 144.
[tool] get_current_time({}) -> 2026-09-10 14:03:51
It is currently 2:03 PM on September 10, 2026.
[tool] word_count({'text': 'The quick brown fox jumps over the lazy dog'}) -> 9
There are 9 words in that sentence.
```

> **If it fails.**
> - No `[tool]` line and an answer that *describes* calling a calculator: the model is not emitting native tool calls.  Confirm the model supports tool calling (see Before You Start) and switch if it does not.
> - `request error: ...` with a connection message: Ollama is not running on port 11434.
> - `unknown tool: ...`: the name the model asked for is not a key in `REGISTRY`.  Check that the `name` in `tool_definitions.py` matches the key in `tool_impl.py` exactly.

> **No-code path.** You may complete the tool-use capability **without writing tool-calling code**, by wiring the same tool in Open WebUI or Langflow.  The learning goal is identical (understand what a tool call is, when the model chooses one, and how it fails) and so is the credit.
> 1. **Give the model a tool without code.** In Open WebUI, enable a built-in tool (web search, or the code interpreter) for one model, or import a community tool.  In Langflow, drag a **Tool** node onto the canvas and connect it to an **Agent** node.
> 2. **Watch the decision, not the output.** Ask three questions: one the model can answer from memory, one that clearly needs the tool, and one that is ambiguous.  For each, capture *whether the tool fired*: Open WebUI shows the tool invocation inline; Langflow highlights the executed path.
> 3. **Break it on purpose.** Disconnect the tool (or revoke its permission) and re-ask the question that needed it.  Record what the model does when the capability disappears: does it say so, or does it invent an answer?
>
> What you submit instead of code: screenshots of the flow or tool configuration, an exported chat or Langflow run showing the tool firing, a table of your three questions with *tool fired: yes/no* and the answer given, and the same written analysis the code route requires.  The analysis is where the grade lives, and it is unchanged: you still have to explain *why* the model called the tool when it did, which is the hard part either way.

### Step 1.6: Work Through the Critical Thinking Questions

Answer these in your writeup.  Question 11 needs a second run of `agent.py`; the others need only the code in front of you.

11. The model decides whether to call a tool based on the tool's **description**, not its name.  Change the `calculator` tool's description to `"counts the words in text"` and re-run the word-count question.  What does the model do?  What does this tell you about where the real "logic" of tool selection lives?

    *Hint: The model never sees your Python function bodies; it only sees the JSON schema.  Swapping the description effectively swaps the tool's identity from the model's perspective.  Run `agent("How many words are in 'hello world'?")` with the swapped description and observe which tool fires.*

12. When the agent loop appends a tool result back into the conversation, what `role` value must that message use?

    - `"user"`
    - `"assistant"`
    - `"tool"`
    - `"system"`

    *Hint: Look at the line `msgs.append({"role": "tool", "content": result})` in the agent loop.  The OpenAI-compatible API (which Ollama follows) requires the role `"tool"` so the model knows this message is a function result rather than a user turn or its own prior response.*

> **Answer.** `"tool"`.

13. Consider a fourth tool: `read_file(path: str) -> str` that opens a file path supplied by the user and returns its contents.  What security risk does this create, and what would you do to mitigate it?

    *Hint: Think about what happens when the model (prompted by a malicious user) supplies the path `/etc/passwd`, `~/.ssh/id_rsa`, or `../../config/secrets.json`.  The mitigation involves restricting which directories the tool is allowed to read from: for example, only allowing paths that begin with an approved prefix such as `/home/user/documents/`.  You might also check that the resolved absolute path (after following symlinks with `os.path.realpath`) still begins with that prefix, to prevent path traversal attacks.*

> **Watch out.** Students often assume `tool_choice="auto"` means the model will always call a tool.  It means the model *may* call a tool if it decides one is needed; it can also answer from memory without calling any tool at all.  If you need a specific tool invoked for every request (for safety, auditing, or consistency), set `tool_choice={"type": "function", "function": {"name": "tool_name"}}` to force it.  The difference matters for tools like `log_query` that you want called every time regardless of the model's judgment.

---

## Part 2: Get Structured Output You Can Parse (20 points)

Before your tool-use option can be trusted, the model has to return data your code can parse reliably, not free-form prose that happens to contain JSON.  Steps 2.1 through 2.4 used to live in a separate Structured Outputs activity.  They are here because the required demonstration in Step 2.5 depends on them, and because a tool call is only as reliable as the schema you constrain it with.  The four output modes in Step 2.2 in particular decide how much error handling your executor needs.

> **Do this.** **Required for everyone: structured output.**  As part of your Tool Use work, demonstrate **one** structured-output technique and show it recovering from a case where naive parsing fails.  Pick one:
> - **Ollama's `format` parameter**: pass a JSON Schema (or `"json"`) in the request so the server constrains the response to valid JSON.  See the [Ollama structured outputs docs](https://docs.ollama.com/capabilities/structured-outputs).
> - **[Instructor](https://python.useinstructor.com/integrations/ollama/)**: define a Pydantic model (a typed schema much like the dataclasses you already write) and let Instructor validate and auto-retry until the response conforms.
> - **[Outlines](https://github.com/dottxt-ai/outlines)**: constrain decoding to a grammar, regex, or JSON schema so invalid tokens are *impossible*, not merely discouraged.
>
> Deliver: a two-or-three-sentence note in your writeup showing a before (free-form parse breaks on a real model response) and after (constrained output parses every time), and one sentence on which of the three guarantees validity versus merely encourages it.  This is the reliability glue the rest of your agent's tool calling depends on.

### Step 2.1: Learn the Vocabulary

These six terms carry the rest of Part 2.  Read the table once now and come back to it when a question uses a term.

| Term | Plain-English Definition | Example You'll See Today |
|------|--------------------------|--------------------------|
| **Structured Output** | An LLM response that conforms to a predefined format (like a JSON object with specific fields) rather than free-form prose | `{"sentiment": "negative", "confidence": 0.87}` instead of "This article seems pretty negative, maybe around 87% confident" |
| **JSON Schema** | A standard language for describing the shape of a JSON object: what fields exist, what types they must be, which are required, and what values are valid | `{"type": "object", "required": ["sentiment"], "properties": {"sentiment": {"type": "string", "enum": ["positive","negative","neutral"]}}}` |
| **Syntactic Validity** | Whether the output can be parsed as valid JSON (or another format); it opens and closes brackets correctly and uses proper quoting | `{"key": "value"}` is syntactically valid; `{"key": value}` is not (missing quotes around `value`) |
| **Schema Validity** | Whether the output conforms to the specific schema: required fields are present, types are correct, enum values are within the allowed set | `{"sentiment": "very bad"}` is syntactically valid JSON but schema-invalid because "very bad" is not in the allowed enum |
| **Semantic Validity** | Whether the output means what was intended: the values are not just correctly formatted but actually accurate and calibrated | `{"sentiment": "positive", "confidence": 0.99}` for an article that is clearly negative is schema-valid but semantically wrong |
| **Pydantic** | A Python library that defines data models with type annotations and validates that incoming data conforms to the model, raising a `ValidationError` with a detailed message if it does not | `class BiasAnalysis(BaseModel): confidence: float = Field(ge=0.0, le=1.0)` rejects `confidence: 1.5` automatically |

### Step 2.2: Compare the Four Output Modes

There is no single "structured output" approach.  There is a spectrum of mechanisms with different guarantees and different failure modes, and what each mode actually does (not what its marketing says) decides which one to reach for.

> **Do this.**
> 1. Read the before-and-after below, then the table.
> 2. For each mode, write down in one line which validity level (syntactic, schema, semantic) it guarantees.  You will need that list in Step 2.5.
> 3. Answer Questions 1 through 3 in your writeup.

> **You should see.** The same prompt produces output like this in each mode:

```text
SAME PROMPT: "Classify the sentiment of: 'The product broke after one day.'"

Plain text output:   "The sentiment of this review is clearly negative. The customer
                      is unhappy because the product failed quickly."
                      -> Cannot parse; requires fragile regex; breaks if phrasing changes

JSON mode output:    {"sentiment": "negative", "reasoning": "Product failure = negative"}
                      -> Usually works, but model might also output prose on a bad day

Tool/function call:  tool_calls=[{"name":"classify","args":{"sentiment":"negative"}}]
                      -> Structural format guaranteed; values still up to the model

Grammar-constrained: {"sentiment": "negative"}
                      -> Mathematically guaranteed to match the schema; no other output possible
```

| Mode | How It Works | Guarantee Provided | Typical Failure Mode |
|------|-------------|-------------------|---------------------|
| **Plain text** | The model generates tokens with no format constraint at all; it produces whatever prose seems most natural | None: output may be anything; format varies based on phrasing of the question | Cannot be parsed programmatically; format changes unpredictably when the prompt is reworded or the model version changes |
| **JSON mode** (instruction-based) | The system prompt instructs the model to output JSON; the model is free to comply or not; it is just a strong suggestion | Soft: the model usually produces valid JSON but may produce prose, truncated JSON, or JSON with extra unexpected fields on a bad day | Model ignores the instruction when the context is long, when it is uncertain, or when the question triggers a refusal; no enforcement mechanism catches this |
| **Function calling / tool use** | The API wraps the model's output in a structured function-call schema; the model generates a `tool_calls` field rather than prose | The format of the function call is guaranteed to be structurally valid; argument types match the declared schema | Model may call the wrong tool when multiple tools are available, omit required arguments, or pass arguments with the right type but wrong semantic content (a valid-format but wrong value) |
| **Grammar-constrained decoding** (Outlines, LMQL, llama.cpp grammars) | At each decoding step, the token sampler masks out any token that would violate the grammar; only valid-next-token candidates can be sampled | Syntactic validity is mathematically guaranteed at the token level; the output will always parse as valid JSON matching the schema | Model may produce syntactically valid but semantically wrong output (correct format, wrong meaning); very complex required outputs can degrade overall response quality |

Three properties are worth separating clearly.  They are the levels of correctness:

- **Syntactic validity**: Is the output parseable as JSON (or another format)?  Does it have matching brackets and correct quoting?
- **Schema validity**: Does the output conform to the specific schema: required fields present, types correct, enum values within the allowed set?
- **Semantic validity**: Does the output mean what was intended: is the confidence score actually calibrated, does the citation actually exist, is the sentiment label actually accurate?

Grammar-constrained decoding guarantees syntactic validity only.  Function calling with a schema guarantees syntactic and schema validity.  Nothing guarantees semantic validity; that takes evaluation, human oversight, or both.

#### Questions to Work Through

1.  A developer uses JSON mode (instruction-based) for a production system and never validates the output, arguing "the model always produces valid JSON in my testing."  Describe a specific production scenario where this assumption breaks, explain exactly what class of failure it causes in the downstream system, and estimate how long it might go undetected.

    *Hint: Testing typically uses short, clean inputs.  What happens when a user submits an unusually long article, an article in a foreign language, or a prompt that contains characters the model tries to escape in JSON?  What does the downstream code do when it receives `None` where it expected a dict?*

2.  Grammar-constrained decoding masks out tokens that would violate the grammar.  Consider a schema that requires `"country": {"enum": ["US", "CA", "MX"]}`.  The model is generating a response about a user who is in Germany.  What does the constrained decoder do when it reaches the `country` field, and is the output it produces correct in any meaningful sense?

    *Hint: The decoder cannot output "DE" because it is not in the enum.  It must output one of "US", "CA", or "MX".  How does the decoder choose, and what does that choice mean for the accuracy of the output?  Is a structural guarantee the same as accuracy?*

3.  The model produces output at all three validity levels: syntactic, schema, and semantic.  For a medical triage agent that outputs `{"urgency": "high" | "medium" | "low", "rationale": string}`, which validity level matters most for patient safety, and why are the lower levels (syntactic, schema) necessary but not sufficient?

    *Hint: A schema-valid output like `{"urgency": "low", "rationale": "Patient reports mild discomfort"}` might describe a patient who is actually in critical condition.  Which validity level catches the difference between "correctly formatted" and "actually right"?*

Knowing what each output mode guarantees raises the next question: how should you design the schema itself so that it elicits better model behavior, and not only a valid format?

### Step 2.3: Design the Schema as a Prompt

The schema you write for a structured output is a prompt as well as a type annotation.  The field names, descriptions, and constraints tell the model what you want in the same way natural-language instructions do.  A poorly designed schema produces valid-but-useless outputs; a well-designed schema elicits better reasoning.

> **Do this.**
> 1. Take the task "analyze a news article for potential bias."  Before you read Version B, list what a thoughtful human analyst would record:
>    - What is the article's overall sentiment toward the subject?
>    - What is the apparent political lean, if any?
>    - How strong is the evidence provided?
>    - What perspectives are not represented?
>    - What sources are cited, and are they independently checkable?
>    - How confident are you in your overall assessment?
> 2. Compare Version A and Version B below, field by field.
> 3. Answer Questions 4 through 6 in your writeup.

**Version A, poorly designed schema:**

```json
{
  "sentiment": "string",
  "bias": "string",
  "score": "number",
  "notes": "string"
}
```

Problems with Version A: `bias` is a free-form string, so 10,000 articles might produce 10,000 different bias descriptions, impossible to aggregate.  `score` has no minimum, maximum, or meaning.  `notes` is a catch-all that will absorb anything the model wanted to say but had no proper field for.

**Version B, schema designed to elicit structured reasoning:**

```json
{
  "type": "object",
  "required": ["sentiment", "political_lean", "evidence_quality", "missing_perspectives", "citations", "confidence"],
  "properties": {
    "sentiment": {
      "type": "string",
      "enum": ["strongly_positive", "positive", "neutral", "negative", "strongly_negative"],
      "description": "Overall sentiment of the article toward its primary subject; use the closest enum value"
    },
    "political_lean": {
      "type": "string",
      "enum": ["far_left", "left", "center_left", "center", "center_right", "right", "far_right", "not_applicable"],
      "description": "Apparent political orientation of the article's framing; assess the framing, not the subject matter"
    },
    "evidence_quality": {
      "type": "number",
      "minimum": 0.0,
      "maximum": 1.0,
      "description": "Score from 0.0 (pure assertion with no evidence) to 1.0 (strong primary sources with verifiable claims)"
    },
    "missing_perspectives": {
      "type": "array",
      "items": {"type": "string"},
      "description": "List of viewpoints or stakeholders relevant to the story that are absent from the article; each item is one missing perspective"
    },
    "citations": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["text", "verifiable"],
        "properties": {
          "text": {"type": "string", "description": "The text of the source as it appears in the article"},
          "verifiable": {"type": "boolean", "description": "True if the citation can be independently checked; false if it is vague or unnamed"}
        }
      },
      "description": "Sources cited in the article with a judgment about whether each is checkable"
    },
    "confidence": {
      "type": "number",
      "minimum": 0.0,
      "maximum": 1.0,
      "description": "Model's confidence in the overall bias assessment; use lower values when the article is ambiguous or mixed"
    }
  }
}
```

> **You should see.** For the same article, the two schemas pull different work out of the model:

```text
ARTICLE: "Officials respond to criticism of new highway project."

Version A output:
{"sentiment": "mixed", "bias": "somewhat political", "score": 5.2, "notes": "hard to tell"}
-> Useless for aggregation; "score" has no unit; "somewhat political" cannot be compared across articles

Version B output:
{"sentiment": "neutral", "political_lean": "center_right", "evidence_quality": 0.4,
 "missing_perspectives": ["environmental groups", "local residents displaced by construction"],
 "citations": [{"text": "city council report", "verifiable": false},
               {"text": "state transportation department study", "verifiable": true}],
 "confidence": 0.72}
-> Every field is comparable across articles; missing_perspectives reveals editorial gaps;
  citations are individually assessable; confidence signals where to apply extra scrutiny
```

#### Questions to Work Through

4.  Version A has a `"bias": "string"` field.  Version B replaces it with `"political_lean"` as an enum.  Explain two specific problems that arise when analyzing 10,000 articles using Version A's free-form bias string, and how the enum in Version B solves each problem.

    *Hint: Problem 1 is about aggregation: if one article is labeled "left-leaning" and another "progressive bias" and a third "liberal slant," how do you count how many articles have a left-leaning bias?  Problem 2 is about consistency across time: if the same model labels the same article as "somewhat biased" in January and "moderately biased" in March (because the model updated), how do you detect this inconsistency?*

5.  The `confidence` field asks the model to report its own uncertainty.  Research on chain-of-thought prompting suggests that requiring a model to explain its reasoning improves the quality of its primary answer.  Propose a mechanism by which requiring a `confidence` field might cause the model to reason more carefully about the `political_lean` field that comes before it.

    *Hint: Token generation is sequential: the model generates the `political_lean` value before it generates the `confidence` value.  If the model "knows" it will need to report a confidence score, how might that shape what it pays attention to while choosing the `political_lean` value?  This is a design hypothesis; reason from what you know about sequential generation.*

6.  The `missing_perspectives` field is an array of strings.  It can always be syntactically valid (any list of strings passes) and always be schema-valid (the schema only requires the items to be strings).  But what makes this field particularly hard to validate *semantically*, even when it is perfectly formatted?  What would a realistic post-hoc validation step for this field look like?

    *Hint: To validate that "environmental groups" is a missing perspective for a highway article, you need to know what perspectives actually exist for highway projects and which ones the article addressed.  You cannot determine this from the JSON alone.  What external resource or process would you need?*

Even the best-designed schema cannot guarantee that the model produces valid output every time.  That is why every production system needs a validation pipeline with a repair loop.

### Step 2.4: Validate, Repair, and Fail Loudly

Never trust raw LLM output, even in JSON mode or with a schema.  Always parse and validate before your code uses the data.  When validation fails, you have two options: surface the error to the caller, or attempt a **repair loop**, which re-prompts the model with the specific validation error and asks it to fix only that problem.

> **Do this.**
> 1. Read the repair loop below, comment by comment.  Pay particular attention to the `max_repair_attempts` limit and the "fail loudly" behavior; they prevent the two most dangerous failure modes, infinite API cost and silent bad data flowing downstream.
> 2. Trace the before-and-after run that follows it against the code, line by line.
> 3. Answer Questions 7 through 10 in your writeup.

```python
# Pydantic data model; defines the expected structure and validates incoming data
from pydantic import BaseModel, Field, ValidationError
from typing import Literal
import json

class BiasAnalysis(BaseModel):
    # Literal["a","b","c"] means the value MUST be exactly one of these strings
    sentiment: Literal["strongly_positive", "positive", "neutral", "negative", "strongly_negative"]
    political_lean: Literal["far_left", "left", "center_left", "center",
                            "center_right", "right", "far_right", "not_applicable"]
    # Field(ge=0.0, le=1.0) means: greater-than-or-equal-to 0.0 AND less-than-or-equal-to 1.0
    # Pydantic raises ValidationError if the model outputs 1.5 or -0.1
    evidence_quality: float = Field(ge=0.0, le=1.0)
    missing_perspectives: list[str]    # List of strings; any content is schema-valid
    confidence: float = Field(ge=0.0, le=1.0)

def analyze_article(article_text: str, llm, max_repair_attempts: int = 2) -> BiasAnalysis:
    prompt = build_analysis_prompt(article_text)    # Build the initial prompt

    # Try up to max_repair_attempts + 1 times (first attempt + repairs)
    for attempt in range(max_repair_attempts + 1):
        raw = llm.generate(prompt, response_format=BiasAnalysis)
        # raw is a string containing JSON; we have not validated it yet

        try:
            # model_validate_json parses the JSON AND validates against the schema
            # If both succeed, we return the validated object immediately
            return BiasAnalysis.model_validate_json(raw)

        except ValidationError as e:
            # Validation failed; either JSON is malformed or values violate the schema
            if attempt == max_repair_attempts:
                # We've used all our repair attempts; fail loudly, do not silently return garbage
                raise RuntimeError(
                    f"Schema validation failed after {max_repair_attempts} repair attempts. "
                    f"Last error: {e}"
                ) from e

            # Build a TARGETED repair prompt that gives the model the specific error message
            # "Fix only the specific errors" prevents the model from changing valid fields
            prompt = f"""Your previous response did not conform to the required schema.

Previous response:
{raw}

Validation errors:
{e}

Please output only corrected JSON that fixes these specific errors.
Do not change any values that were already valid."""
            # Loop continues; next iteration will try again with the repair prompt

    raise RuntimeError("Unreachable")    # Should never get here (loop always returns or raises)
```

> **You should see.** When the first response overshoots the allowed range, the loop repairs it in one extra call:

```text
First attempt output (invalid):
{"sentiment": "negative", "political_lean": "center_left",
 "evidence_quality": 1.5,   <- INVALID: exceeds maximum of 1.0
 "missing_perspectives": ["opposition parties"],
 "confidence": 0.8}

ValidationError message Pydantic generates:
1 validation error for BiasAnalysis
evidence_quality
  Input should be less than or equal to 1 [type=less_than_equal, input_value=1.5, ...]

Repair prompt sent to the model:
"Your previous response did not conform to the required schema.
 Previous response: {...}
 Validation errors: evidence_quality: Input should be less than or equal to 1 [input_value=1.5]
 Please output only corrected JSON that fixes these specific errors.
 Do not change any values that were already valid."

Second attempt output (valid):
{"sentiment": "negative", "political_lean": "center_left",
 "evidence_quality": 0.9,   <- Fixed: now within [0.0, 1.0]
 "missing_perspectives": ["opposition parties"],
 "confidence": 0.8}         <- Unchanged: was already valid
```

Key properties of this pipeline:

- **Parse first, use second**: `model_validate_json` raises an exception before any downstream code touches potentially invalid data.
- **Targeted repair**: The repair prompt includes the *specific* validation error with the actual bad value, not only "try again."  This tells the model exactly what to fix.
- **Bounded retries**: The loop has a hard limit.  Without it, an unfixable validation error (like a model that consistently outputs the wrong type) becomes an infinite loop and unbounded API cost.
- **Fail loudly**: When repair is exhausted, the exception propagates to the caller.  Silent failures (returning `None` or default values) hide the problem and let bad data flow downstream.

> **Watch out.** Many students assume that using "JSON mode" or telling the model to "output JSON" in the system prompt provides the same guarantees as grammar-constrained decoding or function calling with a schema.  It does not.  JSON mode is a *suggestion*; the model can and sometimes will ignore it, especially under pressure (long context, unusual inputs, refusals).  The only way to get a mathematical guarantee that the output parses as valid JSON is grammar-constrained decoding at the token level.  The only way to get schema validity without grammar constraints is to validate with a library like Pydantic *after* the model responds, and repair or reject on failure.

#### Questions to Work Through

7.  The repair prompt says "Do not change any values that were already valid."  Why is this specific constraint important?  Describe a concrete scenario where a repair prompt that just said "output the correct JSON" could accidentally make the response worse, not better.

    *Hint: Consider a case where the model correctly identified `political_lean` as "center_right" but had an invalid `evidence_quality` of 1.5.  If the repair prompt just says "output correct JSON," the model might re-evaluate the article from scratch and now classify `political_lean` as "right", changing a valid field while fixing the invalid one.  What does the more constrained repair prompt do differently?*

8.  Pydantic's `Field(ge=0.0, le=1.0)` on `evidence_quality` catches the case where the model outputs `1.5` (a range violation).  But it does not catch the case where the model outputs `0.9` for an article that cites zero sources and makes no verifiable claims; semantically, `0.9` is wildly wrong here, but it is structurally valid.  What layer of the system is responsible for catching semantic errors like this, and what would that layer concretely look like?

    *Hint: One approach is a separate "quality check" LLM call that reads both the original article and the BiasAnalysis output and asks "is this analysis consistent with the article?"  Another approach is statistical: track the distribution of `evidence_quality` scores across thousands of articles and flag outliers.  Which approach is more scalable?*

9.  The function raises `RuntimeError` after exhausting `max_repair_attempts`.  The caller must handle this exception.  Propose a **graceful degradation** strategy for a system that is analyzing news articles and must always return *something* to the user, even if validation fails after all repair attempts.  What should be returned, and what metadata should accompany the degraded response to make its limitations clear to downstream consumers?

    *Starter hint: One option is to return a partially valid response (the fields that passed validation) alongside an explicit `is_degraded: True` flag and a `validation_errors` field listing what failed.  Another option is to return a "manual review required" placeholder.  Which is more useful to a downstream system?  What does a system that relies on this output need to know to handle both cases correctly?*

10. You ask an LLM to output a JSON object with a field `"confidence": float` constrained to values between 0 and 1.  The model outputs `{"confidence": "high"}`.  What is the most likely root cause of this failure?

### Step 2.5: Demonstrate One Technique With a Before and After

This is the required segment.  The point is evidence: a real parse failure on a real response, and the same request made reliable by one of the three techniques.

> **Do this.**
> 1. Pick one technique from the box at the top of Part 2: Ollama's `format` parameter, Instructor, or Outlines.
> 2. **Before.** Send a prompt to your model that asks for JSON but does not constrain it (plain JSON mode, as in Step 2.2), then hand the raw response to `json.loads`.  Keep trying prompts until a real response breaks the parse; the model adding a sentence of prose before the object is the usual way it happens.  Save the response and the error.
> 3. **After.** Send the same prompt through your chosen technique and parse the result the same way.  Run it several times; it should parse every time.
> 4. Write the two-or-three-sentence note for your writeup: what broke, what fixed it, and which of the three techniques guarantees validity versus merely encourages it.

> **You should see.** In the before, a traceback ending in a line like the one below, because `json.loads` hit prose where it expected an opening brace.  In the after, a Python dict printed with the fields you asked for, on every run.

```text
json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)
```

> **If it fails.**
> - The before never breaks: your prompts are too easy.  Try a longer input, an ambiguous question, or a request the model is inclined to explain first.  Do not fake the failure; the broken parse is the evidence.
> - The after still breaks with Ollama's `format`: confirm you passed the schema in the request's `format` field, not as prose in the prompt.
> - Instructor or Outlines will not install or will not reach your model: switch to Ollama's `format` parameter, which needs nothing beyond `requests`, and note the switch in your writeup.

> **No-code path.** The technique still has to be one of the three.  Capture the before as an exported chat whose reply is prose around JSON.  For the after, the constraint has to actually be applied, which on this route means either a technique your interface supports or a single request sent by hand to Ollama's `/api/chat` with the `format` parameter set; say which you used, show the reply that is only the JSON object, and write the same note.

---

## Part 3: Reasoning, Measured (25 points)

Make the agent reason explicitly, and then find out whether the reasoning was worth what it cost.  Both options below run a plain condition and a reasoning condition over the same fixed set of at least eight tasks at a fixed seed, so that any difference you see comes from the reasoning and not from the dice.  Pick at least one.

### Option 3A: From Scratch, Make the Agent Think and Measure It

Add explicit reasoning to your agent and test whether it helps.  Either (a) insert a scratchpad or chain-of-thought step where the model reasons before it answers, or (b) spend **test-time compute**: sample several reasoning paths at nonzero temperature and select the best (majority vote or a self-check).  Run both the plain and the reasoning version over a fixed set of at least eight tasks at a fixed seed, and report the accuracy delta *and* the extra tokens and latency it cost.  Concepts are in the [model-types lecture]({{ site.baseurl }}/Tutorials/ModelTypes).

> **Paste into your submission.** Both versions, the paired results table, and a sentence on when the extra reasoning earned its cost.

### Option 3B: From a Model Perspective, Use a Reasoning Model

Drive reasoning by *choosing the model* rather than building the loop.  Run a reasoning-capable model (or toggle a "think step by step" or extended-thinking mode where your server supports it) and compare it against a direct-answer model on the same eight-task set.  Report accuracy, latency, and token cost for each, and identify a task type where the reasoning model clearly wins and one where it is wasteful.  See the [model-types lecture]({{ site.baseurl }}/Tutorials/ModelTypes) for what makes a model a "reasoning" model.

> **Paste into your submission.** The comparison table and a short recommendation on which model you would ship for this workload and why.

> **Checkpoint.** Before you run anything, confirm your task set will show a difference.  Pick tasks that need at least two steps; a ceiling at 8/8 in both conditions measures your task set, not the model.  Then start the runs and use the waiting time for Part 4.

> **No-code path.** Run the comparison in the chat interface: a plain model against a reasoning-prompted one (Option 3A) or against a reasoning model (Option 3B), across the same eight fixed tasks.  In Langflow, build the two conditions as two flows.  Wall-clock time and response length are acceptable stand-ins for latency and token counts, provided you state how you measured them.

---

## Part 4: MCP (20 points)

MCP standardizes how a client discovers what tools a server offers and how it calls them, so a tool written once can be used by any MCP-aware client.  Every option below ends in the same evidence: a transcript showing discovery followed by invocation.  Pick at least one.

### Option 4A: Create, Stand Up Your Own MCP Server

Expose your tool(s) over MCP so *any* MCP-aware client can discover and call them, not only your own loop.  Build a small MCP server (for example with the Python MCP SDK / FastMCP) that advertises one or two tools, then connect a client and show the discover -> invoke round trip.  If you take the [MCP Server with OAuth 2.0 direction]({{ site.baseurl }}/Assignments/LocalAgent#direction-4-build-an-mcp-server-with-oauth-20), that fully satisfies this option.  Background: the [MCP activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-mcp.md) and the free [Hugging Face MCP Course](https://huggingface.co/learn/mcp-course/) (built with Anthropic), whose early units walk through building and connecting an MCP server step by step.

> **Paste into your submission.** The server code, a transcript of a client listing the tools and calling one, and one sentence on what MCP standardizes that a hand-rolled `tools` list does not.

### Option 4B: Use, Connect Your Agent to an Existing MCP Server

Consume MCP instead of authoring it.  Point your agent (or a framework client) at an existing MCP server (for example a filesystem, fetch, or SQLite server) and let it discover the server's tools and call them to complete a task.  Background: the [MCP activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-mcp.md).

> **Paste into your submission.** The connection or config, a transcript showing tool discovery and at least one successful invocation, and one sentence on the trust question this raises (you are now running someone else's tool definitions).

### Option 4C: Obsidian Vault, Put Your Notes Behind MCP With a Gated Write

Expose an Obsidian vault (a folder of Markdown notes) to an agent over MCP, with the write path gated so nothing lands in a note without your confirmation.  This option earns the same credit on the MCP rubric row as Create or Use, on whichever route you take.

> **Code path.** Write a small FastMCP or plain-HTTP server over a vault folder that exposes three operations: search (find notes matching a query), read (return one note), and a gated append (add text to a note only after a confirmation step).  The Model 3 vault server in the [MCP: Connecting Agents to Tools and Your Obsidian Vault deck](https://www.billmongan.com/LiaScript/?https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/_pages/Activities/liascript-mcp.md) is the starting point; point it at your own vault folder and connect a client.

> **No-code path.** Configure rather than write.  Either add a community Obsidian MCP server of your choice, cited in your readme, to your client's tool settings over your vault folder, or set up an Open WebUI tool over the vault folder.  The gate still has to exist: the write must not go through until you confirm it.

> **Paste into your submission.** On either route: the server code or the configuration, a transcript that shows tool discovery, one read of a note, and one gated write that was refused first and then carried out once you confirmed it, and one sentence on what MCP standardizes that a hand-rolled `tools` list does not.  If you used a community server, also name the trust question that running someone else's tool definitions raises.

> **No-code path.** For Options 4A and 4B without code: add an MCP server to Open WebUI's tool settings, or configure one in a client's config file (the Langflow low-code variant), and export the chat showing discovery and then invocation.  Consuming a server through a client's configuration file earns the MCP row on the same terms as consuming it from code.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| The model describes a tool call in prose instead of emitting one | The model does not support native function calling, or the tools were passed in the prompt rather than in the `tools` field | Confirm your model supports tool calling; pass tools in the request's `tools` parameter, not as prose in the system prompt |
| The model calls the tool, then ignores the result | The result was never fed back as a `tool`-role message, so the model never saw it | Append the execution result to the message list with `"role": "tool"` and call again. The round trip is the whole mechanism |
| The tool fires on every question, including ones it should not | The tool description is too broad. The model chooses from the description alone | Rewrite the description to say when *not* to use it. Record the before and after; it is a good finding |
| The tool never fires, even on questions that need it | Description too narrow or too abstract, or the parameter schema is missing required fields | Compare your schema against a working one field by field. `required` is the usual omission |
| `json.loads` fails on the model's output | This is the failure the structured-output requirement exists to catch | Capture it. That broken parse *is* your "before"; do not fix it silently |
| MCP client reports zero tools | The server process is not running, the command path in the client config is wrong, or the transport does not match | Run the server by hand first and confirm it responds. Most MCP misconfiguration is a wrong path in a config file |
| The reasoning comparison shows no difference | Your eight tasks are too easy; both conditions get them all right | Pick tasks that need at least two steps. A ceiling at 8/8 measures your task set, not the model |
| Runs take forever | Eight tasks times two conditions times retries | Start it early, run it in the background, and use the waiting time for the MCP part |

---

## Deliverables

| File or artifact | What it shows | Rubric row |
|------------------|---------------|------------|
| Tool schema, round-trip transcript (or exported chat / Langflow run), and the boundary sentence; for Option 1B, the registration, run transcript, and the two things the framework hid | A typed tool invoked end to end and a precise statement of what your code owns | Tool Use (30) |
| No-code tool-use evidence: screenshots of the flow or tool configuration and the three-question table with *tool fired: yes/no* | When the model chose the tool, and what it did when the tool was gone | Tool Use (30) |
| Structured-output note: the before (broken parse on a real response), the after (constrained output parses), and the guarantee-versus-encourage sentence | One technique demonstrated on a real failure | Structured Output (20) |
| Both runners (or both flows / model configurations) and the paired results table over at least eight fixed tasks at a fixed seed, with accuracy, tokens, and latency (or stated stand-ins), plus the sentence on when the cost was earned | Whether reasoning paid for itself | Reasoning, Measured (25) |
| Server code or client configuration, and the discovery-then-invocation transcript (for the vault: discovery, one read, one gated write refused then confirmed), with the standardization sentence and, where applicable, the trust question | A working MCP round trip and an understanding of what the protocol buys | MCP (20) |
| Writeup with the route named at the top, model, parameters, and commands recorded, answers to the Questions to Work Through and Critical Thinking Questions, and an AI-use disclosure | A reader can reproduce your runs | Writeup and Reproducibility (5) |

---

## Self-Check Before You Submit

- [ ] **Tool use:** a transcript showing the request, the execution, and the result fed *back* to the model.
- [ ] The writeup names precisely what your code is responsible for that the model is not.
- [ ] **Structured output:** a real before (naive parse breaks on an actual response) and after (constrained output parses), plus one sentence on which techniques guarantee validity versus merely encourage it.
- [ ] **Reasoning:** at least eight fixed tasks, at a fixed seed, run in both conditions, with an accuracy delta.
- [ ] Cost reported alongside accuracy: tokens and latency, or a stated stand-in.
- [ ] One defensible sentence on when the reasoning cost was earned and when it was not.
- [ ] **MCP:** a transcript showing discovery followed by invocation (for the Obsidian vault option: discovery, one read, and one gated write refused and then confirmed).
- [ ] The writeup says what MCP standardizes that a hand-rolled tools list does not; if you consumed someone else's server, including a community vault server, it names the trust question that raises.
- [ ] Model name and parameters recorded so a reader can reproduce your runs.
- [ ] Route named at the top of the writeup.
- [ ] AI-use disclosure included.

---

## What to Submit

One repository or archive containing your code, plus a writeup that includes, for each of the three capabilities, the deliverable that capability asks for.  Record the model and parameters you used so a reader can reproduce your runs, and include an AI-use disclosure naming what was AI-assisted and how you verified it.
