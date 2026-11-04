---
layout: assignment
permalink: /Projects/FinalProject
title: "CS357: Foundations of Artificial Intelligence - Final Project"

info:
  coursenum: CS357
  purpose: "To synthesize the entire course, and the semester-long Project Thread, into one substantial community-grounded final project.  That may be a system you build, an audit you evidence, or an artifact you publish, carried from proposal through sprints to a multi-audience Demo Day, with the process graded alongside the product."
  tilt:
    task: "With your standing team, choose one of three directions: build a custom agent team, perform a responsible AI audit, or build and publish an open-source agent.  Then propose it, build it in sprints with a community partner in the loop, and present it at Demo Day with a partner-facing artifact."
    criteria: "I grade this on four course families worth 60 points between them: Approach (sound methods and justified design decisions), Process and Professionalism (meeting discipline, communication, project management, check-ins, charter adherence), Product (the working system, audit, or publication, the Demo Day presentation, and the partner-facing artifact), and the Responsible AI Report (token use and its environmental cost, observability, a correctness audit, and a bias audit, all measured on your own work).  The other 40 points come from the six problem-solving criteria of the AAC&U VALUE Problem Solving Rubric.  The rubric below spells out each row."
  points: 100
  goals:
    - To carry one substantial project from proposal through sprints to Demo Day, choosing the direction (build, audit, or publish) that best serves the team's stakeholder problem
    - To justify every major methodological and design decision (architectural choices, framework selection, or scoping) by naming the course pattern, principle, or evidence that motivated it
    - To produce direction-appropriate evidence of rigor, whether that is a baseline-compared evaluation with documented failure modes (Direction A), a systematic framework application with mechanistic failure modes and adoptable governance (Direction B), or a verified ecosystem gap with property tests, publication, and community engagement, or a verified issue in an existing project carried to a submitted, reviewed contribution (Direction C)
    - To practice visible, professional team process (meeting agendas and notes, a decision log, role rotation, all-member signatures, intra-team check-ins, and charter adherence) throughout the project
    - "To engage a community partner: grounding the proposal in stakeholder needs, incorporating a partner feedback pass during the sprint window, and delivering a partner-facing artifact at Demo Day"
    - "To take and report concrete responsible AI actions on your own work: tracking token use and estimating its energy, carbon, and cost; tracing agent actions and handoffs; auditing outcomes for correctness; and probing for bias (Goals 5, 6, 9)"
    - To communicate the result to a multi-audience of technical peers and community stakeholders, and to disclose honestly how and why AI tools were used at the proposal and at the final submission
    - To ground the project in the team's Stakeholder Brief and Literature Review and use the Open Questions to assess growth (Goals 11, 12, 13, 14, 15)
  rubric:
    - weight: 15
      description: Approach, sound methods and justified design decisions
      preemerging: The work shows no evidence of a deliberate approach, decisions are unexplained defaults, the direction's required rigor (baseline evaluation, framework application, or gap verification) is absent, and the project does not build on the Stakeholder Brief or Literature Review
      beginning: An approach is described but is generic or unjustified, design decisions are asserted rather than argued, the direction's evidence of rigor is attempted but incomplete (an evaluation without a baseline, a framework applied superficially, a gap asserted without evidence), or the connection to the stakeholder problem is nominal
      progressing: The approach is deliberate and mostly sound, major design decisions are justified with reference to course patterns or evidence, the direction's rigor requirement is substantially met (baseline comparison with metrics, systematic framework application with citations, or verified gap with linked evidence), and the project builds on the Stakeholder Brief and Literature Review, with minor gaps in how alternatives were considered or in the failure analysis
      proficient: The approach is deliberate, documented, and defensible, every major decision names the alternative that was rejected and the course pattern, principle, or evidence that motivated the choice; the direction's rigor requirement is fully met (Direction A - a fixed evaluation set compared against a monolith baseline with at least three failure modes documented from transcripts and at least one mitigation re-measured; Direction B - every major framework step yields a specific, cited finding with at least three mechanistic failure modes distinguishing materialized from foreseeable risks; Direction C - an independently verifiable ecosystem gap with named alternatives, a one-sentence minimum viable scope, and at least three non-trivially specified property tests); and the work is explicitly grounded in the Stakeholder Brief, Literature Review, and the partner's stated needs (Goals 11, 12)
    - weight: 16
      description: Process and Professionalism, meetings, communication, project management, check-ins, charter adherence
      preemerging: There is no evidence of team process, no meeting agendas or notes, no decision log, no role rotation, and missing check-ins and signatures
      beginning: Some process artifacts exist but are spotty, meeting notes or the decision log have gaps, one or more intra-team check-ins are missing, the GANTT-style timeline is absent or stale, or signatures are missing from a milestone
      progressing: The Team Playbook is followed with minor lapses, meeting agendas and notes, the decision log, role rotation, the project timeline, all three intra-team check-ins, and all-member signatures are present, but one element is thin, late, or inconsistently maintained (Goal 13)
      proficient: Team process is visible and current throughout, every meeting has a posted agenda and notes with owners and dates; the decision log records alternatives and rationale; project management is real (a maintained GANTT-style timeline with named owners, sprint boundaries honored, runnable increments at each sprint); all three intra-team check-ins are submitted on time; the team demonstrably operates under its signed charter, including its conflict protocol; roles rotate per sprint and every student is primary author of at least one section or component of every team deliverable (editable by teammates); each team document's version or commit history shows a real drafting trajectory rather than a single late paste; every milestone carries all members' signatures (Goal 13)
    - weight: 19
      description: Product, the working system, audit, or publication; the Demo Day presentation; and the partner-facing artifact
      preemerging: The direction's core artifact is missing or does not function, the system does not run, the audit lacks findings and governance, or nothing was published; the Demo Day presentation is missing or covers only a happy path with no disclosed limitation; no partner-facing artifact exists
      beginning: The core artifact partially meets its direction's requirements but would not be usable by its intended audience without significant rework, the system runs but is unreproducible or unevaluated, the audit's governance recommendations lack owners, thresholds, or timelines, or the published artifact lacks working documentation, tests, or a registry presence; the presentation serves only a technical audience or omits the failure disclosure; the partner-facing artifact is missing or unusable by the partner
      progressing: The core artifact meets its direction's requirements, a running, documented, evaluated system with committed governance (A); a complete risk analysis and adoptable governance document (B); or a published, installable, tested, documented artifact with a community exchange (C), and Demo Day includes both a technical segment and a stakeholder-facing segment with a partner-facing artifact, with minor gaps in polish, accessibility, or the honesty of the limitations discussion, and a public repository or write-up exists but has gaps in recruiter-legibility (a README a stranger could not follow, or no contribution attribution) (Goal 14)
      proficient: "The core artifact fully meets its direction's requirements and is honest about its limits. Direction A: the system runs from a fresh start following the README; configuration and seeds are externalized and pinned; CI passes on the submission SHA; evidence is surfaced to the user with a confirmation gate on consequential actions; and the committed GOVERNANCE.md matches deployed behavior. Direction B: the artifact package (risk analysis with at least 8 citations; governance document with monitoring plan, incident response, communication plan, and appeal process) could be handed to a regulator without modification. Direction C: the artifact is live and installable from a public registry with green CI, a stranger-tested quickstart, CONTRIBUTING.md and GOVERNANCE.md, and a documented substantive community exchange. All directions: the Demo Day presentation serves the multi-audience: a live technical segment with a rehearsed failure or limitation disclosure and a plain-language stakeholder segment, with every teammate speaking substantively and every teammate able to present any part; the partner-facing artifact (one-page brief, demo video, or deployed tool) is something the community partner can actually use, presented at Demo Day and included in the submission; and the project leaves a public, recruiter-legible trace, a public repository (Directions A and C) or a public write-up or portfolio page (Direction B) whose README or summary answers what it is, why it matters, and how to run or read it in thirty seconds, names each member's contribution, and is suitable for linking from a resume (Goal 14)"
    - weight: 10
      description: Responsible AI Report, token use and its environmental cost, observability and traceability, a correctness audit, and a bias audit, measured on your own work
      preemerging: The Responsible AI Report is missing, or it states intentions without evidence; there are no measured token counts, no traces or logs, no correctness audit, and no bias probe
      beginning: The report addresses some of the four areas but relies on assertion rather than measurement; token counts are guessed or come from a single run, traces are missing or cannot be matched to a run, the correctness audit has no golden set or rubric, or the bias probe is missing or too small to support any claim
      progressing: All four areas are addressed with evidence (token counts measured per run and converted to an energy, carbon, and cost estimate; traces or logs of agent actions and handoffs for the evaluation runs; a correctness audit against a golden set or rubric judge with a pass rate; and a counterfactual or perturbation bias probe with a results table), but one area is thin, the estimate's assumptions are not stated, or the findings are not tied to any change in the work or the governance document (Goals 5, 6, 9)
      proficient: "Every area is measured, evidenced, and acted on.  Token use: prompt and completion tokens are recorded for every evaluation run (from OpenCode's session token display or Ollama's prompt_eval_count and eval_count), totaled and averaged per task, and converted to an energy, carbon, and dollar estimate whose assumptions are stated and sourced.  Observability: every evaluation run has a trace or structured log with a run identifier and each agent action, tool call, and handoff, and the report walks one run end to end.  Correctness: outputs are scored against a committed golden set or a rubric judge whose agreement with human scores is reported, with the pass rate and every failure explained.  Bias: a counterfactual or perturbation probe changes one attribute at a time, uses enough samples to support its claim, reports disaggregated results, and explains or mitigates any gap.  Each area names at least one change the team made, or deliberately declined, because of what it measured, and the Demo Day presentation shows the numbers (Goals 5, 6, 9)"
    - weight: 8
      description: "Define Problem (AAC&U VALUE Problem Solving); here, the stakeholder problem carried from your Brief"
      preemerging: Demonstrates a limited ability in identifying a problem statement or related contextual factors.
      beginning: Begins to demonstrate the ability to construct a problem statement with evidence of most relevant contextual factors, but problem statement is superficial.
      progressing: Demonstrates the ability to construct a problem statement with evidence of most relevant contextual factors, and problem statement is adequately detailed.
      proficient: Demonstrates the ability to construct a clear and insightful problem statement with evidence of all relevant contextual factors.
    - weight: 6
      description: "Identify Strategies (AAC&U VALUE Problem Solving); here, the directions and architectures you weighed before choosing"
      preemerging: Identifies one or more approaches for solving the problem that do not apply within a specific context.
      beginning: Identifies only a single approach for solving the problem that does apply within a specific context.
      progressing: Identifies multiple approaches for solving the problem, only some of which apply within a specific context.
      proficient: Identifies multiple approaches for solving the problem that apply within a specific context.
    - weight: 7
      description: "Propose Solutions/Hypotheses (AAC&U VALUE Problem Solving); here, your proposal and its design decisions"
      preemerging: Proposes a solution/hypothesis that is difficult to evaluate because it is vague or only indirectly addresses the problem statement.
      beginning: Proposes one solution/hypothesis that is "off the shelf" rather than individually designed to address the specific contextual factors of the problem.
      progressing: "Proposes one or more solutions/hypotheses that indicates comprehension of the problem. Solutions/hypotheses are sensitive to contextual factors as well as the one of the following: ethical, logical, or cultural dimensions of the problem."
      proficient: "Proposes one or more solutions/hypotheses that indicates a deep comprehension of the problem. Solution/hypotheses are sensitive to contextual factors as well as all of the following: ethical, logical, and cultural dimensions of the problem."
    - weight: 7
      description: "Evaluate Potential Solutions (AAC&U VALUE Problem Solving); here, your pre-mortem, decision log, and rejected alternatives"
      preemerging: "Evaluation of solutions is superficial (for example, contains cursory, surface level explanation) and includes the following: considers history of problem, reviews logic/reasoning, examines feasibility of solution, and weighs impacts of solution."
      beginning: "Evaluation of solutions is brief (for example, explanation lacks depth) and includes the following: considers history of problem, reviews logic/reasoning, examines feasibility of solution, and weighs impacts of solution."
      progressing: "Evaluation of solutions is adequate (for example, contains thorough explanation) and includes the following: considers history of problem, reviews logic/reasoning, examines feasibility of solution, and weighs impacts of solution."
      proficient: "Evaluation of solutions is deep and elegant (for example, contains thorough and insightful explanation) and includes, deeply and thoroughly, all of the following: considers history of problem, reviews logic/reasoning, examines feasibility of solution, and weighs impacts of solution."
    - weight: 6
      description: "Implement Solution (AAC&U VALUE Problem Solving); here, the sprints and the artifact they produced"
      preemerging: Implements the solution in a manner that does not directly address the problem statement.
      beginning: Implements the solution in a manner that addresses the problem statement but ignores relevant contextual factors.
      progressing: Implements the solution in a manner that addresses multiple contextual factors of the problem in a surface manner.
      proficient: Implements the solution in a manner that addresses thoroughly and deeply multiple contextual factors of the problem.
    - weight: 6
      description: "Evaluate Outcomes (AAC&U VALUE Problem Solving); here, your evaluation, limitations, and what you would do next"
      preemerging: Reviews results superficially in terms of the problem defined with no consideration of need for further work.
      beginning: Reviews results in terms of the problem defined with little, if any, consideration of need for further work.
      progressing: Reviews results relative to the problem defined with some consideration of need for further work.
      proficient: Reviews results relative to the problem defined with thorough, specific considerations of need for further work.
  readings:
    - rtitle: "Agent Teams"
      rlink: "../Tutorials/AgentTeams"
    - rtitle: "The Project Studio activity and its gallery-walk protocol"
      rlink: "Activities/liascript-projectstudio.md"
      liapage: true
    - rtitle: "Explainability"
      rlink: "../Tutorials/Explainability"
    - rtitle: "ShipIt: Build, Test, CI, and Publish One Artifact"
      rlink: "../Tutorials/ShipIt"
    - rtitle: "Demo Day: External Guests and Technical Interview Practice"
      rlink: "../Tutorials/DemoDay"
    - rtitle: "Problem Solving VALUE Rubric (AAC&U); the six problem-solving criteria in the rubric below are quoted from it"
      rlink: "https://www.lamar.edu/data-analytics-reporting-analysis/_files/documents/problem_solving.pdf"

