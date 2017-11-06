#!/usr/bin/env bash

#****************************************
# Author: Susanthab
# Date written: 9/21/2017
# Purpose: To perform Cassandra snapshots. 
# Version: 1.0
#****************************************

# prerequisites
# 1. zip/unzip has to be installed in all the nodes. 
#    apt-get install zip unzip
# 2. aws cli

# Set the data dir path here. 
_DATA_DIR='/data/cassandra/data/'
# Set the cassandra.yaml path here. 
_CASS_YAML='/etc/cassandra/cassandra.yaml'
_S3PARENT_BUCKET_NAME='nibiru-demo'
_AuthEnabled=false
_UserName=""
_Pwd=""

mkdir /tmp/cass_schema_bkp/

_SNAPSHOT_NAME=cassnap-$(date +%Y-%m-%d-%H%M%S)
_DATE=`date +"%Y-%m-%d--%H-%M-%S"`
_CLUSTER_NAME=$(grep cluster_name ${_CASS_YAML}|grep -v "^#" | tr -d "'" | awk -F':' '{print $2}')
_HOSTNAME=`hostname`
_HOSTIP=$(/sbin/ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

KEYSPACES=`ls $_DATA_DIR`
echo "List of key spaces which is going to backup: $KEYSPACES"

schema_backup () {
  echo "Taking schema backup."
  echo "DESC SCHEMA" > "/tmp/schema.sql"
  if [ ${_AuthEnabled} == "true" ]; then
     cqlsh $_HOSTIP -u $_UserName -p $_Pwd -f /tmp/schema.sql > /tmp/cass_schema_bkp/schema_backup.sql
  else
     cqlsh $_HOSTIP -f /tmp/schema.sql > /tmp/cass_schema_bkp/schema_backup.sql
  fi
  echo "Schema backup location: $_BACKUP_S3_LOC"
  aws s3 cp --only-show-errors /tmp/cass_schema_bkp/schema_backup.sql "s3://${_BACKUP_S3_LOC}/"
}

snapshot () {
for ks in $KEYSPACES
do
   echo ""
   echo "________ NEW RUN ________"
   echo "Taking daily db dump of KS: $ks for $_DATE with id=$_SNAPSHOT_NAME"
   nodetool snapshot --tag $_SNAPSHOT_NAME $ks
   _S3_LOC="$_BACKUP_S3_LOC/$ks"
  
   TABLES=`ls $_DATA_DIR\$ks`
   for tb in $TABLES
   do
      pushd "$_DATA_DIR$ks/$tb/snapshots/$_SNAPSHOT_NAME"
      SNAPSHOT_PATH="$_DATA_DIR$ks/$tb/snapshots/$_SNAPSHOT_NAME/"
      zip -rq -D "${_SNAPSHOT_NAME}_${tb}.zip" *
      BACKUP_ZIP="${_SNAPSHOT_NAME}_${tb}.zip"
      s3_up "$_DATA_DIR$ks/$tb/snapshots/$_SNAPSHOT_NAME/$BACKUP_ZIP"
   done
   echo ""
   echo "Remove director: $SNAPSHOT_PATH"
   cd ..
   rm $SNAPSHOT_PATH -r
done
}

s3_up() {
    echo "Uploading $1 to s3"
    aws s3 cp --only-show-errors "$1"  "s3://${_S3_LOC}/"
}

get_EC2_metadata () {
  instance_id=$(ec2metadata --instance-id)
  region=$(ec2metadata --availability-zone | sed 's/[a-z]$//')
  echo "Instance id: $instance_id"
  echo "AWS region : $region"
}

get_ec2_tag_and_s3_location () {
  _STACK_NAME=$(aws ec2 describe-instances --instance-ids $instance_id --region $region  --query 'Reservations[].Instances[].Tags[?Key==`Name`].{val:Value}' --output text)
  _BACKUP_S3_LOC="${_S3PARENT_BUCKET_NAME}/${_STACK_NAME}/${_CLUSTER_NAME}/${_HOSTNAME}/${_DATE}"
  echo "S3 backup location: $_BACKUP_S3_LOC"
}

#Execution
get_EC2_metadata
get_ec2_tag_and_s3_location
snapshot
schema_backup