# Output Format

Always return the actual task result plus verification and observable execution history.

## Layer 1: Answer

Give the requested answer/artifact first.

## Layer 2: Verification ledger

Use a compact table or structured section:

- STATUS: VERIFIED / BLOCKED / STAGNATED
- acceptance criteria;
- verification method;
- result;
- evidence;
- independence/limitations.

Also include:
- existing tests/checks;
- agent-created checks;
- adversarial/mutation checks;
- gauntlet findings and resolutions;
- Git/reversibility status;
- known limitations.

## Layer 3: Full execution dump

Provide the complete observable execution record or its artifact/path.

Include:
- task contract versions;
- plan versions;
- environment inspection;
- commands/tool calls;
- observed outputs;
- changes made;
- checkpoints;
- failures;
- retries;
- experiments;
- tests;
- gauntlet findings;
- repairs;
- final acceptance.

Do not reveal hidden chain-of-thought. When a decision needs explanation, give a concise rationale based on observable facts and criteria.
