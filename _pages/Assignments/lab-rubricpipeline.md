---
layout: assignment
permalink: /Assignments/RubricPipeline
title: "CS357: Foundations of Artificial Intelligence - Lab: Rubric Pipeline"

info:
  coursenum: CS357
  purpose: "To turn the LLM judge you built in class into a batch grading pipeline, and to prove with human-agreement and bias tests whether that judge can be trusted."
  tilt:
    task: "Build a batch pipeline that scores submissions against a JSON rubric into a CSV, then validate it against blind human scores and measure a judge bias."
    criteria: "I grade this on the batch scoring pipeline, human-to-judge agreement on a blind calibration set, and an empirical bias measurement.  Please read the rubric below for the details."
  points: 100
  goals:
    - To build a batch pipeline that scores a folder of submissions against a JSON rubric using a local model and emits a CSV report with per-criterion evidence and a weighted total
    - To verify quoted evidence programmatically against source artifacts and report a hallucinated-evidence rate
    - To validate the judge against blind human scores on a calibration set using percent agreement or Cohen's kappa
    - To measure at least one judge bias empirically with a controlled experiment and propose a concrete countermeasure
    - To express the judge's expected behavior as a versioned, declarative eval configuration in an industry harness (promptfoo or Inspect AI) and demonstrate a regression run against a golden set
    - To design a structured evaluation dataset with golden, stylistic, and adversarial question categories that expose distinct failure modes in an agent
    - To implement multiple automated evaluation metrics including exact match, G-Eval LLM-as-judge scoring, and semantic similarity
    - To identify regressions and improvements by running a controlled before-and-after comparison on a well-defined eval set
    - To integrate the evaluation harness into a CI/CD pipeline that enforces a minimum pass rate on every code push
    - To instrument an AI agent with OpenTelemetry spans, capturing LLM call metadata, tool call metadata, and retrieval metadata as structured attributes
    - To design span attribute schemas that balance diagnostic value against verbosity and PII exposure
    - To analyze distributed traces in Jaeger or Zipkin to locate latency hotspots and diagnose failure modes
    - To write operational alert rules and a runbook that translates trace-derived thresholds into on-call actions
    - To implement test-driven development practices for non-deterministic agent outputs using semantic, format, and safety test patterns
    - To configure and run automated code quality tools including formatters, linters, and coverage reporters on an agentic Python project
    - To construct a GitHub Actions CI pipeline that validates formatting, linting, and test coverage on every push and pull request
    - To package and publish an AI agent as a pip-installable wheel to TestPyPI and as a container image to the GitHub Container Registry
  rubric:
    - weight: 25
      description: Pipeline Implementation
      preemerging: The pipeline fails to run due to major issues, or the program fails to run
      beginning: The pipeline runs but fails on the test submissions due to one or more minor issues
      progressing: The pipeline scores the corpus of submissions against the rubric and emits well formed results (CSV on the code path; captured harness output on the no-code path (promptfoo)), with a fragile component such as output-parsing fallback or evidence capture
      proficient: The batch scorer processes the full synthetic corpus end-to-end without failing and emits one result row per artifact with per-criterion outcomes and an overall result (code path, CSV with level labels, quoted evidence strings, and a weighted total; the no-code path (promptfoo), per-criterion judge verdicts across all dataset items); malformed or unusable judge output is surfaced rather than guessed at (code path, a "REVIEW_NEEDED" flag with the raw output logged; the no-code path (promptfoo), noted and re-run); the rubric, model, paths, and settings live in configuration files, not hardcoded; a terminal screenshot or log confirms the end-to-end run on the full corpus
    - weight: 20
      description: Human Agreement Validation
      preemerging: No human validation is attempted
      beginning: Human scores exist but are collected after seeing the judge output, or agreement is not quantified
      progressing: Both partners independently score a calibration set before running the judge, and human to human and human to judge agreement are reported
      proficient: Both partners independently score the calibration set (at least eight artifacts on the code path; all fifteen on the no-code path (promptfoo)) blind to the judge; agreement is quantified per criterion as percent agreement or Cohen's kappa (the no-code path (promptfoo) uses percent agreement plus the written disagreement analysis of the three worst mismatches); the criterion with the worst human-to-judge gap is identified; a rubric revision is tested and before/after agreement is reported in a table; all human score sheets are included in the submission
    - weight: 20
      description: Bias Measurement
      preemerging: No bias probe is attempted
      beginning: A bias is discussed but not measured
      progressing: One judge bias (position/order, verbosity, or byline) is measured with a controlled experiment
      proficient: At least one judge bias is measured with a controlled experiment (code path, at least four matched pairs; the no-code path (promptfoo), the reordered and padded dataset variants over all items); the effect is quantified (e.g., "the judge awarded 0.8 more points on average when the longer essay appeared first," or "padding flipped 5 of 60 verdicts"); a countermeasure is implemented or prescribed with a concrete code, configuration, or prompt change; the residual risk after the countermeasure is stated honestly
    - weight: 15
      description: Evidence Verification
      preemerging: The judge's evidence or stated reasoning is not collected
      beginning: The judge's evidence or stated reasoning is collected but never checked against the source
      progressing: The judge's evidence or stated reasoning is spot checked by hand with a reported faithfulness rate
      proficient: The judge's grounding is verified against the source artifacts (code path, evidence quotes checked programmatically by exact substring or fuzzy match with the stated threshold, hallucinated quotes flagged in the CSV with a "HALLUCINATED_EVIDENCE" marker, and the hallucinated evidence rate reported, e.g., "3 of 48 quotes, 6.25%"; the no-code path (promptfoo), the judge's stated reasoning for the three worst human-judge mismatches is checked line-by-line against the answer text, with unfaithful or fabricated reasoning called out in the disagreement analysis)
    - weight: 10
      description: Reproducible Eval Harness
      preemerging: No declarative eval configuration is attempted
      beginning: A harness (promptfoo or Inspect AI) is installed and runs, but the eval cases do not correspond to the pipeline's golden set, or results are not captured
      progressing: The judge's expected behavior is expressed as a versioned eval configuration over the golden calibration set, and one full harness run against the local model is captured
      proficient: A versioned eval configuration (promptfoo YAML or an Inspect AI task) encodes the calibration set with at least one assertion per case; the configuration is committed alongside the submission; a before-and-after regression run demonstrates that a deliberate change to the judge prompt or rubric is caught by the harness, with both result sets included and a short interpretation in the readme (on the no-code path (promptfoo) the whole path is such a configuration, and the Part 5 regression diff satisfies this row)
    - weight: 10
      description: Writeup, Reflection, and Submission
      preemerging: An incomplete submission is provided
      beginning: The program is submitted, but not according to the directions in one or more ways
      progressing: The program is submitted according to the directions with a minor omission, with at least superficial responses to the reflection prompts
      proficient: The work is submitted according to the directions, including a readme writeup, a pair log with at least two timestamped role swaps, all human score sheets, and reflection answers that each cite a specific agreement figure (kappa or percent agreement), bias effect size, or evidence-faithfulness finding from the lab rather than restating the prompt
  readings:
    - rtitle: "Critique, Consensus, and the LLM Judge: One Loop, Three Uses"
      rlink: "Activities/liascript-critiqueconsensusjudge.md"
      liapage: true
    - rtitle: "Evaluating Outputs Activity"
      rlink: "Activities/liascript-evaluatingoutputs.md"
      liapage: true
    - rtitle: "Testing Agents"
      rlink: "../Tutorials/TestingAgents"
    - rtitle: "Evaluating Agents With a Rubric: The Judge Pipeline Workshop"
      rlink: "Activities/liascript-rubricworkshop.md"
      liapage: true
    - rtitle: "Observability"
      rlink: "../Tutorials/Observability"
    - rtitle: "Publishing: GHCR, Docker Hub, and npm"
      rlink: "../Tutorials/Publishing"
    - rtitle: "Coding Agents: OpenCode, Spec-First Development, Hooks, and Reading the Diff"
      rlink: "Activities/liascript-codingagents.md"
      liapage: true
    - rtitle: "Rubric Pipeline starter pack (rubric, twelve synthetic submissions, promptfoo dataset)"
      rlink: "../files/rubric-pipeline-starter.zip"
    - rtitle: "Ollama API Documentation"
      rlink: "https://github.com/ollama/ollama/blob/main/docs/api.md"
    - rtitle: "promptfoo Documentation (Part 5, Option A)"
      rlink: "https://www.promptfoo.dev/docs/intro/"
    - rtitle: "Inspect AI Documentation (Part 5, Option B)"
      rlink: "https://inspect.aisi.org.uk/"
    - rtitle: "pytest Documentation"
      rlink: "https://docs.pytest.org/en/stable/"
    - rtitle: "Python Packaging User Guide"
      rlink: "https://packaging.python.org/en/latest/tutorials/packaging-projects/"

