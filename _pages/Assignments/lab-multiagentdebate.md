---
layout: assignment
permalink: /Assignments/MultiAgentDebate
title: "CS357: Foundations of Artificial Intelligence - Lab: Multi-Agent Patterns"

info:
  coursenum: CS357
  purpose: "To orchestrate multiple agents through the four patterns that make agent systems more reliable than a single call (critique, refine, debate, and consensus), and to learn from your own measurements when aggregation improves answers and when correlated errors defeat it."
  tilt:
    task: "Implement a generator/critic/refine loop, then multi-agent debate and embedding-clustered consensus, and compare all of them against a single-shot baseline at matched call budgets."
    criteria: "I grade this on the debate loop, the consensus pipeline, and a matched-budget comparison that surfaces a correlated failure.  The rubric below breaks it down in full."
  points: 100
  goals:
    - To implement multi-agent debate with independent first rounds and peer-informed revision rounds using configurable agents, rounds, and temperature schedules
    - To implement stochastic consensus with normalized-embedding clustering and a synthesis agent that receives cluster summaries
    - To compare debate, consensus, and single-shot baselines at matched call budgets on a labeled task set
    - To identify and explain correlated failure modes that aggregation cannot repair and propose a non-LLM remedy
  rubric:
    - weight: 20
      description: "Part A: Critique and Refine Loop"
      preemerging: "No generator/critic/refine loop, or the critic does not influence the next generation."
      beginning: "A loop exists but runs a fixed number of rounds with no stopping rule, so it cannot tell improvement from churn."
      progressing: "The loop runs generator, critic, and refiner with a stated stopping rule, and a transcript shows an output changing in response to a critique."
      proficient: "As progressing, and the writeup shows a case where the critic was wrong and says how you could tell, plus what the loop cost in extra calls for the quality it bought."
    - weight: 25
      description: Debate Implementation
      preemerging: The debate fails to run due to major issues, or the program fails to run
      beginning: The debate runs but fails on test questions due to one or more minor issues
      progressing: The debate runs correctly with configurable agents and rounds and majority vote aggregation, with a fragile component such as answer extraction
      proficient: "The debate runs correctly with configurable agents, rounds, and temperature schedule; answer extraction anchors on a required ANSWER: line and handles its absence with a located error message; both majority-vote and judge-agent aggregation are available; a transcript of at least one complete 3-agent, 2-round debate is included in the submission"
    - weight: 20
      description: Consensus Implementation
      preemerging: The consensus pipeline fails to run due to major issues
      beginning: Drafts are sampled but clustering or synthesis is missing or incorrect
      progressing: The pipeline samples, clusters by embedding similarity with normalized vectors, and synthesizes from cluster representatives, with a minor issue
      proficient: The pipeline samples k high-temperature drafts, clusters with cosine distance over normalized embeddings and a justified threshold, synthesizes using one representative per cluster with its support count, discloses close disagreements in one line, and the synthesizer receives cluster summaries rather than all k transcripts; a demonstration on a long-form question is included
    - weight: 20
      description: Comparative Evaluation
      preemerging: No evaluation is provided
      beginning: Conditions are compared anecdotally without matched budgets or a protocol
      progressing: Debate, consensus, and single shot baselines are compared on a labeled task set with accuracy and call counts reported
      proficient: All conditions are compared at matched call budgets on a labeled task set of at least ten items; accuracy and model-call count are reported per condition in a table; at least one correlated failure is documented with all agents' verbatim responses showing agreement on the wrong answer; the writeup explains specifically why no aggregation strategy could have repaired it and names one non-LLM addition that would
    - weight: 10
      description: Code Quality and Documentation
      preemerging: Code commenting and structure are absent, or code structure departs significantly from best practice
      beginning: Code commenting and structure is limited in ways that reduce the readability of the program
      progressing: Code documentation is present that re-states the explicit code definitions
      proficient: Every non-trivial function has a docstring; all model calls and embedding operations are wrapped in exception handlers that print a located message (e.g., [lab4:debate_round]) followed by a traceback; number of agents, rounds, temperature schedule, and distance threshold are read from a JSON config file rather than hardcoded
    - weight: 5
      description: Writeup, Reflection, and Submission
      preemerging: An incomplete submission is provided
      beginning: The program is submitted, but not according to the directions in one or more ways
      progressing: The program is submitted according to the directions with a minor omission, with at least superficial responses to the reflection prompts
      proficient: The program is submitted according to the directions, including a readme writeup, a pair log with at least two timestamped role swaps, and reflection answers that each cite a specific accuracy figure, transcript excerpt, or named failure mode from the lab rather than restating the prompt
  readings:
    - rtitle: "Critique, Consensus, and the LLM Judge: One Loop, Three Uses"
      rlink: "Activities/liascript-critiqueconsensusjudge.md"
      liapage: true
    - rtitle: "Agents That Talk: Multi-Agent Communication Through GitHub and Dropbox, and Threat Modeling (the claim protocol behind the optional handoff route in Part B.3)"
      rlink: "Activities/liascript-agentcommunication.md"
      liapage: true
    - rtitle: "Orchestration Activity"
      rlink: "Activities/liascript-orchestration.md"
      liapage: true
    - rtitle: "The Local Agent Stack"
      rlink: "../Tutorials/AgentStack"

tags:
  - multi-agent
  - agents
  - evaluation

---

You and your partner will build the patterns that make an agent system more reliable than a single model call, then measure whether the extra calls bought anything.  The lab has two halves and one grade.  In **Part A** you build a generator/critic/refine loop: a **generator** writes a draft, a **critic** checks it against a written rubric and returns "accept" or "revise" with a list of issues, and the **refine loop** feeds those issues back until the critic accepts or the round budget runs out.  You then calibrate that critic on defects you planted, break your own rubric on purpose, and measure what the loop cost against single-shot generation.  In **Part B** you build the two aggregation architectures from class: **debate**, where agents see and rebut each other, and **stochastic consensus**, where independent samples are clustered by meaning and merged by a synthesizer.  Do Part A first.  The debate work reuses its scaffolding, and a critic you already trust is what makes a debate round worth reading.  You leave with a loop you can read, a working debate, a working sample-cluster-synthesize pipeline, and a measurement of your own that says when aggregation helps and when correlated errors defeat it.

Work in pairs with driver/navigator roles, swap at least every 30 minutes, and keep a swap log.  This lab is handed out alongside the deck *Critique, Consensus, and the LLM Judge: One Loop, Three Uses*.  See the course schedule for the assigned and due dates.

---

## Choose Your Path

Every pattern in this lab is a *protocol*, and you can run each protocol by hand or on a canvas rather than in Python.  The calibration and reward-hack work in Part A is prompt-and-analysis work on every route.  Decide before you start rather than after the first part.

| Route | What you build | What you need | Pick this if |
|-------|----------------|---------------|--------------|
| **Code** | `critique_refine.py` with `rubric.json` and the calibration, hack, and comparison scripts (Part A); then `lab4.py`, `shootout.py`, and `threshold.py` for the debate loop, the embedding-clustered consensus pipeline, and the matched-budget shootout (Part B), all driven by one `config.json` | Python 3, Ollama running `llama3.2`, and the packages installed below | You want the stopping rule, the fail-closed parser, the threshold, and the call budget in code you can re-run and hand in as a log, and you can read a stack trace |
| **No-code** | Part A as three saved Open WebUI presets (generator, critic, reviser) with text moved by hand, or a Langflow (low-code) canvas chaining them as three prompt nodes.  Part B as two Open WebUI chats that rebut each other, a spreadsheet of answers you cluster yourself, and the same comparison table; in Langflow the debate is two Agent nodes and a loop | Open WebUI or Langflow pointed at your local Ollama, and a spreadsheet | You would rather see the seams (where the critic's words become the reviser's instructions, and where your own clustering judgment replaces a distance threshold) than write the orchestration |

The rubric is the same on both paths.  The judgment this lab grades (when the critic was wrong, whether the extra rounds bought anything, and why a correlated failure could not be repaired by aggregation) is identical on every route.  On the no-code path, read "code" in the rubric as "flow or preset configuration" and "log" as "transcript".  Part B.3 also has an optional handoff route, open to both paths, in which two agents exchange positions through a GitHub issue thread or a shared folder.

---

## Before You Start

> **Checkpoint.** This lab has two halves and one grade.  Critique-and-refine and debate-and-consensus used to be two separate 100-point labs due eight days apart.  They are one family of idea (use more than one model call to get a better answer), so they are now one lab, one page, and one rubric.
> - **Part A: Critique and Refine.**  Build the generator/critic/refine loop, calibrate the critic, break and patch the rubric, and measure the loop against single-shot generation.
> - **Part B: Debate and Consensus.**  Build the debate, the consensus pipeline, the shootout, and the threshold sweep.
>
> You submit both halves together, once, against the single rubric above.  There is no separate Critique-and-Refine deadline.

Complete these activities before you write any code:

- [Critique, Consensus, and the LLM Judge]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-critiqueconsensusjudge.md): the generator/critic/refine loop and stopping rules; independent rounds, peer-informed revision, and majority vote (Sections 5 and 6); then sampling, embedding clustering, and synthesis (Section 7)
- [Orchestration Activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-orchestration.md): chaining agents with structured outputs
- [Agents That Talk]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-agentcommunication.md): the claim protocol, needed only if you take the optional handoff route in Part B.3

Install the Python packages.  `pip install` downloads a package and makes it importable: `requests` is how your code talks to Ollama over HTTP, and the other three do the embedding and clustering in Part B.2.  `curl` sends a web request and prints the reply, so the last line asks your local Ollama server to list its models; a JSON list means Ollama is up.

```bash
# Requests for Ollama calls (Parts A and B)
pip install requests

# Sentence transformers for embedding clustering (Part B.2)
pip install sentence-transformers scikit-learn numpy

# Verify Ollama is running
curl http://localhost:11434/api/tags
```

Then run this health check.  It sends one chat request to `llama3.2` and prints the reply, so you know the model answers and can produce the small piece of JSON the critic will need.  It then embeds three sentences, normalizes the vectors, and prints how similar the first two are.  The first run downloads the embedding model, so give it a minute.

```bash
python -c "
import requests, json
r = requests.post('http://localhost:11434/api/chat', json={
    'model': 'llama3.2',
    'messages': [{'role': 'user', 'content': 'Reply with exactly: {\"verdict\": \"accept\", \"issues\": []}'}],
    'stream': False
})
print(r.json()['message']['content'])
from sentence_transformers import SentenceTransformer
import numpy as np
model = SentenceTransformer('all-MiniLM-L6-v2')
vecs = model.encode(['hello world', 'hi there', 'the sky is blue'])
# Normalize
norms = np.linalg.norm(vecs, axis=1, keepdims=True)
normed = vecs / norms
print('Embedding shape:', vecs.shape)
print('Cosine similarity (should be ~0.7 for similar sentences):')
print(normed[0] @ normed[1])
"
```

> **You should see.** The JSON line (the model may add extra text around it; what matters is that the JSON is present), then a shape of `(3, 384)` (three sentences, 384 numbers each) and a similarity near 0.7.  If you see a connection error, start Ollama with `ollama serve` in a separate terminal.  If an import fails, `pip install` landed in a different Python than the one you ran.

```text
{"verdict": "accept", "issues": []}
Embedding shape: (3, 384)
Cosine similarity (should be ~0.7 for similar sentences):
0.6843...
```

