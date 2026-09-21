"""persona_pipeline.py: a multi-step prompt chain with one persona per step.

Each step is one call to the model.  A step carries its own persona (its system
prompt), its own temperature, an optional skill whose body is pasted into that
system prompt, and an explicit list of the earlier outputs it is allowed to read.
Steps run in order, and each writes its output into a shared context that later
steps may or may not see.

There is no agent framework here, and that is the point.  The whole orchestration
is the for-loop in run_pipeline().  An "agent system" at this scale is a list of
personas, a list of temperatures, and a rule about who sees what.

Design decisions this file implements, each argued in class before it was coded:

  * Role before rules.  build_system() puts the persona sentence first and the
    skill's numbered rules after it, because models anchor on early text.
  * A skill body pasted into a system prompt is not a skill firing on a
    description match.  It is present on the step that names it and absent
    everywhere else, which is Route 3 from the skills activity.
  * The attacker is isolated.  build_user() assembles a step's message from
    only the keys in its "sees" list, so the red-team step reads the candidate
    and nothing else: not the brief, not the design decisions, not the
    interview.  An attacker who knows what the designer intended aims politely
    at what the designer expected, and a real user has none of that.  The
    isolation is enforced by this code, not requested of the model.
  * Per-step temperatures.  An interviewer may wander, an author less so, and
    an attacker should wander most of all, because three attacks that resemble
    each other test one thing three times.

Config (endpoint, model, seed, and every step) lives in config.json.
The client is ollama_client.py from the sampling session.
"""

import json
import logging
import os
import re
import sys
import traceback

from ollama_client import chat, load_config

log = logging.getLogger("cs357.pipeline")

# The six checks below are the six principles for effective system prompts,
# applied by code rather than by a model.  This is not a golden set: it is six
# string assertions on one artifact, and it exists to contrast what code can
# decide with what the red team merely claims.
HEDGES = ("unsure", "uncertain", "not certain", "do not know", "don't know")
REFUSALS = ("do not", "don't", "never", "refuse", "decline", "will not")
ESCALATIONS = ("escalate", "professor", "instructor", "a human")


def strip_front_matter(text):
    """Return a SKILL.md body with its YAML front matter removed.

    A SKILL.md opens with a '---' line, carries YAML until the next '---', and
    everything after that is the instruction text the model reads.  Only the
    body is pasted into a system prompt; the front matter is metadata for the
    harness that would normally decide whether to load the skill at all.
    """
    try:
        lines = text.splitlines()
        if not lines or lines[0].strip() != "---":
            return text.strip()
        for i in range(1, len(lines)):
            if lines[i].strip() == "---":
                return "\n".join(lines[i + 1:]).strip()
        return text.strip()
    except Exception as e:
        print(f"[persona_pipeline:strip_front_matter] {e}")
        traceback.print_exc()
        raise


def load_skill(cfg, name):
    """Read one skill body from <skills_dir>/<name>/SKILL.md, or return "".

    The directory name must match the skill's name field.  In opencode a
    mismatch means the skill silently never loads, which is the failure that is
    hardest to diagnose.  Here the mismatch raises, because a pipeline that
    quietly drops its rules produces output that looks fine and is not.
    """
    if not name:
        return ""
    path = os.path.join(cfg.get("skills_dir", ".agents/skills"), name, "SKILL.md")
    try:
        with open(path, encoding="utf-8") as f:
            body = strip_front_matter(f.read())
        log.info("loaded skill %r from %s (%d chars)", name, path, len(body))
        return body
    except FileNotFoundError as e:
        print(f"[persona_pipeline:load_skill] no SKILL.md for {name!r} at {path}")
        print(f"[persona_pipeline:load_skill] create it, or set this step's "
              f"\"skill\" to null in config.json to run without it")
        print(f"[persona_pipeline:load_skill] {e}")
        traceback.print_exc()
        raise
    except Exception as e:
        print(f"[persona_pipeline:load_skill] {e}")
        traceback.print_exc()
        raise


