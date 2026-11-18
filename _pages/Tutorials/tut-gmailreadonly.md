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
5. Under **[Clients](https://console.cloud.google.com/auth/clients)**, select **Create Client > Desktop app**, name the client, and download its JSON. The JSON identifies your app; it does not grant access to your mailbox. That happens when you review the scope and approve it in your browser.

See Google's guides to [OAuth consent](https://developers.google.com/workspace/guides/configure-oauth-consent), [Desktop app authorization](https://developers.google.com/identity/protocols/oauth2/native-app), and [Gmail scopes](https://developers.google.com/workspace/gmail/api/auth/scopes).

## 8. Test with a Read-Only Request

Use the [Google Workspace CLI installation](https://github.com/googleworkspace/cli#installation) and [authentication instructions](https://github.com/googleworkspace/cli#authentication) for your operating system. No MCP server is required. Keep the test credentials in a private local directory outside your project and synced folders. Set `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` to that directory's path, save the downloaded file there as `client_secret.json`, and launch the agent from the same terminal after signing in. Run `gws auth login --scopes https://www.googleapis.com/auth/gmail.readonly` yourself with the agent closed. Check the test account and cancel if Google asks for write access or access to another service. Do not paste the client JSON, a token, or a callback URL into the agent.

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

Check the tool trace for the list request and compare the result with your manual test. Stop the turn if the agent proposes a different operation. If the list is empty, check the subject and signed-in test account before changing the query. Do not test the grant by attempting a write.

## 9. Protect the Returned Data

The OAuth scope controls what the tool can do in Gmail. It does not control where the result goes after Gmail returns it. When an agent runs a command, the output can enter its conversation history and be sent to the model provider. Asking the agent to report only a count limits its reply, not what it sees. In this exercise, the list request returns message IDs without opening messages. On a real account, even IDs and search results can reveal that someone received mail matching a particular query.

If a task needs only a count, leave message bodies, subjects, senders, attachments, and links out of the tool result. For real data, filter the result locally **before** it reaches the model. A local model can avoid sending the result to a hosted provider, but the agent may still keep local transcripts or pass data to other tools. Do not share a transcript or screenshot that contains mailbox data or credentials.

If you later read a message, treat its content as untrusted. An email might tell the agent to open a link or upload a file. That text is part of the message, not permission to take another action. Read-only Gmail access can stop a Gmail write; it cannot stop a separate shell or browser tool from acting. Review the tool trace and stop any call outside the task.

When you finish, close the agent, remove this test app's access in [Google Account connections](https://myaccount.google.com/connections), and remove the exercise's private credential directory. Deleting local files without revoking access does not revoke the Google grant.
