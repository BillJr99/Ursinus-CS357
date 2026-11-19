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

Let's ask an agent to find an email we wrote for this exercise. Use a separate personal Gmail account containing only invented messages. Do not connect an Ursinus account or a mailbox you use for real correspondence. If you need to install an agent, see the [OpenCode setup tutorial]({{ site.baseurl }}/Tutorials/OpenCodeSetup) or its [Oh My Pi instructions]({{ site.baseurl }}/Tutorials/OpenCodeSetup#install-oh-my-pi-too). Signing in to a model provider does not give the agent access to Gmail.
{: .tb-lede}

**Choose one path.** [Path A: CLI](#path-a-cli) lets you run the same Gmail command you ask the agent to run. [Path B: MCP](#path-b-mcp) gives the agent one named tool. You run the Python server on your own computer, and the agent connects to it over localhost. Use the CLI if you want fewer moving parts, or MCP if you want to see how the server can limit both the operation and the data the agent receives.

Both live paths need a Google Desktop OAuth client and your approval in a browser. The MCP fixture works without a Google account or credentials. Use a fresh grant with only `https://www.googleapis.com/auth/gmail.readonly`. This scope permits reads across the mailbox, not just the messages your search returns. It does not allow sending mail or changing labels. Do not reuse credentials from a broader grant.

In Gmail's web interface, send an invented message to your test account with the subject `CS357 MCP DEMO`. Complete Google sign-in yourself. Cancel if the screen shows the wrong account or asks for anything beyond Gmail read access. Never give the agent a token, client secret, or browser callback URL in a prompt.

## Path A: CLI

This simulation illustrates the setup and read-only test. It does not sign in to Google or read a mailbox. [Open the CLI terminal simulation]({{ site.baseurl }}/viz/?mode=terminal#cs357-gmailreadonly-cli-terminal).

<iframe title="Gmail read-only CLI terminal simulation" loading="lazy"
  src="{{ site.baseurl }}/viz/?mode=terminal&embed=1#cs357-gmailreadonly-cli-terminal"
  style="width:100%;height:600px;border:1px solid #888"></iframe>

1. **Set up Google OAuth.**

   - In the [Google Cloud console](https://console.cloud.google.com/), create or select a dedicated test project and [enable the Gmail API](https://console.cloud.google.com/apis/library/gmail.googleapis.com).
   - In **Google Auth Platform > [Branding](https://console.cloud.google.com/auth/branding)**, configure the consent screen. Use a name you will recognize when you sign in, such as `CS357 Gmail Read Test`.
   - Under **[Audience](https://console.cloud.google.com/auth/audience)**, choose **External**, keep the app in **Testing**, and add the Gmail test account under **Test users**.
   - Under **[Data Access](https://console.cloud.google.com/auth/scopes)**, add only `https://www.googleapis.com/auth/gmail.readonly`. This scope lets a tool view email and settings across the mailbox. It cannot send mail or change labels. A search filter limits one request, not the account access granted by the scope.
   - Under **[Clients](https://console.cloud.google.com/auth/clients)**, select **Create Client > Desktop app**, name the client, and download its JSON. You can reuse a suitable Desktop client from this dedicated test project, but authorize it afresh. The JSON identifies your app; it does not grant access to your mailbox. That happens when you review the scope and approve it in your browser.

   See Google's guides to [OAuth consent](https://developers.google.com/workspace/guides/configure-oauth-consent), [Desktop app authorization](https://developers.google.com/identity/protocols/oauth2/native-app), and [Gmail scopes](https://developers.google.com/workspace/gmail/api/auth/scopes).

2. **Install the CLI.** Install [`gws` 0.22.5](https://github.com/googleworkspace/cli/tree/v0.22.5#installation) for your operating system. If you use Node.js 18 or later, run `npm install -g @googleworkspace/cli@0.22.5`, then `gws --version`. This route does not need an MCP server. The CLI still needs its own browser sign-in. Do not import a token from the MCP path.

3. **Store the client file.** Create a private local directory outside your project and synced folders. Move the downloaded client JSON there as `client_secret.json`. On Windows, use a new directory under `%LOCALAPPDATA%` and check **Properties > Security**. On macOS or Linux, use a new directory in your home folder with mode `700` and set the file mode to `600`. Set `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` to the private directory path in the terminal you will use. For example:

   - **Windows (PowerShell):** `$env:GOOGLE_WORKSPACE_CLI_CONFIG_DIR = Join-Path $env:LOCALAPPDATA 'CS357-GmailReadOnly'`
   - **macOS and Linux:** `export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/cs357-gmail-readonly"`

4. **Authorize the CLI.** In a terminal without other `gws` credential overrides, authorize the CLI yourself:

   ```text
   gws auth login --scopes https://www.googleapis.com/auth/gmail.readonly
   ```

   Use the exact scope. Plain `gws auth login` can request write access, and `--readonly` can include other Workspace services. See the [CLI authentication guide](https://github.com/googleworkspace/cli/tree/v0.22.5#authentication) for the client file and local credential store.

5. **Run the search yourself.** Run the search below yourself first. `me` refers to the account that approved the grant. The request returns up to three matching message IDs, not message bodies.

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

6. **Test with a Read-Only Request.** From that terminal, change to an empty working directory and launch `opencode` or `omp`. Paste this prompt instead of pasting the command output or any credential:

   > Check my Gmail test inbox using the `gws` CLI. Use the shell tool to run one `gws gmail users messages list` request. Set `userId` to `me`, `q` to `subject:"CS357 MCP DEMO"`, and `maxResults` to `3`. Use quoting for the shell you are running in. Report how many IDs this page returned. Do not fetch message bodies, open credential files, follow links, run other commands, or change anything in Gmail.

## Path B: MCP

1. **Save the server.** In a new local directory, copy the whole box into `gmail_readonly.py`. The server has one tool, `count_demo_messages`. In live mode it asks Gmail for up to three IDs matching the exercise subject and returns a count, not the IDs or message bodies.

   ```python
   import argparse
   import logging
   from pathlib import Path

   import httpx
   from google_auth_oauthlib.flow import InstalledAppFlow
   from mcp.server.fastmcp import FastMCP

   SCOPE = "https://www.googleapis.com/auth/gmail.readonly"
   URL = "https://gmail.googleapis.com/gmail/v1/users/me/messages"
   QUERY = 'subject:"CS357 MCP DEMO"'


   def authorize(client_json: Path) -> str:
       flow = InstalledAppFlow.from_client_secrets_file(
           str(client_json), scopes=[SCOPE], autogenerate_code_verifier=True
       )
       if flow.client_type != "installed":
           raise ValueError("Use a Desktop app OAuth client.")
       logging.getLogger("google_auth_oauthlib.flow").setLevel(logging.WARNING)
       flow.run_local_server(
           host="127.0.0.1", port=0, timeout_seconds=180,
           authorization_prompt_message=None, access_type="online", prompt="consent",
       )
       grant = flow.oauth2session.token
       scopes = grant.get("scope", [])
       if isinstance(scopes, str):
           scopes = scopes.split()
       if scopes != [SCOPE] or not grant.get("access_token"):
           raise ValueError("The token must grant Gmail read-only access only.")
       return grant["access_token"]


   def make_server(token: str | None) -> FastMCP:
       server = FastMCP(
           "CS357 Gmail demo", host="127.0.0.1", port=8795,
           stateless_http=True, json_response=True,
       )

       @server.tool()
       def count_demo_messages() -> dict[str, int | str]:
           """Count up to three matches for the fixed CS357 demo subject."""
           if token is None:
               return {"mode": "fixture", "matches_on_page": 1}
           try:
               with httpx.Client(timeout=10, trust_env=False) as client:
                   response = client.get(
                       URL,
                       headers={"Authorization": "Bearer " + token},
                       params={"q": QUERY, "maxResults": 3, "fields": "messages(id)"},
                   )
                   response.raise_for_status()
                   messages = response.json().get("messages", [])
                   if not isinstance(messages, list) or len(messages) > 3:
                       raise ValueError("Unexpected Gmail response.")
           except (httpx.HTTPError, ValueError, AttributeError):
               raise RuntimeError("Gmail read failed. Check the test grant or restart.") from None
           return {"mode": "gmail", "matches_on_page": len(messages)}

       return server


   if __name__ == "__main__":
       parser = argparse.ArgumentParser()
       parser.add_argument("--client-json", type=Path)
       args = parser.parse_args()
       token = None
       if args.client_json:
           try:
               token = authorize(args.client_json)
           except Exception:
               raise SystemExit("Google sign-in failed or the grant was not Gmail read-only.") from None
       make_server(token).run(transport="streamable-http")
   ```

2. **Install the dependencies.** Use Python 3.11 or later. Run these commands from the directory containing the script. See the [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk/tree/v1.26.0#streamable-http-transport) for the HTTP transport.

   **macOS/Linux:**

   ```bash
   python3 -m venv .venv
   .venv/bin/python -m pip install 'mcp==1.26.0' 'google-auth-oauthlib==1.2.4'
   .venv/bin/python gmail_readonly.py
   ```

   **Windows (PowerShell):**

   ```powershell
   py -3 -m venv .venv
   .\.venv\Scripts\python.exe -m pip install 'mcp==1.26.0' 'google-auth-oauthlib==1.2.4'
   .\.venv\Scripts\python.exe gmail_readonly.py
   ```

   Leave this terminal open. With no arguments, the server runs in fixture mode and never contacts Gmail. Its MCP endpoint is `http://127.0.0.1:8795/mcp`. It does not authenticate local callers, so use it only on a trusted computer. Do not publish, forward, or tunnel the port. The server and coding agent must run in the same environment, including the same side of WSL if you use it.

3. **Connect your coding agent.** Open a second terminal in the same directory. Use the matching configuration below and start the agent there. What the client calls a `remote` server is an HTTP connection, even when the address is your own computer.

   **[OpenCode v2](https://opencode.ai/docs/mcp-servers/)** (`opencode.json`):

   ```json
   {
     "mcp": {
       "servers": {
         "gmail-demo": {
           "type": "remote",
           "url": "http://127.0.0.1:8795/mcp",
           "oauth": false,
           "codemode": false
         }
       }
     }
   }
   ```

   **[Oh My Pi](https://omp.sh/docs/mcp)** (`.omp/mcp.json`):

   ```json
   {
     "mcpServers": {
       "gmail-demo": {"type": "http", "url": "http://127.0.0.1:8795/mcp"}
     }
   }
   ```

4. **Try the fixture.** Check `/mcps` in OpenCode or `/mcp test gmail-demo` and `/tools` in Oh My Pi. Ask the agent to call `count_demo_messages` once. Check the tool trace for `mode: fixture` and `matches_on_page: 1`, not a result from your mailbox.

5. **Authorize your test mailbox.** Close the agent and stop the fixture server with Ctrl+C. Follow **Step 1 of Path A** to set up a Gmail API project and a Desktop OAuth client; skip the rest of Path A. Put the downloaded JSON in a private local directory outside your project and outside synced folders. On Windows, check **Properties > Security**; on macOS/Linux, use a directory with mode `700` and a file with mode `600`.

   Run the same Python command from Step 2, but add `--client-json` followed by the quoted absolute path to the download. In the browser, authorize only the test mailbox and the Gmail read-only permission. The browser's loopback callback is separate from the MCP endpoint. The script checks Google's returned scope before starting the server and keeps the short-lived token in memory. It does not write a token file or refresh the token. The agent configuration needs only the local URL. After authorization, start the agent again from the second terminal.

6. **Test with a Read-Only Request.** Prompt the agent:

   > Check my Gmail test inbox using only `gmail-demo`. Call `count_demo_messages` once. Tell me whether it ran in Gmail or fixture mode and report the count on the first page. Do not use the shell, open messages, or change anything in Gmail.

   Check the tool trace for one call with `mode: gmail`. Compare the count with the test mailbox. If the token expires, stop the server and authorize again yourself. If the trace says `fixture`, you are still connected to the fixture server.

**For either path**, check the tool trace for the requested search. Compare the result with the test mailbox and, for the CLI, your manual run. Stop the turn if the agent proposes a different operation. If the list is empty, check the subject and signed-in test account before changing the query. Do not test the grant by attempting a write.

## Protect the Returned Data

The OAuth scope controls what the tool can do in Gmail. It does not control where the result goes after Gmail returns it. When an agent runs a command, the output can enter its conversation history and be sent to the model provider. Asking the agent to report only a count limits its reply, not what it sees. The CLI search returns message and thread IDs. The local MCP server counts the IDs before returning the result, so the model receives neither IDs nor message metadata. On a real account, even IDs and search results can reveal that someone received mail matching a particular query.

If a task needs only a count, leave message bodies, subjects, senders, attachments, and links out of the tool result. For real data, filter the result locally **before** it reaches the model. A local model can avoid sending the result to a hosted provider, but the agent may still keep local transcripts or pass data to other tools. Do not share a transcript or screenshot that contains mailbox data or credentials.

If you later read a message, treat its content as untrusted. An email might tell the agent to open a link or upload a file. That text is part of the message, not permission to take another action. Read-only Gmail access can stop a Gmail write; it cannot stop a separate shell or browser tool from acting. Review the tool trace and stop any call outside the task.

When you finish, close the agent, remove this test app's access in [Google Account connections](https://myaccount.google.com/connections), and clean up the local setup. For MCP, stop the local server and remove the demo configuration and private client download. For the CLI, remove the exercise's private credential directory. Deleting a configuration or local credential file does not revoke the Google grant.
