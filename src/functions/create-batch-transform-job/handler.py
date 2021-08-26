import json
import boto3
from time import gmtime, strftime


def lambda_handler(event, context):

    # Create a boto3 sagemaker client
    sagemakerClient = boto3.client('sagemaker')

    params = event['inputs']['transform_job']['params']
    params['TransformJobName'] = params['TransformJobName'] + \
                                strftime("-%Y-%m-%d-%H-%M-%S", gmtime())
    params['TransformInput']['DataSource']['S3DataSource']['S3Uri'] = event['results']['athena_query']['output_location']
    model_name = params['ModelName']
    listmodel_response = sagemakerClient.list_models(
        SortBy='CreationTime',
        SortOrder= 'Descending',
        MaxResults=10,
        NameContains=model_name)
        
    model_list = listmodel_response["Models"]
    next_token = listmodel_response["NextToken"]

    if (len(model_list) == 0) & (next_token != ''):
        print("Using token for paging.")
        listmodel_response = sagemakerClient.list_models(
            NextToken=next_token,
            SortBy='CreationTime',
            SortOrder= 'Descending',
            MaxResults=10,
            NameContains=model_name
        )
        model_list = listmodel_response["Models"]
  
    if len(model_list) == 0:
        raise Exception('unable to find any model with name containing ' + model_name)
    else:    
        print("Model name: " + model_list[0]["ModelName"])

    params['ModelName'] = model_list[0]["ModelName"]
    response = sagemakerClient.create_transform_job(**params)
    return {
        'transform_job_arn': response['TransformJobArn']
    }