tags:
  - final-project
  - multi-agent
  - agents
  - governance
  - responsible-ai
  - open-source
  - community

---

You will carry one substantial, community-grounded project from a written proposal, through three sprints with a community partner in the loop, to a multi-audience Demo Day.  You do this with your standing Project Thread team, under its signed charter, with the project roles (**Coordinator**, **Builder**, **Evaluator**, **Scribe**) rotating at every sprint boundary.  You leave with a public artifact you can link from a resume, a record of how your team decided and worked, and practice presenting real work to people who did not take this course.

This is the final stage of the semester-long [Project Thread]({{ site.baseurl }}/Projects/PBLThread).  Your proposal builds on your team's [Stakeholder Brief]({{ site.baseurl }}/Assignments/StakeholderBrief).  The [Literature Review]({{ site.baseurl }}/Assignments/LitReview) reads against that plan during the sprint window.  Your team operates under its signed charter and the [Team Playbook]({{ site.baseurl }}/Projects/PBLThread), and Demo Day addresses both technical and non-technical audiences.  See the Thread hub for the semester map and assessment philosophy.

There is no final exam in this course.  The final project is due on the last day of class, and teams present it at Demo Day on final exam day.

---

## Choose Your Direction

The Final Project is **one required project with three directions**.  Every team completes the same arc (proposal, sprints with check-ins, a gallery walk, and Demo Day), and every team is graded on the same rubric.  What differs is the direction your team chooses for its intervention.  Choose it slowly, and choose the one that best serves the stakeholder problem you have carried since the [Stakeholder Brief]({{ site.baseurl }}/Assignments/StakeholderBrief).

