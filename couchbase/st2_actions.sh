

# Create IAM role for Couchbase (CouchbaseIAMRole). (default: us-east-1)
st2 run couchbase.create_couchbase_iam_instance_profile \
assume_role="arn:aws:iam::452395698705:role/st2_role"

# Create Security group for Couchbase (sg_couchbase). (default: us-east-1)
st2 run couchbase.create_couchbase_security_group \
vpc_id="vpc-4b864f2c"
assume_role="arn:aws:iam::452395698705:role/st2_role"

# Create a Standard Couchbase cluster on AWS. (default: us-east-1)
# AMI for Ubuntu ami-3f68db29 on ss-np
# AMI for CentOS ami-5006cf46 on ss-np

st2 run couchbase.create_couchbase_cluster \
cluster_name="cb-ee-centos-demo" \
security_group_id="sg-e971169c" \
subnets="subnet-262c5643,subnet-e1c5b5cb" \
storage_type="EBS" \
environment="dev" \
app_id=50 \
t_owner_individual="susantha.bathige@pearson.com" \
instance_type="t2.medium" \
image_id="ami-3d824b2b" \
key_name="susanthab" \
desired_capacity=3 \
iam_role_couchbase="CouchbaseIAMRole" \
volume_type="gp2" \
volume_size=150 \
full_backup_sch="1W:Sun" \
s3_backup_loc=" bitesize.prsn.couchbase.backup.stg" \
assume_role="arn:aws:iam::452395698705:role/st2_role"

# Create a multi-dimentional Couchbase cluster on AWS. (default: us-east-1)
st2 run couchbase.create_couchbase_cluster_with_multidimensional_scaling \
cluster_name="cbbackup-demo" \
security_group_id="sg-d706c2a2" \
subnets="subnet-262c5643,subnet-e1c5b5cb" \
storage_type="EBS" \
environment="dev" \
app_id=50 \
t_owner_individual="susantha.bathige@pearson.com" \
instance_type_data="t2.micro" \
instance_type_index="t2.micro" \
instance_type_query="t2.micro" \
image_id="ami-47bc4c51" \
key_name="susanthab" \
desired_capacity_data=2 \
desired_capacity_index=2 \
desired_capacity_query=2 \
iam_role_couchbase="CouchbaseIAMRole" \
volume_type="gp2" \
s3_backup_loc="bitesize.couchbase.backup.dev" \
assume_role="arn:aws:iam::452395698705:role/st2_role"

# Add node(s) to Couchbase cluster. (default: us-east-1)
# cluster_type (standard | multidimentional)
# node_service_offering ( N/A | data | index | query)
st2 run couchbase.add_nodes_to_couchbase_cluster \
cluster_name="cb-ce-centos-demo" \
cluster_type="standard" \
node_service_offering="N/A" \
number_of_nodes_toadd=1 \
assume_role="arn:aws:iam::452395698705:role/st2_role"


# Remove a node from Couchbase cluster. (default: us-east-1)
# node_type (standard | data | index | query)
# remove_or_terminate (remove | terminate)
st2 run couchbase.remove_node_from_couchbase_cluster \
cluster_name="cb-ce-centos-demo" \
node_type="standard" \
remove_or_terminate="terminate" \
assume_role="arn:aws:iam::452395698705:role/st2_role"

# Restore Couchbase backup. 
st2 run couchbase.restore_couchbase_backup \
region='us-east-1' \
assume_role='' \
cluster_name='restore-testing' \
host='172.31.54.167' \
user_name='admin' \
password='123' \
source_bucket_name='beer-sample' \
destination_bucket_name='beer-sample-restored' \
bucket_ramsize='256' \
backup_file_path='s3://bitesize-couchbase-backup/bitesize/restore-testing/ip-172-31-73-157/2018-01-11-17'

# Create S3 bucket.
# https://docs.aws.amazon.com/AmazonS3/latest/dev/lifecycle-transition-general-considerations.html
# https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
# environment (dev | qa | nft | stg | prod)
# enable_default_encryption (true | false). Default is set to false.
st2 run couchbase.create_s3_bucket_with_policies \
region="ca-central-1" \
destination_region="ap-southeast-1" \
s3_bucket_name="prsn.couchbase.backup" \
transition_days_to_ia=30 \
transition_days_to_glacier=60 \
expiration_days=90 \
environment='stg' \
team_id='bitesize' \
app_id=50 \
enable_default_encryption=true \
assume_role="arn:aws:iam::452395698705:role/st2_role"



