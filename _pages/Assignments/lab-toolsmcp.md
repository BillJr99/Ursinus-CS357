---
layout: assignment
permalink: /Assignments/ToolsMCP
title: "CS357: Foundations of Artificial Intelligence - Lab: Tools and MCP"

info:
  coursenum: CS357
  purpose: "To connect an agent to a tool server someone else wrote, over the protocol the field is standardizing on, and to do it without ever handing the model, the chat, or a configuration file a password or key."
  tilt:
    task: "Pick an existing MCP server, connect to it either from a short Python client (code route) or by prompting opencode to configure it for you (no-code route), and show the client discovering the server's tools and then calling one.  Sign in, where the server needs it, outside the chat, find where the credential landed, and narrow what the server is allowed to do."
    criteria: "I assess a working discover-then-invoke round trip, a clear account of where your credential lives and how you narrowed the server's reach, and a short writeup on what MCP standardizes and what you are trusting when you run someone else's tool definitions.  The full breakdown is in the rubric below."
  points: 100
  goals:
    - To connect a client to an existing MCP server and show tool discovery followed by a successful invocation
    - To say precisely what MCP standardizes that a hand-rolled tools list does not
    - To keep credentials out of the model's reach and out of the chat, and to name the trust question raised by running someone else's tool definitions
  rubric:
    - weight: 40
      description: "MCP Round Trip"
      preemerging: "No MCP server is connected, or the connection is configured but never used."
      beginning: "A server is connected and some output is shown, but the transcript does not show discovery and invocation as separate steps."
      progressing: "A transcript shows the client listing the server's tools and then one successful call with its result."
      proficient: "As progressing, plus one input or question that should not need the tool, with evidence that the tool was not called for it.  On the code route the evidence is the client's own output; on the no-code route it is the exported opencode session, where each tool call appears as its own entry."
    - weight: 20
      description: "Credentials and Scope"
      preemerging: "A password, key, or token appears in the chat, the configuration file, the code, or the submission."
      beginning: "No secret is exposed, but the writeup does not say where sign-in happened or where the credential is stored."
      progressing: "The writeup says where sign-in happened (browser, device code, or not at all) and where the resulting credential is stored, and shows that it is absent from the configuration and the chat."
      proficient: "As progressing, plus one deliberate narrowing of the server's reach (read-only mode, a tool preset or allowlist, or a project-level rather than global configuration) with the tool list before and after.  A server that needs no sign-in earns this row by explaining why no credential exists and what a public endpoint implies, plus the same narrowing."
    - weight: 25
      description: "Understanding"
      preemerging: "No writeup questions answered."
      beginning: "The questions are answered in general terms that could describe any API."
      progressing: "The writeup says what MCP standardizes, names the trust question, and explains why the tool fired when it did."
      proficient: "As progressing, and each answer points at something in your own transcript or configuration rather than at the protocol in the abstract."
    - weight: 15
      description: "Writeup and Reproducibility"
      preemerging: "No writeup, or one that cannot be followed."
      beginning: "A writeup exists, but a reader could not repeat the connection from it."
      progressing: "The route, the server, the client or configuration, and the commands are recorded well enough to repeat."
      proficient: "Fully reproducible, with the route named at the top and an AI-use disclosure."
  readings:
    - rtitle: "MCP: Connecting Agents to Tools and Your Obsidian Vault"
      rlink: "Activities/liascript-mcp.md"
      liapage: true
    - rtitle: "Hugging Face MCP Course (built with Anthropic): protocol, building a server, connecting clients"
      rlink: "https://huggingface.co/learn/mcp-course/"
    - rtitle: "Optional background: MCP, REST, and OAuth 2.0 Together, for what happens behind the sign-in page"
      rlink: "../Tutorials/MCPOAuth"

tags:
  - lab

---

# Lab: Tools and MCP

