import boto3
from time import gmtime, strftime


def lambda_handler(event, context):
    sagemakerClient = boto3.client('sagemaker')

    model_params = event['inputs']['model_params']
    image = model_params['Image']
    execution_role = model_params['ExecutionRoleArn']

    if 'ModelName' in model_params and 'ModelDataUrl' in model_params:
        model_data_url = model_params['ModelDataUrl']
        model_name = model_params['ModelName'] + strftime("-%Y-%m-%d-%H-%M-%S", gmtime())
    else:
        training_job_arn = event['results']['training_job']['training_job_arn']
        model_name = training_job_arn[training_job_arn.index('training-job/') + 13:]
        model_data_url = event['results']['completed_training_job']['s3_model_artifacts']

    response = sagemakerClient.create_model(
        ModelName = model_name,
        PrimaryContainer = {
            'Image': image,
            'ModelDataUrl': model_data_url
        },
        ExecutionRoleArn = execution_role
    )

    model_arn = response['ModelArn']

    return {'model_arn': model_arn, 'model_name': model_name}
