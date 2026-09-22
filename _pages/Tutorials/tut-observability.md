---
layout: textbook
permalink: /Tutorials/Observability
title: 'CS357: Foundations of Artificial Intelligence - Agent Observability and Tracing'
info:
  coursenum: CS357
  purpose: "To make a silently failing agent visible, because a crash at least gives you a stack trace and a wrong answer gives you nothing."
  eyebrow: "Tutorial"
tags:
- observability
- tracing
- production
---
## About This Tutorial

A deployed agent that silently fails is worse than one that visibly crashes.  A crash produces an error message and a stack trace.  Silent failure produces a wrong answer, a missed tool call, or a hallucination, and the operator has no idea it happened.  **Observability** is the discipline of making the internal state of a system legible from the outside, so that you can ask arbitrary questions about its behavior without knowing in advance what questions you will need to ask.  This tutorial introduces the three pillars of observability, distributed tracing for agent pipelines, and the OpenTelemetry standard for instrumenting LLM applications.
{: .tb-lede}

## Key Concepts

| Term | Plain-English Definition | Where You'll Meet It |
|:-----|:------------------------|:------------------------|
| **Observability** | The ability to understand what a system is doing on the inside by looking at its outputs, without having to guess or modify the code | Knowing which step of your RAG pipeline caused a slow response, just by reading the trace data |
| **Trace** | A recording of every step a single request takes as it flows through your system, stitched together with a shared ID | One user asking your agent a question produces one trace with child spans for retrieval, LLM call, and tool use |
| **Span** | A single timed unit of work inside a trace (like one function call) that records its start time, end time, and metadata attributes | The `llm_generate` span that records how many tokens were used and why the model stopped generating |
| **Metric** | A number that is measured repeatedly over time and aggregated, such as a count, average, or histogram | "Error rate rose from 1% to 8% between Tuesday and Wednesday" |
| **Log** | A timestamped record of a specific event, written in text (structured or plain), that describes something that happened at a moment in time | "2025-09-15T14:03:22Z ERROR finish_reason=content_filter query_hash=a3f9" |
| **OpenTelemetry (OTel)** | An open standard that defines a single API for collecting traces, metrics, and logs so you can swap backends without rewriting your instrumentation code | Instrument once with OTel; export to Jaeger, Honeycomb, or Grafana by changing one config line |
| **Token count** | The number of tokens a model read (input) and wrote (output) on one call, reported by the model server itself, so you record it rather than estimate it | `prompt_eval_count` and `eval_count` on every Ollama response, and the token panel in OpenCode |
{: .tb-full}

---

## The Three Pillars of Observability

> Flying an agent without traces is like flying a plane with no instruments: you only know something's wrong when you crash.  In production, your agent will fail in ways you did not anticipate.  The three pillars below are your cockpit instruments: they let you see the problem, measure its scale, and trace it to its source before a user reports it.
{: .tb-key data-title="Why this matters"}

Observability in distributed systems is built on three complementary data types.  No single pillar is sufficient on its own; together they provide a complete picture of system behavior.

| Pillar | What It Captures | Time Granularity | Best For | Example Tool | In Our Course |
|:-------|:-----------------|:----------------|:---------|:-------------|:--------------|
| **Logs** | Discrete events with a timestamp, severity level, and message payload; may include structured key-value fields such as `user_id`, `finish_reason`, or `error_code` | Per-event at arbitrary resolution: every event gets its own entry the moment it happens | Debugging a specific failure after the fact; auditing exactly what the agent said or did at a given moment; investigating a complaint from a specific user | Loki, Elasticsearch, CloudWatch Logs | Printing `finish_reason` and `query_hash` to a structured log file every time your agent handles a request |
| **Metrics** | Numeric measurements aggregated over time: counters (how many requests), gauges (current queue depth), and histograms (distribution of latencies); e.g., request rate, error rate, token consumption per minute | Aggregated over fixed time buckets, typically one second to one minute; you see trends, not individual events | Alerting when a threshold is violated (e.g., error rate > 1%); capacity planning; identifying trends over hours or days | Prometheus, Datadog, InfluxDB | Tracking "tokens used per minute" to catch runaway loops before your API bill spikes |
| **Traces** | Causally linked spans representing the end-to-end execution of a single request through multiple services or steps; each span has a parent, a start time, an end time, and key-value attributes | Per-request at sub-millisecond resolution on individual spans; you see the full causal chain for one request | Root-cause analysis across multiple hops in a pipeline; identifying which specific step added most of the latency | Jaeger, Zipkin, Honeycomb | Visualizing that 73% of your agent's response time comes from the LLM call, not the retrieval step |
{: .tb-full}

