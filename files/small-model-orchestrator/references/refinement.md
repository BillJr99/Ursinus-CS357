# Measured Refinement Loop

This is a generalized propose-change-measure-keep/revert loop.

## Protocol

1. Freeze a verified baseline.
2. State one improvement hypothesis.
3. Predict what metric/evidence should improve.
4. Make the smallest change that tests the hypothesis.
5. Run the evaluator without weakening it.
6. Compare to baseline.
7. Keep, revert, or revise.
8. Record the experiment.
9. Repeat while there is a credible improvement direction.

## Decision hierarchy

Preferred:
1. hard gates;
2. lexicographic quality vector;
3. weighted score;
4. single metric.

Example lexicographic vector:

```text
(
  critical_contract_failures ↓,
  failed_authoritative_tests ↓,
  security_findings ↓,
  unresolved_gauntlet_findings ↓,
  functional_score ↑,
  robustness_score ↑,
  maintainability ↑,
  accidental_complexity ↓
)
```

A lower-priority gain must not compensate for a newly failing hard gate.

## Evaluator integrity

Do not modify the benchmark, expected outputs, test thresholds, or acceptance criteria merely to make a change pass unless the evaluator itself is demonstrably wrong. If the evaluator is wrong, treat that as a separate diagnosed defect and preserve evidence.

## Reversion

If a change regresses the quality vector, revert it cleanly or restore the prior checkpoint. Do not leave failed experimental residue in the final artifact.
