#!/bin/bash

SHELL=/bin/bash
source ~/.bash_profile

#*************************************************************
# Author: Susanthab
# Date written: 11/20/2017
# Purpose: To perform backups of CouchBase.
# Revision: 2.1
#*************************************************************

# prerequisites
# 1. zip/unzip has to be installed in all the nodes. 
#    apt-get install zip unzip
# 2. aws cli

BACKUP_PATH=/backup
TIMESTAMP="$(date -u +"%Y-%m-%d")"
USER=Administrator
PASSWORD=750bfcc54a814bda8eefd06a
DOW=$(date +%u)
HOSTNAME=$(hostname)
instance_id=i-05bd94210f80a33d4
ec2_avail_zone=eu-west-1c

init () {

    WEEKNUMBER=$(( 1 + $(date +%U) - $(date -d "$(date -d "-$(($(date +%d)-1)) days")" +%U) ))
    WEEKDAY=$(date '+%A')

    echo "Week number of the month: ${WEEKNUMBER}W"
    echo "Week day: ${WEEKDAY:0:3}"

    WK_NUM_WK_DAY="${WEEKNUMBER}W:${WEEKDAY:0:3}"
    WK_NUM_WK_DAY=$(echo "$WK_NUM_WK_DAY" | awk '{print tolower($0)}')
    echo "WK_NUM_WK_DAY: $WK_NUM_WK_DAY"

    # as env variable from bash_profile
    FULL_BACKUP_DATE=$(echo $FULL_BACKUP_DATE)
    echo "full_backup_date: $FULL_BACKUP_DATE"

    TODAY=$(date +%Y-%m-%d)
    echo "today: $TODAY"

}

get_EC2_metadata () {
  #ec2_avail_zone=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
  region=${ec2_avail_zone:0:-1}
  CURRENT_NODE_IP=$(aws ec2 describe-instances --instance-ids ${instance_id} --region ${region} --query Reservations[].Instances[].PrivateIpAddress --output text)
  echo "Instance id: $instance_id"
  echo "AWS region : $region"
  echo "Node IP: $CURRENT_NODE_IP"
}

get_ec2_tag () {
  PROJECT_NAME=$(aws ec2 describe-instances --instance-ids $instance_id --region $region  --query 'Reservations[].Instances[].Tags[?Key==`team_id`].{val:Value}' --output text)
  CLUSTER_NAME=$(aws ec2 describe-instances --instance-ids $instance_id --region $region  --query 'Reservations[].Instances[].Tags[?Key==`cluster_name`].{val:Value}' --output text)
  S3_BUCKET_NAME=$(aws ec2 describe-instances --instance-ids $instance_id --region $region  --query 'Reservations[].Instances[].Tags[?Key==`s3_backup_loc`].{val:Value}' --output text)
  FULL_BACKUP_SCH=$(aws ec2 describe-instances --instance-ids $instance_id --region $region  --query 'Reservations[].Instances[].Tags[?Key==`full_backup_sch`].{val:Value}' --output text)
  BACKUP_S3_LOC="$S3_BUCKET_NAME/$PROJECT_NAME/$CLUSTER_NAME/$HOSTNAME/$TIMESTAMP"
  BACKUP_DIR="$BACKUP_PATH/$PROJECT_NAME/$CLUSTER_NAME/$HOSTNAME"
  echo "Project Name: $PROJECT_NAME"
  echo "Cluster name: $CLUSTER_NAME"
  echo "S3 backup location: $BACKUP_S3_LOC"
  echo "Backup dir of the node: $BACKUP_DIR"
  echo "Full backup schedule: $FULL_BACKUP_SCH"
  CHECK_BACKUP_SCH=$(echo "$FULL_BACKUP_SCH" | grep $WK_NUM_WK_DAY)
}

perform_cbbackup () {

  echo "CHECK_BACKUP_SCH: $CHECK_BACKUP_SCH"

  if [ -n "$CHECK_BACKUP_SCH" -a "$TODAY" != "$FULL_BACKUP_DATE" ]; then 
    backup_mode="full"
    sed -i -e "/export FULL_BACKUP_DATE=/d" ~/.bash_profile
    export FULL_BACKUP_DATE=$(date +%Y-%m-%d)
    echo "export FULL_BACKUP_DATE=$(date +%Y-%m-%d)" >> ~/.bash_profile    
  else 
    backup_mode="accu"
  fi

  echo "Backup mode: $backup_mode"
  echo "Backup directory: $BACKUP_DIR"
  mkdir -p $BACKUP_DIR
  pushd $BACKUP_DIR
  mkdir -p backup
  /opt/couchbase/bin/cbbackup http://$CURRENT_NODE_IP:8091 backup -m $backup_mode -u $USER -p $PASSWORD --single-node
}

s3_upload() {
    echo "Uploading $1 to s3 => ${BACKUP_S3_LOC}"
    aws s3 cp --only-show-errors "$1"  "s3://${BACKUP_S3_LOC}/"
    echo "Removing: $1"
    rm $1 -rf
}

get_latest_backup_dir () {
  pushd backup
  child_dir=$(ls -t . | head -1)
  echo "The child dir under backup dir is: $child_dir"
  LATEST_BACKUP_DIR=$(ls -t ./$child_dir | head -1)
  echo "Latest backup dir: $LATEST_BACKUP_DIR"
  SOURCE_DIR="$child_dir/$LATEST_BACKUP_DIR" 
  echo "Source dir for zip...: $SOURCE_DIR"
  
}

compress (){
  echo "Zipping the backup file..."
  BACKUP_ZIP=${LATEST_BACKUP_DIR}-"$(date -u +"%M-%S")".zip
  #zip -rq -D ${LATEST_BACKUP_DIR}.zip $SOURCE_DIR 
  zip -rq -D ${BACKUP_ZIP} $SOURCE_DIR 
  #BACKUP_ZIP="${LATEST_BACKUP_DIR}.zip"  
}

clear_backups () {
  if [ -n "$CHECK_BACKUP_SCH" -a "$TODAY" != "$FULL_BACKUP_DATE" ]; then
     echo "Clear the backup history before the full backup..."
     rm -rf $BACKUP_DIR/backup
  fi
  echo "debug: $backup_mode"
  echo "debug: $LATEST_BACKUP_DIR"
  if [ "$backup_mode" == "accu" ]; then
     echo "Latest backup dir: $LATEST_BACKUP_DIR"
     # clear the latest accu backup - NOT the full backup. 
     if [[ "${LATEST_BACKUP_DIR}" =~ $backup_mode ]]; then
        echo "About to DELETE accu backup"
        rm -rf $BACKUP_DIR/backup/$child_dir/$LATEST_BACKUP_DIR
     fi
  fi
}


echo ""
echo "01. Initialize variables..."
echo "==========================="
    init
echo ""
echo "02. Get EC2 metadata..."
echo "======================="
    get_EC2_metadata
echo ""
echo "03. Determining s3 bucket..."
echo "============================"
    get_ec2_tag
echo ""
echo "04. Clear backup history..."
echo "==========================="
    clear_backups
echo ""
echo "05. Perform cbbackup..."
echo "======================="
    perform_cbbackup
echo ""
echo "06. Get latest backup dir..."
echo "============================"
    get_latest_backup_dir
echo ""
echo "07. Compress the backup..."
echo "=========================="
    compress
echo ""
echo "08. Uploading backup zip file to s3..."
echo "======================================"
    echo "${BACKUP_DIR}/backup/${BACKUP_ZIP}"
    s3_upload ${BACKUP_DIR}/backup/${BACKUP_ZIP}
    cd ~
echo ""