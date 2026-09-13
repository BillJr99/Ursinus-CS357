# Failure Recovery

Failure is evidence. Preserve it before changing anything.

## Failure taxonomy

Classify as one or more:

- REQUIREMENT_MISREAD
- BAD_ASSUMPTION
- PLAN_ERROR
- TOOL_SCHEMA_ERROR
- TOOL_EXECUTION_ERROR
- ENVIRONMENT_ERROR
- DEPENDENCY_ERROR
- SYNTAX_OR_COMPILE_ERROR
- TYPE_ERROR
- LOGIC_ERROR
- TEST_ERROR
- TEST_ORACLE_ERROR
- INTEGRATION_ERROR
- DATA_ERROR
- PERMISSION_ERROR
- EXTERNAL_SERVICE_ERROR
- REGRESSION
- SECURITY_OR_SAFETY_ISSUE
- NO_PROGRESS
- UNKNOWN

## Recovery sequence

1. Capture the exact failure.
2. Identify the earliest stage at which the mistake became inevitable.
3. Decide whether the fix belongs at action, subtask, milestone, contract, or environment level.
4. Retry is allowed.
5. Prefer a changed element after failure.
6. Re-run the original reproducer after repair.
7. Run regression verification appropriate to blast radius.
8. Record the failed approach so it remains visible.

## Encouraged staged escalation

Not a mandatory attempt counter, but a preferred progression when repeated attempts fail:

1. correct execution details;
2. revise local hypothesis;
3. revise implementation strategy;
4. reformulate prompt/task representation;
5. obtain fresh evidence;
6. re-decompose subtask;
7. replan milestone;
8. reconsider architecture/assumptions;
9. cold critic asks what has not been tried.

Repeated identical attempts are permissible only when there is a reason to expect a different result, such as nondeterministic external state.

## Genuine stagnation

Do not use frustration, elapsed time, or attempt count as a stopping condition.

Stagnation requires:
- explicit blocker;
- evidenced lower-level repair attempts;
- higher-level replanning;
- at least one meaningfully different strategy attempted or ruled out;
- cold critic search for untried approaches;
- no credible next action, or an external capability/information/permission block;
- clear report of what would unblock progress.
