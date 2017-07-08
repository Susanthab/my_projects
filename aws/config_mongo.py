#!/usr/bin/python
import boto3
import boto.utils
import awscli
from subprocess import call

data = boto.utils.get_instance_identity()
region_name = data['document']['region']
print("Region: " + region_name)

current_rnstanceId = data['document']['instanceId']
print("Current Instance ID: " + current_rnstanceId)

client = boto3.client('autoscaling',region_name=region_name)
AutoScalingGroupName = client.describe_auto_scaling_instances(
    InstanceIds=[
        current_rnstanceId,
    ],
)['AutoScalingInstances'][0]['AutoScalingGroupName']
print("AutoScaling Group Name: " + AutoScalingGroupName)

response = client.describe_auto_scaling_groups(
    AutoScalingGroupNames=[
        AutoScalingGroupName,
    ],
)['AutoScalingGroups'][0]['Instances']
response = sorted(response)

client = boto3.client('ec2',region_name=region_name)

for id in range(0, len(response)):
  if current_rnstanceId == response[id]['InstanceId']:
    PrivateIpAddress = client.describe_instances(InstanceIds=[current_rnstanceId])['Reservations'][0]['Instances'][0]['PrivateIpAddress']
    print(PrivateIpAddress)
    cfg = ("{'_id': 'rs0', 'members': [{'_id': 1, 'host': '%s:27017'}]}" % PrivateIpAddress)
    shell_str = ("/usr/bin/mongo %s/admin --eval 'printjson(rs.initiate(%s))'" % (PrivateIpAddress,cfg))
    call(shell_str, shell=True)
    print(shell_str)

  print(id)