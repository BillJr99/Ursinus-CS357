<!--
author:   William Mongan
language: en
narrator: US English Male

comment: Render with https://liascript.github.io/course/?https://github.com/BillJr99/Ursinus-CS357-Fall2026/blob/gh-pages/_pages/Activities/liascript-orchestrationworkshop.md or locally via https://www.billmongan.com/LiaScript/?https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/_pages/Activities/liascript-orchestrationworkshop.md

import: https://raw.githubusercontent.com/LiaTemplates/Pyodide/master/README.md

link:   https://cdn.jsdelivr.net/gh/BillJr99/Ursinus-Boilerplate-Assets@main/css/liascript-custom.css?v=2025-08-23-4
        https://fonts.googleapis.com/css2?family=Lexend+Deca&display=swap

-->

# Orchestration and Multi-Agent Patterns

Unit 3 starts here.  In *Agents That Talk, Observability, and Handoff Protocols*, two agents passed work through a channel, and we traced what each one did.  Now, instead of making one agent smarter, we have several simple agents work together.  This works for the reason we saw in *Memory and the Small Context Window Principle*: a model with one narrow job and a short prompt does better than the same model juggling five jobs in a long one.  We go from **why we decompose → the pipeline → the router → the planner → loops that recover → the supervisor loop**, and then we build three of those patterns on **one task**, end to end, printing every intermediate output.

