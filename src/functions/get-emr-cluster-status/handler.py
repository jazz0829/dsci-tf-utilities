import boto3

def lambda_handler(event, context):
    client = boto3.client('emr')
    response = client.describe_cluster(**event)

    return {
        'status': response['Cluster']['Status']['State']
    }