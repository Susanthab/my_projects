
# create cassandra cluster on AWS SS-NP account (us-east-1).
st2 run nibiru.create_cassandra_ring \
LaunchConfigurationName="cass-ryan-test" \
Asg_name="cass-ryan-test" \
Environment="test" \
App_id=50 \
t_owner_individual="anyone@pearson.com" \
InstanceType="t2.micro" \
ImageId="ami-3f68db29" \
KeyName="cass-db" \
DesiredCapacity_seed=2 \
DesiredCapacity_nonseed=1 \
Assume_role="arn:aws:iam::452395698705:role/st2_role" \
consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1009/state/vpc/"