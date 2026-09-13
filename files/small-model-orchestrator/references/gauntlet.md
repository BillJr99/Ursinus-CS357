# Adversarial Gauntlet

The gauntlet is not a request for generic criticism. It is an attempt to falsify completion.

## Critic isolation

Prefer a fresh context. Provide:
- task contract;
- current artifact or diff;
- evidence ledger;
- test results;
- relevant specifications.

Do not provide persuasive builder rationale unless required for understanding.

By default use the same model. If and only if the user explicitly says multiple models are available, use them freely where useful.

## Nine required attack surfaces

### 1. Requirements omissions
Find contract items with no implemented behavior or evidence.

### 2. Functional correctness
Search for wrong outputs, broken control flow, invalid assumptions, and mismatches with specifications.

### 3. Edge cases/adversarial inputs
Construct boundary, malformed, empty, extreme, concurrent, repeated, and unexpected cases appropriate to the domain.

### 4. Tool misuse/unverified side effects
Check argument schemas, target identity, partial writes, stale reads, and whether claimed mutations actually occurred.

### 5. Regression risk
Inspect adjacent behavior, compatibility, API contracts, and existing tests.

### 6. Security/unsafe assumptions
Look for injection, path handling, secrets exposure, unsafe deserialization, command construction, authorization mistakes, and domain-specific hazards.

### 7. Fake completeness
Search for:
- TODO/FIXME;
- stubs;
- placeholders;
- mocked behavior in production paths;
- skipped/disabled tests;
- swallowed errors;
- unexecuted migrations/build steps;
- fabricated results;
- comments claiming behavior not present in code;
- partial implementations presented as complete.

### 8. Simplicity/unnecessary complexity
Find speculative abstraction, duplicated logic, needless dependencies, or fragile orchestration.

### 9. Evidence quality
For every major claim ask: "What actually proves this?"

## Finding record

Each finding should include:
- ID;
- severity;
- attack surface;
- claim;
- evidence;
- reproduction;
- required repair;
- resolution status.

Blocking findings return to execution. Re-run the relevant gauntlet sections after repair.
