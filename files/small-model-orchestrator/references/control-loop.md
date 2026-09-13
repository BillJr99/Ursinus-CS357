# Canonical Control Loop

Use this state machine as the procedural backbone.

```text
INTAKE
  ↓
ENVIRONMENT_INSPECTION
  ↓
CONTRACT
  ↓
PLAN
  ↓
PLAN_GAUNTLET
  ↓
REVERSIBILITY_BASELINE
  ↓
EXECUTE_ATOMIC_ACTION
  ↓
OBSERVE
  ↓
VERIFY
  ├─ PASS → UPDATE_STATE → next action
  └─ FAIL → DIAGNOSE → RETRY / REPLAN → EXECUTE
  ↓
MILESTONE_VERIFY
  ↓
MEASURED_REFINEMENT
  ↓
GAUNTLET
  ├─ finding → REPLAN / REPAIR / VERIFY
  └─ clean enough → FINAL_ACCEPTANCE
  ↓
VERIFIED_SUCCESS
```

Alternative terminal states are `BLOCKED` and `STAGNATED`, never an ambiguous "done".

## State transition rule

The model may choose semantic content inside a state, but it should not casually invent the next control state. Transition according to observed evidence.

## Resume rule

Before resuming after a context break or compaction, re-anchor from disk:

1. `RESUME.md` (authoritative checkpoint);
2. `git status --short`, `git log --oneline -5`, `git diff --stat`;
3. only the contract items, current `PLAN.md` section, and unresolved failure or
   gauntlet entries that the next action needs.

Then state the next planned action and its verifier before acting.

`UPDATE_STATE` means: commit the verified change, then update RESUME.md.

## Cycle awareness

Repeated state is not automatically bad. Repetition becomes unproductive when the same hypothesis/action yields equivalent evidence without new information. In that case, escalate the abstraction level of the repair rather than terminating immediately.

## Quality priority

When tradeoffs are not specified by the user:

1. correctness;
2. completeness;
3. safety / preservation of user data;
4. robustness;
5. maintainability;
6. simplicity;
7. performance;
8. tokens/latency/cost.

Task-specific user constraints override this ordering.