def build_system(step, skill_body):
    """Compose one step's system prompt: the persona first, then the skill body.

    Role before rules.  The identity sentence anchors the step, and the skill's
    numbered rules follow it.  When skill_body is empty this returns the persona
    alone, which is the "without" condition for any comparison run.
    """
    try:
        parts = [step["persona"]]
        if skill_body:
            parts.append("Follow these rules exactly:\n\n" + skill_body)
        return "\n\n".join(parts)
    except Exception as e:
        print(f"[persona_pipeline:build_system] step {step.get('name')!r}: {e}")
        traceback.print_exc()
        raise


def build_user(step, context):
    """Assemble this step's user message from only the keys it may see.

    The "sees" list is the isolation mechanism.  A key absent from the list is
    absent from the message, whatever the model would like to have.  This is why
    the red-team step cannot read the design decisions: not because it was asked
    not to, but because the text never reaches it.
    """
    try:
        blocks = []
        for key in step.get("sees", []):
            value = context.get(key)
            if not value:
                log.debug("step %s: nothing yet under %r", step["name"], key)
                continue
            blocks.append(f"### {key.upper()}\n{value}")
        blocks.append(f"### YOUR TASK\n{step['instruction']}")
        return "\n\n".join(blocks)
    except Exception as e:
        print(f"[persona_pipeline:build_user] step {step.get('name')!r}: {e}")
        traceback.print_exc()
        raise


def run_step(cfg, step, context):
    """Run one step. Returns (text, trace_row).

    Every dial that varies between steps is read from the step, and every dial
    that must not vary (the seed) is read from the top-level config, so a run is
    repeatable and the only differences between steps are the intended ones.
    """
    try:
        skill_body = load_skill(cfg, step.get("skill"))
        system = build_system(step, skill_body)
        user = build_user(step, context)
        options = {"temperature": step.get("temperature", 0.0),
                   "seed": cfg.get("seed", 42)}
        log.debug("step %s system=%d chars user=%d chars",
                  step["name"], len(system), len(user))
        text, data = chat(cfg, user, system=system, **options)
        row = {"name": step["name"],
               "temperature": options["temperature"],
               "skill": step.get("skill") or "none",
               "sees": ",".join(step.get("sees", [])) or "nothing",
               "chars": len(text),
               "tokens": (data or {}).get("eval_count", 0)}
        return text, row
    except Exception as e:
        print(f"[persona_pipeline:run_step] step {step.get('name')!r}: {e}")
        traceback.print_exc()
        raise


def describe_plan(cfg):
    """Print the pipeline's shape before it runs, so predictions come first.

    Controls above the table: this is what you are about to run, and the results
    table below it is what happened.
    """
    try:
        print("\nPIPELINE (predict each step's behavior before running)")
        for i, step in enumerate(cfg["steps"], 1):
            print(f"  {i}. {step['name']:<12} T={step.get('temperature', 0.0):<4} "
                  f"skill={step.get('skill') or 'none':<20} "
                  f"sees={','.join(step.get('sees', [])) or 'nothing'}")
    except Exception as e:
        print(f"[persona_pipeline:describe_plan] {e}")
        traceback.print_exc()
        raise


def run_pipeline(cfg, task, seed_context=None):
    """Run every configured step in order, threading outputs through context.

    seed_context holds anything supplied before the run, such as the human
    answers to the interview step's questions.  A step still sees it only if
    the key appears in that step's "sees" list.
    """
    context = {"task": task}
    context.update(seed_context or {})
    trace = []
    try:
        for step in cfg["steps"]:
            print(f"\n===== step: {step['name']} "
                  f"(T={step.get('temperature', 0.0)}, "
                  f"skill={step.get('skill') or 'none'}) =====")
            text, row = run_step(cfg, step, context)
            print(text)
            context[step["writes"]] = text
            trace.append(row)
        return context, trace
    except Exception as e:
        print(f"[persona_pipeline:run_pipeline] {e}")
        traceback.print_exc()
        raise


