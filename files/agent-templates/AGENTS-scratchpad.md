# Scratchpad rules for agents

<!-- The shared-scratchpad contract.  Lives at the ROOT of a disposable repository
     that two or more agents hand work through, the pattern the "How I AI" and
     "Agents That Talk" sessions build.  Its job is to make concurrent writes by
     agents that never share a context window safe by convention: one writer per
     directory, new files rather than edited ones, and a credential rule that fails
     loudly instead of improvising. -->

This repository is a shared, disposable scratchpad for handing work between agents.

**Before anything else, run `gh auth status`.**  Use `gh` for repository-level work:
creating, cloning, issues, pull requests, reviews.  Use `git` for the verbs below,
which `gh` does not have.  If `gh` is missing or not signed in, carry on with `git`
alone and say so in your next message.  If `git` cannot authenticate either, stop and
tell the user to install and authenticate `gh`, or to set up git authentication.  Do
not switch the remote between HTTPS and SSH, do not ask for a token to put in a file,
and do not retry in a loop.

1. Before reading or writing, run `git pull --rebase`.
2. Write only inside `agents/<your-agent-name>/`. Never edit another agent's folder.
3. To hand something to another agent, create a NEW file in `shared/` named
   `YYYY-MM-DDTHHMM_<from>_to_<to>.md`. Do not edit existing shared files.
4. Commit small and often, with messages of the form `<agent>: <what>`.
5. Push immediately after committing. If the push is rejected, `git pull --rebase`,
   then push again. Never force-push. If the push asks for a password, that is the
   authentication failure above: stop and report it.
6. Never store credentials, API keys, student data, or anything FERPA- or
   IRB-covered here.

## Why the rules are shaped this way

Rules 2 and 3 are the whole concurrency story.  One writer per directory means two
agents cannot collide on a file, and creating a new file rather than editing an
existing one means a handoff cannot overwrite a handoff.  Neither rule needs a lock,
which is the point: the convention does the work a lock would do, and it keeps
working when one of the agents crashes halfway through.

Rule 6 is not boilerplate.  A scratchpad is the easiest place in a workflow to leak
something, because it is disposable and therefore treated casually, and because
agents write to it without a person reading every line first.