| Direction | What you build | What you need | Pick this if |
|---|---|---|---|
| **A: Custom Agent Team** | A system of at least three cooperating, specialized agents that accomplishes a real goal-oriented task end to end on your local stack, benchmarked against a monolithic baseline and governed by a document you can defend | Your local AI stack, a public repository with continuous integration (CI), and a task a multi-agent system actually fits | Your team wants to build, and has people who enjoy making things run |
| **B: Responsible AI Audit** | A structured, evidenced responsible-AI audit of a specific deployed system: a risk analysis with mechanistic failure modes, a governance document a real organization could adopt, and a presentation a real board could act on | Public documentation, news coverage, academic studies, and regulatory filings; no code and no access to the system's internals | Your team wants to investigate.  This is a **fully non-programming** direction and it is not the lesser one; a good audit is harder than a mediocre build |
| **C: Build and Publish an Open-Source Agent** | A verified gap in the agent tooling ecosystem filled by an open-source agent that is built, tested, documented, and published to a public registry, with a real community engaged and its governance and limitations disclosed.  As a variant, reviewed pull requests to an existing open-source agent project (see Direction C below) | A public repository with CI, a registry account (npm, PyPI, Docker Hub, or the MCP marketplace), and a community to post in | Your team wants what you make to outlive the semester, and will take documentation, packaging, and licensing as seriously as the code |

The rubric is the same on every direction.  These are directions within the one project, not separate assignments.

---

## Milestone Timeline

The milestones run in the sequence below, and the [course schedule]({{ site.baseurl }}/) has the dates.  **The final project is due on the last day of class, and no work is accepted after that.  Teams present on final exam day.**