**Key insight**: A metric can tell you that error rate increased at 2:00 PM; a log can tell you the exact error message for one failing request; a trace can tell you which step in the agent pipeline caused that request to fail and how long each step took.

### Questions to Work Through

1.  An agent processes 10,000 requests per day.  If you logged the full input prompt and output for every request, what storage and privacy problems would that create?  What would you log instead, and why would that information still be useful for debugging?

    *Hint:* Think about what information you actually need to diagnose a bug versus what information you only think you might need "just in case."  Also consider: what if a user typed their SSN into a prompt?

2.  A metric shows that 95th-percentile latency for your agent doubled between Tuesday and Wednesday.  Explain why a metric alone cannot tell you *why* this happened, and describe the sequence of steps (which other pillars you would consult, in which order) to diagnose the root cause.

    *Hint:* A metric is a summary.  Summaries throw away details to save space.  What details were thrown away here, and which pillar preserves them?

3.  Logs, metrics, and traces all have associated costs: storage, compute, and egress bandwidth.  If you had to pick only two of the three pillars for an MVP deployment of a new agent, which two would you choose and why?  Be explicit about what visibility you are giving up by omitting the third.

    *Hint:* Consider the order of operations for debugging: what do you need first when something goes wrong?  What do you add when you have more time and budget?

---

## Distributed Tracing for Agent Pipelines

> An agent is not a single function; it is a pipeline with multiple steps that each take time and can each fail independently.  When a user complains that your agent gave a wrong answer, you need to know *which step* failed: was it the retriever that returned irrelevant documents, the LLM that ignored those documents, or the tool call that returned bad data?  Distributed tracing gives you a map of every step so you can pinpoint the failure without guessing.
{: .tb-key data-title="Why this matters"}

When an agent receives a query, it may invoke a retriever, call an LLM, execute a tool, and format a response; each of these is a **span** in a **trace**.  A span records its start time, end time, parent span, and any attributes (key-value metadata).  The spans are linked by a common trace ID, so you can visualize the entire causal chain for a single request.

Below is the span tree for an agent handling a Retrieval-Augmented Generation (RAG) query.  Read it top-to-bottom: the root span represents the entire request, and the indented child spans (retrieve, llm_generate, tool_call) each represent one step inside it; notice how the durations add up to reveal where time is actually being spent.

```
[root span] handle_query   duration: 2340ms
|   attributes: user_id=u-42, query_hash=a3f9...
|
|-- [child] retrieve       duration: 410ms
|       attributes: vector_db=pinecone, top_k=5, db_latency_ms=388
|
|-- [child] llm_generate   duration: 1710ms
|       attributes: model=hermes-3, prompt_tokens=1842,
|                  completion_tokens=317, finish_reason=stop
|
`-- [child] tool_call      duration: 180ms
        attributes: tool_name=search_web, success=true,
                   result_chars=4200
