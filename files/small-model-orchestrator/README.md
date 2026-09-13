# small-model-orchestrator

Version: 0.4.0-platform-agnostic

A platform-agnostic reliability protocol for coding, tool use, research, data,
documents, and mixed tasks, especially with small or local language models.
It combines progressive planning, durable task state, reversible work,
evidence-based verification, failure recovery, and adversarial review.
The canonical agent instructions are in `SKILL.md`.

## Scope and portability

The skill does not require a particular agent application, model provider,
operating system, container runtime, or launcher. Load the skill directory using
your host's supported skill mechanism, or supply its instructions directly when
appropriate. Use only tools and permissions available in the current environment.

For substantial tasks, a writable workspace or equivalent durable storage is
needed for checkpoint-based recovery. Without durable storage, use the principles
that remain applicable and disclose the recovery limitation. The bundled Python
helpers are optional standard-library utilities; the protocol can be implemented
with equivalent host tools. Git is strongly recommended: the protocol uses local
commits on a task branch as its primary rollback and recovery mechanism, and falls
back to file snapshots with a disclosed weaker guarantee when Git is unavailable.

Host-specific launchers, integrations, and configuration files are outside this
package. Session creation, compaction, context detection, and reasoning settings
belong to the host. The skill describes when those capabilities are useful without
assuming their command names or implementation.

## Changes in 0.4.0

- Three invariants: RESUME.md is handoff-ready at all times; every verified step is
  a local Git commit on a task branch; disk (RESUME.md, Git, fresh reads) beats
  memory and compaction summaries.
- Concrete RESUME.md update triggers instead of a general reminder.
- Proactive, boundary-aligned compaction for any window size, with no context cap,
  and a mandatory re-anchoring step after every compaction or summary.
- Reliable-edit rules: re-read before editing, short anchors, whole-file rewrite
  after repeated edit failures, commit before deleting or moving.
- Coding: thin end-to-end slice first; smoke-test each module as it is written.
- `checkpoint.py`: optional `git` field and `--input FILE`.
- `git_checkpoint.py`: `--start TASK_ID` (safe task branch), `--log`, commits that
  tolerate "nothing to commit" and a missing Git identity, state-dir exclusion.

These changes respond to an observed failure pattern: with frequent compaction, a
small model trusted drifting summaries over disk, stopped updating its checkpoint,
edited from memory, and lost work to an unversioned delete.

## Reliability principles

- Plan progressively: maintain a milestone outline and expand the current subtask
  instead of generating exhaustive detail for the entire task at startup.
- Load references only when relevant to the current phase or task type.
- Keep raw logs and historical evidence in durable storage; retrieve bounded
  ranges or concise summaries rather than repeatedly loading full ledgers.
- Save a compact checkpoint before consequential mutations and after verification.
- Distinguish input overflow, output exhaustion, tool-output truncation, and
  transport/process failures; recover according to the observed failure.
- Start a fresh session from the checkpoint when compaction fails or context
  overflow recurs without progress, if the host provides that capability.
- Treat interrupted side effects as UNKNOWN until independently checked.

Context capacity is a correctness constraint even when token cost is unimportant.
A fluent response, successful command, or generated file is not proof of completion.

## Context configuration belongs to the host

The host should compare its declared context limit with the model service's actual
allocation. An advertised model maximum can exceed the capacity actually served.
If detection is unavailable, document an operator-supplied fallback appropriate
to that deployment; this skill imposes no universal context size.

Enable automatic compaction with a trigger that leaves headroom for a full response,
reasoning where applicable, a large tool result, and the summary itself. The skill
does not cap context; it asks the agent to checkpoint continuously, compact early at
task boundaries, and re-anchor from disk afterward.
Recheck effective capacity when model or runtime configuration changes. A larger
reasoning budget does not itself fix truncation. The skill cannot change server
allocation or guarantee that the host can compact or restart automatically.

## Durable checkpoint

The default project-local state directory is `.small-model-orchestrator/`.
`RESUME.md` holds the active checkpoint and is authoritative for handoff; contract,
plan, evidence, failures, and artifacts retain supporting detail. The state directory
is excluded from Git commits (via `.git/info/exclude`) so restoring old code never
restores a stale checkpoint. Preserve existing task state during updates.

