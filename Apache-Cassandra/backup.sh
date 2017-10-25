#!/usr/bin/env bash

_SNAPSHOT_NAME='cassnap-2017-10-23-193241'
#_SNAPSHOT_NAME=cassnap-$(date +%Y-%m-%d-%H%M%S)
_DATA_DIR='/data/cassandra/data/'
_DATE=`date +"%Y-%m-%d--%H-%M-%S"`
_CASS_YAML="/etc/cassandra/cassandra.yaml"
_CLUSTER_NAME=$(grep cluster_name ${_CASS_YAML}|grep -v "^#"|awk -F':' '{print $2}')
_HOSTNAME=`hostname`

KEYSPACES=`ls $_DATA_DIR`

snapshot () {
for ks in $KEYSPACES
do

   echo "________ NEW RUN ________"
   echo "Taking daily db dump for $_DATE with id=$_SNAPSHOT_NAME"
   #nodetool snapshot --tag $_SNAPSHOT_NAME $ks
   _S3_LOC="$_BACKUP_S3_LOC/$ks"
  
   TABLES=`ls $_DATA_DIR\$ks`
   for tb in $TABLES
   do
      pushd "$_DATA_DIR$ks/$tb/snapshots/$_SNAPSHOT_NAME"
      zip -rq -D "${_SNAPSHOT_NAME}${tb}.zip" *
      BACKUP_ZIP="${_SNAPSHOT_NAME}${tb}.zip"
      s3_up "$_DATA_DIR$ks/$tb/snapshots/$_SNAPSHOT_NAME/$BACKUP_ZIP"
   done
done
}

s3_up() {
    echo "Uploading $1 to s3"
    aws s3 cp --only-show-errors "$1"  "s3://${_S3_LOC}/"
    #rm $_BACKUP_PATH -r
}

get_EC2_metadata () {
  instance_id=$(ec2metadata --instance-id)
  region=$(ec2metadata --availability-zone | sed 's/[a-z]$//')
  echo "Instance id: $instance_id"
  echo "AWS region : $region"
}

get_ec2_tag_and_s3_location () {
  _STACK_NAME=$(aws ec2 describe-instances --instance-ids $instance_id --region $region  --query 'Reservations[].Instances[].Tags[?Key==`Name`].{val:Value}' --output text)
  _BACKUP_S3_LOC="nibiru-demo/${_STACK_NAME}/${_CLUSTER_NAME}/${_HOSTNAME}/${_DATE}"
  echo "S3 backup location: $BACKUP_S3_LOC"
}

#Execution
get_EC2_metadata
get_ec2_tag_and_s3_location
snapshot