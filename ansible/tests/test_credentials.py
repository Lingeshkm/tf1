#!/usr/bin/python3

import argparse
import boto3

import logging
import handler

log = logging.getLogger()
log.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
log.addHandler(ch)

def parse_cmd_line():
    parser = argparse.ArgumentParser()
    parser.add_argument('--env', default='dev', choices=['dev','staging','prod'],
                        help="AWS environment(dev,staging,prod)")
    args = parser.parse_args()

    if not args:
        parser.print_help()
    return args


def main():
    args = parse_cmd_line()
    boto3.setup_default_session(profile_name="bc-{env}".format(env=args.env))
    ssm = boto3.client('ssm', region_name='us-east-2')
    env = ssm.get_parameter(Name='default_env')

    log.info("main: env={env}".format(env=args.env))

    issue_key='BC-5010'
    jira_summary = handler.get_jira_summary(args.env, 'read', issue_key)
    log.info("JIRA summary using **readonly** credential")
    print(issue_key + ":" + jira_summary)
    jira_summary = handler.get_jira_summary(args.env, 'write', 'BC-5010')
    log.info("JIRA summary using **readwrite** credential")
    print(issue_key + ":" + jira_summary)
    handler.get_mysql_build_release(args.env, '1')
    log.info("The tests complete successfully")


if __name__ == "__main__":
    main()
