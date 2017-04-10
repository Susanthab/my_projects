
# https://github.com/StackStorm/st2contrib/tree/master/packs/aws


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