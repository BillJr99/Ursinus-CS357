# Coding Reliability Protocol

## Intake

Before editing:
- read repository/project instructions;
- identify language/build system;
- inspect relevant code and tests;
- reproduce the problem when possible;
- record baseline test/build status;
- identify pre-existing failures.

## Implementation

Prefer the smallest change that satisfies the contract while preserving surrounding behavior, unless the architecture itself is the diagnosed cause.

Avoid speculative refactors during a bug fix unless verification shows they are required.

## Test categories

Always distinguish:

1. **Existing tests** — usually the most authoritative local evidence.
2. **New ordinary tests** — tests added to encode the desired behavior.
3. **Adversarial tests** — derived after or independently from implementation to seek counterexamples.
4. **Mutation/counterexample tests** — intentionally alter or challenge behavior to test whether the verifier detects wrong implementations.

User selected both ordinary test creation and adversarial/mutation testing when feasible.

## Verification ladder

Use applicable checks:

- original reproducer;
- syntax/compile;
- targeted existing tests;
- new targeted tests;
- adversarial tests;
- mutation/counterexample tests;
- type checks;
- static analysis/lint already supported by project;
- integration tests;
- full regression suite;
- clean build/package;
- actual runtime behavior.

Do not install unnecessary tools solely to satisfy this list. Opportunistically use project-provided tooling.

## Debugging rule

A fix is not verified until the original failure is shown to fail before the fix when practical, and pass after the fix.

## Test integrity

Do not:
- delete or weaken failing tests without evidence the test is wrong;
- overfit to one example;
- mock away the behavior being verified;
- confuse absence of exceptions with correctness.

## Code review gauntlet

Inspect diff for:
- unintended files;
- dead code;
- TODOs/stubs;
- exception swallowing;
- duplicate logic;
- security regressions;
- API compatibility;
- unhandled edge cases;
- changed semantics not covered by tests.

## Build artifacts

Do not commit generated artifacts unless the project normally tracks them or the user requires them.