In the *Tool Use and Function Calling* session you watched a model ask for a tool and your code run it.  In the *MCP* session you saw the same idea standardized: a **server** advertises its tools, and any MCP-aware **client** can discover them at runtime and call them without anyone writing glue code for that pairing.  This lab is one small, complete step with that idea.  You connect to an MCP server that someone else already wrote, you watch your client discover what it offers, and you make one call.  Along the way you sign in to the server, where it needs it, without ever typing a password or key into a chat window or a configuration file.

You leave with a working connection to a real service, a transcript that shows the protocol doing its job, and a clear answer to two questions that every agent you build from here on will raise: where does my credential live, and what am I trusting when I run someone else's tools?

---

## Choose Your Path

The rubric, the evidence, and the writeup questions are the same on both routes.  What differs is whether you write the client or let an agent configure one for you.

| Route | What you do | What you need | Pick this if |
|-------|-------------|---------------|--------------|
| **Code** | Write a short Python client (about 30 lines) that connects to a server, lists its tools, and calls one | Python 3 and the `mcp` package; `uvx` or `npx` only if you pick a local server | You want to see the protocol's two steps, discovery and invocation, as lines of code you own |
| **No-code** | Prompt opencode to add an MCP server to your project's configuration, review what it wrote, sign in outside the chat, and use the server's tools from a conversation | opencode, and for the OneNote example, Node.js (for `npx`) and a Microsoft account | You want your attention on *when the agent chooses to call a tool* and on where the credential goes, rather than on the plumbing |

> **Watch out.** Do not read the No-code row as "the version without the hard part."  The hard part of this lab is explaining where your credential lives and why the agent called the tool when it did, and those questions are identical on both routes.

---

## Before You Start

- **Code route:** install the official Python SDK and confirm that it imports.  The examples below were tested with version 2.2 of the SDK.

  ```bash
  pip install "mcp>=2"
  python3 -c "import mcp.client.streamable_http; print('mcp ok')"
  ```

- **No-code route:** opencode installed and working (the [OpenCode setup tutorial]({{ site.baseurl }}/Tutorials/OpenCodeSetup) covers this), and a fresh, empty project folder to run it in.  For the OneNote example, also Node.js, so that `npx --version` prints a version.

> **Time budget.** About two hours: thirty minutes to pick a server and connect, thirty to get the transcript you want, and an hour for the writeup.

---

## Step 1: Pick a Server

Every server below is one you can use **without creating an OAuth app, registering anything in a developer portal, or pasting a key**.  They fall into three groups by how you sign in.

| Server | What it reaches | How you sign in | Address or command | Route |
|--------|-----------------|-----------------|--------------------|-------|
| **Microsoft Learn** | Search and read Microsoft's documentation | None | `https://learn.microsoft.com/api/mcp` | Either |
| **DeepWiki** | Ask questions about any public GitHub repository | None | `https://mcp.deepwiki.com/mcp` | Either |
| **Grep by Vercel** | Search code across public GitHub repositories | None | `https://mcp.grep.app` | Either |
| **Context7** | Up-to-date library and framework documentation | None | `https://mcp.context7.com/mcp` | Either |
| **Time** (local) | Current time and time-zone conversion | None; runs on your machine | `uvx mcp-server-time` | Either |
| **Filesystem** (local) | Read files in one folder you name | None; runs on your machine | `npx -y @modelcontextprotocol/server-filesystem <folder>` | Either |
| **Notion** | Your Notion pages and databases | Browser sign-in, handled by opencode | `https://mcp.notion.com/mcp` | No-code |
| **Linear** | Issues and projects in Linear | Browser sign-in, handled by opencode | `https://mcp.linear.app/mcp` | No-code |
| **Asana** | Your Asana tasks and projects | Browser sign-in, handled by opencode | `https://mcp.asana.com/sse` | No-code |
| **Atlassian** | Jira and Confluence | Browser sign-in, handled by opencode | `https://mcp.atlassian.com/v1/sse` | No-code |
| **OneNote** (community server) | Your OneNote notebooks, sections, and pages | Device code, in a terminal | `npx -y @softeria/ms-365-mcp-server --preset onenote` | No-code |