| Milestone | What is due | Points |
|---|---|---|
| Project handed out | Nothing yet.  Teams read all three directions and begin converging on one | - |
| Intra-team check-in 2 | A private check-in to me, due at the *Project Groups* session, before the proposal | - |
| Proposal | The proposal, with direction declared, stakeholder grounding, and an AI-use disclosure | **25 / 100** |
| Literature Review handed out | Handed out at the *RAG Worked Example* session, before the proposal is due; it reads against the committed plan and states what the evidence changes | *graded on its own page* |
| Sprints 1, 2, and 3 | Rotating roles, a runnable increment (or evidenced stage checkpoint) at every sprint boundary, and a **partner feedback pass** during the final sprint | - |
| Sprint checks 1 and 2 | At the start of class at the *Critique, Consensus, and the LLM Judge* and *Training Data, Bias, IP, Privacy, Governance, and the Cost of Inference* sessions.  See [Sprint Checks]({{ site.baseurl }}/Projects/PBLThread#sprint-checks) | 3 points each, within Final Project and Project Thread Milestones |
| Cross-team proposal critique | At the *Project Sprint: Run Your Rubric Against Your Project, and Threat Model It* session, the boundary between Sprint 1 and Sprint 2 | - |
| Gallery walk, peer review (SQR cards), and intra-team check-in 3 | The gallery walk at *Project Studio and Gallery Walk*; check-in 3 at the end of that same day | - |
| Final submission | Your direction's deliverables, the partner-facing artifact, the Responsible AI Report, contribution statements, reflections, and the final AI-use disclosure, all due on the last day of class | **75 / 100**, with Demo Day |
| Demo Day | The presentation, on final exam day | *within the 75* |

---

## Before You Start

This is not a new assignment.  It is the point every Project Thread milestone has been building toward, and most of what it asks for already exists somewhere in your team's work: the stakeholder you interviewed, the agent systems you designed, the labs you built, and, during the sprints, the literature you review.  Read the timeline above as an assembly plan, not a fresh start.

> **Time budget.** This is the largest single commitment of the term, spread across the back half of the semester.  The proposal is due well before the last day of class, so the sprints are where the work lives.  A team that starts building in the last two weeks will submit something that does not run.

> **Watch out.** The thing that most often goes wrong is almost never technical.  Teams build the system they find interesting and present it to an audience that includes the stakeholder they interviewed early in the term.  Demo Day is a **multi-audience** presentation.  Keep the stakeholder's problem visible in every sprint, or you will discover at the end of the term that you built something impressive that answers a different question.

> **Watch out.** Whatever you build, it must run at the start of the *Final Integration and Demo Rehearsal* studio.  That studio is a rehearsal, not a work session, and it falls on the last day of class, when the final project is due.

---

## How the Grade Works

The project is how the learning happens; it is not the point in itself.  I grade your *process* as much as your *product*: how you decided, how you worked together, how you engaged your community partner, and how honestly you disclosed what worked and what did not.  A team that meets on schedule, logs its decisions, checks in candidly, and reports a limitation honestly will outscore a team with a slicker artifact and no visible process.

Your final-project grade combines **team output**, **individual contribution**, and **individual understanding**:

- **Team output** is the team's score on the rubric below, applied to the proposal (25 points) and to the final submission and Demo Day together (75 points).  The rubric has two halves: four **course families** (Approach, Process and Professionalism, Product, and the [Responsible AI Report](#the-responsible-ai-report-required-in-every-direction)) worth 60 points between them, and six **problem-solving criteria** worth 40, described next.
- **Individual contribution**: every student must be **primary author of at least one section or component** of every team deliverable, named in the document, and editable by teammates.  Your primary-author sections, check-in record, and role-rotation history are your contribution evidence.  Riding along is not a strategy, and neither is doing everything yourself.
- **Individual understanding** is assessed through the **Demo Day question-and-answer** and your **individual reflection**: can you explain and defend any part of the work, including parts you did not primarily author?

### The problem-solving half of the rubric

Six of the rubric's criteria (Define Problem, Identify Strategies, Propose Solutions/Hypotheses, Evaluate Potential Solutions, Implement Solution, Evaluate Outcomes) are quoted verbatim from the **Problem Solving VALUE Rubric**, published by the Association of American Colleges and Universities (AAC&U) and reproduced here under its permission for classroom use.  AAC&U's four performance levels map onto this course's four: *Benchmark 1* is read as pre-emerging, *Milestone 2* as beginning, *Milestone 3* as progressing, and *Capstone 4* as proficient.  AAC&U states that its rubrics "can and should be translated into the language of individual campuses, disciplines, and even courses," and that they were designed for program-level assessment rather than for grading.  The translation into a graded course rubric, and the weights, are mine.

These criteria earn their place because of what they measure.  In AAC&U's words, the rubric "is designed to measure the quality of a process, rather than the quality of an end-product," which is the half of this project the four course families are least able to see.  That is also why AAC&U warns that "the final product of an assignment that required problem resolution is insufficient without insight into the student's problem-solving process."  Your decision log, your check-ins, your pre-mortem, and your reflections are that insight, and they are where these six criteria will mostly be scored.  A polished artifact with no visible record of how you got there cannot earn proficient on them.

Read the six criteria as the arc you have walked.  The Stakeholder Brief is *Define Problem*.  The direction and architecture you weighed is *Identify Strategies*.  The proposal is *Propose Solutions*.  The pre-mortem and rejected alternatives are *Evaluate Potential Solutions*.  The sprints are *Implement Solution*.  Your limitations and next steps are *Evaluate Outcomes*.

### Two standing rules

**AI-use disclosure:** both the proposal and the final submission must include a disclosure statement of **how and why AI tools were used**: what was AI-assisted, with what tool, why you chose to use it there, and how the output was verified.  Disclosed, verified AI assistance is professional practice; undisclosed AI assistance is an integrity violation.

**Absence policy for Demo Day:** every team member must be able to present *any* part of the project, so prepare accordingly.  The grade of a member absent on Demo Day depends on the reason for the absence and on that member's documented contribution to that point.

---

## Community Partner Engagement

This project is community-grounded on purpose: **every team connects its project to a community stakeholder**.  I identify the partners and share the roster in class (it is not published on the website).  Three touchpoints are required:

1.  **Proposal:** the partner's stated needs inform the proposal, building directly on your Project Thread [Stakeholder Brief]({{ site.baseurl }}/Assignments/StakeholderBrief).  Name the problem in the partner's terms and state how the direction you chose serves it.
2.  **Partner feedback pass:** during the sprint/gallery-walk window, share your in-progress work with your partner (a demo, a findings summary, or a draft artifact).  Document their feedback and how you triaged it: incorporate, disclose, or defer.
3.  **Partner-facing artifact (Demo Day):** deliver an artifact an external stakeholder can actually use (a one-page brief, a demo video, or a deployed tool), and present it at Demo Day to a **multi-audience** of technical peers and community stakeholders.

**Encouraged, not graded: an early note in Sprint 1.**  Early in Sprint 1, send your partner a short note: here is what we are building, and here is what we will show you.  Your partner then knows what to expect before the feedback pass.  Teams working from a stakeholder persona share the note with another team instead.

---

## The Responsible AI Report (Required in Every Direction)

Every team takes concrete responsible AI actions on its own work and reports them.  This is not an essay about responsible AI in general.  It is a measured account of four things: what your work cost to run, what your agents did, whether their outputs were right, and whether they treated inputs about different people differently.  You learned each measurement in a class session this semester.  Here you apply them to your own project.

The report is a required section of your final submission: a section of the report in Directions A and C, and a section of the artifact package in Direction B.  Keep it to 2-3 pages plus tables, and put the raw evidence in the artifacts folder.  It is graded on the **Responsible AI Report** row of the rubric (10 points).

> **Watch out.** Start measuring in Sprint 1.  Token counts, traces, and probe results cannot be rebuilt from memory at the end of the term.  A report assembled at the end from a single run cannot score above beginning.

### Area 1: Environmental Tracking and Token Use

Record the input (prompt) and output (completion) tokens for every evaluation run, and then estimate what they cost in energy, carbon, and money.  The [Tokens, Energy, and Cost tutorial]({{ site.baseurl }}/Tutorials/TokensEnergyCost) and the [cost section of the bias and governance session]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-biasdata.md) explain the method.

**Count the tokens.**  Keep a `tokens.csv` with one row per model call.  In OpenCode, read the session's token display.  Through Ollama's API, read `prompt_eval_count` (input), `eval_count` (output), and `total_duration` (in nanoseconds, so divide by 1e9) from each response.  Here is the header and one worked row:

```text
run,task,agent,model,input_tokens,output_tokens,total_s
r1,t01,planner,llama3.2,812,146,9.4
```

**Estimate.**  Each conversion is one multiplication by an assumption, so every assumption gets a name and a source.  Save this as `estimate.py`, replace the constants with your own, and replace each `# TODO`:

