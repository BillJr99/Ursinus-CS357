---
layout: assignment
permalink: /Projects/FinalProjectProposal
title: "CS357: Foundations of Artificial Intelligence - Final Project Proposal"

info:
  coursenum: CS357
  purpose: "To commit your team to one defensible plan before you start building: a declared direction, a stakeholder-grounded problem, an argued set of design decisions, and a sprint timeline with named owners, so that the sprint window is spent executing a plan rather than discovering one."
  tilt:
    task: "With your standing team, write a 2-3 page proposal that declares your Final Project direction (A, B, or C), grounds it in your Stakeholder Brief and an initial evidence base, sketches the implementation and assessment plan with a GANTT-style timeline, includes the direction-specific elements, and discloses AI use."
    criteria: "I grade this on three course families worth 60 points between them: Approach (a defended direction and argued design decisions), Process and Professionalism (authorship, timeline, signatures, check-in, and disclosure), and Plan Quality (scope, feasibility, and stakeholder grounding).  The other 40 points come from the four AAC&U VALUE Problem Solving criteria that a plan can demonstrate.  The rubric below breaks it down in full."
  points: 25
  goals:
    - To declare one Final Project direction and defend it against the two you did not choose, naming what your team gains and gives up
    - To carry the stakeholder problem forward from the Stakeholder Brief into a scoped, buildable plan, and to state the gap the project addresses specifically enough that the Literature Review can later confirm or refute it (Goals 11, 12)
    - To argue every major design decision at the point where it is still cheap to change, naming the alternative rejected and the course pattern, principle, or evidence that motivated the choice
    - To size the work honestly against three sprints, producing a GANTT-style timeline with named owners and a role-rotation plan the team has agreed to
    - To anticipate failure before it happens through a pre-mortem, a preliminary risk hypothesis, or a verified gap, depending on direction
    - To practice visible, professional team process at the first milestone of the project, with per-section primary authorship, all-member signatures, and an honest AI-use disclosure (Goal 13)
  rubric:
    - weight: 22
      description: Approach, a defended direction and argued design decisions
      preemerging: No direction is declared, or a direction is named with no reasoning; design decisions are absent or are unexplained defaults; the direction-specific proposal elements are missing
      beginning: A direction is declared but the justification is generic ("it seemed most interesting") rather than tied to the team's stakeholder problem or capabilities; design choices are asserted rather than argued; several direction-specific elements are missing or filled in with placeholders
      progressing: The direction is declared and reasonably defended, most major design decisions are justified with reference to course patterns or evidence, and the direction-specific elements are present and substantially complete, with minor gaps in how the alternatives were weighed or in the specificity of one or more elements
      proficient: The direction is declared and defended against the two rejected alternatives in terms of the team's stakeholder problem and capabilities; every major design decision names the alternative that was rejected and the course pattern, principle, or evidence that motivated the choice; and all direction-specific elements are complete and specific (Direction A - an agent design table with per-agent temperature justification and isolated evaluations, a defended topology, a memory and context plan, a 5-row pre-mortem each with its owning checker or gate, and an evaluation plan naming the baseline and numeric metrics; Direction B - a named deployed system with an identified operator, affected populations traced to decisions, a framework choice defended against the two alternatives, a written-in-advance risk hypothesis, and two independent sources evidencing sufficient public information; Direction C - a stranger-legible artifact description, two to three specific personas, an exact install sequence, a gap verified against the closest existing alternative with linked evidence, a one-sentence minimum viable scope with stretch goals, and a governance sketch naming prohibited uses)
    - weight: 18
      description: Process and Professionalism, authorship, timeline, signatures, check-in, and disclosure
      preemerging: The proposal shows no evidence of team process, no per-section primary authors, no timeline, no signatures, and no AI-use disclosure
      beginning: Some process artifacts exist but are thin, the timeline is a list of tasks without owners or sprint boundaries, the role-rotation plan is missing, one or more members are not primary author of any section, signatures are incomplete, or the AI-use disclosure is a single generic sentence
      progressing: Per-section primary authorship, a GANTT-style timeline mapped to the three sprints, a role-rotation plan, all-member signatures, and an AI-use disclosure are all present, and the second intra-team check-in was submitted, but one element is thin, late, or inconsistent with what the rest of the proposal says (Goal 13)
      proficient: "Every student is named primary author of at least one section, editable by teammates; the GANTT-style timeline maps tasks to the three sprints with named owners and honest durations, and is consistent with the scope claimed elsewhere in the proposal; the role-rotation plan assigns Coordinator, Builder, Evaluator, and Scribe across sprint boundaries so every member holds every role; the document's version or commit history shows a real drafting trajectory rather than a single late paste; the proposal carries all members' signatures; the second intra-team check-in was submitted on time and its content is visibly reflected in the proposal's scope; and the AI-use disclosure states specifically what was AI-assisted, with what tool, why it was used there, and how the output was verified (Goal 13)"
    - weight: 20
      description: "Plan Quality: scope, feasibility, and stakeholder grounding"
      preemerging: The plan is too generic to act on, the scope is unbounded or unrelated to the team's stakeholder, and there is no evidence the work could be completed in three sprints
      beginning: The scope is stated but is either far too large for three sprints or so small it would not exercise the direction's requirements; the stakeholder connection is nominal, a sentence asserting relevance rather than a problem framed in the partner's terms
      progressing: The scope is plausible for three sprints and the plan builds on the Stakeholder Brief and an initial evidence base, but sprint boundaries are uneven, one milestone carries most of the risk, or the account of what the partner's needs imply for scope is thin
      proficient: The scope is specific, accessible, and demonstrably sized to three sprints, with each sprint producing a runnable increment or evidenced stage checkpoint and no single boundary carrying disproportionate risk; the problem appears in the partner's terms, the gap the project addresses is named specifically enough that the Literature Review that follows could confirm or refute it, and the proposal states explicitly what the partner's stated needs imply for scope, including what the team has decided not to do (Goals 11, 12)
    - weight: 9
      description: "Define Problem (AAC&U VALUE Problem Solving); here, the stakeholder problem carried from your Brief into the proposal"
      preemerging: Demonstrates a limited ability in identifying a problem statement or related contextual factors.
      beginning: Begins to demonstrate the ability to construct a problem statement with evidence of most relevant contextual factors, but problem statement is superficial.
      progressing: Demonstrates the ability to construct a problem statement with evidence of most relevant contextual factors, and problem statement is adequately detailed.
      proficient: Demonstrates the ability to construct a clear and insightful problem statement with evidence of all relevant contextual factors.
    - weight: 7
      description: "Identify Strategies (AAC&U VALUE Problem Solving); here, the directions and architectures you weighed before choosing"
      preemerging: Identifies one or more approaches for solving the problem that do not apply within a specific context.
      beginning: Identifies only a single approach for solving the problem that does apply within a specific context.
      progressing: Identifies multiple approaches for solving the problem, only some of which apply within a specific context.
      proficient: Identifies multiple approaches for solving the problem that apply within a specific context.
    - weight: 14
      description: "Propose Solutions/Hypotheses (AAC&U VALUE Problem Solving); here, the proposed project itself and its design decisions"
      preemerging: Proposes a solution/hypothesis that is difficult to evaluate because it is vague or only indirectly addresses the problem statement.
      beginning: Proposes one solution/hypothesis that is "off the shelf" rather than individually designed to address the specific contextual factors of the problem.
      progressing: "Proposes one or more solutions/hypotheses that indicates comprehension of the problem. Solutions/hypotheses are sensitive to contextual factors as well as the one of the following: ethical, logical, or cultural dimensions of the problem."
      proficient: "Proposes one or more solutions/hypotheses that indicates a deep comprehension of the problem. Solution/hypotheses are sensitive to contextual factors as well as all of the following: ethical, logical, and cultural dimensions of the problem."
    - weight: 10
      description: "Evaluate Potential Solutions (AAC&U VALUE Problem Solving); here, your pre-mortem, risk hypothesis, or gap verification, and the alternatives you rejected"
      preemerging: "Evaluation of solutions is superficial (for example, contains cursory, surface level explanation) and includes the following: considers history of problem, reviews logic/reasoning, examines feasibility of solution, and weighs impacts of solution."
      beginning: "Evaluation of solutions is brief (for example, explanation lacks depth) and includes the following: considers history of problem, reviews logic/reasoning, examines feasibility of solution, and weighs impacts of solution."
      progressing: "Evaluation of solutions is adequate (for example, contains thorough explanation) and includes the following: considers history of problem, reviews logic/reasoning, examines feasibility of solution, and weighs impacts of solution."
      proficient: "Evaluation of solutions is deep and elegant (for example, contains thorough and insightful explanation) and includes, deeply and thoroughly, all of the following: considers history of problem, reviews logic/reasoning, examines feasibility of solution, and weighs impacts of solution."
  readings:
    - rtitle: "Agent Teams"
      rlink: "../Tutorials/AgentTeams"
    - rtitle: "The Project Studio activity and its gallery-walk protocol"
      rlink: "Activities/liascript-projectstudio.md"
      liapage: true
    - rtitle: "Problem Solving VALUE Rubric (AAC&U); the four problem-solving criteria in the rubric below are quoted from it"
      rlink: "https://www.lamar.edu/data-analytics-reporting-analysis/_files/documents/problem_solving.pdf"