The no-sign-in servers are the quickest path and are a fine choice on either route.  The browser sign-in servers are only worth picking if you already use that service.  The point is to reach your own data, not to create an account for a lab.

> **Why no app registration?**  The browser sign-in servers support *dynamic client registration*.  When opencode first gets a 401 from one of them, it registers itself with the server, opens your browser to the service's own sign-in page, and stores the token it gets back.  The OneNote server ships with its own public client ID and uses the *device code* flow: it prints a short code, you enter that code at Microsoft's sign-in page in your browser, and the server stores the token.  In neither case do you create anything in a developer portal, and in neither case does a secret pass through the chat.  The [MCP, REST, and OAuth 2.0 tutorial]({{ site.baseurl }}/Tutorials/MCPOAuth) explains what is happening behind that sign-in page, if you are curious.

> **OneNote, specifically.**  Microsoft does not publish an official OneNote MCP server.  The example uses `@softeria/ms-365-mcp-server`, an open-source community server, which makes it a good case for the trust question in Part C.  Sign in with a **personal** Microsoft account, and set `MS365_MCP_TENANT_ID=consumers` so the sign-in survives its first refresh.  A college account may be blocked by an administrator-consent screen.  If you see one, switch to a personal account or pick another server; do not ask IT to approve it for a lab.

> **Avoid for this lab.**  Any server whose instructions start with "register an application," "create an OAuth client," or "paste your personal access token into the config."  Those servers work, but they put a long-lived secret in a place you then have to protect, and that is a different lesson.

---

## Part A: Code Route

### Step A.1: Write the Client

An MCP session always follows the same three moves:

1. **Initialize.**  The client and server agree on a protocol version.
2. **Discover.**  The client asks `tools/list` and receives each tool's name, description, and input schema.
3. **Invoke.**  The client sends `tools/call` with a tool name and arguments, and receives a result.

The SDK wraps each move in one method call.  Save the following as `mcp_client.py`.  It connects to the Microsoft Learn server, which needs no sign-in.

```python
import asyncio
import json
import traceback

from mcp import ClientSession
from mcp.client.streamable_http import streamable_http_client

SERVER_URL = "https://learn.microsoft.com/api/mcp"


async def main():
    # Open an HTTP connection to the server.  The connection hands back two streams:
    # one we read the server's messages from, and one we write ours to.
    async with streamable_http_client(SERVER_URL) as (read, write, *_):
        async with ClientSession(read, write) as session:
            await session.initialize()                       # move 1: agree on a protocol version

            listing = await session.list_tools()             # move 2: tools/list
            print(f"Discovered {len(listing.tools)} tools:")
            for tool in listing.tools:
                print(f"- {tool.name}: {(tool.description or '').splitlines()[0][:80]}")
                print(f"  arguments: {json.dumps(tool.input_schema.get('properties', {}))[:160]}")

            result = await session.call_tool(                # move 3: tools/call
                "microsoft_docs_search", {"query": "What is the Model Context Protocol?"}
            )
            print("\nResult (first 400 characters):")
            print(result.content[0].text[:400])


try:
    asyncio.run(main())
except Exception as e:
    print("[mcp_client:main]", e)
    traceback.print_exc()
```

Notice what is **not** in this file.  There is no list of tools, no description of `microsoft_docs_search`, and no schema for its arguments.  The client learned all of that from the server at runtime.  That is the thing a hand-rolled `tools` list cannot do, and Part C asks you to say why it matters.

Run it:

```bash
python3 mcp_client.py
```

> **You should see.**  Three tools, then the opening of a search result.  The descriptions and the result text change as Microsoft updates its documentation:

