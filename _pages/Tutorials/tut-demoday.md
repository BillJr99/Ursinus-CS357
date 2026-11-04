---
layout: textbook
permalink: /Tutorials/DemoDay
title: 'CS357: Foundations of Artificial Intelligence - Demo Day: External Guests and Technical Interview Practice'
info:
  coursenum: CS357
  purpose: "To prepare you to present your project to people beyond the course by practicing the plain-language pitch, the limitation disclosure, and the interview-style close examination of a system you built."
  eyebrow: "Tutorial"
  numbering: false
tags:
- demo-day
- final-project
- communication
---
*To prepare you to present your project to people beyond the course (your community partner, invited alumni and industry guests, and eventually interviewers) by practicing the plain-language pitch, the limitation disclosure, and the interview-style close examination of a system you actually built.*

This guide is not separately graded.  The presentation is assessed within the Final Project's **Product** dimension, and the mock-interview rehearsal is credited as **class participation**.

Demo Day is already a multi-audience event: your community partner's world and your CS peers' world meet in one room.  This guide widens the circle one step further.  Alumni, industry guests, and faculty from other departments may join as audience members and Q&A panelists, invited **as available**; your grade never depends on who attends.  The guide prepares you for the skill all of those audiences share with a technical interviewer: explain a system you built, in plain language first and full depth on request, defend your decisions, and be honest about what does not work.  Nothing here is extra work.  It is rehearsal for work you already owe.

## Goals

- To open your project for a non-specialist in ninety seconds: the stakeholder problem, what the system does about it, and what working means, without jargon
- To practice the interview form on your own work by explaining your agent architecture, defending a topology or scoping decision, and telling a real failure story with its mitigation
- To handle questions honestly, including redirecting a question you cannot answer and disclosing a known limitation without being asked
- To connect the project to what comes next, whether that is a portfolio story, a resume conversation, or venues for presenting student work beyond the course

## Background Reading and References

- [Project Studio Protocol]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-projectstudio.md)
- [Final Project]({{ site.baseurl }}/Projects/FinalProject)
- [ShipIt Guide: Build, Test, CI, and Publish One Artifact]({{ site.baseurl }}/Tutorials/ShipIt)

## What Strong Work Looks Like

- **The opener lands with someone who has never heard of an agent loop.**  "Our partner's food pantry answers the same fifty questions by phone every week.  We built a system that answers them from the pantry's own documents, says *I don't know* when the documents don't say, and never sends anything without a human approving it.  I built the retrieval piece that finds the right document."  Ninety seconds, no jargon, ends with what *working* means, and what the system refuses to do.
- **Depth is available on demand, not imposed up front.**  When a guest asks "how does it actually work?", the answer walks one request through the system (perceive, plan, act; what each agent sees, decides, and hands off) at whatever level the asker's follow-ups invite.
- **Limitations are volunteered before anyone has to pull them out of you.**  Strong presenters disclose a rehearsed failure mode with its transcript evidence (or, for audit teams, a finding with its citations) before anyone asks.  It reads as command of the work, because it is.
- **Questions come back.**  The best conversations at Demo Day are two-way.  Ask a guest what they build, how their team uses (or refuses) AI tools, and what they wish new graduates knew.

## The One-Page Brief: Talking to Guests

> **Do this.** Have these five moves rehearsed before Demo Day:
> 1. **The ninety-second opener.**  The stakeholder problem in the partner's terms, what your project does about it, who it is for, and one sentence on what you personally built.  Write it, say it aloud, and cut every term a non-CS friend would stumble on.  (Your stakeholder-facing Demo Day segment is the long form of this; the opener is the version you give a guest standing in front of your table.)
> 2. **The three-sentence architecture.**  The system in plain words: *a request comes in; specialist agents each handle their piece, one retrieves evidence, one drafts, one critiques; a human approves anything consequential before it happens.*  Then one sentence on where your part lives.  Audit teams give the framework in plain words instead: *we mapped who the system touches, measured where it fails, and wrote the rules a real organization could adopt.*
> 3. **The limitation.**  One known failure mode or finding, stated plainly, with its evidence and why you triaged it as disclose-rather-than-fix.  Practice saying it without apologizing.
> 4. **The redirect.**  For questions you cannot answer: "I don't know, but here's how I'd find out."  That is a strong answer, and bluffing is the only weak one.  In this course, saying *I don't know* when the evidence is absent is literally what we graded your systems on.  Speak to your own contributions in the first person.  When a question reaches a part a teammate built, answer for the team rather than passing the question along: how the team designed, tested, and decided on that part, and what it does in the product as a whole.
> 5. **The question back.**  Prepare two real questions to ask a guest, about their work, how AI is changing it, or their path.  Demo Day is a networking event wearing a final-exam costume; treat the conversation as two-way.

## The Mock Technical Interview (Final Integration and Demo Rehearsal Studio)

During the *Final Integration and Demo Rehearsal* studio, you will pair **across teams** for interview rounds, credited as class participation.

