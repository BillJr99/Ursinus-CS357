---
layout: assignment
permalink: /Assignments/RAGKnowledgeBase
title: "CS357: Foundations of Artificial Intelligence - Lab: RAG Knowledge Base"

info:
  coursenum: CS357
  purpose: "To give an agent you run a memory of documents you care about, so that it answers from your notes rather than from what it happened to learn in training, and says so when the answer is not there."
  tilt:
    task: "Index a small folder of your own documents in a local vector store, give a Pydantic AI agent one tool that searches it, and ask the agent questions: some your notes answer, one they do not, and one with the tool switched off so you can see the difference retrieval makes."
    criteria: "I assess a working index, an agent that retrieves before it answers and names its sources, a transcript of the questions, and a short writeup on what retrieval changed.  The full breakdown is in the rubric below."
  points: 100
  goals:
    - To split a set of documents into chunks and store them in a vector database that can search them by meaning
    - To give an agent a retrieval tool, so that it looks up evidence before it answers
    - To see, in your own transcript, what retrieval changes about an answer and what it does not
  rubric:
    - weight: 25
      description: "Corpus and Index"
      preemerging: "No index is built."
      beginning: "An index is built, but on placeholder text rather than documents you chose, or the script does not run as submitted."
      progressing: "At least five documents you chose are split into chunks and stored in a Chroma collection, and the indexing script reports how many chunks it stored."
      proficient: "As progressing, and the writeup says what the corpus is, why you chose it, and one thing about how the documents are written that made chunking easier or harder."
    - weight: 35
      description: "Retrieval Agent"
      preemerging: "No agent, or an agent with no retrieval tool."
      beginning: "An agent exists and a search tool is defined, but the agent answers without calling it, or the tool's result never reaches the answer."
      progressing: "A Pydantic AI agent calls a search tool over your collection, and its answers use the returned passages."
      proficient: "As progressing, and the answers name the source file for each fact, the agent says it could not find an answer when the passages do not contain one, and every call to Chroma or the model is wrapped in an exception handler that prints a located message and a traceback."
    - weight: 25
      description: "Queries and Transcript"
      preemerging: "No transcript."
      beginning: "A transcript shows fewer than the five required questions, or does not show the tool calls."
      progressing: "A transcript of five questions shows each tool call and answer: three your notes answer, one they do not, and one asked with retrieval turned off."
      proficient: "As progressing, and for each question you note whether the answer was right and whether its named source actually says it."
    - weight: 15
      description: "Writeup and Reproducibility"
      preemerging: "No writeup, or one that cannot be followed."
      beginning: "A writeup exists, but a reader could not rebuild the index and rerun the questions from it."
      progressing: "The model, package versions, commands, and corpus are recorded well enough to rerun."
      proficient: "Fully reproducible, with the three writeup questions answered and an AI-use disclosure."
  readings:
    - rtitle: "RAG Activity"
      rlink: "Activities/liascript-rag.md"
      liapage: true
    - rtitle: "Pydantic AI From the Loop Up: the agent, tools, and Ollama setup this lab uses"
      rlink: "../Tutorials/PydanticAI"
    - rtitle: "Chroma Documentation"
      rlink: "https://docs.trychroma.com"
    - rtitle: "Optional: RAG and Fine-Tuning: Retrieval Quality and LoRA, for measuring and improving retrieval beyond this lab"
      rlink: "Activities/liascript-ragquality.md"
      liapage: true

tags:
  - lab

---

# Lab: RAG Knowledge Base

Ask a local model when your office hours are, and it will answer.  It will sound sure of itself, and it will be making the answer up, because nothing about your course was in its training data.  **Retrieval-augmented generation (RAG)** fixes this the simplest possible way: before the model answers, your code looks up the passages in your own documents that match the question and hands them to the model as evidence.  The model then answers from what it was given, and can say where each fact came from.

In this lab you build that, small and complete.  You index a folder of documents you care about, give a Pydantic AI agent one tool that searches them, and ask it questions.  You leave with an agent that answers from your notes and says so when your notes do not have the answer.

---

## Before You Start

This lab builds on the *RAG Knowledge Base* session and on [Pydantic AI From the Loop Up]({{ site.baseurl }}/Tutorials/PydanticAI), which sets up the same agent and model this lab uses.  You need Ollama running with a model that calls tools reliably, and two Python packages.

```bash
python -m venv .venv && source .venv/bin/activate
pip install "pydantic-ai-slim[openai]==2.54.0" "chromadb==1.5.9"
ollama pull qwen2.5:3b
```

