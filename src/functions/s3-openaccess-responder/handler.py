import boto3
from botocore.exceptions import ClientError
import json
import os

ACL_RD_WARNING = "The S3 bucket ACL allows public read access."
PLCY_RD_WARNING = "The S3 bucket policy allows public read access."
ACL_WRT_WARNING = "The S3 bucket ACL allows public write access."
PLCY_WRT_WARNING = "The S3 bucket policy allows public write access."
RD_COMBO_WARNING = ACL_RD_WARNING + PLCY_RD_WARNING
WRT_COMBO_WARNING = ACL_WRT_WARNING + PLCY_WRT_WARNING


def policy_notifier(bucket_name):
    sns = boto3.client('sns')
    subject = "Potential compliance violation happened in bucket: " + bucket_name
    message = "Potential bucket compliance violation remedied. Please review the bucket " + bucket_name
    sns_message = {
        "message": message,
        "source": "aws.config.security.alert",
        "resource": bucket_name,
        "subject": "<!channel> :rotating_light: :rotating_light: S3 Security Alert :rotating_light: :rotating_light:"
    }
    response = sns.publish(
        TopicArn = os.environ['TOPIC_ARN'],
        Subject = subject,
        Message = json.dumps(sns_message)
    )


def lambda_handler(event, context):
    # instantiate Amazon S3 client
    s3 = boto3.client('s3')
    resource = list(event['detail']['requestParameters']['evaluations'])[0]
    bucket_name = resource['complianceResourceId']
    compliance_failure = event['detail']['requestParameters']['evaluations'][0]['annotation']
    if compliance_failure == ACL_RD_WARNING or compliance_failure == ACL_WRT_WARNING:
        s3.put_bucket_acl(Bucket = bucket_name, ACL = 'private')
        policy_notifier(bucket_name)
    elif compliance_failure == PLCY_RD_WARNING or compliance_failure == PLCY_WRT_WARNING:
        s3.put_bucket_acl(Bucket = bucket_name, ACL = 'private')
        s3.delete_bucket_policy(Bucket = bucket_name)
        policy_notifier(bucket_name)
    elif compliance_failure == RD_COMBO_WARNING or compliance_failure == WRT_COMBO_WARNING:
        s3.put_bucket_acl(Bucket = bucket_name, ACL = 'private')
        s3.delete_bucket_policy(Bucket = bucket_name)
        policy_notifier(bucket_name)
    return 0
