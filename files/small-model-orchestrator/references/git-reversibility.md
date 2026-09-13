# Git Versioning and Reversibility

Git is the primary recovery mechanism for task work. Commit verified steps as you go
so any state can be inspected, compared, and restored after a failure, a bad edit,
a lost context, or a crashed session.

## Permission defaults

- Local commits on a dedicated task branch or worktree are expected by this skill
  unless the user or project instructions prohibit commits.
- Never push, merge, rebase, force-update, delete branches, or rewrite history
  without explicit user permission.
- Never commit to the user's current branch without permission; use a task branch.
- Never run destructive reset/checkout/clean against changes this task did not make.

## Setup (once per task)

1. Inspect: repository root, current branch, HEAD, `git status --short`.
   `scripts/git_checkpoint.py --inspect` prints these.
2. If the project directory is not a repository and it is the task's own working
   directory, initialize one (`git init`) and make a baseline commit of the existing
   files. If it is a broad directory such as a home folder, ask first.
3. If there are pre-existing uncommitted changes, save a patch snapshot
   (`--snapshot`) and ask the user how to proceed before branching or committing.
   Do not sweep unexplained user changes into task commits.
4. Isolate the work:
   - preferred: `git worktree add <path> -b smo/<task-id>` when a separate directory
     is practical and permitted;
   - otherwise: `git switch -c smo/<task-id>` from a clean tree.
   `scripts/git_checkpoint.py --start <task-id>` performs the branch variant safely.
5. Add `.small-model-orchestrator/` to `.git/info/exclude` (local, never committed).
   Task state must not be versioned with the code: checking out an old commit must
   not roll RESUME.md back to a stale checkpoint.
6. Record the base commit and task branch in RESUME.md.

## Commit cadence

- Commit after each verified action or subtask. The commit is the proof of a known
  good state; RESUME.md records its hash.
- Before a risky or wide change, make sure the last good state is committed.
- Work that is written but not yet verified may be committed as `WIP` when it is
  large or hard to recreate, but mark it clearly and never cite it as verified.
- Message form: `task:<id> <milestone/action> <VERIFIED|WIP>: <short summary>`.
- Review what will be committed. Check `git status` before the first commit for large
  files, secrets, and generated artifacts; respect the project's `.gitignore`.
- `scripts/git_checkpoint.py --commit "<message>"` stages, commits, handles
  "nothing to commit", and supplies a local fallback identity when none is set.

## Recovery with Git

- What changed since the last good state: `git diff` (uncommitted) and
  `git diff <last-verified>..HEAD`.
- In-flight edit uncertain after a crash: inspect `git diff`; keep, finish, or
  restore the affected files (`git restore <path>`) based on evidence.
- Bad experiment on the task branch: `git revert <commit>` or, for uncommitted work,
  `git restore <paths>`. Only discard content this task introduced.
- Accidental deletion or overwrite: restore from the last commit
  (`git restore --source=<commit> <path>`).
- Lost track of progress: `git log --oneline` on the task branch is a reliable
  history, together with RESUME.md.

## When Git is unavailable

Use copied snapshots or patch files under `.small-model-orchestrator/snapshots/`
before consequential changes, record them in RESUME.md, and disclose the weaker
recovery guarantee.

## Final Git ledger

Report: base commit and branch, isolation method, task branch, final commit, whether
anything remains uncommitted, untouched pre-existing changes, and that nothing was
pushed or merged unless the user asked.
