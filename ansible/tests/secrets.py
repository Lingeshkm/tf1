# This code is copied from bc-event-processor/src/main/serverless/handler.py

import json
import re
import boto3
import base64
from typing import NamedTuple


JIRA_READONLY_CONFIG_KEY_NAME = "event_processor"
MYSQL_CONFIG_KEY_NAME = "event_processor"


class JiraCredentials(NamedTuple):
    access_token: str
    access_token_secret: str
    consumer_key: str
    key_cert: str
    url: str
    userid: str

class MysqlCredentials(NamedTuple):
    database: str
    hostname: str
    password: str
    userid: str

def decode_base64(data, altchars=b'+/'):
    """Decode base64, padding being optional.

    :param data: Base64 data as an ASCII byte string
    :returns: The decoded byte string.

    """
    data = re.sub(rb'[^a-zA-Z0-9%s]+' % altchars, b'', data)  # normalize
    missing_padding = len(data) % 4
    if missing_padding:
        data += b'=' * (4 - missing_padding)
    return base64.b64decode(data, altchars)


def _parse_jira_secret_readonly(sm_plaintext: str) -> JiraCredentials:
    parsed_data = json.loads(sm_plaintext)
    key_cert = decode_base64(parsed_data['jira_readonly']['keycert'].encode())
    return JiraCredentials(access_token=parsed_data['jira_readonly']['accesstoken'],
                           access_token_secret=parsed_data['jira_readonly']['accesstokensecret'],
                           consumer_key=parsed_data['jira_readonly']['consumerkey'],
                           key_cert=key_cert.decode(),
                           url=parsed_data['jira_readonly']['url'],
                           userid=parsed_data['jira_readonly']['userid'])


def get_jira_readonly_creds(env) -> JiraCredentials:
    sm = boto3.client('secretsmanager', region_name='us-east-2')
    sm_plaintext = _get_app_config(sm, env, JIRA_READONLY_CONFIG_KEY_NAME)
    return _parse_jira_secret_readonly(sm_plaintext)


def _parse_jira_secret_readwrite(sm_plaintext: str) -> JiraCredentials:
    parsed_data = json.loads(sm_plaintext)
    key_cert = decode_base64(parsed_data['jira_readwrite']['keycert'].encode())
    return JiraCredentials(access_token=parsed_data['jira_readwrite']['accesstoken'],
                           access_token_secret=parsed_data['jira_readwrite']['accesstokensecret'],
                           consumer_key=parsed_data['jira_readwrite']['consumerkey'],
                           key_cert=key_cert.decode(),
                           url=parsed_data['jira_readwrite']['url'],
                           userid=parsed_data['jira_readwrite']['userid'])


def get_jira_readwrite_creds(env) -> JiraCredentials:
    sm = boto3.client('secretsmanager', region_name='us-east-2')
    sm_plaintext = _get_app_config(sm, env, JIRA_READONLY_CONFIG_KEY_NAME)
    return _parse_jira_secret_readwrite(sm_plaintext)


def _parse_mysql_secret(sm_plaintext: str) -> MysqlCredentials:
    parsed_data = json.loads(sm_plaintext)
    return MysqlCredentials(database=parsed_data['mysql_audit_events']['database'],
                           hostname=parsed_data['mysql_audit_events']['hostname'],
                           password=parsed_data['mysql_audit_events']['password'],
                           userid=parsed_data['mysql_audit_events']['userid'])


def get_mysql_creds(env) -> MysqlCredentials:
    sm = boto3.client('secretsmanager', region_name='us-east-2')
    sm_plaintext = _get_app_config(sm, env, MYSQL_CONFIG_KEY_NAME)
    return _parse_mysql_secret(sm_plaintext)


def _get_app_config(sm, env_string: str, app: str) -> str:
    name = '/app/{env}/{app}'.format(env=env_string, app=app)
    return sm.get_secret_value(SecretId=name)['SecretString']