That task is a nightly club digest: five raw messages in, one short digest out, with every day and time intact.  Running one task through all three patterns lets you compare them on the two things the [Multi-Agent Patterns lab](https://www.billmongan.com/Ursinus-CS357-Fall2026/Assignments/MultiAgentDebate) grades: whether the loop stopped for a stated reason, and how many model calls it spent getting there.  The worked example first runs in this page with a scripted stand-in for the model, so every run repeats exactly and you can make every stop condition fire on purpose.  Then you swap in Ollama by changing one function and run the same code on your machine, or you run the same protocol by hand on the lab's no-code route.

**Today:** I hand out the [Multi-Agent Patterns lab](https://www.billmongan.com/Ursinus-CS357-Fall2026/Assignments/MultiAgentDebate), due Thursday, December 3.  Keep the [RAG Knowledge Base lab](https://www.billmongan.com/Ursinus-CS357-Fall2026/Assignments/RAGKnowledgeBase) and your Literature Review annotated bibliographies moving: the lab is due Tuesday, November 17, and the bibliographies are due Thursday, November 19.

---

## Directions and Group Roles

Work in your POGIL (Process Oriented Guided Inquiry Learning) team with your rotated roles (**Manager**, **Recorder**, **Presenter**, **Reflector**).

- **Manager:** asks for a prediction before every cell runs, especially the number of model calls.
- **Recorder:** keeps the team's answers to the questions and the cost table (Checkpoint 4).
- **Presenter:** reports which stop condition fired in the team's run on a real model.
- **Reflector:** watches for any decision the team handed to the model that a line of code could have made instead.

Work through the models and questions together and keep your answers, because the worked example comes back to them by number.  After class, answer the reflection prompt on your own in your notebook.

---

## Key Concepts

| Term | Plain-English Definition | Where You See It |
|---|---|---|
| **Orchestrator** | An agent, or a piece of code, that coordinates other agents: it decides which agent gets which task, in what order, and how their outputs combine.  It manages the work rather than doing it. | A campus event system that sends announcements to an ExtractAgent, then a DraftAgent, then a PolishAgent |
| **Subagent** | A specialized agent that takes one narrow task from the orchestrator, finishes it, and returns the result.  It usually knows nothing about the larger workflow. | The PolishAgent, which sees only a draft and returns a polished version |
| **Fixed pipeline** | A sequence of model calls whose order you wrote before the run; each stage sees only the previous stage's output | extract, draft, polish (Part II and Step 1) |
| **Seam** | The boundary between two agents, where one agent's output becomes the next agent's input.  Most multi-agent bugs live here, because small differences in format or content compound down a pipeline. | A JSON field the next stage expects but the previous stage left out |
| **Check in code** | A test written in ordinary code at a seam, for a property a program can verify without a model | `check_times`, which confirms every day and time survived |
| **Router** | One classification into a closed set of labels, then a dispatch to one specialist; anything outside the set fails closed to a person | A help-desk router (Part II) and a message router (Step 2) |
| **Planner** | A pattern in which a planning agent writes the step list at runtime, because the steps cannot be known in advance; workers carry out the steps, and the planner revises the plan when a worker reports a failure | "Plan my study schedule for finals, and adjust it as I report which topics I have finished." |
| **Supervisor loop** | A loop in which a model chooses the next sub-agent each turn, or stops | Part IV and Step 3, `supervise` |
| **Roster** | The fixed menu of sub-agents the supervisor may call; an unknown name is refused | `ROSTER` |
| **Budget** | A hard ceiling on turns, set in configuration rather than in the prompt, so a confused loop cannot run forever | `SPAWN_BUDGET` and `CONFIG["spawn_budget"]` |
| **Stop condition** | A rule in your code that ends the loop for a named reason: done and checked, malformed decision, repeated call, or budget reached | The four `return` lines in Step 3's `supervise` |
| **Fail closed** | When output cannot be parsed or trusted, stop or hand it to a person instead of guessing | The malformed-decision stop and the router's `needs_human` |

---

### Before You Start

**Have ready:** for the code route in Part VI, Ollama with `llama3.2` pulled and Python with `requests` installed (the setup from the lab's Step 0.2).  For the no-code route, Open WebUI or Langflow pointed at your local Ollama, as the lab's *Choose Your Path* describes.  The worked example in Part V needs nothing; its cells run in this page.

**Run the Part V cells in order.**  Each cell uses what the cell before it built.  If a cell reports a `NameError`, run the cells above it first.  The code cells in Parts II and IV are marked to run on your own machine; the page does not run them.

---

## Today's Plan

1. Part I, decomposition: when one agent should become several (Model 1)
2. Part II, a pipeline and a router in code, and the seams between them (Model 2)
3. Part III, loops that recover: loop architectures, safety controls, and knowing when to stop
4. Part IV, the supervisor loop: what changes when a model, not you, decides the control flow (Models 3 and 4)
5. Part V, the worked example: one task through a pipeline, a router, and a supervisor, with the cost table (Checkpoints 1 to 4)
6. Part VI, the same code on a real model, or the same protocol by hand on the no-code route (Checkpoint 5)
7. Part VII, reflection and recovery (Model 5), the exercises, and the lab handout

---
# Part I: Decomposition

## 1.  Three Foundational Patterns

**Why this matters:** you have already felt this once.  Narrow roles and clear handoffs kept the persona pipeline's four stages small and easy to inspect.  Here we give that pattern its name, add the router and the planner beside it, and then hand the control-flow decision itself to a model.

**Pipeline (a fixed sequence).**  Each stage's output is the next stage's input: extract → draft → polish.  Each stage has its own short system prompt and sees *only* what it needs.  Pipelines are predictable, cheap, and easy to debug, because you can inspect any intermediate output.  They are the right default when you know the workflow in advance.

**Router (one decision, then a dispatch).**  A classifier agent reads the input and sends it to one of several specialists: billing questions to the billing agent, technical questions to the technical agent.  The router's whole context is the input plus the list of destinations, which is about as small as a context gets.  It stays reliable when you limit its output to a closed set of labels.

**Planner (decomposition at runtime).**  When you do *not* know the workflow in advance, a planner agent writes a step list, worker agents carry out the steps, and the planner revises the list when a step fails.  A planner trades predictability for flexibility, so we bound it with a step budget, which *Part III: Loops That Recover* covers in depth.

Those are the three patterns this deck builds.  Two more fixed shapes belong in your vocabulary now, because your project designs will reach for them.  Here are all five, with where each one is covered in full:

| Shape | What it does | Who decides the control flow | Where you meet it |
|---|---|---|---|
| **Pipeline** | A fixed sequence; each stage's output is the next stage's input | You, before runtime | Part II, `digest_pipeline` |
| **Router** | One classification, then a dispatch to exactly one specialist | You; the classifier only picks a label from a closed set | Part II, `route()` |
| **Fan-out / gather** | N independent subtasks run separately, then one aggregator merges the results | You; the branches are independent by design | Going Deeper, section 5c |
| **Critique-refine** | A generator and a critic loop until the critic passes the work or a revision budget runs out | You; the loop is bounded | *Critique, Consensus, and the LLM Judge: One Loop, Three Uses* |
| **Debate / consensus** | Several agents answer independently, and a fixed rule (majority vote, clustering) picks the result | You; the aggregation rule is fixed | the same session |

The planner is left out of that table on purpose, because a model, not you, decides its control flow.  Part IV takes that up as the supervisor loop.  Critique-refine and debate get their own session, so for now you only need to recognize them and know that both are still fixed shapes you could draw on a whiteboard before a run.

All of this leads to one design rule: **choose the least dynamic pattern that solves the problem.**  Pipelines before routers, routers before planners, and planners before free-roaming autonomy.

> **You have already built the first one.**  In *Prompt Engineering as Agent Design* you ran `persona_pipeline.py`, a four-step chain.  One model answered four times, and each call carried three things of its own:
>
> - a persona,
> - a temperature, and
> - an answer to one question: what may this step read?
>
> That chain is the pipeline row of the table above, and it delivered what the row promises.  Every stage saw only what it needed.  The `sees` list in a configuration file enforced that isolation; the code never asked the model to respect it.
>
> So this is not your first pipeline, but carry one difference forward.  There, you wrote the order as a list before the run.  Here, and above all in the planner, something else decides the order.  Everything this deck adds lives in that gap.
>
> The program is in [persona-pipeline-starter.zip](https://www.billmongan.com/Ursinus-CS357-Fall2026/files/persona-pipeline-starter.zip), and the reasoning behind each decision in it is in the [Persona Pipeline tutorial](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/PersonaPipeline).

---

## Model 1: Match the Pattern

| Task | Best Pattern? |
|------|---------------|
| Every night, summarize the day's club announcements into one digest email draft. | ? |
| Triage incoming help-desk tickets to hardware, software, or accounts queues. | ? |
| "Plan my study schedule for finals, adapting if I fall behind on a topic." | ? |

### Critical Thinking Questions

1.  Assign a pattern (pipeline, router, or planner) to each task, and justify each choice in one sentence using the design rule above.

   > *Hint: For each task, ask whether you know the sequence of steps before the task starts.  If so, consider a pipeline.  Is the task a single classification?  Then consider a router.  Does the workflow have to change based on what happens while it runs?  Then consider a planner.*

2.  In the triage task, the router sometimes invents a fourth category that is not on its list.  Give two different fixes: one that changes only the system prompt, and one that changes only the surrounding Python code and leaves the prompt alone.

   > *Hint: The prompt fix should make the closed set explicit and unambiguous.  The code fix should intercept whatever label the model returns and keep anything outside the set from going through; the code below already does part of this.  Which of the two is more reliable, and why?*

3.  In the digest pipeline, name the intermediate output that passes from the Extract stage to the Draft stage.  Explain how inspecting it helps you find where a quality bug came from, compared with debugging one large prompt that does everything at once.

   > *Hint: If the final digest has wrong information, a pipeline lets you check whether the extracted facts were wrong (a bad Extract stage) or whether the facts were right and the draft misused them (a bad Draft stage).  How would you diagnose the same problem in a single large prompt?*

---

# Part II: A Pipeline and a Router in Code

## 2.  Small Agents, Explicit Seams

**Why this matters:** the code below shows the main property of a well-designed orchestration: each agent's system prompt is one sentence long.  That is deliberate.  A one-sentence context has no competing concerns to distract the model.  Each agent does one thing and returns a result, and the orchestrator passes that result, unchanged, to the next agent.  The seams between agents are where the data flows, and they matter most, because a small error at a seam (a wrong JSON key, a missing field, an unexpected format) travels silently through the rest of the pipeline.

You can run this code on your own machine.  Start the model with `ollama run llama3.2`, then run the script in a second terminal:

```bash
# Start the local model server (do this once)
ollama run llama3.2

# In a second terminal, run your orchestration script
python orchestration.py
```

---

## Code Cell

The code below builds a three-stage pipeline (extract, draft, polish) and a two-stage router (classify, then dispatch) on a local language model.  Read the comments before you run it; each one explains a design choice the questions that follow ask about.

> **Runs on your machine, not here.**  This cell talks to the Ollama server on your own laptop at `localhost:11434`, which a web page cannot reach.  Copy it into your course container and run it there.

<!-- run: id=cs357-liascript-orchestrationworkshop-2 viz=agent record -->
```python
import requests

def llm(system, user, temperature=0.0):
    """
    Call a locally running LLM via Ollama.
    system: the agent's role and constraints (kept short on purpose)
    user:   the actual input this agent should process
    temperature=0.0: deterministic output for predictable pipelines
    """
    try:
        r = requests.post("http://localhost:11434/api/chat", json={
            "model": "llama3.2", "stream": False,
            "options": {"temperature": temperature, "seed": 42},
            "messages": [{"role": "system", "content": system},
                         {"role": "user", "content": user}]}, timeout=120)
        return r.json()["message"]["content"].strip()
    except Exception as e:
        print(f"[orchestration:llm] {e}")
        import traceback; traceback.print_exc()
        return ""

# --- Pipeline: extract -> draft -> polish ---
# Each stage sees only what it needs; intermediate outputs are inspectable.

def digest_pipeline(raw_announcements):
    # Stage 1: Extract structured facts from raw text
    # Output: one line per event, in a predictable format
    facts = llm(
        "Extract every event as 'name | date | location', one per line. Output only the lines.",
        raw_announcements
    )
    # Stage 2: Draft a human-readable summary from the structured facts
    # Note: the draft stage never sees the raw announcements, only the extracted facts
    draft = llm(
        "Write a friendly 3-sentence digest of these events for students.",
        facts
    )
    # Stage 3: Polish for length and tone
    final = llm(
        "Edit for concision and warmth. Keep under 60 words.",
        draft
    )
    return facts, draft, final  # return all intermediates for inspection and debugging

raw = (
    "The chess club meets Thursday at 7 in Olin 107. "
    "Hawk Hacks is Saturday 10am in IDDC. Bring laptops! "
    "Ultimate frisbee pickup moved to Sunday 2pm on the quad."
)
facts, draft, final = digest_pipeline(raw)
print("EXTRACTED FACTS:\n", facts)
print("\nDRAFT:\n", draft)
print("\nFINAL DIGEST:\n", final)

# --- Router: classify input, then dispatch to the right specialist ---
# The router makes ONE decision; the specialist does the actual work.

SPECIALISTS = {
    "hardware": "You fix physical computer problems. Give exactly 2 concrete troubleshooting steps.",
    "software": "You fix application and software problems. Give exactly 2 concrete steps.",
    "accounts": "You handle login, password, and account access issues. Give exactly 2 concrete steps.",
}

def route(ticket):
    # Router: classify into exactly one of the allowed labels
    # The closed-set guard below handles cases where the model invents a new category
    label = llm(
        "Classify the ticket as exactly one word: hardware, software, or accounts. Output only that word.",
        ticket
    ).lower()
    # Guard: if the model returns something unexpected, default to "software"
    # This is a code-level fix; a prompt-level fix would say "output ONLY one of these three words"
    label = label if label in SPECIALISTS else "software"
    # Dispatch to the appropriate specialist
    response = llm(SPECIALISTS[label], ticket)
    return label, response

for ticket in [
    "My laptop screen flickers and goes completely black after five minutes.",
    "I cannot log into the campus portal after the password reset last night."
]:
    label, response = route(ticket)
    print(f"\n[Category: {label}]\nTicket: {ticket}\nResponse: {response}")
```
[Visualize this example](https://billjr99.github.io/Ursinus-CS357-Fall2026/viz/#cs357-liascript-orchestrationworkshop-2) <!-- code-viz link -->

---

## Model 2: Reading the Seams

### Critical Thinking Questions

4.  Each `llm` call in the pipeline has a one-sentence system prompt and sees only its own input.  Connect that choice to the "lost in the middle" finding from the memory module: models fail to use information that sits in the middle of a long context.

   > *Hint: If one large prompt held all three jobs (extract, draft, and polish), how long would it be?  Where would the "polish for concision" instruction sit relative to the raw announcements?  What does the lost-in-the-middle finding predict about how well the model would follow it?*

5.  The router's guard, `label if label in SPECIALISTS else "software"`, quietly picks a default when the model returns an unexpected label.  Argue for or against that silent default.  Then describe what a louder failure would look like, and when you would prefer it.

   > *Hint: With a silent default, a ticket that belongs in "accounts" goes to "software," and nobody learns that the classification failed.  A louder failure would log the error, send an alert, or raise an exception.  When does silence protect the user's experience, and when does it hide a bug?*

6.  The polish stage can introduce errors the extract stage never made, for example by changing "Thursday at 7" to "Friday at 7" while editing for concision.  Where in the pipeline would you add a verification step, and which tool or pattern from earlier in the course would you reuse for it?

   > *Hint: Think about the critique-and-refine pattern.  Could a "verify" stage after "polish" check the final output against the extracted facts?  What would its one-sentence system prompt say?*

> **Common Misconception:** Many students assume that a pipeline is more reliable than a single agent because it has more agents.  It is not, automatically.  A pipeline can fail at any seam, and because each agent works from the previous agent's output rather than the original input, errors can compound without anyone noticing.  A pipeline is easier to maintain and debug than one large prompt, but only if you actually inspect the intermediate outputs.  Return every intermediate from your pipeline functions, as the code above does with `return facts, draft, final`, and check them.

By the design rule in this deck, a team should reach for a planner agent only when:

[( )] The task involves more than two steps
[( )] Maximum autonomy is a project goal
[(X)] The sequence of steps cannot be determined before runtime
[( )] The budget allows a larger model

---

# Part III: Loops That Recover

Orchestration decides who runs next.  This part is about what happens when one of them fails, which is the more common case in production: the loop architectures, the safety controls that bound them, and the harder-than-it-sounds question of how an agent knows it is finished.

## Four Loop Architectures

**Why this matters:** self-correction makes agents much more reliable on real tasks.  A surgeon checks the patient's vital signs after each incision before going on, and that feedback catches a problem before it spreads.  ReAct gives an agent the same property: because it writes out its reasoning before each action, it can catch its own mistakes partway through rather than only at the end.  Reflexion goes further and lets an agent learn from a whole failed attempt.  With these patterns, an agent works a problem over several tries instead of guessing once.

These patterns can be combined.  Production systems often layer them: an outer ReAct loop, with a Reflexion pass now and then, and Tree-of-Thought for the steps that are most ambiguous.

| Pattern | Core Idea | When to Use It | Primary Failure Mode |
|---------|-----------|----------------|----------------------|
| **Simple Loop** | Act once, observe the result, and repeat until a "done" signal arrives or a step limit is reached. | Short, well-defined tasks where you know the loop will end quickly and reliably. | An infinite loop when the done signal never fires: the agent runs forever and spends an unbounded API budget. |
| **ReAct** (Yao et al., 2022) | Before every action, write a "Thought:" that explains the reasoning, then an "Action:", then observe the result.  The reasoning stays in the context, where a person can inspect it. | Multi-step tasks that reason over tool outputs, where you want the agent's logic to be auditable. | The context window fills before the task is done, earlier reasoning is cut off, and the agent loses track of what it has already done. |
| **Reflexion** (Shinn et al., 2023) | After each complete attempt, the agent writes a "lesson" critiquing its own trajectory and stores it in episodic memory.  The next attempt starts with those lessons loaded. | Tasks with a clear success or failure signal you can measure afterward, and tasks you expect to run many times. | Every lesson adds tokens to the context, and if the agent judges itself poorly, it stores bad lessons that make later runs worse. |
| **Tree-of-Thought** (Yao et al., 2023) | At each step, branch into k candidate next actions, score each one with a separate LLM call, and expand only the best-scoring branch. | Tasks where early choices are hard to undo and the quality of the plan matters more than speed or cost. | It costs k times as many calls per step as a simple loop; for k = 3 and a 10-step task, that is 30 scoring calls on top of the main calls. |

**The inner loop and the outer loop.**  The *inner loop* is the model generating the tokens of one completion, which is deterministic for a fixed temperature and seed.  The *outer loop* is the agent choosing actions, calling tools, and updating its context, which is random and long-running.  Most failures happen in the outer loop, but most of the compute cost is in the inner loop.

### Critical Thinking Questions

7.  A ReAct agent is working on a ten-step research task.  Each step adds about 800 tokens to the context (thought, action, and observation).  The model's context window is 32,000 tokens.  At what step does the agent risk running out of context, and what can it do at that point?

   > *Hint: Divide the window size by the tokens per step.  Then, if the agent has to summarize earlier content to make room, what is most important to keep: the most recent steps, the earliest steps, or something else?*

8.  Reflexion stores lessons in episodic memory between runs.  How does a lesson stored in memory differ from a change to the agent's system prompt, and when would you prefer each?

   > *Hint: A system prompt change affects every future run, permanently.  A memory entry lasts until it is cleared or overridden.  If your ResearchAgent keeps making the same mistake, which mechanism fits better, and what would make you choose the other?*

9.  Tree-of-Thought scores k branches at each step with an LLM judge.  If k = 3 and the task has 5 steps, how many LLM calls does the agent make in the worst case, with every branch scored at every step?  Compare that with a simple loop over the same 5 steps.

   > *Hint: Each step generates 3 branches and scores 3 branches, for 6 calls.  Multiply by 5 steps and compare with the simple loop's 5 calls.  When is six times the cost worth paying?*

---

## A ReAct Trace: Five Steps in Detail

**Why this matters:** reading a real ReAct trace makes the pattern concrete.  The agent is not calling tools at random; each "Thought:" records a decision about what to do next, based on what it just observed.  That is why ReAct traces help with debugging: you can read the reasoning at each step and find the exact point where the agent made a wrong assumption or missed something.

The task: *"Find the three most-cited papers on transformer self-attention published before 2020 and list their citation counts."*

| Step | Thought | Action | Observation | Next Thought |
|------|---------|--------|-------------|--------------|
| 1 | The task asks for citation data. I should search Semantic Scholar, which has an API for academic papers and returns citation counts. I will start with a broad search and filter by year. | `search_papers(query="transformer self-attention", year_max=2019, limit=10)` | Returns 10 papers with titles and Semantic Scholar IDs, but no citation counts are included in the search response. | Citation counts require a separate API call per paper ID. I have 10 IDs. I will look up the most likely candidates by title first rather than fetching all 10 counts. |
| 2 | "Attention Is All You Need" (Vaswani et al., 2017) is almost certainly the most-cited transformer paper. I will fetch its citation count first as a baseline. | `get_paper_citations(paper_id="204e3073870fae3d05bcbc2f6a8e263d9b72e776")` | Returns: 97,432 citations as of today's date. | That is the most-cited paper. Now I will fetch the BERT paper, which is also transformer-based and pre-2020. |
| 3 | BERT (Devlin et al., 2018) is a major transformer paper published before 2020. I will retrieve its citation count next. | `get_paper_citations(paper_id="df2b0e26d0599ce3e70df8a9da02e51594e0e992")` | Returns: 51,618 citations. | Two papers found with counts. I need a third. The search results include "Universal Language Model Fine-Tuning (ULMFiT)" by Howard and Ruder (2018); I will check it. |
| 4 | ULMFiT is a 2018 NLP transfer learning paper. It appeared in the top 10 search results, making it a reasonable candidate for third most-cited. | `get_paper_citations(paper_id="1e077413b25c4d68cd0a8e6e8e42fcc50c85db7a")` | Returns: 4,441 citations. | I now have three papers with citation counts: 97,432; 51,618; 4,441. I can compile and return the final answer. All sub-goals are satisfied. |
| 5 | I have all data needed to answer the task. No more tool calls are required. The three papers are identified and their citation counts are verified from the API. | *(No tool call, generating final answer text)* | - | Task complete. Returning the three papers and their citation counts to the user. |

At step 1, the agent sees that it needs two separate API calls instead of assuming one call returns everything.  At step 5, it ends because it has met every sub-goal, not because it reached a step limit.  Step 4, though, is a flawed choice: ULMFiT is built on an LSTM language model, not a transformer, so it does not meet the task's "transformer self-attention" requirement at all.  The Thought sounds reasonable while it quietly drops a constraint, which is why the misconception below matters.

### Critical Thinking Questions

10.  At step 4, the agent picked the third candidate by a rule of thumb ("ULMFiT appeared in the top 10 results").  A more careful approach would fetch the citation counts for all 10 papers from step 1 and sort them.  What do you trade between the rule of thumb (fewer steps, lower cost) and the exhaustive approach (a guaranteed answer)?

    > *Hint: The rule of thumb reaches step 5 in 4 API calls.  The exhaustive approach needs 10 citation lookups plus 1 search, or 11 calls.  For this task, which would you choose, and what would change your answer?*

11.  Rewrite step 4 assuming the API call fails with a timeout (HTTP 408).  What belongs in the "Next Thought" column?  Write the full Thought the agent should produce to handle this without abandoning the task or repeating the call that just timed out.

    > *Hint: The agent should (a) acknowledge the failure, (b) decide whether to retry or try another approach, and (c) have a fallback.  What is a good fallback if the Semantic Scholar API is down?*

12.  In this trace, the agent stops because it judged at step 5 that it was finished.  Name two ways the original task could have been written to make that stop more reliable, without depending on the agent's own sense that it is "done."

    > *Hint: What machine-checkable requirement could the task include?  For example, instead of "find three papers," what if the task named a property each paper must have that a program could verify?*

> **Common Misconception:** Students often assume a ReAct trace is a log of what the model "really thought," that the `Thought:` entries are genuine inner reasoning.  They are not.  The `Thought:` entries are generated text, just like the `Action:` entries.  The model writes them because the ReAct prompt tells it to, not because they reflect a separate internal deliberation.  A model can therefore write a confident `Thought:` that is wrong, or that contradicts its own next step.  ReAct traces help with debugging and auditing because they make the agent's reasoning *visible and checkable*, but being visible does not make it correct.  Check the key claims in each Thought against the observations they rest on.

Now that you have walked through a ReAct loop step by step, the next section looks at what can go wrong when such a loop runs unsupervised, and at the engineering controls that prevent it.

---

## Loop Safety Controls

This section covers six engineering controls that keep agent loops safe in production.  They matter because a loop that works perfectly in testing can still run out of control on real, messy inputs.

**Why this matters:** even a well-designed ReAct loop can fail in ways that are expensive, embarrassing, or harmful.  These controls work like circuit breakers in a building's wiring: they do not prevent every failure, but they keep a small failure from turning into a large one.  Circuit breakers are not optional in buildings, and these controls are not optional in production agent systems.  Every agent that runs unsupervised in the real world needs at least a step limit and a gate that escalates to a person.

| Control | Implementation | What It Prevents |
|---------|----------------|------------------|
| **Max iterations** | `if step >= MAX_STEPS: return partial_result`, a hard ceiling on loop iterations, whether or not the agent thinks it is done. | Infinite loops and runaway API costs that can use up a budget in minutes. |
| **Token budget check** | Before each LLM call, check `tokens_used + estimated_next_tokens < context_limit`, and compress the context if it does not fit. | Context overflow and reasoning cut off mid-thought, which produces incoherent or dangerous output. |
| **Idempotency check** | Keep a set of the `(action_name, args_hash)` pairs seen so far; if the current action matches one, flag it as possible oscillation instead of running it again. | Oscillation: an agent alternating between two actions forever, spending tokens and budget without progress. |
| **Confidence threshold** | `if agent.confidence < THRESHOLD: escalate_to_human()`: if the agent rates its own certainty below a set level, it pauses and asks a person instead of acting on a guess. | An agent acting on a low-confidence guess when being wrong is costly. |
| **Human escalation gate** | `if action.is_irreversible() and uncertainty > 0.3: pause_and_notify()`: before any write, delete, send, or purchase that carries real uncertainty, stop and ask a person to approve it. | Irreversible harm from a low-confidence or misunderstood instruction. |
| **Checkpointing** | `state.save(step, context, memory, external_actions)`: after each action finishes, save the full state to disk or a database. | Lost progress on long tasks after a crash, a timeout, or an infrastructure failure. |

**Idempotency and oscillation** deserve a closer look.  An agent oscillates when it alternates between two actions: `search("climate data")` finds nothing new, so it calls `refine_query("climate data 2024")`, which finds nothing new, so it calls `search("climate data")` again.  The idempotency check stores a hash of `(action_name, args)` and flags the repeat.

**Checkpointing** lets a loop pick up after a failure.  The checkpoint stores the full context window, the history of tool calls, and any outside state (files written, IDs retrieved).  On restart, the agent resumes from the last checkpoint instead of from zero.  This matters most for tasks that take hours or make expensive API calls.

### Critical Thinking Questions

13.  The idempotency check compares `(action, args)` hashes.  An agent calls `search("transformer attention mechanisms")` at step 2 and gets 5 results.  It calls other tools, and at step 8 it calls `search("transformer attention mechanisms")` again, hoping the search index has newer results.  Is that true oscillation or a legitimate repeat query?  How would you change the idempotency check to allow legitimate repeats while still catching oscillation?

    > *Hint: What separates a legitimate repeat from an oscillation: the time that has passed, the number of actions in between, or the agent's stated reason for repeating?  Which of those can a program check?*

14.  A checkpointed agent resumes at step 7 after a crash.  Steps 1 to 6 included writing a file to a cloud storage bucket.  When it resumes, should the agent confirm that the file exists before going on, or trust the checkpoint's record of what it did?  Make the strongest case you can for one answer.

    > *Hint: Consider two cases: (a) the write succeeded and the crash came afterward; (b) the write appeared to succeed but failed silently because of a network problem.  Which case is more dangerous to get wrong, and does that change your answer?*

15.  The token budget check estimates the cost of the next call before making it.  Why estimate, rather than just letting the API call fail when the context is too long?

    > *Hint: What happens when a context window overflows depends on the server.  Many hosted APIs reject the request with an error, which stops the loop partway through the task.  Some local servers and client libraries cut the input instead, often from the start of the context, without telling you.  If that cut removes the task description or the early reasoning, what happens to the quality of the answer?  Is a silently cut context more dangerous than a budget failure you detect, and is an error partway through any better than planning ahead?*

---

## Termination: How Does an Agent Know It Is Done?

This section compares three ways to define "done" for an agent, and you practice rewriting task specifications so that the agent stops more reliably.  It builds on the safety controls above: a clear stopping rule is what gives the max-iterations control its meaning.

**Why this matters:** "done" sounds obvious, but it is hard to define for an AI agent.  A traditional program returns when a function exits.  An agent generates text in a loop and has to decide for itself when to stop.  Get this wrong in one direction and the agent quits early with the work unfinished; get it wrong in the other and you get a "perfectionism spiral," an agent that keeps polishing forever.  Knowing the three approaches lets you choose the right one for your task.

This is one of the hardest problems in agent design.  There are three approaches:

**An explicit stop condition.**  The task specification includes a success criterion a program can check.  For example: *"Return when you have found exactly 3 papers and each has a citation count above 1,000."*  The agent checks the criterion against the data it has collected, not against its own sense of being done.

**Self-assessed completion.**  The agent emits a `DONE` token or calls a `finish()` tool when it believes the task is complete.  The ReAct trace above works this way.  The risk is that the agent declares completion too early (believing it answered the question when it did not) or never (the perfectionism spiral, where it keeps improving the answer without stopping).

**Budget exhaustion.**  The outer loop ends when a budget (steps, tokens, dollars, or wall-clock time) runs out, and it returns whatever partial result exists at that point.  This is reliable and predictable, but on a complex task it may return unfinished work.

Production systems usually combine all three: an explicit criterion when one is possible, self-assessment as the main signal, and budget exhaustion as a hard fallback.  The point to keep is that **"done" is a property of the task specification, not of the agent's internal state**.

### Critical Thinking Questions

16.  An agent is asked to *"Write a complete test suite for this Python module."*  The task gives no count of required tests.  The agent writes 12 tests and declares itself done.  How would you rewrite the task to give the agent a more checkable stopping criterion without dictating the solution?

    > *Hint: Which properties of a test suite can a program verify?  Coverage percentage?  A test for each public function?  At least one edge case per function?  Pick a criterion a program can check that does not tell the agent how to write the tests.*

17.  In a "perfectionism spiral," an agent keeps improving its output and never declares that it is finished.  Describe what this failure looks like in the ReAct trace format (write out the `Thought:` entries across five consecutive steps), and name the control from the Loop Safety Controls table that breaks the cycle.

    > *Hint: In a perfectionism spiral, each Thought says something like "The draft is good, but it could be improved by..." even when the draft is already strong.  Which control puts a hard ceiling on how long that can go on?*

---

## Multiple Choice Checkpoint

A ReAct agent is on step 18 of a task.  Its context window shows 28,000 of 32,000 tokens used.  It decides to call a tool that usually returns a 6,000-token observation.  What should it do before making that call?

[( )] Make the tool call and let the API truncate the response automatically
[( )] Immediately terminate the task and return the partial result
[(X)] Summarize or compress earlier context to free token budget before making the tool call
[( )] Switch to Tree-of-Thought because it uses fewer tokens

---

# Part IV: The Supervisor Loop

Everything so far is *fixed* orchestration: the pipeline, the router, and even the recovery and reflection loops in Part III.  **You** wrote the control flow before the run started, and no run can take a path you did not write.  This part asks what changes when that is no longer true.  It gives you a working supervisor loop, about ten lines long, to read, run, and question.

## Model 3: Two Families of Orchestration

**Why this matters:** a fixed pipeline is a commuter train.  It makes the same stops in the same order every day, and you can print the timetable a year ahead.  Dynamic orchestration is a taxi whose driver picks the route while driving, going around traffic nobody could have predicted.  The train is boring, cheap, and easy to audit: if a passenger ends up in the wrong place, you know which segment failed.  The taxi is flexible and handles trips no timetable planned for, but you cannot promise, before the trip starts, which streets it will take.  Neither is better; they answer different questions.

**Family 1: fixed (known) orchestration.**  *You*, the developer, wire a predetermined graph of agents.  The nodes and edges are set before any input arrives, and the control flow lives in your Python, not in a model's output.  The pipeline and the router from Parts I and II both belong here.  Their strengths are the ones you have already seen: predictability, debugging one step at a time (inspect any intermediate output), and a bounded cost (you can count the model calls before you run).

**Family 2: dynamic orchestration.**  The orchestrator, often called a **supervisor**, is itself an LLM.  You give it the task and a *roster* of available sub-agents, and on each turn *it* decides which sub-agent to run, whether to start a new one for a subtask it just discovered, or whether the work is done.  The control flow is now a model's *output*, not your code.  Its strengths mirror Family 1's: flexibility, open-endedness, and the ability to handle tasks whose shape you could not list in advance.  So do its costs: unpredictable paths, harder debugging (the answer to "why did it do that?" lives in a prompt), and open-ended spending unless you cap it.

| | Fixed / known orchestration | Dynamic / supervisor orchestration |
|---|---|---|
| Who authors the control flow | The developer, before runtime | An orchestrator LLM, each turn |
| Path through the agents | The same every run (up to loops you bounded) | Chosen at runtime; may differ per input |
| Debugging story | Inspect the intermediate at each fixed seam | Read the supervisor's decisions in a trace |
| Cost | Countable before you run | Open-ended until you impose a budget |
| Best when | The workflow is known in advance | The workflow cannot be enumerated in advance |

This takes Part I's rule (**choose the least dynamic pattern that solves the problem**) one step further: fixed families before dynamic ones, and a *bounded* dynamic supervisor before free-roaming autonomy.

## 3.  Dynamic Orchestration: the Supervisor Loop

When you *cannot* draw the diagram in advance, because the task is open-ended and the sub-agents it needs depend on what earlier ones find, you make the orchestrator itself an LLM.  This is the pattern behind LangGraph's **supervisor** and LangChain's **DeepAgents**, which you use hands-on in the [Agent Frameworks](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/AgentFrameworks) activity.

The mechanism is a loop.  You give the supervisor the task and a **roster**: a menu of sub-agents, and the tools each one may use.  On each turn, the supervisor model reads the task, the roster, and the transcript so far, and emits one *action*: "call sub-agent X on this input," "start a new researcher for this subtask I just found," or "STOP, here is the answer."  Your code carries out the chosen action, appends the result to the transcript, and asks the supervisor again.  DeepAgents adds machinery around this loop (a planning tool that writes a to-do list, sub-agents that run in *isolated context windows* so their scratch work never reaches the main thread, and a synthesis step at the end), but underneath it is the same loop in which the model decides the next move.

Compare it with the fixed families.  A router makes **one** classification and then hands off; a supervisor makes a **new** decision on **every** turn and may keep starting sub-agents.  That is where both its power and its danger come from.

## Code Cell

The sketch below is for reading and running on your own machine, not for production.  It follows the course's `chat(messages)` convention against a local OpenAI-compatible endpoint (for example, Ollama's `/v1`, LM Studio, or a `llama.cpp` server).  Look for the three things that stay *yours* even in a "dynamic" system: the **roster**, the **spawn budget**, and the **stop condition**.

> **Runs on your machine, not here.**  This cell talks to the Ollama server on your own laptop at `localhost:11434`, which a web page cannot reach.  Copy it into your course container and run it there.

<!-- run: id=cs357-liascript-orchestrationworkshop-3 viz=agent record -->
```python
import json, requests

def chat(messages, temperature=0.0):
    """One turn against a local OpenAI-compatible chat endpoint.
    messages: the running list of {"role": ..., "content": ...} dicts.
    Returns the assistant's text. Illustrative; run locally only."""
    r = requests.post("http://localhost:11434/v1/chat/completions", json={
        "model": "llama3.2", "temperature": temperature, "messages": messages,
    }, timeout=120)
    return r.json()["choices"][0]["message"]["content"].strip()

# The ROSTER is YOURS: the fixed menu of sub-agents the supervisor may call.
# Each value is a one-sentence system prompt: the same small-context
# discipline as the pipeline stages in Part II.
ROSTER = {
    "researcher": "You gather facts for a narrow question. Return exactly 3 bullet points.",
    "writer":     "You turn bullet points into one tight paragraph. Output only the paragraph.",
    "critic":     "You list concrete problems with a paragraph, or reply exactly 'OK' if none.",
}

SPAWN_BUDGET = 6   # YOURS: a hard cap on sub-agent calls, the stop condition of last resort.

def supervise(task):
    """The supervisor LLM decides, each turn, which sub-agent to run next, or to STOP."""
    transcript = []
    for _ in range(SPAWN_BUDGET):          # the budget caps runaway spawning
        decision = chat([
            {"role": "system", "content":
                "You are an orchestrator. Choose the next step and reply with ONLY JSON. "
                f"Available sub-agents: {list(ROSTER)}. "
                'Reply {"action":"call","agent":"<name>","input":"<text>"} '
                'to delegate, or {"action":"stop","answer":"<final text>"} when done.'},
            {"role": "user", "content":
                f"TASK: {task}\n\nTRANSCRIPT SO FAR:\n{json.dumps(transcript, indent=2)}"},
        ])
        try:
            step = json.loads(decision)
        except json.JSONDecodeError:
            break                          # malformed decision -> stop safely (YOUR guard)
        if not isinstance(step, dict):
            break                          # valid JSON that is not an object: stop safely too

        if step.get("action") == "stop":
            return step.get("answer", "")  # the supervisor decided the work is done

        agent = step.get("agent")
        if agent not in ROSTER:            # closed-set guard, exactly like the Part II router
            transcript.append({"agent": agent, "error": "unknown sub-agent"})
            continue

        # Dispatch: the sub-agent runs in its OWN tiny context, isolation by construction,
        # so one sub-agent's scratch work never leaks into another's prompt.
        result = chat([
            {"role": "system", "content": ROSTER[agent]},
            {"role": "user",   "content": step.get("input", "")},
        ])
        transcript.append({"agent": agent, "input": step.get("input"), "result": result})

    # Budget exhausted without a STOP: return what we have, and FLAG that we were cut off.
    return f"[stopped: spawn budget of {SPAWN_BUDGET} reached]\n{json.dumps(transcript, indent=2)}"

print(supervise("Write one tight paragraph on why local models matter, then have it reviewed."))
```
[Visualize this example](https://billjr99.github.io/Ursinus-CS357-Fall2026/viz/#cs357-liascript-orchestrationworkshop-3) <!-- code-viz link -->

**What you still own.**  Handing the control flow to a model does *not* hand it your responsibilities.  Three levers stay in your code, and they are the reason a dynamic system is safe to ship:

- **The roster.**  The supervisor can call only the sub-agents you put on the menu.  An empty or overly broad roster is where open-endedness turns into risk.
- **The spawn budget.**  The `for _ in range(SPAWN_BUDGET)` loop puts a hard ceiling on model calls.  Without it, a confused supervisor can keep starting sub-agents forever, spending tokens and time with nothing to show for it.
- **The stop condition.**  The supervisor may declare `"stop"`, but *you* also stop it when the budget runs out, and you flag that outcome instead of presenting the cut-off transcript as a finished answer.

DeepAgents makes these same decisions (when to plan, when to start a sub-agent, when to finish) *inside* its built-in system prompt.  That is why it is so short to use and so much harder to debug when it misbehaves.  When you write the loop yourself, those decisions are visible in ten lines; when a framework writes it, they move into the framework's prompt.

## Model 4: Who Decides Control Flow?

| Pattern | Who decides the control flow | Reach for it when | Main risk |
|---|---|---|---|
| Sequential pipeline | You, before runtime | The steps are known and each refines the last | An error at a seam propagates silently downstream |
| Router / dispatch | You (the classifier only picks a label) | One input, several handlers, exactly one applies | A mis-classification sends the whole task to the wrong specialist |
| Parallel fan-out / gather | You (branches are independent by design) | N independent subtasks whose results combine | The aggregator hides disagreement or drops a branch's result |
| Critique-refine | You (a bounded generator <-> critic loop) | A checkable quality bar that one pass misses | The loop never converges and burns the revision budget |
| Debate / consensus | You (a fixed voting or clustering rule) | Uncertain or subjective answers needing robustness | Correlated agents "agree" on the same wrong answer |
| Supervisor (dynamic) | An orchestrator LLM, each turn | The workflow cannot be enumerated in advance | Runaway spawning and unpredictable, hard-to-audit paths |

### Critical Thinking Questions

18.  A hospital wants an agent system to draft discharge summaries, and it must show a regulator that the process is auditable and treats comparable patients the same way.  Argue why a **fixed** pipeline is easier to certify than a supervisor loop, and name the property of each that a regulator would ask about.

    > *Hint: A regulator asks, "Can you show me, in advance, every path this system can take, and can you reproduce a given run?"  A fixed pipeline takes the same path every time, and you can inspect the intermediate at each seam.  A supervisor's path is a model output that can differ between two similar inputs.  Which property makes "we tested this exact flow" a true statement?*

19.  A supervisor loop gets a vague task, and on each turn it decides to start "one more researcher to be thorough."  Describe the runaway failure this invites, and explain exactly how the `SPAWN_BUDGET` in the Code Cell caps it, including what should happen at the moment the budget runs out.

    > *Hint: Without a ceiling, "one more to be thorough" never has a natural place to stop: cost and delay keep growing while the answer never arrives.  The budget turns an open-ended loop into a bounded one.  But a cap alone is not enough.  Look at the final `return` in the code: why does it put `[stopped: ...]` in front instead of returning the transcript as though it were a finished answer?*

20.  You are handed a new task and have to pick a family before you write any code.  Give one concrete question about the task whose answer decides between a **fixed** shape and a **dynamic supervisor**, and explain why Part I's rule about the least dynamic pattern still applies one level up.

    > *Hint: The deciding question is roughly, "Can I list the sequence (or set) of sub-agents this task needs before it starts?"  If so, a fixed shape is cheaper, more predictable, and easier to debug, so prefer it.  A supervisor earns its unpredictability only when the answer is "no, the steps depend on what we find along the way."  How does choosing a dynamic design when a fixed one would do repeat the mistake Part I's rule warns against?*

> **Common Misconception:** Students often assume that "dynamic orchestration" means the developer no longer controls the system.  For any system you would actually deploy, the opposite is true.  In a supervisor loop the model chooses the *next move*, but you still write the roster it chooses from, the budget that bounds it, and the stop condition that ends it.  Dynamic orchestration moves *some* decisions to the model; it never moves your responsibility for the roster, the budget, and the stop.

Which single property most distinguishes a supervisor (dynamic) orchestrator from a router (fixed)?

[( )] A supervisor uses a larger model than a router
[( )] A router can call tools but a supervisor cannot
[(X)] A router makes one classification decision and then hands off, while a supervisor makes a new control-flow decision on every turn and may spawn additional sub-agents

---

# Part V: Worked Example: One Task Through Three Patterns

## Setup: The Task, the Settings You Own, and the Stand-In

Five messages arrived today.  Three are events for the digest, one is a question that belongs in an FAQ queue, and one is something the categories did not plan for.  `CONFIG` holds the settings you own, outside any prompt, the same way the lab keeps its round budget in `config.json`.  Each of the four system prompts is one sentence, the small-context discipline from Part II.  `llm()` is the one function every pattern calls, and `CALLS` counts every call.

In this page, `llm()` calls `stand_in()`, which follows fixed rules for each role and is not a language model.  It extracts events with a regular expression and writes one sentence per event.  In the polish stage, it makes the mistake Question 6 warned about, on purpose: it changes "Thursday" to "Friday" while editing for concision.  It also returns a label outside the closed set for the pizza message.  Both mistakes are scripted, so you can watch the controls catch them every time.

<!-- run: id=cs357-liascript-orchestrationworkshop-1 viz=env -->
```python
# Setup: the task, the settings you own, and a scripted stand-in for the model.
import json
import re

MESSAGES = [
    "Chess club meets Thursday at 7pm in Olin 107.",
    "Hawk Hacks is Saturday at 10am in IDDC. Bring laptops!",
    "Ultimate frisbee pickup moved to Sunday at 2pm on the quad.",
    "Does anyone know if the library is open late during finals?",
    "Free pizza in the lobby, first come first served.",
]

CONFIG = {"spawn_budget": 6, "temperature": 0.0, "seed": 42}   # yours, not the model's

EXTRACT = "Extract every event as 'name | day | time | place', one per line. Output only the lines."
DRAFT   = "Write a friendly digest of these events for students, one sentence per event."
POLISH  = "Edit the digest for concision and warmth. Keep every day and time."
CLASSIFY = "Classify the message as exactly one word: event, change, or question. Output only that word."

EVENT = re.compile(r"^(?P<name>.+?) (?:meets|is|moved to) (?P<day>\w+day) at (?P<time>\d+(?:am|pm)) "
                   r"(?:in|on) (?P<place>[^.!]+)")
CALLS = []   # every model call, so each pattern's cost can be counted

def stand_in(system, user):
    """Not a language model: fixed rules per role, so every intermediate output is
    visible and repeatable.  Part VI replaces this function with a real model call."""
    if system == EXTRACT:
        rows = []
        for line in user.splitlines():
            m = EVENT.match(line.strip())
            if m:
                rows.append(" | ".join(m.group("name", "day", "time", "place")))
        return "\n".join(rows)
    if system == DRAFT:
        out = []
        for row in user.splitlines():
            name, day, time, place = [x.strip() for x in row.split("|")]
            out.append(f"{name} is on {day} at {time} ({place}).")
        return " ".join(out)
    if system == POLISH:   # the mistake Question 6 warned about
        return user.replace(" is on ", ": ").replace("Thursday", "Friday")
    if system == CLASSIFY:
        if "moved" in user or "cancel" in user:
            return "change"
        if user.rstrip().endswith("?"):
            return "question"
        return "event" if EVENT.match(user) else "announcement"   # outside the closed set
    return ""

def llm(system, user):
    """The one function every pattern calls.  In this page it is the stand-in."""
    CALLS.append(system[:24])
    return stand_in(system, user)

print(f"{len(MESSAGES)} messages; settings {CONFIG}")
print(repr(llm(CLASSIFY, MESSAGES[0])), repr(llm(EXTRACT, MESSAGES[0])))
CALLS.clear()
```
@Pyodide.eval
[Visualize this example](https://billjr99.github.io/Ursinus-CS357-Fall2026/viz/#cs357-liascript-orchestrationworkshop-1) <!-- code-viz link -->

**You should see:**

```text
5 messages; settings {'spawn_budget': 6, 'temperature': 0.0, 'seed': 42}
'event' 'Chess club | Thursday | 7pm | Olin 107'
```

## Step 1: A Fixed Pipeline With a Check at the Seam

**Goal:** extract, draft, and polish in an order you wrote, print every intermediate, and run a check in code after the last stage.  The check is not a fourth model call.  Whether "Thursday at 7pm" appears in the digest is something a program can verify exactly, so a program verifies it.  When the check fails, the pipeline stops for a stated reason and returns the last version that passed, with the problem attached.  The lab's critique loop follows the same rule when its budget runs out.

<!-- run: id=cs357-liascript-orchestrationworkshop-4 viz=env setup=cs357-liascript-orchestrationworkshop-1 -->
```python
# Step 1: a fixed pipeline.  You wrote the order; the code checks the seam the model cannot.
def check_times(facts, text):
    """A check in code, not a model: every extracted day and time must survive into the text."""
    missing = []
    for row in facts.splitlines():
        name, day, time, _ = [x.strip() for x in row.split("|")]
        if f"{day} at {time}" not in text:
            missing.append(f"{name}: {day} at {time}")
    return missing

def digest_pipeline(messages):
    facts = llm(EXTRACT, "\n".join(messages))
    print("1. EXTRACT ->\n" + facts)
    draft = llm(DRAFT, facts)
    print("2. DRAFT ->\n" + draft)
    final = llm(POLISH, draft)
    print("3. POLISH ->\n" + final)
    missing = check_times(facts, final)
    print("4. CHECK ->", missing or "every day and time present")
    if missing:                        # stop condition: never ship a digest that lost a fact
        print("   polish broke a fact; returning the draft, with the problem attached")
        return draft, missing
    return final, []

CALLS.clear()
digest, problems = digest_pipeline(MESSAGES)
print(f"\nRESULT: {digest}\nmodel calls: {len(CALLS)}")
```
@Pyodide.eval
[Visualize this example](https://billjr99.github.io/Ursinus-CS357-Fall2026/viz/#cs357-liascript-orchestrationworkshop-4) <!-- code-viz link -->

**You should see:**

```text
1. EXTRACT ->
Chess club | Thursday | 7pm | Olin 107
Hawk Hacks | Saturday | 10am | IDDC
Ultimate frisbee pickup | Sunday | 2pm | the quad
2. DRAFT ->
Chess club is on Thursday at 7pm (Olin 107). Hawk Hacks is on Saturday at 10am (IDDC). Ultimate frisbee pickup is on Sunday at 2pm (the quad).
3. POLISH ->
Chess club: Friday at 7pm (Olin 107). Hawk Hacks: Saturday at 10am (IDDC). Ultimate frisbee pickup: Sunday at 2pm (the quad).
4. CHECK -> ['Chess club: Thursday at 7pm']
   polish broke a fact; returning the draft, with the problem attached

RESULT: Chess club is on Thursday at 7pm (Olin 107). ...
model calls: 3
```

> **Checkpoint 1.**  The pizza message has no day or time, so the extract stage dropped it without a word.  Is that the right behavior for a digest, and where would you find out that it happened?  Then: the pipeline cost exactly three model calls.  Could you have said so before you ran it?  That is what a fixed pipeline buys you.

## Step 2: A Router in Front of the Pipeline

**Goal:** classify each message once into a closed set, then dispatch it.  Events and changes go on to the digest pipeline, questions go to an FAQ queue, and anything outside the set goes to a person.  Part II's router fell back to "software" without telling anyone.  This one fails closed and says so, which is the louder failure Question 5 asked for.

<!-- run: id=cs357-liascript-orchestrationworkshop-5 viz=env setup=cs357-liascript-orchestrationworkshop-1 -->
```python
# Step 2: a router.  One classification per message, a closed set, and a loud failure.
ROUTES = {"event": "digest", "change": "digest (marked UPDATED)", "question": "FAQ queue"}

def route(message):
    label = llm(CLASSIFY, message).strip().lower()
    if label not in ROUTES:            # closed-set guard: fail closed, and say so
        return label, "needs_human"
    return label, ROUTES[label]

CALLS.clear()
for_digest = []
for message in MESSAGES:
    label, destination = route(message)
    print(f"{label:<13} -> {destination:<24} {message[:44]}")
    if destination.startswith("digest"):
        for_digest.append(message)
print(f"\nmodel calls: {len(CALLS)}; {len(for_digest)} of {len(MESSAGES)} messages go on to the pipeline")
```
@Pyodide.eval
[Visualize this example](https://billjr99.github.io/Ursinus-CS357-Fall2026/viz/#cs357-liascript-orchestrationworkshop-5) <!-- code-viz link -->

**You should see:**

```text
event         -> digest                   Chess club meets Thursday at 7pm in Olin 107
event         -> digest                   Hawk Hacks is Saturday at 10am in IDDC. Brin
change        -> digest (marked UPDATED)  Ultimate frisbee pickup moved to Sunday at 2
question      -> FAQ queue                Does anyone know if the library is open late
announcement  -> needs_human              Free pizza in the lobby, first come first se

model calls: 5; 3 of 5 messages go on to the pipeline
```

> **Checkpoint 2.**  The stand-in invented a fifth label, `announcement`, just as Question 2 predicted a real router would.  Name the line that kept it out of the digest.  Then count: the router adds one model call per message, so routing these five messages cost five calls before the pipeline's three.  For which inputs is that cost worth paying?

## Step 3: A Supervisor Loop With a Budget and Stop Conditions

**Goal:** the same digest, but now a model decides on each turn which sub-agent runs next, or whether to stop.  The supervisor must reply in JSON, in the same two shapes as Part IV's Code Cell: `{"action": "call", "agent": ..., "input": ...}` or `{"action": "stop", "answer": ...}`.  Everything that keeps the loop safe lives in `supervise`, not in the supervisor:

- **The roster.**  Only `extractor`, `writer`, and `polisher` exist.  Any other name is refused and logged.
- **The budget.**  At most `CONFIG["spawn_budget"]` turns.  Each turn's decision is itself a model call, so it is counted.
- **Four stop conditions**, each a `return` with a named status: the answer passed the check (`done`); the decision was not valid JSON (fail closed); the same sub-agent was asked for the same input twice (a loop, caught by an idempotency check); or the budget ran out.  Every early stop returns the newest text that passed the check, and flags it.  It never returns the newest text as such.
- **A refused stop.**  The supervisor may say "stop," but the answer must pass `check_times` first.  That is the explicit stop condition a program can check, from Part III's section on termination.

The stand-in supervisor below is scripted to make a plausible mistake: it always stops with the newest text, whether or not that text passed the check.

<!-- run: id=cs357-liascript-orchestrationworkshop-6 viz=env setup=cs357-liascript-orchestrationworkshop-1,cs357-liascript-orchestrationworkshop-4,cs357-liascript-orchestrationworkshop-5 -->
```python
# Step 3: a supervisor loop.  A model picks the next move each turn; you own the roster,
# the budget, and every stop condition.
ROSTER = {"extractor": EXTRACT, "writer": DRAFT, "polisher": POLISH}

def naive_supervisor(task, transcript):
    """A scripted stand-in for the supervisor model.  It replies with the same JSON a real
    supervisor must produce, and it makes a plausible mistake: it always stops with the
    newest text, whether or not that text passed the check."""
    results = [t for t in transcript if "result" in t]
    done = [t["agent"] for t in results]
    if "extractor" not in done:
        return json.dumps({"action": "call", "agent": "extractor", "input": task})
    if "writer" not in done:
        return json.dumps({"action": "call", "agent": "writer", "input": results[0]["result"]})
    if "polisher" not in done:
        return json.dumps({"action": "call", "agent": "polisher", "input": results[-1]["result"]})
    return json.dumps({"action": "stop", "answer": results[-1]["result"]})

def supervise(task, decide, budget=CONFIG["spawn_budget"]):
    transcript, seen, facts = [], set(), None
    def best():                                        # the newest text that passed the check
        ok = [t["result"] for t in transcript if t.get("check") == "ok"]
        return ok[-1] if ok else None
    for turn in range(1, budget + 1):
        CALLS.append("SUPERVISOR")                     # the supervisor's own decision is a model call
        raw = decide(task, transcript)
        print(f"turn {turn}: {raw[:84]}")
        try:
            step = json.loads(raw)
        except json.JSONDecodeError:                   # stop condition: fail closed
            return {"status": "stopped: malformed decision", "answer": best(), "turns": turn}
        if step.get("action") == "stop":
            missing = check_times(facts, step.get("answer", "")) if facts else ["no facts yet"]
            if not missing:                            # stop condition: the check passed
                return {"status": "done", "answer": step["answer"], "turns": turn}
            transcript.append({"agent": "supervisor", "error": f"stop refused, missing {missing}"})
            print(f"   stop refused: missing {missing}")
            continue
        agent, text = step.get("agent"), step.get("input", "")
        if agent not in ROSTER:                        # closed roster, like the router's labels
            transcript.append({"agent": agent, "error": "unknown sub-agent"})
            print(f"   refused: {agent!r} is not on the roster")
            continue
        if (agent, text) in seen:                      # stop condition: the same call twice is a loop
            return {"status": f"stopped: repeated call to {agent}", "answer": best(), "turns": turn}
        seen.add((agent, text))
        result = llm(ROSTER[agent], text)              # the sub-agent sees only its own input
        entry = {"agent": agent, "result": result}
        if agent == "extractor":
            facts = result
        elif facts:
            entry["check"] = check_times(facts, result) or "ok"
        transcript.append(entry)
        print(f"   {agent} -> {result[:58].replace(chr(10), ' / ')}...  check={entry.get('check', '-')}")
    return {"status": f"stopped: budget of {budget} turns reached", "answer": best(), "turns": budget}

CALLS.clear()
outcome = supervise("\n".join(for_digest), naive_supervisor)
print(f"\nSTATUS: {outcome['status']} (turns: {outcome['turns']}, model calls: {len(CALLS)})")
print(f"ANSWER (newest text that passed the check): {outcome['answer']}")
```
@Pyodide.eval
[Visualize this example](https://billjr99.github.io/Ursinus-CS357-Fall2026/viz/#cs357-liascript-orchestrationworkshop-6) <!-- code-viz link -->

**You should see:**

```text
turn 1: {"action": "call", "agent": "extractor", "input": "Chess club meets Thursday at 7pm 
   extractor -> Chess club | Thursday | 7pm | Olin 107 / Hawk Hacks | Saturd...  check=-
turn 2: {"action": "call", "agent": "writer", "input": "Chess club | Thursday | 7pm | Olin 1
   writer -> Chess club is on Thursday at 7pm (Olin 107). Hawk Hacks is...  check=ok
turn 3: {"action": "call", "agent": "polisher", "input": "Chess club is on Thursday at 7pm (
   polisher -> Chess club: Friday at 7pm (Olin 107). Hawk Hacks: Saturday...  check=['Chess club: Thursday at 7pm']
turn 4: {"action": "stop", "answer": "Chess club: Friday at 7pm (Olin 107). Hawk Hacks: Satu
   stop refused: missing ['Chess club: Thursday at 7pm']
turn 5: ...
turn 6: ...
   stop refused: missing ['Chess club: Thursday at 7pm']

STATUS: stopped: budget of 6 turns reached (turns: 6, model calls: 9)
ANSWER (newest text that passed the check): Chess club is on Thursday at 7pm (Olin 107). ...
```

Read the transcript as the loop's log.  Turns 1 to 3 are the pipeline again, this time chosen by the supervisor instead of written by you.  At turn 4, the supervisor tried to stop with the broken digest, and the check refused it.  It then asked twice more to stop with the same broken text, and the budget ended the run.  The loop still returned something useful, because an early stop returns the newest *checked* text and reports that it stopped early.

Now make the other two stop conditions fire, one misbehaving supervisor at a time.

<!-- run: id=cs357-liascript-orchestrationworkshop-7 viz=env setup=cs357-liascript-orchestrationworkshop-1,cs357-liascript-orchestrationworkshop-4,cs357-liascript-orchestrationworkshop-5,cs357-liascript-orchestrationworkshop-6 -->
```python
# The other two stop conditions, each fired on purpose by a misbehaving stand-in supervisor.
def stubborn(task, transcript):        # asks for the same extraction forever
    return json.dumps({"action": "call", "agent": "extractor", "input": task})

def chatty(task, transcript):          # answers in prose instead of the required JSON
    return "Sure! First I will extract the events, then write the digest."

for name, decide in [("stubborn", stubborn), ("chatty", chatty)]:
    CALLS.clear()
    result = supervise("\n".join(for_digest), decide)
    print(f"-> {name}: {result['status']} (turns: {result['turns']}, model calls: {len(CALLS)})\n")
```
@Pyodide.eval
[Visualize this example](https://billjr99.github.io/Ursinus-CS357-Fall2026/viz/#cs357-liascript-orchestrationworkshop-7) <!-- code-viz link -->

**You should see:**

```text
turn 1: {"action": "call", "agent": "extractor", "input": "Chess club meets Thursday at 7pm 
   extractor -> Chess club | Thursday | 7pm | Olin 107 / Hawk Hacks | Saturd...  check=-
turn 2: {"action": "call", "agent": "extractor", "input": "Chess club meets Thursday at 7pm 
-> stubborn: stopped: repeated call to extractor (turns: 2, model calls: 3)

turn 1: Sure! First I will extract the events, then write the digest.
-> chatty: stopped: malformed decision (turns: 1, model calls: 1)
```

> **Checkpoint 3.**  For each of the three runs, name the stop condition that fired and the line of `supervise` that fired it.  Then answer Question 19 again with evidence from your screen: what happens at the moment the budget runs out, and why does the status say `stopped` instead of presenting the transcript as a finished answer?

## The Cost Table

**Checkpoint 4.**  The same digest, three ways.  Fill in the last two columns from your runs; the Recorder keeps the table.

| Pattern | Model calls | Who decided the order | Delivered a digest that passed the check? | Stopped because |
|---|---|---|---|---|
| Fixed pipeline (Step 1) | 3 | You, before the run | | |
| Router, then pipeline (Steps 2 and 1) | 5 + 3 | You; the model picks one label per message | | |
| Supervisor (Step 3) | 9 | The model, each turn | | |

The supervisor spent three times the pipeline's calls to reach the same checked draft, and it reached that draft only because your code refused its stop and capped its turns.  That is Part I's rule about choosing the least dynamic pattern, measured on one task.  A supervisor earns its cost only when you cannot write the order down in advance.

### Common Mistakes

- **Putting the budget in the prompt.**  "Stop after six steps" in a system prompt is a request; `range(budget)` in your loop is a guarantee.  Keep the number in configuration, as the lab does with `round_budget`.
- **Trusting the supervisor's "stop."**  A model saying it is done is self-assessed completion.  Before you accept the answer, check it against something a program can verify.
- **Returning the newest text on an early stop.**  In Step 3, the newest text was the broken one.  Return the newest text that passed the check, and say that the run stopped early.
- **Not counting the supervisor's own calls.**  Every decision is a model call.  A supervisor that makes six decisions to dispatch three sub-agents spent nine calls, not three.
- **Silent fallbacks.**  A router that maps an unknown label to a default hides the failure.  Fail closed to a person, and log it.
- **Trusting a check that had nothing to check.**  `check_times` loops over the extracted facts.  If the extract stage returns nothing (because the model is missing, say, or the request failed), there is nothing to miss, and the check prints `every day and time present` for an empty digest.  Treat an empty extraction as a failure in its own right, before you run the check.
- **Letting a parse error crash the loop.**  Wrap `json.loads` and stop with a named status, as `supervise` does, instead of letting an exception end the run with no record.

---
# Part VI: The Same Code on a Real Model

## Code Route: Swap in Ollama

> **Runs on your machine, not here.**  This block talks to the Ollama server on your own laptop at `localhost:11434`, which a web page cannot reach.

Copy the five cells from Part V into one file, `orchestrate.py`, and paste the block below right after the Setup cell's code.  Every pattern looks up `llm()` by name when it runs, so redefining `llm()` here sends the pipeline, the router, and the sub-agents to Ollama with no other change.  Then change one argument in Step 3: pass `model_supervisor` instead of `naive_supervisor`.  The supervisor prompt is the one from Part IV's Code Cell, and `"format": "json"` asks Ollama to limit the reply to JSON, the structured-output setting from the *Tool Use* readings.  The fail-closed stop stays, because a limit on the format promises nothing about the content.

```python
import requests
import traceback

CONFIG.update({"model": "llama3.2", "provider_url": "http://localhost:11434/api/chat"})


def chat_once(system, user, json_only=False):
    """One request to Ollama.  Returns the text, or "" after printing a located error."""
    body = {"model": CONFIG["model"], "stream": False,
            "options": {"temperature": CONFIG["temperature"], "seed": CONFIG["seed"]},
            "messages": [{"role": "system", "content": system},
                         {"role": "user", "content": user}]}
    if json_only:
        body["format"] = "json"
    try:
        r = requests.post(CONFIG["provider_url"], json=body, timeout=120)
        r.raise_for_status()
        return r.json()["message"]["content"].strip()
    except Exception as e:
        print(f"[orchestrate:chat_once] {e}")
        traceback.print_exc()
        return ""


def llm(system, user):
    """Replaces the stand-in: every pattern below now calls the real model."""
    CALLS.append(system[:24])
    return chat_once(system, user)


SUPERVISOR = ("You are an orchestrator. Choose the next step and reply with ONLY JSON. "
              "Available sub-agents: extractor, writer, polisher. "
              'Reply {"action":"call","agent":"<name>","input":"<text>"} '
              'to delegate, or {"action":"stop","answer":"<final text>"} when done.')


def model_supervisor(task, transcript):
    """A real supervisor.  supervise() already counts this call and parses the reply."""
    return chat_once(SUPERVISOR, f"TASK: Write the digest for these messages.\n{task}\n\n"
                                 f"TRANSCRIPT SO FAR:\n{json.dumps(transcript, indent=2)}",
                     json_only=True)
```

Run `python orchestrate.py` and save the full output.  Your output will differ from this page, because a real model does not make the stand-in's scripted mistakes; it makes its own.  An empty reply from `chat_once` means the request failed, and `supervise` stops it as a malformed decision instead of guessing.

### What One Real Run Looked Like

Here is what `llama3.2` did with this code at temperature 0 and seed 42.  Your run will differ, but look for the same three things.

- **The polish kept every fact, and the check still failed it.**  The model wrote "Thursday, 7pm," and the check looks for the exact text "Thursday at 7pm."  A check in code checks exactly what it says, and this one was stricter than we meant.
- **The router stayed inside its labels and was still wrong.**  It called the moved frisbee game an `event` instead of a `change`, and the pizza an `event`, so the pizza went into the digest.  The closed-set guard catches labels the model invents, not wrong labels taken from the list.  Catching those takes a labeled test set.
- **The supervisor skipped the extractor.**  It called the writer first and then tried to stop five times.  With no facts to check against, `supervise` refused every stop, and the budget ended the run after 6 turns and 7 model calls, with no answer.  That is an honest "nothing checked," not a wrong answer.

A second run with the same seed worded the draft differently and dropped "10am" from one event in the polish, but it stopped for the same reasons.  A fixed seed and temperature 0 make a run more repeatable, not identical.

> **Checkpoint 5 (code route).**  Add a row to the Checkpoint 4 table for each pattern on the real model.  Did the real polish stage keep every day and time?  Did the real router stay inside its four labels?  Which stop condition ended the real supervisor's run, and after how many turns and model calls?  If two runs with the same seed differ, write down where.

## No-Code Route: Run the Protocol by Hand

The lab's no-code route runs each role as a saved Open WebUI preset, or as a prompt node on a Langflow canvas, and moves text between them by hand.  The three patterns work the same way, except that you are the code.

1.  **Pipeline.**  Save three presets with the `EXTRACT`, `DRAFT`, and `POLISH` system prompts from the Setup cell.  Paste the five messages into the first, its output into the second, and that output into the third.  Then do the check yourself: is every day and time from the extract still in the polished digest?  If not, keep the draft and write down why.
2.  **Router.**  Save a fourth preset with the `CLASSIFY` prompt, and send each message to it on its own.  Any reply that is not exactly `event`, `change`, or `question` goes to "needs a person," and you write that down.
3.  **Supervisor.**  Save a fifth preset with the `SUPERVISOR` prompt from the code route.  On each turn, paste the task and your running transcript into it, and carry out its decision by hand with the other presets.  You enforce the controls: refuse any agent not on the roster, refuse a stop whose answer fails your check, stop at a repeated request, and stop at six turns.  Log every turn in a spreadsheet: the decision, the result, the check, and the running count of model calls.

> **Checkpoint 5 (no-code route).**  Add your rows to the Checkpoint 4 table from the spreadsheet.  Which control was hardest to enforce by hand, and what does that tell you about where the code route's guarantees come from?

## Where These Controls Appear in the Lab

| Today | In the Multi-Agent Patterns lab |
|---|---|
| `CONFIG["spawn_budget"]`, read from configuration | `round_budget` and the debate's `num_rounds` in `config.json` (Before You Start) |
| The malformed-decision stop | Invalid critic JSON fails closed: the loop treats it as "revise" and logs it (Part A) |
| The newest checked text returned on an early stop, flagged | On budget exhaustion, the loop returns the final draft with its outstanding critique attached (Part A, Practice) |
| `check_times`, a check in code at a seam | Answer extraction anchored on a required `ANSWER:` line, with a located warning when it is missing (Part B, Practice) |
| `CALLS`, counted per pattern | Each Try It counts the pattern's model calls against a single call (Parts A to C); the matched-budget shootout is in the [Measuring Multi-Agent Patterns](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/MultiAgentMeasurement) tutorial |
| Located error messages such as `[orchestrate:chat_once]` | Every model call wrapped in a handler that prints a located message and a traceback (the proficient level of each Part's rubric row) |

The supervisor's writer, check, and refused stop already make a critique-and-refine loop, with a program as the critic instead of a model.  Part A of the lab replaces that program with a critic model and a written rubric.  Measuring when that critic is wrong is the first part of the [Measuring Multi-Agent Patterns](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/MultiAgentMeasurement) tutorial.

---

# Part VII: Synthesis and Practice

This part adds two reliability upgrades, reflection and recovery, summarized from *Part III: Loops That Recover*.  Then the exercises extend what you built: a supervisor that stops correctly, a verification stage for the pipeline, a labeled test set for the router, and a message format for a planner.  They lead straight into the lab, so the design decisions you make here carry forward.

## Model 5: Reflection and Recovery, Keeping Composed Loops Reliable

*(A short summary of Part III; go back to it for the full treatment.)*

**Why this matters:** every orchestration in this deck is still a loop, and loops fail the way loops do: they oscillate, overrun their budgets, crash partway through, and repeat the same mistake on every run.  Two upgrades address this.  The first is the **reflection loop** (Reflexion, Shinn et al., 2023).  After each *complete attempt*, the agent critiques its own trajectory and stores a short "lesson" in memory ("for arXiv IDs, search arXiv directly rather than Google"), and the next attempt starts with those lessons loaded.  It works best on tasks with a clear success or failure signal that you expect to run many times.  Its weakness is that a poor self-critique stores a *bad* lesson that makes later runs worse, and every lesson costs context tokens.  The second is the **recovery and budget model**: even a well-built loop needs circuit breakers, controls that keep a small failure from spreading:

| Control | One-line implementation | What it prevents |
|---------|------------------------|------------------|
| Max iterations | `if step >= MAX_STEPS: return partial_result`, a hard ceiling, whatever the agent "thinks" | Infinite loops and runaway spend |
| Token budget check | Estimate the next call's tokens; compress context if it will not fit | Silent front-truncation of the task mid-thought |
| Idempotency check | Flag any repeated `(action, args_hash)` pair as possible oscillation | Alternating between two actions forever |
| Escalation gate | Pause for a human before irreversible actions taken under uncertainty | Low-confidence irreversible harm |
| Checkpointing | Save full state after each action; on crash, resume, never restart | Lost progress on long or expensive tasks |

Here is one compact loop with both upgrades:

```python
LESSONS = []                                      # reflection memory: survives across attempts

def attempt(task, max_steps=6):
    state = load_checkpoint(task) or fresh_state(task, lessons=LESSONS)
    seen = set()                                  # idempotency ledger
    for step in range(state.step, max_steps):     # budget: hard ceiling
        if not fits_in_context(state):
            state = compress(state)               # budget: summarize, never truncate silently
        action = plan_next(state)                 # the ordinary perceive/plan call
        if (action.name, action.args_hash) in seen:
            return escalate("oscillating", state) # recovery: flag it, do not spin
        seen.add((action.name, action.args_hash))
        if action.irreversible and state.uncertain:
            return escalate("needs approval", state)   # recovery: human gate
        state.observe(execute(action))
        save_checkpoint(task, state, step)        # recovery: crash-safe resume point
        if state.done:
            break
    LESSONS.append(critique(state.trajectory))    # reflection: store one lesson for next time
    return state.result
```

### Critical Thinking Questions

21.  Which of the five controls does Part II's *pipeline* barely need, and which does a dynamic *planner or supervisor* need most?  Explain using the difference in who writes the control flow.

    > *Hint: Your code fixes the pipeline at three steps, so it meets the max-iterations control by construction.  A planner chooses its own next step on every turn, so the ceiling, the idempotency ledger, and the escalation gate are all that stand between it and a run with no end.*

22.  The nightly digest pipeline mangles a date once a week.  Write the one-sentence Reflexion lesson you would want stored, and name the safeguard that keeps a bad lesson (say, "always skip the polish stage") from quietly making every later run worse.

    > *Hint: A lesson should name the strategy that works, not just criticize the failure.  And because the same model that failed writes the lessons, they deserve the same review as any seam: log them, cap how many load per run, and audit them when quality drifts.*

---

## 4.  Exercises

1.  **A supervisor that stops correctly.**

   *What to do:* Write `careful_supervisor(task, transcript)`, a stand-in like `naive_supervisor` that makes the same first three moves, but when it stops, it stops with the newest text in the transcript whose `check` is `"ok"`.  Run `supervise` with it in this page.  Then, on the code route, add one sentence to the `SUPERVISOR` prompt asking the real model for the same behavior, and run it again.

   *Starter hint:* The transcript entries for the writer and the polisher carry a `check` field.  Filter on it before you choose the answer.  For the prompt, say what "done" means in terms the model can see in its transcript.

   *You've succeeded when:* In this page, `supervise` returns `done` in 4 turns with 7 model calls, and you can say in one sentence why that is still more than the pipeline's 3.  On the real model, you can report whether the added sentence changed which stop condition fired, with the transcript as evidence.

2.  **Add a fact-check stage to the Part II pipeline.**

   *What to do:* Add a fourth stage to the Part II `digest_pipeline`: a `verify` stage that compares the polished digest against the extracted facts and returns a JSON object saying whether any fact in the digest disagrees with them.  Then show it catching a planted error: change a date in the digest by hand before you pass it to the verify stage.

   *Starter hint:*
   ```python
   def verify_stage(facts, final_digest):
       return llm(
           """You are a fact-checker. Compare the digest to the extracted facts.
           Return JSON: {"consistent": true/false, "issues": ["list any discrepancies"]}.
           Output only the JSON.""",
           f"Extracted facts:\n{facts}\n\nDigest to verify:\n{final_digest}",
           temperature=0.0  # deterministic: fact-checking should not vary
       )

   # Test with a seeded error: change "Thursday" to "Friday" in the final digest
   corrupted = final.replace("Thursday", "Friday")
   result = verify_stage(facts, corrupted)
   print("Verification result:", result)  # should report the date discrepancy
   ```

   *You've succeeded when:* Your verify stage finds the planted date error and lists it in `issues`, and it reports `"consistent": true` when the digest matches the facts.  Compare this model-based check with Step 1's `check_times`: which one would you trust, and for which kind of error?

3.  **Evaluate the router with a labeled test set.**

   *What to do:* Write 12 help-desk tickets (4 hardware, 4 software, 4 accounts) whose correct categories you know.  Run the Part II router on all 12 and compute its accuracy.  Then weaken the router's prompt on purpose (remove the instruction that limits the output to one of three words) and measure again.  Report the difference.

   *Starter hint:*
   ```python
   test_tickets = [
       ("My keyboard is not responding after I spilled water on it.", "hardware"),
       ("The application crashes every time I open the Reports tab.", "software"),
       ("My account was locked after three failed login attempts.", "accounts"),
       # ... add 9 more with known correct labels
   ]

   correct = 0
   for ticket_text, true_label in test_tickets:
       predicted_label, _ = route(ticket_text)
       if predicted_label == true_label:
           correct += 1
   accuracy = correct / len(test_tickets)
   print(f"Router accuracy: {accuracy:.0%}")
   ```

   *You've succeeded when:* You have an accuracy for both the constrained and the unconstrained router, and you can explain in one sentence why the closed-set instruction (or the guard in code) improved it.

4.  **Design a planner message format.**

   > *Hint: Think about what the planner needs to know when a worker fails.  It has to decide whether to retry the task, skip it, adjust the timeline, or ask the user for help, and it has to decide using only what the failure report says.  Which fields does the failure report need to support all four of those decisions?*

   *What to do:* On paper, design the JSON messages for the planner and its workers in the study-schedule task from Model 1.  Your design must specify (a) what the planner sends a worker as a task assignment, (b) what a worker sends back to report success, and (c) what a worker sends back to report a failure, including what the planner needs in order to revise the plan.  Write out three example messages in full.

   *Starter hint:*
   ```json
   // Planner -> Worker: task assignment
   {"task_id": "t1", "action": "study", "topic": "probability", "duration_minutes": 60, "deadline": "2026-12-10"}

   // Worker -> Planner: success report
   {"task_id": "t1", "status": "complete", "notes": "Covered chapters 4-6, comfortable with Bayes theorem"}

   // Worker -> Planner: failure report (what should go here?)
   {"task_id": "t1", "status": "blocked", "reason": "...", "suggestion": "..."}
   ```

   *You've succeeded when:* Your failure report carries enough for the planner to decide whether to reassign the task, adjust the timeline, or ask the user for clarification, without asking the worker any follow-up questions.

---

## Reflection Prompt

Answer one prompt at each level in your notebook.

**Personal:**

- Splitting a big task into narrow roles is also how good study groups, sports teams, and workplaces run.  Think of a team project, in this class or anywhere else, where unclear roles caused confusion or duplicated work.  How does the pipeline, router, and planner framework describe what went wrong, and what would the "seam" between two teammates look like in practice?
- Today you were the code on the no-code route, or you watched the code refuse a model's "stop."  Think of a group project where someone declared a task done before it was.  What check would have caught it, and who should have owned that check?

**Technical:**

- Describe one place in this deck's pipeline where information lost at a seam could lead to a bad outcome.  For example, if the polish stage changes a date while editing for concision, neither the extract stage nor the draft stage will catch it.  What mechanism (a validation step, a schema check, a logging requirement) would detect that specific failure?
- The supervisor reached the same checked draft as the pipeline at three times the cost.  Describe a task, from your Final Project if you can, whose order you could not write down in advance, and say which of the four stop conditions from Step 3 you would need first.

**Societal:**

- Splitting work into narrow roles is how both efficient organizations and surveillance systems operate.  A pipeline of agents that each know only their own step can process sensitive data (a student's grades, a person's medical history) without any single agent "knowing" the whole picture.  Is that a privacy protection or a way to blur accountability?  Who is responsible when a pipeline of agents that each followed the rules produces a harmful outcome?
- An organization replaces a fixed approval workflow with a supervisor agent "for flexibility," and every run now takes a different path.  What does an auditor lose, and which of this deck's controls would you require before you agreed that the system is accountable?

---

-> Coming Up Next: *Critique, Consensus, and the LLM Judge: One Loop, Three Uses* takes the check you wrote today and asks what happens when it cannot be a program: a critic model that sends issues back to a generator, several generators compared by meaning, and a judge that scores against a rubric.  That loop is the core of the Multi-Agent Patterns lab you received today.  Have `supervise` and your cost table ready.  Sprint Check 1 is at the start of that class, and the RAG Knowledge Base lab is due at the Judge Pipeline Workshop, the session after it.

## Further Reading

- [Orchestration Patterns](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/OrchestrationPatterns): a pipeline, a router, and a supervisor, each on its own, in Python and by hand with presets.
- [Measuring Multi-Agent Patterns](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/MultiAgentMeasurement): the measurement the lab leaves out.
- The [Multi-Agent Patterns lab](https://www.billmongan.com/Ursinus-CS357-Fall2026/Assignments/MultiAgentDebate), where the budget, the fail-closed parse, and the call counts are graded.
- [Agent Teams](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/AgentTeams): a monolith versus a team, topology and shared state, ending with a sketch of your own project's team.
- [Pydantic AI From the Loop Up](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/PydanticAI): the RAG lab's agent caps its loop with `UsageLimits(request_limit=4)`, the same budget idea enforced by a framework instead of your own `range()`.  Read it before Agent Frameworks if you have not yet seen a framework take over the hand-written loop.
- [Agent Frameworks](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/AgentFrameworks), for frameworks that build the supervisor pattern for you, and what they move into their own prompts when they do.
- [From Second Brain to Chief of Staff: one personal agent followed into production](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/ProductionAssistant)
- Anthropic engineering blog.  "Building Effective Agents" (2024, online).  The workflow patterns in this deck.
- Wu et al. "AutoGen: Enabling Next-Gen LLM Applications via Multi-Agent Conversation."  (2023).

---

# Going Deeper (optional): More Fixed Shapes, and Framework Pointers

Everything below is optional, and nothing graded depends on it.  Parts I to IV gave you the vocabulary (pipeline, router, planner, supervisor) and working orchestrators in code, and Part V built three of them on one task.  This section rounds out the fixed family with the shapes you have not yet built by hand, and ends with a reference sheet for all six patterns.

---

## 5.  Fixed Pipelines, Explained Separately

Fixed orchestration is a small family of reusable shapes.  Below, each one gets its own slide: a one-line *when to use*, a small flow sketch, and a pointer to where you have already met it.  All five share one property: **you write the wiring, and it does not change based on what the agents produce.**

### 5a.  Sequential Pipeline (A -> B -> C)

*When to use:* the steps are known ahead of time, and each stage refines the previous stage's output.

```text
input --> [ Extract ] --> [ Draft ] --> [ Polish ] --> output
             facts          prose         tight prose
```

This is the `digest_pipeline` from Part II and Step 1.  Each stage has a one-sentence system prompt and sees only its own input, and the seams between stages are where you look for bugs.

### 5b.  Router / Dispatch (classify, then one specialist)

*When to use:* one input, several possible handlers, and exactly one of them applies.

```text
                       .--> [ Hardware specialist ]
input --> [ Classify ] +--> [ Software specialist ] --> output
                       '--> [ Accounts specialist ]
```

This is `route()` from Part II and Step 2.  The classifier's only job is to emit one label from a closed set, and a guard in code keeps any stray label from going through.

### 5c.  Parallel Fan-Out / Gather (map-reduce)

*When to use:* the task splits into N *independent* subtasks whose separate results are then combined.

```text
              .--> [ Agent 1 ] --.
input --> split +--> [ Agent 2 ] --+--> [ Aggregate ] --> output
              '--> [ Agent N ] --'
```

The subtasks share no context, which is what lets them run in parallel, and a final aggregator (an agent or plain code) merges the results.  Compare it with the sequential pipeline: there, each stage *depends* on the one before; here, the branches stay isolated until the gather step.

### 5d.  Critique-Refine (generator <-> critic loop)

*When to use:* you can state and check a quality bar, and one pass does not reliably meet it.

```text
input --> [ Generate ] --> draft <==> [ Critique ] --> (revise until pass OR budget) --> output
```

The loop is bounded (it stops when the critic is satisfied or the revision budget runs out), so the control flow is still fixed, even though it repeats.  Step 3's writer, check, and refused stop are a small version of this shape.  It gets its own activity: [Critique, Consensus, and the LLM Judge](https://www.billmongan.com/LiaScript/?https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/_pages/Activities/liascript-critiqueconsensusjudge.md).

### 5e.  Debate / Stochastic Consensus (many agents, vote or cluster)

*When to use:* the answer is uncertain or subjective, and several independent attempts give a more reliable result than any one of them.

```text
          .--> [ Agent A ] --.
input --> +--> [ Agent B ] --+--> [ Vote / Cluster ] --> consensus
          '--> [ Agent C ] --'
```

The agents argue or answer independently, and a fixed aggregation rule (majority vote, or clustering the answers) produces the result.  Two activities develop this shape: [Critique, Consensus, and the LLM Judge](https://www.billmongan.com/LiaScript/?https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/_pages/Activities/liascript-critiqueconsensusjudge.md) and [Stochastic Consensus](https://www.billmongan.com/Ursinus-CS357-Fall2026/Assignments/MultiAgentDebate).

Every shape above is *fixed*.  Even the critique loop and the debate vote follow a control flow you wrote and could draw on a whiteboard before a run.  Part IV covered who draws the diagram when it is not you.

### Recap: All Six Patterns, One Table

| Pattern | Who decides the control flow | Reach for it when | Main risk | Where you met it |
|---|---|---|---|---|
| Sequential pipeline | You, before runtime | The steps are known and each refines the last | An error at a seam propagates silently downstream | Part II, Step 1 |
| Router / dispatch | You (the classifier only picks a label) | One input, several handlers, exactly one applies | A mis-classification sends the whole task to the wrong specialist | Part II, Step 2 |
| Parallel fan-out / gather | You (branches are independent by design) | N independent subtasks whose results combine | The aggregator hides disagreement or drops a branch's result | Going Deeper, 5c |
| Critique-refine | You (a bounded generator <-> critic loop) | A checkable quality bar that one pass misses | The loop never converges and burns the revision budget | Going Deeper, 5d |
| Debate / consensus | You (a fixed voting or clustering rule) | Uncertain or subjective answers needing robustness | Correlated agents "agree" on the same wrong answer | Going Deeper, 5e |
| Supervisor (dynamic) | An orchestrator LLM, each turn | The workflow cannot be enumerated in advance | Runaway spawning and unpredictable, hard-to-audit paths | Part IV, Step 3 |

For frameworks that build the supervisor pattern for you, see [Agent Frameworks](https://www.billmongan.com/Ursinus-CS357-Fall2026/Tutorials/AgentFrameworks).  They supply sub-agents in isolated context windows and a built-in planning tool, and they pick up where Part IV's Code Cell and Step 3 leave off.
