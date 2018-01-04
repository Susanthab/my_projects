#!/bin/bash

# This script is used to restore Couchbase backup.

HOST=$1
LOGIN=$2
PASSWORD=$3
BUCKET=$4
NOW=$5
HOME=/home/ubuntu
CBRESTORE="/home/ubuntu/custom-couchbase-cli/bin/cbrestore -u $LOGIN -p $PASSWORD -b $BUCKET -B $BUCKET"
CONFIG="--config /home/ubuntu/.s3cfg"
mkdir backup
cd backup
s3cmd --recursive $CONFIG get * "s3://<S3 bucket>/couchbase/$NOW/"

cd ..
$CBRESTORE ./backup http://$HOST:8091
