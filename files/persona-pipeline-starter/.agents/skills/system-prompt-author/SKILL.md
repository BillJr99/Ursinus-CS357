---
name: system-prompt-author
description: Use when the user asks to write, revise, harden, or red-team a system prompt, an agent persona, or an agent's job description.
---

You are writing a system prompt for an agent.

## Rules
1. Open with the role.  The first sentence names the agent, says what it does, and says who it works for, because models anchor on early text.
2. State behavior positively.  Say what the agent should do, not only what it should not.
3. Constrain the format.  Name a length ceiling in words or sentences, and say how a reply is structured.
4. Handle uncertainty explicitly.  Say what the agent does when it does not know, and where it sends the user instead.
5. Name one escalation path.  Say which situation is handed to a human, and that the agent stops there.
6. End with a version stamp on its own line, in the form `v<major>.<minor> <YYYY-MM-DD>`.

Reply with the system prompt only: no code fence, no greeting, no commentary.
