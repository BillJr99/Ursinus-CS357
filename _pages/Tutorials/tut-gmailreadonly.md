---
layout: textbook
permalink: /Tutorials/GmailReadOnly
title: "CS357: Foundations of Artificial Intelligence - Read Gmail with OpenCode or Oh My Pi"
info:
  coursenum: CS357
  purpose: "To authorize a Gmail read-only tool and verify one agent request against a test mailbox."
  eyebrow: "Tutorial"
  numbering: false
tags:
- mcp
- oauth
- least-privilege
- security
---

## 5. Get the Google OAuth Credentials

Let's ask an agent to find an email we wrote for this exercise. Use a separate personal Gmail account containing only invented messages. Do not connect an Ursinus account or a mailbox you use for real correspondence. If you need to install an agent, see the [OpenCode setup tutorial]({{ site.baseurl }}/Tutorials/OpenCodeSetup) or its [Oh My Pi instructions]({{ site.baseurl }}/Tutorials/OpenCodeSetup#install-oh-my-pi-too). Signing in to a model provider does not give the agent access to Gmail.
{: .tb-lede}

**Choose one path.** [Path A: MCP](#path-a-mcp) gives the agent two named tools and checks their inputs before calling Gmail. It takes more setup: install a local Python server and register it with your agent. [Path B: CLI](#path-b-cli) works directly in a terminal, including native Windows, and lets you inspect the exact command before the agent runs it. The CLI exposes more commands than this exercise needs. It relies on the OAuth scope and your review of each shell call rather than a two-tool menu. Neither path isolates a same-user shell from your files.

Both paths need a Google OAuth client and a browser grant. Create a Desktop client **once for the path you choose**; you do not need two clients or both tools. The CLI can use an existing suitable Desktop client for this dedicated test project, but a model-provider login does not supply Google credentials. Do not reuse a token from another app or a broader grant.

1. In the [Google Cloud console](https://console.cloud.google.com/), create or select a dedicated test project and [enable the Gmail API](https://console.cloud.google.com/apis/library/gmail.googleapis.com).
2. In **Google Auth Platform > [Branding](https://console.cloud.google.com/auth/branding)**, configure the consent screen. Use a name you will recognize when you sign in, such as `CS357 Gmail Read Test`.
3. Under **[Audience](https://console.cloud.google.com/auth/audience)**, choose **External**, keep the app in **Testing**, and add the Gmail test account under **Test users**.
4. Under **[Data Access](https://console.cloud.google.com/auth/scopes)**, add only `https://www.googleapis.com/auth/gmail.readonly`. This scope lets a tool view email and settings across the mailbox. It cannot send mail or change labels. A search filter limits one request, not the account access granted by the scope.
5. Under **[Clients](https://console.cloud.google.com/auth/clients)**, select **Create Client > Desktop app**, name the client, and download its JSON. The JSON identifies your app; it does not grant access to your mailbox. That happens when you review the scope and approve it in your browser.

See Google's guides to [OAuth consent](https://developers.google.com/workspace/guides/configure-oauth-consent), [Desktop app authorization](https://developers.google.com/identity/protocols/oauth2/native-app), and [Gmail scopes](https://developers.google.com/workspace/gmail/api/auth/scopes).

## 8. Test with a Read-Only Request

In Gmail's web interface, send an invented message to your test account with the subject `CS357 MCP DEMO`. Then follow either A or B. For either path, sign in yourself with the agent closed. Check the test account and cancel if Google asks for write access or access to another service. Do not paste client JSON, tokens, or a browser callback URL into the agent.

### Path A: MCP

Use Python 3.11 or later on macOS, Linux, or Windows Subsystem for Linux (WSL). Run the agent and adapter on the same side of WSL, and keep the credentials in the Linux home directory, not `/mnt/c`. The adapter does not implement native Windows access-control lists; use Path B for native Windows.

1. Open the [adapter source directory](https://github.com/BillJr99/Ursinus-CS357-Fall2026/tree/gh-pages/files/gmail-readonly). Save `gmail_readonly.py`, `requirements.txt`, and the JSON template for your agent as individual files in a new directory outside your existing projects. On GitHub, open each file and choose **Download raw file**. Review the script before running it.
2. From that directory, install the dependencies and check fixture mode. The fixture uses invented data and does not contact Gmail.

   ```bash
   python3 -m venv .venv
   .venv/bin/python -m pip install -r requirements.txt
   .venv/bin/python gmail_readonly.py check --fixture
   ```

3. Create `$HOME/.local/share/cs357-gmail-readonly` with `mkdir -p` and set its mode to `700` with `chmod`. Move the Desktop client download there as `client.json` and set its mode to `600`. Keep both the client file and the generated `token.json` out of Git and synced folders. From the adapter directory, run:

   ```bash
   .venv/bin/python gmail_readonly.py authorize
   .venv/bin/python gmail_readonly.py check
   ```

   The adapter requests `gmail.readonly` and refuses to save a grant if the token response omits that scope or reports additional scopes. The check reads the saved grant record; it is not an independent check of Google's token.
4. Replace both example paths in the downloaded template with absolute paths to your `.venv/bin/python` and `gmail_readonly.py`. Remove the `"--fixture"` argument and its preceding comma to enable the live test. Leave `"serve"` in place. The config contains paths, not credentials.
   - **[OpenCode v2](https://opencode.ai/docs/mcp-servers/):** save `opencode.fixture.json` as `opencode.json` in your demonstration directory. Run `opencode mcp list` there, then start `opencode` and inspect `/mcps`.
   - **[Oh My Pi](https://omp.sh/docs/mcp):** save `omp.fixture.json` as `.omp/mcp.json` in the demonstration directory, creating `.omp` if needed. Start `omp` there and run `/mcp list` and `/mcp test gmail-demo`.
5. Check that `gmail-demo` offers `search_demo` and `read_demo_message`, with no write tool. Then prompt the agent:

   > Use only the `gmail-demo` MCP server. Call `search_demo` once and report how many IDs it returned. Do not read a message, use the shell, or call another service.

### Path B: CLI

Install [`gws` 0.22.5](https://github.com/googleworkspace/cli/tree/v0.22.5#installation) for your operating system. If you use Node.js 18 or later, run `npm install -g @googleworkspace/cli@0.22.5`, then `gws --version`. This route does not need an MCP server. Use the Desktop client from Step 5; the CLI still needs its own sign-in. Do not export or import a token from the MCP adapter.

Create a private local directory outside your project and synced folders. Move the downloaded client JSON there as `client_secret.json`. On Windows, use a new directory under `%LOCALAPPDATA%` and check **Properties > Security**. On macOS or Linux, use a new directory in your home folder with mode `700` and set the file mode to `600`. Set `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` to the private directory path in the terminal you will use. For example:

- **Windows (PowerShell):** `$env:GOOGLE_WORKSPACE_CLI_CONFIG_DIR = Join-Path $env:LOCALAPPDATA 'CS357-GmailReadOnly'`
- **macOS and Linux:** `export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/cs357-gmail-readonly"`

In a terminal without other `gws` credential overrides, authorize the CLI yourself:

```text
gws auth login --scopes https://www.googleapis.com/auth/gmail.readonly
```

Use the exact scope. Plain `gws auth login` can request write access, and `--readonly` can include other Workspace services. See the [CLI authentication guide](https://github.com/googleworkspace/cli/tree/v0.22.5#authentication) for the client file and local credential store.

Run the search below yourself first. `me` refers to the account that approved the grant. The request returns up to three matching message IDs, not message bodies.

**Windows (PowerShell 7.3+, with native argument passing set to Standard):**

```powershell
$PSNativeCommandArgumentPassing = 'Standard'
$params = @{userId='me'; q='subject:"CS357 MCP DEMO"'; maxResults=3} | ConvertTo-Json -Compress
gws gmail users messages list --params $params
```

**macOS and Linux (Bash or Zsh):**

```bash
gws gmail users messages list --params '{"userId":"me","q":"subject:\"CS357 MCP DEMO\"","maxResults":3}'
```

From that terminal, change to an empty working directory and launch `opencode` or `omp`. Paste this prompt instead of pasting the command output or any credential:

> Use the shell tool to run one `gws gmail users messages list` request. Set `userId` to `me`, `q` to `subject:"CS357 MCP DEMO"`, and `maxResults` to `3`. Use quoting for the shell you are running in. Report how many IDs this page returned. Do not fetch message bodies, open credential files, follow links, run other commands, or change anything in Gmail.

**For either path**, check the tool trace for the requested search. Compare the result with the test mailbox and, for the CLI, your manual run. Stop the turn if the agent proposes a different operation. If the list is empty, check the subject and signed-in test account before changing the query. Do not test the grant by attempting a write.

## 9. Protect the Returned Data

The OAuth scope controls what the tool can do in Gmail. It does not control where the result goes after Gmail returns it. When an agent runs a command, the output can enter its conversation history and be sent to the model provider. Asking the agent to report only a count limits its reply, not what it sees. In this exercise, the list request returns message IDs without opening messages. On a real account, even IDs and search results can reveal that someone received mail matching a particular query.

If a task needs only a count, leave message bodies, subjects, senders, attachments, and links out of the tool result. For real data, filter the result locally **before** it reaches the model. A local model can avoid sending the result to a hosted provider, but the agent may still keep local transcripts or pass data to other tools. Do not share a transcript or screenshot that contains mailbox data or credentials.

If you later read a message, treat its content as untrusted. An email might tell the agent to open a link or upload a file. That text is part of the message, not permission to take another action. Read-only Gmail access can stop a Gmail write; it cannot stop a separate shell or browser tool from acting. Review the tool trace and stop any call outside the task.

When you finish, close the agent, remove this test app's access in [Google Account connections](https://myaccount.google.com/connections), and remove the exercise's private credential directory. Deleting local files without revoking access does not revoke the Google grant.
