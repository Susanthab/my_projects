import time
import boto3
from st2actions.runners.pythonrunner import Action

# pylint: disable=too-few-public-methods
class nodetool_status(Action):
    def run(self, region, credentials, asg_name):

        client=None
        instanceId=None
        output_string=""

        if credentials is not None:
           session = boto3.Session(
                aws_access_key_id=credentials['Credentials']['AccessKeyId'],
                aws_secret_access_key=credentials['Credentials']['SecretAccessKey'],
                aws_session_token=credentials['Credentials']['SessionToken'])
           client = session.client('autoscaling', region_name=region)
        else:
            client = boto3.client('autoscaling', region_name=region)

        if client is None:
            output_string = "ec2 client creation failed"
            return (False, output_string)

        response = client.describe_auto_scaling_groups(AutoScalingGroupNames = [asg_name])

        azs = response['AutoScalingGroups'][0]['Instances']

        max = 0
        for a in azs:
        az1 = a['AvailabilityZone']
        count = 0
        for b in azs:
            az2 = b['AvailabilityZone']
            if az1 == az2:
            count += 1
            if max < count:
                max = count
                instanceId = b['InstanceId']

        return (True, instanceId)