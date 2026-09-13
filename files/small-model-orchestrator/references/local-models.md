# Local / Offline Model Guidance

The primary use case for this skill is local, private, offline AI, including locally served models, but the protocol must remain environment- and model-agnostic.

## Default model policy

Assume one model only.

Do not search for, switch to, or delegate to another model merely because performance is weak.

If the user explicitly says multiple models are available for the task, they may be used freely at any stage, including:
- independent planning;
- alternative implementation proposals;
- test generation;
- cold criticism;
- gauntlet review;
- tie-breaking.

## Why external state matters

Small local models often benefit from explicit reconstruction of task state. Use `.small-model-orchestrator/` as durable working memory so each pass can recover:
- the contract;
- current plan;
- verified facts;
- open failures;
- evidence;
- experiments;
- unresolved gauntlet findings.

## Host compatibility

Use the current host's supported tool-calling or agent loop. Do not require a particular provider, endpoint, launcher, operating system, or model name.

A host may implement the protocol with repeated calls to the same model. A conceptual loop is:

```text
load contract + current state + next plan step
→ model proposes/executes semantic work
→ host/tool obtains observation
→ append evidence
→ reload state
→ next invocation
```

The skill itself does not require an external configuration file or orchestrator.

## Context pressure

When context is limited:
1. preserve `CONTRACT.md`, `STATE.md`, and current `PLAN.md`;
2. summarize old execution detail into evidence records;
3. keep raw logs on disk;
4. reload only relevant references;
5. never compress away unresolved failures or acceptance criteria.