> **Time budget.** About 7 to 10 hours in total.  This is not a single-sitting lab, so plan more than one pair session.
> - Part A: build the loop (A.1 to A.4) 60-90 min; calibrate the critic (A.5 to A.6) 45-60 min; reward hack the rubric (A.7 to A.8) 30-45 min; compare with single-shot (A.9 to A.10) 45-60 min
> - Part B: B.1 Debate 60-90 min; B.2 Consensus 60-75 min; B.3 The Shootout 60-75 min; B.4 Threshold Sensitivity 30-45 min
> - Readme and reflection for both halves: 45-60 min

---

## Part A: Critique and Refine (20 points)

Choose a generation task with checkable criteria: a structured class announcement, a function docstring, an abstract for a lab report, or a task of your own.  The examples below use the docstring task.  You build three pieces:

1. A generator agent.  Temperature controls how much randomness the model uses when it picks each word; a higher value gives more varied drafts and a lower value gives more predictable ones.  Use a warm temperature for the first draft and a cooler temperature for revisions, and justify your settings using the sampling theory from class.
2. A critic agent.  It receives a JSON rubric of at least four criteria with observable descriptors (a descriptor is observable when a reader can check it by looking at the draft, without guessing at intent), and it returns `{"verdict": "accept" | "revise", "issues": [...]}`.  The critic runs at temperature 0 with a fixed seed, so the same draft gets the same verdict on every run.
3. A loop with a configurable round budget, stored in the JSON configuration file rather than in the code.  Invalid critic JSON fails closed: the loop treats it as "revise" and logs it.  On budget exhaustion, your loop returns the final draft with its outstanding critique attached.

The Part A rubric row rewards four things: a loop whose critic changes the next draft and that stops for a stated reason; a transcript showing that change; a case where the critic was wrong and how you could tell; and what the loop cost in extra calls for the quality it bought.  Steps A.1 through A.4 build the loop, A.5 and A.6 calibrate the critic (which is where you catch it being wrong), A.7 and A.8 break and repair the rubric, and A.9 and A.10 measure the cost.

> **No-code path.** In Langflow, chain Generator, Critic, and Reviser as three prompt nodes, feeding the critic's output back into the reviser.  In Open WebUI, save three model presets (one per role, with the rubric in the critic's system prompt) and pass the text between them by hand.  This is slower, but the loop is identical and the seams are more visible.  Enforce the round budget yourself and write down every verdict, including any reply that is not valid JSON, so your transcript shows the same stopping paths the code path logs.

### Step A.1: Create the configuration and rubric files

`config.json` holds every setting both halves of the lab read, so you can change a temperature, the round budget, or the number of debate agents without editing code.  The top-level keys belong to Part A; the `debate` and `consensus` blocks belong to Part B, and the loop ignores them.  `rubric.json` lists the criteria the critic checks.

> **Do this.**
> 1. Make a folder for this lab (for example `cs357-multiagent`) and open a terminal there.
> 2. Create `config.json` and paste the settings below.
> 3. Create `rubric.json` and paste the criteria below.  This example is for a function docstring task; adapt it to your chosen task.

```json
{
  "model": "llama3.2",
  "ollama_url": "http://localhost:11434/api/chat",
  "generator_temp_first": 0.8,
  "generator_temp_revise": 0.3,
  "critic_temp": 0.0,
  "critic_seed": 42,
  "round_budget": 5,
  "rubric_file": "rubric.json",
  "debate": {
    "num_agents": 3,
    "num_rounds": 2,
    "temperature_schedule": [0.7, 0.4],
    "seed_base": 100
  },
  "consensus": {
    "num_samples": 6,
    "sample_temperature": 0.8,
    "synthesizer_temperature": 0.1,
    "distance_threshold": 0.3,
    "embed_model": "all-MiniLM-L6-v2"
  }
}
```

```json
{
  "task": "function_docstring",
  "criteria": [
    {
      "id": "C1",
      "name": "Purpose",
      "descriptor": "The docstring contains a one-sentence summary of what the function does, not how it does it."
    },
    {
      "id": "C2",
      "name": "Parameters",
      "descriptor": "Every parameter is listed with its name, type, and a brief description."
    },
    {
      "id": "C3",
      "name": "Return value",
      "descriptor": "The return value's type and meaning are explicitly described. If the function returns None, this is stated."
    },
    {
      "id": "C4",
      "name": "Example",
      "descriptor": "At least one usage example is provided in a doctest-compatible format (>>> function_call())."
    }
  ],
  "accept_threshold": "All four criteria must be met for a verdict of 'accept'."
}
```

> **You should see.** `python3 -m json.tool config.json` prints the file back, reformatted, with no error; the same command on `rubric.json` does the same.  An error means a missing comma or quote.

### Step A.2: Implement the generator agent

`generate_draft` builds one of two prompts.  With no previous draft it asks for a first draft at the warm temperature.  With a previous draft and a critique it asks for a revision at the cooler temperature.  The `[lab3:generate_draft]` tag in the exception handler is the located error message the Code Quality row asks for: it names the function that failed, and the traceback says why.

> **Do this.**
> 1. Create `critique_refine.py` in the lab folder.
> 2. Paste the imports, the two loader functions, and `generate_draft` below.  `python3 critique_refine.py` exits silently at this point, which tells you the file parses.

```python
import requests
import json
import traceback

def load_config(path="config.json"):
    with open(path) as f:
        return json.load(f)

def load_rubric(config):
    with open(config["rubric_file"]) as f:
        return json.load(f)

def generate_draft(task_description, previous_draft=None, critique=None, config=None):
    """
    Generate a draft for the given task.
    If previous_draft and critique are provided, this is a revision call.
    """
    temperature = config["generator_temp_first"] if previous_draft is None else config["generator_temp_revise"]

    if previous_draft is None:
        user_message = f"Generate a draft for the following task:\n\n{task_description}"
    else:
        user_message = (
            f"Here is the task:\n\n{task_description}\n\n"
            f"Here is your previous draft:\n\n{previous_draft}\n\n"
            f"Here is the critique you must address:\n\n{json.dumps(critique, indent=2)}\n\n"
            f"Please revise the draft to address every issue listed. Return only the revised draft, no commentary."
        )

    messages = [{"role": "user", "content": user_message}]
    payload = {
        "model": config["model"],
        "messages": messages,
        "stream": False,
        "options": {"temperature": temperature}
    }

    try:
        response = requests.post(config["ollama_url"], json=payload, timeout=60)
        response.raise_for_status()
        return response.json()["message"]["content"]
    except Exception as e:
        print(f"[lab3:generate_draft] {e}")
        traceback.print_exc()
        raise
```

### Step A.3: Implement the critic agent

`critique_draft` turns the rubric into a system prompt, sends the draft, and parses the reply as JSON.  If the reply does not parse, the function returns a "revise" verdict and logs the raw text.  That is the fail-closed rule: a network failure re-raises after a located message, but a parse failure logs the raw text and returns "revise", so the loop never accepts something it could not read.

> **Do this.** Append `critique_draft` below to `critique_refine.py`.

```python
def critique_draft(draft, rubric, config):
    """
    Ask the critic to evaluate the draft against the rubric.
    Returns a dict: {"verdict": "accept"|"revise", "issues": [...]}
    On JSON parse failure, returns {"verdict": "revise", "issues": ["[JSON parse failure - treating as revise]"]}
    """
    criteria_text = "\n".join(
        f"- {c['id']} ({c['name']}): {c['descriptor']}"
        for c in rubric["criteria"]
    )

    system_prompt = (
        "You are a strict quality critic. Evaluate the draft against every criterion below. "
        "Return ONLY valid JSON in this exact format, with no additional text:\n"
        '{"verdict": "accept" or "revise", "issues": ["issue 1", "issue 2", ...]}\n\n'
        "Use 'accept' only if ALL criteria are fully met. "
        "Use 'revise' if ANY criterion is not met. "
        "List every unmet criterion as a separate issue string.\n\n"
        f"CRITERIA:\n{criteria_text}\n\n"
        f"ACCEPT THRESHOLD: {rubric['accept_threshold']}"
    )

    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": f"DRAFT TO EVALUATE:\n\n{draft}"}
    ]

    payload = {
        "model": config["model"],
        "messages": messages,
        "stream": False,
        "options": {"temperature": config["critic_temp"], "seed": config["critic_seed"]}
    }

    try:
        response = requests.post(config["ollama_url"], json=payload, timeout=60)
        response.raise_for_status()
        raw = response.json()["message"]["content"]
    except Exception as e:
        print(f"[lab3:critique_draft:network] {e}")
        traceback.print_exc()
        raise

    # Try to parse JSON; fail closed on malformed output
    try:
        # Strip markdown code fences if present
        clean = raw.strip().lstrip("```json").lstrip("```").rstrip("```").strip()
        critique = json.loads(clean)
        assert "verdict" in critique and "issues" in critique
        return critique
    except Exception as e:
        print(f"[lab3:critique_draft:json_parse] Malformed critic output - failing closed. Raw: {raw!r}")
        return {"verdict": "revise", "issues": [f"[JSON parse failure] Raw output: {raw[:200]}"]}
```

### Step A.4: Implement the loop and run a smoke test

Each round generates a draft and critiques it.  An "accept" verdict returns immediately.  If the loop uses up its budget, it returns the last draft with the outstanding critique appended, so the caller knows the loop did not converge.  The generator and the critic are separate model calls with separate temperatures, and the loop is the only piece that decides when to stop, so every stopping path (accept, fail-closed revise, budget exhausted) must leave a trace in the log.

> **Do this.**
> 1. Append `critique_refine_loop` below to `critique_refine.py`.  Step A.9 reads the `rounds_used` value it returns to count calls.
> 2. Append the `__main__` block after it.  The `__main__` guard means the smoke test runs only when you run this file directly, not when the later scripts import it.
> 3. Run it from the lab folder and save the full terminal output; the Part A row asks for a transcript showing an output changing in response to a critique, so you need at least two complete cycles.
>
> ```bash
> python3 critique_refine.py
> ```

```python
def critique_refine_loop(task_description, config, rubric):
    """
    Run the generate/critique/refine loop.
    Returns (final_draft, final_critique, rounds_used, termination_reason).
    """
    draft = None
    critique = None

    for round_num in range(1, config["round_budget"] + 1):
        print(f"\n=== Round {round_num} ===")

        # Generate
        draft = generate_draft(task_description, previous_draft=draft, critique=critique, config=config)
        print(f"[Generator] Draft (first 200 chars): {draft[:200]}...")

        # Critique
        critique = critique_draft(draft, rubric, config)
        print(f"[Critic] Verdict: {critique['verdict']}")
        if critique["issues"]:
            print(f"[Critic] Issues: {critique['issues']}")

        if critique["verdict"] == "accept":
            return (draft, critique, round_num, "accepted")

    # Budget exhausted - return last draft with critique attached
    final_output = f"{draft}\n\n--- OUTSTANDING CRITIQUE (budget exhausted after {config['round_budget']} rounds) ---\n{json.dumps(critique, indent=2)}"
    return (final_output, critique, config["round_budget"], "budget_exhausted")

if __name__ == "__main__":
    config = load_config()
    rubric = load_rubric(config)
    task = "Write a Python docstring for a function called `merge_sorted_lists` that takes two sorted lists of integers and returns a single sorted list."
    draft, critique, rounds, reason = critique_refine_loop(task, config, rubric)
    print(f"\n=== FINAL OUTPUT ===\nRounds: {rounds} | Reason: {reason}")
    print(draft)
