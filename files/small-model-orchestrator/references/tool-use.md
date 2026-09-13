# Tool-Use Protocol

Use this protocol for EVERY tool call, including reads. Read-only calls can be concise, but do not skip semantic validation.

## Preflight

1. State the purpose.
2. State intended postcondition/observation.
3. Confirm the selected tool can produce that observation.
4. Inspect or recall the tool schema accurately.
5. Resolve identifiers/paths/targets unambiguously.
6. Construct arguments.
7. Validate required fields, types, formats, and scopes.
8. Identify side effects.
9. Check active permission rules.
10. Predict the expected response shape or state change.

## Execute

Call the tool exactly as intended. Do not silently alter scope during execution.

## Postflight

1. Inspect the actual tool response.
2. Distinguish transport success from task success.
3. Check errors, warnings, truncation, pagination, partial results, stale data, and ambiguity.
4. Compare actual result to the expected postcondition.
5. For mutations, independently read back or otherwise verify consequential state when feasible.
6. Record evidence and identifiers needed for later steps.
7. If the result is incomplete, continue retrieval rather than reasoning from missing data.

## Common tool-use failures

- wrong target ID;
- wrong account/repository/file;
- omitted pagination;
- assuming `200 OK` means semantic success;
- treating tool output as exhaustive when truncated;
- ignoring warning fields;
- malformed date/time or timezone;
- reusing stale identifiers;
- performing a write before validating the read target;
- believing a mutation without read-back verification.

## Tool chains

For multi-tool workflows, each tool output becomes an explicit input with provenance to the next step. Do not rely on memory alone for critical identifiers.
