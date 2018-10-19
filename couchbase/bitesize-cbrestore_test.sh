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


/opt/couchbase/bin/couchbase-cli bucket-create -c $HOST:8091 -u $LOGIN -p $PASSWORD --bucket $DESTINATION_BUCKET --bucket-type couchbase --bucket-ramsize $BUCKET_RAMSIZE --wait
CBRESTORE="/opt/couchbase/bin/cbrestore -u $LOGIN -p $PASSWORD -b $SOURCE_BUCKET -B $DESTINATION_BUCKET"
$CBRESTORE $RESTORE_LOC http://$HOST:8091


# copy s3 file to local host
aws s3 cp "s3://bitesize-dev/eu-west-1/ubathsu/backups/couchbase/kernel-glp-prd/full/node5/2018-08-06T060004Z-3.zip" .
aws s3 cp "s3://bitesize-stg/eu-west-1/staging/backups/couchbase/cb-tpr-dev-cbstg/restore/node1/2018-10-07T020012Z-full-24-49.zip" . 



https://s3-eu-west-1.amazonaws.com/bitesize-pre/us-east-2/glp1/backups/couchbase/glp-nft/dba/analytics-glp-nft/couchbase-i-02ff81349c0f941e4.pre.us-east-2.glp1/2018-07-23/2018-07-23T000005Z-diff-00-28.zip


# restore full-backup
#################################################
#!/bin/bash
buckets="common dcms gradebook ims lec led lpb"
path=$1

for b in $buckets
do
   echo "Restoring bucket: $b"
   echo ""
   cbrestore ${path} -u Administrator \
   -p bd9ae9125ec140598076ccc4 \
   -b ${b} \
   -B ${b} \
   http://10.1.32.122:8091

done
#################################################

bash cb_restore.sh susanthab twister75 \
"s3://bitesize-stg/eu-west-1/staging/backups/couchbase/cb-tpr-dev-cbstg/restore/node3/2018-10-07T020011Z-full-23-12.zip"

# restore diff backup
cbrestore 2018-08-14T164821Z/2018-08-14T165843Z-accu -u Administrator \
-p HOm1SIwLW5r3hjyY \
-b test_restore \
-B test_restore \
http://10.1.37.131:8091

# restore locally taken backup
cbrestore sample-backup/2018-07-31T214725Z/2018-07-31T214725Z-full -u Administrator \
-p 9545e99b4aed4145924189b8 \
-b test_backup \
-B test_backup \
http://10.1.44.9:8091



####### BUILD INDEXES
select name from system:indexes where keyspace_id='led';

BUILD INDEX ON `led`
(
`subscribeCourseIndex`,
`ledDocTypeCourseId`,
`ledassetTypeLearnerId`,
`ledCourseId`,
`ledSectionIdUserId`,
`learnercoursestateIndex`,
`LearnerAnalyticsSessionIndex`,
`ledDetails`,
`uniqueIdentifierIndex`,
`ledSubsCources_blankAssetType`,
`ledSectionId`,
`ledIndex500`,
`led`,
`ledSubsCources`,
`learnercourseIndex`,
`learnercourseoutcomesIndex`,
`laddiagnosticid`,
`learnercourseoutcomesArchiveIndex`,
`learnercourseglp1517231821348`,
`ledId`,
`ledLAID`,
`ledLearnerDetails`,
`instructorcoursesubscriptionIndex`
)
USING GSI;