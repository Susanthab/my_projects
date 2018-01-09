#!/bin/bash

# This script is used to restore Couchbase backup.

# need to have proper permission to do this. 
aws s3 sync s3://optimal-aws-nz-play-config/ec2-operator /home/ec2-user
curl -O https://s3.amazonaws.com/bitesize-couchbase-backup/bitesize/backup-testing/ip-172-31-65-242/2018-01-05-22/2018-01-05T220540Z-full-05-52.zip

HOST=$1
LOGIN=$2
PASSWORD=$3
SOURCE_BUCKET=$4
DESTINATION_BUCKET=$5
NOW=$6
HOME=/home/ubuntu
BACKUP_SOURCE=$7
HOSTNAME=$(hostname)
CBRESTORE="/home/ubuntu/custom-couchbase-cli/bin/cbrestore -u $LOGIN -p $PASSWORD -b $BUCKET -B $BUCKET"
CONFIG="--config /home/ubuntu/.s3cfg"
mkdir backup
cd backup
s3cmd --recursive $CONFIG get * "s3://<S3 bucket>/couchbase/$NOW/"

cd ..
$CBRESTORE ./backup http://$HOST:8091


couchbase-cli bucket-create -c 172.31.54.105:8091 -u admin -p 12qwaszx@ --bucket beer-sample-restored --bucket-type couchbase --bucket-ramsize 200


#execute as 

./bitesize_cbrestore.sh \
54.235.105.226 \
admin \
12qwaszx@ \
gamesim-sample \
gamesim-sample-restored \
s3://bitesize-couchbase-backup/bitesize/backup-testing/ip-172-31-65-242/2018-01-05-22 \
120 