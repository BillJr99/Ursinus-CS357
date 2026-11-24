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

**Choose one path.** All three end with the agent reporting how many test messages match, and each puts a different piece of software between the agent and your mailbox.

- [Path A: CLI](#path-a-cli). The agent composes a `gws` command line in its shell, and Google's Workspace CLI talks to Gmail. You can run the same command yourself first, but the CLI offers far more commands than this exercise needs.
- [Path B: Self-hosted MCP](#path-b-self-hosted-mcp). You run your own small MCP server: a Python process on your computer that holds the Gmail grant and offers the agent one named tool. The agent connects to it over streamable HTTP at `http://127.0.0.1:8795/mcp` and never runs a Gmail command itself. It has a fixture mode that works with no Google account at all.
- [Path C: Hosted MCP](#path-c-hosted-mcp). The agent connects straight to Google's own Gmail MCP server at `https://gmailmcp.googleapis.com/mcp/v1`. There is nothing to install, but the service is a [Google Workspace Developer Preview](https://developers.google.com/workspace/preview), and Google's server offers write tools as well as reads.

Use the CLI if you want fewer moving parts, the self-hosted server if you want to see how a server can limit both the operation and the data the agent receives, and the hosted server if your project has preview access and you want to see what a vendor-run MCP server looks like.

Paths A and B use the Google **Desktop app** OAuth client from the shared setup below; Path C uses a **Web application** client, which its own steps create. Every live path asks for a fresh grant with only `https://www.googleapis.com/auth/gmail.readonly`. This scope permits reads across the mailbox, not just the messages your search returns. It does not allow sending mail or changing labels. Do not reuse credentials from a broader grant.

In Gmail's web interface, send an invented message to your test account with the subject `CS357 MCP DEMO`. Complete Google sign-in yourself. Cancel if the screen shows the wrong account or asks for anything beyond Gmail read access. Never give the agent a token, client secret, or browser callback URL in a prompt.

## Shared Setup: Google Cloud and Gmail OAuth

Complete this setup once if you plan to read a test mailbox with Path A or Path B. Path C starts from the same kind of project but needs one more API and a different client, which its own steps cover. If you only want to try the MCP fixture, skip to [Path B](#path-b-self-hosted-mcp); the fixture needs no Google project, credentials, or sign-in.

The browser console is enough for this step. If you want to check or enable the Gmail API from a terminal, use the Google Cloud CLI (`gcloud`). `gcloud` manages the Cloud project; the Google Workspace CLI (`gws`) reads the test mailbox. Each has its own sign-in.

**Optional: install and sign in to `gcloud` on Ubuntu or Ubuntu under WSL.** If `gcloud --version` already works, skip the install block. If you installed Google's archive under `~/google-cloud-sdk` and Bash cannot find `gcloud`, run `source "$HOME/google-cloud-sdk/path.bash.inc"` in this shell. For other systems, see the [Google Cloud CLI install guide](https://docs.cloud.google.com/sdk/docs/install).

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg |
  sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
printf '%s\n' 'deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main' |
  sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update
sudo apt-get install google-cloud-cli
gcloud --version
```

Run `gcloud auth login --brief` yourself and finish the [Cloud CLI sign-in](https://docs.cloud.google.com/sdk/gcloud/reference/auth/login) in your browser. Keep the terminal and the browser flow private. This signs you in to manage Cloud resources; it does not authorize `gws` to read Gmail.

- **Choose a Cloud project for the Gmail OAuth client.** If you already have a dedicated test project you can manage, use its project ID. Otherwise, open the [New Project page](https://console.cloud.google.com/projectcreate), give the project a display name such as `CS357 Gmail Read Test`, and click **Create**. Note the project ID, which is different from the display name. You can also [create the project with `gcloud`](https://docs.cloud.google.com/sdk/gcloud/reference/projects/create) after signing in:

  ```bash
  read -r -p 'Choose a globally unique Cloud project ID: ' PROJECT_ID
  gcloud projects create "$PROJECT_ID" --name='CS357 Gmail Read Test'
  ```

  The Cloud project will contain the Gmail API setting, consent configuration, and Desktop OAuth client. `gcloud auth login` uses its own sign-in flow and does not need the Desktop client you are about to create. If your account cannot create projects, use a dedicated test project you have permission to manage rather than changing your organization's settings.

- **Enable Gmail in that project.** Select the project in the [Cloud console and enable the Gmail API](https://console.cloud.google.com/apis/library/gmail.googleapis.com), or use the commands below. Enter the same project ID for every step. Run the enable command only if the check succeeds but does not list Gmail. Skip `gws auth setup` for this exercise so you do not enable unrelated APIs.

  ```bash
  read -r -p 'Test Cloud project ID: ' PROJECT_ID
  gcloud services list --enabled --project="$PROJECT_ID" --filter='config.name=gmail.googleapis.com' --format='value(config.name)'
  ```

  ```bash
  gcloud services enable gmail.googleapis.com --project="$PROJECT_ID"
  ```
- In **Google Auth Platform > [Branding](https://console.cloud.google.com/auth/branding)**, configure the consent screen. Use a name you will recognize when you sign in, such as `CS357 Gmail Read Test`.
- Under **[Audience](https://console.cloud.google.com/auth/audience)**, choose **External**, keep the app in **Testing**, and add the Gmail test account under **Test users**.
- Under **[Data Access](https://console.cloud.google.com/auth/scopes)**, add only `https://www.googleapis.com/auth/gmail.readonly`. This scope lets a tool view email and settings across the mailbox. It cannot send mail or change labels. A search filter limits one request, not the account access granted by the scope.
- Under **[Clients](https://console.cloud.google.com/auth/clients)**, select **Create Client > Desktop app**, name the client, and download its JSON. You can reuse a suitable Desktop client from this dedicated test project, but authorize it afresh. The JSON identifies your app; it does not grant access to your mailbox. That happens when you review the scope and approve it in your browser.

See Google's guides to [OAuth consent](https://developers.google.com/workspace/guides/configure-oauth-consent), [Desktop app authorization](https://developers.google.com/identity/protocols/oauth2/native-app), and [Gmail scopes](https://developers.google.com/workspace/gmail/api/auth/scopes).


## Path A: CLI

This simulation replays the shared setup, then follows the CLI path. It does not sign in to Google or read a mailbox. [Open the CLI terminal simulation]({{ site.baseurl }}/viz/?mode=terminal#cs357-gmailreadonly-cli-terminal).

<iframe title="Gmail read-only CLI terminal simulation" loading="lazy"
  src="{{ site.baseurl }}/viz/?mode=terminal&embed=1#cs357-gmailreadonly-cli-terminal"
  style="width:100%;height:600px;border:1px solid #888"></iframe>

1. **Install the CLI.** Install [`gws` 0.22.5](https://github.com/googleworkspace/cli/tree/v0.22.5#installation) for your operating system. If you use Node.js 18 or later, run `npm install -g @googleworkspace/cli@0.22.5`, then `gws --version`. This route does not need an MCP server. The CLI still needs its own browser sign-in. Do not import a token from the MCP path.

   **Ubuntu 22.04 WSL: if `gws --version` reports `GLIBC_2.39` not found.** Check `uname -m` and `getconf GNU_LIBC_VERSION`. Ubuntu 22.04 can report `glibc 2.35`. If the error persists after reinstalling `gws` 0.22.5 with npm, the block below is for **x86_64 only**, with npm running under nvm. It uses the matching [musl release](https://github.com/googleworkspace/cli/releases/tag/v0.22.5), which does not need the newer system glibc. Leave system glibc alone. On another architecture or version, use the official release that matches both.

   ```bash
   (
     set -eu
     test "$(uname -m)" = x86_64
     prefix=$(npm prefix -g)
     case "$prefix" in "${NVM_DIR:-$HOME/.nvm}"/versions/node/*) ;; *) exit 1 ;; esac
     pkg="$(npm root -g)/@googleworkspace/cli"
     test "$(node -p 'require(process.argv[1]).version' "$pkg/package.json")" = 0.22.5
     test "$(command -v gws)" = "$prefix/bin/gws"
     test -f "$pkg/bin/gws" && test ! -L "$pkg/bin/gws"
     work=$(mktemp -d)
     cd "$work"
     asset=google-workspace-cli-x86_64-unknown-linux-musl.tar.gz
     base=https://github.com/googleworkspace/cli/releases/download/v0.22.5
     curl -fsSLO "$base/$asset"
     curl -fsSLO "$base/$asset.sha256"
     sha256sum --check "$asset.sha256"
     tar -xzf "$asset" ./gws
     ./gws --version
     install -m 0755 ./gws "$pkg/bin/gws"
     gws --version
   )
   ```

   This replaces the binary the npm launcher calls, not the launcher itself. Recheck `gws --version` after changing Node versions in nvm or reinstalling the package.

2. **Store the client file.** Create a private local directory outside your project and synced folders. Move the downloaded client JSON there as `client_secret.json`. On Windows, use a new directory under `%LOCALAPPDATA%` and check **Properties > Security**. On macOS or Linux, use a new directory in your home folder with mode `700` and set the file mode to `600`. Set `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` to the private directory path in the terminal you will use. For example:

   - **Windows (PowerShell):** `$env:GOOGLE_WORKSPACE_CLI_CONFIG_DIR = Join-Path $env:LOCALAPPDATA 'CS357-GmailReadOnly'`
   - **macOS and Linux (including WSL):** use the following commands. The example assumes you saved the Desktop client download as `~/Downloads/client_secret.json`. Set `client_download` to the actual path if it differs. Do not overwrite a client file from another exercise or project.

     ```bash
     export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/cs357-gmail-readonly"
     client_download="$HOME/Downloads/client_secret.json"
     install -d -m 700 "$GOOGLE_WORKSPACE_CLI_CONFIG_DIR"
     (umask 077; set -C; cat "$client_download" > "$GOOGLE_WORKSPACE_CLI_CONFIG_DIR/client_secret.json")
     ```

     The new file has mode `600`. If WSL downloaded the file to Windows, use its local path from WSL and copy it into the Linux home directory as shown. Keep the client file out of Git, synced folders, agent prompts, and screenshots.

3. **Authorize the CLI.** In a terminal without other `gws` credential overrides, authorize the CLI yourself:

   ```text
   gws auth login --scopes https://www.googleapis.com/auth/gmail.readonly
   ```

   Use the exact scope. Plain `gws auth login` can request write access, and `--readonly` can include other Workspace services. Complete consent yourself in your browser. Do not paste tokens, authorization codes, or callback URLs into chat. See the [CLI authentication guide](https://github.com/googleworkspace/cli/tree/v0.22.5#authentication) for the client file and local credential store.

   **No browser on this machine?** `gws` 0.22.5 has no mode for pasting the redirect address back in. Its documented headless route exports a long-lived credential file from a computer that has a browser, which is more than this exercise should hand around. On a headless machine or in a container, use Path B with `--paste` instead.

4. **Verify with one read.** Run the search yourself before launching the agent. `me` refers to the account that approved the grant. A successful response verifies that the test grant works; `--dry-run` only previews the request. The search returns up to three matching message IDs, not message bodies. Keep its output local.

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

5. **Test with a Read-Only Request.** From that terminal, change to an empty working directory and launch `opencode` or `omp`. Paste this prompt instead of pasting the command output or any credential:

   > Check my Gmail test inbox using the `gws` CLI. Use the shell tool to run one `gws gmail users messages list` request. Set `userId` to `me`, `q` to `subject:"CS357 MCP DEMO"`, and `maxResults` to `3`. Use quoting for the shell you are running in. Report how many IDs this page returned. Do not fetch message bodies, open credential files, follow links, run other commands, or change anything in Gmail.

## Path B: Self-hosted MCP

1. **Save the server.** In a new local directory, copy the whole box into `gmail_readonly.py`. The server has one tool, `count_demo_messages`. In live mode it asks Gmail for up to three IDs matching the exercise subject and returns a count, not the IDs or message bodies.

   This version is written for the [MCP Python SDK](https://py.sdk.modelcontextprotocol.io/) 2.x. If you have an older copy of this script that starts with `from mcp.server.fastmcp import FastMCP`, a fresh install of `mcp` now stops it with `ModuleNotFoundError: No module named 'mcp.server.fastmcp'`, because 2.x renamed `FastMCP` to `MCPServer` and moved the HTTP settings (host, port, and the two transport options) from the constructor to `run()`. The [migration guide](https://py.sdk.modelcontextprotocol.io/v2/migration/#fastmcp-renamed-to-mcpserver) lists the changes. The tool, its checks, and what it returns are the same as before.

   ```python
   # Targets the MCP Python SDK 2.x (mcp>=2.3,<3; see requirements.txt).
   # In 2.x, FastMCP became MCPServer, and the HTTP settings moved to run():
   # https://py.sdk.modelcontextprotocol.io/v2/migration/#fastmcp-renamed-to-mcpserver
   import argparse
   import getpass
   import logging
   from pathlib import Path

   import httpx
   from google_auth_oauthlib.flow import InstalledAppFlow
   from mcp.server.mcpserver import MCPServer

   SCOPE = "https://www.googleapis.com/auth/gmail.readonly"
   URL = "https://gmail.googleapis.com/gmail/v1/users/me/messages"
   QUERY = 'subject:"CS357 MCP DEMO"'
   PASTE_REDIRECT = "http://127.0.0.1:8796/"


   def authorize(client_json: Path, paste: bool = False) -> str:
       flow = InstalledAppFlow.from_client_secrets_file(
           str(client_json), scopes=[SCOPE], autogenerate_code_verifier=True
       )
       if flow.client_type != "installed":
           raise ValueError("Use a Desktop app OAuth client.")
       logging.getLogger("google_auth_oauthlib.flow").setLevel(logging.WARNING)
       if paste:
           # For a machine with no browser: approve on any device, then paste the
           # 127.0.0.1 address the browser could not open. The code in it is useless
           # without the PKCE verifier and client secret this process holds.
           flow.redirect_uri = PASTE_REDIRECT
           url, _ = flow.authorization_url(access_type="online", prompt="consent")
           print("Open this address on any device and approve Gmail read-only access:")
           print(url, flush=True)
           reply = getpass.getpass("Paste the http://127.0.0.1:8796/ address (hidden): ").strip()
           if not reply.startswith(PASTE_REDIRECT + "?"):
               raise ValueError("That is not the loopback address.")
           # The redirect never left this computer, so accept http here only, as
           # run_local_server does for its own loopback callback.
           flow.fetch_token(authorization_response="https://" + reply[len("http://"):])
       else:
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


   def make_server(token: str | None) -> MCPServer:
       server = MCPServer("CS357 Gmail demo")

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
       parser.add_argument("--paste", action="store_true",
                           help="sign in from another device and paste the redirect address")
       args = parser.parse_args()
       token = None
       if args.client_json:
           try:
               token = authorize(args.client_json, args.paste)
           except Exception:
               raise SystemExit("Google sign-in failed or the grant was not Gmail read-only.") from None
       make_server(token).run(
           transport="streamable-http", host="127.0.0.1", port=8795,
           stateless_http=True, json_response=True,
       )
   ```

   Save these three lines next to it as `requirements.txt`. Each pin allows bug fixes but stops at the next major version, so a future 3.x release cannot break the script the way 2.x broke the old one.

   ```text
   mcp>=2.3,<3
   google-auth-oauthlib>=1.5,<2
   httpx>=0.28,<1
   ```

2. **Install the dependencies and start the server.** Use Python 3.11 or later. Run these commands from the directory containing the script.

   **macOS/Linux:**

   ```bash
   python3 -m venv .venv
   .venv/bin/python -m pip install -r requirements.txt
   .venv/bin/python gmail_readonly.py
   ```

   **Windows (PowerShell):**

   ```powershell
   py -3 -m venv .venv
   .\.venv\Scripts\python.exe -m pip install -r requirements.txt
   .\.venv\Scripts\python.exe gmail_readonly.py
   ```

   Leave this terminal open. With no arguments, the server runs in fixture mode and never contacts Gmail. Its MCP endpoint is `http://127.0.0.1:8795/mcp`. It does not authenticate local callers, so use it only on a trusted computer. Do not publish, forward, or tunnel the port. The server and coding agent must run in the same environment, including the same side of WSL if you use it.

   **Check the fixture before you add an agent.** Let's talk to the server ourselves first, so that if something goes wrong later, we know whether the problem is the server or the agent. In a second terminal on macOS, Linux, or WSL, send the two requests an agent would send first: `initialize`, then a call to the tool.

   ```bash
   H='-H Content-Type:application/json -H Accept:application/json,text/event-stream'
   curl -s $H -X POST http://127.0.0.1:8795/mcp -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"t","version":"1"}}}'
   curl -s $H -X POST http://127.0.0.1:8795/mcp -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"count_demo_messages","arguments":{}}}'
   ```

   The first reply should include `"serverInfo":{"name":"CS357 Gmail demo"`. The second should end with `"isError":false,"structuredContent":{"mode":"fixture","matches_on_page":1}`. Neither request sends a session header: `stateless_http=True` lets each request stand on its own, and `json_response=True` sends a plain JSON reply instead of an event stream. If you are on Windows without WSL, you can skip this check and use the agent check in Step 4 instead.

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

5. **Authorize your test mailbox.** Close the agent and stop the fixture server with Ctrl+C. If you skipped [Shared Setup](#shared-setup-google-cloud-and-gmail-oauth), do it now. Use the Desktop OAuth client JSON from that setup; you do not need to install `gws` or run `gws auth login`. Put the downloaded JSON in a private local directory outside your project and outside synced folders. On Windows, check **Properties > Security**; on macOS/Linux, use a directory with mode `700` and a file with mode `600`.

   Run the same `gmail_readonly.py` command from Step 2, but add `--client-json` followed by the quoted absolute path to the download. In the browser, authorize only the test mailbox and the Gmail read-only permission.

   **Optional: sign in from another device.** The default sign-in opens a browser on the same computer and catches Google's reply on a temporary `127.0.0.1` port. On a machine with no browser, such as a server you reach over SSH or a container, add `--paste` as well. The script prints a Google address instead. Open it on any device, sign in, and approve. Google then sends that browser to `http://127.0.0.1:8796/?...`, which fails to load, because nothing on that device is listening there; that is expected. Copy the whole address from the address bar and paste it at the script's hidden prompt. The script checks that it is the loopback address, then trades the code in it for a token using the PKCE verifier and client secret it holds, so the code alone is useless to anyone else. Paste it only into that prompt, never into chat, and do it within a few minutes, because the code expires.

   Either way, the browser's loopback callback is separate from the MCP endpoint. The script checks Google's returned scope before starting the server and keeps the short-lived token in memory. It does not write a token file or refresh the token. The agent configuration needs only the local URL. After authorization, start the agent again from the second terminal.

6. **Test with a Read-Only Request.** Prompt the agent:

   > Check my Gmail test inbox using only `gmail-demo`. Call `count_demo_messages` once. Tell me whether it ran in Gmail or fixture mode and report the count on the first page. Do not use the shell, open messages, or change anything in Gmail.

   Check the tool trace for one call with `mode: gmail`. Compare the count with the test mailbox. If the token expires, stop the server and authorize again yourself. If the trace says `fixture`, you are still connected to the fixture server.

## Path C: Hosted MCP

This simulation illustrates the setup and read-only test. It does not sign in to Google or read a mailbox. [Open the hosted MCP terminal simulation]({{ site.baseurl }}/viz/?mode=terminal#cs357-gmailreadonly-terminal-walkthrough).

<iframe title="Gmail read-only hosted MCP terminal simulation" loading="lazy"
  src="{{ site.baseurl }}/viz/?mode=terminal&embed=1#cs357-gmailreadonly-terminal-walkthrough"
  style="width:100%;height:600px;border:1px solid #888"></iframe>

Use this path only if you can enable the preview service on your test project. Google's server supports writes as well as reads. The OAuth grant, not the tool menu or the prompt, prevents Gmail writes in this exercise.

1. **Set up the preview project.** In a dedicated [Google Cloud project](https://console.cloud.google.com/), follow the manual setup in [Google's Gmail MCP guide](https://developers.google.com/workspace/gmail/api/guides/configure-mcp-server) to enable both the Gmail API (`gmail.googleapis.com`) and the Gmail MCP API (`gmailmcp.googleapis.com`). From a terminal, that is:

   ```bash
   gcloud services enable gmail.googleapis.com --project="$PROJECT_ID"
   gcloud services enable gmailmcp.googleapis.com --project="$PROJECT_ID"
   ```

   Configure branding, choose **External** in **Audience**, leave the app in **Testing**, and add the test Gmail account under **Test users**. Google's guide lists three Gmail scopes for **Data Access**, including `gmail.compose` and `gmail.modify`; for this exercise, add **only** `https://www.googleapis.com/auth/gmail.readonly`. Skip the guide's quick setup, which asks for all three. If your project cannot enable the MCP service, use Path A or Path B.

2. **Create the OAuth client.** In **Google Auth Platform > Clients**, create a new **Web application** client. Select **Use this client for an AI-powered agent**, which Google requires for user-delegated access to this service. Set the authorized redirect URI to `https://developers.google.com/oauthplayground` with no trailing slash. Save the client ID and secret somewhere private until the exercise is over. Do not add them to an agent configuration.

3. **Get a short-lived token.** With the agent closed, open [Google's OAuth 2.0 Playground](https://developers.google.com/oauthplayground/). In the gear menu, choose **Use your own OAuth credentials**, enter the new client ID and secret, leave link sharing of credentials unchecked, and set **Access type** to **Online**. In Step 1, clear any selected scopes, paste `https://www.googleapis.com/auth/gmail.readonly` as the only scope, and choose **Authorize APIs**. Sign in to the test account. In Step 2, choose **Exchange authorization code for tokens**. In Google's response, check that `scope` is exactly `https://www.googleapis.com/auth/gmail.readonly`. If it is missing or includes another scope, do not use the token. Copy only the **Access token** from the Playground when the hidden terminal prompt in Step 5 is ready. Do not save it in a file or use a refresh token.

   An online token expires after about an hour, and that is deliberate here. Google's guide suggests offline access so a long-running agent does not ask you to sign in every hour; for a one-time test, a token that dies on its own is the safer choice.

   **No browser on this machine?** You do not need one. The Playground runs in a browser on any device, and the only thing that crosses to the machine running the agent is the access token you paste at the hidden prompt in Step 5. There is no redirect address to paste back.

4. **Configure the MCP connection.** In an otherwise empty local directory, create the configuration for one agent. The configuration contains an environment-variable reference, not the access token itself.

   **[OpenCode v2](https://opencode.ai/docs/mcp-servers/)** (`opencode.json`):

   ```json
   {
     "mcp": {
       "servers": {
         "gmail-demo": {
           "type": "remote",
           "url": "https://gmailmcp.googleapis.com/mcp/v1",
           "oauth": false,
           "codemode": false,
           "headers": {"Authorization": "Bearer {env:CS357_GMAIL_ACCESS_TOKEN}"}
         }
       }
     }
   }
   ```

   **[Oh My Pi](https://omp.sh/docs/mcp)** (`.omp/mcp.json`):

   ```json
   {
     "mcpServers": {
       "gmail-demo": {
         "type": "http",
         "url": "https://gmailmcp.googleapis.com/mcp/v1",
         "headers": {"Authorization": "Bearer ${CS357_GMAIL_ACCESS_TOKEN}"}
       }
     }
   }
   ```

   Use the whole address, including `/mcp/v1`. If you open `https://gmailmcp.googleapis.com/` by itself in a browser, Google answers `404 Not Found`; that does not mean the service is down, because the server lives only at `/mcp/v1`.

5. **Start the agent from that directory.** Use a private terminal without recording or shell tracing. Paste the token only when the hidden input prompt appears, then clear your clipboard. Replace the `opencode` line with `omp` if you chose Oh My Pi. The Bash/Zsh subshell and the PowerShell `finally` block keep the token from staying in your interactive shell after the agent exits. While it runs, a same-user agent with shell access may still be able to read its environment. Do not approve shell calls for this MCP exercise.

   **macOS/Linux (Bash or Zsh):**

   ```bash
   (
     printf 'Gmail demo access token: ' >&2
     IFS= read -rs CS357_GMAIL_ACCESS_TOKEN || exit 1
     printf '\n' >&2
     export CS357_GMAIL_ACCESS_TOKEN
     opencode
   )
   ```

   **Windows (PowerShell 7.3+):**

   ```powershell
   try {
       $env:CS357_GMAIL_ACCESS_TOKEN = Read-Host 'Gmail demo access token' -MaskInput
       opencode
   } finally {
       Remove-Item Env:CS357_GMAIL_ACCESS_TOKEN -ErrorAction SilentlyContinue
   }
   ```

6. **Test with a Read-Only Request.** In OpenCode, check `/mcps`. In Oh My Pi, run `/mcp test gmail-demo`, then use `/tools` to find the search tool. Google's catalog lists write tools such as `create_draft` and `trash_thread` even before you sign in; seeing a tool name does not prove you have permission to use it. Prompt the agent:

   > Check my Gmail test inbox using only the `gmail-demo` MCP server. Call `search_threads` once with `query` set to `subject:"CS357 MCP DEMO"`, `pageSize` set to `3`, and `view` set to `THREAD_VIEW_IDS_ONLY`. Report how many threads the first page returned. Do not open a thread or message, use the shell, or change anything in Gmail.

   The [search tool](https://developers.google.com/workspace/gmail/api/reference/mcp/tools_list/search_threads) accepts the Gmail read-only scope. If a token expires, close the agent and repeat the narrow authorization in Step 3. If Google reports a preview or project-access restriction, use Path A or Path B instead of adding scopes.

**For any path**, check the tool trace for the requested search. Compare the result with the test mailbox and, for the CLI, your manual run. Stop the turn if the agent proposes a different operation. If the list is empty, check the subject and signed-in test account before changing the query. Do not test the grant by attempting a write.

## Protect the Returned Data

The OAuth scope controls what the tool can do in Gmail. It does not control where the result goes after Gmail returns it. When an agent runs a command, the output can enter its conversation history and be sent to the model provider. Asking the agent to report only a count limits its reply, not what it sees. The CLI search returns message and thread IDs. The self-hosted MCP server counts the IDs before returning the result, so the model receives neither IDs nor message metadata. Google's hosted server returns whatever its tool returns; with `THREAD_VIEW_IDS_ONLY`, that is thread IDs without per-thread message metadata, and the model sees them. On a real account, even IDs and search results can reveal that someone received mail matching a particular query.

If a task needs only a count, leave message bodies, subjects, senders, attachments, and links out of the tool result. For real data, filter the result locally **before** it reaches the model. A local model can avoid sending the result to a hosted provider, but the agent may still keep local transcripts or pass data to other tools. Do not share a transcript or screenshot that contains mailbox data or credentials.

If you later read a message, treat its content as untrusted. An email might tell the agent to open a link or upload a file. That text is part of the message, not permission to take another action. Read-only Gmail access can stop a Gmail write; it cannot stop a separate shell or browser tool from acting. Review the tool trace and stop any call outside the task.

When you finish, close the agent, remove this test app's access in [Google Account connections](https://myaccount.google.com/connections), and clean up the local setup. For the self-hosted server, stop it and remove the demo configuration and private client download. For the hosted server, close the Playground, clear the clipboard, and remove the demo agent configuration. For the CLI, remove the exercise's private credential directory. Deleting a configuration or local credential file does not revoke the Google grant.
