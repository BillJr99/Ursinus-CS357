# Progressive Planning and Plan Versions

Keep the full task visible through milestones and acceptance criteria. Expand only
the current subtask into executable actions. Detail for distant subtasks can wait
until the relevant evidence exists. Context limits constrain the working plan.

Each current action needs purpose, inputs, dependencies, preconditions, intended
operation, expected result, verifier, recovery method, and evidence location.
Keep these concise. Read the current section of a large PLAN.md, not its full history.

Before execution, check for uncovered requirements, missing verifiers, untested
assumptions, implicit dependencies, and irreversible actions lacking authorization.
Revise the affected section when evidence changes the plan. Record the reason and
which completed steps remain valid; preserve old plan versions on disk using
scripts/plan_version.py when useful and permitted.

At each milestone, check acceptance coverage and expand the next subtask. Archive
completed detail rather than repeating it in the current conversation. RESUME.md
points to the active plan section and exact next action/verifier.
