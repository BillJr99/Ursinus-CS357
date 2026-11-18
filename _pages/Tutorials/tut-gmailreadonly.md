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

**Choose one path.** [Path A: MCP](#path-a-mcp) connects the agent to Google's hosted Gmail Model Context Protocol server. The agent calls a named tool with structured arguments, and there is no local server to install. This path requires [Google Workspace Developer Preview access](https://developers.google.com/workspace/preview). If you do not have it, use [Path B: CLI](#path-b-cli). The CLI lets you inspect and run the same command the agent will use, but it exposes many more commands than this exercise needs.

Both paths need a Google OAuth client and your approval in a browser. Each path tells you which client to create. Use a fresh grant with only `https://www.googleapis.com/auth/gmail.readonly`. This scope permits reads across the mailbox, not just the messages your search returns. It does not allow sending mail or changing labels. Do not reuse credentials from a broader grant.

In Gmail's web interface, send an invented message to your test account with the subject `CS357 MCP DEMO`. Complete Google sign-in yourself. Cancel if the screen shows the wrong account or asks for anything beyond Gmail read access. Never give the agent a token, client secret, or browser callback URL in a prompt.

## Path A: MCP

This simulation illustrates the setup and read-only test. It does not sign in to Google or read a mailbox. [Open the MCP terminal simulation]({{ site.baseurl }}/viz/?mode=terminal#cs357-gmailreadonly-terminal-walkthrough).

<iframe title="Gmail read-only MCP terminal simulation" loading="lazy"
  src="{{ site.baseurl }}/viz/?mode=terminal&embed=1#cs357-gmailreadonly-terminal-walkthrough"
  style="width:100%;height:600px;border:1px solid #888"></iframe>

Use this path only if you can enable the preview service on your test project. Google's server supports writes as well as reads. The OAuth grant, not the tool menu or the prompt, prevents Gmail writes in this exercise.

1. **Set up the preview project.** In a dedicated [Google Cloud project](https://console.cloud.google.com/), follow [Google's Gmail MCP setup guide](https://developers.google.com/workspace/gmail/api/guides/configure-mcp-server#configure-mcp-server) to enable both the Gmail API (`gmail.googleapis.com`) and Gmail MCP API (`gmailmcp.googleapis.com`). Configure branding, choose **External** in **Audience**, leave the app in **Testing**, and add the test Gmail account under **Test users**. Unlike the general Google setup, add **only** `https://www.googleapis.com/auth/gmail.readonly` under **Data Access**. If your project cannot enable the MCP service, use Path B.

2. **Create the OAuth client.** In **Google Auth Platform > Clients**, create a new **Web application** client. Select **Use this client for an AI-powered agent**, as [Google requires for this service](https://developers.google.com/workspace/gmail/api/guides/configure-mcp-server#configure-your-ai-application). Set the authorized redirect URI to `https://developers.google.com/oauthplayground` with no trailing slash. Save the client ID and secret somewhere private until the exercise is over. Do not add them to an agent configuration.

3. **Get a short-lived token.** With the agent closed, open [Google's OAuth 2.0 Playground](https://developers.google.com/oauthplayground/). In the gear menu, choose **Use your own OAuth credentials**, enter the new client ID and secret, leave link sharing of credentials unchecked, and set **Access type** to **Online**. In Step 1, clear any selected scopes, paste `https://www.googleapis.com/auth/gmail.readonly` as the only scope, and choose **Authorize APIs**. Sign in to the test account. In Step 2, choose **Exchange authorization code for tokens**. In Google's response, check that `scope` is exactly `https://www.googleapis.com/auth/gmail.readonly`. If it is missing or includes another scope, do not use the token. Copy only the **Access token** from the Playground when the hidden terminal prompt in Step 5 is ready. Do not save it in a file or use a refresh token.

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

6. **Test with a Read-Only Request.** In OpenCode, check `/mcps`. In Oh My Pi, run `/mcp test gmail-demo`, then use `/tools` to find the search tool. Google's catalog can list write tools even without a grant; seeing a tool name does not prove you have permission to use it. Prompt the agent:

   > Check my Gmail test inbox using only the `gmail-demo` MCP server. Call `search_threads` once with `query` set to `subject:"CS357 MCP DEMO"`, `pageSize` set to `3`, and `view` set to `THREAD_VIEW_METADATA_ONLY`. Report how many threads the first page returned. Do not open a thread or message, use the shell, or change anything in Gmail.

   The [search tool](https://developers.google.com/workspace/gmail/api/reference/mcp/tools_list/search_threads) accepts the Gmail read-only scope. If a token expires, close the agent and repeat the narrow authorization in Step 3. If Google reports a preview or project-access restriction, use Path B instead of adding scopes.

## Path B: CLI

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

**For either path**, check the tool trace for the requested search. Compare the result with the test mailbox and, for the CLI, your manual run. Stop the turn if the agent proposes a different operation. If the list is empty, check the subject and signed-in test account before changing the query. Do not test the grant by attempting a write.

## Protect the Returned Data

The OAuth scope controls what the tool can do in Gmail. It does not control where the result goes after Gmail returns it. When an agent runs a command, the output can enter its conversation history and be sent to the model provider. Asking the agent to report only a count limits its reply, not what it sees. The CLI search returns message and thread IDs. The MCP search uses a metadata-only view to omit subjects and snippets, but its result can still include thread and message metadata. On a real account, even IDs and search results can reveal that someone received mail matching a particular query.

If a task needs only a count, leave message bodies, subjects, senders, attachments, and links out of the tool result. For real data, filter the result locally **before** it reaches the model. A local model can avoid sending the result to a hosted provider, but the agent may still keep local transcripts or pass data to other tools. Do not share a transcript or screenshot that contains mailbox data or credentials.

If you later read a message, treat its content as untrusted. An email might tell the agent to open a link or upload a file. That text is part of the message, not permission to take another action. Read-only Gmail access can stop a Gmail write; it cannot stop a separate shell or browser tool from acting. Review the tool trace and stop any call outside the task.

When you finish, close the agent, remove this test app's access in [Google Account connections](https://myaccount.google.com/connections), and clean up the local setup. For MCP, close the Playground, clear the clipboard, and remove the demo agent configuration. For the CLI, remove the exercise's private credential directory. Deleting a configuration or local credential file does not revoke the Google grant.
