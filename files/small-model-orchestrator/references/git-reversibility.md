# Git Reversibility

Use Git as a safety and experimental-control mechanism when a repository is available.

## Preferred strategy

### 1. Dedicated worktree
Preferred when feasible and permitted. It isolates experiments from the user's working tree.

Before creating:
- inspect repository root;
- inspect current branch;
- inspect status;
- identify pre-existing changes;
- choose a non-conflicting path and branch.

### 2. Dedicated branch
Fallback when a worktree is not feasible.

### 3. Snapshot/diff fallback
Always possible when Git can inspect the repository, even if branch/commit operations are unavailable.

Capture:
- `git status --short`;
- current HEAD;
- branch name;
- `git diff`;
- `git diff --staged`;
- untracked-file inventory.

## Checkpoints

Checkpoint methods may include commits, branches, worktrees, patches, or copied snapshots, subject to host/user permissions.

Do not assume commit permission. Do not assume commit prohibition either. Follow the active environment/user policy.

`scripts/git_checkpoint.py` supports:
- inspection;
- patch snapshot;
- optional local checkpoint commit when explicitly invoked and permitted.

## Protecting pre-existing work

Never use destructive reset/checkout/clean operations against unexplained user changes.

Before reverting an experiment, prove that the reverted content was introduced by this task or restore from an isolated worktree/checkpoint.

## Final Git ledger

Report:
- initial HEAD/branch;
- initial dirty state;
- isolation method;
- checkpoint identifiers;
- final status;
- whether changes are committed/uncommitted;
- any untouched pre-existing changes.