tags:
  - evaluation
  - llm-as-judge
  - pipelines
  - testing
  - ci
  - observability
  - opentelemetry
  - monitoring
  - ci-cd
  - publishing
  - tdd

---


In this lab you and your partner turn the judge you built in class into a batch grading pipeline, then measure whether that judge deserves to be trusted.  A JSON rubric and a folder of submissions go in.  A table of per-criterion scores, quoted evidence, and weighted totals comes out.  You then test that table three ways: against blind human scores, against the source text the evidence claims to quote, and against a deliberate bias probe.  **All submissions in this lab are synthetic artifacts; no real student work may be used.**  The starter pack gives you a rubric and twelve synthetic paragraphs, and you write at least two more yourselves.  You complete this lab in pairs, using driver/navigator roles, swapping at least every 30 minutes and keeping a swap log.

I hand this lab out at *Evaluating Agents With a Rubric: The Judge Pipeline Workshop*, where you build the in-class judge this lab scales up; that judge comes from the critic-and-judge loop in *Critique, Consensus, and the LLM Judge: One Loop, Three Uses*.  See the course schedule for the assigned and due dates.

A few terms recur on this page, so here they are up front.  A rubric is a list of criteria, each with a weight and a set of observable levels, written so that two graders reading the same text land on the same score.  An LLM as judge is a language model prompted to score an artifact against that rubric instead of writing the artifact itself.  Human agreement is the rate at which independent scores match: human to human, or human to judge.  A bias measurement is a controlled experiment that changes one feature the rubric does not care about (length, position, author name) and records how far the score moves.  Fail closed means that when the judge returns output the pipeline cannot parse, the pipeline flags the row for a human instead of guessing a score.

---

## Choose Your Path

There are two paths through this lab.  Both use the same starter rubric and corpus, both run against your local Ollama model, and both produce the same measurements.  What differs is whether you write the pipeline in Python or describe it in a promptfoo configuration file.

| Path | What you build | What you need | Pick this if |
|------|----------------|---------------|--------------|
| **Code** | A Python script that walks the `submissions/` folder, prompts the judge for strict JSON, fails closed on bad output, writes `grades.csv`, verifies every evidence quote, and runs a matched-pair bias probe; then a promptfoo or Inspect AI harness over your golden set | Python 3, `pip install requests`, local Ollama with `llama3.2` | You want to own the parsing, the CSV, and the evidence check, and you are comfortable reading a 150-line script |
| **No-code** | promptfoo YAML files that score every row of `dataset.csv` with `llm-rubric` assertions, plus two dataset variants for the bias probe and a deliberately regressed config for the regression diff; the evidence check is a written faithfulness analysis | Node.js and `npx` (promptfoo installs itself), local Ollama with `llama3.2`, a spreadsheet | You want your attention on the rubric wording and the judge's reasoning rather than on Python, or you have not written much code yet |

The rubric at the top of this page is the same on both paths; each rubric row names what it means on each path in parentheses.

---

## Before You Start

**Prep deck.**  [Testing Agents: Evaluation, Regression, and the Non-Determinism Problem]({{ site.baseurl }}/Tutorials/TestingAgents) sets up the judge-calibration work this lab grades.

Complete these two activities before you install anything:

- [Evaluating Agents With a Rubric: The Judge Pipeline Workshop]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-rubricworkshop.md): judge prompting, structured output, fail-closed policies
- [Evaluating Outputs Activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-evaluatingoutputs.md): agreement metrics, bias taxonomy, evidence faithfulness

**The starter pack.**  Download [rubric-pipeline-starter.zip]({{ site.baseurl }}/files/rubric-pipeline-starter.zip) and unzip it into your lab folder.  It contains `rubric.json` (four criteria, four named levels each, weights summing to 100), `submissions/s01.txt` through `s12.txt` (twelve synthetic persuasive paragraphs spanning strong, adequate, and weak, plus an empty file, an off-topic recipe, and a verbose paragraph that never makes a claim), `dataset.csv` (the same twelve paragraphs in the two-column form promptfoo reads), and a `README.md` that names the planted edge cases and lists the intended quality tier per id.  Do not read the tier table until you have recorded your own blind scores in Part 2.

Both paths need Ollama running with the `llama3.2` model, as in the earlier labs.  Start it with `ollama serve` in a separate terminal and leave that terminal open.

### Install: code path

```bash
# requests talks to Ollama; thefuzz is optional and only used for fuzzy evidence matching in Part 3
pip install requests
pip install thefuzz python-Levenshtein
```

Health check.  This command sends one chat request to Ollama and asks for a tiny JSON object back; if it prints, your model answers structured-output requests:

```bash
python3 -c "
import requests, json
r = requests.post('http://localhost:11434/api/chat', json={
    'model': 'llama3.2',
    'messages': [{'role': 'user', 'content': 'Respond with only this JSON: {\"test\": \"ok\"}'}],
    'stream': False
})
print(r.json()['message']['content'])
"
```

Expected output:

```json
{"test": "ok"}
```

### Install: no-code path