```python
import csv

WATTS = 30               # ASSUMPTION: measure your machine under load
GRID_G_PER_KWH = 350     # SOURCE: EPA eGRID; look up your region
PRICE_IN_PER_M = 15.00   # SOURCE: a comparable hosted model's price per million input tokens
PRICE_OUT_PER_M = 60.00  # SOURCE: the same model's price per million output tokens

with open("tokens.csv") as f:
    rows = list(csv.DictReader(f))
input_tokens = sum(int(r["input_tokens"]) for r in rows)
# TODO: total output_tokens and seconds (the total_s column) the same way.  total_s holds a float.
# TODO: kwh = WATTS * seconds / 3600 / 1000
# TODO: grams = kwh * GRID_G_PER_KWH
# TODO: dollars = input_tokens / 1e6 * PRICE_IN_PER_M + output_tokens / 1e6 * PRICE_OUT_PER_M
print(f"{len(rows)} calls, {kwh:.6f} kWh, {grams:.4f} g CO2e, ${dollars:.4f} hosted")
```

> **You should see.** On the one worked row: `1 calls, 0.000078 kWh, 0.0274 g CO2e, $0.0209 hosted`

Then put the numbers to use:

- **Show where the cost goes.**  Report tokens per run, per task, and per agent, so a reader can see which agent or step dominates.
- **Compare one alternative.**  Put the numbers beside one cheaper option (a smaller model, fewer agents, a shorter context, or the monolith baseline), and say whether the difference in quality justifies the difference in cost.

**Evidence to submit:** `tokens.csv`, the estimate with its assumptions and sources, and the comparison.  An order-of-magnitude estimate is acceptable.  A hidden assumption is not.

### Area 2: Observability and Traceability

Log every agent action, tool call, and handoff with a run identifier, so that a reader can reconstruct any evaluation run from the logs alone.  Follow the practice from the Observability session: store identifiers and measurements (a query hash, token counts, `finish_reason`, latency), not private content.

**Evidence to submit:** the trace or structured log files for the evaluation runs, and a walk-through of one run from start to finish in the report, naming each agent, what it received, what it did, and what it handed off.

### Area 3: Auditing Outcomes for Correctness

Score your outputs against a committed **golden set** (inputs with agreed correct answers or agreed human rubric levels) or with a **rubric judge**.  Check the judge against human scores before you trust it.  The [Judge Pipeline Workshop: Build and Audit a Judge]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-rubricworkshop.md) and the [Project Sprint: Run Your Rubric Against Your Project, and Threat Model It]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-projectsprint.md) session build this harness; bring it into your project repository (or your evidence folder) and run it on your final outputs.

**Evidence to submit:** the golden set or rubric, the one command that runs the harness and the pass rate it printed, the judge's agreement with human scores, and an explanation of every failure.

### Area 4: Auditing for Potential Bias

Run a **counterfactual or perturbation probe**: send inputs that are identical except for one attribute (a name, a dialect, a neighborhood, a stated group membership) and compare the outputs.  The byline-swap probe from the [Training Data, Bias, IP, Privacy, Governance, and the Cost of Inference]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-biasdata.md) session is the model: change one attribute, hold everything else fixed, sample enough times to support a claim, and disaggregate the results.  Choose attributes that matter to your partner's community.

**Evidence to submit:** the probe design (which attribute, which values, how many samples), the disaggregated results table, and either an explanation of any gap or the mitigation you applied and its re-measured result.

### How the Report Relates to Your Direction

- **Direction A.**  Run all four areas on the frozen 10-task evaluation set, for both the monolith baseline and the multi-agent system, so the token and cost comparison sits beside the accuracy comparison.  Your evaluation already covers much of Area 3.  Reuse it, and add the judge-to-human agreement.  Anything the report finds that changes how the system should be run belongs in GOVERNANCE.md as well.
- **Direction B.**  The audit and the report look at different systems, so they do not conflict.  The audit examines someone else's deployed system from public evidence.  The report examines your team's own AI use: the model you probed during adversarial probing, and any AI tools you used in the research (for example, an agent that summarized sources or extracted claims).  Count the tokens those sessions used.  Log every probe (prompt, model and version, response, and timestamp) so someone else could reproduce your findings, as the Red-Teaming tutorial's reporting standard already asks.  Check every AI-assisted summary or extracted claim against its cited source before it reaches the risk analysis; that set of verified claims is your golden set.  Your counterfactual probes on the reachable model may serve as evidence for both the audit and Area 4.  Present them once, and say which claims they support about the audited system and which about your own tooling.
- **Direction C.**  Run all four areas on the published artifact, using its worked examples and property-test inputs.  Publish the token-use figures and the bias probe result in the README or in GOVERNANCE.md's known limitations, so that users see them before they install.  In the contribution variant, measure the feature you contributed.

### On Demo Day

- In the **technical segment**, show the token and cost table next to your evaluation results, and show one trace.
- In the **stakeholder-facing segment**, give one plain-language sentence for each area: what the system costs to run, how you can see what it did, how you know it is right, and what you checked about fairness.
- Be ready for a question on any of the four areas.  "We did not measure that" is an honest answer.  It is also a limitation to disclose.

For each of the four areas, also name at least one change your team made, or deliberately declined to make, because of what it measured.

---

## Phase 1: Converge on a Direction and Check In

Between the hand-out and the proposal, your team weighs the three directions against the stakeholder problem and surfaces disagreements before they become a proposal problem.

> **Do this.**
> 1. Read all three directions below, and reread your [Stakeholder Brief]({{ site.baseurl }}/Assignments/StakeholderBrief).
> 2. Record in your decision log which directions you weighed and why you chose one (this is the *Identify Strategies* criterion).
> 3. Submit intra-team check-in 2 privately to me at the *Project Groups* session.

---

## Phase 2: Proposal (25 points)

The proposal has its own page and its own rubric: see [Final Project Proposal]({{ site.baseurl }}/Projects/FinalProjectProposal).  That page lists everything a proposal needs, including your direction's elements.  *Implement Solution* and *Evaluate Outcomes* are graded here on this page, because a plan cannot demonstrate them.

---

## Phase 3: Sprints

Build in three sprints between the proposal and the last day of class.  The [course schedule]({{ site.baseurl }}/) has the sprint boundaries and the class sessions that support them: the two sprint checks, the *Project Sprint* session, and the two *Project Studio* sessions.  Your direction's section below lists what each sprint builds and how you know it is done.

