import json
import boto3
from time import gmtime, strftime


def lambda_handler(event, context):

    # Create a boto3 sagemaker client
    sagemakerClient = boto3.client('sagemaker')

    transform_job_arn = event['transform_job_arn']
    transform_job_name = transform_job_arn[transform_job_arn.index(
        'transform-job/') + 14:]

    response = sagemakerClient.describe_transform_job(
        TransformJobName=transform_job_name
    )
    status = response['TransformJobStatus']

    s3_uri = response['TransformInput']['DataSource']['S3DataSource']['S3Uri']
    indexOfLastSlash = s3_uri.rfind('/')
    filename = s3_uri[indexOfLastSlash + 1:]

    output_path = response['TransformOutput']['S3OutputPath']
    output_location = output_path + filename + '.out'

    if (status == 'Completed'):
        return {
            'status': status,
            'output_location': output_location
        }

    return {'status': status}