```

> **You should see.** A round banner, a draft preview, and a verdict line per round, then either an `accepted` return or an `OUTSTANDING CRITIQUE` block.  Abbreviated; your drafts and round count will differ.

```text
=== Round 1 ===
[Generator] Draft (first 200 chars): """Merge two sorted lists.
...
[Critic] Verdict: revise
[Critic] Issues: ['C4 (Example): No usage example in doctest format is provided.']

=== Round 2 ===
[Generator] Draft (first 200 chars): """Merge two sorted lists of integers into one sorted list.
...
[Critic] Verdict: accept
[Critic] Issues: []

=== FINAL OUTPUT ===
Rounds: 2 | Reason: accepted
```

> **Checkpoint.** Before moving to Step A.5, make sure you can answer:
> 1. Why does the critic run at temperature 0 while the generator runs at a higher temperature?  What property does each temperature setting encourage?
> 2. What does "fail closed" mean in the context of JSON parsing?  Why is fail-closed safer than ignoring the parse error?
> 3. On budget exhaustion, your loop attaches the outstanding critique to the returned draft.  Why is this useful to the caller?

### Step A.5: Write calibration drafts and run the critic over them

Calibration means measuring how well the critic's verdicts track the truth.  You do that with drafts whose defects you planted yourself, so you know the right answer for each one.  Two numbers describe the critic per criterion.  The **detection rate** is the fraction of drafts with a planted defect in that criterion that the critic flagged.  The **false positive rate** is the fraction of defect-free drafts that the critic flagged for that criterion anyway.  Defect-free drafts are what let you see false positives at all, so the set needs some.

> **No-code path.** Calibration is prompt work and analysis, not code.  Run each calibration draft through your critic preset or Critic node, record the verdict beside the defect you planted, and compute the two rates per criterion in a spreadsheet using the four counts Step A.6 describes.

> **Do this.**
> 1. Create `calibration_drafts.json` in your lab folder and start from the three entries below.  Each entry records the draft, the defect you planted, and a short description, so Step A.6 can score the critic against the truth.
> 2. Add D04 through D12: at least one defect per criterion, several multi-defect drafts, and at least two defect-free drafts in total.  Make some defects subtle (a parameter description that lists the name but not the type, or an example that shows a call but not the return value); obvious defects tell you nothing about the critic.  You do not have to hand-escape every entry: write the draft as a normal triple-quoted Python string, build the entry as a dict, and print `json.dumps(entry, indent=2)` to get the escaped version to paste in.
> 3. Check the file with `python3 -m json.tool calibration_drafts.json`.  An error at a line number usually means the `// TODO` comment or an unescaped quote.

```json
[
  {
    "id": "D01",
    "defect": "missing_C4",
    "description": "No example provided",
    "draft": "\"\"\"Merge two sorted lists of integers.\n\nArgs:\n    a (list[int]): First list.\n    b (list[int]): Second list.\n\nReturns:\n    list[int]: Merged sorted list.\n\"\"\""
  },
  {
    "id": "D02",
    "defect": "missing_C2_and_C3",
    "description": "No parameter or return descriptions",
    "draft": "\"\"\"Merge two sorted lists.\n\nExample:\n    >>> merge_sorted_lists([1, 3], [2, 4])\n    [1, 2, 3, 4]\n\"\"\""
  },
  {
    "id": "D03",
    "defect": "none",
    "description": "Defect-free draft",
    "draft": "\"\"\"Merge two sorted lists of integers into a single sorted list.\n\nArgs:\n    a (list[int]): First sorted list of integers.\n    b (list[int]): Second sorted list of integers.\n\nReturns:\n    list[int]: A new sorted list containing all elements from a and b.\n\nExample:\n    >>> merge_sorted_lists([1, 3], [2, 4])\n    [1, 2, 3, 4]\n\"\"\""
  }
  // TODO: Add D04 through D12 - at least one defect per criterion, multiple multi-defect drafts
]
```

> **Watch out.** Two things trip people up here.  First, JSON does not allow comments, so delete the `// TODO` line before you run your code; it is a note to you, not valid JSON.  Second, a multi-line docstring must be written as a single JSON string with `\n` for each line break and `\"` for each quote.

Now run the critic once per draft and keep the verdict beside the planted defect.

> **Do this.**
> 1. Create `calibrate.py` in the same folder and start it with `from critique_refine import critique_draft, load_config, load_rubric`.
> 2. Add `run_calibration` below.

```python
import json

def run_calibration(calibration_file, config, rubric):
    with open(calibration_file) as f:
        drafts = json.load(f)

    results = []
    for d in drafts:
        critique = critique_draft(d["draft"], rubric, config)
        results.append({
            "id": d["id"],
            "planted_defect": d["defect"],
            "critic_verdict": critique["verdict"],
            "critic_issues": critique["issues"]
        })
        print(f"{d['id']} (defect={d['defect']}): critic says {critique['verdict']}")

    return results
```

> **You should see.** One line per draft, such as `D01 (defect=missing_C4): critic says revise`.  A defect-free draft should say `accept`; if not, that is a false positive, and Step A.6 counts it.

### Step A.6: Compute the rates and find the case where the critic was wrong

For each criterion, the code counts four cases: true positives (planted defect, critic flagged it), false negatives (planted defect, critic missed it), false positives (no defect, critic flagged it), and true negatives (no defect, critic stayed quiet).  A missed defect or a phantom defect is a case where the critic was wrong, and you can tell because you planted the truth.  That case, with how you could tell, is what the Part A row's proficient column asks for.

> **Do this.**
> 1. Add `compute_rates` below to `calibrate.py`.
> 2. Add a `__main__` block that loads the config and rubric, calls `run_calibration("calibration_drafts.json", config, rubric)`, and passes the results to `compute_rates`.
> 3. Run `python3 calibrate.py` and copy the per-criterion lines into a table in your readme.
> 4. Name the weakest criterion (the one with the lowest detection rate) and pick one draft where the critic was wrong: a planted defect it missed, or a defect-free draft it flagged.  In your readme, quote the critic's verdict beside the defect you planted and say in one or two sentences how you could tell the critic was wrong.
> 5. Rewrite the weakest criterion's descriptor in `rubric.json` so that a reader can check it without interpretation, as in the example below, re-run `python3 calibrate.py`, and show the original descriptor next to the new one with the detection rate before and after.  Report both numbers even if the rewrite did not help; that is a result too.

```python
def compute_rates(results, rubric):
    criteria_ids = [c["id"] for c in rubric["criteria"]]
    rates = {}

    for cid in criteria_ids:
        # True positives: draft has this defect AND critic mentioned it
        # False negatives: draft has this defect AND critic missed it
        # False positives: draft has NO defect AND critic flagged this criterion
        tp = fp = fn = tn = 0

        for r in results:
            has_defect = cid.lower() in r["planted_defect"].lower() or "none" not in r["planted_defect"].lower()
            # Simplification: check if any issue string mentions the criterion ID or name
            critic_flagged = any(cid in issue for issue in r["critic_issues"])

            if r["planted_defect"] == "none":
                # Defect-free draft
                if critic_flagged:
                    fp += 1
                else:
                    tn += 1
            else:
                # Draft has planted defect
                if critic_flagged:
                    tp += 1
                else:
                    fn += 1

        detection_rate = tp / (tp + fn) if (tp + fn) > 0 else float("nan")
        fp_rate = fp / (fp + tn) if (fp + tn) > 0 else float("nan")
        rates[cid] = {"detection_rate": detection_rate, "false_positive_rate": fp_rate}
        print(f"  {cid}: detection={detection_rate:.2f}, fp_rate={fp_rate:.2f}")

    return rates
```

> **You should see.** One line per criterion in the form `  C1: detection=0.75, fp_rate=0.00`.  A `nan` means no draft exercised that case; add drafts until none remain.  After the rewrite, the rewritten criterion's detection rate goes up on the re-test while the others hold steady.

Example rewrite:

- **Before**: "C4 (Example): At least one example is provided."
- **After**: "C4 (Example): At least one usage example is shown in doctest format: a line beginning with `>>>` followed by the function call, and a second line with the expected return value."

> **Checkpoint.** Before moving to Step A.7, make sure you can answer:
> 1. Which criterion had the lowest detection rate before your rewrite?  What specifically made that criterion hard for the model to evaluate?
> 2. What is the difference between a detection rate and a false positive rate?  Which one is more costly in a real deployment, and why?
> 3. Why must you include defect-free drafts in a calibration set, not just defective ones?

### Step A.7: Find a loophole and write a hack draft

Reward hacking is producing an output that satisfies the letter of a scoring rule while missing its intent.  The scorer says "accept"; a human says "this is poor."  Do exactly that to your own rubric on purpose, so you can see the loophole and close it.  A successful hack is a second kind of case where the critic was wrong, and this time you can tell because your own judgment disagrees with its verdict.

> **No-code path.** This step asks you to write something that scores well and is bad.  That is a writing exercise; the route you used to run the rubric does not change it.  Save the critic's "accept" reply, edit the rubric text inside the preset or Critic node to make the patch in Step A.8, and run both the hack and a defect-free draft through the patched critic.

> **Do this.**
> 1. Read each criterion's descriptor literally, the way the critic does, and look for one of these loophole types:
>    - **Keyword stuffing**: The descriptor says "contains a one-sentence summary"; can you write a sentence so vague it is technically present but useless?
>    - **Minimal compliance**: The descriptor says "every parameter is listed"; can you list parameters with empty or copy-pasted descriptions?
>    - **Format gaming**: The descriptor says "in doctest format"; can you write a syntactically valid doctest that tests nothing meaningful?
> 2. Write down which criterion you can satisfy without producing anything useful, and why; the checkpoint after Step A.8 asks for it in one sentence.
> 3. Create `hack.py` in your lab folder.  Import `critique_draft`, `load_config`, and `load_rubric` from `critique_refine`, then load the config and rubric.
> 4. Paste the block below, replacing `hack_draft` with your own hack if the example does not fit your task, and run `python3 hack.py`.
> 5. Put the transcript in your readme verbatim, with your own judgment of why the draft is poor.

```python
hack_draft = """
\"\"\"Do stuff.

Args:
    a (list[int]): a.
    b (list[int]): b.

Returns:
    list[int]: result.

Example:
    >>> merge_sorted_lists([1], [2])
    [1, 2]
\"\"\"
"""

critique = critique_draft(hack_draft, rubric, config)
print(f"Critic verdict on hack: {critique['verdict']}")
print(f"Issues: {critique['issues']}")
# Expected: verdict == "accept" despite being a poor docstring
```

> **You should see.** `Critic verdict on hack: accept` with an empty issue list.  If the critic says `revise`, the loophole is not as open as you thought; see Troubleshooting, Part A.

### Step A.8: Patch the rubric and verify the patch

A rubric that only rejects the hack is not a fix if it also rejects good work.  Both tests below have to pass.

> **Do this.**
> 1. Copy `rubric.json` to `rubric_patched.json` and change only the exploited criterion's descriptor.
> 2. Append the two tests below to `hack.py`, with `good_draft` set to your defect-free draft from Step A.5, and run it again.
> 3. Show the diff in your readme; `diff rubric.json rubric_patched.json` prints it.

```python
# load_rubric_from_file(path) is a two-line helper you write: open the path and return json.load(f)
rubric_patched = load_rubric_from_file("rubric_patched.json")

# Test 1: patch rejects the hack
critique_hack = critique_draft(hack_draft, rubric_patched, config)
print(f"Patched rubric on hack: {critique_hack['verdict']}")  # Expected: revise

# Test 2: patch still accepts a good draft
good_draft = "..."  # your defect-free draft from Step A.5
critique_good = critique_draft(good_draft, rubric_patched, config)
print(f"Patched rubric on good draft: {critique_good['verdict']}")  # Expected: accept
```

