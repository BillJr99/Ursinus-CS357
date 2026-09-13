---
name: small-model-orchestrator
description: Reliability and orchestration protocol for difficult coding, tool-use, research, data, document, and mixed tasks, especially with small local or offline language models. Use when correctness matters more than latency or token cost and the agent should plan progressively, maintain persistent state, work reversibly, verify every consequential action, test aggressively, diagnose failures, retry and replan, run measured refinement loops, and perform adversarial gauntlet review before declaring success.
license: MIT
metadata:
  author: Bill + OpenAI
  version: "0.3.0-platform-agnostic"
  primary-use-case: "local-offline-private-models"
  optimization-target: "maximum-verified-task-success"
---

# Small Model Orchestrator

Maximize verified task success using reversible work, durable state, and evidence.
Context capacity is a correctness constraint even when token cost and latency are
unimportant. Never rely on the conversation being available after a failed call.

## Operating rules

- Preserve user goals, acceptance criteria, existing work, and permission boundaries.
  A resume checkpoint does not grant new permission to commit, send, delete, or publish.
- Separate model confidence from verified evidence. State a postcondition, perform
  the action, check the result, and record the evidence for consequential work.
- Prefer isolated worktrees, branches, or snapshots where appropriate and permitted.
- Continue while a credible new approach remains; do not retry an unchanged failing
  payload. Bound each recovery episode even when the overall task is long-running.
- Maintain `.small-model-orchestrator/` for substantial tasks. Keep detailed evidence
  and raw logs on disk, with concise references in the active context.
- Log observable actions and decisions, never private chain-of-thought.

## Bootstrap and plan

1. Read the task and applicable project instructions. Check for an existing
   `RESUME.md` before creating task state; distinguish a new task from a resumed one.
2. On recovery, follow [context-recovery.md](references/context-recovery.md) first.
   Read the bounded checkpoint, verify its task identity and relevant disk state,
   and load only the missing contract or current-plan sections.
3. For a new substantial task, create a compact contract covering objective, scope,
   constraints, assumptions, outputs, acceptance criteria, verifiers, and permissions.
   Existing templates and `scripts/bootstrap_workspace.py` are optional; preserve
   existing state and obey applicable batch-write permissions.
4. Maintain a milestone outline and expand only the next executable subtask into
   atomic actions, with dependencies, expected results, verifiers, and recovery paths.
   Use [planning.md](references/planning.md) when detailed planning is needed.
5. Load only the reference needed for the current phase and task type. Do not load
   all verification, failure, refinement, and critic references at bootstrap.

## Execute and checkpoint

For each consequential action:

1. Verify preconditions and record the intended action and verifier. Before a
   mutation, save an `in_flight` checkpoint whose status is `UNKNOWN` until checked.
2. Execute the smallest meaningful action. Keep reads and generated edits bounded.
   For large logs, save the full output to a file and inspect selected ranges or
   a deterministic summary. Keep tool status and exit codes with the log.
3. Inspect sufficient evidence for the postcondition. A truncated tool response is
   not complete evidence, but does not require reloading the entire output.
4. Mark the action VERIFIED, FAILED, BLOCKED, INVALIDATED, or NEEDS_REVIEW.
5. Save the next action, its verifier, and evidence paths in `RESUME.md`. Update
   the checkpoint before context rollover, after a failure, and at milestone changes.

Use `scripts/checkpoint.py --root <project-root> write` with a JSON object on stdin
for validated atomic checkpoints. Its schema and usage are in
[context-recovery.md](references/context-recovery.md); limits are in
`assets/checkpoint-config.json`. If unavailable, write a temporary checkpoint,
validate it, and atomically replace the current checkpoint within permissions.
Do not overwrite a valid checkpoint with a partial generation.

## Context and interruption recovery

These bounded-context rules take precedence over any older reference language
requiring exhaustive planning, full-result reads, all-ledger resume reads, or an
unlimited retry of the same call. Preserve complete evidence on disk; load only
what is necessary to choose and verify the next action.

- Treat a reported window as untrusted until the host reconciles it with the
  server's active allocation. Model metadata can describe a larger maximum.
- Use the host's compaction margin and output limits. A summary is not a replacement
  for the durable checkpoint. Do not wait for overflow to save state.
- On input/context overflow, checkpoint if possible, compact once, and if that fails
  or overflow recurs without progress, request a fresh session from `RESUME.md`.
  Do not ask an already overflowing context to produce an exhaustive rescue summary.
- On output-token exhaustion or an incomplete tool-call payload, inspect actual
  tool execution and affected files before retrying a smaller action. Never blindly
  concatenate incomplete JSON, shell commands, or code. Reverify repaired artifacts.
- On tool-output truncation, narrow the query or read specific ranges from the
  saved complete output. Preserve unresolved issues and acceptance criteria.
- On a crash or transport failure, treat the last in-flight mutation as UNKNOWN.
  Check its effects before any replay. A disconnected client does not prove that
  the server or tool performed no action.
- A skill cannot restart a dead process. Use the host's supported session storage
  and fresh-session mechanism to resume from the checkpoint without replaying the
  old transcript. If those capabilities are unavailable, report the checkpoint
  location and the manual steps needed to resume in a new session.

## Verify, refine, and review

Reproduce and diagnose failures using [failure-recovery.md](references/failure-recovery.md).
Change the hypothesis, inputs, tactic, or decomposition before another attempt.
Re-run the original failing verifier and checks appropriate to the affected scope.

Use [verification.md](references/verification.md) for final acceptance. Evidence
must cover every acceptance criterion; distinguish existing checks from new ones.
Run a measured refinement loop only when it serves a task criterion, using
[refinement.md](references/refinement.md). Do not create endless optional work.

Use [gauntlet.md](references/gauntlet.md) for adversarial review of consequential
outputs. Prefer a fresh-context critic using the same model when available and
permitted; disclose when review is a self-review. Give the critic the contract,
artifact/diff and relevant evidence, not the entire builder transcript. Preserve
all review dimensions, but perform focused passes whose inputs fit the context.
Repair blocking findings and reverify the affected behavior.

Stop without success when a concrete external blocker exists or credible new
approaches are exhausted after diagnosis and higher-level reconsideration. Report
what remains and how to resume. Never mistake interrupted output for completion.

## References on demand

- [Control loop](references/control-loop.md): detailed state transitions; use the bounded resume protocol above.
- [Planning](references/planning.md): progressive decomposition and plan revisions.
- [Context recovery](references/context-recovery.md): checkpoint schema and failure handling.
- [Tool use](references/tool-use.md): semantic preflight/postflight checks; keep read-only checks concise.
- [Coding](references/coding.md), [research](references/research.md), [data](references/data.md),
  [documents](references/documents.md), [general reasoning](references/general-reasoning.md): current task's checks only.
- [Git reversibility](references/git-reversibility.md): authorized isolation and checkpoints.
- [Local models](references/local-models.md): model policy; host configuration governs actual context.
- [Output format](references/output-format.md): answer and verification ledger.

## Completion

Return the requested result, concise verification and limitations, and paths to the
observable execution record. Do not inline full logs or repeat the entire plan.
Save a final checkpoint with status VERIFIED, BLOCKED, or STAGNATED as appropriate.
