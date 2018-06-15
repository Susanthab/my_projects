#!/bin/bash
exec > "/var/log/cbrestore.log" 2>&1

HOST=$1
LOGIN=$2
PASSWORD=$3
SOURCE_BUCKET=$4
DESTINATION_BUCKET=$5
BACKUP_FILE_PATH=$6
BUCKET_RAMSIZE=$7
HOSTNAME=$(hostname)
RESTORE_LOC="/var/www/html/couchbase-backup/restore/$HOSTNAME"

input_var () {
    printf "Input variables...\n"
    printf "Couchbase host which is backup will be restored: $HOST\n"
    printf "Source bucket name: $SOURCE_BUCKET\n"
    printf "Destination bucket name: $DESTINATION_BUCKET\n"
    printf "Backup file path in s3: $BACKUP_FILE_PATH\n"
    printf "Bucket RAM size: $BUCKET_RAMSIZE\n"
}

create_dir () {
    printf "Create a restore dir...\n"
    mkdir -p $RESTORE_LOC
    pushd $RESTORE_LOC
}

download_file () {
    aws s3 sync $BACKUP_FILE_PATH .
}

unzip_file () {
    printf "Unzip backup file(s)...\n"
    unzip '*.zip'
}

backup_restore () {

    /opt/couchbase/bin/couchbase-cli bucket-create -c $HOST:8091 -u $LOGIN -p $PASSWORD --bucket $DESTINATION_BUCKET --bucket-type couchbase --bucket-ramsize $BUCKET_RAMSIZE --wait
    CBRESTORE="/opt/couchbase/bin/cbrestore -u $LOGIN -p $PASSWORD -b $SOURCE_BUCKET -B $DESTINATION_BUCKET"
    $CBRESTORE $RESTORE_LOC http://$HOST:8091

    printf "Clear files from restore location...\n"
    rm -rf *
}

#**************************************************************

echo -e "-------------------"
echo -e "| Input variables |"
echo -e "-------------------"
    input_var
echo -e "----------------------"
echo -e "| Create restore dir |"
echo -e "----------------------"
    create_dir
echo -e "--------------------------------"
echo -e "| Download backup file from s3 |"
echo -e "--------------------------------"
    download_file
echo -e "---------------------"
echo -e "| Unzip backup file |"
echo -e "---------------------"
    unzip_file
echo -e "------------------"
echo -e "| Restore backup |"
echo -e "------------------"
    backup_restore

#**************************************************************