import json
import boto3
import time
from time import gmtime, strftime


def lambda_handler(event, context):

    # Create a boto3 sagemaker client
    glueClient = boto3.client('glue', region_name='eu-west-1')

    params = event['params']

    response = glueClient.start_job_run(**params)

    return {
        'JobName': params['JobName'],
        'RunId': response['JobRunId']
    }
