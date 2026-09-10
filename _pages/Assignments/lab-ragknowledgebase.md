---
layout: assignment
permalink: /Assignments/RAGKnowledgeBase
title: "CS357: Foundations of Artificial Intelligence - Lab: RAG Knowledge Base"

info:
  coursenum: CS357
  purpose: "To give an agent you run grounded, citable memory over a corpus you care about, including the honesty to abstain when the answer is not there, and then to check that pipeline mid-flight with a golden set, real retrieval and citation measurements, and a regression harness you can rerun for the rest of the term."
  tilt:
    task: "Build a RAG pipeline over your own corpus with Chroma and a local model, compare chunking strategies by recall@k, and audit its citations and abstention.  Then run the RAG Quality Checkup pathway on it: design a ten-item golden set with a prediction and rationale per item, complete a checkup worksheet with measurements from your own pipeline (recall@k across two chunking configurations, a citation audit, and one analyzed failure), and pin both into a regression harness that reruns identically."
    criteria: "I assess your work on the citing, abstaining pipeline, an empirical chunking comparison, and a hand-audited evaluation of retrieval and citations, plus the checkup pathway: the design quality of your benchmark items and their rationales, a worksheet with real measurements from your own pipeline, and a regression harness that reruns identically.  The full breakdown is in the rubric below."
  points: 200
  goals:
    - To construct a complete retrieval-augmented generation pipeline over a personal document corpus using Chroma and a local model
    - To make and defend chunking decisions empirically by comparing at least two strategies with recall@k metrics
    - To evaluate retrieval quality with recall at k and grounding quality with a citation audit
    - To implement and demonstrate abstention when the corpus does not contain an answer
    - To design a ten-item golden set that deliberately mixes reliable and hallucination-prone territory, with a falsifiable prediction and a scoring rule stated for each item before it runs
    - To measure recall@k across two chunking configurations on your own corpus, audit citations by hand as supported or unsupported by the cited chunk, and record one concrete pipeline failure with a hypothesis and a planned fix
    - To freeze that evaluation into a rerunnable regression harness, show that two runs agree, and separate knowledge failures from metric failures in the results
    - To apply parameter-efficient fine-tuning (LoRA/QLoRA) to a local model using a real dataset and a modern training toolchain (Unsloth or hand-rolled transformers/peft/trl)
    - To export a fine-tuned model to GGUF and run it locally in Ollama, making a model you trained a first-class citizen of your local-first stack
    - To instrument training with loss curves and evaluate output quality before and after fine-tuning
    - To understand the trade-offs between fine-tuning, RAG, and prompting for knowledge injection
    - To document a fine-tuned model with a model card and identify potential bias shifts
    - To implement a Monte Carlo retirement simulation that draws annual returns from a configurable normal distribution and records portfolio paths across 1,000 simulations
    - To generate a labeled two-panel visualization showing simulated paths with median and percentile bands, and a histogram of final balances
    - To construct a multimodal API request that encodes a PNG image as a base64 string, packages it in the correct Ollama JSON payload, and parses the structured text response
    - To conduct a two-turn conversation with a multimodal model using a structured prompt that specifies role, required response sections, and audience assumptions
    - To compare AI-generated quantitative claims against ground-truth statistics and identify specific numerical errors with verbatim AI excerpts
    - To evaluate the sensitivity of simulation outcomes to parameter changes and explain the compounding effect of return mean and volatility on the outcome distribution
    - To propose a user-facing guardrail that limits over-reliance on AI numerical claims in financial contexts
  rubric:
    - weight: 15
      description: Pipeline Implementation
      preemerging: The pipeline (code or flow) fails to index or query because of major issues, or the program or flow does not run
      beginning: The pipeline (code or flow) runs but fails on test questions because of one or more minor issues
      progressing: The pipeline indexes and answers correctly with citations, but a component such as abstention or configuration is fragile or incomplete
      proficient: The pipeline (hand-coded or built as a Langflow flow) indexes, retrieves, answers with bracketed source numbers as citations, and abstains with the designated phrase when no chunk is relevant; a screenshot or log shows all three behaviors (answer with citation, abstention, and the bare-model hallucination contrast); configuration is externalized and exceptions are handled with located messages and tracebacks, or, on the flow route, the exported flow JSON plus documented node settings is the externalized configuration
    - weight: 12
      description: Chunking Strategy and Justification
      preemerging: A single arbitrary chunking is used without discussion
      beginning: A chunking choice is stated but not compared against an alternative
      progressing: Two chunking strategies (in code, or as two flow configurations) are compared on a small question set with results reported
      proficient: At least two chunking strategies (implemented in code or as two Langflow configurations with different splitter settings) are compared on a defined question set; recall@k is reported for k in {1,3,5} for each strategy in a table; the shipped choice is defended with a specific numeric comparison (e.g., "strategy A achieves recall@3 of 0.80 vs. 0.60 for strategy B on our question set")
    - weight: 13
      description: Evaluation and Citation Audit
      preemerging: No evaluation is provided
      beginning: Informal trials are described without a protocol or metric
      progressing: A question set with recall at k and an answer accuracy measure is evaluated, with limited citation auditing
      proficient: A question set of at least ten questions is evaluated with recall@k and answer accuracy; every citation in a sample of at least ten answers is audited by hand for faithfulness; a faithfulness rate (e.g., "9/10 citations correctly supported the claim") is reported; any failures are shown verbatim and classified using the hallucination taxonomy from class
    - weight: 5
      description: Code Quality and Documentation
      preemerging: Code or configuration documentation and structure are absent, or the work departs significantly from accepted practice
      beginning: Code or configuration documentation is limited in ways that reduce the readability and reproducibility of the work
      progressing: Documentation is present but only restates the explicit code or configuration definitions
      proficient: Every non-trivial function has a docstring; all network, embedding, and database operations are wrapped in exception handlers that print a located message (e.g., [lab2:query_corpus]) followed by a traceback; model name, chunk size, overlap, top-k, and abstention threshold are read from a JSON config file rather than hardcoded; on the Langflow route this row is earned by configuration quality, the two exported flow JSONs, documented node settings (model, chunk size, overlap, top-k), and setup notes sufficient to reproduce both flows exactly
    - weight: 5
      description: Writeup, Reflection, and Submission
      preemerging: An incomplete submission is provided
      beginning: The program is submitted, but not according to the directions in one or more ways
      progressing: The program is submitted according to the directions with a minor omission, with at least superficial responses to the reflection prompts
      proficient: The program is submitted according to the directions, including a readme writeup, a pair programming log with at least two timestamped role swaps, a corpus datasheet covering sources, time range, representation gaps, and known limitations, and reflection answers that each cite a specific experimental result from the lab rather than restating the prompt
    - weight: 12
      description: "Quality Checkup: Benchmark Design"
      preemerging: Fewer than ten items exist, or items lack expected answers
      beginning: Ten items exist with expected answers, but the set does not deliberately mix reliable and hallucination-prone territory, or rationales are missing
      progressing: The set mixes five expected-reliable and five expected-fragile items with rationales, but several rationales do not connect to why model training data would be thick or thin there
      proficient: "Ten items (five expected-reliable, five expected-fragile), each with an expected answer, a scoring rule the harness can apply, and a one-sentence rationale grounded in training-data reasoning (recency, locality, specificity, or citation-shaped risk).  This row is about judgment, not medium: it is earned identically whether the set is a JSON file, a promptfoo YAML case list, or a spreadsheet"
    - weight: 23
      description: "Quality Checkup: The Checkup Worksheet"
      preemerging: The worksheet is empty or filled with invented numbers that the team's pipeline did not produce
      beginning: Some measurements exist but only one chunking configuration was tested, or the citation audit is missing
      progressing: recall@k for both configurations and a five-row citation audit are complete, but the failure case is missing or has no hypothesis
      proficient: "recall@k is measured for both chunking configurations on the team's own corpus with the winner identified; the five-row citation audit classifies each claim as supported or unsupported with chunk references; and one observed failure is recorded with a plausible hypothesis and a planned fix.  The medium does not matter: measurements taken by hand in Open WebUI's knowledge-base view or the Langflow playground earn this row on the same terms as measurements printed by a script, provided the numbers came from the team's own pipeline"
    - weight: 15
      description: "Quality Checkup: The Regression Harness"
      preemerging: No harness exists, or it cannot be rerun
      beginning: A harness exists but the golden set is not pinned (questions or scoring change between runs), or it was run only once
      progressing: The harness reruns with a pinned golden set and protocol, but the two runs' outputs were not compared, prediction misses are listed rather than explained, or the harness is not committed alongside the rest of the lab
      proficient: The harness (a scripted run sheet in a spreadsheet, declarative promptfoo YAML, or plain Python built on the class evaluation harness, your choice) pins the Part 5 golden set, extended with corpus-specific items, and a fixed protocol (temperature 0.0, a fixed seed, the model named); two runs are shown to agree; every item whose outcome differs from its Part 5 prediction gets a sentence separating knowledge failure from metric failure; and the harness lives in the lab repository where the Rubric Pipeline Lab can pick it up
  readings:
    - rtitle: "RAG Activity"
      rlink: "Activities/liascript-rag.md"
      liapage: true
    - rtitle: "RAG Quality: Chunking and Measuring Retrieval"
      rlink: "Activities/liascript-ragquality.md"
      liapage: true
    - rtitle: "Chroma Documentation"
      rlink: "https://docs.trychroma.com"
    - rtitle: "RAG Quality: Chunking and Measuring Retrieval (its extension weighs fine-tuning against RAG and prompting)"
      rlink: "Activities/liascript-ragquality.md"
      liapage: true
    - rtitle: "Unsloth: Fine-Tuning Notebooks and Ollama/GGUF Export (Direction 1)"
      rlink: "https://unsloth.ai/docs/get-started/unsloth-notebooks"
    - rtitle: "Unsloth: Fine-tune Llama 3 and Use in Ollama (Direction 1 tutorial)"
      rlink: "https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/tutorial-how-to-finetune-llama-3-and-use-in-ollama"
    - rtitle: "Running Local Models"
      rlink: "../Tutorials/LocalModels"
    - rtitle: "Data Cards and Model Cards"
      rlink: "../Tutorials/DataCards"
    - rtitle: "Sampling, Temperature, and Generation"
      rlink: "../Tutorials/SamplingAndTemperature"
    - rtitle: "Evaluating Agent Outputs Activity: the evaluation harness, and the Part IIb benchmark-design work that Part 5 finishes"
      rlink: "Activities/liascript-evaluatingoutputs.md"
      liapage: true
    - rtitle: "Multimodal Agents"
      rlink: "../Tutorials/MultimodalAgents"
    - rtitle: "Testing Agents: Evaluation, Regression, and the Non-Determinism Problem (required prep for the Rubric Pipeline Lab, which picks up the Part 5 harness)"
      rlink: "../Tutorials/TestingAgents"
    - rtitle: "promptfoo, for declarative LLM and agent evaluation.  One of the Part 5 harness options, and it runs against Ollama"
      rlink: "https://www.promptfoo.dev/"

tags:
  - rag
  - embeddings
  - local-ai
  - fine-tuning
  - lora
  - local-models
  - evaluation
  - multimodal
  - simulation
  - visualization

---

In this lab, you and your partner build a question-answering system over a corpus that matters to you: your own course notes, a student organization's documents, a hobby wiki you maintain, or a set of public campus documents.  The system answers with citations when the corpus supports an answer and says so honestly when it does not.  Once it runs, you check it in Part 5 with a golden set of ten questions, a worksheet of real measurements from your own pipeline, and a regression harness you will rerun in the Rubric Pipeline lab.  This is a **pair lab**: driver and navigator, a swap at least every 30 minutes, and a swap log you turn in.

---

## Choose Your Path

Decide before you install anything.  Core Part 1 (corpus and datasheet), core Part 4 (the citation audit by hand), and Part 5 (the checkup pathway) are required on every path; between them they carry most of the judgment this lab is about.  The path decides only how you build Parts 2 and 3.

| Path | What you build | What you need | Pick this if |
|------|----------------|---------------|--------------|
| **Code** | Parts 2-3 in Python: a Chroma index with two chunkers, a grounded query function with bracketed citations and abstention, every parameter in `config.json` | `chromadb`, `sentence-transformers`, `requests`, Ollama with `llama3.2` | You want the Python harness you will extend in the Rubric Pipeline lab, and you then choose Direction 1 or 2 |
| **No-code** | The same pipeline on a Langflow canvas (Direction 0, the low-code route): two flows that differ only in splitter settings, exported flow JSON as your configuration | Langflow, Ollama with `llama3.2` and `nomic-embed-text` | You would rather put your attention on the audit than on plumbing; Direction 0 replaces the coding of Parts 2-3 and is your direction |

The rubric is the same on both paths: a pipeline earns each row whether it is hand-coded or built as a flow.

---

## Before You Start

Complete these activities before writing any code:

- [RAG Activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-rag.md): the index, retrieve, generate pipeline
- [RAG Quality: Chunking and Measuring Retrieval]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-ragquality.md): recall@k, faithfulness, and abstention

Install the tools (the code path needs all three; the no-code path installs Langflow in Direction 0 instead):

```bash
pip install chromadb                # Chroma vector database (pure Python, no server needed)
pip install sentence-transformers   # local embeddings, no API key
pip install requests                # HTTP calls to Ollama
```

Then run one health check.  Each `python -c` line imports a library and prints a word if the import worked; the last one asks the Ollama server for its model list.

```bash
python -c "import chromadb; print('chromadb ok')"
python -c "from sentence_transformers import SentenceTransformer; print('sentence_transformers ok')"
python -c "import requests; r = requests.get('http://localhost:11434/api/tags'); print('ollama ok' if r.ok else 'ollama NOT running')"
```

```text
chromadb ok
sentence_transformers ok
ollama ok
```

If you see `ollama NOT running`, start the server with `ollama serve` in a separate terminal.

> **Time budget.**  This lab runs across a multi-week window (see the course schedule).  Get the core pipeline working early, and front-load if a break falls inside your window, so the direction, the audit, and Part 5 are not compressed into the final days.
> - Core Parts 1-4 (corpus and datasheet; indexing; grounded generation; citation audit): 4-5 hours
> - Your chosen direction: 3-5 hours
> - Part 5, the RAG Quality Checkup pathway: 3-4 hours, most of it in class
> - Writeup, learning log, and packaging: included above
> - **Total: about 11-14 hours.**  Direction 0 is 7-9 hours on its own, but it replaces the coding of Parts 2-3 rather than adding to it, so core plus direction stays about 8-10 hours.

---

## Part 1: Curate and Document Your Corpus (datasheet, Writeup row)

Assemble at least 15 documents or pages (markdown, text, or extracted PDF text) and write a half-page datasheet about them.  **Do not use any document containing another person's private information.**  If your corpus involves anything sensitive, the local-only nature of this pipeline is your friend, and your writeup must say so explicitly.

### Step 1.1: Collect Your Documents

Good corpus ideas: your notes from another class (15 or more lecture note files), a student club's public meeting minutes, Wikipedia articles on a hobby you know well (so you can verify answers), or Ursinus College's public web pages saved as text.

> **Do this.**
> 1. Create a folder named `corpus/` in your lab repository and put every file in it as plain text or markdown.
> 2. If some sources are PDFs, put them in `corpus_pdfs/` and extract their text with the script below (`pymupdf` reads the embedded text of each page).

```bash
pip install pymupdf
python -c "
import fitz, pathlib
for pdf in pathlib.Path('corpus_pdfs').glob('*.pdf'):
    doc = fitz.open(pdf)
    text = '\n'.join(page.get_text() for page in doc)
    pathlib.Path('corpus/' + pdf.stem + '.txt').write_text(text)
    print(f'Extracted {pdf.name}: {len(text)} chars')
"
```

> **If it fails.**
> - Garbled text from a scanned PDF: `pymupdf` only extracts embedded text.  Use `pip install pytesseract` with Tesseract OCR, or choose different sources.
> - Encoding errors when reading: always open files with `encoding="utf-8", errors="replace"`.

### Step 1.2: Verify Your Corpus Size

> **Do this.** Run this count from your repository root.  It lists every `.txt` and `.md` file in `corpus/` and adds up their sizes.

```bash
python -c "
import pathlib
files = list(pathlib.Path('corpus').glob('*.txt')) + list(pathlib.Path('corpus').glob('*.md'))
total_chars = sum(f.stat().st_size for f in files)
print(f'Files: {len(files)} | Total characters: {total_chars:,}')
"
```