```text
Discovered 3 tools:
- microsoft_docs_search: Search official Microsoft/Azure documentation to find the most relevant and trus
  arguments: {"query": {"description": "a query or topic about Microsoft/Azure products, services, platforms, developer tools, frameworks, or APIs", "type": "string", "defau
- microsoft_code_sample_search: Search for code snippets and examples in official Microsoft Learn documentation.
  arguments: {"query": {"description": "a descriptive query, SDK name, method name or code snippet related to Microsoft/Azure products, services, platforms, developer tools,
- microsoft_docs_fetch: Fetch and convert a Microsoft Learn documentation webpage to markdown format. Th
  arguments: {"url": {"description": "URL of the Microsoft documentation page to read", "type": "string"}}

Result (first 400 characters):
{"results":[{"title":"Data agent as Model Context Protocol server","content":"# Data agent as Model Context Protocol server\nThe Model Context Protocol (MCP) is an emerging standard ...
```

> **If it fails.**  `ModuleNotFoundError: No module named 'mcp'` means the install went to a different Python; run `python3 -m pip install "mcp>=2"`.  `ImportError: cannot import name 'streamable_http_client'` means you have the older 1.x SDK, where the function was spelled `streamablehttp_client`; upgrade, or use that spelling.  A connection error from inside the course container means that container cannot reach the internet; try it on your host.

### Step A.2: Point It at Your Server

If you picked a different **remote** server from the table, change `SERVER_URL`, run the client once to see the tool list, and then change the `call_tool` line to use one of the names and argument shapes you just discovered.

If you picked a **local** server, the server runs as a process on your machine and talks over its standard input and output (*stdio*) instead of HTTP.  Replace the import and the first `async with` line.  The rest of the file does not change, and that is the point of the protocol:

```python
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

SERVER = StdioServerParameters(command="uvx", args=["mcp-server-time"])

async def main():
    async with stdio_client(SERVER) as (read, write):
        async with ClientSession(read, write) as session:
            ...  # initialize, list_tools, call_tool exactly as before
```

For the time server, a call such as `session.call_tool("get_current_time", {"timezone": "America/New_York"})` returns the current time in that zone.  Check the names and argument shapes against your own discovery output rather than trusting this page.

> **Do this first.**  The first time `uvx` runs a server, it downloads the server and its dependencies, and the client can give up waiting before the download finishes.  Fetch the server once by hand before you run the client:
>
> ```bash
> uvx mcp-server-time --help
> ```

> **You should see.**  Two tools, then the current time in New York.  Your timestamp will differ:

```text
Discovered 2 tools:
- get_current_time: Get current time in a specific timezone
  arguments: {"timezone": {"type": "string", "description": "IANA timezone name (e.g., 'America/New_York', 'Europe/London'). Use 'Etc/UTC' as local timezone if no timezone p
- convert_time: Convert time between timezones
  arguments: {"source_timezone": {"type": "string", "description": "Source IANA timezone name (e.g., 'America/New_York', 'Europe/London'). Use 'Etc/UTC' as local timezone if

Result:
{
  "timezone": "America/New_York",
  "datetime": "2026-10-15T11:39:33-04:00",
  "day_of_week": "Thursday",
  "is_dst": true
}
```

> **Paste into your submission.**  Your final `mcp_client.py` and its full output.

### Step A.3: Show When the Tool Should Not Fire

Your client calls the tool because you told it to.  An agent decides for itself.  Show both sides of that decision with the smallest possible experiment: write down two questions, one that the server's tools can answer and one that they cannot (for Microsoft Learn, "how do I create an Azure storage account?" against "what is 17 times 23?").  For each, say which tool, if any, an agent *should* call and with what arguments, and justify it from the tool descriptions your client printed.  That is the input the model would have to decide from.

> **Go further (ungraded).**  Hand the discovered tools to a local model and let it choose.  Convert each discovered tool into the function-calling format from the *Tool Use* session (`name`, `description`, and `parameters` set to `tool.input_schema`), send both questions to Ollama with `qwen2.5:3b` and those tools attached, and when the model asks for a tool, run it with `session.call_tool` and feed the result back.  Did the model's choices match your predictions?

