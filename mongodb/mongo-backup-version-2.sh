#!/usr/bin/env bash

SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#*************************************************************
# Author: Susanthab
# Enhancements: s3 location, worked only in one secondary, etc
# Date written: 9/21/2017
# Purpose: To perform backups of mongodb replica sets. 
# Revision: 2.0
#*************************************************************

# prerequisites
# 1. zip/unzip has to be installed in all the nodes. 
#    apt-get install zip unzip
# 2. aws cli

_BACKUP_PATH="/tmp/mongodump"
_TIMESTAMP="$(date -u +"%Y-%m-%d-%H")"
_BACKUP_DIR="${_BACKUP_PATH}/${STACK_NAME}/${_TIMESTAMP}"
_MONGODUMP_ARGS="--quiet --out $_BACKUP_DIR"

_USER="susanthab"
_PWD="abc123"

check_root_user () {
  if [ ${USER:-} != "root" ]
  then
      echo "Must be root user."
      exit 1
  else 
      echo "Executing under root user..."
  fi
}

get_EC2_metadata () {
  instance_id=$(ec2metadata --instance-id)
  region=$(ec2metadata --availability-zone | sed 's/[a-z]$//')
  echo "Instance id: $instance_id"
  echo "AWS region : $region"
}

get_ec2_tag () {
  #STACK_NAME=$(aws ec2 describe-instances --instance-ids $instance_id --region $region  --query 'Reservations[].Instances[].Tags[?Key==`Project`].{val:Value}' --output text)
  STACK_NAME=$(aws ec2 describe-instances --instance-ids $instance_id --region $region  --query 'Reservations[].Instances[].Tags[?Key==`Stack`].{val:Value}' --output text)
  #BACKUP_S3_LOC="nibiru-demo/${STACK_NAME}/${_TIMESTAMP}"
  BACKUP_S3_LOC="bitesize-be-backups/${STACK_NAME}/${_TIMESTAMP}"
  echo "S3 backup location: $BACKUP_S3_LOC"
}

backup_mongodb () {
  mkdir -p ${_BACKUP_DIR}
  pushd ${_BACKUP_DIR}
  mongodump --username "$_USER" --password "$_PWD" ${_MONGODUMP_ARGS}
  zip -rq -D "${_TIMESTAMP}.zip" *
  BACKUP_ZIP="${_TIMESTAMP}.zip"
}

select_secondary_node_for_mongodump () {
    R=`/usr/bin/mongo admin -u "$_USER" -p "$_PWD" --eval "printjson(rs.status())" | grep name | awk '{print $3}' | tr -d '",'`
    me=`/usr/bin/mongo admin -u "$_USER" -p "$_PWD" --eval "db.isMaster().me" | tail -1`
    echo "R: $R"
    max_id=0
    n=0
    for i in $R
    do
        Is_Secondary=`/usr/bin/mongo ${i}/admin -u "$_USER" -p "$_PWD" --eval "db.isMaster().secondary" | grep true`
        echo "Is_Secondary: $Is_Secondary"
        member_id=`/usr/bin/mongo ${i}/admin -u "$_USER" -p "$_PWD" --eval "rs.conf().members[$n]._id" | tail -c 3`
        if [ $member_id -gt $max_id -a "$Is_Secondary"=="true" ]; then
            max_id=$member_id
            mongodump_node=$i
        fi
        ((n++))
    done
    echo $me
    echo $mongodump_node
    if [ "$me" == "$mongodump_node" ]; then
        echo "MongoDB backup is executing on: $me" 
        do_the_rest=true
    else 
        echo "Not the correct node for mongo backup. Aborting the script."
    fi
}

s3_up() {
    echo "Uploading $1 to s3"
    aws s3 cp --only-show-errors "$1"  "s3://${BACKUP_S3_LOC}/"
    rm $_BACKUP_PATH -r
}

echo ""
echo "01. Check for root user..."
check_root_user
select_secondary_node_for_mongodump
echo ""
if [ $do_the_rest ]; then
    echo ""
    echo "02. Get EC2 metadata..."
    get_EC2_metadata
    echo ""
    echo "03. Determining s3 bucket..."
    get_ec2_tag
    echo ""
    echo "04. Identifying the secondary node to use for backup and start mongo backup..."
    backup_mongodb
    echo ""
    echo "05. Uploading backup zip file to s3..."
    s3_up ${_BACKUP_DIR}/${BACKUP_ZIP}
fi