Each checkpoint records:

- task identity and objective;
- constraints and permission boundaries;
- verified progress and unresolved issues;
- evidence locations;
- the exact next action and its verifier;
- any in-flight operation and its uncertain completion state;
- optionally, the task branch and last verified commit.

Before a consequential mutation, record the intended operation with completion
UNKNOWN. After checking its effects, record the result and next action. Lost
responses do not establish that an operation failed to execute.

`scripts/checkpoint.py` accepts a JSON object on standard input or via `--input FILE`, validates its
schema and limits, and atomically replaces RESUME.md only after a successful write.
Invalid, incomplete, or oversized input leaves the last valid checkpoint intact.
The helper flushes the file before replacement and also flushes the containing
directory on POSIX systems. It uses the filesystem's available durability guarantees.

The default limit is 8000 bytes, controlled by `assets/checkpoint-config.json`.
This is a byte limit, not an exact token count. Use one active checkpoint writer
per task directory and obey the user's file-write permissions.

See `references/context-recovery.md` for the full schema and usage. Resolve helper
paths relative to this skill directory and invoke them using the Python interpreter
available in your environment. If Python is unavailable, use equivalent validated,
atomic checkpoint writes through the host's tools.

## Failure-specific recovery

| Observation | Response |
|---|---|
| Input overflow or server input truncation | Reconcile context limits; try compaction once if viable, then use a fresh session if compaction fails or overflow repeats without progress. |
| Output limit or incomplete tool-call payload | Inspect actual tool execution and affected artifacts; split the action and rerun its verifier. |
| Tool output truncated or paginated | Narrow the query or inspect relevant ranges/pages while preserving full evidence where possible. |
| Connection lost, timeout, or process crash | Treat in-flight effects as UNKNOWN; check `git diff` and effects before replay. |
| Compaction or summary occurred | Re-anchor: read RESUME.md, `git status`/`log`/`diff`, re-read files before editing. |
| Failed or incomplete compaction | Preserve checkpoint and old session records; reconstruct working context from the checkpoint. |

Do not concatenate partial JSON, commands, or code into a supposed complete result.
Do not retry an unchanged failing payload indefinitely. Bound each recovery episode
while continuing the overall task when a credible new strategy remains.

## Fresh-session procedure

1. Open a new session through the current host's supported mechanism. Supply the
   original task identity and checkpoint location, without replaying the old transcript.
2. Read RESUME.md in bounded form, confirm task identity and current intent, and
   verify disk and Git state (`git status`, `git log`, `git diff`) and any in-flight effects.
3. Load only missing contract details, the active plan section, unresolved findings,
   and evidence needed for the next action.
4. Execute and verify the next unverified action, then update the checkpoint.

If no checkpoint exists, reconstruct from the contract, current state, and relevant
plan/evidence sections. Ask for missing task information rather than inventing it.
If the host cannot start a fresh session, give the operator concise resume instructions.
Recovery does not grant new permission for commits, messages, deletion, or publication.

## Included resources

- `SKILL.md`: compact operating instructions and reference routing.
- `references/`: task-specific verification, planning, review, and recovery guidance.
- `assets/templates/`: optional contract, plan, state, and evidence templates.
- `assets/checkpoint-config.json`: bounds for the optional checkpoint helper.
- `scripts/`: optional workspace, checkpoint, evidence, plan-version, and Git helpers
  (Python standard library only).
- `MANIFEST.sha256`: checksums for package contents.

## Validation and limits

The package is checked for valid skill metadata, working local reference paths,
archive integrity, and absence of provider-specific launchers and instructions.
The checkpoint helper has been tested to preserve the previous checkpoint when
new input is malformed or oversized. These checks do not establish compatibility
with every host or filesystem; helpers are optional and require a suitable Python
runtime where used.

A skill cannot restart a dead process, enforce model compliance, or establish the
outcome of an external mutation whose response was lost. Checkpoints, independent
verification, and host capabilities work together to make recovery possible.
Observable execution records include actions, results, decisions, and evidence,
never private chain-of-thought.
