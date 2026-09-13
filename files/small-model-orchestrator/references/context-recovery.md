# Durable Checkpoints, Compaction, and Recovery

## RESUME.md is the handoff document

RESUME.md must always be good enough for a different agent, with no transcript, to
continue the task correctly. It is authoritative over conversation memory and over
any compaction summary. Other state files (contract, plan, evidence, failures) hold
detail; RESUME.md points to them.

Write it with the helper, relative to this skill's directory. JSON can come from
stdin or, more robustly, from a file written first with a normal file-write tool:

```bash
python3 scripts/checkpoint.py --root /path/to/project write --input /path/to/checkpoint.json
```

```json
{
  "task_id": "repair-parser-20260913",
  "objective": "Repair the parser while preserving its public API",
  "constraints": ["Local commits on smo/repair-parser-20260913 only; no push", "Contract: .small-model-orchestrator/CONTRACT.md"],
  "status": "IN_PROGRESS",
  "verified": ["Reproducer fails on baseline: .small-model-orchestrator/artifacts/baseline.txt", "parse_expr(tokens) -> Node is the public entry point (src/parser.py)"],
  "unresolved": ["Empty input behavior remains unverified"],
  "evidence": ["artifacts/baseline.txt", ".small-model-orchestrator/PLAN.md: milestone 2"],
  "next_action": "Re-read src/parser.py lines 40-80, then apply the planned empty-input guard",
  "verifier": "Run the original reproducer and tests/test_parser.py",
  "in_flight": "NONE",
  "git": "branch smo/repair-parser-20260913; base a1b2c3d; last verified 9f8e7d6"
}
```

`git` is optional; all other keys are required. The helper validates fields and size
limits, then atomically replaces RESUME.md. Invalid, truncated, or oversized input
leaves the last valid checkpoint intact. Use `show` to read it back in bounded form.
If the helper is unavailable, write a temporary file, check it, and rename it over
RESUME.md. Keep one active writer per task directory.

Record facts a successor needs in `verified` (actual interfaces, paths, gotchas), not
just progress claims. Before a consequential mutation, set `in_flight` to the intended
action with UNKNOWN completion; after verification and commit, set it to `NONE`.

## Proactive compaction

The goal is never to overfill the window, whatever its size, and never to lose state
when compaction happens.

Host settings (check at bootstrap; change only within permissions, else tell the
operator): automatic compaction should be on, and its trigger should leave headroom
of at least one maximum-length response, reasoning allowance if applicable, one
large tool result, and the summary's own output. Do not reduce the context window.

Agent behavior:

1. Checkpoint continuously (see SKILL.md triggers) so compaction at any moment
   loses nothing important.
2. Prefer compacting at boundaries: after a verified commit and RESUME.md update.
3. Compact early: at roughly half to two-thirds usage when usage is visible, or
   after several large reads or outputs since the last checkpoint when it is not.
4. Avoid loading content that will not be used: read ranges, save large outputs to
   files, grep before reading, and keep only paths and conclusions in context.
5. When writing or steering a summary, include: task id, RESUME.md path, task branch,
   last verified commit, and the next action. Do not reproduce code, interfaces, or
   file contents from memory; point to the files instead.

## Re-anchoring after compaction, summary, or restart

Summaries are lossy and can be confidently wrong about what is on disk. Before the
next action:

1. Read RESUME.md (`checkpoint.py show`). Confirm task identity.
2. Run `git status --short`, `git log --oneline -5`, and `git diff --stat`.
3. If `in_flight` is not NONE, or the diff shows uncommitted changes, decide from
   evidence whether that action completed; do not replay blindly.
4. Re-read any file before editing it, and any interface before calling it.
5. Where the summary disagrees with disk, disk wins. Note the discrepancy in RESUME.md.

## Recovery routing

| Observation | Required action |
|---|---|
| Context exceeded, prompt too long, or input truncation | Checkpoint if possible. Compact once, then start fresh from RESUME.md if it fails or overflow recurs without progress. |
| Output length limit, incomplete tool payload, or cut-off code | Inspect what executed (`git diff`, affected files). Split the action and rerun its verifier. |
| Tool output truncated or paginated | Save the complete output to a file; read relevant ranges. |
| Connection lost, timeout, or crash | Treat the in-flight action as UNKNOWN; check `git diff` and effects before retrying. |
| Edits fail or files look different than expected | Stop editing from memory. Re-anchor as above, then re-read the exact region. |
| Summary incomplete or compaction failed | Preserve RESUME.md and old session records; use a fresh session. |

## Fresh-session protocol

1. Open a new session through the host's supported mechanism, giving the task
   identity and RESUME.md path, not the old transcript.
2. Re-anchor as above.
3. Load only the contract items, active plan section, and unresolved findings
   needed for the next action.
4. Execute and verify the next action, commit, and update RESUME.md.

If no RESUME.md exists, reconstruct from CONTRACT.md, the active PLAN.md section,
and `git log` on the task branch; ask for missing task information rather than
inventing it. If the host cannot start a fresh session, give the operator concise
resume instructions. Recovery does not grant new permissions.

## Host capabilities and limits

The host owns the context window, compaction mechanism, and session storage. It
should reconcile its declared window with the model service's actual allocation;
an advertised model maximum can exceed what is served. This skill names no provider
APIs, configuration keys, or commands. It cannot force a model to follow checkpoint
instructions, restart a dead process, or make replay of arbitrary side effects safe;
continuous checkpoints, Git history, and independent read-back remain essential.