tags:
  - final-project
  - proposal
  - agents
  - governance
---

With your standing team, you will write a 2-3 page proposal that commits you to one Final Project plan: a declared direction (A, B, or C), a problem stated in your stakeholder's terms, argued design decisions, and a sprint timeline with named owners.  It is the first graded stage of the [Final Project]({{ site.baseurl }}/Projects/FinalProject), which is itself the last stage of the semester-long [Project Thread]({{ site.baseurl }}/Projects/PBLThread), and it is worth **25 of the Final Project's 100 points**.  The other 75 come from Demo Day and the final submission, and I grade those against the [Final Project rubric]({{ site.baseurl }}/Projects/FinalProject) rather than this one.  Your proposal builds on your team's [Stakeholder Brief]({{ site.baseurl }}/Assignments/StakeholderBrief).  The [Literature Review]({{ site.baseurl }}/Assignments/LitReview) is handed out the day this proposal is due, and it reads against the plan you commit to here.  You write the proposal under your signed charter and the [Team Playbook]({{ site.baseurl }}/Projects/PBLThread).

The sprint window is short.  A team that arrives at Sprint 1 with a declared direction, an argued architecture, named owners, and a written list of what could go wrong spends the sprints building.  A team that arrives still deciding spends the sprints deciding, and demos an apology.  Most of what the proposal asks for already exists in your team's work: the stakeholder you interviewed, the agent systems you designed in the labs, and the check-ins you have filed.  Read this page as an assembly plan, not a new assignment.

