
# Create security group for MongoDB server
st2 run aws.ec2_create_security_group name="MongoDBServerSecurityGroup" description="Security Group for MongoDB" vpc_id="vpc-4b864f2c"

# src_security_group_group_id is the security group for the web status page.
st2 run aws.ec2_authorize_security_group group_name="MongoDBServerSecurityGroup" ip_protocol="TCP" from_port=28017 to_port=28017 src_security_group_group_id="sg-06249479"

st2 run aws.ec2_authorize_security_group group_name="MongoDBServerSecurityGroup" ip_protocol="TCP" from_port=22 to_port=22 src_security_group_group_id="sg-06249479"

st2 run aws.ec2_authorize_security_group group_name="MongoDBServerSecurityGroup" ip_protocol="TCP" from_port=27000 to_port=28000 src_security_group_group_id="sg-06249479"


# To give Dinesh to incorporate to VPC creation. 
st2 run aws.ec2_create_security_group name="MongoDBServerSecurityGroup" description="Security Group for MongoDB" vpc_id="vpc-4b864f2c"
st2 run aws.ec2_authorize_security_group group_name="MongoDBServerSecurityGroup" ip_protocol="TCP" from_port=28017 to_port=28017 cidr_ip="0.0.0.0/0"
st2 run aws.ec2_authorize_security_group group_name="MongoDBServerSecurityGroup" ip_protocol="TCP" from_port=22 to_port=22 cidr_ip="0.0.0.0/0"
st2 run aws.ec2_authorize_security_group group_name="MongoDBServerSecurityGroup" ip_protocol="TCP" from_port=27000 to_port=28000 cidr_ip="0.0.0.0/0"

# Security Group rules for Apache Cassandra
st2 run aws.ec2_create_security_group name="CassandraRingSecurityGroup" description="Security Group for Cassndra Ring" vpc_id="vpc-4b864f2c"
st2 run aws.ec2_authorize_security_group group_name="MongoDBServerSecurityGroup" ip_protocol="TCP" from_port=7000 cidr_ip="0.0.0.0/0"
st2 run aws.ec2_authorize_security_group group_name="MongoDBServerSecurityGroup" ip_protocol="TCP" from_port=22 to_port=22 cidr_ip="0.0.0.0/0"
st2 run aws.ec2_authorize_security_group group_name="MongoDBServerSecurityGroup" ip_protocol="TCP" from_port=8080 to_port=28000 cidr_ip="0.0.0.0/0"




# Create IAM profile
st2 run nibiru.create_mongo_iam_instance_profile \
consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1100/state/vpc/"

# Delete IAM profile
st2 run nibiru.delete_mongo_iam_instance_profile 

