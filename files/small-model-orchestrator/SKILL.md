---
name: small-model-orchestrator
description: Reliability and orchestration protocol for difficult coding, tool-use, research, data, document, and mixed tasks, especially with small local or offline language models. Use when correctness matters more than latency or token cost and the agent should plan progressively, keep an always-current RESUME.md handoff checkpoint, version its work with Git, compact context proactively, verify every consequential action, diagnose failures, retry and replan, and perform adversarial gauntlet review before declaring success.
license: MIT
metadata:
  author: Bill + OpenAI
  version: "0.4.0-platform-agnostic"
  primary-use-case: "local-offline-private-models"
  optimization-target: "maximum-verified-task-success"
---

# Small Model Orchestrator

Maximize verified task success using durable state, versioned work, and evidence.
Assume the conversation can be summarized, truncated, or lost at any moment. What
survives is what is on disk: `RESUME.md`, the Git history, and the files themselves.

## The three invariants

1. **Handoff-ready at all times.** `.small-model-orchestrator/RESUME.md` must let a
   fresh agent with no transcript continue correctly if this session ended right now.
2. **Every verified step is a Git checkpoint.** Work can be inspected with
   `git log`/`git diff` and rolled back to the last good state.
3. **Disk beats memory.** After any compaction, summary, restart, or surprise, trust
   RESUME.md, Git, and fresh reads over recalled file contents or summary claims.

## Operating rules

- Preserve user goals, acceptance criteria, existing work, and permission boundaries.
- Separate model confidence from verified evidence. State a postcondition, act,
  check the result, and record the evidence for consequential work.
- Continue while a credible new approach remains; do not retry an unchanged failing
  payload. Bound each recovery episode even when the overall task is long-running.
- Keep raw logs and large outputs on disk; keep only references in active context.
- Log observable actions and decisions, never private chain-of-thought.

## Bootstrap

1. Read the task and project instructions. Check for an existing `RESUME.md` first;
   if present, this is a resume: follow [context-recovery.md](references/context-recovery.md).
2. Write a compact contract: objective, scope, constraints, outputs, acceptance
   criteria, verifiers, permissions. Write the first RESUME.md immediately.
3. Establish Git versioning per [git-reversibility.md](references/git-reversibility.md):
   inspect the repository, protect pre-existing changes, work on a dedicated task
   branch or worktree, and exclude `.small-model-orchestrator/` from commits.
4. Check the host's context management: whether automatic compaction is enabled and
   whether its trigger leaves room for a full response plus a large tool result.
   If you can adjust it within permissions, do so; otherwise tell the operator once.
   Do not shrink or cap the context window; manage how full it gets.
5. Keep a milestone outline and expand only the next subtask into atomic actions
   with expected results and verifiers ([planning.md](references/planning.md)).
   Load references only for the current phase and task type.

## Execute loop

For each consequential action:

1. Re-read the exact region you will change. Never edit from memory or a summary.
2. Record the intended action in RESUME.md as `in_flight` with status UNKNOWN.
3. Execute the smallest meaningful action. Save large outputs to files.
4. Verify the postcondition with a real check (run, test, import, read back).
5. Mark it VERIFIED, FAILED, BLOCKED, INVALIDATED, or NEEDS_REVIEW.
6. If VERIFIED, commit it: `task:<id> <action> VERIFIED`. Then update RESUME.md with
   the result, commit hash, next action, and verifier, and set `in_flight` to NONE.

Build a thin working slice end to end before adding breadth; smoke-test each new
file or module as soon as it exists, not after writing many.

## RESUME.md update triggers

Update RESUME.md (prefer `scripts/checkpoint.py`, which validates and writes
atomically) whenever any of these occur. Do not batch updates for later.

- before any mutation whose outcome would be unclear if interrupted;
- after each verified action or Git commit, and at every milestone change;
- after any failure, surprise, or change of plan or hypothesis;
- whenever you learn a fact a successor would need (an interface, path, gotcha);
- before context may be compacted, and before ending or pausing the session;
- at least every few tool calls during long read-only investigation.

Keep it bounded: link evidence and plan sections by path instead of inlining them.
Never overwrite a valid checkpoint with a partial one.

## Context management

Context overflow and lossy summaries are correctness risks for any window size.

- Prefer compaction at natural boundaries: after a commit and RESUME.md update, when
  a subtask ends. Compacting then loses little, because the state is already on disk.
- Compact before the window gets tight, not at overflow. If you can see usage, act
  once roughly half to two-thirds is used or before an action expected to produce
  large output. If you cannot see usage, treat several large reads or long outputs
  since the last checkpoint as a signal to checkpoint and compact.
- Before compaction: commit verified work, update RESUME.md. When writing or
  steering a summary, point to RESUME.md and file paths; do not restate code,
  interfaces, or file contents from memory, because those summaries drift from disk.
- After any compaction or summary, re-anchor before acting: read RESUME.md, run
  `git status` and `git log --oneline -5`, inspect `git diff` for in-flight changes,
  and re-read any file before editing it. Where the summary and disk disagree,
  disk wins; record the discrepancy.
- If compaction fails or overflow recurs without progress, checkpoint and request
  a fresh session from RESUME.md; do not ask an overflowing context for a rescue summary.
- On output-token exhaustion or a partial tool-call payload, inspect what actually
  executed before retrying a smaller action. Never concatenate partial code or JSON.
- On a crash or transport failure, treat the in-flight mutation as UNKNOWN and
  check `git diff` and affected files before any replay.

## Verify, refine, and review

Reproduce and diagnose failures with [failure-recovery.md](references/failure-recovery.md).
Change the hypothesis, inputs, tactic, or decomposition before another attempt; use
`git diff` against the last verified commit to see exactly what changed.

Use [verification.md](references/verification.md) for final acceptance: evidence must
cover every acceptance criterion. Run a measured refinement loop only when it serves
a criterion ([refinement.md](references/refinement.md)); revert failed experiments to
the last verified commit.

Use [gauntlet.md](references/gauntlet.md) for adversarial review of consequential
outputs. Prefer a fresh-context critic using the same model when available; give it
the contract, the diff from the task's base commit, and evidence, not the transcript.
Disclose when review is a self-review. Repair blocking findings and reverify.

Stop without success when a concrete external blocker exists or credible new
approaches are exhausted. Report what remains and how to resume.

## References on demand

- [Context recovery](references/context-recovery.md): checkpoint schema, re-anchoring, fresh sessions.
- [Git reversibility](references/git-reversibility.md): branch setup, commit cadence, rollback.
- [Tool use](references/tool-use.md): preflight/postflight checks and reliable edits.
- [Planning](references/planning.md) and [control loop](references/control-loop.md): decomposition and state transitions.
- [Coding](references/coding.md), [research](references/research.md), [data](references/data.md),
  [documents](references/documents.md), [general reasoning](references/general-reasoning.md): current task's checks only.
- [Local models](references/local-models.md): single-model policy.
- [Output format](references/output-format.md): answer and verification ledger.

## Completion

Return the requested result, concise verification and limitations, the task branch
and final commit, and paths to the execution record. Do not inline full logs. Save a
final checkpoint with status VERIFIED, BLOCKED, or STAGNATED. Do not push, merge,
or delete branches unless the user asked for it.
