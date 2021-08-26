from __future__ import print_function
import os, boto3, json, base64
import urllib.request, urllib.parse
import logging


def cloudwatch_events_codepipeline_notification(message, region):
    states = {'SUCCEEDED': 'good', 'INSUFFICIENT_DATA': 'warning', 'FAILED': 'danger'}

    return {
        "color": states[message['detail']['state']],
        "fallback": "Alarm {} triggered".format(message['detail-type']),
        "fields": [
            { "title": "EventType", "value": message['detail-type'], "short": True },
            { "title": "Pipeline", "value": message['detail']['pipeline'], "short": True },
            { "title": "Status", "value": message['detail']['state'], "short": True },
            { "title": "ExecutionId", "value": message['detail']['execution-id'], "short": True }
        ]
    }


def cloudwatch_events_glue_notification(message, region):
    states = {'TIMEOUT': 'danger', 'STOPPED': 'danger', 'FAILED': 'danger', 'Failed': 'danger'}
    if "crawlerName" in message["detail"]:
        return {
            "color": states[message['detail']['state']],
            "fallback": "Alarm {} triggered".format(message['detail-type']),
            "fields": [
                { "title": "Crawler", "value": message['detail']['crawlerName'], "short": True },
                { "title": "Status", "value": message['detail']['state'], "short": True },
                { "title": "ErrorMessage", "value": message['detail']['state'], "errorMessage": True},
                { "title": "CloudWatchLog", "value": message['detail']['cloudWatchLogLink'], "short": True },
                { "title": "Message", "value": message['detail']['message'], "short": True }
            ]
        }
    elif "jobRunId" in message["detail"]:
        return {
            "color": states[message['detail']['state']],
            "fallback": "Alarm {} triggered".format(message['detail-type']),
            "fields": [
                { "title": "EventType", "value": message['detail-type'], "short": True },
                { "title": "Job", "value": message['detail']['jobName'], "short": True },
                { "title": "Status", "value": message['detail']['state'], "short": True },
                { "title": "JobRunId", "value": message['detail']['jobRunId'], "short": True },
                { "title": "Message", "value": message['detail']['message'], "short": True }
            ]
        }


def cloudwatch_events_config_notification(message, region):
    return {
        "color": "danger",
        "fallback": "Alarm {} triggered".format(message['subject']),
        "fields": [
            { "title": "Resource", "value": message['resource'], "short": True },
            { "title": "Message", "value": message['message'], "short": True }
        ]
    }


def cloudwatch_alarm_notification(message, region):
    states = {'OK': 'good', 'INSUFFICIENT_DATA': 'warning', 'ALARM': 'danger'}

    return {
        "color": states[message['NewStateValue']],
        "fallback": "Alarm {} triggered".format(message['AlarmName']),
        "fields": [
            { "title": "AlarmName", "value": message['AlarmName'], "short": True },
            { "title": "Description", "value": message['AlarmDescription'], "short": True },
            { "title": "State", "value": message['NewStateValue'], "short": True },
            { "title": "Reason", "value": message['NewStateReason'], "short": True },
            { "title": "AlarmTime", "value": message['StateChangeTime'], "short": True },
            { "title": "Metric", "value": message['Trigger']['MetricName'], "short": True }
        ]
    }


def codepipeline_approval_notification(message, region):
    return {
        "color": "INSUFFICIENT_DATA",
        "fallback": "Approval action needed".format(message['approval']['pipelineName']),
        "fields": [
            { "title": "Pipeline", "value": message['approval']['pipelineName'], "short": True },
            { "title": "ConsoleLink", "value": message['consoleLink'], "short": True },
            { "title": "ApprovalLink", "value": message['approval']['approvalReviewLink'], "short": True }
        ]
    }


def default_notification(message):
    return {
        "fallback": "A new message",
        "fields": [{"title": "Message", "value": json.dumps(message), "short": False}]
    }


# Send a message to a slack channel
def notify_slack(message, region):
    slack_url = os.environ['SLACK_WEBHOOK_URL']
    slack_channel = os.environ['SLACK_CHANNEL']
    slack_username = os.environ['SLACK_USERNAME']
    slack_emoji = os.environ['SLACK_EMOJI']

    payload = {
        "channel": slack_channel,
        "username": slack_username,
        "icon_emoji": slack_emoji,
        "attachments": []
    }
    if "detail-type" in message or "source" in message:
        if message['source'] == 'aws.codepipeline':
            notification = cloudwatch_events_codepipeline_notification(message, region)
            payload['text'] = "AWS CloudWatch Event notification"
        elif  message['source'] == 'aws.glue':
            notification = cloudwatch_events_glue_notification(message, region)
            payload['text'] = "AWS CloudWatch Event notification"
        elif message['source'] == 'aws.config.security.alert':
            notification = cloudwatch_events_config_notification(message, region)
            payload['text'] = message['subject']
        payload['attachments'].append(notification)
    elif "approval" in message:
        notification = codepipeline_approval_notification(message, region)
        payload['text'] = "AWS Pipeline approval notification/ Action needed !"
        payload['attachments'].append(notification)
    elif "AlarmName" in message:
        notification = cloudwatch_alarm_notification(message, region)
        payload['text'] = "AWS Cloudwatch Alarm Notification"
        payload['attachments'].append(notification)
    else:
        payload['text'] = "AWS notification"
        payload['attachments'].append(default_notification(message))

    data = urllib.parse.urlencode({"payload": json.dumps(payload)}).encode("utf-8")
    req = urllib.request.Request(slack_url)
    urllib.request.urlopen(req, data)


def lambda_handler(event, context):
    message = json.loads(event['Records'][0]['Sns']['Message'])
    region = event['Records'][0]['Sns']['TopicArn'].split(":")[3]
    notify_slack(message, region)

    return message

#notify_slack({"AlarmName":"Example","AlarmDescription":"Example alarm description.","AWSAccountId":"000000000000","NewStateValue":"ALARM","NewStateReason":"Threshold Crossed","StateChangeTime":"2017-01-12T16:30:42.236+0000","Region":"EU - Ireland","OldStateValue":"OK"}, "eu-west-1")
