---
layout: textbook
permalink: /Tutorials/ProjectCoordination
title: 'CS357: Foundations of Artificial Intelligence - Coordinating a Team Project'
info:
  coursenum: CS357
  purpose: "To show how a project team plans work, keeps track of decisions, and learns from each sprint, with a small example of each artifact."
  eyebrow: "Tutorial"
  numbering: false
tags:
- teams
- project
---
*How a team plans its work, tracks its decisions, and learns from each sprint.*

A team project rarely fails because nobody could do the work.  It fails because two people did the same work, or nobody did it, or a decision made in week two got reopened in week ten.  Each artifact below solves one of those problems, and all of them are short.  The examples are constructed for this page.

The team charter comes first, and the [Group Charter tutorial]({{ site.baseurl }}/Tutorials/GroupCharter) covers it.

## A GANTT-Style Timeline

A **GANTT chart** lays tasks out against time, so you can see what overlaps and what has to finish first.  You do not need special software.  A table with one row per task and one column per sprint is enough:

```text
Task                      Owner    Needs     Sprint 1   Sprint 2   Sprint 3
Draft evaluation set      Ana      -         XXXX
Baseline pipeline         Ben      -         XXXX
Add retrieval tool        Chris    baseline             XXXX
Run evaluation            Ana      tool                 XX
Fix top two failures      Ben      eval                    XXXX
Final write-up            everyone fixes                           XXXX
```

To build one:

1. List the tasks at the level of a day or two of work.  "Build the agent" is too big to assign or to estimate.
2. Give every task one named owner.  A task owned by two people is a task owned by no one, though others can help.
3. Write what each task needs before it can start.  This shows you the chain of tasks that cannot slip.
4. Estimate honestly, then add slack.  Things take longer than you think, and a sprint with no slack has already failed.

Update it at each sprint boundary, because the plan will change as you learn what the work takes.

## A Pre-Mortem

Before you start, imagine the project has failed, and ask why.  Each person writes down reasons on their own, and then the team combines them.  Because the failure is imaginary, people say what they would otherwise keep to themselves.

```text
Risk                               Likelihood  Impact  What we will do now
Partner stops answering            Medium      High    Agree on a backup user this week
Local model too slow to evaluate   High        Medium  Time 10 runs in Sprint 1, before we commit
One person holds all the context   Medium      High    Rotate who runs the pipeline each sprint
```

A risk with no action is only a worry, so give each one something you will do now.

## A Standup

A **standup** is a short meeting where each person answers three questions: what did I finish, what is next, and what is blocking me?  Keep the notes, because they become your record of who did what.

```text
Ben.  Done: baseline answers one task end to end.  Next: add logging.
      Blocked: need the evaluation set from Ana by Thursday.
```

Problems get named here and solved after, with only the people they involve.

## A Decision Log

A **decision log** records what you chose, what you rejected, and why, so that nobody has to reopen the question later.  Add a line whenever the team makes a choice someone could reasonably question.

```text
Date   Decision                Rejected           Why                          Who
       Use Chroma for search   A hosted service   No key to manage; runs local  Team
```

Six weeks from now, someone may suggest the hosted service again, and the "rejected" column says why you did not choose it.

## A Retrospective

At the end of each sprint, take fifteen minutes to ask three questions: what worked, what did not, and what will we change?

```text
Worked:     Pairing on the evaluation found two bugs quickly.
Did not:    We merged on the last night, and the demo broke.
Will change: Merge by the day before.  Ana owns the check.
```

Give the last line an owner, and start the next retrospective by asking whether you made that change.