> **You should see.** One line like `Files: 18 | Total characters: 142,350` (your numbers will differ).  You need at least 15 files.  If you have fewer, Wikipedia is a reliable fallback: `pip install wikipedia-api` and download 15 or more related articles.

### Step 1.3: Write Your Corpus Datasheet

> **Do this.** In your readme, answer these in prose (about half a page):
> 1. **Sources**: where each document came from, with URL or file path.
> 2. **Time range**: when the documents were written or last updated.
> 3. **Who and what is represented**: the topics, people, or events that appear.
> 4. **Who and what is absent**: related topics not covered, and who would find this corpus unhelpful.
> 5. **Known limitations**: documents that are incomplete, low-quality, or possibly outdated.

> **Checkpoint.** Before Part 2, make sure you can answer:
> 1. How many documents are in your corpus, and what is their total character count?
> 2. Name one topic your corpus covers well and one topic a user might ask about that it cannot answer.  You will use both in Part 3.
> 3. What does your datasheet reveal about blind spots in the answers your system will give?

---

## Part 2: Index with Two Chunking Strategies (Chunking Strategy row, 12%)

A chunk is the unit of text you embed and retrieve, and its size decides whether an answer arrives whole or in pieces.  You implement two chunking strategies (fixed-size with overlap, and paragraph-structural), keep the parameters in a JSON file rather than in code, build a question set of at least ten questions with hand-located answers, and report recall@k for $$k \in \{1, 3, 5\}$$ under both strategies.

> **No-code path.** Build this part as Direction 0, Parts B and C: two Langflow flows that differ only in the Text Splitter settings, measured on the same ten questions.  The requirements in this part still apply.

### Step 2.1: Create Your Configuration File

> **Do this.** Create `config.json` in your repository root.  Model name, chunk size, overlap, top-k, and the abstention phrase live here, never in the code.

```json
{
  "corpus_dir": "corpus",
  "model": "llama3.2",
  "embed_model": "all-MiniLM-L6-v2",
  "temperature": 0.1,
  "seed": 42,
  "top_k": 3,
  "abstention_phrase": "I don't have enough information in my knowledge base to answer that.",
  "chunking": {
    "strategy": "fixed",
    "chunk_size": 500,
    "overlap": 50
  }
}
```

### Step 2.2: Implement the Two Chunkers

> **Do this.** Create `rag.py` and add both functions.  Each returns a list of `(chunk_text, position)` tuples.

```python
def chunk_fixed(text, chunk_size=500, overlap=50):
    """Split text into overlapping fixed-size chunks. Returns (chunk_text, start_char) tuples."""
    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_size
        chunks.append((text[start:end], start))
        start += chunk_size - overlap
    return chunks

def chunk_by_paragraph(text, min_size=100, max_size=1000):
    """Split on blank lines, merging short paragraphs until min_size. Returns (chunk_text, paragraph_index) tuples."""
    raw_paragraphs = [p.strip() for p in text.split("\n\n") if p.strip()]
    chunks = []
    current = ""
    idx = 0
    for para in raw_paragraphs:
        current = (current + "\n\n" + para).strip() if current else para
        if len(current) >= min_size:
            chunks.append((current[:max_size], idx))
            current = current[max_size:]
            idx += 1
    if current:
        chunks.append((current, idx))
    return chunks
```

### Step 2.3: Build the Chroma Index

An embedding is a vector of numbers that places a piece of text so that similar meanings land near each other.  `build_index` chunks every document, embeds each chunk with a local model, and stores the vectors in a Chroma collection named for the strategy.

> **Do this.** Add this to `rag.py`.  The exception handlers around network, embedding, and database calls are a rubric requirement: each prints a located message such as `[lab2:build_index]` and a traceback.

```python
import chromadb
from sentence_transformers import SentenceTransformer
import pathlib
import json
import traceback

def build_index(config, strategy="fixed"):
    """Load corpus_dir, chunk, embed, and store in Chroma. Returns (collection, embed_model, chunk_metadata_list)."""
    try:
        embed_model = SentenceTransformer(config["embed_model"])
        client = chromadb.Client()
        collection_name = f"lab2_{strategy}"
        try:
            client.delete_collection(collection_name)   # start clean on every rerun
        except Exception:
            pass
        collection = client.create_collection(collection_name)

        all_chunks, all_ids, all_metadatas = [], [], []
        corpus_path = pathlib.Path(config["corpus_dir"])
        doc_files = list(corpus_path.glob("*.txt")) + list(corpus_path.glob("*.md"))
        for doc_file in doc_files:
            text = doc_file.read_text(encoding="utf-8", errors="replace")
            if strategy == "fixed":
                cfg = config["chunking"]
                chunks = chunk_fixed(text, cfg["chunk_size"], cfg["overlap"])
            else:
                chunks = chunk_by_paragraph(text)
            for i, (chunk_text, position) in enumerate(chunks):
                all_chunks.append(chunk_text)
                all_ids.append(f"{doc_file.stem}_{strategy}_{i}")
                all_metadatas.append({"source": doc_file.name, "position": position, "strategy": strategy})

        all_embeddings = []
        batch_size = 64                                  # embed in batches to limit memory use
        for i in range(0, len(all_chunks), batch_size):
            all_embeddings.extend(embed_model.encode(all_chunks[i:i+batch_size]).tolist())
            print(f"  Embedded {min(i+batch_size, len(all_chunks))}/{len(all_chunks)} chunks")

        collection.add(documents=all_chunks, embeddings=all_embeddings, ids=all_ids, metadatas=all_metadatas)
        print(f"Indexed {len(all_chunks)} chunks using strategy='{strategy}'")
        return collection, embed_model, list(zip(all_ids, all_chunks, all_metadatas))
    except Exception as e:
        print(f"[lab2:build_index] {e}")
        traceback.print_exc()
        raise
```

> **You should see.** Progress lines, then a total:

```text
  Embedded 64/312 chunks
  Embedded 128/312 chunks
  ...
  Embedded 312/312 chunks
Indexed 312 chunks using strategy='fixed'
```

> **If it fails.**
> - `ValueError: Embedding function is required`: you pass embeddings yourself in `collection.add`, so do not also pass `embedding_function` when creating the collection.
> - The `all-MiniLM-L6-v2` download (about 80 MB) is slow: pre-download on a fast connection with `python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"`.  It is cached afterward.

### Step 2.4: Write Ten Questions with Hand-Located Answers

Before running any retrieval, find each answer yourself in the corpus and record the file and a short snippet that appears in the answering chunk.  This is your ground truth, and the retriever's output must not anchor it.

> **Do this.** Create `question_set.py`.  Cover different documents, and mark at least two questions your corpus cannot answer with `"unanswerable": True` for Part 3's abstention test.

```python
# question_set.py
QUESTIONS = [
    {
        "id": "Q01",
        "question": "What is the main topic covered in lecture 3?",
        "answer_in_source": "lecture03.txt",       # file where the answer lives
        "answer_text_snippet": "gradient descent"  # short string that appears in the answer chunk
    },
    # TODO: Add Q02 through Q10 covering different documents
    # Include at least 2 questions your corpus CANNOT answer (for abstention testing in Part 3)
]
```

### Step 2.5: Compute recall@k for Both Strategies

Recall@k is the fraction of answerable questions whose ground-truth snippet appears somewhere in the top `k` retrieved chunks.  A higher number means the retriever is putting the right chunk in front of the model more often.

> **Do this.** Add `recall_at_k` to `rag.py` and run the loop at the bottom with `python3 rag.py`.

```python
from question_set import QUESTIONS

def recall_at_k(collection, embed_model, questions, k=3):
    """Fraction of answerable questions whose snippet appears in the top-k retrieved chunks."""
    hits = 0
    for q in questions:
        if q.get("unanswerable"):
            continue  # abstention questions do not count toward recall
        query_embedding = embed_model.encode([q["question"]]).tolist()
        results = collection.query(query_embeddings=query_embedding, n_results=k)
        retrieved_docs = results["documents"][0]
        if any(q["answer_text_snippet"].lower() in doc.lower() for doc in retrieved_docs):
            hits += 1
    answerable = [q for q in questions if not q.get("unanswerable")]
    return hits / len(answerable) if answerable else 0.0

if __name__ == "__main__":
    config = json.load(open("config.json"))
    for strategy in ["fixed", "paragraph"]:
        print(f"\nStrategy: {strategy}")
        collection, embed_model, _ = build_index(config, strategy=strategy)
        for k in [1, 3, 5]:
            print(f"  recall@{k} = {recall_at_k(collection, embed_model, QUESTIONS, k=k):.2f}")
```

> **You should see.** Six numbers (yours will differ):

```text
Strategy: fixed
  recall@1 = 0.50
  recall@3 = 0.80
  recall@5 = 0.90

Strategy: paragraph
  recall@1 = 0.60
  recall@3 = 0.70
  recall@5 = 0.80
```

> **Paste into your submission.** Put these six numbers in a table in your readme and defend the strategy you ship with a specific numeric comparison ("fixed reaches recall@3 of 0.80 versus 0.70 for paragraph on our question set").  Then set `"strategy"` in `config.json` to the winner.

> **If it fails.** `recall@1 = 0.0` everywhere under fixed chunking usually means `chunk_size` is too small and answers are split across chunks; try 800 or 1000.  Also confirm each `answer_text_snippet` really appears in its file: `grep -n "your snippet" corpus/yourfile.txt`.

> **Checkpoint.** Before Part 3, make sure you can answer:
> 1. What is a vector embedding, and why is it more useful for semantic search than exact keyword matching?
> 2. How many chunks did your corpus produce under each strategy?  Why might one strategy produce more than the other?
> 3. What happens if you query the collection before adding any documents?  Test it and record the error.

---

## Part 3: Generate Grounded Answers (Pipeline Implementation row, 15%)

The query path embeds the question, retrieves the top-k chunks, and assembles a prompt that tells the model to answer **only** from that context, to cite bracketed source numbers, and to reply with the designated abstention phrase when the context is insufficient.  You demonstrate five answered questions with correct citations, two abstentions, and one before/after comparison where the bare model hallucinates and your system answers correctly or abstains.  The Code Quality row (5%) is earned here and in Part 2: docstrings on every non-trivial function, located exception handlers, and no hardcoded parameters.

> **No-code path.** Build this part as Direction 0, Part D: the Prompt node carries the same rules, and the playground transcripts are your demonstration.

### Step 3.1: Implement the Query-and-Generate Function

> **Do this.** Add `query_rag` to `rag.py`.  The numbered `[i]` labels in the context are what the model cites.

```python
import requests

def query_rag(question, collection, embed_model, config, ollama_url="http://localhost:11434/api/chat"):
    """Retrieve top-k chunks, build a grounded prompt, and generate. Returns (answer_text, retrieved_chunks_with_metadata)."""
    q_embedding = embed_model.encode([question]).tolist()
    k = config["top_k"]
    results = collection.query(query_embeddings=q_embedding, n_results=k)
    chunks = results["documents"][0]
    metadatas = results["metadatas"][0]

    context_parts = []
    for i, (chunk, meta) in enumerate(zip(chunks, metadatas), start=1):
        context_parts.append(f"[{i}] (source: {meta['source']})\n{chunk}")
    context = "\n\n".join(context_parts)
    abstention_phrase = config["abstention_phrase"]

    system_prompt = f"""You are a helpful assistant that answers questions strictly from the provided context.

RULES:
1. Answer ONLY using information from the numbered context passages below.
2. Cite the source number in brackets after every claim, like this: "The sky is blue [1]."
3. If the context does not contain enough information to answer the question, respond with exactly:
   {abstention_phrase}
4. Do not add information from your training data. Do not speculate.

CONTEXT:
{context}"""

    payload = {
        "model": config["model"],
        "messages": [{"role": "system", "content": system_prompt}, {"role": "user", "content": question}],
        "stream": False,
        "options": {"temperature": config["temperature"], "seed": config["seed"]}
    }
    try:
        response = requests.post(ollama_url, json=payload, timeout=60)
        response.raise_for_status()
        answer = response.json()["message"]["content"]
    except Exception as e:
        print(f"[lab2:query_rag] {e}")
        traceback.print_exc()
        raise
    return answer, list(zip(chunks, metadatas))
```

### Step 3.2: Answer Five Questions with Citations

> **Do this.** Create `demo.py` with the three runs in Steps 3.2 through 3.4 and run it with `python3 demo.py`.  Build the index with the strategy you chose in Part 2.

```python
# demo.py
import json
from rag import build_index, query_rag
from question_set import QUESTIONS

config = json.load(open("config.json"))
collection, embed_model, _ = build_index(config, strategy=config["chunking"]["strategy"])

answerable_questions = [q for q in QUESTIONS if not q.get("unanswerable")][:5]
for q_item in answerable_questions:
    print(f"\nQ: {q_item['question']}")
    answer, retrieved = query_rag(q_item["question"], collection, embed_model, config)
    print(f"A: {answer}")
    print(f"Retrieved from: {[m['source'] for _, m in retrieved]}")
```

> **You should see.** Five blocks shaped like this, each with at least one bracketed citation:

```text
Q: What is the main topic covered in lecture 3?
A: Lecture 3 covers gradient descent and its role in optimizing neural network weights [1].
Retrieved from: ['lecture03.txt', 'lecture02.txt', 'lecture04.txt']
```

### Step 3.3: Abstain on Two Questions

> **Do this.** Add this to `demo.py`.

```python
unanswerable = [q for q in QUESTIONS if q.get("unanswerable")][:2]
for q_item in unanswerable:
    print(f"\nQ: {q_item['question']}")
    answer, _ = query_rag(q_item["question"], collection, embed_model, config)
    print(f"A: {answer}")
    print(f"Abstained correctly: {config['abstention_phrase'] in answer}")
```

> **You should see.**

```text
Q: What year was the Ursinus College library built?
A: I don't have enough information in my knowledge base to answer that.
Abstained correctly: True
```

> **If it fails.** Smaller models sometimes answer from training data anyway.  Make the instruction more direct ("You MUST respond with exactly that phrase and nothing else if the context is insufficient").  If it still fails, add a post-processing check: if the answer has no `[1]`-style bracket and no abstention phrase, replace it with the abstention phrase and log a warning.

### Step 3.4: Show the Bare-Model Hallucination Contrast

> **Do this.** Add `query_bare_model` to `demo.py` and ask the bare model (no context) a question your RAG system answered correctly.  Include the comparison verbatim in your readme.

```python
import requests

def query_bare_model(question, config, ollama_url="http://localhost:11434/api/chat"):
    """Ask the model with no retrieved context, for the before/after contrast."""
    payload = {"model": config["model"], "messages": [{"role": "user", "content": question}], "stream": False,
               "options": {"temperature": config["temperature"], "seed": config["seed"]}}
    r = requests.post(ollama_url, json=payload, timeout=60)
    return r.json()["message"]["content"]

example_q = answerable_questions[0]["question"]
print(f"Question: {example_q}")
print(f"\nBare model answer:\n{query_bare_model(example_q, config)}")
print(f"\nRAG answer:\n{query_rag(example_q, collection, embed_model, config)[0]}")
```

> **You should see.** A bare answer that is confident and wrong (or invented) next to a RAG answer that is cited or abstains.  If the bare model happens to be right, pick another question; the contrast is the deliverable.

> **If it fails.**
> - The model cites `[1]` but the wrong chunk: a retrieval problem, not a generation problem.  If Part 2's recall@3 is below 0.5, raise `top_k` to 5 or switch strategy.
> - The answer is cut off mid-sentence: the context overflows the model's window.  Lower `top_k` to 2 or `chunk_size`, or add `"num_ctx": 4096` to the Ollama `options`.

> **Checkpoint.** Before Part 4, make sure you can answer:
> 1. What does the RULES section of the system prompt do to prevent hallucination?  What would happen if you removed Rule 4?
> 2. In your before/after comparison, what specific false claim did the bare model make, and what training-data pattern likely caused it?
> 3. How would you support a follow-up question ("Tell me more about that") while keeping citation grounding?

---

## Part 4: Audit Your Citations by Hand (Evaluation and Citation Audit row, 13%)

For at least ten answered questions, read the chunk each citation points to and decide whether it supports the claim.  Report a **faithfulness rate** (the fraction of audited citations whose chunk supports the claim) and show every failure verbatim, classified with the hallucination taxonomy from class.  This part is required on every path; on Direction 0, use the playground's node-inspection view to read the cited chunk.

### Step 4.1: Build the Audit Table

