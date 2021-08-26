import boto3
import os
import json

def dev_endpoint_found_notifier(endpoint_name):
    sns = boto3.client('sns')
    subject = "Glue development endpoint is still running after 6 PM "
    message = "This development endpoint *" + endpoint_name + "* is going to be deleted as it's still running after 6 PM."

    sns_message = {
        "message": message
    }

    sns.publish(
        TopicArn = os.environ['TOPIC_ARN'],
        Subject = subject,
        Message = json.dumps(sns_message)
    )

def lambda_handler(event, context):
    client = boto3.client('glue')
    available_endpoints = client.get_dev_endpoints()
    for endpoint in available_endpoints['DevEndpoints']:
        if endpoint['Status'] == 'READY' and not endpoint['EndpointName'].endswith('_do_not_delete'):
            dev_endpoint_found_notifier(endpoint['EndpointName'])
            client.delete_dev_endpoint(EndpointName = endpoint['EndpointName'])