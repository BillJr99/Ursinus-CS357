---
layout: textbook
permalink: /Tutorials/PythonEssentials
title: 'CS357: Foundations of Artificial Intelligence - Python Essentials for the Labs'
info:
  coursenum: CS357
  purpose: "To collect in one place the Python that the course's code routes use, each idea with a small example you can run."
  eyebrow: "Tutorial"
  numbering: false
tags:
- python
- reference
---
*The Python this course's code routes use, one small example at a time.*

You do not need to read this from top to bottom.  Each section stands alone, and a lab links to the one it uses.  If you have taken an introductory programming course, most of it will look familiar.  What may be new is how often a model's answer arrives as text that you have to turn into data, and that is where these pieces come together.

Run the examples with `python3`.  Type them into the interactive prompt, or save them in a file.

## Keeping a Project's Packages Together: `venv`

A **virtual environment** gives one project its own Python and its own packages, so that installing something for one lab cannot break another.  It is a folder, usually named `.venv`.

```bash
python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
python3 -m pip install requests
python3 -c "import requests; print('requests ok')"
```

You should see `requests ok`.  Run the `source` line again in each new terminal, because activating lasts only as long as the terminal does.

**Two errors you may meet.**

- `externally-managed-environment`: your operating system manages its own Python (common on Ubuntu, Debian, WSL, and Homebrew), so it refuses packages installed directly into it, because they could break the tools that depend on it.  The virtual environment above is the fix.  Do not use `--break-system-packages`.
- `ensurepip is not available` when you make the environment: on Ubuntu, Debian, and WSL, virtual environments come in a separate package.  Run `sudo apt install python3-venv`, delete the partial folder with `rm -rf .venv`, and start again.  If that package name is not found, use the version-specific name the error message gives you.

Add `.venv/` to your `.gitignore`, because it is large and each person rebuilds it.

## Lists and Dictionaries

A **list** keeps items in order.  A **dictionary** (`dict`) looks up a value by a key.  Nearly every API in this course sends and receives these two shapes, nested inside each other.

```python
message = {"role": "user", "content": "Hello"}
print(message["role"])              # look up one key
print(message.get("tool", "none"))  # .get gives a default when the key is missing

messages = []                       # an empty list
messages.append(message)            # add to the end
messages.append({"role": "assistant", "content": "Hi!"})
print(len(messages))
print(messages[-1]["content"])      # the last item, then one of its keys

for m in messages:
    print(m["role"], "said", m["content"])
```

You should see:

```text
user
none
2
Hi!
user said Hello
assistant said Hi!
```

Use `message["role"]` when a missing key would be a bug, so that it fails loudly.  Use `.get` when a missing key is normal.

## Building a List in One Line

A **list comprehension** makes a new list from an old one, and it can filter along the way.

```python
words = ["agent", "", "tool", "loop", ""]
print([w.upper() for w in words if w])
```

You should see `['AGENT', 'TOOL', 'LOOP']`.  Read it as "`w.upper()`, for each `w` in `words`, if `w` is not empty."  An empty string counts as false, so `if w` drops the blanks.  This pattern is how you remove empty pieces after you split text.

## Building Strings

An **f-string** puts values inside text, with the values in curly braces.

```python
name, score = "planner", 0.8765
print(f"{name} scored {score:.2f}")
```

You should see `planner scored 0.88`.  The `:.2f` means two decimal places.  Use this to build prompts and to build ID strings from a file name and a number.

To cut text apart, use `split`, and to clean its ends, use `strip`:

```python
text = "first paragraph\n\n  second paragraph  \n\n"
print([p.strip() for p in text.split("\n\n") if p.strip()])
```

You should see `['first paragraph', 'second paragraph']`.  A blank line is two newlines in a row, so `split("\n\n")` separates paragraphs.

## Files and Folders with `pathlib`

```python
from pathlib import Path

folder = Path("demo_notes")
folder.mkdir(exist_ok=True)
(folder / "a.txt").write_text("alpha\n", encoding="utf-8")
(folder / "b.txt").write_text("beta\n", encoding="utf-8")

for doc in sorted(folder.glob("*.txt")):
    print(doc.name, doc.stem, doc.read_text(encoding="utf-8").strip())
```

You should see:

```text
a.txt a alpha
b.txt b beta
```

`doc.name` is the file's whole name, and `doc.stem` is its name without the extension.  `sorted` keeps the order the same on every machine, because `glob` promises no order.

## JSON: Data as Text