```

Attributes on spans are the primary mechanism for answering questions about production behavior.  They turn a timing graph into a searchable, filterable record of what the agent did.  However, attributes must be chosen carefully: they are stored in your tracing backend, may be retained for weeks, and may be exported to third-party vendors.

> Many developers assume that adding more span attributes is always better: "the more data, the more observability."  In practice, storing raw prompt text as a span attribute can expose private user data to your tracing vendor, violate GDPR or FERPA, and generate storage costs that make your traces unusable at scale.  Good observability is about storing the *right* attributes (identifiers and measurements), not the raw content.
{: .tb-pitfall data-title="Common Misconception"}

### Questions to Work Through

4.  Looking at the span tree above, the `llm_generate` span consumed 73% of the total request duration (1710ms out of 2340ms).  Before you decide to optimize the LLM call, what information would you need to determine whether that latency is acceptable or problematic?  Consider both technical and business factors in your answer.

    *Hint:* What does your SLA say?  Is this a synchronous user-facing call or a background batch job?  Does the user experience the full 2340ms, or do you stream tokens as they are generated?

5.  A teammate suggests adding a `prompt_text` attribute to the `llm_generate` span so you can inspect what was sent to the model during debugging.  Identify at least two categories of information that might appear in a RAG prompt that would be inappropriate to store in a tracing backend.  Then propose an alternative approach that gives you the debugging benefit without the privacy risk.

    *Hint:* What documents does a RAG system retrieve?  Who wrote those documents, and did they consent to their content being stored in a third-party analytics system?  What about the user's original question?

6.  The `retrieve` span shows `db_latency_ms=388` out of a total span duration of 410ms.  The remaining 22ms is presumably Python serialization overhead.  If you needed to reduce retrieval latency by 50% (from 410ms to under 205ms), what specific options would you consider, and how would you use the span data to validate that a change actually worked?

    *Hint:* The span tells you where the time is going.  Is it network round-trip to Pinecone, or is it the vector search itself?  Those have different solutions.  How would you measure before and after?
{: start="4"}

---

## OpenTelemetry Integration

> Before OpenTelemetry existed, every observability vendor had its own SDK. Switching from Datadog to Honeycomb meant rewriting all your instrumentation.  OTel solves this the same way USB solved the "every device needs its own cable" problem: one standard API, any backend.  For agents, this means you can instrument your code once and export to whatever backend your employer uses.
{: .tb-key data-title="Why this matters"}

**OpenTelemetry** (OTel) is a vendor-neutral open standard for collecting and exporting telemetry data (traces, metrics, and logs) from applications.  It provides a unified API and SDK so you can instrument your agent once and export to any compatible backend (Jaeger, Honeycomb, Grafana Tempo, etc.) by changing configuration, not code.

The following pseudocode shows how to wrap an agent invocation with OpenTelemetry tracing in Python.  As you read it, notice two things: (1) the setup block runs once at startup and wires up the exporter, and (2) each instrumented function uses `with tracer.start_as_current_span(...)` to create a span; look at which attributes are logged and which sensitive information (like the raw query text) is deliberately omitted.

> This cell needs libraries that are installed in your course container rather than in the page.  Copy it there and run it.
{: .tb-warning data-title="Runs on your machine, not here"}

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# --- Setup (done once at application startup) ---
provider = TracerProvider()
exporter = OTLPSpanExporter(endpoint="http://otel-collector:4317")
provider.add_span_processor(BatchSpanProcessor(exporter))
trace.set_tracer_provider(provider)

tracer = trace.get_tracer("cs357.agent")

# --- Per-request instrumentation ---
def handle_query(user_query: str, user_id: str) -> str:
    with tracer.start_as_current_span("handle_query") as root:
        root.set_attribute("user_id", user_id)
        root.set_attribute("query_length", len(user_query))
        # NOTE: we store query_length (a number), not query text (raw content)

        with tracer.start_as_current_span("llm_generate") as llm_span:
            response = call_llm(user_query)
            llm_span.set_attribute("model_name", response.model)
            llm_span.set_attribute("prompt_tokens", response.usage.prompt_tokens)
            llm_span.set_attribute("completion_tokens", response.usage.completion_tokens)
            llm_span.set_attribute("finish_reason", response.finish_reason)
            # finish_reason values: "stop" (normal), "length" (truncated),
            # "content_filter" (blocked by safety policy)

        return response.text
```

For **SLA tracking**, the attributes you instrument determine what you can measure.  A service level agreement (SLA) might specify: "95th-percentile latency under 2 seconds," "error rate below 0.1%," or "completion token usage under 500 per request."  Each of these requires a specific attribute to be present on spans.

A production agent is silently failing on approximately 8% of queries: users receive a response, but it is unhelpful or factually wrong.  There are currently no logs, metrics, or traces in place.  Which observability pillar would you add FIRST to diagnose this problem?

- Metrics; aggregate rates tell you that 8% of requests failed but cannot tell you what went wrong in any specific request, so you still cannot diagnose the root cause
- Traces; a span tree requires knowing in advance which steps to instrument; without first understanding the failure pattern from logs, you may instrument the wrong spans
- Logs; structured per-request logging of the input, model response, and finish reason gives you the raw evidence needed to identify patterns in the failures before you know what to measure
- All three simultaneously; instrumenting all three at once is expensive and slow to implement; start with the cheapest source of raw evidence and add the others as needed

<details markdown="1"><summary>Answer</summary>

Logs; structured per-request logging of the input, model response, and finish reason gives you the raw evidence needed to identify patterns in the failures before you know what to measure

</details>

### Questions to Work Through

7.  The SLA requires "95th-percentile latency under 2 seconds."  Looking at the pseudocode above, which span attributes are strictly necessary to compute and track this SLA, and which attributes are useful for debugging but contribute nothing to the SLA metric itself?  Be specific about which attributes belong in which category and why.

    *Hint:* To compute a latency percentile, what is the minimum information you need?  The span start and end times are recorded automatically by OTel; what else do you need, and what attributes in the code above are you collecting beyond that minimum?

8.  The `finish_reason` attribute can take values such as `stop` (normal completion), `length` (truncated because the model hit the token limit), or `content_filter` (blocked by a safety policy).  Explain why `finish_reason` is particularly important for detecting quality regressions in production, and write a specific alert rule using it: describe what you monitor, what threshold triggers the alert, and what time window you evaluate over.

    *Hint:* If `finish_reason=length` spikes from 2% to 15% of requests, what does that tell you about your system?  What changed?  What would you check first?

