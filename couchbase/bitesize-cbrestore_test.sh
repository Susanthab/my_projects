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
aws s3 cp "s3://bitesize-dev/eu-west-1/ubathsu/backups/couchbase/tpr-dev/testing/cb-052-tpr-dev/couchbase-i-05bd94210f80a33d4.dev.eu-west-1.ubathsu/2018-08-07/2018-08-07T180616Z-accu-06-18.zip" . 

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


# restore diff backup
cbrestore 2018-08-07T180122Z/2018-08-07T180616Z-accu -u Administrator \
-p 750bfcc54a814bda8eefd06a \
-b test-restore \
-B test-restore \
http://10.1.53.77:8091

# restore locally taken backup
cbrestore sample-backup/2018-07-31T214725Z/2018-07-31T214725Z-full -u Administrator \
-p 9545e99b4aed4145924189b8 \
-b travel-sample \
-B ts-restored \
http://10.1.38.96:8091



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