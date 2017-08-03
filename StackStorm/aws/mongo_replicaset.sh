

## Create IAM instance profile for MongoDB.
## This workflow will fail, if the instance profile already exists. 
# Executes with default values. 
st2 run nibiru.create_iam_instance_profile_forMongoDB  

# Create specific Role. 
st2 run nibiru.create_iam_instance_profile_forMongoDB Role_name="MongoDBRole2"

# Create mongo replica set. 
# Shared services non-prod. 
st2 run nibiru.create_mongo_asg \
LaunchConfigurationName="mongo_lc_pre_demo" \
Asg_name="mongo_asg_pre_demo" \
Environment="test" \
App_id=90 \
t_owner_individual="susantha.bathige@pearson.com" \
InstanceType="t2.micro" \
ImageId="ami-12de8c72" \
KeyName="nibiru-demo" \
consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1100/state/vpc/"


# Testing deployment to Shared services prod.
st2 run nibiru.create_mongo_asg \
LaunchConfigurationName="mongo-lc-1" \
Asg_name="mongo-asg-1" \
Environment="test" \
App_id=70 \
t_owner_individual="susantha.bathige@pearson.com" \
InstanceType="t2.micro" \
ImageId="ami-d7ecb7b7" \
KeyName="nibiru-demo" \
consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1200/state/vpc/"


st2 run nibiru.create_mongo_asg \
LaunchConfigurationName="mongo-lc-test" \
Asg_name="mongo-asg-test" \
Environment="test" \
App_id=99 \
t_owner_individual="susantha.bathige@pearson.com" \
InstanceType="t2.micro" \
ImageId="ami-d7ecb7b7" \
KeyName="nibiru-demo" \
consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1009/state/vpc/"


