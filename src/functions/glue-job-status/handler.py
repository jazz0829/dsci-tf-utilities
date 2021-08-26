import json
import boto3
import time
from time import gmtime, strftime


def lambda_handler(event, context):

    # Create a boto3 sagemaker client
    glueClient = boto3.client('glue', region_name='eu-west-1')

    response = glueClient.get_job_run(**event)

    return {
        'status': response['JobRun']['JobRunState']
    }
