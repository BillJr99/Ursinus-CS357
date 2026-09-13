# Verification and Evidence

## Core rule

A task is complete only when the evidence supports the task contract.

## Evidence hierarchy

Prefer, roughly in this order:

1. direct observation of the requested external state;
2. existing authoritative acceptance/regression tests;
3. independent oracle or external specification;
4. targeted reproducer exercising the original failure;
5. independent/cold critic inspection;
6. agent-created tests;
7. static inspection;
8. model assertion.

Lower-ranked evidence can be useful but should not silently replace stronger available evidence.

## Independence

Evidence is stronger when its failure mode differs from the artifact under test.

Examples:
- implementation + existing test suite: stronger;
- implementation + tests authored from the same mistaken interpretation: correlated;
- implementation + independently derived adversarial tests: stronger;
- tool says "success": weaker than reading back the changed state.

## Verification ledger

For each acceptance criterion record:

- criterion;
- verifier;
- evidence location;
- observed result;
- status: PASS / FAIL / PARTIAL / BLOCKED;
- independence note;
- limitations.

## Negative testing

Ask not only "does it work?" but also:
- where should it fail?
- can malformed input break it?
- can missing state produce a false success?
- can stale caches or mocks fool the verifier?
- can a partial write masquerade as completion?

## Final acceptance

Before declaring success:
1. re-read the contract from scratch;
2. map every criterion to evidence;
3. inspect unresolved failures;
4. inspect unresolved gauntlet findings;
5. verify that all changed artifacts are the intended artifacts;
6. run the strongest practical final checks;
7. state limitations explicitly.

No critical criterion may be silently omitted.
