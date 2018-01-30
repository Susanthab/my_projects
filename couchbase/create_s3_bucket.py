import time
import boto3

from st2actions.runners.pythonrunner import Action

# pylint: disable=too-few-public-methods
class create_s3_bucket(Action):
    def run(self,region,credentials,bucket_name,acl):

        client=None
        response=None
        output_string=""
 
        if credentials is not None:
           session = boto3.Session(
                aws_access_key_id=credentials['Credentials']['AccessKeyId'],
                aws_secret_access_key=credentials['Credentials']['SecretAccessKey'],
                aws_session_token=credentials['Credentials']['SessionToken'])
           client_s3 = session.client('s3', region_name=region)
        else:
            client_s3 = boto3.client('s3', region_name=region)

        if client_s3 is None:
            output_string = "ec2 client creation failed"
            return (False, output_string)

        if region == 'us-east-1': 
            response = client_s3.create_bucket( ACL=acl, Bucket=bucket_name) 
        else: 
            response = client_s3.create_bucket( Bucket=bucket_name, CreateBucketConfiguration={'LocationConstraint': region})

        return (True, response)     
