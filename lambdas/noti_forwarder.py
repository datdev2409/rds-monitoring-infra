import os
import json
import boto3
import urllib3
import textwrap

# Util functions
def get_message(event):
    event_id = event['detail']["EventID"]
    message = event['detail']['Message']
    source_arn = event['detail']['SourceArn']
    (rds_id, rds_console_url) = get_rds_info(source_arn)
    return textwrap.dedent(f'''\
        @everyone
        EventID: {event_id}
        EventMessage: {message}
        DBInstance: {rds_id}
        See more at: {rds_console_url}
    ''')

def get_rds_info(rds_arn):
    rds_info = rds_arn.split(':')
    region = rds_info[3]
    rds_id = rds_info[-1]
    rds_console_url = f"https://{region}.console.aws.amazon.com/rds/home?region={region}#database:id={rds_id}"
    return (rds_id, rds_console_url)

def send_sns_message(message, sns_topic_arn):
    client = boto3.client('sns')
    response = client.publish(TopicArn=sns_topic_arn, Message=message)
    return response['ResponseMetadata']['HTTPStatusCode']

def send_discord_message(message, discord_webhook_url):
    http = urllib3.PoolManager()
    response = http.request('POST', discord_webhook_url, fields={"content": message})
    return response.status

def lambda_handler(event, context):
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    discord_webhook_url = os.environ['DISCORD_WEBHOOK_URL']
    message = get_message(event)

    sns_resp_status = send_sns_message(message, sns_topic_arn)
    discord_resp_status = send_discord_message(message, discord_webhook_url)

    return (sns_resp_status, discord_resp_status)
