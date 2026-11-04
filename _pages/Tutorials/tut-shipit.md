---
layout: textbook
permalink: /Tutorials/ShipIt
title: 'CS357: Foundations of Artificial Intelligence - ShipIt: Build, Test, CI, and Publish One Artifact'
info:
  coursenum: CS357
  purpose: "To carry one small artifact from a written specification through AI-assisted building, testing, and CI to responsible publication under your own name."
  eyebrow: "Tutorial"
  numbering: false
tags:
- publishing
- ci
- final-project
---
*To experience the maker's full arc on one small, real, public artifact, carrying it from a written specification through AI-assisted building, testing, and CI to responsible publication under your own name.*

This guide is for Final Project Directions A and C, and it is not separately graded.  Direction B publishes a write-up instead, as the [publish gate]({{ site.baseurl }}/Projects/FinalProject#publish-gate) explains.  The guide walks you through carrying one artifact from a written specification through building with an AI agent, testing, continuous integration (CI, the automated checks that run on every push), and public publication under your own name.  That is the maker's full arc, compressed into one real, public, small artifact.  By the end, something you built will exist in the world, installable or reachable by anyone, with your name on it.  The self-check table at the end of this guide rewards discipline over scope.  A small, finished, well-tested, well-documented artifact demonstrates more than an ambitious one that does not run.  Use the self-check before your project's [publish gate]({{ site.baseurl }}/Projects/FinalProject#publish-gate).  **Choose one track and one artifact**, and observe the standing course rule throughout: agents may prepare every step, but a human (you) runs every publish or deploy command.

## Goals

- To carry one artifact from specification through testing and continuous integration to public publication
- To practice the AI maker discipline in your chosen track, with the agent generating and the human specifying, verifying, and owning
- To publish responsibly to a real registry or hosting platform (GHCR, Docker Hub, npm, or Cloudflare) with the human gate observed
- To document the artifact for strangers with a readme and a disclosed AI contribution statement

## Background Reading and References

- [The AI Maker Activity]({{ site.baseurl }}/Tutorials/AIMaker)
- [Publishing Your Work Activity]({{ site.baseurl }}/Tutorials/Publishing)
- [Hosting with Cloudflare Activity]({{ site.baseurl }}/Tutorials/Cloudflare)

## What Strong Work Looks Like

- **The specification preceded the artifact, with a timestamp to prove it.**  The dated specification file is preserved in its original form, before any agent-generated code touches it.  The self-assessment values the original spec even if it was imperfect.  Discovering and documenting a spec gap is part of the discipline, not a failure.
- **CI is wired to something real, not to a placeholder.**  The GitHub Actions workflow runs the project's actual tests (or actual accessibility/content checks for Track B), not `echo "tests pass"`.  The evidence portfolio includes links or screenshots of one red run and one green run.  The red run proves the CI was not trivially passing before the code worked.
- **A classmate confirmed it works cold.**  The "stranger test" is documented: a classmate's GitHub username or name, what they installed or visited, and their one-line confirmation that it worked from the public record alone.  This is not optional.  It is what "published" means.
- **The AI contribution statement is honest and specific.**  A weak statement says "I used AI to help build this."  A strong statement says: "The agent generated the initial `handler.js` function and all three test files.  I wrote the `config.json` schema and the README, and I rewrote the error handling in lines 44-62 of `handler.js` after the agent's version silently swallowed exceptions.  I verified every test manually before pushing."

Weak work has CI that passes immediately with no red run, a readme that only an author could follow, and an AI contribution statement that could apply to any project.

## Choose Your Track and Artifact

| Track | What you build | What you need | Pick this if |
|---|---|---|---|
| **Track A (software engineering)** | One of: a container image published to GHCR (a small useful service such as a rubric-checking API or a markdown linter for course conventions); a scoped npm package with a working `bin` (a CLI utility you actually want to exist); or a Cloudflare Worker API (the gateway-facade pattern is a strong choice) | A GitHub account, plus GHCR or Docker Hub (container option) or an npm account (package option) | You have a software engineering background.  Your specification instrument is a **failing test suite written before implementation**; the agent's job is to make the tests pass without modifying them |
| **Track B (maker)** | One of: a static site deployed to Cloudflare Pages (a project page, a resource hub, or an interactive explainer built with an agent); or a simple Cloudflare Worker built entirely through agent collaboration (a JSON API for something you care about) | A GitHub account and a Cloudflare free-tier account.  You use guided DevOps tooling (GitHub Actions and Cloudflare's wrangler), following step-by-step instructions | No programming background is assumed.  Your specification instruments are an **acceptance checklist written before generation** and the five-questions instruction to your agent (what it should do, what it must not do, who will use it, what counts as working, and what the edge cases are) |

The self-check is the same on both tracks.  Artifacts must be original, must not include course-restricted materials or anyone's personal data, and must carry a license.  If your idea touches credentials, payments, or other people's private information, redesign or consult the instructor first.  Recognizing that boundary is part of the assignment.

## Stage 1: Specify (before building)

Write and date your specification before generation begins.  The timestamp is part of the discipline.  Commit it to the repository (or post it where your project lives) before any agent-generated code exists.

> **Do this.**
> 1. **Track A:** write your failing test suite.  Cover the happy path, at least one edge case (empty input, malformed input), and at least one deliberate misuse case (input designed to trigger an error or unexpected behavior).  Include a `spec.md` describing what the artifact should do in plain English, one paragraph per major feature.
> 2. **Track B:** write your acceptance checklist.  Each item is a falsifiable statement: "The page loads in under 3 seconds on a standard wifi connection," not "The page is fast."  Also write a one-paragraph persona (who uses this, on what device, under what pressure) and explicit expected behavior for at least one misuse case (what happens when someone submits an empty form, clicks an unexpected button, or uses the artifact in an unintended way).
> 3. **Both tracks:** state in your specification what "done" means: the specific condition under which you would consider this artifact ready to publish.  You will compare your shipped artifact against this standard in the writeup.

## Stage 2: Build and Verify

Work with your agent against the specification.

> **Do this.**
> 1. **Track A:** instruct your agent: "Make these tests pass without modifying the test files."  Keep the conversation log or session notes.  When the agent generates code, read it before running it.  Verify every test passes.  Run your misuse case.  If you modify any agent-generated code, note what you changed and why.
> 2. **Track B:** iterate against your checklist.  For each failed checklist item, file a bug report in the agent conversation in what-I-did / what-I-expected / what-happened form.  When all items pass, conduct the **silent stranger test**: give a classmate the public URL and nothing else.  Watch (or ask them to document) what they do, where they get confused, and whether they complete the primary task without help.  Log their experience.
> 3. **Both tracks:** document one specification gap you discovered during building: a criterion you forgot to specify, a behavior you assumed but did not state, or a constraint you discovered mid-build.  Show the original spec, the gap, and how you repaired the spec (not just the artifact).

## Stage 3: Continuous Integration

Add the automated check appropriate to your artifact.

> **Do this.**
> 1. **Track A:** add a GitHub Actions workflow (`.github/workflows/ci.yml`) that installs dependencies, runs your test suite, and reports pass/fail on every push to `main` and every pull request.
> 2. **Track B:** add a preview-deployment-plus-checklist pipeline, or an Actions-driven build check that verifies the site builds without errors and key content is present.
> 3. **Both tracks:** demonstrate one **red run**, a commit that intentionally fails at least one check, and one **green run**, the commit that makes all checks pass.  Include the link or screenshot of each.
> 4. **Both tracks:** arrange the pipeline so that publication to the public registry requires CI green **plus** a deliberate human act (pushing a tag, merging to a release branch, or running a manual publish step).  In your writeup, state in exactly one sentence where the human gate lives.

## Stage 4: Publish

Before publishing, conduct the pre-publication audit.  Publication is irreversible, so this audit is the last point at which you can confirm that no secret, credential, or private file leaves your machine inside the artifact.

> **Do this.**
> 1. Audit the package before it leaves your machine, and save the output in your evidence portfolio:
>    - **npm:** run `npm pack --dry-run` and review the file listing.  Verify no secrets, no test fixtures, no node_modules are included.
>    - **Container image:** run `docker image inspect <image>` and review the layer listing.  Verify no credentials or private data are in any layer.
>    - **Cloudflare:** review the deploy directory listing before `wrangler deploy`.  Verify no `.env` files or private keys are staged.
> 2. Publish, running the command yourself:
>    - `npm publish --access public` (npm)
>    - `docker push` and set visibility to public (GHCR)
>    - `wrangler deploy` or `wrangler pages deploy` (Cloudflare)
> 3. Version it.  Start at `0.1.0`.  Ship at least one subsequent patch release (`0.1.1`) so the version walk is demonstrated.  Use semantic versioning: patch for bug fixes, minor for new features.
> 4. Get the stranger confirmation.  A classmate must install or visit your artifact from the public record alone: no setup instructions from you, no personal help.  They should use only your README.  Their one-line confirmation ("I ran `npm install -g your-package` and `your-package --help` worked, [GitHub username]") goes in your evidence portfolio.

## Evidence Portfolio

Assemble the following evidence.  This is what you will check against the self-assessment checklist before your project's publish gate:

1.  The dated specification (original form, before generation)
2.  The build transcript or session log (conversation with the agent, or commit history)
3.  Verification evidence for every specification criterion, including the misuse case
4.  For Track B: the stranger-test log (what your classmate did, where they got confused, what you changed as a result)
5.  The CI workflow file and links or screenshots of one red run and one green run
6.  The pre-publication audit artifact (the dry-run output, layer listing, or deploy directory review)
7.  The public URL or registry name with install instructions
8.  The classmate confirmation (one line, with their name or username)
9.  A README suitable for strangers (what, install, use; answerable in 30 seconds)
10.  An **AI contribution statement** honestly delineating what the agent produced, what you wrote or changed, and what you verified
11.  A **portfolio entry**: the repository pinned or linked from your GitHub profile or portfolio page with your 200-word project story, **plus a drafted LinkedIn-style post** (150-250 words: the problem, what you built, one concrete number, and what you learned).  Submitting the draft is required; **publishing it is always optional and never graded: your professional profiles are yours.**  The draft exists so that if you choose to post it, the post is already written while the evidence is fresh

Ensure reproducibility by pinning dependency versions and listing software version information (Node version, npm version, Docker version, or Wrangler version as applicable).

## Your Portfolio Entry and GitHub Profile

Publication is only half of existing in the world.  The other half is being findable.  Once the artifact is live:

- **Pin the repository** on your GitHub profile.  If you do not have a profile README, create one now.  It is a ten-minute job with an outsized payoff, and this artifact is its first entry.
- **Write a project story of roughly 200 words**: the problem, what you built (and what the agent built, honestly delineated; your AI contribution statement is most of this already), and the evidence: the registry link, the CI badge, the classmate's stranger confirmation.  Name what *you* did explicitly, because that is the sentence a resume bullet and an interview answer are made from.
- **Reuse the story.**  The same story is your opening move with guests at Demo Day (see the [Demo Day Guide]({{ site.baseurl }}/Tutorials/DemoDay)) and the public, recruiter-legible trace the Final Project's Product rubric asks for.  Update your resume and LinkedIn while the numbers are fresh.
- **Draft the post.**  Turn the story into a **drafted LinkedIn-style post** (150-250 words: problem, what you built, one number, what you learned) and include the draft in your submission.  Publishing is always optional and never graded.  The draft means that if you want the post, it is already written at the moment the project is most impressive to describe.

## Frequently Asked Questions

**Q: My CI keeps failing because of a flaky network call in my tests.  What should I do?**
A: Mock the network call in tests.  The specification discipline the course teaches requires tests that are deterministic.  If a test depends on an external service, mock it in the test suite and test against the real service only in a separate integration step that is clearly labeled as potentially flaky.  Document the decision in your writeup.

**Q: What counts as a "deliberate misuse case"?**
A: An input or user action that is wrong, adversarial, or outside the happy path.  Examples: an empty input field, an input that is 10,000 characters long, a file of the wrong type, a sequence of requests that tries to exhaust a rate limit.  The requirement is that your specification named the case and your testing shows what the artifact does when it happens.

**Q: Do I really need to publish to a public registry?  Can I just push to a private GitHub repo?**
A: No.  The "stranger confirmation" criterion requires a classmate to install or visit from the public record alone, which means the artifact must be publicly accessible.  A private repository does not satisfy this requirement.

**Q: Can my classmate "confirm it works" by email instead of in the evidence portfolio?**
A: Include the confirmation in your evidence portfolio, not only in email.  Quote their exact words and identify them by name or GitHub username.  The confirmation should describe what they did, not only say "it worked."

**Q: My Track B artifact is a static site.  Do I still need to demonstrate CI?**
A: Yes.  Even a static site can have automated checks: a build step that verifies the HTML is valid, a link checker, a content check that confirms key pages exist.  The CI requirement applies to both tracks.  Cloudflare Pages has built-in GitHub Actions integration that makes this straightforward.

## ShipIt Reflection Prompts

Answer these as part of your self-assessment before your project's publish gate:

- Where in this project did the agent's output most need you, and what would have shipped if you had not been paying attention there?
- Publication is effectively irreversible.  Describe the moment you ran the publish command: what had to be true for you to feel entitled to run it, and is that standard now portable to bigger things?

## ShipIt Self-Check

| Criterion | Pre-Emerging | Beginning | Progressing | Proficient |
|---|---|---|---|---|
| Self-Check: Specification and Verification Discipline | I let the agent generate code before I wrote any specification, and I have no systematic verification; I should revisit Stage 1 before applying this guide to my Final Project | I have a specification, but it is vague and my verification covers only the happy path | I wrote a concrete specification (failing tests in Track A; an acceptance checklist with a stranger test in Track B) before generation began, and I can point to verification evidence for most criteria | My specification preceded generation and is preserved in its original form, every criterion has verification evidence, at least one deliberate misuse case is covered, and I documented one specification gap I discovered mid-project along with how I repaired it |
| Self-Check: Continuous Integration | I have no automated checking; my project cannot pass the Final Project's publish gate yet | I have a CI workflow, but it does not run my project's real checks | My CI runs the real checks on every push, and I can show one demonstrated red run and one demonstrated green run | My CI runs the real checks on every push with demonstrated red and green runs, publication is gated on green plus a deliberate human act (a tag or merge) that I perform myself, and I can state in one sentence exactly where the human gate lives in my pipeline |
| Self-Check: Publication Quality | I have not published anything, or my publication is broken for strangers | My artifact is published, but a stranger cannot use it from the public record alone | My artifact is published, installable or reachable by a stranger, with versioning and a readme, though a minor gap remains such as a missing license or visibility friction | My artifact is published with semantic versioning, a license, and a readme answering what, install, and use in thirty seconds; I documented a pre-publication audit (dry run output or layer listing reviewed); a classmate verified a stranger installation or visit; and the artifact is pinned or linked from my GitHub profile or personal portfolio page with a short project story |
| Self-Check: Writeup, AI Disclosure, and Evidence Portfolio | My evidence portfolio is incomplete | My evidence portfolio exists, but the AI contribution statement or human-centric design evidence is missing | My evidence portfolio is complete with an AI contribution statement and design evidence, and I gave at least superficial responses to the reflection prompts | My evidence portfolio is complete, my AI contribution statement honestly delineates agent work from my own work, my human-centric design evidence covers the persona and at least one failure path, and I answered the reflection prompts thoughtfully |