---

## Before You Start

- **Read the [Final Project]({{ site.baseurl }}/Projects/FinalProject) page in full**, including all three directions.  That page is the complete reference for the project.  This page describes the proposal deliverable and its rubric.
- **Know where this sits in the Project Thread.**  The proposal comes before the [Literature Review]({{ site.baseurl }}/Assignments/LitReview), on purpose.  You commit to a plan first, then you read against it.  The review will confirm parts of this document, complicate others, and occasionally kill one, and your team synthesis has to say which.  So propose the plan you believe in, not the plan that will be easiest to defend later.
- **Submit the second intra-team check-in.**  It is due two days before this proposal.  It is private, it goes to me, and it exists so that scope disagreements surface now rather than in week 14.  A check-in that says "everything is fine" from a team that is not fine wastes the instrument.
- **Length:** 2-3 pages, excluding the timeline, tables, and appendices.

**Choose your direction slowly.**  All three directions are real, and they suit different teams:

| Take | If your team |
|---|---|
| **A: Custom Agent Team** | Wants to build. You have people who enjoy making things run, and a stakeholder problem a multi-agent system actually fits |
| **B: Responsible AI Audit** | Wants to investigate. This is a **fully non-programming** direction and it is not the lesser one; a good audit is harder than a mediocre build |
| **C: Open-Source Agent** | Wants what you make to outlive the semester, and is willing to take documentation, packaging, and licensing as seriously as the code |

