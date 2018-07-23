

# Create IAM role for Couchbase (CouchbaseIAMRole). (default: us-east-1)
st2 run couchbase.create_couchbase_iam_instance_profile \
namespace='tpr-dev' \
deployment_name='couchbtest' \
role='database' \
database_system='couchbase' \
iam_role_name='couch-iam-test' \
iam_policy_name='couch-iam-test-policy' \
region='us-west-2' \
s3_bucket_name='couchb-bkt' \
account_id='602604727914'

# Create Security group for Couchbase (sg_couchbase). (default: us-east-1)
# vpc_id and env parameter values need to be taken from Bitesize modular.
st2 run couchbase.create_couchbase_security_group \
group_name="couchbase_vm_sg" \
vpc_id="vpc-cd44cbb4 " \
env='susanthab'

# Create a Standard Couchbase cluster on AWS. (default: us-east-1)
# AMI for Ubuntu ami-3f68db29 on ss-np
# AMI for CentOS ami-5006cf46 on ss-np

# ami-3d824b2b
# Run in bitesize environment. 
st2 run couchbase.create_couchbase_cluster \
vpc_id="vpc-cd44cbb4" \
namespace="ubathsu" \
storage_type="EBS" \
environment="dev" \
app_id=50 \
instance_type="t2.medium" \
image_id="ami-5216952a" \
key_name="bitesize" \
desired_capacity=3 \
volume_type="gp2" \
volume_size=150 \
full_backup_sch="1W:Sun" \
s3_backup_loc=" bitesize.prsn.couchbase.backup.stg" \
t_owner_individual="susantha.bathige@pearson.com"

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
deployment_name="nft1-glp" \
namespace="tpr-dev" \
database_system="couchbase" \
number_of_nodes_toadd=1

# Remove a node from Couchbase cluster. (default: us-east-1)
# node_type (standard | data | index | query)
# remove_or_terminate (remove | terminate)
st2 run couchbase.remove_node_from_couchbase_cluster \
deployment_name="nft1-glp" \
namespace="tpr-dev" \
role="database" \
remove_or_terminate="terminate"


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
region="us-west-2" \
s3_bucket_name="prsn.couchbase.backup" \
transition_days_to_ia=30 \
transition_days_to_glacier=60 \
expiration_days=90 \
environment='stg' \
team_id='bitesize' \
app_id=50 \
enable_default_encryption=true


st2 run couchbase.create_s3_bucket \
region="ca-central-1" \
bucket_name="bitesize.50.prsn.couchbase.backup.ap-southeast-1.stg.replica" \
acl="private"


st2 run couchbase.create_alb \
lb_name="couchbase-tpr-dev" \
subnets="subnet-42de2109,subnet-95e358cf,subnet-4f64b936" \
tg_name="tpr-dev-couchbtest" \
asg_name="couchbase-couchbtest-tpr-dev" \
sg_name="couchbase-alb" \
sg_name_tag="couchbase-alb-dev" \
namespace="tpr-dev" \
deployment_name="couchtest" \
role="database" \
database_system="couchbase"

# common action to create a security group.
st2 run couchbase.create_security_group \
group_name="couchbase-alb" \
description="Security group for Couchbase security group." \
name="couchbase-alb-dev" \
namespace="tpr-dev" \
deployment_name="couchtest" \
role="database" \
database_system="couchbase" \
vpc_id="vpc-d51985ac"

st2 run couchbase.bump_release_version_userdata_temp \
asg_name="couchbase-ubathsu-dev-tpr-dev-couchb-64" \
ansible_couchb_release="v1.2.2" \
docker_engine_version="v1" \
namespace="tpr-dev" \
deployment_name="couchb-64"

# restore cb-backup
st2 run couchbase.restore_couchbase_backup \
deployment_name="cb013" \
namespace="tpr-dev" \
role="database" \
node_type="stabdard" \
host="10.1.55.31" \
source_bucket_name='beer-sample' \
destination_bucket_name='beer-sample2' \
bucket_ramsize=256 \
backup_file_path='s3://bitesize-dev/us-west-2/ubathsu/backups/couchbase/tpr-dev/testing/cb010-tpr-dev/couchbase-i-069847ba6430b20a4.dev.us-west-2.ubathsu/2018-06-15/2018-06-15T000005Z-full-00-07.zip'

couchbase-cli server-list -c 10.240.51.188:8091 -u Administrator -p d50b99228f054289a8aac812


couchbase-cli server-list -c http://host -u admin -p 12qwaszx@


curl -v -u Administrator:6ea53ff70d14409ab05e2078 http://host/pools/nodes

curl -u Administrator:gzC#qRoBDCSYjy8XjwglBF0Q http://host/pools/nodes