> **Do this.** In your readme, record one row per audited citation:

| Q# | Answer excerpt and citation | Chunk cited | Faithful? | Failure type |
|----|-----------------------------|-------------|-----------|--------------|
| Q01 | "Gradient descent is ..." [1] | "lecture03: Gradient descent is a method..." | Yes | - |
| Q02 | ... | ... | No | Fabrication |

### Step 4.2: Classify Failures with the Taxonomy

> **Do this.** Label each unfaithful citation with one of the four categories from class:
> - **Fabrication**: the cited chunk exists but does not contain the claimed fact; the model invented it.
> - **Conflation**: the cited chunk is about a related but different topic; the model merged two concepts.
> - **Extrapolation**: the chunk implies but does not state the claim; the model over-inferred.
> - **Wrong citation**: the fact is correct and in the corpus, but in a different chunk than the one cited.  Count it as a failure, but classify it accurately: the answer may be right even though the number is wrong.

### Step 4.3: Compute the Faithfulness Rate

> **Do this.** Create `audit.py`, fill it from your table, and run `python3 audit.py`.

```python
# audit.py - fill this in from your hand-audit table
audit_results = [
    {"q_id": "Q01", "faithful": True, "failure_type": None},
    {"q_id": "Q02", "faithful": False, "failure_type": "Extrapolation"},
    # ... add all 10
]

faithful_count = sum(1 for r in audit_results if r["faithful"])
print(f"Faithfulness rate: {faithful_count}/{len(audit_results)} = {faithful_count/len(audit_results):.1%}")
for f in [r for r in audit_results if not r["faithful"]]:
    print(f"  {f['q_id']}: {f['failure_type']}")
```

> **You should see.** One line such as `Faithfulness rate: 9/10 = 90.0%` followed by one line per failure.  Put the table and the rate in your readme.

> **If it fails.**
> - Every citation is faithful and the audit feels trivial: add at least two questions that need information from two chunks; those produce conflation and extrapolation errors.
> - You cannot find a cited chunk: `collection.get(ids=["chunk_id"])` fetches one by ID; the IDs are in the `metadatas` list `query_rag` returns.

> **Checkpoint.** Before Part 5, make sure you can answer:
> 1. What was your faithfulness rate, and is it higher or lower than you expected?
> 2. Which failure type appeared most often, and what does that suggest about where to add safeguards?
> 3. Which did you find more often overall: retrieval fetching the wrong chunk, or generation misusing a correct chunk?

---

## Part 5: Run the RAG Quality Checkup (three Quality Checkup rows, 50%)

Part 5 is a structured checkup on the pipeline from Parts 2 through 4, in three steps: design a **golden set** (ten questions with expected answers and a stated scoring rule, five that should be easy for your model and five that should not), complete a checkup worksheet with measurements from your own pipeline, and freeze both into a regression harness (a fixed test you can rerun after any change and compare against the last run).  It sits mid-window on purpose: your pipeline is running by then and not yet due, which is the only point in the term when a diagnostic can still change what you build.

The metrics (recall@k, citation faithfulness, abstention) come from *RAG Quality: Chunking and Measuring Retrieval*.  Do most of the worksheet in the open studio in *How I AI* (Part III) with your pipeline-in-progress in front of you.  The harness follows you forward: the Rubric Pipeline lab starts from it, and Evaluation Workshop II runs your judge against your own project work.  Most of Part 5 is evaluation work Parts 2 through 4 ask for anyway, done earlier and under supervision; the harness is the one forward investment.  Work on your pair's own pipeline and corpus, and keep the swap log going.

### Before You Start Part 5

This builds on the *Hallucinations and Evaluating Agent Outputs* session, where we mapped the territory where models are unreliable and wrote the evaluation harness that Step 5a starts from; the *RAG Quality* session; and your in-progress pipeline.  You do not need Parts 2 through 4 finished; you need the pipeline *running*, even badly.  A pipeline that answers poorly is a better subject for a checkup than one that does not answer at all.

> **Bring to class.**
> - Your lab repository, cloned and runnable.
> - Your corpus indexed, with at least one chunking configuration working end to end.
> - Any benchmark questions you sketched in the *Hallucinations and Evaluating Agent Outputs* session (Part IIb and its Exercise 1).  Step 5a turns them into a finished ten-item set; if you have none, start there.
> - Five questions you care about the answers to, drawn from your own corpus.

Sanity check before you arrive: your pipeline answers one question, however badly.  On Direction 0, the equivalent is one question answered in the Langflow playground.

```bash
python3 ask.py "a question your corpus should be able to answer"
```

> **Time budget.** Step 5a is about one hour, most of it judgment rather than typing, and it is meant to be done before the studio: it needs no running pipeline, and doing it early is the single best way to make the studio productive.  Steps 5b and 5c are the studio session plus an hour or two of finishing on your own; 5c goes quickly because your golden set already exists.  If 5a runs past an hour you are polishing: ten adequate items beat six perfect ones.

If your pipeline is not running, come anyway and say so at the start.  Debugging it *is* the studio, and the checkup works on a pipeline you got running at 12:20.

### Choose Your Part 5 Route

Same rubric, same credit.  Step 5a is identical on every route: designing ten good items is the assignment, and the file format is a detail.  The judgment in the rest of Part 5 (which configuration wins, which citations are real, what the failure means) is identical too; the routes differ only in how you collect and rerun the numbers.  Pairs on Direction 0 usually take the no-code or low-code route; pairs who coded Parts 2 and 3 usually take the code route.  Any combination is allowed.

