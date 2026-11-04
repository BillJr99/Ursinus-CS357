---
layout: assignment
permalink: /Assignments/RAGKnowledgeBase
title: "CS357: Foundations of Artificial Intelligence - Lab: RAG Knowledge Base"

info:
  coursenum: CS357
  purpose: "To give an agent you run a memory of documents you care about, so that it answers from your notes instead of from its training data, and says so when your notes do not have the answer."
  tilt:
    task: "Write three questions about a small folder of your own documents before you index anything.  Then index the folder in a local vector store, connect it to a model that searches it before it answers (a Pydantic AI agent with a search tool on the code path, or a Langflow flow on the no-code path), and check each answer against your files."
    criteria: "I assess a working index, an agent that retrieves before it answers and names its sources, your three questions with a check on each answer, and a short writeup.  The rubric below gives the full breakdown."
  points: 100
  goals:
    - To split a set of documents into chunks and store them in a vector database that can search them by meaning
    - To connect a model to a retrieval step, as an agent tool in code or as a node on a Langflow canvas, so that it looks up evidence before it answers
    - To decide what a right answer is before you see any answers, and then check the agent against it
  rubric:
    - weight: 30
      description: "Corpus and Index"
      preemerging: "No index is built."
      beginning: "An index is built, but from placeholder text instead of documents you chose, or the submitted script does not run (on the no-code path, the exported flow)."
      progressing: "At least five documents you chose are split into chunks and stored in a Chroma collection, and the indexing script reports how many chunks it stored."
      proficient: "As progressing, and the readme says what the corpus is, why you chose it, and one thing about how the documents are written that made chunking easier or harder.  On the no-code path, a File, Text Splitter, Ollama Embeddings, and Chroma flow over the same documents earns this row on equal terms, with the stored chunk count read from the Chroma node's inspection view."
    - weight: 30
      description: "Retrieval Agent"
      preemerging: "No agent, or an agent with no retrieval tool (on the no-code path, no flow, or a flow with no search step)."
      beginning: "An agent exists and a search tool is defined, but the agent answers without calling it, or the tool's result never reaches the answer.  On the no-code path: the flow runs, but the search results are not wired into the prompt."
      progressing: "A Pydantic AI agent calls a search tool over your collection, and its answers use the returned passages.  On the no-code path: a Langflow flow searches your Chroma collection and passes the results into the Prompt node, and its answers use them."
      proficient: "As progressing, and the answers name the source file for each fact, the agent says it could not find an answer when the passages do not contain one, and an exception handler wraps every call to Chroma or the model and prints a located message and a traceback.  On the no-code path, the same source naming and abstention earn this row on equal terms, with every node setting (models, Base URL, chunk size, number of results, temperature, prompt text) recorded in the readme in place of the exception handlers."
    - weight: 25
      description: "Golden Questions and Checks"
      preemerging: "No questions, or no saved runs."
      beginning: "Fewer than three questions, questions written after the index was built, or saved runs that do not show the tool calls (on the no-code path, the retrieved chunks)."
      progressing: "Three questions written in the readme before indexing, two that your files answer and one that they do not, each with a saved run that shows the tool call and the answer.  On the no-code path each run is a Playground conversation, with a screenshot or copy of the chunks the search step returned."
      proficient: "As progressing, and each answer has a one-line check: was it right, and does the file it named actually say that?  For the question your files do not answer, the agent says \"I could not find that\" instead of inventing an answer, or the check says plainly that it did not."
    - weight: 15
      description: "Writeup and Reproducibility"
      preemerging: "No writeup, or one that cannot be followed."
      beginning: "A writeup exists, but a reader could not rebuild the index and rerun the questions from it."
      progressing: "The model, package versions, commands, and corpus are recorded well enough to rerun.  On the no-code path: the exported flow JSON, the Langflow version, and the node settings."
      proficient: "Fully reproducible, with the two writeup questions answered and an AI-use disclosure."
  readings:
    - rtitle: "RAG: Building and Measuring a Knowledge Base"
      rlink: "Activities/liascript-rag.md"
      liapage: true
    - rtitle: "RAG Worked Example: Build the Pipeline Together (this lab's steps, built end to end on both paths and measured)"
      rlink: "Activities/liascript-ragworkshop.md"
      liapage: true
    - rtitle: "Pydantic AI From the Loop Up: the agent, tools, and Ollama setup this lab uses"
      rlink: "../Tutorials/PydanticAI"
    - rtitle: "Visual Agents: Langflow setup and the RAG flow wiring the no-code path uses"
      rlink: "../Tutorials/VisualAgents"
    - rtitle: "Chroma Documentation"
      rlink: "https://docs.trychroma.com"