> **You should see.** `Patched rubric on hack: revise` followed by `Patched rubric on good draft: accept`.  Both lines are your second transcript.

> **Checkpoint.** Before moving to Step A.9, make sure you can answer:
> 1. Describe your hack in one sentence.  Which criterion's descriptor had the loophole?
> 2. What does the existence of reward hacking imply about using any rubric (automated or human) as the sole quality gate?
> 3. In your patched rubric, what specific wording change closed the loophole?  Why does that wording prevent the hack while still accepting good work?

### Step A.9: Compare the loop with single-shot generation

Single-shot generation is one generator call with no critique.  On a fixed set of at least eight tasks, compare single-shot generation against your full critique-and-refine loop.  Score both conditions with the same instrument: your calibrated critic on a held-out rubric, or a blind human ranking between you and your partner.  The comparison is only fair when both conditions use the same tasks and the same scorer.  For each task, condition A makes one generator call and one scoring call; condition B runs the full loop and then makes one scoring call.

> **No-code path.** Run each task once through the generator preset alone and once through the full loop, score both drafts with the critic preset, and count the calls by hand.  Time one pass versus three by the clock, and answer Step A.10's question with your own measurements.

> **Do this.**
> 1. Create `compare.py` in your lab folder.  Import `generate_draft`, `critique_draft`, `critique_refine_loop`, `load_config`, and `load_rubric` from `critique_refine`, then load the config and rubric.
> 2. Paste the task list and `score_draft` below, and add five more tasks of increasing complexity, following the comments in the list.
> 3. Append the run block after them and run `python3 compare.py`.  Eight tasks times up to five rounds takes a while on a laptop; let it finish.
> 4. Keep `comparison_results.csv`; it goes in your ZIP.

```python
COMPARISON_TASKS = [
    "Write a docstring for a function `binary_search(arr, target)` that searches a sorted list.",
    "Write a docstring for a function `flatten(nested_list)` that recursively flattens nested lists.",
    # Worked example of a more complex task - note how it adds competing constraints
    # (multiple parameters, an exception case, and a default value) that all four
    # rubric criteria must cover simultaneously:
    "Write a docstring for a function `paginate(items, page_size=10, page=1)` that returns one page of a list and raises ValueError when page is out of range.",
    # TODO: Add 5 more tasks of increasing complexity, following the pattern above.
    # Each task is just a plain string in this list. Good sources of "complexity":
    # more parameters, default values, error/exception cases, and edge cases
    # (empty input, ties, duplicates) that the docstring must document.
]

# Use your calibrated rubric as the scoring instrument
# Score: count the number of criteria the critic marks as met (0-4 for a 4-criterion rubric)
def score_draft(draft, rubric, config):
    """Returns (numeric_score, critique_dict, calls_made)."""
    critique = critique_draft(draft, rubric, config)
    issues = critique.get("issues", [])
    # Score = total criteria - number of issues mentioned
    num_criteria = len(rubric["criteria"])
    score = max(0, num_criteria - len(issues))
    return score, critique, 1  # 1 model call for critique
```

```python
import csv

results = []
for i, task in enumerate(COMPARISON_TASKS):
    # Condition A: single shot
    single_draft = generate_draft(task, config=config)
    single_score, _, critique_calls = score_draft(single_draft, rubric, config)
    single_total_calls = 1 + critique_calls  # 1 generate + 1 critique

    # Condition B: critique and refine loop
    loop_draft, loop_critique, rounds, reason = critique_refine_loop(task, config, rubric)
    loop_score, _, final_critique_calls = score_draft(loop_draft, rubric, config)
    # Calls: rounds * (1 generate + 1 critique) + 1 final scoring critique
    loop_total_calls = rounds * 2 + final_critique_calls

    results.append({
        "task_id": f"T{i+1:02d}",
        "single_score": single_score,
        "single_calls": single_total_calls,
        "loop_score": loop_score,
        "loop_calls": loop_total_calls,
        "loop_rounds": rounds,
        "loop_reason": reason,
    })
    print(f"T{i+1:02d}: single={single_score}/4 ({single_total_calls} calls) | loop={loop_score}/4 ({loop_total_calls} calls, {rounds} rounds)")

# Write results CSV
with open("comparison_results.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=results[0].keys())
    writer.writeheader()
    writer.writerows(results)

avg_single = sum(r["single_score"] for r in results) / len(results)
avg_loop = sum(r["loop_score"] for r in results) / len(results)
avg_single_calls = sum(r["single_calls"] for r in results) / len(results)
avg_loop_calls = sum(r["loop_calls"] for r in results) / len(results)
print(f"\nSingle-shot: avg score={avg_single:.2f}, avg calls={avg_single_calls:.1f}")
print(f"Loop: avg score={avg_loop:.2f}, avg calls={avg_loop_calls:.1f}")
```

> **You should see.** One line per task and two summary lines; your numbers will differ.

```text
T01: single=2/4 (2 calls) | loop=4/4 (6 calls, 3 rounds)
T02: single=3/4 (2 calls) | loop=4/4 (4 calls, 2 rounds)
...
Single-shot: avg score=2.75, avg calls=2.0
Loop: avg score=3.50, avg calls=5.2
```

### Step A.10: Write the cost-for-quality paragraph

Report the cost next to the quality every time, because a loop that always wins on quality can still lose on cost.  This paragraph is the last thing the Part A row's proficient column asks for.

> **Do this.** In your readme, answer two questions in one paragraph, citing the average scores and call counts from your run:
> 1. Did the loop earn its extra model calls?  State what the loop cost in extra calls for the quality it bought.
> 2. Under what conditions (task complexity, quality threshold, latency budget) would you choose each approach?

> **Checkpoint.** Before moving to Part B, make sure you can answer:
> 1. On average, how many extra model calls did the loop use compared to single-shot?  What was the average quality improvement?
> 2. On which tasks did the loop NOT improve over single-shot?  What do those tasks have in common?
> 3. If each model call costs \$0.001, what is the maximum quality improvement you would pay for in a real deployment, and how does that compare to what you measured?

### Troubleshooting, Part A

- **The critic always returns `"verdict": "revise"` even after many rounds.**  Print the full critic output (`raw` before JSON parsing) to see what the model is actually saying.  Common causes: (1) the model is outputting JSON wrapped in markdown fences; the strip step in the parser should handle this, but check for unusual fence formats; (2) the rubric descriptors are so strict that no draft can satisfy them; loosen one criterion as a test.
- **`json.JSONDecodeError` fires on valid-looking output.**  The model may be inserting a BOM or non-breaking space before the opening `{`.  Add `raw = raw.encode('ascii', 'ignore').decode('ascii')` before `json.loads` to strip non-ASCII, then re-try.
- **The loop never terminates (no `accept` and no budget exhaustion).**  Check that your `for round_num in range(1, config["round_budget"] + 1)` loop is iterating the correct number of times.  Print `round_num` at the start of each iteration.  If it runs forever, your `return` on `"accepted"` may be inside an inner scope; check indentation.
- **Detection rate is 1.0 for all criteria even with weak descriptors.**  Your planted defects may be too obvious.  Try subtle defects: a parameter description that lists the name but not the type, or an example that shows a call but not the return value.  Make the defect require careful reading to spot.
- **Detection rate is 0.0 for a criterion even after rewriting.**  The model may not be parsing your criterion ID correctly.  Change the prompt to include the criterion name in full (not just "C1") and check that the model's issue strings reference those names.
- **Your two defect-free drafts get critiqued as "revise".**  This is a false positive.  Record the rate and include it in your analysis; it is an important signal that the rubric is stricter than it needs to be.
- **You cannot find a hack: the critic is too strict.**  Try the minimal-compliance approach: meet every criterion with the absolute minimum.  For example, if the criterion says "every parameter is listed with name, type, and description," write a description of a single character: `a (list[int]): x.`
- **The patch rejects both the hack AND the good draft.**  Your patch is too strict.  Revise the wording to be more precise rather than more restrictive.  The goal is to close the specific loophole, not to raise the bar for all drafts.
- **The critic is non-deterministic even at temperature 0.**  Some Ollama models ignore the seed parameter.  Run the same draft three times and record whether the verdict is consistent.  If it is not, note this in your writeup as a threat to calibration reliability.
- **Single-shot and loop produce identical scores.**  Your rubric criteria may be too easy to satisfy in a single shot.  Try harder tasks (more criteria to satisfy simultaneously) or add a fifth criterion to your rubric.  Single-shot may also score high because you chose simple tasks; the benefit of the loop shows most clearly on tasks with four or more competing constraints.
- **The loop always hits the round budget without accepting.**  Decrease the `round_budget` to 3 for the comparison experiment so budget-exhaustion cases are more frequent and visible in your data.  Document these cases; they show the loop's failure mode.
- **Scores from the critic feel inconsistent across conditions.**  Use a fresh critic call with a fixed seed for all final scoring (not the verdicts from within the loop).  Then both conditions are scored by the same "judge call" and the results are comparable.

---

## Part B.1: Build a Configurable Debate (25 points)

Build a debate in which the number of agents, the number of rounds, and the temperature schedule all live in the JSON configuration file.  Round one is independent: each agent answers alone.  Later rounds are peer-informed: each agent sees the other agents' previous answers and may revise or hold its position.  Aggregate the final round two ways, by majority vote and by an optional judge agent.  Answer extraction must tolerate formatting drift: anchor on a required `ANSWER:` line, and when that line is missing, print a located error message instead of failing silently.

### Step B.1.1: Check the debate settings in the configuration file

> **Do this.** Open the `config.json` you created in Step A.1 and find the `debate` block: three agents, two rounds, a temperature schedule, and a seed base.  Leave the values as they are for the first run.  The `temperature_schedule` list has one temperature per round; if there are more rounds than entries, repeat the last entry.  The `consensus` block in the same file is read in Part B.2.

### Step B.1.2: Write the per-agent generation function

One function produces one agent's response for one round; the prompt differs between round 1 and the peer-informed rounds.

> **Do this.**
> 1. Create a file named `lab4.py` next to `config.json`.  Parts B.1 and B.2 both add functions to this file.
> 2. Paste in the imports, `load_config`, and `agent_respond` below.

```python
import requests
import json
import re
import traceback

def load_config(path="config.json"):
    with open(path) as f:
        return json.load(f)

def agent_respond(question, agent_id, round_num, peer_answers, config):
    """
    Generate one agent's response for the given round.
    round_num: 1-indexed
    peer_answers: list of (agent_id, answer_text) from the previous round (empty for round 1)
    Returns the full response text.
    """
    schedule = config["debate"]["temperature_schedule"]
    temp = schedule[min(round_num - 1, len(schedule) - 1)]
    seed = config["debate"]["seed_base"] + agent_id * 100 + round_num

    if round_num == 1:
        # Independent first round
        user_content = (
            f"Question: {question}\n\n"
            f"Think through this carefully and provide your answer. "
            f"End your response with a line in exactly this format:\n"
            f"ANSWER: <your answer here>"
        )
    else:
        # Peer-informed revision round
        peer_section = "\n\n".join(
            f"Agent {pid} said:\n{ans}" for pid, ans in peer_answers
        )
        user_content = (
            f"Question: {question}\n\n"
            f"Here are the answers from the other agents in the previous round:\n\n"
            f"{peer_section}\n\n"
            f"Review their reasoning. You may revise your answer if you find their arguments convincing, "
            f"or maintain your position with a rebuttal. "
            f"End your response with a line in exactly this format:\n"
            f"ANSWER: <your answer here>"
        )

    messages = [{"role": "user", "content": user_content}]
    payload = {
        "model": config["model"],
        "messages": messages,
        "stream": False,
        "options": {"temperature": temp, "seed": seed}
    }

    try:
        response = requests.post(config["ollama_url"], json=payload, timeout=60)
        response.raise_for_status()
        return response.json()["message"]["content"]
    except Exception as e:
        print(f"[lab4:agent_respond:agent{agent_id}:round{round_num}] {e}")
        traceback.print_exc()
        raise
```