**Format.**  Ten minutes per round, then swap roles.  The interviewer asks from the question bank below (or invents better ones).  The interviewee answers **without slides**; a whiteboard or paper is allowed, your repository is not.  Close each round with an SQR-style feedback card: one **Strength** with evidence, one **Question** the interviewee should be ready for at Demo Day, and one **Risk** in how they explain the project, with a suggested fix.

**Question bank** (interviewers: pick three or four, follow the answers, dig where they wobble):

- Walk me through your agent architecture: what happens to one request, from arrival to answer, naming each agent and what it hands to the next.
- Why this topology over a monolith?  What did the baseline comparison actually show, and what would make you go back to the monolith?
- Tell me about a failure you found in your own system: how you caught it, what the transcript showed, and what changed after your mitigation.
- Where does your system say "I don't know," and how do you know it actually does?
- What would you do with two more weeks?  Two more months?
- (For audit teams) Which of your findings would the operator dispute most vigorously, and what is your evidence when they do?
- (For open-source teams) A stranger files an issue saying your quickstart fails on their machine.  Walk me through what you do.

**Why cross-team pairs:** explaining your system to someone who has never seen it is the whole game.  Your own teammates know too much to be useful practice, and interviewing *them* about their project teaches you what good interviewer questions feel like from the inside.

## Taking It Further

The project does not have to end at Demo Day:

- **[CCSC-Eastern](https://ccscne.org/)** and similar regional conferences run **student poster sessions**.  An evaluated multi-agent system, a regulator-ready audit, or a published open-source tool is exactly the kind of work they exist to present.  Talk to the instructor about submitting; your proposal and report are most of the abstract.
- **Campus research and creative-work showcases** welcome course projects of this scope.  Presenting there is a low-stakes rehearsal for any external venue.
- **Your profile.**  The [ShipIt guide]({{ site.baseurl }}/Tutorials/ShipIt)'s portfolio entry (the pinned repository or public write-up and the 200-word project story) is the durable version of everything you rehearsed here.  Update your resume and LinkedIn while the numbers (evaluation results, test counts, the registry link) are fresh.

## Frequently Asked Questions

**Q: Will there definitely be external guests at Demo Day?**
A: Guests are invited as available.  Some years the room is full; some years it is classmates, partners, and faculty.  Prepare the same either way: the Product rubric's multi-audience expectations do not change, and the mock-interview rehearsal happens regardless.

**Q: Does talking to guests affect my grade?**
A: The presentation is graded by the Final Project's existing rubric.  Guest attendance and guest reactions are never grading conditions.  The mock-interview rehearsal is credited as ordinary class participation for the studio session it happens in.

**Q: I get nervous in interview settings.  Can I opt out of the mock interview?**
A: Talk to the instructor beforehand; the format can be adjusted (a smaller room, a written walk-through, extra prep time).  The rehearsal exists because the tenth time explaining your architecture is calmer than the first.  We want you to spend the nervous repetitions here, where they are cheap.

**Q: Our project is an audit with no running system.  What do we demo to a guest?**
A: The evidence walkthrough is your demo: one failure mode, its mechanism, and the trail of citations behind it, shown rather than asserted.  Done well, an audit conversation can be among the most engaging in the room, for guests and classmates alike.

## Demo Day Guide Reflection Prompts

Answer individually after the mock-interview rehearsal, connecting to the course's Open Questions, especially *What will I do?*  (Goal 15):

- Which question made you realize you understood something less well than you thought, and what did you do about it before Demo Day?
- What did you learn from being the *interviewer* that you could not have learned as the interviewee?
- You practiced telling the story of work you built with AI assistance, honestly disclosed.  How does that conversation change what you will claim (and disclose) about your work after this course?

## Demo Day Guide Self-Check

| Criterion | Pre-Emerging | Beginning | Progressing | Proficient |
|---|---|---|---|---|
| Self-Check: Guest-Facing Communication | I cannot explain the project without assuming the listener took this course | I can describe the project, but my opening runs long, leans on jargon, or hides what does not work | I can open the project in about ninety seconds in plain language and disclose a limitation when asked, though my answers to unexpected questions still wobble | I can open the project in ninety seconds in plain language, volunteer one rehearsed limitation or failure mode with its evidence, redirect a question I cannot answer honestly ("I don't know, but here is how I would find out"), and ask a guest a real question back |
| Self-Check: Mock Technical Interview | I skipped the rehearsal or could not explain my own part of the system | I explained my component but not how it connects to the rest of the system, or I could not tell a single concrete failure story | I walked my partner through the architecture, defended one design decision, and told one failure story with its mitigation, though I leaned on notes or slides | Without slides, I explained the system end to end, defended a design decision by naming the alternative we rejected and why, told a failure story with its measured mitigation (or a finding with its evidence, for audit teams), and asked my partner at least one probing question about their project when roles reversed |
| Self-Check: Portfolio Story | I have no way to show this project to anyone outside the course | I can point at the repository or write-up but cannot yet tell its story in a way a recruiter would follow | My 200-word project story exists and names my contribution, though it is not yet linked from anywhere or rehearsed aloud | My project story is written, linked from my profile or portfolio per the ShipIt guide, rehearsed aloud as a two-minute narrative, a drafted (publication-optional) LinkedIn-style post exists, and I can produce the evidence behind every claim in it on request |
