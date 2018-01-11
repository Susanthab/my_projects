#!/usr/bin/python
import boto3
import boto.utils
import awscli

data = boto.utils.get_instance_identity()
region_name = data['document']['region']
print(region_name)

instanceId = data['document']['instanceId']

client = boto3.client('autoscaling',region_name=region_name)
AutoScalingGroupName = client.describe_auto_scaling_instances(
    InstanceIds=[
        instanceId,
    ],
)['AutoScalingInstances'][0]['AutoScalingGroupName']
print(AutoScalingGroupName)

response = client.describe_auto_scaling_groups(
    AutoScalingGroupNames=[
        AutoScalingGroupName,
    ],
)['AutoScalingGroups'][0]['Instances']

client = boto3.client('ec2',region_name=region_name)

for id in response:
   instanceId=id['InstanceId']
   PublicIpAddress = client.describe_instances(InstanceIds=[instanceId])['Reservations'][0]['Instances'][0]['PublicIpAddress']
   print(PublicIpAddress)
   c = pymongo.MongoClient(host = PublicIpAddress, port = 27017)
   result = c.admin.command("ismaster")
   print(result)