import boto3


def lambda_handler(event, context):
    emr_client = boto3.client('emr')
    s3_client = boto3.client('s3')
    params = event['params']

    if 'scripts_location' in event:
        steps = []
        bucket = event['scripts_location']['bucket']
        s3_response = s3_client.list_objects_v2(
            Bucket = bucket,
            Prefix = event['scripts_location']['prefix']
        )

        for item in s3_response['Contents']:
            steps.append(
                {
                    "Name": item['Key'][item['Key'].rfind('/') + 1:len(item['Key'])].replace('.py', ''),
                    "ActionOnFailure": "CONTINUE",
                    "HadoopJarStep": {
                        "Jar": "command-runner.jar",
                        "Args": [
                            "spark-submit",
                            "--deploy-mode",
                            "cluster",
                            "s3://{0}/{1}".format(bucket, item['Key'])
                        ]
                    }
                }
            )
        params['Steps'] = steps

    emr_response = emr_client.run_job_flow(**params)

    return {
        'ClusterId': emr_response['JobFlowId']
    }