9.  The exporter in the pseudocode sends trace data to `http://otel-collector:4317`; note the `http://` prefix (not `https://`).  In a production system, what specific security concerns does this configuration raise, and what would you change to address each concern?

    *Hint:* Trace data contains user IDs, token counts, and model names.  Who can intercept unencrypted HTTP traffic on your network?  What else might be in those traces that you would not want intercepted?
{: start="7"}

---

## Token Accounting: Counting What Every Call Spends

> Tokens are the one measurement that every cost you care about is built from.  A hosted API bills by the token, a local model spends seconds and watts per token, and the carbon estimate in *Governance, Policy, and the Cost of Inference* starts from a token count.  If you do not record tokens per call, you cannot say which agent in your system is expensive, you cannot catch a loop that is quietly spending ten times its budget, and you cannot write the token section of your final project's Responsible AI Report, which asks for counts measured on every evaluation run.
{: .tb-key data-title="Why this matters"}

A token count is both kinds of telemetry at once.  On a single call it is a **span attribute**: the `llm_generate` span above carries `prompt_tokens` and `completion_tokens`.  Added up over calls, agents, and days it is a **metric**: tokens per run, per agent, per hour.  You do not have to measure it yourself.  Both tools this course uses count every token the model reads and writes and hand you the number; your job is to read it, keep it, and add it up.

| Where you are | Input (prompt) tokens | Output (completion) tokens | Also reported |
|:--|:--|:--|:--|
| **OpenCode**, sidebar during a session | The session's running token total and, when the model's context limit is known, the share of the context window used | (same panel) | The session's cost; `$0.00` for a local Ollama model |
| **OpenCode**, `opencode stats` | Input, totaled over sessions | Output, totaled over sessions | Cache read and write, total cost, average and median tokens per session, and a per-model breakdown with `--models` |
| **OpenCode**, `opencode export <sessionID>` | `tokens.input` on each assistant message | `tokens.output` | `tokens.reasoning`, `tokens.cache.read`, `tokens.cache.write`, `cost`, `modelID`, `agent` |
| **Ollama** native API (`/api/chat`, `/api/generate`) | `prompt_eval_count` | `eval_count` | `prompt_eval_cached_count`, and `total_duration`, `load_duration`, `prompt_eval_duration`, `eval_duration`, all in **nanoseconds** |
| **Ollama** OpenAI-compatible API (`/v1/chat/completions`) | `usage.prompt_tokens` | `usage.completion_tokens` | `usage.total_tokens`; no durations, so time the call yourself |
{: .tb-full}

### Reading Tokens in OpenCode

These commands were checked against opencode 1.18, the version the course container and the [opencode setup tutorial]({{ site.baseurl }}/Tutorials/OpenCodeSetup) install.  Field names in the exported JSON can change between releases, so if a key below is missing, open the file and look before you conclude the count is zero.

**During a session.**  The TUI sidebar has a Context panel with the session's token count and cost.  If the sidebar is hidden, `ctrl+x b` toggles it (the leader key is `ctrl+x`; see the [keybinds reference](https://opencode.ai/docs/keybinds/)).  The percentage of the context window it shows depends on opencode knowing the model's window, which for an Ollama model is the `limit.context` value in that model's entry in `opencode.json` ([providers reference](https://opencode.ai/docs/providers/)).  The cost reads `$0.00` for a local model.  That is the bill you avoided, not the energy you spent.