---

## What Every Proposal Must Include

Write these sections in this order.  Sections 1 through 5, 7, and 8 appear in every proposal.  Section 6 is the one direction-specific block that matches your declared direction; the three blocks are spelled out further down.

> **Do this.**
> 1. Direction declaration and problem statement
> 2. Direction defense
> 3. Stakeholder grounding
> 4. Implementation-and-assessment sketch, with the GANTT-style timeline
> 5. Design decisions
> 6. Direction-specific elements (A, B, or C)
> 7. AI-use disclosure
> 8. Signatures and per-section primary authors

### Section 1: Direction Declaration and Problem Statement

Declare the direction explicitly; do not leave it inferable.

> **Paste into your submission.**
> - The direction you are taking: A, B, or C, in so many words.
> - A one-paragraph problem statement naming the task or system, the affected users or populations, and the success criterion.

### Section 2: Direction Defense

Two or three sentences is enough, but they must be about *your* team and *your* stakeholder, not about the directions in general.

> **Paste into your submission.**
> - Why this direction, in terms of your stakeholder problem and your team's capabilities.
> - What you gain and give up relative to the two directions you did not choose.

### Section 3: Stakeholder Grounding

Build this section on your [Stakeholder Brief]({{ site.baseurl }}/Assignments/StakeholderBrief).  The [Literature Review]({{ site.baseurl }}/Assignments/LitReview) that follows tests your gap claim in depth, so state it here specifically enough to be proven wrong (Goals 11, 12).

> **Paste into your submission.**
> - The problem in the partner's terms.
> - The gap this project addresses.
> - The initial evidence you have that the gap is real: sources you have actually opened, per your direction's requirements.
> - What the partner's needs imply for scope, **including what you have decided not to do**.

### Section 4: Implementation-and-Assessment Sketch

Size the work honestly against three sprints (Goal 13).  Each sprint should end in a runnable increment or an evidenced stage checkpoint, and no single boundary should carry most of the risk.

> **Paste into your submission.**
> - Who holds which role in which sprint: a role-rotation plan that assigns Coordinator, Builder, Evaluator, and Scribe across sprint boundaries so every member holds every role.
> - How progress will be assessed at each sprint boundary.
> - A shared **GANTT-style timeline** mapping tasks to the three sprints, with a named owner and an honest duration on every task.

### Section 5: Design Decisions

This is the section that most distinguishes a proposal from a summary.  A decision that names no rejected alternative is a default, not a decision.

> **Paste into your submission.**
> - Each major design decision.
> - For each one: the alternative you rejected, and the course pattern, principle, or evidence that motivated the choice.

### Section 7: AI-Use Disclosure

Disclose AI use on the proposal itself.  Disclosed, verified AI assistance is professional practice; undisclosed AI assistance is an integrity violation.

> **Paste into your submission.**
> - What was AI-assisted, section by section.
> - Which tool you used.
> - Why you chose to use it there.
> - How you verified the output.

### Section 8: Signatures and Primary Authors

Every member signs, and every member is primary author of at least one section, editable by teammates.  I also read the document's version or commit history, which should show a real drafting trajectory rather than a single late paste.

> **Paste into your submission.**
> - A named primary author for each section.
> - Signatures from every team member.

---

## Direction-Specific Proposal Elements

