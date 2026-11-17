"""Synthetic tests only. Never loads a real Google credential."""
import asyncio
import importlib.util
import json
import os
from pathlib import Path
import stat
import sys
from unittest.mock import Mock

import pytest

MODULE = Path(__file__).with_name('gmail_readonly.py')
SCOPE = 'https://www.googleapis.com/auth/gmail.readonly'


def load():
    assert MODULE.exists(), 'Reference adapter has not been implemented'
    spec = importlib.util.spec_from_file_location('gmail_readonly', MODULE)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def test_scope_contract():
    m = load()
    assert m.SCOPES == [SCOPE]
    m.require_scopes([SCOPE])
    for scopes in ([], [SCOPE, 'https://www.googleapis.com/auth/gmail.modify'], None):
        with pytest.raises(ValueError):
            m.require_scopes(scopes)


def test_private_storage(tmp_path):
    m = load()
    directory = tmp_path / 'private'
    m.prepare_directory(directory)
    target = directory / 'token.json'
    m.save_private(target, {'synthetic': True})
    assert json.loads(m.read_private(target)) == {'synthetic': True}
    assert stat.S_IMODE(target.stat().st_mode) == 0o600
    assert stat.S_IMODE(directory.stat().st_mode) == 0o700
    target.chmod(0o644)
    with pytest.raises(ValueError):
        m.read_private(target)
    target.unlink()
    target.symlink_to(directory / 'other')
    with pytest.raises(ValueError):
        m.save_private(target, {})


def test_fixture_read_and_missing():
    m = load()
    reader = m.FixtureReader()
    assert reader.search_demo() == {'message_ids': ['demo-1'], 'more_available': False}
    assert reader.read_demo_message('demo-1')['snippet'] == 'This is a constructed course message. No real mailbox was accessed.'
    with pytest.raises(ValueError):
        reader.read_demo_message('other')


def test_live_reader_only_lists_and_gets_metadata():
    m = load()
    api = Mock()
    messages = api.users.return_value.messages.return_value
    messages.list.return_value.execute.return_value = {'messages': [{'id': '123'}], 'nextPageToken': 'synthetic'}
    messages.get.return_value.execute.return_value = {
        'id': '123', 'snippet': 'x' * 1000,
        'payload': {'headers': [{'name': 'Subject', 'value': m.SUBJECT}]}}
    reader = m.GmailReader(lambda: api)
    assert reader.search_demo() == {'message_ids': ['123'], 'more_available': True}
    messages.list.assert_called_once_with(userId='me', q='subject:"CS357 MCP DEMO"', maxResults=3, includeSpamTrash=False)
    result = reader.read_demo_message('123')
    assert len(result['snippet']) == 500
    messages.get.assert_called_once_with(userId='me', id='123', format='metadata', metadataHeaders=['Subject'])
    assert [x[0] for x in messages.mock_calls] == ['list', 'list().execute', 'get', 'get().execute']
    messages.get.return_value.execute.return_value['payload']['headers'][0]['value'] = 'private'
    with pytest.raises(ValueError):
        reader.read_demo_message('123')


def test_auth_contract_no_browser_or_network(tmp_path, monkeypatch):
    m = load()
    directory = tmp_path / 'private'
    m.prepare_directory(directory)
    m.save_private(directory / 'client.json', {'installed': {'client_id': 'synthetic'}})
    flow = Mock()
    flow.oauth2session.token = {'scope': SCOPE}
    flow.credentials.to_json.return_value = json.dumps({'scopes': [SCOPE], 'token': 'SYNTHETIC-NOT-A-TOKEN'})
    factory = Mock(return_value=flow)
    monkeypatch.setattr(m.InstalledAppFlow, 'from_client_config', factory)
    m.authorize(directory)
    assert factory.call_args.kwargs['autogenerate_code_verifier'] is True
    assert factory.call_args.args[1] == [SCOPE]
    kwargs = flow.run_local_server.call_args.kwargs
    assert kwargs['host'] == '127.0.0.1'
    assert kwargs['port'] == 0
    assert kwargs['authorization_prompt_message'] is None
    assert kwargs['include_granted_scopes'] == 'false'
    assert kwargs['prompt'] == 'consent'
    with pytest.raises(ValueError):
        m.authorize(directory)  # Never silently overwrite an existing grant.


