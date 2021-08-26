import json
import boto3
import time
from time import gmtime, strftime


def lambda_handler(event, context):
    # Create a boto3 sagemaker client
    athenaClient = boto3.client('athena', region_name='eu-west-1')
    s3Resource = boto3.resource('s3', region_name='eu-west-1')
    s3Client = boto3.client('s3', region_name='eu-west-1')

    response = athenaClient.start_query_execution(**event)

    query_execution_id = response['QueryExecutionId']
    status = 'RUNNING'
    while (status == 'RUNNING'):
        time.sleep(2)
        response = athenaClient.get_query_execution(
            QueryExecutionId=query_execution_id)
        status = response['QueryExecution']['Status']['State']
    if (status == 'SUCCEEDED'):
        output_location = response['QueryExecution']['ResultConfiguration']['OutputLocation']

        prefix_length = 5  # s3://
        indexOfThirdSlash = output_location[prefix_length:].find(
            '/') + prefix_length
        bucket_name = output_location[prefix_length:indexOfThirdSlash]
        key = output_location[indexOfThirdSlash + 1:]

        indexOfLastSlash = key.rfind('/')
        new_key = key[:indexOfLastSlash] + \
                  '/output' + key[indexOfLastSlash:]

        bucket = s3Resource.Bucket(bucket_name)
        copy_source = {
            'Bucket': bucket_name,
            'Key': key
        }
        bucket.copy(copy_source, new_key)

        new_location = 's3://' + bucket_name + '/' + new_key

        response = s3Client.select_object_content(
            Bucket=bucket_name,
            Key=new_key,
            ExpressionType='SQL',
            Expression="Select count(0) from S3Object s",
            InputSerialization={
                'CSV': {
                    'FileHeaderInfo': 'USE',
                    'RecordDelimiter': '\n',
                    'FieldDelimiter': ',',
                    'AllowQuotedRecordDelimiter': True
                }
            },
            OutputSerialization={
                'CSV': {
                }
            }
        )
        for event in response['Payload']:
            if 'Records' in event:
                records = event['Records']['Payload'].decode('utf-8').rstrip('\n')

        return {
            'output_location': new_location,
            'output_row_count': int(records)
        }

    return {
        'status': status
    }