This is Section 6 of your proposal; include only the block for your direction.  The elements match those listed under each direction on the [Final Project]({{ site.baseurl }}/Projects/FinalProject) page, which carries the full build requirements and final deliverables.

### Direction A: Custom Agent Team

The [Design Your Agent System]({{ site.baseurl }}/Assignments/AgentSystemDesign) written assignment is due the week after this proposal, and it develops these same artifacts in full depth.  Sketch them here at proposal fidelity: enough to defend the architecture and show the work is feasible.  The design assignment is where they become a specification someone else could build from.

> **Paste into your submission.**
> - An **agent design table**, one row per agent: role, system-prompt summary, inputs, outputs, temperature with justification, tools, and the isolated evaluation you will run on it.
> - A **topology statement** (pipeline, router, planner, blackboard, or hybrid) with a 3-sentence defense.
> - A **memory and context plan**: what each agent carries, summarizes, retrieves, and discards.
> - A **pre-mortem table** with at least 5 predicted risks (your specification gap, irreversible action, global invariant, and two more), each with the deterministic checker or gate that owns it.
> - An **evaluation plan**: the 10-task set sketch, numeric metrics (precision, recall, parse success rate, latency, or human rating), the protocol, and the **monolith baseline** description.

### Direction B: Responsible AI Audit

The system you audit must be specific: not "AI in hiring" but a named tool as deployed by a named operator.

> **Paste into your submission.**
> - **System identification**: name, operator, what it does, where it is deployed.
> - **Affected populations**: who is affected and how the system's decisions reach them.
> - **Framework choice** (NIST AI RMF, EU AI Act, or Montreal Declaration) with a 3-sentence justification for why it fits this system better than the alternatives.
> - **Preliminary hypothesis**: where you expect the highest risks to lie, written before the deep analysis.
> - Evidence that enough public information exists: at least two independent sources from an initial search.

> **Watch out.** Your framework choice may be provisional.  The *Governance, Policy, and the Cost of Inference* session comes after this proposal on the schedule, so declare the framework you expect to use and defend it as well as you can now.  You may revise that choice once, with a written justification, by the end of Sprint 1.  The other Direction B elements are not provisional.

### Direction C: Build and Publish an Open-Source Agent

> **Paste into your submission.**
> - **What the artifact does**, in one paragraph a stranger can understand.
> - **Who would use it**: two to three user personas with realistic, specific use cases.
> - **How they would install it**: the exact command sequence from a clean machine to a working demo.
> - **Gap verification**: the closest existing alternative, the specific gap it does not fill, and linked evidence the gap is real (a community post, GitHub issue, or unanswered Stack Overflow question where a real person asked for this).
> - **Minimum viable scope** in one sentence, plus two to three stretch goals.
> - **Governance sketch**: who is responsible, what the artifact must never be used for, and what risk the instructor should know about before approving.

> **Watch out.** If you are taking the **Direction C variant** (contributing to an existing open-source project rather than publishing a new one), the "what the artifact does / who would use it / how they would install it" elements describe the upstream feature you are adding.  Gap verification becomes issue selection, with linked evidence that a maintainer or real user wants it.  Scope must be approved here, in the proposal.

---

## How This Is Graded

The rubric has two halves, like the Final Project's:

- Three **course families** worth 60 points between them: **Approach** (a defended direction and argued design decisions), **Process and Professionalism** (authorship, timeline, signatures, check-in, and disclosure), and **Plan Quality** (scope, feasibility, and stakeholder grounding).
- Four criteria worth 40 between them, quoted verbatim from the **Problem Solving VALUE Rubric** published by the Association of American Colleges and Universities (AAC&U) and reproduced here under its permission for classroom use.  AAC&U's four performance levels map onto this course's four: *Benchmark 1* is read as pre-emerging, *Milestone 2* as beginning, *Milestone 3* as progressing, and *Capstone 4* as proficient.  The translation into a graded course rubric, and the weights, are mine.

