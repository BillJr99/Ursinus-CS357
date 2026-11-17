# CS357 Gmail read-only reference

Start with the course tutorial at `Tutorials/GmailReadOnly`. This is a small
teaching adapter, not a maintained production Gmail integration. Python 3.11+
on Linux/macOS/WSL is required. Native Windows file ACLs and keyring storage
are not implemented. Keep WSL credentials in its Linux home, not `/mnt/c`.

Install and test without credentials:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-test.txt
.venv/bin/python -m pytest -q
.venv/bin/python gmail_readonly.py check --fixture
```

Edit the absolute paths in the fixture config before copying it to the agent's
project config. Never paste a credential value into either file. Live mode
requires separate human authorization of a personal, synthetic-only test
account. See the tutorial for Cloud setup, consent, private file placement,
read verification and revocation. `authorize` opens a local browser and
creates a grant; it is not part of the synthetic test procedure.

Tools: `search_demo` and `read_demo_message`. Search returns at most three
IDs, not a total; `more_available` describes a remaining page. Read returns
only an exact demo subject and at most 500 snippet characters. No body,
attachment, send, draft, label, trash, delete, or arbitrary API tool exists.
The OAuth scope still covers the whole mailbox, not just demo messages.

The tests fake only the Google boundary, run the real adapter, and exercise
the real MCP SDK over stdio. They do not prove a successful Google login,
Google-granted permissions, or native OpenCode/Oh My Pi interoperability.