def test_broad_auth_response_not_saved(tmp_path, monkeypatch):
    m = load()
    directory = tmp_path / 'private'
    m.prepare_directory(directory)
    m.save_private(directory / 'client.json', {'installed': {}})
    flow = Mock()
    flow.oauth2session.token = {'scope': SCOPE + ' https://www.googleapis.com/auth/gmail.modify'}
    monkeypatch.setattr(m.InstalledAppFlow, 'from_client_config', Mock(return_value=flow))
    with pytest.raises(ValueError):
        m.authorize(directory)
    assert not (directory / 'token.json').exists()


def test_saved_broad_token_rejected_before_refresh(tmp_path, monkeypatch):
    m = load()
    directory = tmp_path / 'private'
    m.prepare_directory(directory)
    m.save_private(directory / 'token.json', {
        'scopes': [SCOPE, 'https://www.googleapis.com/auth/gmail.modify'],
        'verified_granted_scopes': [SCOPE]})
    factory = Mock()
    monkeypatch.setattr(m.Credentials, 'from_authorized_user_info', factory)
    with pytest.raises(ValueError):
        m.credentials(directory)
    factory.assert_not_called()


def test_refresh_preserves_scope_evidence_and_private_mode(tmp_path, monkeypatch):
    m = load()
    directory = tmp_path / 'private'
    m.prepare_directory(directory)
    original = {'scopes': [SCOPE], 'verified_granted_scopes': [SCOPE]}
    m.save_private(directory / 'token.json', original)
    creds = Mock(valid=False, refresh_token='SYNTHETIC-NOT-A-TOKEN', granted_scopes=[SCOPE])
    creds.to_json.return_value = json.dumps({'scopes': [SCOPE]})
    monkeypatch.setattr(m.Credentials, 'from_authorized_user_info', Mock(return_value=creds))
    monkeypatch.setattr(m, 'Request', Mock())
    m.credentials(directory)
    creds.refresh.assert_called_once()
    assert json.loads(m.read_private(directory / 'token.json')) == original
    creds.granted_scopes = [SCOPE, 'https://www.googleapis.com/auth/gmail.modify']
    with pytest.raises(ValueError):
        m.credentials(directory)
    assert json.loads(m.read_private(directory / 'token.json')) == original


def test_empty_results_and_invalid_ids():
    m = load()
    api = Mock()
    api.users.return_value.messages.return_value.list.return_value.execute.return_value = {}
    reader = m.GmailReader(lambda: api)
    assert reader.search_demo() == {'message_ids': [], 'more_available': False}
    for value in ('', 'x' * 129, None):
        with pytest.raises(ValueError):
            reader.read_demo_message(value)
    api.users.return_value.messages.return_value.get.assert_not_called()


def test_tool_error_does_not_expose_provider_exception():
    m = load()
    from mcp import Client
    reader = Mock()
    reader.search_demo.side_effect = RuntimeError('SYNTHETIC-PRIVATE-DETAIL')
    async def check():
        async with Client(m.make_server(reader)) as client:
            result = await client.call_tool('search_demo', {})
            assert result.is_error
            assert 'SYNTHETIC-PRIVATE-DETAIL' not in str(result)
    asyncio.run(check())


def test_sdk_stdio_fixture_and_no_write_tools():
    load()
    from mcp import Client
    from mcp.client.stdio import StdioServerParameters
    async def check():
        params = StdioServerParameters(command=sys.executable, args=[str(MODULE), 'serve', '--fixture'])
        async with Client(params, mode='legacy') as client:
            listed = await client.list_tools()
            assert {t.name for t in listed.tools} == {'search_demo', 'read_demo_message'}
            assert listed.next_cursor is None
            for tool in listed.tools:
                assert tool.annotations.read_only_hint is True
            result = await client.call_tool('search_demo', {})
            assert not result.is_error
            assert result.structured_content['message_ids'] == ['demo-1']
            result = await client.call_tool('read_demo_message', {'message_id': 'demo-1'})
            assert not result.is_error
            assert result.structured_content['data_classification'] == 'untrusted email data'
            for name in ('send', 'delete', 'modify', 'create_draft'):
                assert (await client.call_tool(name, {})).is_error
            assert (await client.call_tool('read_demo_message', {'message_id': 'missing'})).is_error
    asyncio.run(check())