**JSON** is how programs and models pass structured data as text.  `json.loads` turns text into Python, and `json.dumps` turns Python into text.

```python
import json

reply = '{"action": "lookup", "args": {"term": "agent"}}'
data = json.loads(reply)
print(data["action"], data["args"]["term"])
print(json.dumps({"ok": True, "n": 3}))
```

You should see:

```text
lookup agent
{"ok": true, "n": 3}
```

A model's reply is only text, so it is not always valid JSON.  Parse it inside a `try`, as the next section shows.

## When Things Go Wrong: `try` and `except`

```python
import json

def parse_reply(text):
    try:
        return json.loads(text)
    except json.JSONDecodeError as e:
        print("not JSON:", e.msg)
        return None

print(parse_reply('{"ok": 1}'))
print(parse_reply("Sure! Here is the JSON"))
```

You should see:

```text
{'ok': 1}
not JSON: Expecting value
None
```

Catch the error you expect, and say what happened.  A bare `except:` that prints nothing hides the failure you most need to see.

## Calling a Model over HTTP

`requests.post` sends JSON to a server and gives back its response.  This is the call underneath every local model lab, and the [RESTful LLM Access tutorial]({{ site.baseurl }}/Tutorials/RESTLLMAPI) goes further with it.

```python
import requests

response = requests.post(
    "http://localhost:11434/api/chat",
    json={"model": "llama3.2", "stream": False,
          "messages": [{"role": "user", "content": "Say hi in three words."}]},
    timeout=120,
)
response.raise_for_status()              # stop here on an HTTP error
print(response.json()["message"]["content"])
```

This needs Ollama running with `llama3.2` pulled, and the reply will vary.  `raise_for_status` turns a failed request into an error you can see, and `.json()` applies `json.loads` for you.

## Finding Text with `re`

A **regular expression** describes a pattern in text.  `re.findall` returns every match, as a list.

```python
import re

text = "SCORE: 3\nsome reasoning\nSCORE: 5"
print(re.findall(r"SCORE:\s*(\d+)", text))
```

You should see `['3', '5']`.  `\s*` means any amount of space, `\d+` means one or more digits, and the parentheses mark the part you want returned.  The last match is `matches[-1]`, which is the one you want when a model states an answer more than once, and an empty list means there was no match.

## Counting with `Counter`

```python
from collections import Counter

votes = Counter(["red", "blue", "red"])
print(votes)
print(votes.most_common(1))
print(votes.most_common(1)[0][0])
```

You should see:

```text
Counter({'red': 2, 'blue': 1})
[('red', 2)]
red
```

`most_common(1)` is a list holding one pair, which is why reaching the winner takes `[0][0]`.

## Arrays with NumPy

An embedding is a list of numbers, and NumPy does arithmetic on whole lists at once.  Install it with `python3 -m pip install numpy`.

```python
import numpy as np

vectors = np.array([[3.0, 4.0], [0.0, 2.0], [1.0, 0.0]])
lengths = np.linalg.norm(vectors, axis=1, keepdims=True)
normed = vectors / lengths                  # every row now has length 1
print(normed[0])
group = [0, 1]                              # a list of row numbers
print(normed[group])                        # just those rows
average = normed[group].mean(axis=0)        # average down the columns
print(average)
print(round(float(normed[0] @ normed[1]), 2))
print(int(np.argmax([0.2, 0.9, 0.5])))
```

You should see:

```text
[0.6 0.8]
[[0.6 0.8]
 [0.  1. ]]
[0.3 0.9]
0.8
1
```

`@` multiplies matching entries and adds them up.  When both vectors have length 1, that number is their **cosine similarity**: near 1 means they point the same way.  `np.argmax` gives the position of the largest value.  The [Tokens and Embeddings tutorial]({{ site.baseurl }}/Tutorials/TokensEmbeddingsAttention) explains why this measures meaning.

## `async` and `await`

Some libraries, including the MCP SDK, are **asynchronous**: a call can wait on a network without holding up the whole program.  You mainly need to recognize the shape.

```python
import asyncio

async def fetch(name):
    await asyncio.sleep(0.01)       # stand-in for waiting on a server
    return f"got {name}"

async def main():
    print(await fetch("tools"))

asyncio.run(main())
```

You should see `got tools`.  Three rules cover it.  You define such a function with `async def`.  You call it with `await`, which works only inside another `async def`.  And you start the outermost one with `asyncio.run`.  `async with` is the same idea applied to `with`: it opens something over the network, and it closes it again when the block ends.
