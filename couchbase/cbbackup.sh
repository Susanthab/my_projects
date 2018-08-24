#!/bin/bash

#*************************************************************
# Author: Susanthab
# Date written: 11/20/2017
# Purpose: To perform backups of CouchBase.
# Revision: 2.1
#*************************************************************

# if the script is already running, then exit.
for pid in $(pgrep -f cbbackup.sh); do
    if [ $pid != $$ ]; then
        echo "[$(date)] : cbbackup.sh : Process is already running with PID $pid"
        exit 1
    else
      echo "Running with PID $pid"
    fi  
done

SHELL=/bin/bash
source ~/.bash_profile

# prerequisites
# 1. zip/unzip has to be installed in all the nodes. 
#    apt-get install zip unzip
# 2. aws cli

BACKUP_PATH={{ couchbase_backup_path }}
USER={{ cluster_user_name }}
PASSWORD={{ cluster_password }}
CURRENT_NODE_IP={{ ansible_ec2_local_ipv4 }}
FULL_BACKUP_SCH={{ full_backup_schedule }}
S3_BUCKET_NAME={{ s3_backup_location }}

HOSTNAME=$(hostname)
DOW=$(date +%u)
TIMESTAMP="$(date -u +"%Y-%m-%d")"

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

set_backup_dir () {
  BACKUP_DIR="$BACKUP_PATH/$HOSTNAME"
  BACKUP_S3_LOC="$S3_BUCKET_NAME/$HOSTNAME/$TIMESTAMP"
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
  echo "Latest backup dir $LATEST_BACKUP_DIR"
  echo "Source dir $SOURCE_DIR"
  BACKUP_ZIP=${LATEST_BACKUP_DIR}-"$(date -u +"%M-%S")".zip
  zip -rq -D ${BACKUP_ZIP} $SOURCE_DIR 
}

clear_full_backup () {
  if [ -n "$CHECK_BACKUP_SCH" -a "$TODAY" != "$FULL_BACKUP_DATE" ]; then
     echo "Clear the backup history before the full backup..."
     rm -rf $BACKUP_DIR/backup
  fi
}

clear_accu_backup () {
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

echo "----------------------------"
echo "| 01. Initialize variables |"
echo "----------------------------"
        init
        sleep 10m
echo "-----------------------"
echo "| 02. Set backup dirs |"
echo "-----------------------"
        set_backup_dir
echo "----------------------------"
echo "| 03. Clear backup history |"
echo "----------------------------"
        clear_full_backup
echo "------------------------"
echo "| 04. Perform cbbackup |"
echo "------------------------"
        perform_cbbackup
echo "-----------------------------"
echo "| 05. Get latest backup dir |"
echo "-----------------------------"
        get_latest_backup_dir
echo "---------------------------"
echo "| 06. Compress the backup |"
echo "---------------------------"
        compress
echo "---------------------------------------"
echo "| 07. Uploading backup zip file to s3 |"
echo "---------------------------------------"
        echo "${BACKUP_DIR}/backup/${BACKUP_ZIP}"
        s3_upload ${BACKUP_DIR}/backup/${BACKUP_ZIP}
echo ""
echo "--------------------------"
echo "| 08. Clear accu backups |"
echo "--------------------------"
    clear_accu_backup
    cd ~