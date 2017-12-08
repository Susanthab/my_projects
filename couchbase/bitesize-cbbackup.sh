#!/usr/bin/env bash

SHELL=/bin/bash

#*************************************************************
# Author: Susanthab
# Date written: 11/20/2017
# Purpose: To perform backups of mongodb replica sets. 
# Revision: 2.0
#*************************************************************

# prerequisites
# 1. zip/unzip has to be installed in all the nodes. 
#    apt-get install zip unzip
# 2. aws cli

BACKUP_PATH="/var/www/html/couchbase-backup"
TIMESTAMP="$(date -u +"%Y-%m-%d-%H")"
HOSTNAME=$(hostname)
S3_BUCKET_NAME="nibiru-demo"

USER="admin"
PASSWORD="12qwaszx@"

get_EC2_metadata () {
  instance_id=$(ec2metadata --instance-id)
  region=$(ec2metadata --availability-zone | sed 's/[a-z]$//')
  CURRENT_NODE_IP=$(aws ec2 describe-instances --instance-ids ${instance_id} --region ${region} --query Reservations[].Instances[].PrivateIpAddress --output text)
  echo "Instance id: $instance_id"
  echo "AWS region : $region"
  echo "Node IP: $CURRENT_NODE_IP"
}

get_ec2_tag () {
  PROJECT_NAME=$(aws ec2 describe-instances --instance-ids $instance_id --region $region  --query 'Reservations[].Instances[].Tags[?Key==`Project`].{val:Value}' --output text)
  CLUSTER_NAME=$(aws ec2 describe-instances --instance-ids $instance_id --region $region  --query 'Reservations[].Instances[].Tags[?Key==`cluster_name`].{val:Value}' --output text)
  BACKUP_S3_LOC="$S3_BUCKET_NAME/$PROJECT_NAME/$CLUSTER_NAME/$TIMESTAMP"
  echo "Project Name: $PROJECT_NAME"
  echo "Cluster name: $CLUSTER_NAME"
  echo "S3 backup location: $BACKUP_S3_LOC"
}

cbbackup_full_diff () {

  DOW=$(date +%u)
  echo "Day of the week: $DOW"
  if [ "$DOW" == 7 ]; then 
    # sunday
    backup_mode="full"
  else 
    backup_mode="diff"
  fi

  BACKUP_DIR="$BACKUP_PATH/$PROJECT_NAME/$CLUSTER_NAME/$HOSTNAME"
  echo "Backup directory: $BACKUP_DIR"
  mkdir -p $BACKUP_DIR
  pushd $BACKUP_DIR
  mkdir -p backup
  cbbackup http://$CURRENT_NODE_IP:8091 backup -m $backup_mode -u $USER -p $PASSWORD --single-node
  zip -rq -D "${TIMESTAMP}.zip" *
  BACKUP_ZIP="${TIMESTAMP}.zip"
}

s3_upload() {
    echo "Uploading $1 to s3"
    aws s3 cp --only-show-errors "$1"  "s3://${BACKUP_S3_LOC}/"
    echo "Removing: $1"
    rm $1 -r
}

echo ""
echo "01. Get EC2 metadata..."
    get_EC2_metadata
echo ""
echo "02. Determining s3 bucket..."
    get_ec2_tag
echo ""
echo "03. Perform cbbackup..."
    cbbackup_full_diff
echo ""
echo "04. Uploading backup zip file to s3..."
    s3_upload ${BACKUP_DIR}/${BACKUP_ZIP}