tags:
  - lab

---

# Lab: RAG Knowledge Base

Ask a local model when your office hours are, and it will answer.  It will sound sure of itself, and it will be making the answer up, because nothing about your course was in its training data.  **Retrieval-augmented generation (RAG)** fixes this in the simplest way: before the model answers, your code finds the passages in your own documents that match the question and gives them to the model as evidence.  The model then answers from those passages and can say where each fact came from.

In this lab you build a small, complete version of that.  You write three questions about a folder of documents you care about, index the folder, give a Pydantic AI agent one tool that searches it, and check its answers against your files.  When you finish, you have an agent that answers from your notes and says so when your notes do not have the answer.  If you want to see each step on its own first, with a retrieval-off comparison, work through the [RAG From Zero]({{ site.baseurl }}/Tutorials/RAGFromZero) tutorial.

---

## Choose Your Path

Both paths build the same pipeline, reach the same learning objectives, and earn the same rubric.  Pick one before you start, and name it at the top of your readme.

| Path | What you build | What you need | Pick this if |
|------|----------------|---------------|--------------|
| **Code** | `index.py` and `rag_agent.py`: a Chroma index and a Pydantic AI agent with a search tool (Steps 2 and 3) | Python, `pydantic-ai-slim` and `chromadb`, and Ollama with `qwen2.5:3b` | You want to see the tool call in your own code and control every line of it |
| **No-code** | The same index and query path as one Langflow flow (the [No-code Path](#no-code-path) section, in place of Steps 2 and 3) | Langflow, and Ollama with `llama3.2` and `nomic-embed-text` | You would rather wire and inspect than write Python; you still choose the corpus, write the grounding prompt, and check every answer |

Steps 1 and 4, the writeup, and the deliverables apply to both paths.  On the no-code path, read "script" as "exported flow JSON", "tool call" as "the chunks the search step returned", and "run" as "one question in the Playground" wherever this page and the rubric use those words.

---

## Before You Start

The *RAG Worked Example* session builds these steps on a small corpus, on both paths.  **Code path:** [Pydantic AI From the Loop Up]({{ site.baseurl }}/Tutorials/PydanticAI) sets up the same agent and model this lab uses.  You need two Python packages and Ollama running with a model that calls tools reliably.  **No-code path:** skip the commands below and start with Step 1, then follow the [No-code Path](#no-code-path) section in place of Steps 2 and 3.

```bash
python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
python3 -m pip install "pydantic-ai-slim[openai]==2.54.0" "chromadb==1.5.9"
python3 -c "import pydantic_ai, chromadb; print('packages ok')"
ollama pull qwen2.5:3b
```

> **You should see.** Both installs finish without an error, and the check prints `packages ok`.  `chromadb` is a vector database that runs on your own machine.  `pydantic-ai-slim` is the agent framework from the tutorial.  `qwen2.5:3b` is the course's recommended model for tool calling.  Run the `source` line again in each new terminal.

> **If `pip` says `externally-managed-environment`.**  Your operating system manages its own Python (common on Ubuntu, Debian, WSL, and Homebrew), so it refuses packages installed directly into it, because they could break the tools that depend on it.  Nothing is wrong with your machine, and the virtual environment is the fix: run the first two lines, and then install again.  Do not use `--break-system-packages`.

> **If `python3 -m venv` says `ensurepip is not available`.**  On Ubuntu, Debian, and WSL, virtual environments come in a separate package.  Run `sudo apt install python3-venv`, delete the partial folder with `rm -rf .venv`, and then start again from the `venv` line.  If that package name is not found, use the version-specific name the error message gives you, such as `python3.14-venv`.

> **Time budget.** About two hours: thirty minutes to gather a corpus and write your questions, an hour to index it and build the agent, and the rest for the runs and the writeup.

---

## Step 1: Gather a Small Corpus

**Goal:** a folder of five to twenty documents whose answers you can check yourself, and three questions about them written before anything is indexed.

Make a folder named `corpus` next to where your scripts will go.  Put in `.md` or `.txt` files you know well: your own course notes, the syllabus pages of a class you are taking, a club's handbook, the documentation for a tool you use.  You may also use your team's stakeholder material (interview notes, your partner's public documents, your evidence folder), so that the lab also moves your project forward.  If you do, use only material your partner agreed to share, and leave out personal details about the people you interviewed.  You need to know the answers, because in Step 4 you check the agent against them.

> **Watch out.** Do not index anything private you would not want stored in a file on disk, such as passwords, health records, or other people's messages.  The index is an ordinary folder, and anyone with your laptop can read it.

Before you index anything, write three **golden questions** in your readme: two that your files answer (ideally worded differently from the files) and one that they do not.  Next to each answerable question, write the answer and the file it comes from.  Write them first.  A question written after you have seen the agent's answers measures how much you agree with the agent, not whether the agent is right.

> **You should have.** A `corpus` folder with at least five files, a sentence in your readme saying what they are and why you chose them, and your three golden questions with their expected answers.

---

## Step 2: Index It

**Goal:** every document split into chunks and stored where the agent can search them by meaning.

A model cannot read your whole folder for every question, so you cut each document into **chunks** (here, one paragraph each) and store them in **Chroma**.  When you add a chunk, Chroma turns it into an **embedding**: a list of numbers that places text with similar meaning close together.  As a result, a search for "when can I meet the professor" can find a paragraph about "office hours," even though the words differ.

Each chunk needs three things: an ID, its text, and the file it came from, because the agent has to name that file later.  Suppose `hours.md` holds this:

```text
Office Hours

I hold office hours on Mondays in Room 204.
```

The blank line separates two paragraphs, so this file becomes two chunks:

```text
id          text                                            source
hours-0     Office Hours                                    hours.md
hours-1     I hold office hours on Mondays in Room 204.     hours.md
```

The ID is the file's stem and the paragraph's number, so it stays the same every time you run the script.  That matters because `upsert` replaces a chunk that has the same ID, so rerunning the script does not store everything twice.  Save this as `index.py`, and fill in the `TODO`s:

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
        # TODO: make paragraphs, a list of this file's paragraphs.  doc.read_text(encoding="utf-8")
        #       reads the file, .split("\n\n") cuts it at blank lines, and .strip() trims a
        #       paragraph.  Leave out any paragraph that is empty after trimming.
        for i, paragraph in enumerate(paragraphs):
            # TODO: append one entry to each list, as in the table above:
            #       ids gets f"{doc.stem}-{i}", chunks gets the paragraph, and
            #       sources gets a dictionary, {"source": doc.name}.
    if not chunks:
        print("Indexed 0 chunks: no .md or .txt files in corpus/.")
        return
    try:
        # TODO: store everything with collection.upsert(ids=..., documents=..., metadatas=...).
        #       documents is your chunks list, and metadatas is your sources list.
    except Exception as e:
        print("[index:build_index]", e)
        traceback.print_exc()
        raise
    print(f"Indexed {len(chunks)} chunks from {len(set(s['source'] for s in sources))} files.")


if __name__ == "__main__":
    build_index()
```

Run it with `python index.py`.

> **You should see.** The first run downloads Chroma's small embedding model (about 80 MB) once.  Then the script prints one line, such as `Indexed 5 chunks from 2 files.`, with your own counts, and a new `chroma_db` folder appears next to the script.

> **If it fails.** `0 chunks` means the script found no `.md` or `.txt` files, so check that `corpus` is in the folder you ran the script from.

**Now check the retrieval by itself.**  Later, a wrong answer could come from the search or from the model.  If you test the search now, you will know which one to fix.  Save this as `check_retrieval.py`, a scratch file you do not submit, with one of your golden questions in it:

```python
import chromadb

collection = chromadb.PersistentClient(path="chroma_db").get_or_create_collection("notes")
question = "When are office hours?"     # use one of your golden questions

hits = collection.query(query_texts=[question], n_results=3)
for text, meta in zip(hits["documents"][0], hits["metadatas"][0]):
    print(f"[{meta['source']}] {text[:70]}")
```

> **You should see.** Three lines, and the file your readme expects for that question is among them.  If it is not, no model can give the right answer from these passages, so fix this first.  Reword the question, or look at how that file split into paragraphs.

A heading on its own line becomes a chunk with no information in it, and it can crowd out the paragraph you wanted.  If that happens in your index, fold each heading into the paragraphs under it, as Step 6 of the [RAG Worked Example](https://liascript.github.io/course/?https://raw.githubusercontent.com/BillJr99/Ursinus-CS357-Fall2026/gh-pages/_pages/Activities/liascript-ragworkshop.md#11) does, and say in your readme what changed.

---

## Step 3: Give an Agent a Search Tool

**Goal:** an agent that looks up passages before it answers, and names where each fact came from.

The search is a **tool**, as in the *Tool Use* session: a Python function the model can ask your code to run.  So the flow on each question is:

```text
question --> model --> asks for search_notes(query) --> your code queries Chroma
                                                              |
answer that names the file <-- model <-- passages with their file names
```

Two pieces of text steer the model.  The docstring tells it what the tool does.  The instructions tell it how to behave, and they are where you prevent made-up answers.  Save this as `rag_agent.py`, and fill in the `TODO`s:

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
    # TODO: write the instructions as one string.  Tell the model to answer questions about the
    #       user's notes, to always call search_notes first, to answer only from the passages it
    #       returns, and to name the source file for each fact.  End with this exact rule:
    #       If the passages do not contain the answer, say: I could not find that in your notes.
    instructions="",
    model_settings={"temperature": 0.0, "seed": 42},
)


@agent.tool_plain
def search_notes(query: str) -> str:
    """Searches the user's notes and returns the three most relevant passages with their source files.

    Args:
        query: What to search for, in plain words.
    """
    try:
        # TODO: set hits to the same query your check_retrieval.py runs, using this query.
    except Exception as e:
        print("[rag_agent:search_notes]", e)
        traceback.print_exc()
        raise
    # TODO: return one string holding each passage as "[source file] text", with a blank line
    #       between passages.  The bracketed file name is what lets the model name its source.


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

> **You should see.** A `[tool call] search_notes(...)` line, a `[tool result]` line beginning with a source file in brackets, and an answer that names that file.  The wording depends on your model and your notes.

> **If it fails.** A connection error means Ollama is not running, so start it and retry.  If there is no `[tool call]` line, the model answered without searching, so confirm `MODEL` is `qwen2.5:3b`, since smaller or older models often skip the tool.

---

## No-code Path

If you chose the no-code path, follow this section in place of Steps 2 and 3.  You build the same two phases on a Langflow canvas: an **index path** that chunks, embeds, and stores your `corpus` once, and a **query path** that runs for every question.  The [Visual Agents]({{ site.baseurl }}/Tutorials/VisualAgents) tutorial walks through the same wiring.  Node names change a little between Langflow versions, but the dataflow stays the same:

```text
index path:  File --> Text Splitter --> Chroma (with Ollama Embeddings)
query path:  Chat Input --> Chroma search --> Prompt --> Ollama --> Chat Output
```

### Step N1: Install and Launch Langflow

**Goal:** the Langflow canvas open in your browser, with both Ollama models available to it.

```bash
python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
python3 -m pip install langflow
langflow run
ollama pull llama3.2
ollama pull nomic-embed-text
```

> **You should see.** A "Langflow is running" banner in the terminal and the canvas at `http://localhost:7860`.  `ollama list` shows `llama3.2` and `nomic-embed-text`.

> **If `pip` says `externally-managed-environment` or `python3 -m venv` says `ensurepip is not available`.**  The notes under *Before You Start* explain both errors and how to fix them.

> **If it fails.** A dependency-resolver error from `pip install langflow` usually means your Python is too new or too old.  Create a fresh virtual environment on Python 3.11 or 3.12 and install there.  If `localhost:7860` refuses to connect, the server is still starting, so wait for the banner.

### Step N2: Build the Index Path, and Check the Search

**Goal:** your `corpus` stored in Chroma, and a search that finds the right file before any model is involved.

Create a **New Flow** from a **Blank Canvas**, and wire the index path:

1.  **File** (upload every file in your `corpus` folder) to **Text Splitter** (the recursive character splitter; start with a chunk size of 1000 and an overlap of 100) to **Chroma** (collection name `notes`).
2.  Wire an **Ollama Embeddings** node (model `nomic-embed-text`, Base URL `http://localhost:11434`) into Chroma's embedding input.  Chroma uses it to turn each chunk into numbers that place similar meanings close together.
3.  Write every node setting in your readme as you go: the model, the Base URL, chunk size, and overlap.  On this path, that list takes the place of the code.

> **You should see.** The Chroma node's inspection view lists the chunks it stored.  Write that count in your readme, as `index.py` would have printed it.

Now check the search by itself.  Later, a wrong answer could come from the search or from the model, and if you test the search now, you will know which one to fix.  Wire **Chat Input** to the same **Chroma** node's search input, with the number of results set to 3, and type one of your golden questions.

> **You should see.** In the Chroma node's inspection view, three chunks, including one from the file your readme expects for that question.  If it is not there, no model can give the right answer from these chunks, so change the chunk size or reword the question first, and record what you changed.

> **If it fails.** A connection refusal at run time means a node's Base URL is wrong or Ollama is not running.  If old documents still show up after you change the corpus, give the Chroma collection a new name and run the index path again.

### Step N3: Ground the Answers and Name the Source

**Goal:** answers that come only from your notes, name the file each fact came from, and say so when the notes do not have the answer.

Finish the query path.  Wire the search results to a **Prompt** node, then to **Ollama** (model `llama3.2`, temperature 0, Base URL `http://localhost:11434`), then to **Chat Output**, and add these settings to your readme.  Paste this into the Prompt node, then wire the search results into `{context}` and the Chat Input into `{question}`:

```text
Answer questions about the user's notes, using ONLY the passages below.
Name the source file for each fact.
If the passages do not contain the answer, say: I could not find that in your notes.

Passages:
{context}

Question: {question}
```

The first line is what stops the model from using what it remembers, and the last rule gives it something to say when the search comes up empty.  Ask one in-corpus question in the **Playground**.

> **You should see.** An answer that names a file from your `corpus`, and, in the search step's inspection view, the chunks that file came from.

> **If it fails.** If the answer never names a file, check that the search results carry the file name.  The File node usually stores it with each chunk, and the inspection view shows whether it is there.

Then go on to Step 4.  When you are done, export the flow (the flow menu's **Export**) and save the JSON file next to your readme.

---

## Step 4: Ask Your Three Golden Questions

**Goal:** a saved run for each of your three questions, and a check on each answer.

Run `rag_agent.py` once for each golden question and save the full output of every run.  On the no-code path, ask each question in a fresh Playground session and save the conversation together with the chunks the search step returned.

For each answer, write one line in your readme: was it right, and does the file it named actually say that?  For the question your files do not answer, the agent should say it could not find it.  If it answered anyway, say so in your check.  That is a finding, not a failure of your lab.

**Predict:** before you run the question your files do not answer, write down what you expect the agent to say.

> **You should have.** Three saved runs and three one-line checks in your readme.

---

## Writeup

Answer each in a short paragraph, pointing at your own runs:

1. Did the agent ever name a source that did not actually support its answer?  What does that tell you about trusting the source it names?
2. If your notes doubled in size tomorrow, what in `index.py` (or which node setting in your flow) would you change first, and why?

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| The answer ignores the passages | The model is not following the instructions, or never called the tool | Check for a `[tool call]` line; use `qwen2.5:3b` |
| Old documents still show up after you edit the corpus | The `chroma_db` folder still holds the previous chunks | Delete `chroma_db` and rerun `index.py` |
| (No-code) The answer ignores your notes | The search results are not wired into the Prompt's `{context}` | Open the Prompt node's inspection view and check that the passages arrived |
| (No-code) The answer names no source file | The chunks do not carry their file name | Check the search step's inspection view; re-upload through the File node rather than pasting text |

---

## Deliverables

| File or artifact | What it shows | Rubric row |
|---|---|---|
| `corpus/`, `index.py`, and its output (no-code: the chunk count from the Chroma node) | Your documents, chunked and stored | Corpus and Index (30) |
| `rag_agent.py` (no-code: the exported flow JSON and your node settings) | An agent that searches before it answers and names its sources | Retrieval Agent (30) |
| Your three golden questions with expected answers, the three saved runs, and your one-line checks (no-code: Playground conversations with the retrieved chunks) | Whether the agent was right, question by question | Golden Questions and Checks (25) |
| A readme with your path, the corpus description, commands, model and package (or Langflow) versions, the two writeup answers, and an AI-use disclosure | A reader could rerun everything | Writeup and Reproducibility (15) |

---

## Self-Check Before You Submit

- [ ] Your readme names your path, code or no-code.
- [ ] At least five documents you chose are indexed, and `index.py` (or the Chroma node) reports the chunk count.
- [ ] Your three golden questions, with expected answers, were in the readme before you built the index.
- [ ] Every agent run shows a `[tool call]` line before the answer (no-code: the retrieved chunks).
- [ ] Answers name their source file, and the not-in-my-notes question gets "I could not find that".
- [ ] Code path: every call to Chroma or the model sits inside an exception handler with a located message and a traceback.  No-code path: every node setting is in the readme and the flow JSON is exported.
- [ ] Three saved runs, three one-line checks, and the two writeup answers are in the readme.
- [ ] Model name and package versions (or the Langflow version) are recorded.