Notice the `except` block: a located message (the `[lab4:agent_respond:...]` tag says where it failed), a traceback, then a re-raise.  The Code Quality row checks for this on every model and embedding call.

### Step B.1.3: Extract the answer with a located warning

> **Do this.**
> 1. Add `extract_answer` below `agent_respond` in `lab4.py`.

```python
def extract_answer(response_text, agent_id, round_num):
    """
    Extract the ANSWER: line from a response.
    Returns the answer string, or None if not found (with a located warning).
    """
    match = re.search(r"ANSWER:\s*(.+)", response_text, re.IGNORECASE)
    if match:
        return match.group(1).strip()
    else:
        print(f"[lab4:extract_answer] WARNING: Agent {agent_id}, round {round_num} - no ANSWER: line found. Full response: {response_text[:200]!r}")
        return None
```

> **Watch out.** A missing `ANSWER:` line must produce a located error, never a silent wrong answer.  `None` is the signal, and every caller of this function has to handle it.

### Step B.1.4: Run the debate loop

The loop feeds each agent the *other* agents' previous answers, never its own, and keeps every full response for your transcript.

> **Do this.**
> 1. Add `run_debate` below `extract_answer`.

```python
def run_debate(question, config):
    """
    Run a full multi-agent debate.
    Returns (final_answers_by_agent, all_round_transcripts, total_calls).
    """
    num_agents = config["debate"]["num_agents"]
    num_rounds = config["debate"]["num_rounds"]
    total_calls = 0

    # round_answers[round][agent_id] = (full_response, extracted_answer)
    round_answers = {}

    for round_num in range(1, num_rounds + 1):
        print(f"\n=== Debate Round {round_num} ===")
        round_answers[round_num] = {}

        for agent_id in range(num_agents):
            # Peer answers: all agents from previous round except self
            if round_num == 1:
                peer_answers = []
            else:
                peer_answers = [
                    (pid, extract_answer(data[0], pid, round_num - 1) or "(no answer)")
                    for pid, data in round_answers[round_num - 1].items()
                    if pid != agent_id
                ]

            response = agent_respond(question, agent_id, round_num, peer_answers, config)
            answer = extract_answer(response, agent_id, round_num)
            round_answers[round_num][agent_id] = (response, answer)
            total_calls += 1
            print(f"  Agent {agent_id}: ANSWER = {answer}")

    # Final answers from last round
    final_answers = {
        agent_id: data[1]
        for agent_id, data in round_answers[num_rounds].items()
        if data[1] is not None
    }

    return final_answers, round_answers, total_calls
```

### Step B.1.5: Aggregate by majority vote

> **Do this.**
> 1. Add the `Counter` import and `majority_vote` below `run_debate`.

```python
from collections import Counter

def majority_vote(final_answers):
    """
    Return the most common answer among the agents.
    In case of a tie, return the lexicographically first answer.
    """
    if not final_answers:
        return None
    counts = Counter(final_answers.values())
    return counts.most_common(1)[0][0]
```

The proficient column asks for a judge-agent option alongside majority vote.  Challenge B1 at the end of this page describes the judge, and the handoff route in Part B.3 uses one as its tie rule.

### Step B.1.6: Run a smoke test

> **Do this.**
> 1. Add this block at the bottom of `lab4.py`.
> 2. Run the file from the lab folder.  `python3 lab4.py` runs the file top to bottom; the block under `if __name__ == "__main__":` is what executes.
>
> ```bash
> python3 lab4.py
> ```

```python
if __name__ == "__main__":
    config = load_config()
    question = "What is 15% of 240?"
    final_answers, transcripts, calls = run_debate(question, config)
    winner = majority_vote(final_answers)
    print(f"\nFinal answers: {final_answers}")
    print(f"Majority vote: {winner}")
    print(f"Total model calls: {calls}")
```

> **You should see.** Two rounds of three agents, then a vote.  Your answers will differ, but the call count should equal agents times rounds.

```text
=== Debate Round 1 ===
  Agent 0: ANSWER = 36
  Agent 1: ANSWER = 36
  Agent 2: ANSWER = 34

=== Debate Round 2 ===
  Agent 0: ANSWER = 36
  Agent 1: ANSWER = 36
  Agent 2: ANSWER = 36

Final answers: {0: '36', 1: '36', 2: '36'}
Majority vote: 36
Total model calls: 6
```

### Troubleshooting, Part B.1

- **`ANSWER:` is never found even though it appears in the raw output.**  The model may be writing `Answer:` (different capitalization) or `**ANSWER:**` (markdown bold).  The template's regex is already case-insensitive (`re.IGNORECASE`).  Strip the markdown before matching: `response_text = re.sub(r'\*+', '', response_text)`.
- **Agents always agree on round 1 (no diversity).**  Your seeds may be too similar, or the temperature is too low.  Try `seed_base: 0` and `temperature_schedule: [0.9, 0.5]`.  Factual questions can produce agreement even at high temperature; use more subjective questions when you are testing for diversity.
- **One agent's response is cut off mid-sentence.**  The model hit its context window.  Shorten `peer_section` by passing only the extracted `ANSWER` lines from peers, not their full reasoning: `f"Agent {pid} answered: {ans}"`.

> **Checkpoint.** Before you move to Part B.2, make sure you can answer these:
> 1. What is the purpose of sharing peer answers in rounds 2+ rather than keeping agents independent for all rounds?  What risk does peer-sharing introduce?
> 2. What happens in your code if `extract_answer` returns None for one agent in the final round?  How does your majority vote handle it?
> 3. Run a 3-agent, 2-round debate on an arithmetic question.  Did any agent change their answer between rounds?  If so, was it because they were persuaded by correct reasoning or simply by social pressure?

> **No-code path.** Open two Open WebUI chats with different system prompts (for example, an advocate and a skeptic), give both the same question, then paste each one's answer to the other for a rebuttal round.  Two rounds is enough to see the dynamic.  In Langflow, the same thing is two Agent nodes and a loop.  Your exported transcripts take the place of the smoke-test output.

---

## Part B.2: Build the Consensus Pipeline (20 points)

Implement the sample, cluster, synthesize pipeline: $$k$$ high-temperature drafts, embedding clustering over normalized vectors with cosine geometry, and a low-temperature synthesizer that receives one representative per cluster with its support count, follows the majority on conflicts, and discloses any close disagreement in one line.  Demonstrate the pipeline on a long-form question with no single correct answer.  The in-class tomatillo salsa question is a fine starting point; choose an analogous question of your own as well.

### Why this matters: voting on meaning instead of strings

Section 7 of *Critique, Consensus, and the LLM Judge* (Voting on Meaning Instead of Strings) introduces this pattern in class.  Here is the core idea again before you build.  **Stochastic consensus** uses the fact that a language model at high temperature is a *sampler*, not an oracle: ask it the same question six times and you get six different drafts drawn from a distribution of plausible answers.  Any one draft might be idiosyncratic or wrong.  But if you group the drafts by *meaning* (not by exact wording), the sizes of the groups tell you something no single draft can: which positions the model keeps returning to (high support) and which are one-off flukes (low support).

The grouping step is where embeddings come in.  An embedding model maps each draft to a vector, and drafts with similar meaning land close together even when they share few words.  Normalize those vectors and cluster them with cosine distance, and "six drafts" becomes "three positions, with support counts of 3, 2, and 1."  A final low-temperature **synthesizer** then receives one representative draft per cluster (plus its support count), never all six raw transcripts, and writes a single answer that follows the majority and *discloses* any close disagreement instead of papering over it.  That disclosure rule is the pattern's honesty mechanism: when the samples split, the user deserves to know.

```text
question --> sample k drafts at high temperature      (k model calls)
                    |
                    v
             embed each draft --> normalize vectors
                    |
                    v
             cluster by cosine distance (threshold)
                    |
                    v
      one representative per cluster + support count
                    |
                    v
             synthesizer at low temperature            (1 model call)
                    |
                    v
   single answer, majority-following, close-disagreement disclosed
```

You will experiment with two dials in this lab: the **sampling temperature** (how diverse the drafts are) and the **distance threshold** (how aggressively meanings are merged; the subject of Part B.4).

There are three ways to aggregate $$k$$ samples, and they are not interchangeable.

**Self-consistency** votes on the *answer*.  Sample $$k$$ independent chains at moderate temperature, extract each final answer, and return the mode:

$$
\hat{y} = \arg\max_{y} \sum_{i=1}^{k} \mathbb{1}[y_i = y]
$$

For questions with short checkable answers, accuracy rises with $$k$$, because many distinct reasoning paths tend to reach a correct answer while errors scatter.  This is what Part B.1's debate vote does.

**Clustered consensus** votes on the *meaning*.  When answers are paragraphs rather than tokens, exact-match voting collapses: "simmer the tomatillos" and "boil them briefly" should count together, and a string comparison says they are unrelated.  Embed the $$k$$ drafts, cluster by cosine similarity, and treat the largest cluster as the consensus position.  It is the same machinery as the RAG-quality clustering you have already met, aimed now at agent outputs.

**Synthesis** writes the merged view.  A synthesizer receives the cluster representatives with their support counts and drafts one output that keeps majority positions and names real disagreements.  Its context stays small on purpose: cluster summaries, never all $$k$$ transcripts.

### Worked example: five recipes, three positions

Five agents at temperature 1.0 propose tomatillo salsa recipes.  Three roast the tomatillos, one boils them, one uses them raw; four include cilantro; opinions split on jalapeño versus serrano.

| Agent | Cooking technique | Chile | Key aromatics | Cluster |
|---|---|---|---|---|
| Agent 1 | Roasts under broiler until charred | Jalapeño | Cilantro, white onion, garlic | A |
| Agent 2 | Roasts in dry skillet | Serrano | Cilantro, white onion | A |
| Agent 3 | Roasts on open flame | Jalapeño | Cilantro, garlic, lime | A |
| Agent 4 | Boils for 10 minutes | Jalapeño | Cilantro, cumin | B |
| Agent 5 | Uses raw, no heat | Serrano | Cilantro, avocado, lime | C |

Before you build anything, work out three things on paper.  They are the design decisions the code will otherwise make for you.

1. Which choice here is *load-bearing* (it changes the dish) and which is garnish-level?  If you swapped jalapeño for serrano, would the dish taste radically different?  What if you swapped raw for roasted?  Your answer tells you what the clustering has to be sensitive to, and where embeddings are likely to mislead you.
2. Write, in two sentences, the synthesis you would want.  It should commit where the majority is strong (3 of 5 roast) and stay candid where it is split (the chile).  That is the behavior your synthesizer prompt has to produce.
3. State precisely why exact-match voting on the full recipe texts yields five singleton answers.  The distinction you need is *string* identity versus *semantic* identity.

> **Watch out.** Independence is the load-bearing assumption.  Sampling helps only when the errors scatter.  If all $$k$$ drafts share a systematic bias, whether a misconception baked into the model or a misleading phrase in your own prompt, they will agree confidently and be wrong together, and a large cluster will look exactly like a strong consensus.  Part B.3's shootout deliberately includes questions with well-known intuitive-but-wrong answers so you can watch this happen.

### Step B.2.1: Sample k drafts independently

