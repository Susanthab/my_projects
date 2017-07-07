

## Create IAM instance profile for MongoDB.
## This workflow will fail, if the instance profile already exists. 
# Executes with default values. 
st2 run nibiru.create_iam_instance_profile_forMongoDB  

# Create specific Role. 
st2 run nibiru.create_iam_instance_profile_forMongoDB Role_name="MongoDBRole2"

# Create mongo replica set. 

st2 run nibiru.create_mongo_asg \
VPCZoneIdentifier="subnet-cb3514f6,subnet-262c5643,subnet-e1c5b5cb,subnet-3983a04f,subnet-11d2ad49" \
LaunchConfigurationName="mongo-lc-2" \
Asg_name="mongo-asg-2" \
Environment="test" \
App_id=70 \
t_owner_individual="anyname@pearson.com" \
InstanceType="t2.micro" \
ImageId="ami-47bc4c51" \
Assume_role="arn:aws:iam::452395698705:role/st2_role"


# Execute Test action.

# Testing deployment to Shared services prod.
st2 run nibiru.create_mongo_asg \
LaunchConfigurationName="mongo_lc_1" \
Asg_name="mongo_asg_1" \
Environment="test" \
App_id=70 \
t_owner_individual="susantha.bathige@pearson.com" \
InstanceType="t2.micro" \
ImageId="ami-d7ecb7b7" \
KeyName="nibiru-demo" \
consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1009/state/vpc/"


