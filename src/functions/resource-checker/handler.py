import json
import os
import boto3

def ec2_without_tags_found_notifier(instance):
    sns = boto3.client('sns')
    id = instance.id
    type = instance.instance_type
    key  = instance.key_name
    subject = "Running EC2 instances without Tags"
    message = f'The EC2 instance of type: {type} with the Id: {id} and with Key {key} will be stopped as it has no (or empty) Project tag'

    sns_message = {
        "message": message
    }

    sns.publish(
        TopicArn = os.environ['TOPIC_ARN'],
        Subject = subject,
        Message = json.dumps(sns_message)
    )

def lambda_handler(event, context):
    client = boto3.resource('ec2')
    instance_id = event['detail']['instance-id']
    state = event['detail']['state']
    
    if state == 'running' and instance_id is not None:
        instance = client.Instance(instance_id)
        lifecycle = instance.instance_lifecycle
        if lifecycle != 'spot':
            tags = instance.tags
            tag_dict = {tag['Key']:tag['Value'] for tag in tags}
            if not tag_dict.get('Project',None):
                ec2_without_tags_found_notifier(instance)
                instance.stop()