---

## Part B: No-code Route

### Step B.1: Ask opencode to Configure the Server

Open a terminal in a fresh, empty project folder and start opencode there.  Give it a prompt that says which server, where the configuration goes, how narrow it should be, and what it must not ask you for.  Here is the OneNote version; adapt the server line for any other server in the table:

```text
Add the OneNote MCP server to this project's opencode.json (not my global config).
Use the community server @softeria/ms-365-mcp-server, run with npx, limited to the
OneNote preset and in read-only mode, for a personal Microsoft account
(MS365_MCP_TENANT_ID=consumers).
Do not ask me for any password, key, client secret, or token, and do not put one in
the file. I will sign in myself, outside this chat.
Show me the file before you save it.
```

For a remote server with browser sign-in, the prompt is shorter, because opencode handles the sign-in itself: *"Add the Notion MCP server at https://mcp.notion.com/mcp to this project's opencode.json as a remote server. Do not ask me for any key or token; I will run `opencode mcp auth` myself."*

### Step B.2: Read What It Wrote Before You Accept It

An MCP configuration entry is a command that will run on your machine, or an address your agent will send data to.  Read it the way you would read a script someone emailed you.  For the OneNote prompt, a good result looks like this:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "onenote": {
      "type": "local",
      "command": ["npx", "-y", "@softeria/ms-365-mcp-server", "--preset", "onenote", "--read-only"],
      "environment": { "MS365_MCP_TENANT_ID": "consumers" },
      "enabled": true
    }
  }
}
```

Before you accept it, answer three questions in your notes:

- What exact command or address will run?
- Is there anything secret in the file?  There should not be.
- Which flag or field limits what the server can do?

If opencode put a placeholder such as `"YOUR_TOKEN_HERE"` in the file, or asked you to paste one, say no and repeat the constraint.

### Step B.3: Sign In Outside the Chat

Quit opencode, then sign in from a terminal.

- **OneNote (device code):**

  ```bash
  MS365_MCP_TENANT_ID=consumers npx -y @softeria/ms-365-mcp-server --login
  ```

  It prints a web address and a short code.  Open the address in your browser, enter the code, and sign in with your personal Microsoft account.  The terminal reports success, and the server stores the token encrypted on your machine.

- **Browser sign-in servers (Notion, Linear, Asana, Atlassian):**

  ```bash
  opencode mcp auth notion      # use the name from your opencode.json
  ```

  Your browser opens the service's own sign-in and consent page.  Read what it asks permission for before you click Allow.  The note in your writeup about what you granted is part of the Credentials row.

- **No-sign-in servers:** skip this step, and say in your writeup why no credential was needed.

### Step B.4: Discover, Then Use

Confirm that opencode can see the server, then start it again:

```bash
opencode mcp list
```

In a new opencode session, ask:

1. *"What tools does the onenote server give you?"*  This is discovery.
2. A question that needs the server, such as *"List the sections in my notebook called Personal."*  This is invocation.
3. A question that does not, such as *"What is 17 times 23?"*  The tool should not fire.

Export the session with `/export`, which opens the conversation as Markdown in your editor, and save it, so the tool calls appear as their own entries.  A screenshot of the final answer is not enough; the evidence is the record of the tool being called, or not called.

### Step B.5: Find the Credential, Then Clean Up

Find out where the credential went.  opencode stores browser sign-in tokens in `~/.local/share/opencode/mcp-auth.json`; the OneNote server keeps its own in an encrypted file under `~/.config/ms-365-mcp-server/` on Linux, `~/Library/Application Support/ms-365-mcp-server/` on macOS, or `%APPDATA%\ms-365-mcp-server\` on Windows, with the encryption key held in your operating system's credential store.  **Do not open the file or paste its contents anywhere.**  It is enough to show that it exists (`ls -l` on the file) and that `opencode.json` contains no secret.

When you are done, sign out: `opencode mcp logout <name>` for browser sign-in servers, or `npx -y @softeria/ms-365-mcp-server --logout` for OneNote.  Then revoke the app's access in the service's own account settings.

---

## Part C: Both Routes, the Writeup

Answer each question in a short paragraph, and point at your own transcript or configuration as you go.

1. **What MCP standardizes.**  Your client or agent learned the server's tool names, descriptions, and argument schemas at runtime.  What would you have had to write by hand without MCP, and what would break the next time the server added or renamed a tool?
2. **Where the credential lives.**  Where did sign-in happen, where is the resulting token stored, and who can read it?  What would have been different if you had pasted a key into `opencode.json` or into the chat?  For a no-sign-in server: why is there no credential, and what does a public endpoint imply about what you should send it?
3. **How you narrowed it.**  What did you do to limit the server's reach (read-only, a preset, project-level configuration, a single folder), and what disappeared from the tool list when you did?  Include the tool list before and after.
4. **The trust question.**  You ran tool definitions that someone else wrote, and those descriptions go straight into your model's context.  What could a malicious or careless server do with that, and what in your setup limits it?
5. **When the tool fired.**  For your two questions, why did the tool fire, or should it fire, for one and not the other?  Which words in the tool's description made the difference?

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| The client or opencode lists zero tools | The server is not running, the command in the configuration is wrong, or the address is mistyped | For a local server, run its command by hand first and check that it starts.  For a remote one, run `opencode mcp debug <name>` |
| A 401, or a sign-in page that loops | You have not signed in yet, or the token expired | Run `opencode mcp auth <name>` again, or rerun the OneNote `--login` command |
| "Need admin approval" at the Microsoft sign-in | A college account whose administrators restrict third-party apps | Use a personal Microsoft account, or pick another server |
| A local server fails on the first run with `Connection closed` | `uvx` or `npx` was still downloading the server when the client gave up waiting | Run the server's command once by hand (for example `uvx mcp-server-time --help`), then run the client again |
| `uvx: command not found` or `npx: command not found` | uv or Node.js is not installed | Install uv (`pip install uv`) or Node.js, or pick a remote server instead |
| The agent answers from memory and never calls the tool | The question does not match the tool's description, or the model was not told the tools exist | Ask more specifically, or ask first what tools it has.  Note it in Part C, question 5: it is a finding, not a failure |
| A local server works on your host but not from inside the course container | Inside a container, `localhost` and the installed programs are the container's own | Run the client, and the server it launches, on the same side of the container wall |

---

## Deliverables

| File or artifact | What it shows | Rubric row |
|------------------|---------------|------------|
| Code: `mcp_client.py` and its full output.  No-code: the reviewed `opencode.json` and the exported session | Discovery, then a successful invocation, and a question where the tool did not fire | MCP Round Trip (40) |
| How you signed in, where the credential is stored (a file listing, not its contents), and the tool list before and after your narrowing | The credential is outside the chat and the config, and the server's reach is deliberate | Credentials and Scope (20) |
| Answers to the five Part C questions | What MCP standardizes, what you are trusting, and why the tool fired | Understanding (25) |
| A writeup with the route and the server named at the top, the commands you ran, and an AI-use disclosure | A reader could repeat your connection | Writeup and Reproducibility (15) |

---

## Self-Check Before You Submit

- [ ] The route and the server are named at the top of the writeup.
- [ ] The transcript shows the tool list first, and then one successful call with its result.
- [ ] One question where the tool did not fire, or should not, with the reason.
- [ ] No password, key, or token appears anywhere in the submission, the configuration, or the chat.
- [ ] The writeup says where you signed in and where the credential is stored, or why there is none.
- [ ] One narrowing of the server's reach, with the tool list before and after.
- [ ] All five Part C questions are answered, each pointing at your own evidence.
- [ ] You signed out and revoked access when you were done (sign-in servers only).