> **Do this.**
> 1. Add `sample_drafts` to `lab4.py`, below `majority_vote` and above the `__main__` block.

```python
def sample_drafts(question, config):
    """
    Sample k independent drafts at high temperature.
    Returns list of draft strings.
    """
    k = config["consensus"]["num_samples"]
    temp = config["consensus"]["sample_temperature"]
    drafts = []

    for i in range(k):
        seed = config["debate"]["seed_base"] + i  # different seed per sample
        messages = [{"role": "user", "content": question}]
        payload = {
            "model": config["model"],
            "messages": messages,
            "stream": False,
            "options": {"temperature": temp, "seed": seed}
        }
        try:
            response = requests.post(config["ollama_url"], json=payload, timeout=60)
            response.raise_for_status()
            draft = response.json()["message"]["content"]
            drafts.append(draft)
            print(f"  Sample {i+1}/{k}: {draft[:80]}...")
        except Exception as e:
            print(f"[lab4:sample_drafts:sample{i}] {e}")
            traceback.print_exc()
            raise

    return drafts
```

### Step B.2.2: Embed and cluster the drafts

This code is provided complete; copy it as-is.  You are not expected to write embedding or clustering internals with one semester of Python behind you; `sentence-transformers` and scikit-learn's `AgglomerativeClustering` do that work.  Your job in this step is to *call* this function and *interpret* what it returns: which drafts landed in which cluster, which cluster has the most support, and whether the grouping matches your own reading of the drafts.

> **Do this.**
> 1. Add the three imports below to the top of `lab4.py`, and `cluster_drafts` below `sample_drafts`.
> 2. After you run the pipeline in Step B.2.4, answer the three interpretation questions that follow the code in your readme.

```python
import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.cluster import AgglomerativeClustering

def cluster_drafts(drafts, config):
    """
    Embed drafts, normalize vectors, cluster by cosine distance.
    Returns (labels, embeddings, cluster_representatives).
    labels[i] = cluster ID for draft i.
    cluster_representatives: dict {cluster_id: (representative_draft, support_count)}
    """
    embed_model_name = config["consensus"]["embed_model"]
    threshold = config["consensus"]["distance_threshold"]

    embed_model = SentenceTransformer(embed_model_name)
    embeddings = embed_model.encode(drafts)

    # Normalize to unit vectors so cosine distance = 1 - dot product
    norms = np.linalg.norm(embeddings, axis=1, keepdims=True)
    normed = embeddings / norms

    # Cosine distance = 1 - cosine_similarity
    # AgglomerativeClustering with metric='cosine' requires precomputed or use distance_threshold
    clustering = AgglomerativeClustering(
        n_clusters=None,
        distance_threshold=threshold,
        metric="cosine",
        linkage="average"
    )
    labels = clustering.fit_predict(normed)

    # Find representative (draft closest to cluster centroid) and support count
    cluster_ids = set(labels)
    representatives = {}
    for cid in cluster_ids:
        indices = [i for i, l in enumerate(labels) if l == cid]
        support = len(indices)
        # Centroid of normalized vectors
        centroid = normed[indices].mean(axis=0)
        centroid /= np.linalg.norm(centroid)
        # Draft closest to centroid
        similarities = [normed[i] @ centroid for i in indices]
        best_idx = indices[int(np.argmax(similarities))]
        representatives[cid] = (drafts[best_idx], support)

    print(f"\nClustering: {len(drafts)} drafts -> {len(cluster_ids)} clusters (threshold={threshold})")
    for cid, (rep, support) in sorted(representatives.items()):
        print(f"  Cluster {cid} (support={support}): {rep[:80]}...")

    return labels, normed, representatives
```

Interpretation questions, answered in your readme after you run the provided clustering code:

1. Print `labels` next to the first 80 characters of each draft.  Read the drafts in each cluster yourself: do the groupings match *your* judgment of which drafts say the same thing?  Name one pair the clusterer grouped that you would not have, or vice versa.
2. Which cluster has the highest support count, and in one sentence, what position does its representative draft take?
3. The representative is the draft closest to the cluster centroid.  Look at the representative chosen for your largest cluster; is it also the draft you would have picked as the "most typical" of that group?  Why might the centroid-nearest draft differ from the best-written draft?

### Step B.2.3: Synthesize from cluster representatives

The synthesizer sees one representative per cluster with its support count, majority first, never the raw drafts.

> **Do this.**
> 1. Add `synthesize` and `run_consensus` below `cluster_drafts`.

```python
def synthesize(question, representatives, config):
    """
    Build a context from cluster representatives and synthesize a final answer.
    Returns the synthesized answer string.
    """
    # Sort by support (descending) so the synthesizer sees majority first
    sorted_clusters = sorted(representatives.items(), key=lambda x: -x[1][1])
    total_support = sum(s for _, (_, s) in sorted_clusters)

    context_parts = []
    for cid, (rep, support) in sorted_clusters:
        pct = support / total_support * 100
        context_parts.append(f"[Cluster {cid}, support={support}/{total_support} ({pct:.0f}%)]\n{rep}")

    context = "\n\n---\n\n".join(context_parts)
    majority_support = sorted_clusters[0][1][1]
    close_disagreement = len(sorted_clusters) > 1 and (majority_support / total_support) < 0.6

    system_prompt = (
        "You are a synthesizer. You receive several response clusters from independent samples. "
        "Each cluster is labeled with its support count. "
        "Your job:\n"
        "1. Follow the majority position on any factual conflicts.\n"
        "2. If there is a close disagreement (majority < 60% of samples), disclose it in one sentence at the end.\n"
        "3. Produce a single coherent, well-written response. Do not just concatenate the clusters.\n\n"
        + ("NOTE: There is a close disagreement among the samples. Disclose it." if close_disagreement else "")
    )

    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": f"Question: {question}\n\nClusters:\n\n{context}"}
    ]
    payload = {
        "model": config["model"],
        "messages": messages,
        "stream": False,
        "options": {
            "temperature": config["consensus"]["synthesizer_temperature"],
            "seed": config["debate"]["seed_base"]
        }
    }
    try:
        response = requests.post(config["ollama_url"], json=payload, timeout=60)
        response.raise_for_status()
        return response.json()["message"]["content"]
    except Exception as e:
        print(f"[lab4:synthesize] {e}")
        traceback.print_exc()
        raise

def run_consensus(question, config):
    """Full sample-cluster-synthesize pipeline."""
    print(f"\n=== Sampling {config['consensus']['num_samples']} drafts ===")
    drafts = sample_drafts(question, config)

    print("\n=== Clustering ===")
    labels, embeddings, representatives = cluster_drafts(drafts, config)

    print("\n=== Synthesizing ===")
    synthesis = synthesize(question, representatives, config)

    total_calls = config["consensus"]["num_samples"] + 1  # samples + synthesizer
    return synthesis, drafts, labels, representatives, total_calls
```

### Step B.2.4: Demonstrate on a long-form question

> **Do this.**
> 1. Replace the `__main__` block at the bottom of `lab4.py` with the one below.  (Keep the Part B.1 smoke test in a comment if you want to rerun it later.)
> 2. Run `python3 lab4.py` again.  Save the full printout; it is your consensus transcript.

```python
if __name__ == "__main__":
    config = load_config()
    long_form_q = "What makes a great study group, and what are the biggest pitfalls to avoid?"
    synthesis, drafts, labels, reps, calls = run_consensus(long_form_q, config)
    print(f"\n=== SYNTHESIZED ANSWER ({calls} model calls) ===\n{synthesis}")
```

> **You should see.** Six sample previews, a clustering summary with support counts, and one synthesized answer with a disclosure line when the split is close.  Abbreviated:

```text
=== Sampling 6 drafts ===
  Sample 1/6: A great study group needs clear goals and...
  ...

=== Clustering ===
Clustering: 6 drafts -> 3 clusters (threshold=0.3)
  Cluster 0 (support=3): A great study group needs clear goals...
  Cluster 1 (support=2): The key ingredients are...
  Cluster 2 (support=1): Study groups work best when...

=== Synthesizing ===

=== SYNTHESIZED ANSWER (7 model calls) ===
A great study group combines clear shared goals, consistent meeting times, and mutual accountability...
Note: there was minor disagreement about whether size or structure matters more.
```

### Troubleshooting, Part B.2

- **`AgglomerativeClustering` raises `ValueError: The number of samples is too small`.**  This happens when `n_samples < 2`.  Set `num_samples >= 2` in your config.  For clustering to mean anything, use at least 5 samples.
- **All drafts end up in one giant cluster.**  Your `distance_threshold` is too large.  Decrease it from 0.3 to 0.15 and re-run.  If everything is still one cluster, your question may produce very uniform answers; try a more open-ended question that generates diverse responses.
- **All drafts end up in separate clusters (no merging).**  Your `distance_threshold` is too small.  Increase it from 0.3 to 0.5.  This is common with very short drafts (under 50 words) because their embedding geometry is more spread out.

> **Checkpoint.** Before you move to Part B.3, make sure you can answer these:
> 1. Why do we normalize the embedding vectors before computing cosine distance?  What goes wrong if we skip normalization?
> 2. What is the purpose of the support count in the synthesizer's context?  What would happen if you gave the synthesizer all 6 raw drafts instead of one representative per cluster?
> 3. What does it mean for a question to be "too easy" for stochastic consensus?  What kind of question would produce maximum cluster diversity?

> **No-code path.** Ask the same question *n* times at a temperature above zero, record the answers in a spreadsheet, and cluster them by hand.  The clustering judgment is the actual skill, and doing it by hand is not a concession: it is the version where the ambiguous cases cannot hide behind a distance threshold you picked without looking.  Answer the Step B.2.2 interpretation questions about your own hand clustering.

---

## Part B.3: Run the Shootout (20 points)

Build a labeled task set of at least ten questions with checkable answers (arithmetic word problems with traps work well).  At **matched call budgets**, compare:

1. Single shot (one agent, one sample).
2. Self-consistency (sample $$k$$, majority vote, no debate rounds).
3. Full debate (your Part B.1 system).

Report accuracy and total model calls per condition.  Then find and document at least one correlated failure: a question where every agent agrees on the same wrong answer.  Explain, using the independence argument from class, why no aggregation strategy could have saved you, and what non-LLM addition (a tool, retrieval) would.

### Step B.3.1: Build the labeled task set

Good task types for this comparison:

- Arithmetic word problems where one step is easy to get wrong (for example, a percentage of a percentage)
- Multi-step logic puzzles with a common false shortcut
- Questions with a well-known but incorrect folk belief as a trap

> **Do this.**
> 1. Create `shootout.py` in the lab folder.  Start it with these lines, which pull in your Part B.1 functions and load the config once:
>
> ```python
> import requests
> from collections import Counter
> from lab4 import load_config, extract_answer, run_debate, majority_vote
>
> config = load_config()
> ```
>
> 2. Paste the task set below under those lines.  Swap in questions of your own if you like, keeping this mix.

