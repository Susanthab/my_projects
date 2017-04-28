
# https://github.com/StackStorm/st2contrib/tree/master/packs/aws

# Install aws pack. 


## run in my personal aws account
st2 run aws.create_vm hostname="test_vm" 
dns_zone="ec2-107-21-20-123.compute-1.amazonaws.com" 
subnet_id="subnet-841412ae" image_id="ami-2d39803a" 
instance_type="t2.micro" 
key_name=test2 keyfile="~/aws/key_pair/test.pem" -a


## run in shared services non-prod aws account. 
st2 run aws.create_vm hostname=susanthab_test_vm dns_zone=ZJUW1FLH7BIEB security_group_ids=sg-4ad27f35   subnet_id=subnet-bd1476d8 image_id=ami-47bc4c51 instance_type=t2.micro key_name="susanthab" keyfile="~/aws/key_pair/susanthab.pem" -a

security_group_ids:
    type: string

st2 run aws.ec2_run_instances security_groups


st2 run aws.ec2_run_instances dns_zone="ZJUW1FLH7BIEB" security_group_ids={"sg-4ad27f35"}   subnet_id="subnet-bd1476d8" image_id="ami-47bc4c51" instance_type="t2.micro" key_name="susanthab" keyfile="~/aws/key_pair/susanthab.pem" placement AvailabilityZone="us-east-1b"

st2 run aws.ec2_run_instances security_group_ids=sg-4ad27f35  subnet_id=subnet-bd1476d8 image_id=ami-47bc4c51 instance_type=t2.micro placement AvailabilityZone=us-east-1b

st2 run aws.ec2_run_instances image_id=ami-47bc4c51 instance_type=t2.micro security_group_ids=sg-4ad27f35 placement=us-east-1a subnet_id=subnet-bd1476d8

## Auto Scaling group.

st2 run aws.autoscaling_create_launch_configuration LaunchConfigurationName="test-asg" ImageId="ami-47bc4c51" KeyName="~/aws/key_pair/susanthab.pem" SecurityGroups="sg-06249479" InstanceType="t2.micro"

## using aws cli
# worked. 
aws autoscaling create-launch-configuration --launch-configuration-name my-first-asg --image-id ami-47bc4c51 --instance-type t2.micro

--=================================================
## Parameters to create Launch Configuration in AWS.
--=================================================

image_id = ami-47bc4c51
KeyName = susanthab
SecurityGroups = sg-06249479
InstanceType = t2.micro
LaunchConfigurationName = launch-config-mongo-2
userdata =


#!/bin/bash

SYSTEMUSER="stanley"
PUBKEY=""

echo "########## Creating system user: ${SYSTEMUSER} ##########"
useradd ${SYSTEMUSER}
mkdir -p /home/${SYSTEMUSER}/.ssh
echo ${PUBKEY} > /home/${SYSTEMUSER}/.ssh/authorized_keys
chmod 0700 /home/${SYSTEMUSER}/.ssh
chmod 0600 /home/${SYSTEMUSER}/.ssh/authorized_keys
chown -R ${SYSTEMUSER}:${SYSTEMUSER} /home/${SYSTEMUSER}
if [ $(grep ${SYSTEMUSER} /etc/sudoers.d/* &> /dev/null; echo $?) != 0 ]
 then
   echo "${SYSTEMUSER}    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/st2
 fi

--=================================================
## Parameters to create ASG in AWS.
--=================================================

AvailabilityZone = us-east-1a, us-east-1b, us-east-1c
DesiredCapacity = 1
LaunchConfigurationName = launch-config-mongo-2
AutoScalingGroupName = test-asg-mongo2
MinSize = 1
MaxSize = 2


--======================
--Attach volumnes to ec2
--======================

# http://docs.aws.amazon.com/cli/latest/reference/ec2/attach-volume.html
aws ec2 attach-volume --volume-id vol-1234567890abcdef0 --instance-id i-01474ef662b89480 --device /dev/sdf

aws ec2 create-volume --size 80 --region us-east-1 --availability-zone us-east-1a --volume-type gp2



--block-device-mappings "[{\"DeviceName\": \"/dev/sdh\",\"Ebs\":{\"VolumeSize\":25}}]"

DeviceName=/dev/sdg,"Ebs": {"VolumeSize": 25}

{
    "DeviceName": "/dev/sdh", {
    "Ebs": {
      "VolumeSize": 300
    }
    }
}

{"DeviceName": "/dev/sdh","Ebs": {"VolumeSize": 25}}

"DeviceName=/dev/sdh","DeviceType=Ebs","VolumeSize=25"

{'DeviceName':'/dev/sdh'}

{a:1,b:2,c:3}

 BlockDeviceMappings=[
        {
            'DeviceName': '/dev/sdh',
            'Ebs': {
                'VolumeSize': 25,
            },
        },
    ]