promptfoo is an evaluation harness: you describe prompts, a model, test cases, and assertions in a YAML file, and one command runs them all.  Its `llm-rubric` assertion is an LLM as judge, a model prompted to decide whether an answer meets a stated criterion.  Install Node.js from [https://nodejs.org](https://nodejs.org), version **22.22 or newer**; promptfoo refuses to start on anything older, and the version your package manager offers is often older than that, so check with `node --version` first.  `npx` then downloads promptfoo on first use, so nothing else needs a global install.

```bash
mkdir cs357-rubric-nocode
cd cs357-rubric-nocode
npx promptfoo@latest init
```

The `init` command scaffolds a `promptfooconfig.yaml`.  Replace its contents with this smoke test, which asks the model one question and checks the answer for one word:

```yaml
# smoke-test promptfooconfig.yaml: verify that promptfoo can reach Ollama
description: "Rubric Pipeline Lab smoke test"

prompts:
  - "Reply with exactly one word: the capital of France."

providers:
  - ollama:chat:llama3.2

tests:
  - assert:
      - type: contains
        value: "Paris"
```

Health check:

```bash
npx promptfoo@latest eval
```

Expected output (the last lines of the run):

```text
Successes: 1
Failures: 0
Pass Rate: 100.00%
```

`npx promptfoo@latest view` opens the results in your browser.  If promptfoo cannot reach Ollama, confirm that `curl http://localhost:11434/api/tags` responds.  If your Ollama runs elsewhere, promptfoo reads the base URL from the `OLLAMA_BASE_URL` environment variable.

> **Time budget.**  Code path: 3-4 hours.  No-code path: 3-4 hours.  Writeup on either path: 30-45 minutes.  Plan two or three pair sessions; the blind scoring in Part 2 needs both partners present and cannot be compressed.

| Part | Code path | No-code path |
|------|-----------|--------------|
| Part 1: Build the pipeline | 60-75 min | 45-60 min |
| Part 2: Validate against humans | 40-50 min | 50-60 min |
| Part 3: Verify the evidence | 25-30 min | folded into Part 2 |
| Part 4: Measure a bias | 35-45 min | 40-50 min |
| Part 5: Regression harness | 30-40 min | 30-40 min |
| Writeup | 30-45 min | 30-45 min |

---

## Part 1: Build the Pipeline (25 points)

The pipeline does four things.  It walks a folder of text submissions with every setting externalized (paths, model, rubric file, temperature, seed).  It prompts your local model to award a level per criterion with a quoted sentence of evidence, returning strict JSON.  It fails closed on malformed judge output, flagging the row for human review and printing the exception and traceback instead of guessing.  It emits a CSV with one row per submission: filename, per-criterion level and evidence, weighted total, and any flags.

Your corpus is the starter pack's twelve submissions plus at least two of your own.  One of your two must be designed to fool the judge: a paragraph that looks like it meets a criterion on the surface but does not (for example, one that uses every transition word in the rubric and never makes a claim, or one that cites a precise-sounding number that supports nothing).  Everything you write is synthetic.

### Step 1.1: Unpack the starter pack and read the rubric

> **Do this.**
> 1. Unzip `rubric-pipeline-starter.zip` so that `rubric.json`, `submissions/`, `dataset.csv`, and `README.md` sit in your lab folder.
> 2. Open `rubric.json` and read all sixteen level descriptors.  Each level has a number (4 down to 1), a name (proficient, progressing, beginning, preemerging), and one sentence saying what must be visible in the text.
> 3. Read `submissions/s01.txt` and `submissions/s08.txt` and decide, for one criterion, which level each one earns.  Do not open the tier table in `README.md` yet.

The shape of the file matters because the code below reads it: a `criteria` list, where each criterion has an `id`, a `name`, an integer `weight`, and a `levels` list of objects with a numeric `level`, a `name`, and a one-sentence `descriptor`.

> **You should see.** Four criteria (`C1` thesis clarity, `C2` evidence, `C3` organization, `C4` mechanics) with weights 30, 30, 20, and 20, and four levels each, listed from 4 down to 1.

### Step 1.2: Write the configuration file

Every setting the pipeline needs lives in one file, so that changing the model or the corpus never means editing code.

> **Do this.**
> 1. Create `config.json` next to `rubric.json` with the contents below.
> 2. Leave `temperature` at `0.0` and `seed` at `42` for the whole lab; the regression run in Part 5 depends on repeatable settings.

```json
{
  "model": "llama3.2",
  "ollama_url": "http://localhost:11434/api/chat",
  "temperature": 0.0,
  "seed": 42,
  "rubric_file": "rubric.json",
  "submissions_dir": "submissions",
  "output_csv": "grades.csv"
}
```

### Step 1.3: Add two submissions of your own

> **Do this.**
> 1. Write `submissions/s13.txt`: a persuasive paragraph of 60-140 words on an everyday topic, at whatever quality you like.
> 2. Write `submissions/s14.txt`: a paragraph designed to fool the judge, as described above.  Write down which criterion you expect it to fool and why.
> 3. Before you run anything, both partners privately record the level you expect for every criterion in `s13` and `s14`.  Part 2 depends on it.

> **No-code path.** Add the same two paragraphs as rows `s13` and `s14` in `dataset.csv`, then add a third of your own as `s15` so the dataset has fifteen rows, the count the rubric names for this path.  Put each answer in double quotes and double any quote mark inside it, exactly as `s02` in the starter file does.  A `.txt` file for each is optional on this path.

### Step 1.4: Implement the judge prompt function

This function builds the system and user messages, sends them to Ollama, and parses the reply.  Parsing is where fail closed lives: if the model returns anything but valid JSON with a `grades` list, the function returns `None` and the caller flags the row.

> **Do this.**
> 1. Create `pipeline.py` in your lab folder.
> 2. Paste the code below into it.  Read `judge_submission` once before moving on; the `except` block is the fail-closed policy.

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

def build_judge_prompt(submission_text, rubric):
    """
    Build the system and user messages for the judge.
    Returns (system_message, user_message).
    """
    criteria_section = ""
    for c in rubric["criteria"]:
        criteria_section += f"\n{c['id']} - {c['name']} (weight: {c['weight']})\n"
        for lv in c["levels"]:   # levels are listed 4 down to 1 in rubric.json
            criteria_section += f"  Level {lv['level']} ({lv['name']}): {lv['descriptor']}\n"

    system_message = (
        "You are an objective grading assistant. "
        "You will be given an artifact and a rubric. "
        "For each criterion, award a level (1-4) and quote ONE sentence from the artifact as evidence. "
        "The evidence must be a verbatim quote from the artifact - do not paraphrase.\n\n"
        "Return ONLY valid JSON in this exact format:\n"
        "{\n"
        '  "grades": [\n'
        '    {"criterion_id": "C1", "level": 3, "evidence": "exact quote from artifact"},\n'
        "    ...\n"
        "  ]\n"
        "}\n\n"
        "If the artifact is empty or off-topic, award level 1 for all criteria and use the evidence: 'N/A'.\n"
        "Do not add any text outside the JSON object."
    )

    user_message = (
        f"RUBRIC:\n{criteria_section}\n\n"
        f"ARTIFACT TO GRADE:\n{submission_text}"
    )

    return system_message, user_message

def judge_submission(submission_text, rubric, config):
    """
    Run the judge on a single submission.
    Returns (grades_dict, raw_output) where grades_dict has the parsed JSON,
    or (None, raw_output) if parsing fails.
    """
    system_msg, user_msg = build_judge_prompt(submission_text, rubric)
    payload = {
        "model": config["model"],
        "messages": [
            {"role": "system", "content": system_msg},
            {"role": "user", "content": user_msg}
        ],
        "stream": False,
        "options": {"temperature": config["temperature"], "seed": config["seed"]}
    }

    try:
        response = requests.post(config["ollama_url"], json=payload, timeout=90)
        response.raise_for_status()
        raw = response.json()["message"]["content"]
    except Exception as e:
        print(f"[lab5:judge_submission:network] {e}")
        traceback.print_exc()
        raise

    # Parse JSON; fail closed on malformed output
    try:
        clean = raw.strip().lstrip("```json").lstrip("```").rstrip("```").strip()
        parsed = json.loads(clean)
        assert "grades" in parsed and isinstance(parsed["grades"], list)
        return parsed, raw
    except Exception as e:
        print(f"[lab5:judge_submission:json_parse] Malformed output - flagging for review. Error: {e}. Raw: {raw[:300]!r}")
        return None, raw
```

### Step 1.5: Implement the batch pipeline and CSV emitter

`run_pipeline` walks the folder, calls the judge once per file, and writes one CSV row per file.  An empty file never reaches the model; it is flagged `EMPTY_FILE` and scored zero.  A file whose judge output failed to parse gets `REVIEW_NEEDED` and `N/A` in every score column, with the first 100 characters of the raw output kept in the flag so a human can see what came back.

> **Do this.**
> 1. Append the code below to `pipeline.py`, under the functions from Step 1.4.
> 2. Confirm the `if __name__ == "__main__":` block is the last thing in the file.

```python
import pathlib
import csv

def compute_weighted_total(grades, rubric):
    """Compute the weighted total score (0-100) from the grades list."""
    criterion_weights = {c["id"]: c["weight"] for c in rubric["criteria"]}
    total = 0
    for grade in grades:
        cid = grade["criterion_id"]
        level = int(grade["level"])
        weight = criterion_weights.get(cid, 0)
        # Level 4 = full weight, Level 1 = 25% weight
        total += weight * (level / 4)
    return round(total, 1)

def run_pipeline(config):
    """
    Walk the submissions directory, grade each file, and write grades.csv.
    """
    rubric = load_rubric(config)
    submissions_path = pathlib.Path(config["submissions_dir"])
    output_csv = config["output_csv"]

    # Collect all .txt and .md files
    files = sorted(list(submissions_path.glob("*.txt")) + list(submissions_path.glob("*.md")))
    print(f"Found {len(files)} submissions in {submissions_path}")

    # Build CSV column headers
    criterion_ids = [c["id"] for c in rubric["criteria"]]
    fieldnames = ["filename", "weighted_total", "flags"]
    for cid in criterion_ids:
        fieldnames += [f"{cid}_level", f"{cid}_evidence"]

    rows = []
    for i, filepath in enumerate(files):
        print(f"\n[{i+1}/{len(files)}] Grading {filepath.name}...")
        text = filepath.read_text(encoding="utf-8", errors="replace").strip()

        row = {"filename": filepath.name, "flags": ""}

        if not text:
            # Empty file edge case: never sent to the model
            row["flags"] = "EMPTY_FILE"
            row["weighted_total"] = 0.0
            for cid in criterion_ids:
                row[f"{cid}_level"] = 1
                row[f"{cid}_evidence"] = "N/A"
            rows.append(row)
            print(f"  Flagged: EMPTY_FILE")
            continue

        grades_dict, raw_output = judge_submission(text, rubric, config)

        if grades_dict is None:
            # Fail closed: flag for human review
            row["flags"] = f"REVIEW_NEEDED|raw={raw_output[:100]!r}"
            row["weighted_total"] = "N/A"
            for cid in criterion_ids:
                row[f"{cid}_level"] = "N/A"
                row[f"{cid}_evidence"] = "N/A"
        else:
            grades = grades_dict["grades"]
            row["weighted_total"] = compute_weighted_total(grades, rubric)
            for grade in grades:
                cid = grade["criterion_id"]
                row[f"{cid}_level"] = grade["level"]
                row[f"{cid}_evidence"] = grade.get("evidence", "")
            print(f"  Weighted total: {row['weighted_total']}")

        rows.append(row)

    with open(output_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"\nDone. Results written to {output_csv}")
    return rows

if __name__ == "__main__":
    config = load_config()
    run_pipeline(config)
```

### Step 1.6: Run the pipeline on the full corpus

> **Do this.**
> 1. From your lab folder, with Ollama running, run the script.
> 2. Keep the terminal output; a screenshot or a saved log of this run is a deliverable.
>
> ```bash
> python3 pipeline.py
> ```

> **You should see.** One progress line per file, a weighted total for each graded file, and `EMPTY_FILE` for `s10.txt`.  Expect about 20-40 seconds per submission on a laptop.

```text
Found 14 submissions in submissions

[1/14] Grading s01.txt...
  Weighted total: 95.0
[2/14] Grading s02.txt...
  Weighted total: 90.0
...
[10/14] Grading s10.txt...
  Flagged: EMPTY_FILE
...
Done. Results written to grades.csv
```

Open `grades.csv` and confirm it has 14 rows with the columns `filename`, `weighted_total`, `flags`, then `C1_level` and `C1_evidence` and so on for each criterion.  Confirm that `s10.txt` shows `EMPTY_FILE` in the flags column and that `s11.txt` (the recipe) scored low.

> **If it fails.**
> - `REVIEW_NEEDED` appears for most submissions: the model is not returning valid JSON.  Print `raw` first to see what it is producing, then add `"Keep your response to ONLY the JSON object, nothing else."` at the end of the system prompt.  The template already strips markdown code fences.
> - `weighted_total` is the same for every file (for example 62.5 everywhere): the model is awarding level 2 for everything.  Make the level 4 descriptor specific enough that excellent work is unmistakable.
> - More than two minutes per submission: confirm `"stream": False` is in the payload, and reduce the rubric to three criteria while you debug.

### No-code path: Part 1

The declarative counterpart of Steps 1.2 through 1.6 is one YAML file.  For each criterion the judge's job is binary: PASS if the answer sits at level 3 or 4 of that criterion, FAIL if at level 1 or 2.  The `echo` provider passes each stored answer straight through as the "output", so the `llm-rubric` judge grades your dataset rows instead of a freshly generated answer.

> **Do this.**
> 1. Copy `dataset.csv` from the starter pack into your `cs357-rubric-nocode` folder and add your rows `s13` through `s15`.
> 2. Create `promptfooconfig-baseline.yaml` with the contents below.  The four `value:` blocks carry the starter rubric's descriptors; if you sharpen one later, edit it here.
> 3. Run the batch and save the output file; Part 5 diffs against it.
>
> ```bash
> npx promptfoo@latest eval -c promptfooconfig-baseline.yaml --output run_baseline.json
> npx promptfoo@latest view
> ```

{% raw %}
```yaml
# promptfooconfig-baseline.yaml
# Validated against: ollama llama3.2, temperature 0
description: "Rubric Pipeline Lab, no-code path: baseline rubric-as-judge batch scoring"

prompts:
  # The echo provider returns each stored answer unchanged, so the judge grades the dataset row.
  - "{{answer}}"

providers:
  - echo

defaultTest:
  options:
    # The judge model that grades every llm-rubric assertion:
    provider:
      id: ollama:chat:llama3.2
      config:
        temperature: 0
  assert:
    - type: llm-rubric
      value: >
        Criterion C1 (Thesis clarity): PASS only if an arguable claim, a position someone
        could disagree with, is stated somewhere in the answer. FAIL if only a topic is
        named with no position taken, or if there is no text.
    - type: llm-rubric
      value: >
        Criterion C2 (Evidence): PASS only if at least one specific piece of support (a
        number, a named event, a concrete example) is connected to the claim with a stated
        reason. FAIL if support is only asserted in general terms, or if none is offered.
    - type: llm-rubric
      value: >
        Criterion C3 (Organization): PASS only if the claim comes before the support and
        the paragraph ends with a closing sentence. FAIL if the sentences are in no
        discernible order, the paragraph stops without a closing, or there is no structure.
    - type: llm-rubric
      value: >
        Criterion C4 (Mechanics): PASS only if there are at most two errors in spelling,
        punctuation, capitalization, or sentence boundaries and none obscures meaning.
        FAIL if there are three or more errors, one that changes meaning, or no text.

tests: file://dataset.csv
```
{% endraw %}

> **You should see.** 15 rows times 4 assertions, so 60 judge verdicts, in the viewer and in `run_baseline.json`.  Spot-check three items in the viewer: does the judge's reasoning for each verdict reference the actual answer text?  Note one example where its reasoning is weak or generic.  That note is this path's evidence-faithfulness concern, and it feeds your Part 2 disagreement analysis.

> **If it fails.**
> - Every assertion passes (or every one fails): the rubric text is not discriminating.  Sharpen the PASS line with countable features ("names an opposing view in a full sentence AND rebuts it with a reason").
> - Every case fails with an empty output: the prompt template references a variable that is not in the test case.  promptfoo does not error on an unknown variable; it substitutes nothing.  Check that the {% raw %}`{{answer}}`{% endraw %} name matches the CSV header.
> - The judge output is erratic: re-run.  `llm-rubric` verdicts from a small local model are noisy, and observing that noise is a legitimate finding for your writeup.
> - The YAML will not load: a bare `: ` inside an unquoted string, or a tab character, is the usual cause.

---

> **Checkpoint.** Before moving to Part 2, make sure you can answer:
> 1. What does "fail closed" mean in the context of this pipeline, and what specific behavior does your pipeline exhibit when the judge returns malformed JSON (or, on the no-code path, an unusable verdict)?
> 2. Open `grades.csv` (or `run_baseline.json`).  Does the result for `s01.txt` match your expectation?  If not, which criterion level is wrong, and why might the judge have awarded that level?
> 3. Which planted edge cases did the corpus include, and how does the pipeline handle each one?  Verify by reading the rows for `s10`, `s11`, and `s12`.

---

## Part 2: Validate Against Humans (20 points)

Before running the judge, you and your partner independently hand-score a calibration set of at least eight submissions.  Then run the judge and report two things per criterion: human-to-human agreement and human-to-judge agreement.  Identify the criterion with the worst machine-human gap, revise its level descriptors toward observability, and report agreement before and after the revision.

### Step 2.1: Score independently before running the judge

The order matters.  If you see the judge's scores first, your human scores anchor to them and the comparison is biased.  The same applies to the tier table in the starter pack's `README.md`: do not open it until both sheets are complete.

> **Do this.**
> 1. Choose at least eight submissions from your corpus of fourteen.  Include at least one from each tier and at least one of your own two.
> 2. Each partner scores all eight on a separate sheet (paper or spreadsheet), using the template below.  For each criterion, record the level (1-4) and a one-sentence justification.
> 3. Do not discuss scores with your partner until both sheets are complete.

```text
Scorer: [your name]   Date: [today]
Submission: s01.txt

C1 (Thesis clarity): Level ___ | Justification: ___
C2 (Evidence): Level ___ | Justification: ___
C3 (Organization): Level ___ | Justification: ___
C4 (Mechanics): Level ___ | Justification: ___
```

> **Watch out.** Both partners' original sheets are a deliverable.  Do not revise them after discussion; where you disagree, record both marks and reach a consensus on a separate line.  Human-to-human disagreement is a finding, not a mistake.

### Step 2.2: Compute human-to-human agreement

Percent agreement is the share of cells where the two scorers gave the same level.  Cohen's kappa is the same comparison corrected for the agreement two scorers would reach by chance (0 is chance level, 1 is perfect agreement).  The rubric accepts either figure; percent agreement is the simpler one to compute and to explain.

> **Do this.**
> 1. Create `agreement.py` in your lab folder and paste the code below.
> 2. Replace the example dictionaries with your actual scores, all eight files each.
> 3. Run it:
>
> ```bash
> python3 agreement.py
> ```

```python
# After both partners have scored independently:
# partner_a_scores[file][criterion] = level (int)
# partner_b_scores[file][criterion] = level (int)

def percent_agreement(scores_a, scores_b, criterion_id, files):
    """Exact-match agreement rate for one criterion."""
    matches = sum(
        1 for f in files
        if scores_a[f][criterion_id] == scores_b[f][criterion_id]
    )
    return matches / len(files)

# Example (fill in your actual scores):
partner_a = {
    "s01.txt": {"C1": 4, "C2": 4, "C3": 4, "C4": 4},
    "s06.txt": {"C1": 3, "C2": 3, "C3": 2, "C4": 3},
    # ... add all 8 files
}
partner_b = {
    "s01.txt": {"C1": 4, "C2": 4, "C3": 4, "C4": 4},
    "s06.txt": {"C1": 3, "C2": 2, "C3": 3, "C4": 3},
    # ...
}

calibration_files = list(partner_a.keys())
criteria = ["C1", "C2", "C3", "C4"]

print("Human-to-human agreement:")
for cid in criteria:
    agr = percent_agreement(partner_a, partner_b, cid, calibration_files)
    print(f"  {cid}: {agr:.0%}")
```

> **You should see.** One percentage per criterion.  Your numbers will differ from these.

```text
Human-to-human agreement:
  C1: 87%
  C2: 75%
  C3: 62%
  C4: 87%
```

### Step 2.3: Compare human scores to judge scores

> **Do this.**
> 1. Append the code below to `agreement.py`.  It reads `grades.csv` from Part 1 and compares each partner's sheet to the judge, skipping any file the judge flagged.
> 2. Run it again and copy both agreement tables into your readme.

```python
# Load judge scores from grades.csv
import csv

judge_scores = {}
with open("grades.csv") as f:
    reader = csv.DictReader(f)
    for row in reader:
        filename = row["filename"]
        judge_scores[filename] = {
            cid: int(row[f"{cid}_level"]) if row[f"{cid}_level"] not in ("N/A", "") else None
            for cid in criteria
        }

print("\nHuman A to Judge agreement:")
for cid in criteria:
    files_with_valid = [f for f in calibration_files if judge_scores.get(f, {}).get(cid) is not None]
    agr = percent_agreement(partner_a, judge_scores, cid, files_with_valid)
    print(f"  {cid}: {agr:.0%}")
```

> **If it fails.**
> - `KeyError` on a filename: the keys in `partner_a` must match the `filename` column in `grades.csv` exactly, including `.txt`.
> - Judge scores are missing for some calibration files: those files triggered `REVIEW_NEEDED`.  Check the console log for the raw output and retry those files with a slightly rephrased system prompt.

### Step 2.4: Identify the weakest criterion and revise it

The weakest criterion is the one with the lowest human-to-judge agreement.  Revise its level descriptors so they are observable: specific, countable, and anchored to visible text features.

> **Do this.**
> 1. Name the criterion with the lowest human-to-judge agreement and quote the wording you think caused it.
> 2. Edit that criterion's descriptors in `rubric.json`.  Keep a copy of the original wording in your readme.
> 3. Re-run `python3 pipeline.py` on the same corpus, then `python3 agreement.py` again.
> 4. Put a before-and-after table in your readme: criterion, agreement before, agreement after.

Example revision for a vague criterion:

- **Before**: "C2 Level 4: At least two distinct, specific pieces of support each appear with a stated reason connecting them to the claim."
- **After**: "C2 Level 4: At least two sentences each contain a number, a named event, or a concrete example, AND each of those sentences (or the one after it) contains 'because', 'so', or 'which means' tying it to the claim."

> **If it fails.**
> - Human-to-human agreement is below 50% on one criterion: the criterion is poorly defined; your scores are not wrong.  Explain in your writeup what made it ambiguous and how your revision addresses it.  Do not revise your scores to match your partner.
> - Levels 1 and 4 are easy to tell apart but 2 and 3 look the same: this is a real problem in rubric design.  Note it in your writeup and check whether the adequate-tier files (`s04` through `s06`) fall in this gap.

### No-code path: Part 2

Human agreement on this path is measured with a spreadsheet and percent agreement; no code is needed.  Before looking at any judge output, each partner independently hand-scores all fifteen dataset rows, criterion by criterion, as PASS (level 3 or 4) or FAIL (level 1 or 2).

> **Do this.**
> 1. Build a spreadsheet (Google Sheets, Excel, or CSV) with exactly these columns.
> 2. Each partner fills in their own four columns without discussion.  Only then open `run_baseline.json` (or the viewer) and fill in the judge columns.
> 3. Where you and your partner disagree with each other, record both marks and discuss until you reach a consensus verdict for the judge comparison.  Do not erase the original marks.

| Column | Contents |
|--------|----------|
| `item_id` | s01 through s15 |
| `C1_human_A` through `C4_human_A` | Partner A's blind P/F per criterion |
| `C1_human_B` through `C4_human_B` | Partner B's blind P/F per criterion |
| `C1_judge` through `C4_judge` | The judge's P/F per criterion, filled in after both humans finish |
| `mismatches` | Count of criteria where the human-consensus verdict differs from the judge |
| `notes` | One line on any disputed item |

Compute percent agreement with a spreadsheet formula or a calculator:

```text
percent agreement = (number of criterion cells where human consensus == judge verdict)
                    / (15 items x 4 criteria = 60 cells) x 100
```

Report percent agreement overall and per criterion (each criterion has 15 cells).

> **No-code path.** Cohen's kappa is not required on this path.  Two things replace it: the percent-agreement numbers above, and a written disagreement analysis of the three worst mismatches, meaning the three items with the highest `mismatches` count.  For each of the three, quote the answer, state the human verdict and the judge verdict per disputed criterion, quote the judge's stated reasoning from the promptfoo output, and diagnose why they diverged: is the criterion's wording ambiguous, is the judge pattern-matching on surface features, or did the humans read something into the answer that is not on the page?  Then revise the wording of the single worst criterion's rubric text in `promptfooconfig-baseline.yaml`, re-run it, and report that criterion's agreement before and after.  This is the same revise-and-remeasure discipline as Step 2.4.

> **If it fails.**
> - Percent agreement is suspiciously high: the partners scored together, or one saw the judge's output first.  Rescore blind.  The value of this part is entirely in the independence.
> - `llm-rubric` verdicts look random: the grading model and the model under test are the same, and the rubric text is vague.  Sharpen the descriptors first.  If verdicts stay unstable, say so and quantify it.

---

> **Checkpoint.** Before moving to Part 3, make sure you can answer:
> 1. Which criterion had the worst human-to-judge agreement?  What specific wording in that criterion's level descriptors made it ambiguous?
> 2. After your rubric revision, did human-to-judge agreement improve for that criterion?  If it did not, what further change might help?
> 3. Why must human scores be collected before running the judge?  What specific bias would you introduce by reversing the order?

---

## Part 3: Verify the Evidence (15 points)

Write a programmatic check that each quoted evidence string appears in the source submission, by exact substring or by a fuzzy match with a stated threshold.  A quote that appears nowhere in the source is hallucinated evidence.  Report the hallucinated evidence rate across your corpus, and flag the offending rows in the CSV.

> **No-code path.** promptfoo's judge returns reasoning rather than a quoted evidence string, so there is no CSV column to check by substring.  On this path, evidence verification is the faithfulness check inside your three-worst-mismatches analysis from Part 2: read the judge's stated reasoning for each of those items line by line against the answer text, and call out every claim the judge makes about the answer that the answer does not support.  Report how many of the judge's reasoning statements you checked and how many were unfaithful, as a fraction and a percentage.  Steps 3.1 and 3.2 below are code path only.

### Step 3.1: Implement and run the evidence check

`verify_evidence` tries an exact, case-insensitive substring match first.  If that fails and `thefuzz` is installed, it falls back to a partial-ratio fuzzy match against the stated threshold.  `N/A` evidence (the value the prompt asks for on empty or off-topic artifacts) is treated as faithful.  `verify_all_evidence` applies it to every evidence cell in `grades.csv` and writes a new CSV with a `HALLUCINATED_EVIDENCE` flag on the offending rows.

> **Do this.**
> 1. Create `verify.py` in your lab folder and paste both functions below into it, in order.
> 2. Run it from your lab folder:
>
> ```bash
> python3 verify.py
> ```

```python
import csv
import pathlib
from pipeline import load_config, load_rubric

def verify_evidence(evidence_quote, submission_text, fuzzy_threshold=90):
    """
    Check whether evidence_quote appears in submission_text.
    First tries exact substring match. Falls back to fuzzy match.
    Returns (is_faithful, match_type, match_score).
    match_type: "exact", "fuzzy", or "hallucinated"
    """
    if not evidence_quote or evidence_quote.strip() in ("N/A", ""):
        return True, "n/a", 100  # N/A evidence is treated as faithful

    # Exact substring match (case-insensitive)
    if evidence_quote.lower() in submission_text.lower():
        return True, "exact", 100

    # Fuzzy match (optional, requires thefuzz)
    try:
        from thefuzz import fuzz
        score = fuzz.partial_ratio(evidence_quote.lower(), submission_text.lower())
        if score >= fuzzy_threshold:
            return True, "fuzzy", score
        else:
            return False, "hallucinated", score
    except ImportError:
        # If thefuzz is not installed, treat non-exact as hallucinated
        return False, "hallucinated", 0

def verify_all_evidence(csv_path, submissions_dir, rubric, fuzzy_threshold=90):
    """
    Read grades.csv, check every evidence quote, and rewrite with HALLUCINATED_EVIDENCE flags.
    Returns (hallucination_count, total_evidence_count).
    """
    rows = []
    criteria = [c["id"] for c in rubric["criteria"]]
    hallucinated = 0
    total = 0

    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames + ["evidence_flags"]
        for row in reader:
            filename = row["filename"]
            filepath = pathlib.Path(submissions_dir) / filename
            try:
                submission_text = filepath.read_text(encoding="utf-8", errors="replace")
            except FileNotFoundError:
                row["evidence_flags"] = "FILE_NOT_FOUND"
                rows.append(row)
                continue

            evidence_issues = []
            for cid in criteria:
                evidence = row.get(f"{cid}_evidence", "")
                if row.get(f"{cid}_level") in ("N/A", "", "1"):
                    continue  # Skip N/A and level-1 (often "N/A" evidence)
                faithful, match_type, score = verify_evidence(evidence, submission_text, fuzzy_threshold)
                total += 1
                if not faithful:
                    hallucinated += 1
                    evidence_issues.append(f"{cid}:HALLUCINATED(score={score})")
                    print(f"  [HALLUCINATED] {filename} | {cid} | Quote: {evidence!r}")

            row["evidence_flags"] = "|".join(evidence_issues) if evidence_issues else ""
            # Update flags column
            existing_flags = row.get("flags", "")
            if evidence_issues:
                row["flags"] = (existing_flags + "|HALLUCINATED_EVIDENCE").strip("|")
            rows.append(row)

    # Rewrite CSV with evidence_flags column
    verified_csv = csv_path.replace(".csv", "_verified.csv")
    with open(verified_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    rate = hallucinated / total if total > 0 else 0
    print(f"\nEvidence verification complete.")
    print(f"Hallucinated: {hallucinated}/{total} = {rate:.1%}")
    print(f"Verified CSV written to: {verified_csv}")
    return hallucinated, total

if __name__ == "__main__":
    config = load_config()
    rubric = load_rubric(config)
    verify_all_evidence(config["output_csv"], config["submissions_dir"], rubric)
```

> **You should see.** One `[HALLUCINATED]` line per unfaithful quote, then the rate and the name of the new CSV.

```text
  [HALLUCINATED] s05.txt | C2 | Quote: 'Studies consistently demonstrate that composting works.'
Evidence verification complete.
Hallucinated: 3/42 = 7.1%
Verified CSV written to: grades_verified.csv
```

Put the hallucination rate and any verbatim hallucinated quotes in your readme.

> **If it fails.**
> - The rate is 0% even though you expected some hallucinations: the judge may be copying so faithfully that even paraphrases pass the fuzzy threshold.  Lower `fuzzy_threshold` to 80 and check a few quotes by hand to confirm the automated check works.
> - The rate is above 30%: the model is paraphrasing rather than quoting.  Add "The evidence MUST be a verbatim copy-paste from the artifact.  Do not rephrase." to the system prompt.  If paraphrasing persists, lower the threshold to 85 and say so in the readme.
> - `thefuzz` will not import: run `pip install thefuzz python-Levenshtein`.  If you cannot install it, use Python's built-in `difflib` instead:
>
> ```python
> from difflib import SequenceMatcher
> score = SequenceMatcher(None, evidence.lower(), submission_text.lower()).ratio() * 100
> ```

---

> **Checkpoint.** Before moving to Part 4, make sure you can answer:
> 1. What is your hallucinated evidence rate (or, on the no-code path, your unfaithful-reasoning rate)?  Is it higher or lower than you expected?
> 2. Look at one hallucinated quote.  Is it a fabrication (completely invented), a paraphrase (real idea, different words), or a conflation (combines two real sentences)?  Which is most dangerous in a grading pipeline and why?
> 3. If a quote passes fuzzy matching at 85% similarity but not exact match, is it faithful?  Does your answer change depending on the length of the quote?

---

## Part 4: Measure a Bias (20 points)

Design and run a controlled probe of one judge pathology from class: position bias (A/B comparisons in both orders), verbosity bias (padded versus unpadded versions of the same content), or byline bias (identical essays with varied author names).  Quantify the effect, implement or prescribe a countermeasure, and state honestly what risk remains.

### Step 4.1: Choose and design your bias probe

> **Do this.**
> 1. Pick one option below and write one sentence in your readme stating the hypothesis ("the judge awards more points to the padded version").
> 2. Decide what stays fixed: same model, same temperature and seed, same rubric.  Only the probed feature changes.

- **Option A, verbosity bias** (recommended): compare each of four submissions against a copy of itself with three filler sentences appended.  If the judge scores the padded version higher, that is verbosity bias.  The starter pack's `s12.txt` is a related observation: it is long, clean, and makes no claim, so its weighted total relative to `s07` through `s09` is a free data point.
- **Option B, position bias**: present two submissions in a comparison prompt (A then B, then B then A).  Check whether the judge consistently favors the first-presented submission.
- **Option C, byline bias**: add a fake author byline to otherwise identical submissions (for example "Written by: Sarah Chen" versus no name versus a name that correlates with demographic assumptions).  Check whether the scores differ.

### Step 4.2: Run the probe and record results

The probe below implements Option A with four matched pairs drawn from different quality tiers, which is the rubric's minimum.

> **Do this.**
> 1. Create `bias.py` in your lab folder and paste the code below.
> 2. Run it from the same folder:
>
> ```bash
> python3 bias.py
> ```

```python
import pathlib
from pipeline import load_config, load_rubric, judge_submission, compute_weighted_total

config = load_config()
rubric = load_rubric(config)

# Substantive-sounding but vacuous filler; three copies are appended to each original
FILLER = "\n\nFurthermore, it is important to consider the various aspects of this topic from multiple perspectives, as has been noted by many scholars and practitioners in the field."

matched_pairs = [
    ("s01.txt", "s01_padded.txt"),  # strong
    ("s05.txt", "s05_padded.txt"),  # adequate
    ("s08.txt", "s08_padded.txt"),  # weak
    ("s04.txt", "s04_padded.txt"),  # adequate
]

# Create the padded versions
for original, padded_name in matched_pairs:
    original_text = (pathlib.Path(config["submissions_dir"]) / original).read_text()
    padded_text = original_text + FILLER * 3
    (pathlib.Path(config["submissions_dir"]) / padded_name).write_text(padded_text)

# Grade all pairs and compare totals
results = {}
for original, padded in matched_pairs:
    for fname in [original, padded]:
        text = (pathlib.Path(config["submissions_dir"]) / fname).read_text()
        grades, _ = judge_submission(text, rubric, config)
        total = compute_weighted_total(grades["grades"], rubric) if grades else None
        results[fname] = total
        print(f"  {fname}: {total}")

# Compute the average bias
deltas = []
for original, padded in matched_pairs:
    if results[original] and results[padded]:
        delta = results[padded] - results[original]
        deltas.append(delta)
        print(f"  {original} -> {padded}: delta = {delta:+.1f}")

avg_delta = sum(deltas) / len(deltas) if deltas else 0
print(f"\nAverage verbosity bias: {avg_delta:+.1f} points (positive = padded scores higher)")
```

> **You should see.** A total for each of the eight files, four deltas, and an average.  Your numbers will differ.

```text
  s01.txt: 95.0
  s01_padded.txt: 97.5
  s05.txt: 62.5
  s05_padded.txt: 70.0
  ...
Average verbosity bias: +4.2 points (positive = padded scores higher)
```

> **Watch out.** The padded files now live in `submissions/`, so the next `python3 pipeline.py` will grade them too.  Either move them to a `probe/` folder after the run or note in the readme that `grades.csv` includes them.

> **If it fails.**
> - No verbosity bias (delta near 0): this is a valid finding.  Confirm that the filler sentences are coherent; incoherent filler can lower the score.
> - The bias is inconsistent across runs (sometimes positive, sometimes negative): your Ollama version may not honor the seed at temperature 0.  Run each file three times and report the average, and note the variance as a reliability issue in your writeup.
> - The byline probe feels unethical: measuring potential bias in a grading system with synthetic test cases is responsible AI development, not an expression of bias.  No real people are involved.

### Step 4.3: Implement or prescribe a countermeasure

> **Do this.**
> 1. For verbosity bias, add this sentence to the judge system prompt in `pipeline.py`: "Score based solely on the quality of the argument, not the length of the submission.  A concise, high-quality paragraph should score the same as a longer one that makes the same argument."
> 2. Re-run `python3 bias.py` and record the residual delta.
> 3. For position or byline bias, the countermeasure is procedural: always score submissions in isolation (no comparison prompts), and strip author bylines before grading.  State it concretely enough that someone could implement it, and if you can, implement it and re-measure.

### Step 4.4: Report your findings

> **Do this.**
> 1. Put this table in your readme, filled in with your numbers.
> 2. Below it, state in one or two sentences what risk remains even after the countermeasure.

| Condition | Avg score (control) | Avg score (treatment) | Avg delta | After countermeasure delta |
|-----------|--------------------|-----------------------|-----------|---------------------------|
| Verbosity bias | 65.6 | 69.8 | +4.2 | +1.1 |

### No-code path: Part 4

On this path you measure two biases with two more config files over the same dataset: reordering (position and order effects) and padding (verbosity).

> **Do this.**
> 1. Create `dataset_reordered.csv`: the same fifteen answers with the row order reversed (`s15` first, `s01` last).  A spreadsheet is the easiest tool; export it as CSV with the same `id,answer` header.
> 2. Create `dataset_padded.csv`: the same fifteen answers, each with three filler sentences appended (substantive-sounding but vacuous, for example "Furthermore, it is important to consider the various aspects of this topic from multiple perspectives.").  Leave the empty row empty.
> 3. Copy `promptfooconfig-baseline.yaml` to `promptfooconfig-reordered.yaml` and change only the last line to `tests: file://dataset_reordered.csv`.  Copy it again to `promptfooconfig-padded.yaml` with `tests: file://dataset_padded.csv`.
> 4. Run both and keep the outputs:
>
> ```bash
> npx promptfoo@latest eval -c promptfooconfig-reordered.yaml --output run_reordered.json
> npx promptfoo@latest eval -c promptfooconfig-padded.yaml --output run_padded.json
> ```

Each answer is judged in isolation, so a trustworthy judge should give identical verdicts regardless of row order.  Any per-item verdict that flips between the baseline and the reordered run is evidence of order sensitivity or judge instability, which in a real grading deployment is position bias against whoever gets graded late.  Padding adds no rubric-relevant content, so verdicts should not improve; any criterion that flips FAIL to PASS under padding is verbosity bias.

> **You should see.** Two more result files with 60 verdicts each.  Compare the three runs in this table (one row per item; a deliverable in your writeup):

| item_id | baseline passes (of 4) | reordered passes (of 4) | padded passes (of 4) | reorder delta | padding delta |
|---------|------------------------|-------------------------|----------------------|---------------|---------------|
| s01 | | | | | |
| ... | | | | | |
| **Total flips** | | | | | |

> **No-code path.** Then do four things.  Summarize each bias in one sentence with a number (for example "padding flipped 5 of 60 verdicts FAIL to PASS, an 8% verbosity effect").  Propose one countermeasure you can express in the rubric text of the config (for example "Length and repetition must not be credited; judge only the content that addresses the criterion").  Apply it and re-run the padded config.  Report the residual effect.  This is the same countermeasure-and-residual-risk discipline as Steps 4.3 and 4.4.

> **If it fails.**
> - Results change between identical runs: temperature is not pinned.  Set `temperature: 0` under the judge provider's `config`, as the baseline file does, not only in the prompt.
> - The reordered run differs from the baseline on many items: that is a finding about judge instability, not a bug in your files.  Report the flip count.

---

> **Checkpoint.** Before moving to Part 5, make sure you can answer:
> 1. What bias did you measure, and what was the average effect size (or flip count)?  Is that effect large enough to matter in a real grading context?
> 2. What was your countermeasure?  Did it eliminate the bias or reduce it?  What residual risk remains?
> 3. Name one condition from the course that must be satisfied before you would trust this pipeline to grade real student work.  Be specific about what "trust" means: beyond "the bias is low," what evidence would you need and from whom?

---

## Part 5: Reproducible Evals with a Declarative Harness (10 points)

So far, your confidence in the judge lives in scripts and a readme.  In this part you move it into a versioned eval configuration: a declarative file that says "given these inputs, the judge must produce these outputs (or satisfy these assertions)."  The file is checked into the repository next to the code, so every future change to the prompt, model, or rubric can be re-verified with one command.  The harness returns in *Evaluation Workshop II: Run Your Rubric Against Your Project*, where teams run it against their own final project artifacts.

On the code path, choose one harness.  This is a choice within the lab, not an optional extra; everyone completes Part 5.

- **Option A (default): [promptfoo](https://www.promptfoo.dev/)**, a declarative YAML harness.  You describe prompts, providers, test cases, and assertions in `promptfooconfig.yaml` and run `npx promptfoo eval`.  promptfoo talks to local models through Ollama's OpenAI-compatible endpoint, so no hosted API is required.  Most assertion types (`contains`, `equals`, `javascript`, `regex`) run without any judge model at all.
- **Option B (for pairs who want a Python-native harness): [Inspect AI](https://inspect.aisi.org.uk/)**, the UK AI Security Institute's open-source framework.  You define a `Task` (Dataset, Solver, Scorer) in Python and run `inspect eval`.  Point the model at your local Ollama endpoint.  Inspect's log viewer gives you a per-sample trace of every call.

### Step 5.1: Encode the golden set and run the harness

> **Do this.**
> 1. Define the golden set.  Reuse the calibration set from Part 2: the (at least eight) synthetic submissions with agreed blind human scores.  Each becomes one eval case: the input is the submission text plus the rubric criterion, and the expected output is the human-consensus level for that criterion.
> 2. Add two adversarial cases from Part 4's bias probe (for example the padded and unpadded versions of the same submission, which must receive the same level).
> 3. Encode assertions.  For each case, write at least one: the judge's returned level equals the human-consensus level (exact match on the parsed JSON field), or, for the adversarial pairs, the two levels equal each other.  In promptfoo these are `assert:` blocks; in Inspect they are scorers.  Assert on the parsed field, not the raw text; if parsing itself fails, that is a legitimate eval failure worth counting.
> 4. Run the harness against your local model and capture the results: promptfoo's `--output` JSON or a viewer screenshot, or Inspect's `.eval` log.  Record the pass rate in your readme.

> **You should see.** A pass rate that is probably not 100%.  That is a finding, not a failure; your Part 2 agreement figures already told you the judge and humans disagree sometimes.

> **If it fails.**
> - promptfoo cannot reach Ollama: set the provider to Ollama's OpenAI-compatible endpoint, `openai:chat:llama3.2` with `apiBaseUrl: http://localhost:11434/v1` (any non-empty API key satisfies the client).  Verify first with `curl http://localhost:11434/v1/models`.
> - Assertions fail because the judge output wraps JSON in prose: reuse the fail-closed lesson from Part 1.  In promptfoo use a `javascript` assertion that parses first; in Inspect, parse in the scorer.
> - Inspect runs but every score is zero: check that your scorer compares the parsed level as the same type (int versus string) as the target.  `inspect view` shows the raw model output per sample, which usually reveals the mismatch.

### Step 5.2: Demonstrate a regression and commit the configuration

> **Do this.**
> 1. Make a deliberate, plausible-seeming degradation to your judge prompt: for example, delete the instruction that evidence must be quoted verbatim, or remove the fail-closed JSON instruction.
> 2. Re-run the harness.  Show the pass rate drop.
> 3. Revert the change and re-run.  Show the pass rate recover.
> 4. Include both result sets and a two-or-three-sentence interpretation in your readme.  This is what the harness buys you: a tripwire that catches silent quality regressions before they reach anything real.
> 5. Put the eval config file in your submission alongside the code, with a comment header stating the model, temperature, and seed it was validated against.

### No-code path: Part 5

This path satisfies the harness discipline by construction, because every measurement you made lives in a versioned YAML file.  Now demonstrate it.

> **Do this.**
> 1. Copy `promptfooconfig-baseline.yaml` to `promptfooconfig-regressed.yaml`.
> 2. Weaken one criterion's rubric text in the copy: for example, delete the observable PASS line and leave only the criterion name.
> 3. Re-run and keep the output:
>
> ```bash
> npx promptfoo@latest eval -c promptfooconfig-regressed.yaml --output run_regressed.json
> ```
>
> 4. Compare `run_baseline.json` and `run_regressed.json`.  The viewer's side-by-side, a text diff, or a hand-built table of the 60 verdicts all work.  Identify which items' verdicts changed and in which direction.
> 5. Write two or three sentences in your readme interpreting the result, then revert the change and confirm the baseline verdicts recover.

> **You should see.** A set of verdicts that moved on the weakened criterion and stayed put on the other three.  If everything changed, the two runs used different datasets or provider settings; change exactly one thing between runs.

---

## Self-Check Before You Submit

Held against the rubric's `proficient` column.  No-code path requirements are given in parentheses where they differ.

- [ ] The batch scorer processes the **full** synthetic corpus end to end, one result row per artifact, including the planted edge cases and my own two submissions.
- [ ] Per-criterion outcomes and an overall result, with quoted evidence strings and a weighted total (no-code path: per-criterion judge verdicts across all items).
- [ ] Malformed judge output is surfaced, not guessed at: a `REVIEW_NEEDED` flag rather than a silent default (no-code path: noted and re-run).
- [ ] Rubric, model, paths, and settings live in configuration files; nothing is hardcoded.
- [ ] A terminal screenshot or log confirms the end-to-end run on the full corpus.
- [ ] Both partners scored the calibration set independently and blind to the judge (at least eight artifacts; no-code path, all fifteen).
- [ ] Agreement quantified per criterion, as percent agreement or Cohen's kappa.
- [ ] The criterion with the worst human-to-judge gap is identified, a rubric revision is tested, and the change in agreement is reported in a table.
- [ ] At least one judge bias measured with a controlled experiment (at least four matched pairs; no-code path, the reordered and padded variants).
- [ ] The effect is quantified with a number, not described.
- [ ] A countermeasure is implemented or prescribed concretely enough to build, and the residual risk is stated.
- [ ] Evidence verification: quotes checked against the source artifacts, hallucinated quotes flagged, and the hallucinated-evidence rate reported as a fraction and a percentage (no-code path: the judge's reasoning for the three worst mismatches checked line by line against the answer text).
- [ ] A versioned eval configuration (promptfoo YAML or an Inspect AI task) with at least one assertion per case, committed.
- [ ] A before-and-after regression run shows a deliberate judge-prompt or rubric change being caught, with both result sets and an interpretation.
- [ ] All human score sheets included.
- [ ] Pair log with at least two timestamped role swaps.
- [ ] Every reflection answer cites a specific agreement figure, bias effect size, or evidence-faithfulness finding.
- [ ] The path I took is named at the top of the readme.

---

## Deliverables

Submit one ZIP.  Fix random seeds and list software version information (Python or Node version, promptfoo version, Ollama version, model tag) so the run is reproducible.  Name your path at the top of the readme.

| File or artifact | What it shows | Rubric row |
|------------------|---------------|------------|
| `pipeline.py`, `config.json`, `rubric.json` (code path) or `promptfooconfig-baseline.yaml` (no-code path) | The batch scorer with every setting externalized | Pipeline Implementation |
| `submissions/` folder with `s01` through `s14` (code path) or `dataset.csv` with fifteen rows (no-code path) | The synthetic corpus, starter pack plus your own | Pipeline Implementation |
| `grades.csv` plus a terminal screenshot or log (code path) or `run_baseline.json` (no-code path) | The end-to-end run on the full corpus | Pipeline Implementation |
| Both partners' original score sheets, `agreement.py` output or the score spreadsheet, and the before-and-after agreement table | Blind human scoring and quantified agreement (no-code path: plus the three-worst-mismatches analysis) | Human Agreement Validation |
| `bias.py` output and the findings table (code path) or `dataset_reordered.csv`, `dataset_padded.csv`, `run_reordered.json`, `run_padded.json`, and the comparison table (no-code path) | The controlled bias probe, effect size, countermeasure, residual risk | Bias Measurement |
| `grades_verified.csv` and the hallucination rate (code path) or the faithfulness check inside the mismatch analysis (no-code path) | Evidence checked against the source | Evidence Verification |
| Eval config with both regression result sets (code path) or `promptfooconfig-regressed.yaml` with `run_regressed.json` next to `run_baseline.json` (no-code path) | A versioned harness that catches a deliberate regression | Reproducible Eval Harness |
| `readme.md`: about two pages, with the Learning Log below, the pair log with at least two timestamped swaps, and the software versions | The writeup | Writeup, Reflection, and Submission |

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

- Your pipeline could grade a real class's submissions tomorrow by changing one path in a configuration file.  List two conditions (one technical and one procedural) that you believe must be satisfied before that would be responsible.  For each condition, name the specific course concept it connects to (for example hallucinated evidence rate, human-to-judge agreement, bias measurement).
- Where did you and your partner disagree with each other more than with the judge?  What does that specific disagreement reveal about what the rubric was measuring versus what you thought it was measuring?  What would you add to the rubric to resolve it?
- If collaboration beyond your pair occurred, identify it.  Do you certify that this submission represents your pair's original work?  Please identify any and all portions of your submission that were not originally written by you.
- Approximately how many hours did this lab take (I will not judge you for this at all; I am simply using it to gauge if the assignments are too easy or hard)?

---

## Extension Challenges

These are optional and carry no extra credit.

**Challenge 1 (moderate): Add a confidence score.**
Modify the judge prompt to also return `"confidence": 1-5` for each criterion grade, where 1 means "I am guessing" and 5 means "the evidence clearly determines this level."  Analyze the correlation between confidence score and faithfulness of the evidence quote; do low-confidence grades also have higher hallucination rates?

**Challenge 2 (harder): Implement two-pass grading.**
Run the judge twice on each submission with different seeds.  If the two runs agree on a criterion level, accept it.  If they disagree, flag it as "DISPUTED" and run a third tiebreaker call.  Measure whether two-pass grading reduces human-to-judge disagreement at the cost of more model calls.

**Challenge 3 (hardest): Grading as a RAG problem.**
Instead of putting the entire submission in the prompt, treat grading as a retrieval task: for each criterion, retrieve the three most relevant sentences from the submission using a sentence embedder, then ask the judge to grade that criterion based only on those three sentences.  Measure whether focused-retrieval grading reduces the hallucinated evidence rate compared to full-text grading.

Three further optional ideas, each a lab of its own if you want one:

- **Eval harness with a CI gate.**  Generalize Part 5 into a standing test suite (a categorized eval dataset, exact-match and LLM-judge metrics, a regression runner) and have a GitHub Actions workflow fail any push whose pass rate drops below a threshold you set.
- **OpenTelemetry tracing.**  Wrap every judge call in a span carrying model, temperature, token counts, and parse outcome, export the traces to Jaeger, and use them to find where the pipeline spends its time and where it fails.
- **Packaging and publishing.**  Turn the pipeline into a pip-installable package with tests against a mocked model, and publish it to TestPyPI or as a container image to the GitHub Container Registry.
