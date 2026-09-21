# Persona Pipeline starter

A four-step prompt chain in which one model is called four times, with a different
persona, a different temperature, and a different view of the work at each step.
The tutorial that explains every decision in it is *The Persona Pipeline: One
Model, Four Personas, and a Rule About Who Sees What*, on the course website
under Tutorials.

## What is here

| File | What it is |
|---|---|
| `persona_pipeline.py` | The whole program. The orchestration is the for-loop in `run_pipeline()` |
| `ollama_client.py` | `load_config()` and `chat()`, the two functions every script in this course calls |
| `config.json` | Every dial: endpoint, model, seed, logging level, and the four steps |
| `task_brief.md` | The design brief the interviewer step reads |
| `decisions.md` | Your answers to the interviewer's questions, pre-filled so the chain runs first try |
| `.agents/skills/system-prompt-author/SKILL.md` | The skill the author and reviser steps load |

## Running it

Ollama must be listening and the model pulled. From a container, the host is
`host.docker.internal` rather than `localhost`, and Ollama has to have been
started so that it accepts connections from outside the host:

```bash
OLLAMA_CONTEXT_LENGTH=8192 OLLAMA_HOST=0.0.0.0 ollama serve   # in one terminal
ollama pull llama3.2                                          # once
```

Then, from this folder:

```bash
python3 persona_pipeline.py config.json
```

The program prints the plan before it runs anything, so you can predict each
step's behavior, then the four outputs in order, then a trace table of what each
step cost, then the final artifact and the verdict of six checks applied in code.

## Changing it

Change the chain by editing `config.json`, not the code. The four things that
differ between steps are the persona, the temperature, whether a skill body is
present, and the `sees` list that decides what the step is allowed to read. That
list is the whole content of an agent system at this scale.

Four experiments worth running, each one line:

1. Remove `"skill": "system-prompt-author"` from the author step. Compare the two
   candidates, and run the six checks on both.
2. Add `"task"` and `"decisions"` to the red team's `sees` list. Do the attacks get
   sharper, or only more agreeable?
3. Set the red team's temperature to `0.1`. Are the three attacks still three
   different attacks?
4. Edit one line of `decisions.md`, such as the 150-word cap, and see how far that
   single answer propagates.

## If it fails

A missing `SKILL.md` stops the run and names the path it looked at, because a
pipeline that quietly drops its rules produces output that looks fine and is not.
The directory name must match the skill's `name:` field exactly.

A connection error names the URL it tried. Check `ollama_url` in `config.json`
against where Ollama is actually listening before changing anything else.
