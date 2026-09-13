# Bounded Context and Durable Recovery

## Checkpoint contract

Use a task-specific ID. Keep objective, permission constraints, unresolved issues,
and the next action/verifier explicit. Refer to detailed evidence and plan sections
by file path. Checkpoint sizes are byte limits, not exact tokenizer counts.

Run the helper relative to this skill's directory, with JSON on stdin:

```bash
python3 scripts/checkpoint.py --root /path/to/project write <<'JSON'
{
  "task_id": "repair-parser-20260913",
  "objective": "Repair the parser while preserving its public API",
  "constraints": ["No commits or deletion without confirmation", "Contract: .small-model-orchestrator/CONTRACT.md"],
  "status": "IN_PROGRESS",
  "verified": ["Reproducer fails on the baseline: artifacts/baseline.txt"],
  "unresolved": ["Empty input behavior remains unverified"],
  "evidence": ["artifacts/baseline.txt", ".small-model-orchestrator/PLAN.md: milestone 2"],
  "next_action": "Inspect the current parser implementation before applying the planned fix",
  "verifier": "Run the original reproducer and existing parser tests",
  "in_flight": "UNKNOWN: previous edit may have been applied; inspect the file and diff before retrying"
}
JSON
```

The helper validates required fields and bounds before replacing RESUME.md with
an atomic, flushed write. Invalid or truncated JSON leaves the last valid checkpoint
intact. Use `show` instead of `write` to read a size-checked checkpoint. Maintain one
active writer per task directory. Checkpoint updates remain subject to user permissions.

Before a consequential mutation, record the intended action as in-flight with
UNKNOWN completion. After independent verification, record its result and set
in_flight to `NONE` when appropriate. If a call fails between these checkpoints,
the old intent survives and prevents unsafe blind replay. Never infer successful
completion from the mere existence of a generated file.

## Recovery routing

| Observation | Required action |
|---|---|
| Context exceeded, prompt too long, or server input truncation | Check the host's effective context configuration. Try one compaction if viable, then start fresh from the checkpoint if it fails or overflow repeats without progress. |
| Output finish reason length, incomplete JSON/tool payload, or cut-off code | Inspect actual tool execution and affected artifacts. Split the action, reserve answer space if thinking used the budget, and rerun the affected verifier. |
| Tool output truncated or paginated | Keep the complete output on disk where possible; read relevant ranges or retrieve needed pages. Do not load everything to satisfy a completeness ritual. |
| Connection lost, timeout, or process crash | Check whether the action completed before retrying. Resume from durable state and preserve the saved session for diagnostics. |
| Summary incomplete or manual compaction failed | Preserve the checkpoint and old session. Use a fresh session; do not summarize the failing transcript repeatedly. |

## Fresh-session protocol

1. Read RESUME.md in bounded form. If missing, inspect CONTRACT.md, STATE.md, and
   only the current PLAN.md section to reconstruct it. If those are insufficient,
   request the missing task information instead of guessing.
2. Confirm task identity and current user intent. Check evidence paths, modified
   files, and any in-flight effects before trusting the checkpoint as current.
3. Load only unresolved findings and acceptance criteria needed for the next step.
4. Execute and verify the next unverified action, then checkpoint again.

## Host responsibilities and capability limits

The host should reconcile its declared context window with the model service's
actual allocation, reserve output and tool-result headroom, and preserve session
records when supported. Use only capabilities documented for the current host;
this skill specifies no provider APIs, configuration keys, or session commands.

If actual context allocation cannot be detected, use an explicitly documented
operator-supplied fallback appropriate to that deployment. Never confuse a model's
advertised maximum with allocated capacity. Recheck capacity when the model or
runtime configuration changes.

After a context failure, use the host's supported mechanism to create a fresh
session and provide the checkpoint location and original task identity. Preserve
old session records when possible, but do not reopen the oversized transcript as
the default recovery strategy. If the host cannot create a fresh session itself,
ask the operator to do so and provide concise resume instructions.

Where supported, host-side event handling can record interrupted generations and
failed compactions. It cannot record a hard kill before the event fires, force a
model to obey checkpoint instructions, or make replay of arbitrary side effects
safe. Durable pre-action checkpoints and independent read-back remain essential.