> **You should see.** Both installs end without an error.  `chromadb` is a vector database that runs on your own machine; `pydantic-ai-slim` is the agent framework from the tutorial.  `qwen2.5:3b` is the course's recommended model for tool calling.

> **Time budget.** About three hours: thirty minutes to gather a corpus, an hour to index it and build the agent, and the rest for the questions and the writeup.

---

## Step 1: Gather a Small Corpus

**Goal:** a folder of five to twenty documents whose answers you can check yourself.

Make a folder named `corpus` next to where your scripts will go, and put in `.md` or `.txt` files you know well: your own course notes, the syllabus pages of a class you are taking, a club's handbook, the documentation for a tool you use.  You need to know the answers, because in Step 4 you check the agent against them.

> **Watch out.** Do not index anything private you would not want stored in a file on disk, such as passwords, health records, or other people's messages.  The index is an ordinary folder, and anyone with your laptop can read it.

> **You should have.** A `corpus` folder with at least five files, and a sentence in your readme saying what they are and why you chose them.

---

## Step 2: Index It

**Goal:** every document split into chunks and stored where the agent can search them by meaning.

A model cannot read your whole folder on every question, so we cut each document into **chunks**, here one paragraph each, and store them in **Chroma**.  When you add a chunk, Chroma turns it into an **embedding**, a list of numbers that places text with similar meaning close together, so that a later search for "when can I meet the professor" can find a paragraph about "office hours" even though the words differ.  Save this as `index.py`:

```python
# index.py: split every document in corpus/ into paragraphs and store them in a local Chroma collection.
import traceback
from pathlib import Path

import chromadb

CORPUS = Path("corpus")
client = chromadb.PersistentClient(path="chroma_db")      # a folder on disk; nothing leaves your machine


def build_index():
    collection = client.get_or_create_collection("notes")
    ids, chunks, sources = [], [], []
    for doc in sorted(CORPUS.glob("*.md")) + sorted(CORPUS.glob("*.txt")):
        paragraphs = [p.strip() for p in doc.read_text(encoding="utf-8").split("\n\n") if p.strip()]
        for i, paragraph in enumerate(paragraphs):
            ids.append(f"{doc.stem}-{i}")
            chunks.append(paragraph)
            sources.append({"source": doc.name})
    try:
        collection.upsert(ids=ids, documents=chunks, metadatas=sources)   # Chroma embeds each chunk for us
    except Exception as e:
        print("[index:build_index]", e)
        traceback.print_exc()
        raise
    print(f"Indexed {len(chunks)} chunks from {len(set(s['source'] for s in sources))} files.")


if __name__ == "__main__":
    build_index()
```

Run it with `python index.py`.

> **You should see.** The first run downloads Chroma's small embedding model (about 80 MB), once.  Then one line reporting what was stored; on a two-file test corpus it read `Indexed 5 chunks from 2 files.`  Yours will be larger.  A new `chroma_db` folder appears next to the script.

> **If it fails.** `0 chunks` means the script found no `.md` or `.txt` files; check that `corpus` is in the folder you ran the script from.

**Predict:** some of your files have a heading on its own line, separated from the text below by a blank line.  What chunk will that heading become, and will it help or hurt a search?

---

## Step 3: Give an Agent a Search Tool

**Goal:** an agent that looks up passages before it answers, and names where each fact came from.

The search is a **tool**, exactly like the tools in the *Tool Use* session: a Python function the model may ask your code to run.  The docstring tells the model what the tool does and when to use it.  The instructions tell it to search first, answer only from what comes back, name the file, and say so when the answer is not there.  Save this as `rag_agent.py`:

