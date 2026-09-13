# Data Analysis Reliability Protocol

## Intake

Establish:
- data provenance;
- schema;
- units;
- time range;
- missingness;
- duplicates;
- encoding;
- row counts;
- filters;
- target population;
- analysis question.

## Baseline checks

Before modeling or aggregation:
- preserve original data;
- compute basic counts;
- inspect ranges;
- check nulls;
- check duplicates;
- validate joins;
- validate units/timezones;
- confirm sign conventions.

## Analysis verification

For every transformation record:
- input size;
- operation;
- output size;
- invariants;
- dropped rows;
- assumptions.

For statistics:
- distinguish descriptive computation, estimator, uncertainty, prediction, and probability estimation;
- verify formulas against known cases;
- use independent recomputation for critical metrics when feasible.

## Gauntlet

Seek:
- leakage;
- selection bias;
- denominator mistakes;
- double counting;
- join explosions;
- Simpson's paradox;
- inappropriate aggregation;
- unit conversion errors;
- time-window mismatch;
- train/test contamination;
- misleading visualization scales.

Never report a polished number without provenance.
