import sys
import time
import boto3

from st2actions.runners.pythonrunner import Action

# pylint: disable=too-few-public-methods
class restore_backup(Action):
    def run(self, region, credentials, cluster_name,host,user_name,password,source_bucket_name,destination_bucket_name,bucket_ramsize,backup_file_path,destination_bucket_name):

        client=None
        response=None
        instanceId=None
        output_string=""

        if credentials is not None:
           session = boto3.Session(
                aws_access_key_id=credentials['Credentials']['AccessKeyId'],
                aws_secret_access_key=credentials['Credentials']['SecretAccessKey'],
                aws_session_token=credentials['Credentials']['SessionToken'])
           client_asg = session.client('autoscaling', region_name=region)
           client_ec2 = session.client('ec2', region_name=region)
           client_ssm = session.client('ssm', region_name=region)
        else:
            client_asg = boto3.client('autoscaling', region_name=region)
            client_ec2 = boto3.client('ec2', region_name=region)
            client_ssm = boto3.client('ssm', region_name=region)

        if client_asg is None or client_ec2 is None or client_ssm is None:
            output_string = "ec2 client creation failed"
            return (False, output_string)

        asg_name='couchbase-asg-standard-' + cluster_name

        response = client_asg.describe_auto_scaling_groups(AutoScalingGroupNames = [asg_name])

        for i in response['AutoScalingGroups'][0]['Instances']:
            inst_id=i['InstanceId']
            instance_info = client_ec2.describe_instances(InstanceIds=[inst_id])
            ip_address=instance_info['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['PrivateIpAddresses'][0]['PrivateIpAddress']

            if ip_address == host:
                break

        Command = client_ssm.send_command( InstanceIds= [inst_id], DocumentName='AWS-RunShellScript', Comment='cbrestore', Parameters={ "commands":[ "./bitesize_cbrestore.sh " + host + user_name + password + source_bucket_name + destination_bucket_name + backup_file_path + bucket_ramsize })
        
        return (True, Command)


=================================




import sys
import time
import boto3

client = boto3.client('autoscaling', region_name='us-east-1')

client_ec2 = boto3.client('ec2', region_name='us-east-1')

asg_name='couchbase-asg-standard-restore-testing'

response = client.describe_auto_scaling_groups(AutoScalingGroupNames = [asg_name])

for i in response['AutoScalingGroups'][0]['Instances']:
  inst_id=i['InstanceId']
  instance_info = client_ec2.describe_instances(InstanceIds=[inst_id])
  ip_address=instance_info['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['PrivateIpAddresses'][0]['PrivateIpAddress']