def render_trace(trace):
    """Print the run as a bordered table, one row per step."""
    try:
        headers = ("step", "T", "skill", "sees", "chars", "tokens")
        widths = (12, 5, 20, 26, 6, 6)
        bar = "+" + "+".join("-" * (w + 2) for w in widths) + "+"
        print("\n" + bar)
        print("| " + " | ".join(f"{h:<{w}}" for h, w in zip(headers, widths)) + " |")
        print(bar)
        for r in trace:
            cells = (r["name"], str(r["temperature"]), r["skill"],
                     r["sees"], str(r["chars"]), str(r["tokens"]))
            print("| " + " | ".join(f"{c[:w]:<{w}}" for c, w in zip(cells, widths)) + " |")
        print(bar)
    except Exception as e:
        print(f"[persona_pipeline:render_trace] {e}")
        traceback.print_exc()
        raise


def verify(prompt):
    """Apply the six system-prompt principles in code. Returns [(label, bool)].

    Each check corresponds to one principle from the persona section, in order.
    The red team reports in prose on whether the prompt holds up.  This function
    decides six specific things about it.  Where the two disagree, the
    disagreement is the lesson: an instruction shapes a distribution and a check
    decides a fact.
    """
    try:
        text = prompt.strip()
        low = text.lower()
        first = (text.splitlines() or [""])[0]
        return [
            ("1 role named in line 1",
             bool(re.search(r"\byou are\b", first, re.I))
             and bool(re.search(r"\b[A-Z][a-z]{2,}\b", first))),
            ("2 states a refusal",
             any(w in low for w in REFUSALS)),
            ("3 constrains the format",
             bool(re.search(r"\b\d+\s*(words|sentences|bullets?)\b", low))),
            ("4 handles uncertainty",
             any(w in low for w in HEDGES)),
            ("5 names an escalation path",
             any(w in low for w in ESCALATIONS)),
            ("6 carries a version stamp",
             bool(re.search(r"\bv\d+\.\d+\b", low))
             and bool(re.search(r"\b20\d{2}-\d{2}-\d{2}\b", text))),
        ]
    except Exception as e:
        print(f"[persona_pipeline:verify] {e}")
        traceback.print_exc()
        raise


def render_verdict(checks):
    """Print the code's verdict as a bordered table beside the red team's prose."""
    try:
        bar = "+" + "-" * 32 + "+" + "-" * 8 + "+"
        print("\n" + bar)
        print(f"| {'check':<30} | {'result':<6} |")
        print(bar)
        for label, ok in checks:
            print(f"| {label:<30} | {'PASS' if ok else 'FAIL':<6} |")
        print(bar)
        print(f"  {sum(ok for _, ok in checks)}/{len(checks)} decided by code, "
              f"not by a model")
    except Exception as e:
        print(f"[persona_pipeline:render_verdict] {e}")
        traceback.print_exc()
        raise


if __name__ == "__main__":
    try:
        cfg = load_config(sys.argv[1] if len(sys.argv) > 1 else "config.json")
        with open(cfg["task_file"], encoding="utf-8") as f:
            task = f.read()
        # Human decisions and any other pre-supplied context are files, not
        # arguments, so a rerun with one line changed is a file edit.
        seed_context = {}
        for key, path in (cfg.get("context_files") or {}).items():
            with open(path, encoding="utf-8") as f:
                seed_context[key] = f.read()
        describe_plan(cfg)
        context, trace = run_pipeline(cfg, task, seed_context)
        render_trace(trace)
        final_key = cfg["steps"][-1]["writes"]
        print("\n===== final artifact =====")
        print(context[final_key])
        render_verdict(verify(context[final_key]))
    except Exception as e:
        print(f"[persona_pipeline:__main__] {e}")
        traceback.print_exc()
        sys.exit(1)
