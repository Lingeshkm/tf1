# This code is copied from bc-event-processor/src/main/serverless/handler.py

import logging
from jira import JIRA
from secrets import get_jira_readonly_creds, get_jira_readwrite_creds, JiraCredentials, get_mysql_creds, MysqlCredentials
import  pymysql


log = logging.getLogger()
log.setLevel(logging.DEBUG)

def get_jira_summary(env, access_method, jira_issue):
    log.debug("get_jira_summary: env={env}, jira_issue={jira_issue}".format(env=env,jira_issue=jira_issue))

    if access_method == 'read':
        jira_cred = get_jira_readonly_creds(env)
    else:
        jira_cred = get_jira_readwrite_creds(env)

    jira = get_jira_connection(jira_cred)
    log.debug("Received param: {jira_issue}".format(jira_issue=jira_issue))
    jira_details = jira.issue(jira_issue)
    return jira_details.fields.summary


def get_jira_connection(jira_cred: JiraCredentials) -> JIRA:
    jira_url = jira_cred.url
    oauth = {
        'access_token': jira_cred.access_token,
        'access_token_secret': jira_cred.access_token_secret,
        'consumer_key': jira_cred.consumer_key,
        'key_cert': jira_cred.key_cert
    }
    log.debug("Connecting to Jira url: {url} and params: {params}".format(url=jira_url, params=oauth))
    return JIRA(server=jira_url, oauth=oauth)


def get_mysql_build_release(env, build_release_id):
    log.debug("get_jira_summary: env={env}, build_release_id={build_release_id}".format(env=env,build_release_id=build_release_id))

    mysql_cred = get_mysql_creds(env)
    log.info("db={db}, hostname={hostname}, userid={userid}, pw={pw}".format(
             db=mysql_cred.database, hostname=mysql_cred.hostname, userid=mysql_cred.userid,
             pw=mysql_cred.password))

    mysql_connection = get_mysql_connection(mysql_cred)


    log.info("Before connecting to Mysql")
    try:
        with mysql_connection.cursor() as cursor:
            sql = "SELECT * from audit_events"
            cursor.execute(sql)
            result = cursor.fetchone()
            log.info(result)
    finally:
        mysql_connection.close()


def get_mysql_connection(cred: MysqlCredentials):
    connection = pymysql.connect(host=cred.hostname,
                             user=cred.userid,
                             password=cred.password,
                             db=cred.database,
                             charset='utf8mb4',
                             cursorclass=pymysql.cursors.DictCursor)
    return connection


