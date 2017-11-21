

# Pre-reqs
# The assume role, st2_role must exists on the AWS account with below permissions. 


# AMI details. 
Distributor ID:	Ubuntu
Description: Ubuntu 16.04.2 LTS
Release: 16.04
Codename: xenial

# Create instance IAM profile for Cassandra (default: us-east-1)
# The action will fail if the role exiss. (CassandraIAMRole)
st2 run bitesize-cassandra.create_cassandra_iam_instance_profile \
assume_role="arn:aws:iam::452395698705:role/st2_role"

# Create a ring on AWS.
st2 run bitesize-cassandra.create_cassandra_ring \
cluster_name="testing" \
security_group_id="sg-314fc841" \
subnets="subnet-262c5643,subnet-e1c5b5cb,subnet-3983a04f" \
storage_type="EBS" \
environment="test" \
app_id=50 \
t_owner_individual="susantha.bathige@pearson.com" \
instance_type="t2.micro" \
image_id="ami-3f68db29" \
key_name="cass-db" \
desired_capacity_seed=2 \
desired_capacity_nonseed=1 \
assume_role="arn:aws:iam::452395698705:role/st2_role" \
consul_endpoint="n/a"