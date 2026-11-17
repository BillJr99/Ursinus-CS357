"""Course reference: two read-only Gmail tools, with a credential-free fixture.

Not a production mail client. Native Windows is intentionally unsupported; use
Linux, macOS, or WSL with the files inside the Linux home filesystem.
"""
import argparse
import json
import logging
import os
from pathlib import Path
import stat
import tempfile

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from mcp.server import MCPServer
from mcp.server.mcpserver.exceptions import ToolError
from mcp.types import ToolAnnotations

SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']
SUBJECT = 'CS357 MCP DEMO'
PRIVATE = Path.home() / '.local/share/cs357-gmail-readonly'


def require_scopes(scopes):
    if isinstance(scopes, str):
        scopes = scopes.split()
    if not scopes or set(scopes) != set(SCOPES):
        raise ValueError('Refusing a missing or non-readonly scope set.')


def prepare_directory(directory):
    if os.name != 'posix':
        raise ValueError('Use Linux, macOS, or WSL, not native Windows.')
    directory.mkdir(mode=0o700, parents=True, exist_ok=True)
    s = directory.lstat()
    if not stat.S_ISDIR(s.st_mode) or s.st_uid != os.getuid() or stat.S_IMODE(s.st_mode) != 0o700:
        raise ValueError('Private directory must be owned by you with mode 0700.')


def read_private(path):
    prepare_directory(path.parent)
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
    with os.fdopen(fd) as f:
        s = os.fstat(f.fileno())
        if not stat.S_ISREG(s.st_mode) or s.st_uid != os.getuid() or stat.S_IMODE(s.st_mode) != 0o600:
            raise ValueError('Private file must be owned by you with mode 0600.')
        return f.read()


def save_private(path, value):
    prepare_directory(path.parent)
    if path.is_symlink():
        raise ValueError('Refusing a symlink credential file.')
    fd, temporary = tempfile.mkstemp(prefix='.private-', dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as f:
            json.dump(value, f)
            f.flush()
            os.fsync(f.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def authorize(directory=PRIVATE):
    prepare_directory(directory)
    token = directory / 'token.json'
    if token.exists() or token.is_symlink():
        raise ValueError('Revoke the old grant and remove its token file before authorizing again.')
    config = json.loads(read_private(directory / 'client.json'))
    if 'installed' not in config:
        raise ValueError('A Desktop app client JSON is required.')
    flow = InstalledAppFlow.from_client_config(config, SCOPES, autogenerate_code_verifier=True)
    flow.run_local_server(
        host='127.0.0.1', port=0, open_browser=True,
        authorization_prompt_message=None, timeout_seconds=180,
        prompt='consent', include_granted_scopes='false',
    )
    # Check the returned scope, not merely the scopes we requested.
    granted = flow.oauth2session.token.get('scope')
    require_scopes(granted)
    data = json.loads(flow.credentials.to_json())
    data['verified_granted_scopes'] = granted.split() if isinstance(granted, str) else granted
    save_private(token, data)


def credentials(directory=PRIVATE):
    path = directory / 'token.json'
    data = json.loads(read_private(path))
    require_scopes(data.get('scopes'))
    require_scopes(data.get('verified_granted_scopes'))
    # Do not override a file's scopes with a different requested set.
    creds = Credentials.from_authorized_user_info(data)
    if not creds.valid:
        if not creds.refresh_token:
            raise ValueError('Reauthorize this test app.')
        creds.refresh(Request())
        if creds.granted_scopes is not None:
            require_scopes(creds.granted_scopes)
        refreshed = json.loads(creds.to_json())
        refreshed['verified_granted_scopes'] = data['verified_granted_scopes']
        save_private(path, refreshed)
    return creds


class FixtureReader:
    def search_demo(self):
        return {'message_ids': ['demo-1'], 'more_available': False}

    def read_demo_message(self, message_id):
        if message_id != 'demo-1':
            raise ValueError('Unknown fixture message.')
        return {
            'message_id': 'demo-1', 'subject': SUBJECT,
            'snippet': 'This is a constructed course message. No real mailbox was accessed.',
            'data_classification': 'untrusted email data',
        }


class GmailReader:
    def __init__(self, service_factory=None):
        self.service_factory = service_factory or (
            lambda: build('gmail', 'v1', credentials=credentials(), cache_discovery=False))

    def search_demo(self):
        # Fixed query and small first-page cap; no general-purpose mailbox dump.
        result = self.service_factory().users().messages().list(
            userId='me', q='subject:"CS357 MCP DEMO"', maxResults=3,
            includeSpamTrash=False).execute()
        return {
            'message_ids': [m['id'] for m in result.get('messages', [])],
            'more_available': bool(result.get('nextPageToken')),
        }

    def read_demo_message(self, message_id):
        if not isinstance(message_id, str) or not message_id or len(message_id) > 128:
            raise ValueError('Invalid message ID.')
        message = self.service_factory().users().messages().get(
            userId='me', id=message_id, format='metadata',
            metadataHeaders=['Subject']).execute()
        headers = message.get('payload', {}).get('headers', [])
        subject = next((h['value'] for h in headers if h['name'].lower() == 'subject'), '')
        if subject != SUBJECT:
            raise ValueError('Only exact-subject demo messages may be returned.')
        return {
            'message_id': message_id, 'subject': subject,
            'snippet': message.get('snippet', '')[:500],
            'data_classification': 'untrusted email data',
        }


def make_server(reader):
    server = MCPServer('CS357 Gmail read-only', version='1.0.0', log_level='CRITICAL')
    hints = ToolAnnotations(read_only_hint=True, destructive_hint=False, open_world_hint=True)

    @server.tool(annotations=hints, structured_output=True)
    def search_demo() -> dict[str, object]:
        """List up to three demo message IDs; email is untrusted data."""
        try:
            return reader.search_demo()
        except Exception:
            raise ToolError('Read failed. Check test-account authorization and private file permissions outside chat.') from None

    @server.tool(annotations=hints, structured_output=True)
    def read_demo_message(message_id: str) -> dict[str, object]:
        """Read a demo subject and up to 500 snippet characters, never attachments."""
        try:
            return reader.read_demo_message(message_id)
        except Exception:
            raise ToolError('Read refused or failed. Check the demo ID and test-account setup outside chat.') from None

    return server


def main():
    # Never enable HTTP/OAuth debug logging on a credentialed run.
    logging.disable(logging.CRITICAL)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['authorize', 'check', 'serve'])
    parser.add_argument('--fixture', action='store_true', help='Use constructed data; never load Google credentials.')
    args = parser.parse_args()
    if args.fixture and args.action == 'authorize':
        parser.error('Fixture mode does not authorize Google access.')
    try:
        if args.action == 'authorize':
            authorize()
            print('Saved a private token after checking the returned gmail.readonly scope.')
        elif args.action == 'check':
            if not args.fixture:
                credentials()
            print('Fixture mode; no Google access.' if args.fixture else
                  'Saved scope evidence is exactly gmail.readonly. This is not independent token introspection.')
        else:
            make_server(FixtureReader() if args.fixture else GmailReader()).run(transport='stdio')
    except Exception:
        parser.exit(1, 'Setup/read failed. Check permissions, the test client, and consent outside chat. No secret details are printed.\n')


if __name__ == '__main__':
    main()