**Across sessions.**  `opencode stats` prints token and cost totals for every session on your machine ([CLI reference](https://opencode.ai/docs/cli/)):

```bash
opencode stats                        # everything, all time, all projects
opencode stats --days 1 --project ""  # today, in the current project only
opencode stats --days 7 --models      # the last week, broken down by model
```

**Per message.**  `opencode session list` finds the session, and `opencode export` writes it as JSON.  Each assistant message in the export carries its own `tokens` block, and opencode reports cache reads separately from input, so the prompt the model actually saw on a call is `input` plus `cache.read`.  The script below totals one export.

```bash
opencode session list -n 5                           # newest five sessions, with their IDs
opencode export ses_XXXXXXXX > session.json          # the full session as JSON
python opencode_tokens.py session.json
```

```python
"""Total the token counts in one `opencode export` file.  Usage: python opencode_tokens.py session.json"""
import json
import sys

raw = open(sys.argv[1], encoding="utf-8").read()
session = json.loads(raw[raw.index("{"):])      # skip anything a plugin printed before the JSON

rows = []
for msg in session["messages"]:
    info = msg["info"]
    if info.get("role") != "assistant":
        continue
    t = info.get("tokens") or {}
    cache = t.get("cache") or {}
    rows.append((info.get("agent", ""), info.get("modelID", ""), t.get("input", 0),
                 t.get("output", 0), t.get("reasoning", 0), cache.get("read", 0),
                 info.get("cost", 0)))

print(f"{'agent':<8} {'model':<22} {'input':>8} {'output':>7} {'reason':>7} {'cache_rd':>9}")
for agent, model, inp, out, rsn, crd, _ in rows:
    print(f"{agent:<8} {model:<22} {inp:>8} {out:>7} {rsn:>7} {crd:>9}")
print(f"{len(rows)} assistant messages: {sum(r[2] for r in rows)} input, {sum(r[3] for r in rows)} output, "
      f"{sum(r[4] for r in rows)} reasoning tokens; cost ${sum(r[6] for r in rows):.4f}")
```

> An export is the whole transcript: every prompt, every file the agent read, every command it ran.  Take the numbers out of it and do not commit the file itself.  `opencode export --sanitize` redacts transcript and file data if you need to share one.  The `/export` command inside the TUI is a different thing: it writes the conversation as Markdown, without the token fields.
{: .tb-warning data-title="Watch out"}

### Counting Tokens Programmatically with Ollama

Every non-streaming response from Ollama's `/api/chat` and `/api/generate` carries its own usage counters ([Ollama usage reference](https://docs.ollama.com/api/usage)).  A response looks like this, trimmed:

```json
{"model": "llama3.2", "done": true, "done_reason": "stop",
 "total_duration": 2773000000, "load_duration": 12000000,
 "prompt_eval_count": 412, "prompt_eval_duration": 610000000,
 "eval_count": 41, "eval_duration": 2100000000}
```

`prompt_eval_count` is input tokens and `eval_count` is output tokens.  Every duration is in nanoseconds, so generation speed is `eval_count / eval_duration * 10**9`: here 41 tokens in 2.1 seconds, about 19.5 tokens per second.  `prompt_eval_duration` is the time to read the prompt, which grows with the history you resend, and `load_duration` is the cost of loading the model, paid once when it is cold.

The module below is the `chat` helper from *The Agent Loop: Perceive, Plan, Act* with one change: the inner call returns the whole response instead of only the text, so the counts are not thrown away.  A decorator, `metered`, records every call the wrapped function makes as one CSV row, and `summarize` totals a run per agent.

> This needs Ollama running on your machine and `pip install requests`.  Copy it to `token_usage.py` beside your agent.  Inside the course container, change `localhost` to `host.docker.internal`, the same address rule the opencode setup tutorial gives.
{: .tb-warning data-title="Runs on your machine, not here"}

```python
"""Count every token an agent spends: one CSV row per model call."""
import csv
import functools
import os
import traceback
import uuid
from datetime import datetime, timezone

import requests

OLLAMA_URL = "http://localhost:11434/api/chat"
MODEL = "llama3.2"
USAGE_CSV = "token_usage.csv"
RUN_ID = "run-" + uuid.uuid4().hex[:6]   # one id per run; put the same id in your trace
NS = 1e9                                 # Ollama reports every duration in nanoseconds
FIELDS = ["ts", "run_id", "agent", "model", "input_tokens", "output_tokens",
          "cached_input_tokens", "prompt_eval_s", "eval_s", "total_s",
          "tokens_per_s", "done_reason"]


def record_usage(data, agent):
    """Append one row to USAGE_CSV from a response, or from the final streamed chunk."""
    try:
        out_tok = data.get("eval_count", 0)
        eval_s = data.get("eval_duration", 0) / NS
        row = {
            "ts": datetime.now(timezone.utc).isoformat(timespec="seconds"),
            "run_id": RUN_ID,
            "agent": agent,
            "model": data.get("model", MODEL),
            "input_tokens": data.get("prompt_eval_count", 0),
            "output_tokens": out_tok,
            "cached_input_tokens": data.get("prompt_eval_cached_count", 0),
            "prompt_eval_s": round(data.get("prompt_eval_duration", 0) / NS, 3),
            "eval_s": round(eval_s, 3),
            "total_s": round(data.get("total_duration", 0) / NS, 3),
            "tokens_per_s": round(out_tok / eval_s, 1) if eval_s else 0.0,
            "done_reason": data.get("done_reason", ""),
        }
        new_file = not os.path.exists(USAGE_CSV)
        with open(USAGE_CSV, "a", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=FIELDS)
            if new_file:
                writer.writeheader()
            writer.writerow(row)
        print(f"[{agent}] in={row['input_tokens']} out={out_tok} "
              f"{row['tokens_per_s']} tok/s, {row['total_s']} s")
        return row
    except Exception as e:
        print(f"[token_usage:record_usage] {e}")
        traceback.print_exc()
        return None


def metered(agent):
    """Decorator: record the tokens of every call the wrapped function makes."""
    def decorate(call):
        @functools.wraps(call)
        def wrapper(*args, **kwargs):
            data = call(*args, **kwargs)
            if data:
                record_usage(data, agent)
            return data
        return wrapper
    return decorate


def ollama_chat(messages, temperature=0.7):
    """The course helper with one change: it returns the whole response, not only the text."""
    try:
        r = requests.post(OLLAMA_URL, json={
            "model": MODEL,
            "messages": messages,
            "stream": False,
            "options": {"temperature": temperature}
        }, timeout=120)
        r.raise_for_status()
        return r.json()
    except Exception as e:
        print(f"[token_usage:ollama_chat] {e}")
        traceback.print_exc()
        return {}


def summarize(path=USAGE_CSV, run_id=RUN_ID):
    """Total the CSV for one run, per agent and overall."""
    totals = {}
    try:
        with open(path, newline="") as f:
            for row in csv.DictReader(f):
                if row["run_id"] != run_id:
                    continue
                t = totals.setdefault(row["agent"], {"calls": 0, "in": 0, "out": 0, "s": 0.0})
                t["calls"] += 1
                t["in"] += int(row["input_tokens"])
                t["out"] += int(row["output_tokens"])
                t["s"] += float(row["total_s"])
    except Exception as e:
        print(f"[token_usage:summarize] {e}")
        traceback.print_exc()
    print(f"\nRun {run_id}")
    print(f"{'agent':<10} {'calls':>5} {'input':>7} {'output':>7} {'seconds':>8}")
    for agent, t in totals.items():
        print(f"{agent:<10} {t['calls']:>5} {t['in']:>7} {t['out']:>7} {t['s']:>8.1f}")
    grand_in = sum(t["in"] for t in totals.values())
    grand_out = sum(t["out"] for t in totals.values())
    print(f"Run total: {grand_in} input + {grand_out} output = {grand_in + grand_out} tokens")
    return totals
```

**Wrapping an existing agent loop.**  Your loop already calls `chat(messages)` and expects text back.  Keep that contract and change only what `chat` calls underneath, so no line of the loop changes and every call is counted.  Wrap the inner call once per agent, and each agent's tokens land in the CSV under its own name:

```python
from token_usage import metered, ollama_chat, summarize

planner_call = metered("planner")(ollama_chat)
critic_call = metered("critic")(ollama_chat)

def chat(messages, temperature=0.7, call=planner_call):
    """Drop-in replacement for the course helper: same arguments, same return value."""
    data = call(messages, temperature)
    return (data.get("message") or {}).get("content", "")

plan = chat([{"role": "user", "content": "In two sentences, plan how to find when Ursinus College was founded."}])
review = chat([{"role": "user", "content": "Critique this plan in one sentence: " + plan}], call=critic_call)
summarize()
```

Each call prints a line such as `[planner] in=412 out=41 19.5 tok/s, 2.773 s`, appends a row to `token_usage.csv`, and `summarize()` ends the run with a per-agent table and a total.  Run the script three times and the CSV holds three runs, separated by `run_id`, which is exactly the token table the Responsible AI Report asks for.  Put the same `run_id` in your JSON-lines trace and a row in the CSV can be matched to the steps that spent it.

**Streaming.**  With `"stream": true`, Ollama sends many small chunks, and only the **last one**, the chunk with `"done": true`, carries `prompt_eval_count`, `eval_count`, and the durations.  A streaming helper therefore has to keep that final chunk and hand it back; because it does, the same `metered` decorator works on it unchanged:

```python
import json
import traceback

import requests
from token_usage import OLLAMA_URL, MODEL

def ollama_chat_stream(messages, temperature=0.7):
    """Streaming version.  The counts arrive only in the last chunk, the one with done=true."""
    text, final = [], {}
    try:
        with requests.post(OLLAMA_URL, json={
            "model": MODEL,
            "messages": messages,
            "stream": True,
            "options": {"temperature": temperature}
        }, stream=True, timeout=120) as r:
            r.raise_for_status()
            for line in r.iter_lines():
                if not line:
                    continue
                chunk = json.loads(line)
                piece = (chunk.get("message") or {}).get("content", "")
                print(piece, end="", flush=True)
                text.append(piece)
                if chunk.get("done"):
                    final = chunk            # prompt_eval_count and eval_count live here
        print()
        if final:
            final["message"] = {"role": "assistant", "content": "".join(text)}
        return final
    except Exception as e:
        print(f"[token_usage:ollama_chat_stream] {e}")
        traceback.print_exc()
        return {}
```

A helper that stops reading when the text looks finished, or keeps only the text, loses the counts for that call.  That is the most common reason a token table has zeros in it.

**The OpenAI-compatible endpoint.**  If your agent talks to `http://localhost:11434/v1/chat/completions`, as opencode and most frameworks do, the counts are in `usage` instead: `resp.json()["usage"]["prompt_tokens"]` and `["completion_tokens"]`.  Ollama fills them from the same two counters ([Ollama source, `openai/openai.go`](https://github.com/ollama/ollama/blob/main/openai/openai.go)), but this response carries no durations, so time the call yourself.  When streaming through this endpoint, ask for the usage chunk with `"stream_options": {"include_usage": true}`.

### Tokens as a Trace Attribute

The OpenTelemetry example above named its attributes `prompt_tokens` and `completion_tokens`, which works but is private to your code.  The OpenTelemetry GenAI semantic conventions define shared names, so any backend that understands them can chart tokens without being told what your fields mean ([GenAI spans](https://github.com/open-telemetry/semantic-conventions-genai/blob/main/docs/gen-ai/gen-ai-spans.md)):

| Convention attribute | From Ollama | Meaning |
|:--|:--|:--|
| `gen_ai.operation.name` | `"chat"` | What kind of call this was |
| `gen_ai.request.model` | `MODEL` | The model you asked for |
| `gen_ai.usage.input_tokens` | `prompt_eval_count` | Tokens in the prompt |
| `gen_ai.usage.output_tokens` | `eval_count` | Tokens in the response |
| `gen_ai.usage.cache_read.input_tokens` | `prompt_eval_cached_count` | Input tokens served from cache |
| `gen_ai.response.finish_reasons` | `[done_reason]` | Why generation stopped, as a list |
{: .tb-full}

The conventions recommend naming the span `{gen_ai.operation.name} {gen_ai.request.model}`, so the span becomes `chat llama3.2`:

```python
with tracer.start_as_current_span(f"chat {MODEL}") as span:
    data = ollama_chat(messages)
    span.set_attribute("gen_ai.operation.name", "chat")
    span.set_attribute("gen_ai.request.model", MODEL)
    span.set_attribute("gen_ai.usage.input_tokens", data.get("prompt_eval_count", 0))
    span.set_attribute("gen_ai.usage.output_tokens", data.get("eval_count", 0))
    span.set_attribute("gen_ai.response.finish_reasons", [data.get("done_reason", "")])
```

These attributes are still marked *Development* in the specification, and the GenAI conventions have moved from the main semantic-conventions site to their [own repository](https://github.com/open-telemetry/semantic-conventions-genai), where the token *metrics* are also being reorganized.  Record the span attributes above, keep your CSV as the metric, and check the repository before you build a dashboard on a metric name.

> "The dashboard said $0.00, so the run was free."  A local model has no invoice, but it still reads and writes every token, and each one costs seconds of your GPU and watts from the wall.  The count is the same whether or not anyone bills for it, which is why the Responsible AI Report asks for tokens rather than dollars, and converts them to energy, carbon, and cost using the method in *Governance, Policy, and the Cost of Inference*.
{: .tb-pitfall data-title="Common Misconception"}

### Questions to Work Through

10.  Run the same question through your agent twice, once with a fresh history and once after ten turns.  `eval_count` barely changes but `prompt_eval_count` and `prompt_eval_duration` grow.  Explain why, and say which of the two numbers an agent that resends its whole history is really paying for.

     *Hint:* Every turn resends every earlier turn as input.  What does the small context principle from the Observability session say to do about it, and which column of your CSV would show that it worked?

11.  Your multi-agent system's CSV shows the critic agent using 70% of all input tokens but only 10% of output tokens.  What does that pattern suggest the critic is being sent, and what one change would you test first?

     *Hint:* High input and low output means a long prompt and a short answer.  Does the critic need the whole transcript, or only the draft it is judging?

12.  `opencode stats` reports $0.00 for a week of local work and 2.1 million input tokens.  A teammate writes "our agent use had no cost" in the Responsible AI Report.  Rewrite that sentence so that someone outside the team could check it against your logs.

     *Hint:* Name the token count, the time it took, and what converts either one into energy, carbon, or a comparable hosted price, with the assumption stated.
{: start="10"}

---

## Exercises

Everything below is optional.  Nothing here is collected and nothing here is graded; this is a tutorial, and the exercises exist so that you can design the spans, attributes, and alerts for a real agent rather than only read about them.  Each one ends with a check you apply yourself, so you can tell whether it worked.

1.  **Trace tree design.**

    *What to do:* A 3-step ReAct loop for a research agent consists of: (1) the agent deciding to search the web, (2) executing the web search tool, (3) the agent synthesizing results and deciding whether to search again or answer.  Draw the full span tree for one complete ReAct iteration that ends with an answer.  Label each span with its name, key attributes, and approximate duration.  Indicate parent-child relationships with indentation or arrows.

    *Starter hint:* Start with a root span called `react_loop` that contains the full iteration.  Under it, create child spans for `plan` (the LLM deciding what to do), `tool_execute` (the actual web search), and `synthesize` (the LLM reading results).  For each span, think: what measurement or identifier would help you debug a failure in that specific step?  Example attributes for `tool_execute`: `tool_name=search_web`, `query_text_length=45`, `results_returned=5`, `duration_ms=320`.

    *You've succeeded when:* Your tree shows clear parent-child relationships, every span has at least two non-trivial attributes, and a classmate could use your diagram to identify which step was the bottleneck in a hypothetical slow request.

2.  **PII audit.**

    *What to do:* Review the following list of candidate span attributes and classify each as "safe to store in traces," "store with caution (explain the specific concern)," or "do not store (explain the specific harm)."  Attributes: `user_id`, `full_prompt_text`, `retrieved_document_ids`, `retrieved_document_content`, `model_name`, `finish_reason`, `user_email`, `response_text`, `session_duration_ms`, `ip_address`.

    *Starter hint:* Ask yourself three questions for each attribute: (1) Is this a measurement/identifier, or is it raw content?  (2) Could it reveal information about a specific person to someone who reads the trace?  (3) Is it needed for debugging, or is a derived version (like a hash or length) equally useful?  For example, `user_id` is typically a pseudonymous identifier, safer than `user_email`, which is directly identifying.

    *You've succeeded when:* Every attribute has a classification and a one-sentence justification that cites a specific risk or a specific reason it is safe.  You should have at least one attribute in each category.

3.  **Alert design.**

    *What to do:* You are the on-call engineer for a deployed advising agent at a university.  Design an alerting policy with at least three separate alert rules covering different failure modes.  For each rule, specify: (a) which metric or trace attribute to monitor, (b) the threshold value that triggers the alert, (c) the time window over which the threshold is evaluated, (d) who gets paged, and (e) what the first step of the runbook is.

    *Starter hint:* Consider these three failure modes as a starting point: (1) the agent is returning `finish_reason=content_filter` too often, which may indicate the system prompt is misconfigured; (2) the `retrieve` span latency is spiking, which may indicate the vector database is under load; (3) `completion_tokens` per request is rising, which may indicate a prompt injection is causing the model to generate unusually long responses.  Each of these needs different thresholds and different first responders.

    *You've succeeded when:* Each rule has a concrete, measurable threshold (not "if it gets too slow") and a runbook step that a new team member could follow without guessing what to do.

4.  **Meter a real run.**

    *What to do:* Put `token_usage.py` beside an agent you have already built (the Local Agent lab, or a two-agent pipeline), wrap its model calls with `metered`, and run it on three tasks.  Then do one task by hand in opencode with the same model and record what `opencode stats --days 1 --project ""` reports before and after.

    *Starter hint:* If one agent's row is missing from the CSV, that agent calls the model through a path you did not wrap.  Search the code for every `requests.post` and every client call; each one needs the decorator, or the total is an undercount.

    *You've succeeded when:* Your CSV has one row per model call for all three tasks, `summarize()` names the agent that spent the most input tokens, and you can state in one sentence why that agent is the expensive one.

---

## Reflection Prompt

**Personal level:** Describe a time when you could not tell why a program you wrote was behaving unexpectedly.  What would you have needed to observe to diagnose it faster?  How does that experience relate to what you learned today about observability?

**Technical level:** What would you need to observe to prove (not just believe, but demonstrate with evidence) that your agent is NOT hallucinating in production?  Describe the specific logs, metrics, or trace attributes you would collect, how you would analyze them, and what limitation you would still have even with perfect observability in place.

**Societal level:** Observability data creates a detailed record of what users asked an AI system and what it said.  Who should have access to that record: the deploying organization, the model vendor, regulators, the users themselves?  What privacy rights should users have over the observability data collected about their interactions with AI?

---

**Coming Up Next:** In the next activity, we examine how regulatory frameworks (the EU AI Act, NIST AI RMF, and sector rules) determine what you are legally required to observe, log, and audit, and what records you must keep when something goes wrong.

---

## Further Reading

- OpenTelemetry Documentation: https://opentelemetry.io/docs/
- OpenTelemetry Semantic Conventions for LLMs (GenAI): https://opentelemetry.io/docs/specs/semconv/gen-ai/
- Honeycomb.  "Observability Engineering."  O'Reilly Media, 2022.
- Charity Majors.  "Observability: the Big Picture." https://charity.wtf/2020/03/03/observability-is-a-many-splendored-thing/
- Jaeger Distributed Tracing: https://www.jaegertracing.io/
- OpenTelemetry GenAI Semantic Conventions, now in their own repository: https://github.com/open-telemetry/semantic-conventions-genai
- Ollama API, usage fields: https://docs.ollama.com/api/usage
- opencode CLI reference, including `stats`, `export`, and `session list`: https://opencode.ai/docs/cli/