Sprint 1 is the longest and spans the Thanksgiving break, so the two [sprint checks]({{ site.baseurl }}/Projects/PBLThread#sprint-checks) cut it into short laps.

The [Literature Review]({{ site.baseurl }}/Assignments/LitReview) runs across Sprints 1 and 2.  Its synthesis states what the evidence confirms, complicates, or changes about your proposal, and any scope change that follows belongs in your decision log and your next check-in.

> **Do this.** At every sprint boundary:
> 1. Rotate roles, and record the new assignments in the meeting notes.
> 2. Ship the sprint's step from your direction's section, and update your evaluation or evidence table with a number or a citation, not an adjective.
> 3. Update the decision log and the GANTT-style timeline, including any scope change.
> 4. Add the sprint's token counts, traces, audit results, and probe results to the Responsible AI evidence folder.
> 5. Hold the sprint retrospective, and file the Scribe notes in your team note.  Each member adds three to five sentences: what I built, what I learned, and what I would do differently, keyed to one of the Open Questions.

During the final sprint, also run the **partner feedback pass**: put your work in front of your community partner, and document the exchange and your triage (incorporate, disclose, or defer).

---

## Phase 4: Gallery Walk, Peer Review, and Check-in 3

The gallery walk and peer review happen during the final sprint.  They are mandatory and graded within the Process family.  Intra-team check-in 3 is due at the end of the gallery walk day.  The *Final Integration and Demo Rehearsal* studio that follows hosts the cross-team mock-interview rehearsal (see the [Demo Day Guide]({{ site.baseurl }}/Tutorials/DemoDay)).

> **Do this.**
> 1. Host honestly: demonstrate your work, including at least one known failure or open finding.
> 2. Walk generously: fill out a **S**trength / **Q**uestion / **R**isk card for every team you visit.
> 3. Triage all feedback you receive into three buckets: *fix before submission*, *disclose in the report*, or *defer to future work*.
> 4. Put your triage decisions in the artifacts folder.
> 5. Submit intra-team check-in 3 at the end of the gallery walk day.

---

## Phase 5: Final Submission and Demo Day (75 points)

The final submission is due on the last day of class, and teams present on final exam day.

**Demo Day logistics:** all teams present in the final exam period, splitting the time evenly, so each team's window is short and fixed: **15 minutes per team, including Q&A**, with the rest of the period held for setup and changeovers.  Each direction's presentation length below is set to fit inside that window, and whatever your presentation does not use is Q&A.  Rehearse to time.  Demo Day is **external-facing**: alumni, industry guests, and faculty from other departments may join the audience and Q&A, as available; your grade never depends on who attends.

Every team, regardless of direction, delivers at Demo Day:

- A **live technical segment** for CS peers: a real demonstration (Direction A: the running system; Direction B: a walkthrough of the framework application and evidence for one failure mode's mechanism; Direction C: the installed, published artifact) including a **rehearsed failure or limitation disclosure**.
- A **non-technical, stakeholder-facing segment** in plain language: who this is for, the problem in their terms, what the work does for them, what it must not be used for, and a brief multidisciplinary reflection on how disciplines beyond CS shaped the work (Goal 14).
- The **partner-facing artifact**, presented to the multi-audience and included in the submission.
- The **Responsible AI Report** numbers: the token and cost table and one trace in the technical segment, and one plain-language sentence per area in the stakeholder-facing segment (see [The Responsible AI Report](#the-responsible-ai-report-required-in-every-direction)).
- A **public portfolio artifact**: the public repository (Directions A and C) or public write-up/portfolio page (Direction B) described in the Product rubric; pass the [publish gate](#publish-gate) before it goes public.
- **Every teammate speaks substantively**, and every teammate must be prepared to present any part (see the absence policy above).
- Q&A with the instructor, peers, and partners: this is where individual understanding is assessed.  I ask each member at least one question about a part of the work they did not build.  Prepare with the [Demo Day Guide]({{ site.baseurl }}/Tutorials/DemoDay); the final Project Studio includes a cross-team mock-interview rehearsal, credited as class participation.

> **Do this.**
> 1. Assemble the final submission: your direction's deliverables below, the Responsible AI Report, individual contribution statements documenting the role rotation, individual reflections (see Reflection Prompts), and the **final AI-use disclosure**.
> 2. Submit everything on the last day of class.  Nothing is accepted after it.
> 3. Rehearse the whole demo on the clock, on the machine you will use, on the network you will have, with every teammate able to cover any part.

**Deliverables for this phase:**

- [ ] The Demo Day presentation, with the technical segment, the stakeholder-facing segment, and the rehearsed limitation disclosure
- [ ] The partner-facing artifact, presented and included in the submission
- [ ] The public portfolio artifact (repository or write-up), past the publish gate
- [ ] Your direction's final deliverables (below)
- [ ] The Responsible AI Report, with its evidence in the artifacts folder
- [ ] Individual contribution statements documenting the role rotation, and individual reflections
- [ ] The final AI-use disclosure and all-member signatures

---

## Direction A: Custom Agent Team

> **What this direction requires.** Your local AI stack, a public repository with CI on every push, a task that needs at least three meaningfully distinct agent roles, at least one retrieval or tool capability, and at least one evaluation or critique stage.  Tasks touching sensitive data require instructor approval, must run fully locally with de-identification, and your governance document must say so explicitly.

Design, build, evaluate, and present a **custom agent team**: cooperating, specialized agents accomplishing a real goal-oriented task end to end on your local AI stack.  The agent loop, prompting, retrieval, memory, tools, orchestration, critique, judging, explainability, and governance all have a place here, and your report must show that each architectural choice was a *decision*, not a default.  Choose a task that matters to your partner's community.

### Direction A sprints

- **Sprint 1 (proposal to cross-team critique).**  Build the monolith baseline first: by Sprint Check 1 it answers one evaluation task end to end, with the evaluation set drafted.  By the end of the sprint, finalize and freeze the 10-task evaluation set, draft the agent design table, and set up the repository with a CI placeholder.  *You are done when* the baseline has a result for all 10 tasks.
- **Sprint 2 (critique to gallery walk).**  Implement all the agents, and commit a first draft of GOVERNANCE.md.  *You are done when* each agent passes a test on its own, and at least 5 evaluation tasks have run.
- **Sprint 3 (gallery walk to the last day of class).**  Run the full evaluation against the baseline, document at least 3 failure modes with transcripts, and re-measure one mitigation.  *You are done when* the baseline and multi-agent numbers sit side by side, and the mitigation has a before and an after.

### Direction A build requirements

- Build the monolith baseline *first* and evaluate against it; freeze the 10-task evaluation set at Sprint 1
- Document at least three failure modes with agent transcripts; implement and re-measure at least one mitigation with before-and-after numbers
- Surface evidence to the user following the evidence hierarchy (direct retrieval citation over generated summary), with a **human confirmation gate** on every consequential action and a demonstrated **abstention behavior** (the system declines rather than hallucinating when evidence is absent)
- Commit a **GOVERNANCE.md** that matches the deployed system's behavior (data handling, human gates, incident response), updated at each sprint boundary, not written at the end

### Direction A final deliverables

- [ ] **The system:** a repository that runs from a fresh start following the README in under 3 minutes on a machine the team has not configured; configuration externalized to `config.json`, model versions and seeds pinned, exceptions handled with located messages, a test suite with at least one end-to-end test, CI on every push, and a publish step (triggered by the `submission` tag) pushing the artifact to GitHub Container Registry (GHCR), Docker Hub, or npm
- [ ] **The report** (6-8 pages): design rationale tied to named course patterns; evaluation results with the baseline comparison table, failure analysis with transcripts, and re-measurement after mitigation; explainability design; limitations (your "disclose" bucket from the gallery walk, verbatim); a governance summary referencing the committed GOVERNANCE.md; the Responsible AI Report; and individual contribution statements documenting the role rotation
- [ ] **The presentation** (12 minutes, leaving 3 minutes of questions in your 15-minute window), meeting the shared Demo Day requirements, plus: the evaluation table (baseline vs. multi-agent, side by side) and the 90-second explainability story (what does a user see when the system makes a decision?)
- [ ] **The artifacts folder:** final agent design table, final pre-mortem with binding governance clauses noted, all sprint notes, gallery-walk cards received with your triage, and a release-readiness checklist signed by the Evaluator confirming CI passes on the submission SHA (the commit hash of the version you submit), the artifact is live at its published URL, and the README was tested by a stranger

---

## Direction B: Responsible AI Audit

> **What this direction requires.** A **specific** system: a named, deployed product with a defined purpose and identifiable affected populations, in the domain your community partner cares about.  Not "AI in hiring," but a named tool as deployed by a named operator.  You are not expected to have access to the system's internals.  Base the analysis on public documentation, news coverage, academic studies, and regulatory filings, and cite every claim.  Documented absence of information is itself a finding.

Perform a structured **responsible AI audit** of a publicly available, deployed AI system.  This is the kind of analysis that regulatory frameworks such as the EU AI Act and the NIST AI RMF call for, and that the communities a system touches have reason to ask for.  The deliverable is not an opinion piece.  It is evidenced, structured, and written for people who will make decisions based on it.  Strong candidates: a hiring screening tool, a medical imaging AI, a content moderation system, a predictive risk tool in criminal justice or benefits eligibility, or an educational AI that grades or places students.  Avoid general-purpose chatbots unless scoped to a specific deployment context.

### Direction B sprints

- **Sprint 1 (proposal to cross-team critique).**  Build an evidence folder with at least 5 sources, begin the framework mapping, and identify your first failure-mode candidates.  *You are done when* each candidate cites at least one source in the folder.
- **Sprint 2 (critique to gallery walk).**  Draft the risk analysis (4-6 pages, at least 8 citations, 3 mechanistic failure modes), and outline the governance document.  *You are done when* every major framework step has a specific finding with a citation.
- **Sprint 3 (gallery walk to the last day of class).**  Complete the governance document (monitoring plan, incident response, communication plan, appeal process), and rehearse the board presentation.  *You are done when* every recommendation traces to a specific risk finding.

### Direction B build requirements (the audit)

- **Systematic risk analysis** (4-6 pages, at least 8 citations): apply the chosen framework in full: all four NIST functions (GOVERN, MAP, MEASURE, MANAGE), an argued EU AI Act risk-tier classification with applicable obligations, or all ten Montreal Declaration principles each with an evidentiary basis.  Every major framework step produces a specific, evidenced finding
- At least **three failure modes with named mechanisms**: each naming the affected group or input type, the specific erroneous output, and the mechanism, distinguishing risks that have materialized from risks that are foreseeable, and naming accountability gaps specifically (what role is absent, and what decision cannot be made without it)
- **Adversarial probing** of the system or a comparable one you can reach: the [Red-Teaming LLMs]({{ site.baseurl }}/Tutorials/RedTeaming) tutorial gives you the method, including how to write a scoped brief and how to report a failure so someone else can reproduce it.  Where the audited system is not reachable, probe the nearest model you can run and say plainly what that substitution does and does not license you to claim
- **Governance document** (3-5 pages) a real organization could adopt, passing the third-party test (could an outside auditor verify compliance from evidence?): a **monitoring plan** (each metric with data source, frequency, review threshold, and named owner), an **incident response procedure** (specific incident definition, notification order and timeframes, suspension authority), a **stakeholder communication table** (general public, affected individuals, regulators), and an **appeal process** a person can follow without a lawyer (initiation, reviewer, evidence, remedies, timeline).  Every recommendation must trace to a specific risk finding

### Direction B final deliverables

- [ ] **The artifact package**, organized so it could be handed to a regulator without modification: the approved proposal, the risk analysis report, the governance document, the presentation materials, and the Responsible AI Report on your team's own AI use and probing
- [ ] **The board presentation** (your full 15-minute window, questions included, timing graded): the class role-plays the operator's board: intelligent, busy, skeptical, and mixed technical/non-technical.  Required arc: what the system does and who uses it (2 min, plain English); who is at risk and how (3 min, including at least one concrete individual harm example); what you found, by severity (5 min, most serious first, sources on request); what you recommend, in priority order (3 min, each with estimated effort and timeline); questions (remaining).  Prepare evidence-based responses to the three standard board objections: "these risks are theoretical," "the vendor tested it for fairness," and "we lack the resources"
- [ ] **Demo Day additions:** the shared requirements above; the technically grounded evidence walkthrough serves as this direction's technical segment, and the partner-facing artifact presents the stakeholder context, the top findings by severity, and the priority recommendations
- [ ] Individual contribution statements and reflections

---

## Direction C: Build and Publish an Open-Source Agent

> **What this direction requires.** A public GitHub repository with GitHub Actions CI, an account on at least one public registry (npm, PyPI, Docker Hub, or the MCP marketplace), a real community to post in, and a gap that serves the community your partner belongs to.  Artifacts touching sensitive data or making outbound API calls on behalf of users require instructor approval and a governance statement addressing those risks.

Build something that outlasts the semester: a published, documented, reusable agent or agent component that real users can discover, install, and run.  The deliverable is a **software artifact with a community presence**: a package on a public registry, a README a stranger can follow, a CI badge, a governance statement, and at least one authentic exchange with a real community member.

### Direction C variant: Contribute to an Existing Open-Source Project

Instead of publishing a new artifact, your team may make substantive, reviewed contributions to an existing project in the agent ecosystem.  An MCP server, the Ollama or OpenWebUI ecosystem, promptfoo, or Inspect AI are strong candidates.  The same rubric applies with these equivalences:

- *Gap verification* becomes issue selection: a triaged open issue or feature request, with linked evidence that a maintainer or real user wants it.
- *Publication* becomes one or more submitted pull requests with tests and documentation, carried through maintainer review.  A merge is ideal but not required; a substantive review exchange is required, because maintainer response times are outside your control.
- *Community engagement* is intrinsic to the PR thread and documented from it.
- The CONTRIBUTING.md and GOVERNANCE.md requirements are met by following the upstream project's own documents and stating in your report what they required of you.
- Scope must be approved in the proposal, whose "what the artifact does / who would use it / how they would install it" elements describe the upstream feature you are adding.

A contribution reviewed by the maintainers of a real project is a strong portfolio line, and one that many graduates do not have.

### Direction C sprints

- **Sprint 1 (proposal to cross-team critique).**  Build a running minimum viable product (MVP) with the core feature only, and add at least 3 tests (1 unit and 2 property).  *You are done when* CI is green on the MVP.
- **Sprint 2 (critique to gallery walk).**  Implement a non-trivial feature, add a third property test, and draft the README quickstart.  *You are done when* a classmate has cold-tested the quickstart and you have written down what they hit.
- **Sprint 3 (gallery walk to the last day of class).**  Publish to a registry, tag v1.0.0, make your community post, and complete CONTRIBUTING.md and GOVERNANCE.md.  *You are done when* the package installs from the registry on a clean machine.

### Direction C build requirements

- Core functionality works on a clean machine by following the README, with at least one **non-trivial feature** fully implemented (streaming responses, token-level authentication, persistent memory across sessions, or multiple integrated tools with error recovery)
- **Unit tests** for all deterministic components with meaningful assertions, and at least **three property tests** for LLM-dependent components, each naming a clearly stated behavioral contract (e.g., "every response includes a source citation," "the output is valid JSON matching the named schema"), no trivially passing properties
- **GitHub Actions CI** running the full suite on every push, green on the submission SHA; configuration externalized with documented defaults; no credentials anywhere in the git history; model versions and seeds pinned
- **Documentation:** a README whose quickstart works in 5 commands or fewer on a clean machine (verified by a classmate cold-following it, result documented), with a configuration reference, two worked examples, the registry link, and the CI badge; a **CONTRIBUTING.md** covering bug reporting, PR submission, local test execution, and a code of conduct; a **GOVERNANCE.md** covering scope, prohibited uses with reasons, responsibility and contact, harm reporting, and known limitations that could cause harm; and a **LICENSE** (MIT, Apache 2.0, or AGPL) justified in one paragraph naming what the choice means for users
- **Publication:** installable from at least one public registry (npm, PyPI, Docker Hub, or the MCP marketplace); submission commit tagged `v1.0.0` and matching the published version
- **Community engagement:** a post in a relevant community (r/LocalLLaMA, r/MachineLearning, a relevant Discord, or Show HN); respond substantively to feedback (acknowledge its substance and incorporate it, explain why not, or file an issue) and document the exchange with a screenshot or link.  If no response arrives within a week, post to a second community and document the attempt

### Direction C final deliverables

- [ ] **The repository and the published package**: public GitHub repo running from a fresh start, CI green on the submission SHA, and a live registry URL where the artifact is installable
- [ ] **The report** (3-5 pages): the gap and how it was verified; key design decisions and tradeoffs; property-test results; documentation strategy and the classmate quickstart-test result; license justification; governance rationale; the community engagement summary with evidence; the Responsible AI Report; and individual contribution statements
- [ ] **The presentation** (8 minutes, leaving 7 minutes of questions in your 15-minute window), meeting the shared Demo Day requirements, plus: property-test results and a 60-second governance statement addressed to the audience as potential users; the partner-facing artifact may be a well-crafted public project page presenting the stakeholder context, what the artifact does, its limits, and how to get it

---

## Reflection Prompts

Answer individually in your final submission:

- Which course principle did your team most rely on, and where did you knowingly depart from one, with what consequence?
- What did your direction's rigor requirement (the baseline, the framework, or the gap verification) teach you that you did not expect?
- What did your community partner's feedback change about the work, and what did you decide not to change, and why?
- Using the four Open Questions (*What should matter to me?  How should we live together?  How can we understand the world?  What will I do?*), describe one specific new understanding and one area of growth or skill development from the Project Thread, from formation survey to Demo Day (Goal 15).

---

## Publish Gate

Publishing is effectively irreversible, so every team passes this gate before it publishes.  The [ShipIt guide]({{ site.baseurl }}/Tutorials/ShipIt) walks through each step.

**Directions A and C.**

1.  CI runs your real tests on every push, and you can show one red run and one green run.
2.  You audited the package before it left your machine (`npm pack --dry-run`, `docker image inspect`, or the deploy directory listing), and it holds no credentials or private data.
3.  Publishing requires a green CI run, and a person on your team, not an agent, runs the publish step.
4.  A classmate installed or ran the artifact from your public README alone, and their confirmation is in your artifacts folder.
5.  The README says what the artifact is, how to install it, and how to use it, and it names each member's contribution.

**Direction B.**  You have no CI or registry.  Before your write-up goes public, confirm that every claim has its citation, that it holds no private data, and that someone outside your team could say what you found after reading it.

---

## Self-Check Before Demo Day

**The system**

- [ ] It runs, end to end, from a clean checkout, following only our own written instructions.
- [ ] Someone who did not build it has followed those instructions successfully.
- [ ] We know which parts are fragile, and the demo does not depend on them.
- [ ] For every agent or automated action: we can say how it is **observed**, what it can **reach**, and how it is **undone**.

**The evidence**

- [ ] Claims about how well it works are backed by an evaluation we ran, with numbers, not by the demo going well once.
- [ ] At least one honest failure or limitation is documented, and we can talk about it without defensiveness.
- [ ] The Responsible AI Report is backed by measurements: token counts for every evaluation run, traces we can walk, a correctness audit with a pass rate, and a bias probe with disaggregated results.

**The audience**

- [ ] The stakeholder's problem is recognizable in the first two minutes.
- [ ] There is a version of the explanation that works for a non-technical listener, and we have practiced it out loud.
- [ ] The partner-facing artifact is something they could actually use after we graduate.

**The paperwork**

- [ ] GOVERNANCE.md (Directions A and C) or the governance document (Direction B).
- [ ] Contribution statements naming who did what.
- [ ] AI-use disclosure for the team's work.
- [ ] The publish gate passed.
- [ ] The Responsible AI Report, with its evidence in the artifacts folder.

**The rehearsal**

- [ ] We have run the whole demo on the clock, on the machine we will use, on the network we will have.