Only four of AAC&U's six problem-solving criteria appear here, on purpose.  *Implement Solution* and *Evaluate Outcomes* cannot be demonstrated by a plan, so they are graded at Demo Day on the [Final Project rubric]({{ site.baseurl }}/Projects/FinalProject).  A proposal can show that you defined the problem, weighed the strategies, proposed something specific, and evaluated it honestly before committing.  That is why *Propose Solutions/Hypotheses* and *Evaluate Potential Solutions* carry the most weight of the four.

> **Why this matters.** Your pre-mortem (Direction A), preliminary risk hypothesis (Direction B), or gap verification (Direction C) is the evidence for *Evaluate Potential Solutions*, together with the alternatives you rejected and why.  A proposal that names no rejected alternative and predicts no failure cannot score above beginning on that criterion, however polished the plan looks.

---

## What Happens After You Submit

- **Incomplete proposals are returned ungraded.**  Complete means every shared element and every direction-specific element is present.  It does not mean every one is perfect.
- **Proposals whose scope is too generic, inaccessible, or infeasible in three sprints are redirected**, with specific guidance on what to cut or change.  A redirect is not a penalty.  It is much cheaper here than in week 14.
- **Sprint 1 begins from the approved proposal** and runs to the cross-team proposal critique at the *Project Studio: Sprint and Threat Model* session.  Your Sprint 1 milestone depends on your direction; see the sprint table on the [Final Project]({{ site.baseurl }}/Projects/FinalProject) page.
- **The [Literature Review]({{ site.baseurl }}/Assignments/LitReview) is handed out the day this is due**, and it reads against the plan you have just committed to.  Its team synthesis must state what the evidence confirms, complicates, or changes about this proposal.  A synthesis that changes nothing is a warning sign, not a clean bill of health.
- Some proposal artifacts are **living documents**.  The pre-mortem, the decision log, and the timeline are maintained through the sprints and resubmitted with the final artifacts folder.  They are not frozen here.

---

## Deliverables

| File or artifact | What it shows | Rubric row |
|---|---|---|
| The proposal (2-3 pages, Sections 1 through 8) | A defended direction, a problem in the partner's terms, a named gap, argued design decisions | Approach; Plan Quality; Define Problem; Identify Strategies; Propose Solutions/Hypotheses |
| GANTT-style timeline and role-rotation plan | Tasks mapped to three sprints with named owners; every member holds every role | Process and Professionalism; Plan Quality |
| Direction-specific block (pre-mortem, risk hypothesis, or gap verification, and the rest of Section 6) | You anticipated failure and weighed alternatives before committing | Approach; Evaluate Potential Solutions |
| AI-use disclosure | What was AI-assisted, with what tool, why, and how it was verified | Process and Professionalism |
| Signatures, per-section primary authors, version or commit history | Every member owns a section; the draft grew over time | Process and Professionalism |
| Second intra-team check-in, two days before the proposal | Scope disagreements surfaced early and show in the proposal's scope | Process and Professionalism |

---

## Self-Check Before You Submit

Answer these honestly as a team.  Every "no" is cheaper to fix now than at any later point in the project.

- [ ] Could a classmate outside your team read the problem statement and say who is affected and what success would look like?
- [ ] Does the proposal name at least one alternative you rejected, and say why?
- [ ] Would your community partner recognize their problem in your description of it, in their own words?
- [ ] Does the timeline have a named owner on every task, and does each sprint boundary produce something runnable or evidenced?
- [ ] Is there anything on the timeline that only one person on the team knows how to do?
- [ ] Have you written down what you are *not* doing?
- [ ] Is every team member primary author of at least one section, and can every member explain every section?
- [ ] Does the AI-use disclosure name the tool, the section, the reason, and the verification, rather than gesturing at "AI was used for editing"?
- [ ] Is your gap claim specific enough that the Literature Review could prove it wrong?
- [ ] If your most likely predicted failure happened in Sprint 2, does the plan survive it?