| Route | Golden set and harness | How you measure | Pick this if |
|-------|------------------------|-----------------|--------------|
| **No-code** | A spreadsheet, one row per item (`question`, `expected`, `rule`, `rationale`); the harness is a **run sheet** with the pinned questions, pinned settings, and a dated results column per run (rerunning means working the sheet again and comparing columns) | Query both configurations by hand in **Open WebUI's** knowledge-base interface or in your two Langflow flows, and record hits and misses | You built Parts 2-3 in Langflow (Direction 0), or you want your attention on the citation audit rather than on plumbing |
| **Low-code** | A `promptfoo` YAML case list, with the golden set as cases and `temperature: 0` pinned | By hand as above, or a small promptfoo run against your retriever | You expect to take the Rubric Pipeline lab's promptfoo direction |
| **Code** | `goldenset.json`; the harness is a Python script grown from the class evaluation harness | A loop over your five queries that prints retrieved chunk IDs, scored against your own relevance judgments (Part 2's `recall_at_k` is a natural start) | You coded Parts 2-3 and want the harness you will extend in the Rubric Pipeline lab |

> **Watch out.** The no-code route is not the shortcut.  Measuring recall@k by hand means you look at every retrieved chunk, which is exactly how people discover that their retriever returned the right document and the wrong *part* of it.  A script that prints `recall@5 = 0.6` hides that.  The same holds in Step 5a: running ten items by hand means you read every answer closely, which is what catches a *metric failure*, where your rule mis-graded a correct answer.  Students on the code route often miss those because the harness printed FAIL and they believed it.

### Step 5a: Design Your Golden Set

Before you can tell whether your pipeline is any good, you need a fixed set of questions with known answers.  Each item has four fields: `question`; `expected` (the answer text your scoring rule matches); `rule` (exact, substring, or normalized match, your choice per item, stated); and `rationale` (one sentence predicting whether the model will pass and *why*, reasoned from training data: how recent, how local, how specific, how citation-shaped the fact is).

These ten items are about the **model**, not yet about your corpus.  Step 5c extends the set with corpus-specific questions, and the gap between how the bare model does on the fragile five and how the same model does with your retrieved chunks in front of it is the entire argument for having built a RAG pipeline.  Part 3 makes that argument on one question; the golden set makes it on ten.

> **Do this.**
> 1. Write five **expected-reliable** items first: stable, well-documented knowledge (famous dates, authors, capitals, definitions).  They calibrate your sense of what an unambiguous `expected` looks like.
> 2. Write five **expected-fragile** items, spread across the four kinds of thin territory the *Hallucinations* session mapped, at least one of each: **local** or niche facts, **post-cutoff** events, **exact statistics**, and a **citation-shaped** request (a source, reference, or attribution).
> 3. Choose each item's `rule` **last**, after you know what a correct answer looks like.  Could a fully correct answer fail this rule?  Could a wrong answer pass it?
> 4. Write every rationale as a prediction plus a reason.  The prediction is what Step 5c grades you against.

Two worked items.  Notice that each rationale names a reason from the training data (thick, thin, recent, local, changing) and commits to a prediction before the run.  "This seems hard" earns the `beginning` row; "the data would be thin here because..." earns `proficient`.

```json
{
  "question": "In what year was the Declaration of Independence signed?",
  "expected": "1776",
  "rule": "substring",
  "rationale": "Expect PASS. This date appears in a vast number of training documents in exactly this form, so it is about as thick as training data gets. Substring matching is safe because any correct phrasing contains the four digits."
}
```

```json
{
  "question": "Which building houses the Ursinus College mathematics and computer science department, and what are its office hours?",
  "expected": "Pfahler Hall",
  "rule": "substring",
  "rationale": "Expect FAIL on the second half. The building name may appear in a handful of pages; the office hours almost certainly appear nowhere, and they change every term. I predict a confident, invented answer, which is exactly the failure mode worth catching."
}
```

> **Checkpoint.** You have succeeded when you have ten items, each with all four fields, and a classmate reading only your rationales could predict your pass rate to within two items.

### Step 5b: Complete the Checkup Worksheet

Complete `checkup.md` against your in-progress pipeline, with your Part 5 route named at the top.  Three measurements, in this order.

**Measurement 1: retrieval quality.** For five queries representative of your corpus, measure recall@k under your current chunking configuration and one alternative (a different chunk size or overlap), name the winner, and carry the winning configuration back into your Part 2 config.  Here recall is measured against *your* reading: for each query you decide which chunks contain the answer (the relevant chunks), ask the retriever for its top `k`, and count how many relevant ones came back.  Part 2's `recall_at_k` approximates that judgment with a snippet match; this measurement replaces the approximation with your own reading, on five queries, at one `k`.

> **Do this.**
> 1. Fix `k` (5 is a reasonable default) and **do not change it** between configurations.  Comparing recall@5 against recall@10 tells you nothing.
> 2. For each of the five queries, read your corpus and write down which chunks *should* come back, **before** you run the retriever, so its answers do not anchor your judgment.
> 3. Run all five under configuration A and record which relevant chunks appeared in the top `k`.
> 4. Change exactly **one thing** (chunk size or overlap, not both), re-index, and run the same five.
> 5. Fill in the table and name the winner.

Worked row, so the format is unambiguous:

| Query | Relevant chunks (my judgment) | Config A (512/50): retrieved, recall@5 | Config B (256/25): retrieved, recall@5 |
|---|---|---|---|
| "What is the late policy for a three-day extension?" | c14, c15 | c14, c22, c31, c07, c19; 1/2 = 0.50 | c14, c15, c22, c31, c07; 2/2 = 1.00 |

Config A retrieved `c14` and stopped; the policy spanned two chunks, and the 512-token chunking put the second half of the sentence in a chunk that scored just below the cut.  That is a *chunking* failure that looks like a *retrieval* failure, and it is the single most common thing this checkup finds.

> **Checkpoint.** You have a five-row table with the same `k` in both columns, a named winner, and one sentence explaining *why* the winner won that refers to your corpus rather than to general principle.

**Measurement 2: citation audit.** For five answered queries, one row each: the answer's central claim, the chunk it cites, and your verdict.  Part 4's ten-row audit with the class taxonomy is the full version; these five rows are the same muscle, built early.

> **Do this.**
> 1. Ask your pipeline five questions and capture the full answer plus whatever it offered as a citation.
> 2. Write the answer's **single central claim** in your own words, in one sentence.  If you cannot state one, record "no single claim" and say why; that is a finding.
> 3. Open the cited chunk and read it.  Not the document; the chunk.
> 4. Verdict: **supported** if the claim is in there, **unsupported** if not, and **partial** if the chunk supports a weaker version than the answer stated.  Add the partial column; it is where most real systems live.

> **Watch out.** A "partial" is the interesting finding.  The chunk says the extension is available "with prior permission"; the answer says students "may take a three-day extension."  Everything in the answer traces to the chunk, and a condition has quietly dropped.  No retrieval metric catches that.  You do.

> **Checkpoint.** You have five rows with verdicts, and at least one row where the verdict required reading the chunk rather than pattern-matching a phrase.

**Measurement 3: one failure.** Capture one concrete misbehavior you observed (a wrong retrieval, an unsupported citation, a failed abstention) with the query, the output, a one-paragraph hypothesis for the mechanism, and your planned fix.  A hypothesis is not a complaint: "the model hallucinated" is a complaint.  A hypothesis names the stage that failed and says why:

> *"The retriever returned c31 rather than c14 for this query.  Both chunks mention 'extension,' but c31 is a syllabus paragraph about deadline extensions for the project and c14 is the late-work policy.  My embedding cannot distinguish the two senses because the chunks are short enough that neither carries the surrounding context that disambiguates them.  **Fix:** increase overlap so each chunk carries its section heading, and re-measure."*

> **Checkpoint.** Your hypothesis names a *stage* (chunking, embedding, retrieval, reranking, generation) and your fix is something you could do this week.

### Step 5c: Build the Regression Harness

Freeze your evaluation so it can be rerun forever.  The point is not the code; it is that **six weeks from now you can prove a change made things better rather than believing it did.**

> **Do this.**
> 1. **Pin a golden set.** Take your 5a items and **extend** them with at least five corpus-specific questions from your own corpus.  Keep the 5a items; step 6 grades your predictions against what happened.  Include at least one question that **should trigger abstention**; a harness with no abstention case cannot tell a confident wrong answer from a right one.
> 2. **Pin the protocol.** Temperature 0.0, a fixed seed, the model name, the chunking configuration, and `k`.  Write all five at the top of the harness, not in your memory of what you did.
> 3. **Build it in your chosen medium**: a spreadsheet run sheet with a dated column per run, a promptfoo YAML case list, or a Python script grown from the class harness.
> 4. **Run it twice**, changing nothing between runs.
> 5. **Compare the two runs and show they agree.** `diff run1.txt run2.txt` on the code route; two columns side by side on the no-code route.  Paste the comparison, not a claim about it.
> 6. **Classify your misses.** A miss is any 5a item whose outcome differs from its predicted `rationale`, in *either* direction; a fragile item that passed is as interesting as a reliable one that failed.  In one sentence each, say which it was:
>    - **Knowledge failure**: the model does not have the fact.
>    - **Metric failure**: the model answered correctly (or incorrectly) and *your rule graded it wrong*, for example "seventeen seventy-six" against a substring rule looking for "1776".
>    - You may also find a third kind in a RAG pipeline, a **retrieval failure**: the model would have known the answer from the right chunk and did not get it.  Name it; it points straight back at 5b's recall numbers.
> 7. **Commit** the harness and the golden set inside your lab repository (and include them in the submission ZIP), where the Rubric Pipeline lab can pick them up.

That distinction in step 6 is why you wrote the predictions down first.  A benchmark whose failures are mostly metric failures is measuring your rules, not your system.  A worked miss, for calibration:

> **Item 7** (fragile, citation-shaped).  Predicted FAIL, outcome PASS.
>
> I asked for a source on a claim about local rainfall and expected an invented citation.  The model instead refused, saying it did not have a reliable source.  That is a **metric failure**: my rule scored "no answer" as a pass because the invented-citation string was absent, but abstention and correctness are not the same outcome and my rule cannot tell them apart.  **Revision:** split this into two items, one that scores abstention as a pass and one that scores a fabricated citation as a fail, so the two behaviors stop sharing a row.

> **If it fails.** If the two runs disagree, you have found something worth more than the points for this step.  Say so in `checkup.md` and chase it: something in your pipeline is not pinned.  Usual suspects, in order: temperature is not zero, the seed is not passed through, the index was rebuilt between runs, or your retriever ties on score and breaks the tie differently each time.  Report what you found even if you cannot fix it today.

> **Checkpoint.** Two runs of the same golden set produce identical results, you can point at the exact lines where the protocol is pinned, and every prediction miss is explained as a knowledge failure or a metric failure.

### Troubleshooting Part 5

- **Recall@k is 1.0 for every query.** Your relevance judgments were made *after* seeing what the retriever returned.  Redo them on fresh queries, written down before you run anything.
- **Recall@k is 0.0 for every query.** Chunk IDs are not stable across re-indexing, so your judgments no longer refer to the same chunks.  Record chunk *text* alongside the ID, or re-derive judgments after the final index build.
- **Re-indexing with a new chunk size changes nothing.** The old collection is still being queried.  Delete or rename it before re-indexing (Part 2's `build_index` does this) and confirm the stored chunk count changed.
- **The pipeline answers but shows no citation.** Your prompt does not require one, or chunk IDs are not passed into the prompt.  Fix it and note it in the failure section; ungrounded answers are what this checkup exists to find.
- **Two runs disagree.** Something is unpinned.  Diagnose in this order: temperature, seed, index rebuild, score ties.
- **Everything is too slow to finish.** You are re-embedding the whole corpus per query.  Embed and store once; embed only the query per run.  If it is still slow, cut the corpus for this checkup and say you did.
- **Everything "passes" and you do not believe it.** Your `expected` strings are too short; `"1"` is a substring of almost every answer.  Lengthen them, or switch that item to exact or normalized matching.
- **A correct answer scores FAIL.** A formatting mismatch, not a knowledge gap: a **metric failure**, and a finding rather than a bug to hide.  Record it, then decide whether to normalize.
- **The model refuses instead of answering.** Abstention, a distinct outcome from right and wrong.  Your rule probably cannot distinguish it from a wrong answer.  Say so in the analysis; that observation is worth points.
- **promptfoo cannot find your provider.** The Ollama provider string is wrong or the server is down.  Use `ollama:chat:llama3.2` and confirm your model server answers first.

> **Checkpoint.** Before writing your deliverables, make sure you can answer:
> 1. Which chunking configuration won in 5b, by how much, and does your Part 2 recall@k table agree?
> 2. Where, exactly, does your harness pin temperature, seed, model, chunking configuration, and `k`?  Point at the lines.
> 3. Of your prediction misses, how many were metric failures rather than knowledge failures, and what does that say about your rules?

---

## Chunking Strategy Comparison Walkthrough

This in-class walkthrough runs three chunking strategies over one 400-word document and five test questions, with a word-frequency cosine similarity (a score between 0 and 1 measuring how much vocabulary two texts share) standing in for embeddings, so the comparison is purely about chunking.  No libraries are needed.  For real RAG you would use a local embedding model (for example `nomic-embed-text` via Ollama); word frequency works here because the test questions deliberately reuse the document's vocabulary.

### Step W.1: Create the Document and the Three Chunkers

> **Do this.** Create `chunking_compare.py` and paste in the document and the three functions.  The excerpt contains facts that span paragraph boundaries on purpose.

```python
DOCUMENT = """
The field of artificial intelligence was formally founded at the Dartmouth Conference in 1956,
where John McCarthy, Marvin Minsky, Claude Shannon, and others gathered to explore whether
machines could be made to simulate human intelligence. The participants were optimistic,
predicting that a significant portion of human intellectual activity could be replicated
within a single generation. This optimism led to substantial government funding throughout
the late 1950s and 1960s, particularly from the United States Department of Defense.

Early AI research focused on symbolic reasoning and rule-based systems. Programs like the
Logic Theorist, created by Allen Newell and Herbert Simon in 1956, could prove mathematical
theorems by manipulating symbols according to formal rules. The General Problem Solver,
which followed in 1957, attempted to model human problem-solving strategies using means-ends
analysis. These systems demonstrated that computers could perform tasks previously thought
to require human intelligence, though they struggled with the complexity of real-world problems.

The first AI winter arrived in the 1970s when researchers encountered fundamental limitations.
Minsky and Papert's 1969 book Perceptrons demonstrated mathematical limitations of single-layer
neural networks, dampening enthusiasm for connectionist approaches. Meanwhile, combinatorial
explosion made symbolic AI intractable for realistic problem sizes. Funding from DARPA and
other agencies dried up as promises went unmet, and the field entered a period of reduced
activity and skepticism known as the AI winter.

The expert systems era of the 1980s briefly revived interest. Programs like MYCIN, which
diagnosed bacterial infections and recommended antibiotics, and XCON, which configured
computer hardware for Digital Equipment Corporation, demonstrated real commercial value.
XCON alone saved DEC an estimated forty million dollars per year by the mid-1980s. These
systems encoded human expertise as thousands of if-then rules and could outperform novices
in narrow domains, but they were brittle: any question outside the rule set produced no answer.

The rise of machine learning in the 1990s and 2000s shifted the paradigm from hand-coded
rules to systems that learned patterns from data. The availability of larger datasets,
faster processors, and algorithms like support vector machines and boosting made it possible
to achieve high accuracy on tasks like handwriting recognition and email spam filtering
without explicit programming of rules. This data-driven approach would eventually culminate
in the deep learning revolution of the 2010s.
"""

def chunk_fixed_size(text: str, chunk_size: int = 300, overlap: int = 50) -> list[str]:
    """Split text into fixed-character windows with overlap."""
    chunks = []
    start = 0
    while start < len(text):
        chunks.append(text[start:start + chunk_size].strip())
        start += chunk_size - overlap
    return [c for c in chunks if c]

def chunk_by_sentence(text: str, n_sentences: int = 3, overlap: int = 1) -> list[str]:
    """Split text into groups of n_sentences, with overlap sentences between groups."""
    import re
    sentences = [s.strip() for s in re.split(r'(?<=[.!?])\s+', text.strip()) if s.strip()]
    chunks = []
    step = max(1, n_sentences - overlap)
    for i in range(0, len(sentences), step):
        group = sentences[i:i + n_sentences]
        if group:
            chunks.append(" ".join(group))
    return chunks

def chunk_by_paragraph(text: str) -> list[str]:
    """Split text on blank lines, one paragraph per chunk."""
    return [p.strip() for p in text.split("\n\n") if p.strip()]
```

### Step W.2: Add Retrieval and the Five Questions, Then Run

> **Do this.** Append the retriever, the questions, and the comparison loop, then run `python3 chunking_compare.py`.  Each question is designed to stress a different boundary.

```python
def cosine_sim(a: str, b: str) -> float:
    """Cosine similarity between two strings using word-frequency vectors."""
    words = list(set(a.split() + b.split()))
    va = [a.split().count(w) for w in words]
    vb = [b.split().count(w) for w in words]
    dot = sum(x * y for x, y in zip(va, vb))
    mag_a = sum(x * x for x in va) ** 0.5
    mag_b = sum(x * x for x in vb) ** 0.5
    return dot / (mag_a * mag_b + 1e-9)

def retrieve(chunks: list[str], query: str, top_k: int = 3) -> list[str]:
    """Return the top_k chunks most similar to query."""
    scored = [(cosine_sim(query.lower(), c.lower()), c) for c in chunks]
    return [c for _, c in sorted(scored, reverse=True)[:top_k]]

QUESTIONS = [
    # Q1: answer is contained within a single paragraph
    "Who were the founders of artificial intelligence at the Dartmouth Conference?",
    # Q2: answer requires connecting two adjacent sentences in different paragraphs
    "What mathematical limitation did Minsky and Papert demonstrate, and when?",
    # Q3: answer uses a specific number that appears mid-paragraph
    "How much money did XCON save Digital Equipment Corporation per year?",
    # Q4: answer is in the last paragraph, using different vocabulary than the question
    "What algorithmic approaches enabled high accuracy on spam filtering?",
    # Q5: answer spans a paragraph boundary between the expert systems era and ML era
    "What limitation did expert systems have compared to machine learning systems?",
]

for strategy_name, chunks in [
    ("Fixed (300 chars, overlap=50)", chunk_fixed_size(DOCUMENT)),
    ("By Sentence (3 sent, overlap=1)", chunk_by_sentence(DOCUMENT)),
    ("By Paragraph", chunk_by_paragraph(DOCUMENT)),
]:
    print(f"\n=== {strategy_name} ({len(chunks)} chunks) ===")
    for i, q in enumerate(QUESTIONS, 1):
        print(f"  Q{i}: {q[:60]}...")
        for j, r in enumerate(retrieve(chunks, q, top_k=2), 1):
            print(f"    [{j}] {r[:100].strip()}...")
```

> **You should see.** Three blocks, one per strategy, each with the chunk count in its header and the top two chunks for each of the five questions.

### Step W.3: Fill In the Results Table

> **Do this.** Mark each cell **Y** if a returned chunk actually contains the answer, **N** if not, and total the row.

| Chunking Strategy | Num Chunks | Q1 | Q2 | Q3 | Q4 | Q5 | Recall@2 |
|---|---|---|---|---|---|---|---|
| Fixed (300 chars, overlap=50) | | | | | | | /5 |
| By Sentence (3 sent, overlap=1) | | | | | | | /5 |
| By Paragraph | | | | | | | /5 |

### Walkthrough Questions

1. Fixed-size chunking sometimes splits a sentence mid-phrase.  Find one example in your table where this hurt retrieval: which question failed, and what did the returned chunks contain instead of the answer?  (Look for an answer that spans a character-boundary cut, such as chunk N ending with "the participants were" and chunk N+1 beginning "optimistic, predicting...".  Print a few boundary regions of the fixed chunks to see where cuts landed.)
2. You raise `chunk_size` from 100 to 1000 characters with `overlap=0`.  Which best describes the trade-off?
   - Fewer chunks means faster embedding but always better retrieval precision
   - Larger chunks improve the chance that a multi-sentence answer is intact in one chunk, but each chunk's embedding blurs across more topics, reducing precision for focused queries
   - Larger chunks always increase recall@k regardless of the query
   - Chunk size affects only storage cost, not retrieval quality
3. With `overlap=0` and `chunk_size=100`, a fact spanning characters 95 to 110 is split and may be incomplete in both chunks.  With `overlap=90`, that fact appears in many chunks.  What is the cost of very large overlap?  (Count the chunks a 1000-character document produces at overlap 90 versus 0; every chunk is embedded and stored, and many near-identical chunks all rank highly for the same query.)
4. Sentence-based chunking preserves meaning better than fixed-size, but sentences in legal contracts can be 200 words long and a clause can span ten of them.  What strategy would you use for legal documents, and why?  (Consider a hybrid: split structurally on numbered clauses or headings first, then apply sentence chunking inside any clause over a maximum character count.)

> **Answer.** Question 2: larger chunks improve the chance that a multi-sentence answer is intact in one chunk, but each chunk's embedding blurs across more topics, reducing precision for focused queries.  This is the Goldilocks problem: a 1000-character chunk spanning three topics must summarize all three in one vector, so it can rank below a smaller, focused chunk even when the answer is physically inside it.

> **Watch out.** Smaller is not always better.  Very small chunks lose the surrounding context the similarity function needs: a chunk containing only "the act" scores low against almost any query because nothing says which act, when, or why.  A practical lower bound is roughly one complete sentence; a practical upper bound is roughly one focused paragraph.

---

## Choose Your Direction

Everyone completes core Part 1, core Part 4, and Part 5.  Beyond that, you choose **one** direction below and do not do more than one.  Pick the one that most interests you, and carry your corpus, config discipline, and evaluation habits into it.

**Direction 0 is different in kind from the other two.** It is the low-code route through the middle of the lab itself: it **replaces the coding of core Parts 2-3** (indexing and grounded generation) with a visual Langflow build that meets the same requirements: two compared chunking configurations, recall@k, citations, and abstention.  Directions 1 and 2 are extensions you complete **after** finishing core Parts 1-4 in code.

The **single grade for this lab (200 points) covers your core RAG work, the Part 5 checkup, and your chosen direction together**; the rubric above still governs your score, and its rows credit a pipeline whether it is hand-coded or built as a flow.  Treat the "What proficient work looks like" bullets (or the deliverables list, for Direction 0) in your direction as the standard to meet, and fold your direction's deliverables into the same submission ZIP and readme as the core lab.

- **Direction 0: The Langflow Route (low-code)**: build the same RAG pipeline visually on a Langflow canvas over your own corpus, with no pipeline code authorship.  Estimated 7-9 hours, replacing core Parts 2-3.
- **Direction 1: Hands-On Fine-Tuning with LoRA and QLoRA**: bake domain knowledge into the weights instead of retrieving it at query time, and decide from evidence whether that was worth it compared to your RAG pipeline.  GPU, free-Colab, or provided-adapter paths.
- **Direction 2: Multimodal AI and Monte Carlo Simulation**: turn from text to images, and probe where a multimodal model reads a chart confidently but wrongly, using a simulation you build as ground truth.  Fully local and free (about a 4.7 GB model pull).

---

## Direction 0: The Langflow Route (low-code)

You build the same pipeline the core lab specifies (your corpus chunked and embedded into Chroma, retrieved, and answered with citations and abstention), but you wire components on a Langflow canvas instead of authoring Python.  The requirements do not soften: two chunking configurations compared empirically, recall@k reported, grounding and abstention forced, citations audited by hand.  What changes is the medium.  Core Part 1 and core Part 4 stay required and unchanged; use your flow's answers as the Part 4 audit material.  The writeup expectations are the core lab's.

> **What this direction requires.**
> - **Accounts:** none.
> - **API costs:** none; the flow runs entirely against your local Ollama server.
> - **Installs / disk:** Langflow (`pip install langflow`, or `uv pip install langflow` for a faster install; expect roughly five minutes and a couple of GB of dependencies), plus the `nomic-embed-text` embedding model in Ollama (about a 270 MB pull).
> - **Hardware:** any machine that runs the core lab.
> - **No-cost fallback:** this *is* the no-cost, low-code route.

**Estimated time: 7-9 hours**, in place of core Parts 2-3, so the lab total stays about 8-10 hours.  Background: the [Visual Agent Building with Langflow activity]({{ site.baseurl }}/Tutorials/VisualAgents), especially Part IV's hands-on build; this direction extends that 30-minute build to the full lab standard.

### Step A: Install and Launch Langflow

> **Do this.**
> 1. Install and start Langflow.  The first launch is slow; wait for the "Langflow is running" banner, then browse to `http://localhost:7860`.
> 2. Pull the embedding model your flow will use.
> 3. Confirm Ollama is running: `ollama list` should show `llama3.2` and `nomic-embed-text`.  Every model component in your flow points at `http://localhost:11434`.

```bash
pip install langflow        # or: uv pip install langflow (faster resolver)
langflow run
ollama pull nomic-embed-text
```

> **You should see.** The Langflow canvas in your browser, and `nomic-embed-text` listed by `ollama list`.

> **If it fails.**
> - A dependency-resolver error from `pip install langflow`: create a fresh virtual environment on Python 3.11 or 3.12 and install there.
> - `http://localhost:7860` refuses to connect: the server is still starting; watch the terminal for the banner.
> - A component errors with a connection refusal at runtime: its Base URL is wrong or Ollama is not running.

### Step B: Build the RAG Flow on the Canvas

> **Do this.** Create a **New Flow, Blank Canvas** and wire the pipeline over the corpus you curated in Part 1 (upload your actual corpus files, not a toy document).
> 1. **Ingest path:** **File** loader (your corpus documents) to **Text Splitter** (RecursiveCharacterTextSplitter; set the chunk size and overlap you will defend in Step C) to **Ollama Embeddings** (model `nomic-embed-text`, Base URL `http://localhost:11434`) to **Chroma** (ingest mode; name the collection and note the persist directory).
> 2. **Query path:** **Chat Input** to **Retriever** over the same Chroma collection (with **Ollama Embeddings** wired in for query embedding; set top-k to match your config) to **Prompt** node with your grounding-and-citation instructions and a `{context}` variable, to **Ollama** chat model (`llama3.2`, temperature 0.1, Base URL `http://localhost:11434`) to **Chat Output**.
> 3. Run the flow in the playground with an in-corpus question.
> 4. Record every node setting (model, chunk size, overlap, top-k, temperature) in a config notes file; this is your externalized configuration for the rubric.

Component names vary slightly across Langflow versions; the dataflow is what matters, and Part IV of the visual agents activity walks through the same wiring.

> **You should see.** An in-corpus question comes back answered with context in the playground before you move on.

### Step C: Compare Two Flow Configurations by recall@k

This is the core lab's empirical chunking requirement, on canvas.

> **Do this.**
> 1. Duplicate the flow (do not edit in place) so you have **two configurations** that differ only in the Text Splitter settings: for example 500 characters with 50 overlap versus 1,000 with 100, or a small-chunk versus large-chunk regime that mimics the fixed-versus-paragraph contrast.  Give each Chroma collection a distinct name so the two indexes cannot contaminate each other.
> 2. Take the **same ten retrieval queries** the core lab requires (ten questions whose answering chunk you located by hand in your corpus) and run all ten through **both** flows.
> 3. For each query, open the playground's inspection view (it shows each node's output; this visibility is the point of the canvas) and record whether the relevant document appeared in the top k, for k in {1, 3, 5}.
> 4. Fill in the table and defend your shipped choice with a specific numeric comparison, exactly as the rubric's chunking row requires.

Recall@k here is the count, reported as a fraction, of queries whose relevant document appears among the top k retrieved chunks.

| Configuration | recall@1 | recall@3 | recall@5 |
|---------------|----------|----------|----------|
| Flow A (chunk=___, overlap=___) | /10 | /10 | /10 |
| Flow B (chunk=___, overlap=___) | /10 | /10 | /10 |

> **You should see.** Six fractions and a one-sentence defense that names numbers.

### Step D: Force Grounding and Abstention

> **Do this.**
> 1. Write the Prompt node so the model **must** cite the retrieved chunks and **must** abstain otherwise.  Start from the template below and tighten it for your corpus.
> 2. Run **three in-corpus queries** (answers with citations) and **two out-of-corpus queries** (clean abstentions), and save all five transcripts.

```text
You answer questions using ONLY the numbered context passages below.
Cite the passage number in brackets, like [1], after every claim.
If the context does not contain the answer, reply exactly:
"I don't have enough information in my knowledge base to answer that."

Context:
{context}
```

> **You should see.** Bracketed citations on the three in-corpus answers and the exact abstention phrase on the two out-of-corpus ones.

> **If it fails.** The model answers an out-of-corpus question from its own general knowledge instead of abstaining.  That is a real finding: tighten the prompt, re-run, and report both versions.

### Step E: Audit Citations and Write Up

> **Do this.**
> 1. Complete core Part 4 unchanged: audit every citation in a sample of at least ten answers from your shipped flow by hand, report a faithfulness rate, and classify failures with the hallucination taxonomy.  The playground's node-inspection view shows exactly which chunk text the model was given; check each bracketed citation against its source chunk there.
> 2. Write the readme, datasheet, learning log, and pair log to the core lab's requirements, and add one paragraph on what the canvas made easier and what it hid from you compared with the code your classmates wrote.

### Direction 0 Deliverables

Fold these into the standard submission ZIP:

- **Exported flow JSON, two files**: both chunking configurations (the flow menu's Export Flow), plus your node-settings config notes.
- **Query/recall table**: the ten queries, their hand-located source chunks, and the completed recall@k table for both configurations with your defended choice.
- **Transcripts**: the three in-corpus and two out-of-corpus grounding/abstention runs, and the answers used in your citation audit.
- **Datasheet**: from core Part 1.
- **Writeup**: core-lab scope, including the faithfulness rate and failure classification from the audit and the canvas-versus-code paragraph.

### Direction 0 Reflection Prompts

- What did the canvas make easier than code, and what did it hide from you?  Name one node setting you could not see until you opened the inspection view.
- Your two flows differ only in splitter settings.  Which won, by how much, and what in your corpus explains the margin?
- When the model answered an out-of-corpus question from general knowledge, what changed in the prompt to stop it, and what did that cost on in-corpus answers?

---

## Direction 1: Hands-On Fine-Tuning with LoRA and QLoRA

This direction takes the opposite approach to knowledge injection.  Your RAG system kept knowledge *outside* the model and retrieved it at query time.  Here you adapt a local model by **baking** domain knowledge into a small set of trainable weights using **LoRA** (Low-Rank Adaptation, which adds a tiny number of trainable parameters to a frozen base model so fine-tuning fits on consumer hardware).  You train on a real domain dataset, instrument the run with loss tracking, evaluate before and after, document the result with a model card, export the model to GGUF so it runs in Ollama, and then decide whether fine-tuning earned its keep against the RAG pipeline from the core lab.

> **What this direction requires.**
> - **Accounts:** a free Hugging Face account.  If you use a gated Llama base model, accept the model license on its Hugging Face page and log in with `huggingface-cli`; the non-gated bases in the table below need no license step.  A Google account if you take the free Colab path.
> - **API costs:** none.  Training runs on your own GPU or on Google Colab's free tier; nothing is billed.
> - **Installs / disk:** the training toolchain (`unsloth`, or `transformers` + `peft` + `trl`) in Colab or locally, plus a few GB of disk for model weights and the exported GGUF.
> - **Hardware:** a CUDA GPU with roughly 6-8 GB of VRAM, **or no GPU at all** using one of the two no-GPU paths below.
> - **No-cost fallback:** Google Colab's free T4 tier runs every step; if Colab is unavailable to you, the provided-artifact variant skips training and still earns full credit.

Pace yourself: the active work is bounded, and training runs in the background while you do other things.

**No GPU?  Two paths, both full credit.**

1. **Colab path (the default no-GPU route).** Everything runs on Colab's free T4 GPU: run the Colab setup cell in Step A, then work Steps B through E as written in the notebook.  A 3.8B to 8B model with QLoRA fits in the free tier's roughly 15 GB of VRAM in a 15-60 minute run.  Download the exported GGUF at the end of Step E and finish the Ollama deployment on your own machine.
2. **Provided-artifact variant (only if Colab is unavailable to you).** Skip training and start from a published adapter: search the Hugging Face Hub for a public LoRA adapter for `llama3.2` (any published one works), pick one whose model card describes its training domain, cite it, and download it.  Then do **only the deployment and evaluation half**: the GGUF merge in Step E (merging the downloaded adapter), the `Modelfile`, the `ollama create` / `ollama run` deployment, and the full before/after evaluation of Step D comparing the base model against the adapted model.  **This variant earns full credit with the evaluation weighted more heavily** in place of the training run: extend your before/after comparison to at least 15 prompts (rather than 10) and include the regression analysis, since the evaluation is your primary evidence.  The model card (Step F) is still required; document the adapter's provenance, dataset, and license in place of your own training details.  The loss-curve deliverable is waived for this variant.

### Step A: Set Up Your Toolchain

Prerequisites: GPU access confirmed (your own GPU, Colab's free T4, a cloud VM, or the provided-artifact variant chosen); Python 3.10 or later (`python --version`); for a Llama model, a Hugging Face account with the license accepted at `meta-llama/Meta-Llama-3-8B-Instruct`; the Hugging Face CLI installed and logged in if you download gated models.

Pick one training toolchain; the graded work is identical on both: a converging training run, a before/after evaluation, a model card, **and your fine-tuned model answering a prompt from inside Ollama.**

- **Toolchain A (recommended default): [Unsloth](https://unsloth.ai/).** Wraps `transformers`, `peft`, and `trl` with a faster, lower-memory training path (a 7B model fits on a free Colab T4 in a 15-60 minute run) and exports **directly to GGUF so it runs in Ollama**.  Start from an official [Unsloth notebook](https://unsloth.ai/docs/get-started/unsloth-notebooks) for your base model and adapt it.
- **Toolchain B (see-the-internals alternative): raw `transformers` + `peft` + `trl`.** Wire `LoraConfig`, `BitsAndBytesConfig`, and `SFTTrainer` by hand to see exactly what Unsloth abstracts, then convert to GGUF with `llama.cpp` in Step E.

> **Do this.**
> 1. **On Colab with Unsloth (recommended):** create a new notebook, set Runtime, Change runtime type, T4 GPU, and run this setup cell first.
> 2. **On local hardware:** run the install in the `bash` fence instead.
> 3. Run the tokenizer sanity check to confirm model downloads work.
> 4. Choose a base model from the table.

```python
# Cell 1: Google Colab setup (Unsloth). Runtime > Change runtime type > T4 GPU
import subprocess, sys
subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "unsloth"])
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'None'}")
print(f"VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB" if torch.cuda.is_available() else "")
```

```bash
pip install unsloth          # Toolchain A (recommended)
# or, for Toolchain B (hand-rolled):
# pip install transformers peft datasets bitsandbytes accelerate trl
python -c "import torch; print('GPU:', torch.cuda.get_device_name(0))"
```

```python
# Sanity check: confirm Hugging Face downloads work, using a small non-gated model
from transformers import AutoTokenizer
tokenizer = AutoTokenizer.from_pretrained("microsoft/phi-3-mini-4k-instruct", trust_remote_code=True)
print(f"Tokenizer OK. Token IDs: {tokenizer('Hello, world!')['input_ids']}")
```

> **You should see.** `CUDA available: True`, `GPU: Tesla T4`, `VRAM: 15.8 GB` on Colab, and `Tokenizer OK. Token IDs: [1, 15043, 29892, 3186, 29991]` from the sanity check.  `OSError: Can't load tokenizer` means your connection is down or you are not logged in (`huggingface-cli login`).

| Model | Size | Min VRAM | Notes |
|-------|------|----------|-------|
| `microsoft/phi-3-mini-4k-instruct` | 3.8B | 6 GB | Best for free Colab T4 |
| `meta-llama/Meta-Llama-3-8B-Instruct` | 8B | 8 GB with QLoRA | Requires Hugging Face token |
| `mistralai/Mistral-7B-Instruct-v0.3` | 7B | 8 GB with QLoRA | Good quality, open weights |

### Step B: Choose and Format a Domain Dataset

The dataset determines what your model learns, what biases it might amplify, and how you can measure success.  A natural choice is the *same domain as your corpus*, so your before/after comparison speaks directly to the RAG-versus-fine-tuning question.

> **Do this.**
> 1. Choose one dataset from the table, or propose your own with instructor approval first.
> 2. Create `dataset_format.py`, load and inspect the dataset, and adapt `format_example` to its field names.  `SFTTrainer` expects one string per example in a consistent instruction format.
> 3. Run `python3 dataset_format.py`.
> 4. Write the dataset section of `model_card.md`: source URL, number of examples, format, train/validation split sizes, and one known limitation.

| Dataset | Hugging Face ID | Domain | Format |
|---------|-----------------|--------|--------|
| Medical Q&A | `medalpaca/medical_meadow_medical_flashcards` | Medical | instruction/output |
| Python codegen | `iamtarun/python_code_instructions_18k_alpaca` | Code | instruction/input/output |
| Legal reasoning | `nguha/legalbench` | Legal | varies by subset |
| Science questions | `sciq` | Science | question/answer/support |

```python
# dataset_format.py
from datasets import load_dataset

DATASET_ID = "sciq"  # TODO: replace with your chosen dataset ID
dataset = load_dataset(DATASET_ID)
print(f"Dataset splits: {list(dataset.keys())} | Train size: {len(dataset['train'])}")
print(f"First example:\n{dataset['train'][0]}")

def format_example(example: dict) -> dict:
    """Convert a raw dataset row into an instruction-tuning string. TODO: adapt the field names."""
    instruction = example.get("question", "")
    answer = example.get("correct_answer", example.get("output", ""))   # TODO: your answer field
    context = example.get("support", "")                                # TODO: supporting context, if any
    if context:
        text = f"### Instruction:\n{instruction}\n\n### Context:\n{context}\n\n### Response:\n{answer}"
    else:
        text = f"### Instruction:\n{instruction}\n\n### Response:\n{answer}"
    return {"text": text}

formatted = dataset["train"].map(format_example)
if "validation" not in dataset:                       # 90/10 split if the dataset has none
    split = formatted.train_test_split(test_size=0.1, seed=42)
    train_data, val_data = split["train"], split["test"]
else:
    train_data, val_data = formatted, dataset["validation"].map(format_example)
print(f"Train examples: {len(train_data)} | Validation examples: {len(val_data)}")
print(f"Formatted example:\n{train_data[0]['text'][:300]}")
```

> **You should see.** For `sciq`: splits `['train', 'validation', 'test']`, train size `11679`, a first example with `question`, `correct_answer`, and `support` fields, and a formatted string that starts with `### Instruction:` and contains `### Response:`.  Confirm your validation split has at least 100 examples.

> **If it fails.**
> - `load_dataset` hangs: a firewall may block the Hugging Face CDN; try `cache_dir="/tmp/hf_cache"` or download manually.
> - Field names do not match: print `dataset['train'][0].keys()`.
> - Empty formatted text on some rows: those rows have `None` values; return `None` for them and `.filter(lambda x: x is not None)` after mapping.

### Step C: Fine-Tune with LoRA or QLoRA

LoRA leaves the original weights untouched and learns two small matrices (A and B, with rank `r`) that approximate the weight update, so a 7B model trains on 8-16 GB of VRAM.  **QLoRA** adds 4-bit quantization on top, cutting VRAM roughly in half again.  You own every hyperparameter and must justify `r`, `learning_rate`, and `target_modules` in your writeup; the toolchain speeds the run, it does not make the choices.

> **Do this.**
> 1. Create `train_unsloth.py` (Toolchain A) or `train.py` (Toolchain B) from the skeleton for your toolchain, fill every `# TODO`, and reuse your `format_example`.
> 2. Run it and watch the loss: `python3 train_unsloth.py` or `python3 train.py`.
> 3. Create `plot_loss.py`, run it, and annotate the curve in your writeup: does loss converge?  Is there overfitting (training loss keeps falling while validation loss rises or plateaus)?  Justify at least one hyperparameter choice.

```python
# train_unsloth.py - Toolchain A. Unsloth loads the model 4-bit and attaches the LoRA adapters.
from unsloth import FastLanguageModel
from trl import SFTTrainer
from transformers import TrainingArguments
from datasets import load_dataset

MODEL_ID = "unsloth/Phi-3-mini-4k-instruct"   # TODO: your base model (Unsloth 4-bit variant)
MAX_SEQ = 512
model, tokenizer = FastLanguageModel.from_pretrained(model_name=MODEL_ID, max_seq_length=MAX_SEQ, load_in_4bit=True)
model = FastLanguageModel.get_peft_model(
    model, r=8, lora_alpha=16, lora_dropout=0.05,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],  # TODO: justify
)
dataset = load_dataset("sciq")                 # TODO: load and format your dataset into a "text" field
def format_example(ex):
    return {"text": f"### Instruction:\n{ex.get('question','')}\n\n### Response:\n{ex.get('correct_answer','')}"}
train_data = dataset["train"].map(format_example)

trainer = SFTTrainer(
    model=model, tokenizer=tokenizer, train_dataset=train_data, dataset_text_field="text", max_seq_length=MAX_SEQ,
    args=TrainingArguments(output_dir="./lora-finetuned", num_train_epochs=1, per_device_train_batch_size=4,
                           gradient_accumulation_steps=4, learning_rate=2e-4, fp16=True, logging_steps=10,
                           warmup_ratio=0.03, report_to="none"),
)
print("Starting training..."); trainer.train()
model.save_pretrained("./lora-finetuned")     # LoRA adapters; GGUF export happens in Step E
```

```python
# train.py - Toolchain B. The same LoRA/QLoRA setup wired by hand.
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig, TrainingArguments
from peft import LoraConfig, get_peft_model, TaskType
from trl import SFTTrainer
from datasets import load_dataset

MODEL_ID, DATASET_ID, OUTPUT_DIR = "microsoft/phi-3-mini-4k-instruct", "sciq", "./lora-finetuned"   # TODO: yours
LORA_R, LORA_ALPHA, LORA_DROPOUT = 8, 16, 0.05   # rank (try 8 or 16), typically alpha = 2 * rank, regularization
TARGET_MODULES = ["q_proj", "v_proj"]            # TODO: adjust for your model family, e.g. add "k_proj", "o_proj"

bnb_config = BitsAndBytesConfig(load_in_4bit=True, bnb_4bit_quant_type="nf4",     # QLoRA; drop if you have the VRAM
                                bnb_4bit_compute_dtype=torch.float16, bnb_4bit_use_double_quant=True)
tokenizer = AutoTokenizer.from_pretrained(MODEL_ID, trust_remote_code=True)
tokenizer.pad_token = tokenizer.eos_token        # required for batch training
model = AutoModelForCausalLM.from_pretrained(MODEL_ID, quantization_config=bnb_config, device_map="auto", trust_remote_code=True)
model = get_peft_model(model, LoraConfig(r=LORA_R, lora_alpha=LORA_ALPHA, target_modules=TARGET_MODULES,
                                         lora_dropout=LORA_DROPOUT, bias="none", task_type=TaskType.CAUSAL_LM))
model.print_trainable_parameters()

dataset = load_dataset(DATASET_ID)               # TODO: or load_from_disk("./formatted_dataset")
def format_example(example):                     # TODO: adapt field names to your dataset
    return {"text": f"### Instruction:\n{example.get('question','')}\n\n### Response:\n{example.get('correct_answer', example.get('output',''))}"}
train_data = dataset["train"].map(format_example)
val_data = dataset.get("validation", dataset["train"].select(range(500))).map(format_example)

training_args = TrainingArguments(               # TODO: 2-3 epochs if you have time and VRAM; justify learning_rate
    output_dir=OUTPUT_DIR, num_train_epochs=1, per_device_train_batch_size=4, per_device_eval_batch_size=4,
    gradient_accumulation_steps=4, learning_rate=2e-4, fp16=True, logging_steps=10, eval_strategy="steps",
    eval_steps=50, save_steps=100, warmup_ratio=0.03, report_to="none")   # "wandb" for W&B tracking
trainer = SFTTrainer(model=model, args=training_args, train_dataset=train_data, eval_dataset=val_data,
                     dataset_text_field="text", max_seq_length=512)
print("Starting training..."); trainer.train()
trainer.save_model(OUTPUT_DIR); print(f"Model saved to {OUTPUT_DIR}")
```

```python
# plot_loss.py - reads the log the Trainer saves in output_dir/trainer_state.json
import json
import matplotlib.pyplot as plt

state = json.load(open("./lora-finetuned/trainer_state.json"))
train = [(e["step"], e["loss"]) for e in state["log_history"] if "loss" in e]
evals = [(e["step"], e["eval_loss"]) for e in state["log_history"] if "eval_loss" in e]
plt.figure(figsize=(10, 5))
plt.plot(*zip(*train), label="Training loss", color="blue")
if evals:
    plt.plot(*zip(*evals), label="Validation loss", color="orange", linestyle="--")
plt.xlabel("Steps"); plt.ylabel("Loss"); plt.title("Training vs. Validation Loss"); plt.legend(); plt.grid(True)
plt.savefig("loss_curve.png", dpi=150)
print("Saved loss_curve.png")
```

> **You should see.** A healthy run reports the trainable fraction and then a falling loss, roughly 2.3 toward 1.1 over 200 steps (your numbers will differ):

```text
trainable params: 4,194,304 || all params: 3,825,160,192 || trainable%: 0.1097
Starting training...
{'loss': 2.3421, 'learning_rate': 0.0002, 'epoch': 0.01}
{'loss': 1.5201, 'learning_rate': 0.00018, 'epoch': 0.10}
{'loss': 1.1478, 'learning_rate': 0.00010, 'epoch': 0.40}
{'eval_loss': 1.2341, 'epoch': 0.40}
...
Model saved to ./lora-finetuned
```

> **Checkpoint.** `./lora-finetuned/` exists and contains adapter files, `loss_curve.png` is saved, and training loss fell from the first logged step to the last.

> **If it fails.**
> - `CUDA out of memory`: drop `per_device_train_batch_size` to 2 or 1 and raise `gradient_accumulation_steps` to keep the effective batch the same.
> - Loss is `nan` from step 1: the learning rate is too high; try `1e-4` or `5e-5`.  Loss stuck above 2.0 or oscillating wildly: same fix, then check your formatting.
> - `target_modules` raises `ValueError`: print `[name for name, _ in model.named_modules()]` to see the real module names.
> - Training exceeds 2 hours on Colab: `train_data = train_data.select(range(2000))`.

### Step D: Evaluate Before and After

Without systematic evaluation, fine-tuning is a black box: hours of training and no idea whether the model improved.  This is the same habit as recall@k and the citation audit in the core lab.

> **Do this.**
> 1. Create `evaluate_models.py`: load the base model and your fine-tuned model, write **10 test prompts** from your domain that are **not** in the training set (15 on the provided-artifact variant), run both models, and save `eval_comparison.csv`.
> 2. Open the CSV and fill in the `improvement` (Y / N / Partial) and `notes` columns by hand.
> 3. Compute at least one quantitative metric: **Option A**, perplexity on a held-out test set (lower is better; the function below); **Option B**, task accuracy for an MCQ dataset such as `sciq` (compare the model's top predicted answer to `correct_answer`); or **Option C**, an LLM-as-judge score from 1 to 5 on each test prompt.
> 4. Document at least one **regression** in your writeup: a prompt where the base model was better.  This is expected, and honesty about it is graded.
> 5. Compare against your RAG pipeline: ask the fine-tuned model two or three questions your RAG system answered from your corpus, with no retrieval.  Which answered more faithfully?  Which hallucinated?  Record the head-to-head so your recommendation rests on evidence.

```python
# evaluate_models.py
import csv, math, torch
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel

MODEL_ID = "microsoft/phi-3-mini-4k-instruct"   # TODO: your model ID
LORA_PATH = "./lora-finetuned"
tokenizer = AutoTokenizer.from_pretrained(MODEL_ID, trust_remote_code=True)

def load_base_model():
    return AutoModelForCausalLM.from_pretrained(MODEL_ID, device_map="auto", trust_remote_code=True, torch_dtype=torch.float16)

def generate(model, prompt: str, max_new_tokens: int = 200) -> str:
    inputs = tokenizer(prompt, return_tensors="pt").to(model.device)
    with torch.no_grad():
        output = model.generate(**inputs, max_new_tokens=max_new_tokens, temperature=0.1, do_sample=True,
                                pad_token_id=tokenizer.eos_token_id)
    return tokenizer.decode(output[0][inputs["input_ids"].shape[1]:], skip_special_tokens=True)  # new tokens only

def compute_perplexity(model, texts: list[str], max_length: int = 512) -> float:
    """Option A: exp(mean token loss) over held-out texts. Lower is better."""
    model.eval(); total_loss = 0; total_tokens = 0
    for text in texts:
        inputs = tokenizer(text, return_tensors="pt", max_length=max_length, truncation=True).to(model.device)
        with torch.no_grad():
            outputs = model(**inputs, labels=inputs["input_ids"])
        total_loss += outputs.loss.item() * inputs["input_ids"].shape[1]
        total_tokens += inputs["input_ids"].shape[1]
    return math.exp(total_loss / total_tokens)

TEST_PROMPTS = [   # TODO: 10 prompts from your domain, none from the training set
    "### Instruction:\nWhat is the primary mechanism of action of beta-blockers?\n\n### Response:",
    "### Instruction:\nExplain the difference between supervised and unsupervised learning.\n\n### Response:",
]
base_model = load_base_model()
ft_model = PeftModel.from_pretrained(load_base_model(), LORA_PATH)

rows = []
for i, prompt in enumerate(TEST_PROMPTS):
    print(f"Prompt {i+1}/{len(TEST_PROMPTS)}...")
    rows.append({"prompt": prompt[:80], "base_output": generate(base_model, prompt)[:200],
                 "finetuned_output": generate(ft_model, prompt)[:200], "improvement": "?", "notes": ""})
with open("eval_comparison.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["prompt", "base_output", "finetuned_output", "improvement", "notes"])
    writer.writeheader(); writer.writerows(rows)
print("Saved eval_comparison.csv - open it and fill in the improvement and notes columns.")

test_texts = ["### Instruction:\n...\n\n### Response:\n..."]   # TODO: real held-out texts from your dataset
base_ppl, ft_ppl = compute_perplexity(base_model, test_texts), compute_perplexity(ft_model, test_texts)
print(f"Base model perplexity: {base_ppl:.2f} | Fine-tuned model perplexity: {ft_ppl:.2f} | "
      f"Improvement: {((base_ppl - ft_ppl) / base_ppl * 100):.1f}%")
```

> **You should see.** `eval_comparison.csv` with one row per prompt, and a perplexity line such as `Base model perplexity: 24.31 | Fine-tuned model perplexity: 11.87 | Improvement: 51.2%` (numbers will vary).

> **Checkpoint.** The CSV has 10 rows (15 on the provided-artifact variant) with `improvement` filled in by hand, and your quantitative metric is computed for both models.

> **If it fails.**
> - Repetitive output (the same phrase over and over): add `repetition_penalty=1.2` to `generate()`.
> - Both models produce identical output: the adapter did not load; check that `LORA_PATH` contains `adapter_config.json`.
> - Fine-tuned perplexity is higher than base: likely overfitting; check the loss curve for rising validation loss.

### Step E: Export to GGUF and Run Your Model in Ollama

All semester your agents have talked to Ollama.  A fine-tuned model that only runs inside a notebook is not yet part of your stack, so you convert it to **GGUF** (the quantized file format Ollama loads) and run *your own model* locally, exactly like the stock models.

> **Do this.**
> 1. Merge the adapter into the base weights and write a quantized GGUF, with the command for your toolchain.
> 2. Download the `.gguf` file to the machine running Ollama (from Colab: `from google.colab import files; files.download(...)`, or save to Google Drive).
> 3. Write a `Modelfile` that points Ollama at your GGUF and sets the system prompt you trained against.
> 4. Register and run it, and capture a terminal screenshot or log of `ollama run my-finetuned` answering one in-domain prompt.  This transcript is a required deliverable: it is the evidence that your model runs in your local stack.

```python
# Toolchain A (Unsloth): merge LoRA into the base weights and write a quantized GGUF in one call
model.save_pretrained_gguf("my-finetuned-gguf", tokenizer, quantization_method="q4_k_m")   # produces my-finetuned-gguf/*.gguf
```

```bash
# Toolchain B: after merging PeftModel into the base model and saving to ./merged-model, convert with llama.cpp
git clone https://github.com/ggerganov/llama.cpp
python llama.cpp/convert_hf_to_gguf.py ./merged-model --outfile my-finetuned.gguf --outtype q4_k_m
```

```text
FROM ./my-finetuned.gguf
SYSTEM "You are a domain assistant fine-tuned for <your domain>."
PARAMETER temperature 0.7
```

```bash
ollama create my-finetuned -f Modelfile
ollama run my-finetuned "Ask a question from your domain here"
```

> **You should see.** `ollama create` reports success, and `ollama run my-finetuned` answers your in-domain prompt in the style of your training data.

> **If it fails.**
> - `ollama create` cannot parse the GGUF: confirm the download finished (compare byte sizes) and that your Ollama version supports the quantization (`q4_k_m` is widely supported).
> - The model loads but answers in gibberish: the chat template does not match the instruction format you trained on; add a `TEMPLATE` block to the `Modelfile` matching your `### Instruction / ### Response` format.

### Step F: Write the Model Card and Reflection

A model without documentation is a liability.  The model card (Mitchell et al. 2019) is the industry standard on Hugging Face, and writing one forces you to say what your model does, what it does not do, and what could go wrong, the same discipline as the corpus datasheet.

> **Do this.**
> 1. Create `model_card.md` with all eight sections from the template.
> 2. Answer the reflection prompts in your writeup, including the fine-tuning-versus-RAG recommendation.

```markdown
# Model Card: [Your Model Name]

## Model Details
Base model ID; fine-tuning method (LoRA r, alpha, target_modules); training dataset and size; training duration (steps, epochs, wall-clock); developer; date.

## Intended Use
The primary use case in one sentence, and at least two out-of-scope uses this model should NOT be used for (for example "clinical diagnosis or treatment decisions").

## Factors
Relevant factors (language, domain, question type) and evaluation factors (what you held constant and what you varied).

## Metrics
Your evaluation metric(s) (perplexity, accuracy, or LLM-as-judge) and the threshold you would call acceptable.

## Training Data
From Step B: source, size, format, train/validation split, and known limitations.

## Quantitative Analyses
A table from Step D: Metric | Base Model | Fine-Tuned Model | Change, with rows for your metric and the qualitative improvement rate (Y out of 10).

## Ethical Considerations
At least one bias your dataset might introduce or amplify (for example a medical set that skews toward Western clinical practice), and whether the training data contains PII.

## Caveats
At least two known limitations of your fine-tuned model (for example "performance degrades on questions longer than 200 tokens").
```

> **Checkpoint.** `model_card.md` has all eight sections, and Ethical Considerations names a specific bias risk tied to your dataset.  If you are unsure what biases it carries, read the dataset's "Dataset Card" tab on Hugging Face; most discuss known biases and limitations.

### Direction 1 Extension Challenges (optional)

- **LoRA rank ablation.** Train with `r=4`, `r=8`, and `r=16`; plot all three loss curves on one axis.  Does rank improve final loss?  Test perplexity?  VRAM use?  Report all three in a table.
- **LoRA versus QLoRA memory.** Train once with 4-bit quantization and once without, measuring peak VRAM with `torch.cuda.max_memory_allocated()`.  How much did quantization save, and did it hurt quality?
- **Few-shot prompting versus fine-tuning.** Put 10 training examples in the base model's context window as few-shot examples and compare to your fine-tuned model on the test set.  When does fine-tuning win, and when does few-shot match it with far less effort?

### Direction 1 Deliverables

Fold these into the submission ZIP and readme:

- `train.py`/`train_unsloth.py` or the Colab notebook (`.ipynb`): a runnable training script, noting which toolchain you used
- `dataset_format.py`: dataset loading and formatting code
- `evaluate_models.py`: the comparison script
- `loss_curve.png`: the annotated training/validation loss plot (waived on the provided-artifact variant)
- `eval_comparison.csv`: the before/after table (10 rows; 15 on the provided-artifact variant)
- Quantitative metric results (printed output, screenshot, or CSV)
- `Modelfile` and a terminal transcript or screenshot of `ollama run my-finetuned` answering an in-domain prompt
- `model_card.md`: complete, with all 8 sections
- A section in your writeup covering reflection answers, hyperparameter justifications, and your fine-tuning-versus-RAG recommendation

**What proficient work looks like.** Training runs with a loss curve, a quantitative before/after metric, a comparison table, and at least one hyperparameter choice justified with evidence.  The model is exported to GGUF and demonstrably runs in Ollama via a `Modelfile`, with a transcript.  The dataset is described with source, size, format, and cleaning; a validation set catches overfitting; at least one dataset limitation is named.  Evaluation uses a defined metric, honestly reports at least one regression, and delivers a defended recommendation on fine-tuning versus RAG and prompting.  The model card is complete across all eight sections, names at least one bias shift the fine-tuning introduced or amplified, and the reflection answers are grounded in your own results.

### Direction 1 Reflection Prompts

- You spent hours fine-tuning on 1,000 examples.  A colleague says "just put those examples in the system prompt instead."  When would they be right, and when would fine-tuning be worth the effort?
- For your specific domain, which would you deploy, the RAG system or the fine-tuned model, and what evidence from your two evaluations drives that choice?
- Your fine-tuned model may now do better in your domain and worse on general questions.  Who is responsible for communicating that trade-off to users?
- How many hours did this direction take?

---

## Direction 2: Multimodal AI and Monte Carlo Simulation

This direction turns from text retrieval to images.  In the core lab you audited whether a model faithfully used *text* you retrieved; here you audit whether a **multimodal** model faithfully reads *a chart*.  You build a Monte Carlo retirement simulation, send its chart to a local vision model, and find that AI image analysis is strong at pattern recognition and fragile on numerical precision, a difference that matters when the output might shape someone's financial decisions.  The ground-truth-versus-AI-claim audit is the citation audit applied to pixels instead of passages.

Work in **pairs using driver/navigator roles**: the driver types while the navigator reviews, questions, and consults documentation.  Swap roles at least every 30 minutes and keep a brief log of swap times and roles.

> **What this direction requires.**
> - **Accounts:** none.
> - **API costs:** none; the vision model runs locally in Ollama.
> - **Installs / disk:** `numpy`, `matplotlib`, and `requests`, plus the `llava` multimodal model (about a 4.7 GB pull; smaller alternatives such as `moondream`, `bakllava`, or `llava-phi3` also work).
> - **Hardware:** any machine that runs the core lab; the 4.7 GB model is happiest with 8 GB of RAM or more.  Pull it before the day you need it.
> - **No-cost fallback:** not needed; fully local and free.

Why Monte Carlo?  A spreadsheet gives you one future; Monte Carlo simulation gives you a thousand.  Instead of projecting a single "expected" outcome, you draw thousands of possible annual returns from a statistical distribution, let each play out over a 40-year career, and look at the spread of endings.  That spread, not the center, is what matters for a decision whose consequences compound for decades.

Complete these before writing code: [Sampling, Temperature, and Generation]({{ site.baseurl }}/Tutorials/SamplingAndTemperature) (stochastic sampling and output distributions), the [Evaluating Agent Outputs Activity]({{ site.lia_viewer_url }}{{ site.raw_pages_url }}Activities/liascript-evaluatingoutputs.md) (assessing AI-generated content critically), and [Multimodal Agents]({{ site.baseurl }}/Tutorials/MultimodalAgents) (sending images to local vision models).

> **Do this.** Install the libraries, pull the vision model, and confirm the API answers.  `ollama list` prints every model on your machine; `curl` fetches the same list from the server.

```bash
pip install numpy matplotlib requests
ollama pull llava
ollama list
curl http://localhost:11434/api/tags
```

> **You should see.** A row like `llava:latest   8dd30f6b0cb1   4.7 GB   2 minutes ago` from `ollama list`, and JSON beginning `{"models":[{"name":"llava:latest", ...` from `curl`.  If `llava` will not pull, use `moondream`, `bakllava`, or `llava-phi3` and set the `"model"` key in your config to match.

> **Time budget.** Step A, simulation engine: 50-70 minutes.  Step B, multimodal integration: 40-60 minutes.  Step C, parameter sensitivity: 25-35 minutes.  Step D, critical analysis: 20-30 minutes.  Readme and reflection: 30-45 minutes.

### Step A: Build the Simulation Engine

You write `montecarlo.py`, which simulates 1,000 possible futures for a person who starts saving at 25 and retires at 65.  Each simulated year draws a random annual return from a normal distribution, applies it to the portfolio, and records the balance.  The output is a two-panel chart on disk.  Keep the config-file discipline from the core lab; it makes Step C a one-file edit.

> **Do this.**
> 1. Create `config.json` in your project root.
> 2. Create `montecarlo.py` with `load_config`, `simulate_retirement`, `plot_simulation`, `save_statistics`, and the main block below.
> 3. Run `python3 montecarlo.py`.

```json
{
  "starting_age": 25,
  "retirement_age": 65,
  "life_expectancy": 90,
  "starting_savings": 10000,
  "monthly_contribution": 500,
  "annual_return_mean": 0.07,
  "annual_return_std": 0.12,
  "inflation_rate": 0.025,
  "num_simulations": 1000,
  "model": "llava",
  "ollama_url": "http://localhost:11434"
}
```

```python
# montecarlo.py
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import base64, io, json, traceback
import requests

def load_config(path="config.json"):
    """Load simulation and model parameters from a JSON config file."""
    with open(path) as f:
        return json.load(f)

def simulate_retirement(cfg):
    """Return an array of shape (num_simulations, years); each row is one portfolio path of end-of-year balances."""
    years = cfg["retirement_age"] - cfg["starting_age"]
    results = np.zeros((cfg["num_simulations"], years))
    for sim in range(cfg["num_simulations"]):
        balance = cfg["starting_savings"]
        for year in range(years):
            balance += cfg["monthly_contribution"] * 12                                   # annual contribution
            annual_return = np.random.normal(cfg["annual_return_mean"], cfg["annual_return_std"])
            balance *= (1 + annual_return)                                                # apply the return
            balance = max(balance, 0)                                                     # a portfolio cannot go negative
            results[sim, year] = balance
    return results

def plot_simulation(balances, cfg):
    """Two panels: all paths with median and 10th/90th bands; histogram of final balances. Saves a PNG and returns it base64-encoded."""
    ages = list(range(cfg["starting_age"] + 1, cfg["retirement_age"] + 1))
    final_balances = balances[:, -1]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    for path in balances:                                                                  # every path, faint gray
        ax1.plot(ages, path, color="gray", alpha=0.05, linewidth=0.5)
    ax1.plot(ages, np.median(balances, axis=0), color="blue", linewidth=2, label="Median")
    ax1.plot(ages, np.percentile(balances, 10, axis=0), color="red", linewidth=1.5, linestyle="--", label="10th / 90th percentile")
    ax1.plot(ages, np.percentile(balances, 90, axis=0), color="red", linewidth=1.5, linestyle="--")
    ax1.set_xlabel("Age"); ax1.set_ylabel("Portfolio Balance")
    ax1.set_title(f"Monte Carlo Retirement Simulation\n{cfg['num_simulations']:,} paths | "
                  f"${cfg['monthly_contribution']:,}/mo contribution | Mean return {cfg['annual_return_mean']:.0%}")
    ax1.legend()
    ax1.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"${x:,.0f}"))      # currency axis

    ax2.hist(final_balances, bins=50, color="steelblue", edgecolor="white", alpha=0.8)
    ax2.axvline(np.median(final_balances), color="blue", linewidth=2, label=f"Median: ${np.median(final_balances):,.0f}")
    ax2.axvline(1_000_000, color="green", linewidth=1.5, linestyle="--", label="$1 Million milestone")
    ax2.set_xlabel("Final Balance at Retirement"); ax2.set_ylabel("Number of Simulations")
    ax2.set_title("Distribution of Final Balances at Age 65"); ax2.legend()
    ax2.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"${x/1e6:.1f}M"))

    plt.tight_layout()
    plt.savefig("retirement_simulation.png", dpi=150, bbox_inches="tight")
    print("Saved: retirement_simulation.png")
    buf = io.BytesIO()                                                                     # encode for the multimodal API
    fig.savefig(buf, format="png", dpi=150, bbox_inches="tight")
    plt.close(fig); buf.seek(0)
    return base64.b64encode(buf.getvalue()).decode("utf-8")

def save_statistics(balances, cfg, path="simulation_stats.txt"):
    """Save the key statistics of the run to a text file; this is your ground truth for Steps B, D, and E."""
    final = balances[:, -1]
    lines = [
        "Simulation parameters:",
        f"  Monthly contribution: ${cfg['monthly_contribution']:,}",
        f"  Mean annual return:   {cfg['annual_return_mean']:.1%}",
        f"  Return std dev:       {cfg['annual_return_std']:.1%}",
        f"  Number of paths:      {cfg['num_simulations']:,}",
        "",
        f"Final balance at retirement (age {cfg['retirement_age']}):",
        f"  10th percentile: ${np.percentile(final, 10):>12,.0f}",
        f"  Median (50th):   ${np.median(final):>12,.0f}",
        f"  90th percentile: ${np.percentile(final, 90):>12,.0f}",
        f"  Mean:            ${final.mean():>12,.0f}",
        "",
        f"Probability of reaching $1 million: {(final >= 1_000_000).mean():.1%}",
    ]
    text = "\n".join(lines)
    print(text)
    with open(path, "w") as f:
        f.write(text)
    print(f"Saved: {path}")
    return text

if __name__ == "__main__":
    cfg = load_config()
    np.random.seed(42)
    print("Running simulation...")
    balances = simulate_retirement(cfg)
    print("Generating visualization...")
    image_b64 = plot_simulation(balances, cfg)
    print("Computing statistics...")
    stats_text = save_statistics(balances, cfg)
```

> **You should see.** The PNG and the statistics file, with numbers that vary by seed:

```text
Running simulation...
Generating visualization...
Saved: retirement_simulation.png
Computing statistics...
Simulation parameters:
  Monthly contribution: $500
  Mean annual return:   7.0%
  Return std dev:       12.0%
  Number of paths:      1,000

Final balance at retirement (age 65):
  10th percentile: $      341,208
  Median (50th):   $    1,042,577
  90th percentile: $    2,847,031
  Mean:            $    1,298,451

Probability of reaching $1 million: 53.2%
Saved: simulation_stats.txt
```

The left panel shows a fan of gray paths widening toward age 65 with a visible median line and two outer dashed bands; the right panel shows a right-skewed histogram with a median line and a $1M milestone line.

> **If it fails.**
> - `ValueError: could not broadcast input array...`: check that `results` is indexed `results[sim, year]` with `year` from `0` to `years - 1`.
> - The y-axis shows scientific notation: the `FuncFormatter` must be assigned after `ax1` is populated; move it to just before `plt.tight_layout()`.
> - All paths converge to zero: add the contribution *before* applying the return, and check `annual_return_std` is not unreasonably high.

> **Checkpoint.** Before Step B, make sure you can answer:
> 1. What does the width of the fan (the gap between the 10th and 90th percentile lines) mean in plain English?  How would you expect it to change if you doubled `num_simulations`?
> 2. Why does the histogram skew right rather than form a symmetric bell curve?
> 3. If `starting_savings` were $0, what would change in the simulation and in the chart?  Test it.

### Step B: Send the Chart to a Multimodal Model

You send the PNG to a local multimodal model through the Ollama API and hold a two-turn conversation about it.  The first turn is a structured prompt that sets the model's role, what to look at, the response format, and the audience; the second presses it on a specific quantitative claim.

> **Do this.**
> 1. Add `ask_multimodal_model` and `run_analysis_conversation` to `montecarlo.py`.
> 2. Extend the main block with the two lines shown, then run `python3 montecarlo.py` again.
> 3. Read `model_responses.txt` before Step D.

```python
def ask_multimodal_model(image_b64, question, cfg):
    """Send a base64 PNG and a question to a local multimodal model via Ollama /api/generate; return its text."""
    payload = {"model": cfg["model"], "prompt": question, "images": [image_b64], "stream": False}
    try:
        response = requests.post(cfg["ollama_url"] + "/api/generate", json=payload, timeout=120)
        response.raise_for_status()
        return response.json()["response"]
    except Exception as e:
        print(f"[montecarlo:ask_multimodal_model] {e}")
        traceback.print_exc()
        raise

def run_analysis_conversation(image_b64, cfg):
    """Turn 1: structured four-section analysis. Turn 2: press on the probability estimate. Returns (response1, response2)."""
    initial_prompt = (
        "You are a financial educator analyzing a Monte Carlo retirement simulation "
        "chart for a college student audience with no prior finance background.\n\n"
        "The chart has two panels:\n"
        "- Left panel: 1,000 simulated portfolio paths from age 25 to 65, with a "
        "solid blue median line and two red dashed lines showing the 10th and 90th "
        "percentile bounds.\n"
        "- Right panel: a histogram of final portfolio balances at age 65, with a "
        "vertical blue line at the median and a vertical green dashed line at $1 million.\n\n"
        "Please analyze the chart and respond in exactly four numbered sections:\n"
        "1. What the spread of paths (the gap between the dashed red lines) tells us "
        "about retirement savings risk.\n"
        "2. Your estimate of what percentage of simulations ended above $1 million, "
        "based on the histogram.\n"
        "3. One specific, actionable insight for a 25-year-old starting their career.\n"
        "4. One limitation of this simulation that a tool deployer should disclose to users."
    )
    print("=== Turn 1: Initial Analysis ===")
    response1 = ask_multimodal_model(image_b64, initial_prompt, cfg)
    print(response1)

    # TODO: write a follow-up that presses the model on a specific quantitative claim from Turn 1.
    # The suggested one asks it to show its reasoning for the percentage; numerical precision often breaks down here.
    followup = (
        "Based specifically on the histogram in the right panel, walk me through your "
        "reasoning for the percentage estimate you gave in section 2. What visual "
        "features of the histogram did you use, and how confident are you in that number?"
    )
    print("\n=== Turn 2: Follow-Up ===")
    response2 = ask_multimodal_model(image_b64, followup, cfg)
    print(response2)

    with open("model_responses.txt", "w") as f:
        f.write("=== Turn 1 ===\n" + response1 + "\n\n=== Turn 2 ===\n" + response2 + "\n")
    print("\nSaved: model_responses.txt")
    return response1, response2
```

```python
    # add to the end of the main block
    print("\nRunning multimodal analysis...")
    response1, response2 = run_analysis_conversation(image_b64, cfg)
```

> **You should see.** Two turns printed and saved.  A good Turn 1 notices pattern-level features: the fan widens sharply after age 40, the histogram is right-skewed with many paths below the median, and a concrete suggestion such as "another $100 a month noticeably raises the 10th-percentile outcome."  A flawed Turn 1 says something like *"approximately 68% of simulations reached $1 million"* when `simulation_stats.txt` says 53%: a confident number estimated from visual impression rather than counted.  That is exactly what Step D analyzes.

> **If it fails.**
> - `KeyError: 'response'`: `/api/generate` returns `{"response": ...}`; `/api/chat` returns `{"message": {"content": ...}}`.  Use `/api/generate` here.
> - An empty or very short response: put "Describe the image in detail before analyzing it." as the first sentence of the prompt; some vision models need an explicit grounding instruction.
> - The request times out on a large image: resize before encoding (`from PIL import Image; Image.open(buf).resize((800, 600))`) or lower `dpi` to `100`.

> **Checkpoint.** Before Step C, make sure you can answer:
> 1. What percentage did the model report for simulations reaching $1 million, and what does your statistics file say?  Are they the same?
> 2. In Turn 2, did the model's confidence rise, fall, or hold?  What does that say about follow-up questioning as a verification strategy?
> 3. Did the model's section 4 name a limitation you had not considered?

### Step C: Measure Parameter Sensitivity

> **Do this.**
> 1. Add `run_sensitivity_analysis` to `montecarlo.py`, call it from the main block, and run.  (Editing `config.json` between three runs also works.)
> 2. Record the four statistics for each scenario in your writeup and save the table as `sensitivity_results.txt` or equivalent.
> 3. Answer, with numbers from your runs rather than intuition: which change moved the median more, raising the mean return from 0.07 to 0.10, or lowering the standard deviation from 0.12 to 0.08?

| Configuration | `annual_return_mean` | `annual_return_std` | Label |
|---------------|----------------------|---------------------|-------|
| Pessimistic | 0.04 | 0.15 | Poor market, high volatility |
| Baseline | 0.07 | 0.12 | Historical average (default) |
| Optimistic | 0.10 | 0.08 | Strong market, lower volatility |

```python
def run_sensitivity_analysis(base_cfg):
    """Run the simulation under three parameter configurations and print a comparison table."""
    scenarios = [
        {"label": "Pessimistic",  "annual_return_mean": 0.04, "annual_return_std": 0.15},
        {"label": "Baseline",     "annual_return_mean": 0.07, "annual_return_std": 0.12},
        {"label": "Optimistic",   "annual_return_mean": 0.10, "annual_return_std": 0.08},
    ]
    print(f"\n{'Scenario':<14} {'Median':>14} {'P(>$1M)':>10} {'10th pct':>14} {'90th pct':>14}")
    print("-" * 70)
    for scenario in scenarios:
        cfg = {**base_cfg, **scenario}
        np.random.seed(42)
        final = simulate_retirement(cfg)[:, -1]
        print(f"{scenario['label']:<14} ${np.median(final):>13,.0f} {(final >= 1_000_000).mean():>9.1%} "
              f"${np.percentile(final, 10):>13,.0f} ${np.percentile(final, 90):>13,.0f}")
```

> **You should see.** Median, probability of $1M, and the 10th and 90th percentiles per scenario (yours will vary slightly):

```text
Scenario       Median   P(>$1M)       10th pct       90th pct
----------------------------------------------------------------------
Pessimistic    $  314,042       4.2%   $   73,501   $  877,209
Baseline       $1,042,577      53.2%   $  341,208   $2,847,031
Optimistic     $2,891,044      89.7%   $1,201,330   $5,912,448
```

> **Checkpoint.** Before Step D, make sure you can answer:
> 1. Between pessimistic and baseline the median more than tripled.  What does that say about compounding a moderate improvement in average return over 40 years?
> 2. The pessimistic scenario has a higher `annual_return_std`.  How does higher volatility affect the 10th percentile differently than the median, and why?
> 3. If a user saw only the optimistic chart and made contribution decisions from it, what harm could result?

### Step D: Audit the Model Against Ground Truth

This is the most important step.  In Steps A through C you built a tool; now you evaluate what happens when AI interprets that tool's output, the core lab's audit discipline moved from retrieved text to a rendered chart.

> **Do this.**
> 1. **Read the chart yourself first.** Before re-reading the model's responses, note your own estimates: roughly what percentage of paths end above $1 million, where the median falls, whether the 10th percentile line ever reaches zero during accumulation, and whether the histogram is symmetric, right-skewed, or left-skewed.  Write them down and do not change them afterward.
> 2. **Compare to Turn 1.** Identify **three specific differences** between your reading and the model's.  For each, record the exact AI excerpt (copied from `model_responses.txt`), whether the AI was correct, approximately correct, or wrong, and your best explanation for the discrepancy.  At least one must be a case where the model was **wrong or imprecise about a number**, rather than merely phrased differently.
> 3. **Propose a prompt improvement.** For the numerical error you found, make one change to `initial_prompt` that would have reduced it, re-run Step B, and record whether the response improved.  Strategies worth trying: an explicit disclaimer ("If you cannot read a precise number from the chart, say 'approximately' and give a range"); reasoning before numbers ("Before giving a percentage, describe what you see in the histogram bin by bin"); or restricting scope ("Only comment on what is visually unambiguous.  Flag anything that requires precise numerical reading as uncertain").
> 4. **Write the guardrail.** In 2-3 sentences, write the **guardrail statement** a financial planning tool would show users before the AI's chart analysis, protecting against over-reliance on numerical claims the AI cannot read precisely.

> **Checkpoint.** You have succeeded at this direction when your simulation produces a labeled two-panel PNG and a statistics file; the multimodal model gives a four-section analysis with at least one follow-up exchange; you have identified at least one specific numerical error with an exact AI excerpt; you have proposed and tested a prompt change; and your sensitivity table covers all three configurations with four statistics each.

### Step E: Wrap the Simulation as a Tool (Function-Calling Extension)

In Steps A through D the model only *interpreted* an experiment you designed.  This extension inverts the relationship and bridges to the **Tool Use and Function Calling** session: you wrap the simulation as a tool with a JSON schema, and the model **chooses the parameters**, asks your code to invoke the tool, and then interprets the chart the tool produced.  The model never executes anything; it can only request, and your code runs the simulation.  A fully worked, runnable version (with canned offline responses for machines without Ollama) is in the [companion notebook]({{ site.baseurl }}/files/notebooks/MonteCarloRetirement.ipynb).  `llava` does not support function calling: use a tool-capable model for the parameter-selection turn (`ollama pull llama3.1`, or `qwen2.5`) and keep `llava` for the vision turn.

> **Do this.**
> 1. Refactor Step A into one callable, `run_retirement_sim`.  The new `stock_allocation` parameter blends an equity-like return distribution (mean 8%, std 15%) with a bond-like one (mean 3%, std 5%), giving the agent a meaningful lever.
> 2. Write the tool's JSON schema.  The schema, not your Python, is the tool's entire interface from the agent's point of view; every name, description, and bound shapes what the model chooses.
> 3. Drive the agent loop: POST the goal plus the schema to `/api/chat` with a `tools` array, read the tool call it returns (a function name and JSON arguments), execute `run_retirement_sim` with those arguments, then send the chart to `llava` (and the exact stats dict in the prompt) for interpretation.  Save the goal, the tool call, the tool result, and the interpretation to `tool_call_transcript.txt`.
> 4. **Critique the agent** in your readme, against `simulation_stats.txt` and the tool's returned stats:
>    - **Parameter choices.** The user said "$500 a month" and "retire at 65" starting at 25.  Did `annual_contribution` equal 500 times 12?  Did `years` equal 40?  Is the chosen `stock_allocation` a defensible reading of "fairly aggressive," and did the model justify it?  Mark each correct, approximately correct, or wrong, quoting the tool call verbatim.
>    - **Interpretation.** Compare the narrative to the tool's exact `prob_million` and to the ground truth.  Does "roughly three-quarters" or "more likely than not" match the number?  Quote the sentence and the statistic side by side, as in Step D.
>    - **Compounding risk.** In 2-3 sentences: when one agent both picks parameters and interprets results, how can an early mistranslation (a wrong contribution, an unjustified allocation) compound into a confident but misleading recommendation, and which single check above would you automate as a guardrail?

```python
def run_retirement_sim(years=40, annual_contribution=6000, stock_allocation=0.8, n_paths=1000, seed=42):
    """
    Monte Carlo retirement simulation as a tool. stock_allocation is the fraction 0.0-1.0 in stocks;
    blend: mean = alloc*0.08 + (1-alloc)*0.03, std = alloc*0.15 + (1-alloc)*0.05.
    Returns a dict with keys: median, p10, p90, mean, prob_million, years, annual_contribution,
    stock_allocation, n_paths, seed, chart_path.
    """
    # TODO: build a cfg dict from these arguments (reuse your Step A functions),
    #       call simulate_retirement and plot_simulation, and return the stats dict.

RETIREMENT_TOOL_SCHEMA = {
    "type": "function",
    "function": {
        "name": "run_retirement_sim",
        "description": "Run a Monte Carlo retirement savings simulation and return summary statistics plus a saved two-panel chart.",
        "parameters": {
            "type": "object",
            "properties": {
                "years": {"type": "integer", "minimum": 1, "maximum": 60, "description": "Years of saving before retirement."},
                "annual_contribution": {"type": "number", "minimum": 0, "description": "Dollars contributed per year."},
                "stock_allocation": {"type": "number", "minimum": 0.0, "maximum": 1.0,
                                     "description": "Fraction of the portfolio in stocks; higher raises both expected return and volatility."},
                "n_paths": {"type": "integer", "minimum": 100, "maximum": 10000, "description": "Number of Monte Carlo paths (1000 recommended)."},
                "seed": {"type": "integer", "description": "Random seed for reproducibility."}
            },
            "required": ["years", "annual_contribution", "stock_allocation"]
        }
    }
}

goal = ("I am 25 and want to know whether contributing $500 a month with a fairly aggressive portfolio gives me a good "
        "chance of retiring at 65 with over $1 million. Choose appropriate parameters, run the simulation, and interpret the results for me.")
payload = {
    "model": "llama3.1",
    "messages": [{"role": "system", "content": "You are a retirement planning assistant. Use the simulation tool, "
                                               "choosing parameters that faithfully reflect the user's situation."},
                 {"role": "user", "content": goal}],
    "tools": [RETIREMENT_TOOL_SCHEMA],
    "stream": False,
}
# TODO: POST to /api/chat, read message["tool_calls"][0]["function"],
#       invoke run_retirement_sim(**arguments), and save the goal, the tool call,
#       the tool result, and the interpretation to tool_call_transcript.txt.
```

> **You should see.** A tool call in the response (not prose) with a function name and arguments, a stats dict and chart path from your function, and a `llava` interpretation of that chart.

> **Checkpoint.** Step E is complete when `run_retirement_sim` runs from a single call and returns the stats dict plus a chart path; the model selected parameters via a tool call and your transcript captures the goal, the call, the tool result, and the interpretation; and your critique covers at least one judgment of the parameter choices and one of the interpretation, each backed by a verbatim excerpt and a ground-truth number.

### Direction 2 Deliverables

Fold these into the submission ZIP and readme:

- `montecarlo.py`: complete simulation, visualization, and multimodal analysis code
- `config.json`: your baseline configuration
- `retirement_simulation.png`: the two-panel chart from your baseline run
- `simulation_stats.txt`: the statistics summary from your baseline run
- `model_responses.txt`: both turns of the AI conversation from your baseline run
- `sensitivity_results.txt` or equivalent: the three-scenario comparison table
- `tool_call_transcript.txt`: the Step E transcript: the user goal, the model's tool call (name and arguments), the tool's returned statistics, and the model's interpretation
- Step E critique (in the readme): the agent's parameter choices and its interpretation, each audited against `simulation_stats.txt` and the tool's stats dict, with verbatim excerpts
- A readme section covering: (1) the sensitivity analysis with all three scenarios and four statistics each, (2) the critical analysis with three AI/human comparison items including at least one AI error with a verbatim excerpt, (3) the prompt engineering change you tested and whether it helped, (4) your guardrail statement
- `pair_log.txt`: the driver/navigator swap log with timestamps and roles

**What proficient work looks like.** The simulation is configurable from a JSON file; the visualization includes the median, 10th and 90th percentile bands, and the final-balance histogram, with a text summary saved alongside, and edge cases are handled.  The multimodal integration sends a valid base64 PNG in the `images` array to `/api/generate`, parses `response.json()["response"]`, runs a structured Turn 1 (role, four numbered sections, audience) plus a Turn 2 that presses a specific quantitative claim, and saves both turns.  The comparative analysis names three AI-versus-human differences, at least one a wrong or imprecise number backed by a verbatim excerpt alongside the true value from `simulation_stats.txt`, tests one prompt change and reports whether it helped, and (if the tool-calling extension is attempted) audits both the agent's parameter choices and its interpretation.  The writeup tabulates the four statistics for all three scenarios, states which parameter change moved the median more, judges AI interpretation quality with a verbatim excerpt, and delivers a 2-3 sentence plain-language user-facing guardrail.

### Direction 2 Reflection Prompts

1. What does the spread of simulation paths tell you that a single projected number ("you will have $800,000 at retirement") does not?  Point to a visual feature of your chart that would disappear under a single-path projection.
2. The AI reported a specific probability from the histogram.  How would you verify it, what tools would you need, and what does that challenge say about using AI for quantitative analysis of charts?
3. In the core lab you audited citations against text; here you audited a number against a chart.  Which was harder to verify, and why?
4. In Step C, the pessimistic and optimistic scenarios produced dramatically different outcomes from "reasonable" parameters.  How should a financial planning tool present parameter uncertainty to a non-expert user?
5. If collaboration beyond your pair occurred, identify it.  Do you certify that this submission represents your pair's original work?  Identify any and all portions of your submission that were not originally written by you.
6. Approximately how many hours did this direction take?

---

## Deliverables

> **Bring to class.** Carry your pipeline-in-progress and your stuck points into the open studio in *How I AI* (Part III); it is open build time, and it is only as useful as the problems you bring to it.  Step 5a should be done before you arrive.

Submit one ZIP.  Fix random seeds and list software version information so the work is reproducible, and commit the four Part 5 files in your lab repository with their paths noted in the readme.  Your direction's deliverables (listed in its section) go in the same ZIP and readme.

| File or artifact | What it shows | Rubric row |
|------------------|---------------|------------|
| Code (`rag.py`, `question_set.py`, `demo.py`, `audit.py`) or, on Direction 0, the two exported flow JSONs plus node-settings notes | The pipeline indexes, answers with citations, and abstains; located exception handlers | Pipeline Implementation; Code Quality |
| `config.json` (or the flow JSON) | Model, chunk size, overlap, top-k, and abstention phrase externalized | Code Quality |
| Corpus (or a pointer plus a sample if it is large) and the datasheet | Sources, time range, representation gaps, known limitations | Writeup, Reflection, and Submission |
| Question set with labels (ten or more, at least two unanswerable) | Hand-located ground truth for retrieval | Chunking Strategy; Evaluation |
| Evaluation results (CSV or table): recall@k for k in {1, 3, 5} under both strategies, with the defended choice | The chunking decision rests on numbers | Chunking Strategy and Justification |
| Audit results: the ten-row table, the faithfulness rate, failures verbatim and classified | Citations were checked by hand | Evaluation and Citation Audit |
| Transcripts or log: five cited answers, two abstentions, the bare-model contrast | All three required behaviors | Pipeline Implementation |
| Pair log with at least two timestamped role swaps | Driver/navigator discipline | Writeup, Reflection, and Submission |
| Readme writeup (about two pages) with the route named at the top, the learning log, and reflection answers | Each answer cites a specific experimental result | Writeup, Reflection, and Submission |
| Golden set (`goldenset.json`, the promptfoo YAML case list, or the spreadsheet CSV) | Ten items with question, expected, rule, and rationale | Quality Checkup: Benchmark Design |
| `checkup.md`, with the Part 5 route named at the top | Real measurements from your own pipeline plus the prediction-versus-outcome miss analysis | Quality Checkup: The Checkup Worksheet |
| The harness (run sheet, YAML, or script) with its extended golden set, and the two-run agreement log | The evaluation reruns identically and is committed where the Rubric Pipeline lab can pick it up | Quality Checkup: The Regression Harness |

---

## Self-Check Before You Submit

Held against the rubric's `proficient` column.  On Direction 0, read "code" as "flow configuration" and "log" as "screenshot of the run".  An unchecked box is a specific, fixable thing rather than a vague worry: fix it and check it.

- [ ] All three behaviors are demonstrated: **answer with citation**, **abstention with the designated phrase**, and the **bare-model hallucination contrast**.
- [ ] Two chunking strategies compared on a defined question set.
- [ ] recall@k reported for **k in {1, 3, 5}** for each strategy, in a table.
- [ ] The shipped choice is defended with a **specific numeric comparison**, not a preference.
- [ ] The question set has **at least ten** questions, with recall@k and answer accuracy.
- [ ] At least ten citations audited **by hand** for faithfulness, with a faithfulness rate reported.
- [ ] Every failure shown verbatim and classified with the class hallucination taxonomy.
- [ ] Chunk size, overlap, top-k, abstention threshold, and model name are in a **config file** (or in the exported flow JSON).
- [ ] Located exception handlers with tracebacks on network, embedding, and database calls.
- [ ] Corpus **datasheet** covers sources, time range, representation gaps, and known limitations.
- [ ] Pair log with at least two timestamped role swaps.
- [ ] Every reflection answer cites a specific experimental result of mine.
- [ ] The route I took is named at the top of the writeup.

Part 5, the checkup pathway:

- [ ] Ten benchmark items, with **five** predicted reliable and **five** predicted fragile.
- [ ] The fragile five cover all four kinds of thin territory, including **at least one citation-shaped** item.
- [ ] Every item has `question`, `expected`, a stated `rule`, and a `rationale`.
- [ ] Every rationale names a **training-data reason** (recency, locality, specificity, citation-shaped risk) rather than a difficulty guess.
- [ ] Recall@k measured for **two** chunking configurations, at the **same** `k`, on your own corpus.
- [ ] Relevance judgments were made before seeing the retriever's output.
- [ ] A winner is named, with a reason specific to your corpus.
- [ ] The five-row citation audit has a stated central claim, the cited chunk, and a verdict in every row.
- [ ] At least one **partial** or **unsupported** verdict, or an explicit note that you looked for one and everything checked out.
- [ ] One failure recorded with the query, the output, a hypothesis naming a **stage**, and a fix you could do this week.
- [ ] The pinned harness set is the 5a golden set **plus at least five** corpus-specific items, including at least one **abstention** case.
- [ ] The protocol is written down: temperature, seed, model, chunking configuration, `k`.
- [ ] Two runs, compared, with the comparison pasted.
- [ ] **Every** prediction miss is classified as a knowledge failure or a metric failure, in a sentence.
- [ ] Golden set, `checkup.md`, harness, and two-run log committed in the lab repository, with paths noted.
- [ ] Part 5 route named at the top of `checkup.md`.

---

## Learning Log

Keep a metacognitive learning log for this lab in your readme.  In the spirit of multiple means of action and expression, respond to each prompt in prose, in bullet points, or with an annotated diagram, whichever best conveys your thinking.  (Prompt 4 adapts the AI-Assisted Learning Template by Marc Watkins.)

1. **What I built.** One paragraph, in plain language a friend outside computer science could follow (deliberate practice in writing for multiple audiences).
2. **What surprised me.**
3. **What I verified and how.** Evidence, not vibes.
4. **How I used AI during this lab**, and what I learned from that use.
5. **What I'd tell the next student** before they start.
6. **One open question I still have.**

### Lab-Specific Prompts

- Which failure did you find more often: retrieval fetching the wrong chunk, or generation misusing a correct chunk?  What does that imply about where to invest next: better retrieval, or a stricter generation prompt?
- Your corpus datasheet names who is absent from your documents.  Give a concrete example of a question where that absence would cause your system to abstain incorrectly (the answer exists somewhere but not in your corpus) or answer incorrectly (the corpus holds a biased or incomplete view).  What would you add to the corpus to fix it?
- Which fragile item in your golden set surprised you in either direction, and what does that tell you about your mental model of the training data?
- Which chunking configuration won on your corpus in 5b, and did the margin surprise you?  Does your Part 2 table agree?
- What did the 5b citation audit reveal that the recall@k numbers alone would have hidden?
- If collaboration beyond your pair occurred, identify it.  Do you certify that this submission represents your pair's original work?  Please identify any and all portions of your submission that were not originally written by you.
- Approximately how many hours did this lab take?  (I will not judge you for this at all; I use it to gauge whether the assignments are too easy or too hard.)

---

## Extension Challenges

These are optional and carry no extra credit.

- **Challenge 1 (moderate): Add re-ranking.** After retrieving top-k=10 chunks, re-rank them by asking the model "Does this passage answer the question: [question]?  Answer yes or no." and keep only the top 3 "yes" passages.  Measure whether re-ranking improves recall@3 on your question set.
- **Challenge 2 (harder): Implement hybrid search.** Combine embedding retrieval with BM25 keyword search (install `rank_bm25`).  For each query, take the top-5 from each method, merge the lists (deduplicating by chunk ID), and pass the union to the model.  Report whether hybrid search improves recall@3 over either method alone.
- **Challenge 3 (hardest): Add source freshness metadata.** Add a `last_modified` timestamp to each chunk's metadata (from the file's `mtime`) and modify your generation prompt to prefer recent sources when two chunks conflict.  Demonstrate this on a question where you have two versions of a document with different information.