```python
# rag_agent.py: a Pydantic AI agent that answers only from your notes, using a search tool over Chroma.
import os
import sys
import traceback

os.environ.setdefault("PYDANTIC_AI_NO_BANNER", "1")

import chromadb
from pydantic_ai import Agent, UsageLimits
from pydantic_ai.models.openai import OpenAIChatModel
from pydantic_ai.providers.ollama import OllamaProvider

collection = chromadb.PersistentClient(path="chroma_db").get_or_create_collection("notes")

model = OpenAIChatModel(
    os.environ.get("MODEL", "qwen2.5:3b"),
    provider=OllamaProvider(base_url=os.environ.get("BASE_URL", "http://localhost:11434/v1")),
)

agent = Agent(
    model,
    instructions=(
        "Answer questions about the user's notes. Always call search_notes first. "
        "Answer only from the passages it returns, and name the source file for each fact. "
        "If the passages do not contain the answer, say: I could not find that in your notes."
    ),
    model_settings={"temperature": 0.0, "seed": 42},
)


@agent.tool_plain
def search_notes(query: str) -> str:
    """Searches the user's notes and returns the three most relevant passages with their source files.

    Args:
        query: What to search for, in plain words.
    """
    try:
        hits = collection.query(query_texts=[query], n_results=3)
    except Exception as e:
        print("[rag_agent:search_notes]", e)
        traceback.print_exc()
        raise
    return "\n\n".join(
        f"[{meta['source']}] {text}" for text, meta in zip(hits["documents"][0], hits["metadatas"][0])
    )


if __name__ == "__main__":
    question = " ".join(sys.argv[1:]) or "When are office hours?"
    try:
        result = agent.run_sync(question, usage_limits=UsageLimits(request_limit=4))
    except Exception as e:
        print("[rag_agent:main]", e)
        traceback.print_exc()
        raise
    for message in result.all_messages():
        for part in message.parts:
            if part.part_kind == "tool-call":
                print(f"  [tool call] {part.tool_name}({part.args})")
            elif part.part_kind == "tool-return":
                print(f"  [tool result] {str(part.content)[:120]!r}")
    print(result.output)
```

Run it with a question your notes answer, for example `python rag_agent.py "When are office hours?"`.

> **You should see.** A `[tool call] search_notes(...)` line, a `[tool result]` line beginning with a source file in brackets, and then an answer that names that file.  The exact wording depends on your model and your notes.

> **If it fails.** A connection error means Ollama is not running; start it and retry.  If there is no `[tool call]` line, the model answered without searching: confirm `MODEL` is `qwen2.5:3b`, since smaller or older models often skip the tool.

---

## Step 4: Ask Five Questions

**Goal:** a transcript that shows what retrieval does, and what it does not do.

Run `rag_agent.py` once for each question below and save the full output of every run.

1. Three questions your notes answer, ideally worded differently from the notes themselves.
2. One question your notes do not answer.  The agent should say it could not find it.
3. One of your first three questions again, with retrieval turned off.  Comment out the `@agent.tool_plain` line and the instruction to call `search_notes`, rerun, then restore them.

For each answer, write one line in your readme: was it right, and does the file it named actually say that?

**Predict:** before you run question 5, write down what you expect the model to say without its notes.

> **You should have.** Five saved runs and five one-line checks in your readme.

---

## Writeup

Answer each in a short paragraph, pointing at your own transcript:

1. What did retrieval change between question 5 and the same question with the tool on?
2. Did the agent ever name a source that did not actually support its answer?  What does that tell you about trusting the source it names?
3. If your notes doubled in size tomorrow, what in `index.py` would you change first, and why?

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Indexed 0 chunks` | No `.md` or `.txt` files in `corpus`, or the script ran from another folder | Run it from the folder that contains `corpus` |
| The answer ignores the passages | The model is not following the instructions, or never called the tool | Check for a `[tool call]` line; use `qwen2.5:3b` |
| Old documents still show up after you edit the corpus | The `chroma_db` folder still holds the previous chunks | Delete `chroma_db` and rerun `index.py` |
| Connection refused | Ollama is not running | Start Ollama and retry |

---

## Deliverables

| File or artifact | What it shows | Rubric row |
|---|---|---|
| `corpus/`, `index.py`, and its output | Your documents, chunked and stored | Corpus and Index (25) |
| `rag_agent.py` | An agent that searches before it answers and names its sources | Retrieval Agent (35) |
| The five saved runs and your one-line checks | What retrieval changed, question by question | Queries and Transcript (25) |
| A readme with the corpus description, commands, model and package versions, the three writeup answers, and an AI-use disclosure | A reader could rerun everything | Writeup and Reproducibility (15) |

---

## Self-Check Before You Submit

- [ ] At least five documents you chose are indexed, and `index.py` reports the chunk count.
- [ ] Every agent run shows a `[tool call]` line before the answer, except the retrieval-off run.
- [ ] Answers name their source file, and the not-in-my-notes question gets "I could not find that".
- [ ] Every call to Chroma or the model sits inside an exception handler with a located message and a traceback.
- [ ] Five saved runs, five one-line checks, and the three writeup answers are in the readme.
- [ ] Model name and package versions are recorded.
