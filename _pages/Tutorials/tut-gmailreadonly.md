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

1. In the [Google Cloud console](https://console.cloud.google.com/), create or select a dedicated test project and [enable the Gmail API](https://console.cloud.google.com/apis/library/gmail.googleapis.com).
2. In **Google Auth Platform > [Branding](https://console.cloud.google.com/auth/branding)**, configure the consent screen. Use a name you will recognize when you sign in, such as `CS357 Gmail Read Test`.
3. Under **[Audience](https://console.cloud.google.com/auth/audience)**, choose **External**, keep the app in **Testing**, and add the Gmail test account under **Test users**.
4. Under **[Data Access](https://console.cloud.google.com/auth/scopes)**, add only `https://www.googleapis.com/auth/gmail.readonly`. This scope lets a tool view email and settings across the mailbox. It cannot send mail or change labels. A search filter limits one request, not the account access granted by the scope.
5. Under **[Clients](https://console.cloud.google.com/auth/clients)**, select **Create Client > Desktop app**, name the client, and download its JSON. You will move the download in Step 6. The JSON identifies your app; it does not grant access to your mailbox. That happens when you review the scope and approve it in your browser.

See Google's guides to [OAuth consent](https://developers.google.com/workspace/guides/configure-oauth-consent), [Desktop app authorization](https://developers.google.com/identity/protocols/oauth2/native-app), and [Gmail scopes](https://developers.google.com/workspace/gmail/api/auth/scopes).

## 6. Keep Credentials Outside the Agent Project

Use a fresh, local directory outside Git and synced folders. Give the Google Workspace CLI (`gws`) the directory **path** through `GOOGLE_WORKSPACE_CLI_CONFIG_DIR`. Launching the agent from the same terminal lets its shell tool inherit the path. Do not put the JSON contents, a token, or a browser callback URL in an environment variable, a prompt, or an agent configuration. Use a fresh terminal without any existing `GOOGLE_WORKSPACE_CLI_TOKEN`, `GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE`, `GOOGLE_WORKSPACE_CLI_CLIENT_ID`, or `GOOGLE_WORKSPACE_CLI_CLIENT_SECRET` overrides.

### Windows (PowerShell)

Use PowerShell 7.3 or later for the native command arguments in Step 8. In a fresh terminal, run:

```powershell
$env:GOOGLE_WORKSPACE_CLI_CONFIG_DIR = Join-Path $env:LOCALAPPDATA 'CS357-GmailReadOnly'
New-Item -ItemType Directory -Path $env:GOOGLE_WORKSPACE_CLI_CONFIG_DIR
```

Move the downloaded JSON into that directory using File Explorer and name it `client_secret.json`. In **Properties > Security** for the directory and file, confirm that other ordinary users cannot read them. Do not proceed if the directory is shared or the permissions do not look right.

### macOS and Linux (Bash or Zsh)

```bash
umask 077
export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/cs357-gmail-readonly"
mkdir -m 700 "$GOOGLE_WORKSPACE_CLI_CONFIG_DIR"
```

Move the downloaded JSON into that directory using your file manager and name it `client_secret.json`. Then run:

```bash
chmod 600 "$GOOGLE_WORKSPACE_CLI_CONFIG_DIR/client_secret.json"
```

If the directory already exists on either system, stop and check that it belongs to this exercise before using it. If you use WSL, keep the files in your Linux home directory, not in a Windows mount. Keep both agents closed during sign-in. File permissions protect against other users, not a shell running as you. The agent only needs to run the CLI; it does not need to open any credential file.

## 7. Install and Authorize the Google Workspace CLI

You do not need an MCP server for this exercise. Both agents can call `gws` through their shell tool. Google's [remote Gmail MCP setup](https://developers.google.com/workspace/gmail/api/guides/configure-mcp-server) is a different route: it requires Developer Preview access and documents compose and modify scopes as well as read access. Skip that setup here.

1. With Node.js 18 or later, run these commands in PowerShell, Bash, or Zsh. The [Google Workspace CLI project](https://github.com/googleworkspace/cli) also provides platform binaries. It is not an officially supported Google product. The commands below use version `0.22.5`.

   ```text
   npm install -g @googleworkspace/cli@0.22.5
   gws --version
   ```

2. In the terminal where you set the directory path, run this command yourself, not through the agent:

   ```text
   gws auth login --scopes https://www.googleapis.com/auth/gmail.readonly
   ```

3. In your browser, check the app name and the test account. Approve only read access to Gmail. Cancel if Google asks for permission to send, modify, or manage mail, or to access another service. Use the exact scope above: plain `gws auth login` can request write access, and `--readonly` can request access to other Workspace services. If Google blocks the request, check the project and test-user settings. Do not switch to a broader grant.

The CLI saves its credentials locally. Keep its credential store private and do not export the token for the agent. If local credential storage fails, stop and consult the [CLI authentication guide](https://github.com/googleworkspace/cli#authentication). Do not paste a token into the agent to get around the failure.

## 8. Test with a Read-Only Request

In Gmail's web interface, send an invented message to your test account with the subject `CS357 MCP DEMO`. Run the search below yourself first. `me` refers to the account that approved the grant. The request returns up to three matching message IDs, not message bodies.

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

Check the tool trace for the list request and compare the result with your manual test. Stop the turn if the agent proposes a different operation. If the list is empty, check the subject and signed-in test account before changing the query. Do not test the grant by attempting a write. Keep real mail out of the session: tool results can reach a hosted model, and instructions inside an email are untrusted data.

When you finish, close the agent, remove this test app's access in [Google Account connections](https://myaccount.google.com/connections), and remove the exercise's private credential directory. Deleting local files without revoking access does not revoke the Google grant.
