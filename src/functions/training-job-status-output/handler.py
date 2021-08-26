import json
import boto3
from time import gmtime, strftime

def lambda_handler(event, context):

    # Create a boto3 sagemaker client
    sagemakerClient = boto3.client('sagemaker')

    training_job_arn = event['training_job_arn']
    training_job_name = training_job_arn[training_job_arn.index('training-job/') + 13:]

    response = sagemakerClient.describe_training_job(
        TrainingJobName = training_job_name
    )

    training_job_status = response['TrainingJobStatus']

    if training_job_status == 'Completed':
        s3_model_artifacts = response['ModelArtifacts']['S3ModelArtifacts']
        return { 's3_model_artifacts': s3_model_artifacts, 'status': training_job_status }
    else:
        return { 'status': training_job_status }
