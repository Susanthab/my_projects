

# Pre-reqs
# The assume role, st2_role must exists on the AWS account with below permissions. 


# AMI details. 
Distributor ID:	Ubuntu
Description: Ubuntu 16.04.2 LTS
Release: 16.04
Codename: xenial

# Create instance IAM profile for Cassandra (default: us-east-1)
# The action will fail if the role exiss. (CassandraIAMRole)
st2 run bitesize_cassandra.create_cassandra_iam_instance_profile \
assume_role="arn:aws:iam::452395698705:role/st2_role"

# with specific role name. 
st2 run bitesize_cassandra.create_cassandra_iam_instance_profile \
assume_role="arn:aws:iam::452395698705:role/st2_role" \
iam_role_name="CassandraIAMRole_Demo"

# Create a ring on AWS. (default: us-east-1)
st2 run bitesize_cassandra.create_cassandra_ring \
cluster_name="testing" \
security_group_id="sg-314fc841" \
subnets="subnet-262c5643,subnet-e1c5b5cb,subnet-3983a04f" \
storage_type="EBS" \
environment="dev" \
app_id=50 \
t_owner_individual="anyone@pearson.com" \
instance_type="t2.micro" \
image_id="ami-3f68db29" \
key_name="cass-db" \
desired_capacity_seed=2 \
desired_capacity_nonseed=8 \
assume_role="arn:aws:iam::452395698705:role/st2_role"

# add nodes to Cassandra ring. (default: us-east-1)
# node_type (seed | nonseed) 
# Need to wait at least 5 min to add another node after adding one.
st2 run bitesize_cassandra.add_nodes_to_cassandra_ring \
assume_role="arn:aws:iam::452395698705:role/st2_role" \
cluster_name="testing" \
node_type="nonseed" \
number_of_nodes_toadd=1 \
consul_endpoint="for future use."

# Remove a node from Cassandra ring. (default: us-east-1)
# node_type (seed | nonseed)
# remove_or_terminate (remove | terminate)
st2 run bitesize_cassandra.remove_node_from_cassandra_ring \
assume_role="arn:aws:iam::452395698705:role/st2_role" \
cluster_name="testing" \
node_type="nonseed" \
remove_or_terminate="terminate"