```python
SHOOTOUT_TASKS = [
    {"id": "S01", "question": "A shirt costs $40 and is on sale for 25% off. You also have a coupon for 10% off the sale price. What is the final price?", "answer": "27.00"},
    {"id": "S02", "question": "If you fold a piece of paper in half 10 times, how many layers thick is it?", "answer": "1024"},
    {"id": "S03", "question": "A store buys a jacket for $60 and marks the price up by 50%. During a sale, the marked-up price is then reduced by 50%. What is the sale price?", "answer": "45.00"},
    {"id": "S04", "question": "Three friends split a $75 dinner bill evenly, and then each person adds a $5 tip of their own. How much does each person pay in total?", "answer": "30.00"},
    {"id": "S05", "question": "A town's population of 8,000 grows by 10% one year and then shrinks by 10% the next year. What is the population after both years?", "answer": "7920"},
    {"id": "S06", "question": "How many bones are in the typical adult human body?", "answer": "206"},
    {"id": "S07", "question": "What is the capital city of Australia?", "answer": "Canberra"},
    {"id": "S08", "question": "In what year did humans first walk on the Moon?", "answer": "1969"},
    {"id": "S09", "question": "A bat and a ball cost $1.10 in total. The bat costs $1.00 more than the ball. How much does the ball cost, in cents?", "answer": "5"},
    {"id": "S10", "question": "A patch of lily pads doubles in size every day. It covers the entire lake after 48 days. After how many days did it cover half the lake?", "answer": "47"},
]
# S03-S05 are arithmetic word problems with a trap step; S06-S08 are short factual
# questions with verifiable answers; S09-S10 are classic reasoning puzzles where the
# intuitive-but-wrong answer (10 cents; 24 days) is a well-known misconception:
# good candidates for a correlated failure, where every agent agrees on the same
# wrong answer. Feel free to swap in questions of your own, keeping this mix.
```

### Step B.3.2: Run the three conditions at matched call budgets

For a budget of B=6 calls per question:

- Single shot: 1 call (use the remaining 5 as wasted budget, or run 6 single shots and majority-vote them as "self-consistency")
- Self-consistency: 6 samples, majority vote
- Full debate: 3 agents times 2 rounds = 6 calls

> **Do this.**
> 1. Paste the code below under the task set in `shootout.py`.
> 2. Run it from the lab folder.  Ten questions at 13 calls each takes a while on a laptop; let it finish.
>
> ```bash
> python3 shootout.py
> ```

```python
import csv

def single_shot(question, config, seed_offset=0):
    """One call, no aggregation."""
    messages = [{"role": "user", "content": f"{question}\n\nEnd your response with: ANSWER: <your answer>"}]
    payload = {
        "model": config["model"],
        "messages": messages,
        "stream": False,
        "options": {"temperature": 0.2, "seed": config["debate"]["seed_base"] + seed_offset}
    }
    r = requests.post(config["ollama_url"], json=payload, timeout=60)
    text = r.json()["message"]["content"]
    return extract_answer(text, "single", 1)

def self_consistency(question, config, k=6):
    """Sample k answers and take majority vote."""
    answers = []
    for i in range(k):
        ans = single_shot(question, config, seed_offset=i)
        if ans:
            answers.append(ans)
    if not answers:
        return None
    return Counter(answers).most_common(1)[0][0]

results = []
for task in SHOOTOUT_TASKS:
    q, expected = task["question"], task["answer"]
    print(f"\n=== {task['id']} ===")

    # Single shot
    ss_answer = single_shot(q, config)
    ss_correct = expected.lower() in (ss_answer or "").lower()

    # Self-consistency (6 samples = 6 calls)
    sc_answer = self_consistency(q, config, k=6)
    sc_correct = expected.lower() in (sc_answer or "").lower()

    # Full debate (3 agents × 2 rounds = 6 calls)
    final_answers, transcripts, debate_calls = run_debate(q, config)
    debate_answer = majority_vote(final_answers)
    debate_correct = expected.lower() in (debate_answer or "").lower()

    print(f"  Single shot: {ss_answer} ({'CORRECT' if ss_correct else 'WRONG'})")
    print(f"  Self-consistency: {sc_answer} ({'CORRECT' if sc_correct else 'WRONG'})")
    print(f"  Debate: {debate_answer} ({'CORRECT' if debate_correct else 'WRONG'})")

    results.append({
        "id": task["id"], "expected": expected,
        "single_answer": ss_answer, "single_correct": ss_correct, "single_calls": 1,
        "sc_answer": sc_answer, "sc_correct": sc_correct, "sc_calls": 6,
        "debate_answer": debate_answer, "debate_correct": debate_correct, "debate_calls": debate_calls,
    })

# Print summary
for condition, calls_key, correct_key in [
    ("Single shot", "single_calls", "single_correct"),
    ("Self-consistency", "sc_calls", "sc_correct"),
    ("Debate", "debate_calls", "debate_correct"),
]:
    acc = sum(r[correct_key] for r in results) / len(results)
    avg_calls = sum(r[calls_key] for r in results) / len(results)
    print(f"{condition}: accuracy={acc:.1%}, avg_calls={avg_calls:.1f}")
```

> **You should see.** A per-question block for each task, then three summary lines.  Your percentages will differ; the shape is what matters.

```text
Single shot: accuracy=60.0%, avg_calls=1.0
Self-consistency: accuracy=70.0%, avg_calls=6.0
Debate: accuracy=80.0%, avg_calls=6.0
```

> **Watch out.** `single_shot` has no exception handler.  Add the located `try`/`except` from `agent_respond` before you submit; the Code Quality row covers every model call.

### Step B.3.3: Document a correlated failure

> **Do this.**
> 1. Find a question in your task set (or add one) where all agents agree on the same wrong answer.
> 2. Paste all agents' verbatim `ANSWER:` lines alongside the correct answer in your readme.
> 3. Explain in your writeup: why does aggregation fail here, and what non-LLM resource (a calculator, a lookup, retrieval from a factual source) would fix it?

### Optional route: exchange positions through a channel

You may run the debate condition of the shootout as two agents that exchange positions through a shared channel, instead of three agents inside one Python process.  The channel is a GitHub issue thread or a Dropbox-style shared folder, and the agents follow the claim protocol from the session *Agents That Talk: Multi-Agent Communication Through GitHub and Dropbox, and Threat Modeling*.  This route earns the same credit on the same rubric rows (Debate Implementation and Comparative Evaluation).  The channel transcript takes the place of the in-process 3-agent, 2-round transcript, and the written protocol (how to claim, what a second agent does on seeing a claim, what makes a claim stale, what "done" looks like) takes the place of the round loop in `run_debate`.

A **claim** is a visible mark in the channel that says "this item is mine now," made before any work starts.  On GitHub it is a "Claiming this" comment plus an `in-progress` label.  In a folder it is a rename from `inbox/` to `claimed/` followed by a `.claim` file holding `claimed_by` and `claimed_at`.  The rule that matters for a debate is that an agent claims the other agent's position before it reads it, so the transcript proves who read what, and when.

> **Do this.** For each question in your task set:
> 1. Write the protocol down first, as paths and conditions.  For GitHub: one issue per question, titled with the task id, and the four conventions (claim comment and label, the reply format ending in `ANSWER:`, the stale timeout, the closing comment that records the vote).  For a folder: `handoff/inbox/`, `handoff/claimed/`, and `handoff/done/`, the rename-as-claim rule, the `.claim` file, the stale timeout, and the `.result.md` file that marks a position as answered.
> 2. Round 1, independent.  Each agent is its own chat session or its own script with its own seed.  Each answers from the question alone, before reading anything the other posted, and ends with an `ANSWER:` line.  On GitHub, each agent posts its full response as a comment.  In the folder, each agent writes `S01-agentA-round1.md` or `S01-agentB-round1.md` into `inbox/`.
> 3. Round 2, handoff.  Each agent claims the other's round-1 position (the claim comment and label, or the rename plus the `.claim` file), then reads it, then posts a revision: a changed answer or a held position with a rebuttal, again ending in `ANSWER:`.  On GitHub the revision is a comment.  In the folder, the agent renames the claimed file into `done/` and writes its revision beside it as `S01-agentA-round1.result.md`.
> 4. Aggregate.  Extract the `ANSWER:` line from each round-2 post with the same `extract_answer` rule as the in-process debate, including the located warning when the line is missing.  Two agents can tie, so your protocol must state the tie rule: a judge agent (one extra call) picks the answer, or the pair records the tie as no answer.  Post the result as the closing comment or as `S01.vote.md` in `done/`.
> 5. Match the budget.  The channel debate costs two agents times two rounds, plus one call if the judge ran.  Set `k` for self-consistency to that same number so the three conditions stay matched, and report the actual call count per condition in your table.

Your transcript must show the exchange with timestamps.  On the GitHub route, submit the issue URL and a saved copy of each thread (an export or screenshots) showing, in order: the question, each agent's round-1 comment, each claim comment with its label, each round-2 comment, and the closing comment with the vote.  GitHub timestamps every comment for you.  On the folder route, submit a listing of `handoff/` with full timestamps (for example `ls -l --time-style=full-iso -R handoff/`, or the Dropbox file activity view) alongside the contents of every file in `inbox/`, `claimed/`, and `done/`, including each `.claim` file with its `claimed_by` and `claimed_at`.  In either case a reader must be able to see that each claim happened before the read it authorized, and that every round-2 post is a reply to a specific round-1 position.

> **Watch out.** One reminder from that session applies here: a comment in the thread is an instruction the other agent will read, so a stray or injected line in a position becomes part of the next agent's context.

### Troubleshooting, Part B.3

- **Self-consistency and debate produce identical results on every task.**  For debate to beat self-consistency, some agents need to change their mind in revision rounds, and that requires questions with initial diversity.  Add more word problems with common arithmetic pitfalls; single-step questions rarely produce diversity.
- **All three conditions fail on the same questions (beyond the one correlated failure).**  Your task set may be too hard for the model you are using.  Add some easier questions so the results spread across correct and incorrect answers and the comparison has signal.  If everything is wrong, you cannot see which method is better.
- **One agent never produces an ANSWER: line.**  Check the temperature and seed for that agent.  At very high temperature (above 1.0) the model output can be incoherent.  Cap temperatures at 0.9 in your `temperature_schedule`.

