
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