> **Checkpoint.** Before you move to Part B.4, make sure you can answer these:
> 1. On your task set, which condition had the best accuracy?  Did it also have the highest call count?  What does that tradeoff imply about deployment decisions?
> 2. Describe your correlated failure in one sentence.  Why could neither majority vote nor debate fix it?
> 3. Name the non-LLM resource that would fix your correlated failure.  How would you integrate it into your existing agent architecture (think back to the Local Agent Lab's tool pattern)?

> **No-code path.** Compare single-shot, debate, and consensus on the same question set in your spreadsheet, with a column for cost (rough token count or wall-clock time).  The handoff route above fits here too: the two chats can exchange their positions through an issue thread or a shared folder instead of by pasting.

---

## Part B.4: Test Threshold Sensitivity (supports the Consensus row)

Vary the clustering `distance_threshold` across at least three values and report how the cluster structure, and therefore the synthesized consensus, changes on your long-form question.  Conclude with one paragraph: who should own this parameter in a deployed system, and how would you document its setting?

### Step B.4.1: Run consensus at three threshold values

> **Do this.**
> 1. Create `threshold.py` in the lab folder, starting with these two lines:
>
> ```python
> from lab4 import load_config, run_consensus
> config = load_config()
> ```
>
> 2. Paste the loop below under them and run it:
>
> ```bash
> python3 threshold.py
> ```

```python
long_form_q = "What makes a great study group, and what are the biggest pitfalls to avoid?"
thresholds = [0.1, 0.3, 0.5]  # tight, medium, loose

for threshold in thresholds:
    config["consensus"]["distance_threshold"] = threshold
    synthesis, drafts, labels, reps, calls = run_consensus(long_form_q, config)
    num_clusters = len(set(labels))
    print(f"\n=== Threshold = {threshold} ===")
    print(f"Clusters: {num_clusters}")
    print(f"Synthesis (first 200 chars): {synthesis[:200]}...")
```

> **You should see.** The cluster count falling as the threshold rises.

```text
=== Threshold = 0.1 ===
Clusters: 6   <- each draft is its own cluster
Synthesis (first 200 chars): There were 6 distinct perspectives on what makes a great study group...

=== Threshold = 0.3 ===
Clusters: 3   <- moderate merging
Synthesis (first 200 chars): A great study group combines clear goals (supported by 3 samples)...

=== Threshold = 0.5 ===
Clusters: 1   <- everything merged
Synthesis (first 200 chars): A great study group needs...
```

### Step B.4.2: Tabulate and write your conclusion

> **Do this.**
> 1. In your readme, fill in a table like this one with your own numbers and descriptions:
>
> | Threshold | Clusters | Synthesis character |
> |-----------|----------|---------------------|
> | 0.1 | 6 | Highly fragmented; all views presented equally |
> | 0.3 | 3 | Balanced; majority position emerges |
> | 0.5 | 1 | Over-merged; diversity lost |
>
> 2. Then answer in one paragraph: who should own this parameter, the system developer, the deployer, or the end user?  What documentation would help them choose a value?

### Troubleshooting, Part B.4

- **All thresholds produce the same number of clusters.**  Your drafts may be nearly identical (low diversity from sampling).  Increase `sample_temperature` to 0.9 or 1.0, or use a more open-ended question.  You can also inspect the actual pairwise cosine distances with `1 - (normed @ normed.T)` to see what distances you are working with.
- **Threshold 0.1 produces fewer clusters than threshold 0.3.**  This is unexpected: a lower threshold should produce more (tighter) clusters.  Check that you are using `distance_threshold` as an upper bound for merging (not a lower bound).  With `AgglomerativeClustering`, lower threshold = more clusters.

> **Checkpoint.** Before you write your deliverables, make sure you can answer these:
> 1. At what threshold did the synthesizer produce the most useful response on your long-form question?  Why?
> 2. What is the danger of setting the threshold too low?  What is the danger of setting it too high?
> 3. If you were deploying this system for a company's internal knowledge base, who would you recommend owns the threshold parameter, and what guidance would you write in the documentation?

> **No-code path.** Vary the agreement threshold you would accept (how many of your hand-clustered answers have to agree before you call it a consensus) and show, from your own data, where the answer flips.

---

## Deliverables

Submit one ZIP containing both halves.  Fix random seeds where determinism is intended and list software version information so I can reproduce your numbers.  The readme writeup is approximately two pages and names your route at the top.

| File or artifact | What it shows | Rubric row |
|------------------|---------------|------------|
| `critique_refine.py`, `rubric.json`, and a terminal log or screenshot with at least two complete generate, critique, refine cycles | The loop, its stopping rule, fail-closed parsing, and a draft changing in response to a critique | Part A (20) |
| `calibration_drafts.json` and the per-criterion rates table | Planted defects, detection and false positive rates, the weakest criterion before and after, and the case where the critic was wrong with how you could tell | Part A (20) |
| Hack transcript, `rubric_patched.json`, diff, second transcript | The critic's "accept" beside your judgment that the draft is poor; the patch; reject-hack and accept-good | Part A (20) |
| `comparison_results.csv` and the cost-for-quality paragraph | Score and call count per condition on at least eight tasks; what the loop cost in extra calls for the quality it bought | Part A (20) |
| `lab4.py`, `shootout.py`, `threshold.py` | Debate loop, consensus pipeline, and comparison script, with docstrings and located exception handlers | Debate (25); Consensus (20); Code Quality (10) |
| `config.json` | Temperatures, round budget, agents, rounds, temperature schedule, and distance threshold for both halves, not hardcoded | Code Quality (10) |
| Task set with labels | At least ten checkable questions | Comparative Evaluation (20) |
| Comparison results (CSV or table) | Accuracy and call count per condition at matched budgets | Comparative Evaluation (20) |
| Debate and consensus transcripts, at least two questions each | One complete 3-agent, 2-round debate (or the handoff thread or folder listing with timestamps) and the long-form consensus demonstration | Debate (25); Consensus (20) |
| Correlated failure analysis | Verbatim agreement on the wrong answer, why no aggregation could repair it, one non-LLM fix | Comparative Evaluation (20) |
| Pair log | At least two timestamped role swaps | Writeup, Reflection, and Submission (5) |
| Readme writeup, about two pages | Route named at the top, versions and seeds, Step B.2.2 interpretation answers, Part B.4 table and ownership paragraph, Learning Log | Writeup, Reflection, and Submission (5) |

> **No-code path.** What you submit instead of code: the exported flow or preset prompts and chat transcripts (including at least three refine rounds in place of the Part A log, your calibration table, and your successful reward hack and patch), the spreadsheet of runs and clusters, and the identical written analysis, including the honest verdict on whether the extra rounds bought you anything.

---

## Self-Check Before You Submit

Held against the rubric's `proficient` column.  On the no-code or low-code route, read "code" as "flow or preset configuration" and "log" as "transcript".

- [ ] **Part A:** the loop runs generator, critic, and refiner with a stated stopping rule; every round produces a verdict of **accept** or **revise** as valid JSON, invalid JSON is logged and treated as **revise**, and on budget exhaustion the last draft comes back **with the outstanding critique attached**.
- [ ] A transcript shows at least two complete cycles, with a draft changing in response to a critique.
- [ ] **Calibration:** drafts with planted defects spanning **every** rubric criterion, plus at least two defect-free drafts, with detection rate and **false positive** rate per criterion in a table and the weakest criterion shown before and after its rewrite.
- [ ] The writeup shows a case where the critic was **wrong**, plus how I could tell.
- [ ] **Reward hack:** a working one, shown verbatim, with the critic's "accept" next to my own judgment that the draft is poor; the patch shown as a **diff**; a second transcript showing the patched rubric rejects the hack **and still accepts a defect-free draft**.
- [ ] **Comparison:** fixed tasks, the same scoring instrument on both sides, and a paragraph that says what the loop cost in extra calls for the quality it bought.
- [ ] **Debate:** agents, rounds, and temperature schedule are configurable.
- [ ] Answer extraction anchors on a required `ANSWER:` line, and a missing one produces a located error rather than a silent wrong answer.
- [ ] Both **majority-vote** and **judge-agent** aggregation are available.
- [ ] A complete **3-agent, 2-round** debate transcript is included (or, on the handoff route, the issue thread or the folder listing with timestamps).
- [ ] **Consensus:** k high-temperature drafts, clustered with a **justified** threshold.
- [ ] The synthesizer receives **cluster summaries with support counts**, not all k transcripts.
- [ ] Close disagreements are disclosed in one line of the output.
- [ ] A long-form demonstration is included.
- [ ] **Shootout:** all conditions at **matched call budgets**, on a labeled set of at least ten items.
- [ ] Accuracy and model-call count reported per condition, in a table.
- [ ] At least one **correlated failure** documented with all agents' verbatim responses agreeing on the wrong answer.
- [ ] The writeup explains why no aggregation could have repaired it, and names one **non-LLM** addition that would.
- [ ] Temperatures, round budget, agent count, rounds, temperature schedule, and distance threshold live in a config file.
- [ ] Located exception handlers with tracebacks on model and embedding calls.
- [ ] Pair log with at least two timestamped role swaps.
- [ ] Every reflection answer cites a specific accuracy figure, transcript excerpt, or named failure mode.
- [ ] The route I took is named at the top of the writeup.

---

## Learning Log

Keep a metacognitive learning log for this lab in your readme.  In the spirit of multiple means of action and expression, you may respond to each prompt in prose, in bullet points, or with an annotated diagram, whichever best conveys your thinking.  (Prompt 4 adapts the AI-Assisted Learning Template by Marc Watkins.)

1. **What I built.**  One paragraph, in plain language that a friend outside of computer science could follow (this is deliberate practice in writing for multiple audiences).
2. **What surprised me.**
3. **What I verified and how.**  Evidence, not vibes.
4. **How I used AI during this lab**, and what I learned from that use.
5. **What I'd tell the next student** before they start.
6. **One open question I still have.**

### Lab-specific prompts

- Your critic is an LLM judging an LLM.  At what specific points in this lab did you, the humans, remain indispensable, and what would have gone wrong if you had removed yourselves?  Connect your answer to the broader question of when it is safe to remove humans from an evaluation pipeline.
- Describe the most surprising critic behavior you observed: a missed defect, a phantom defect, or an oscillation (the critic reverses its verdict across rounds without the draft changing).  What does that behavior imply about using this critic in a high-stakes setting?
- Debate and consensus spend extra computation to buy reliability.  Name one decision in your own life where you would pay that cost and one where you would not.  Map each onto a condition from your shootout (single-shot, self-consistency, or debate), and explain what feature of the task, beyond the cost, drives the choice.
- Your synthesizer "follows the majority."  Name a real scenario (in medicine, law, or public policy) where the majority of experts can all be wrong in the same direction, and explain what mechanism (something other than more samples) would be needed to catch that error.
- If collaboration beyond your pair occurred, identify it.  Do you certify that this submission represents your pair's original work?  Please identify any and all portions of your submission that were not originally written by you.
- Approximately how many hours did this lab take (I will not judge you for this at all...I am simply using it to gauge if the assignments are too easy or hard)?

---

## Extension Challenges

These are optional and carry no extra credit.

**Challenge A1 (moderate): Add a revision history log.**  After each round, store the draft and critique in a list.  At the end of the loop, print a table showing how many issues were resolved each round (issues in round N minus issues in round N+1).  Identify which criteria took the most rounds to satisfy.

**Challenge A2 (harder): Multi-agent cross-critique.**  Instead of one critic, use two critics with different system prompts (one strict, one lenient).  Accept a draft only when both critics agree on "accept."  Measure how this changes the average rounds-to-acceptance and the quality of accepted drafts.

**Challenge A3 (hardest): Self-referential calibration.**  Use your loop to generate and refine its own rubric: start with a vague rubric, ask the critic "is this rubric's criterion C1 observable enough to detect without ambiguity?", and refine criterion descriptors until the critic accepts the rubric as well-specified.  Then run Step A.6's calibration on the auto-refined rubric and compare its detection rates to your manually-refined rubric.

**Challenge B1 (moderate): Implement a judge agent.**  Instead of majority vote, add an aggregation option that sends all final-round debate answers to a judge agent (a separate model call) that chooses the best answer and explains why.  Compare the judge's accuracy to majority vote on your task set.  Does the judge ever pick the minority answer, and when it does, is it usually right or wrong?

**Challenge B2 (harder): Adaptive sampling.**  In the consensus pipeline, start with 3 samples.  If all 3 land in one cluster, you are done.  If they span more than 2 clusters, sample 3 more.  Continue until either a clear majority cluster exists or you hit a call budget of 9.  Measure whether adaptive sampling reduces average cost while maintaining accuracy compared to always sampling 6.

**Challenge B3 (hardest): Cross-architecture comparison.**  Run the same 10-task shootout using a second model available via `ollama pull` (e.g., `mistral` or `phi3`).  Compare both models across all three conditions.  Do the two models have different correlated failure patterns?  Does combining agents from two different model families reduce correlated failures compared to using the same model for all agents?

---

## Where the Coding-Agent Work Went

Earlier versions of the critique-and-refine half of this lab carried a "Coding Agents in Practice" direction, in which a coding agent stood in as the generator and you critiqued its diff.  That material is now its own lab, [OpenCode Studio]({{ site.baseurl }}/Assignments/OpenCodeStudio), handed out in Week 2, so that it can be taught before you need it rather than after.  The discipline is the same one you build in Part A: read the output against a written specification, sort the findings into categories, and drive one precise refine turn from those categories.
