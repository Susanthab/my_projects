curl -v -X POST -u 'Administrator':'8d89d97f6889476f89810832' \
  http://host:8091/controller/createReplication \
  -d fromBucket='beer-sample' \
  -d toCluster='inst1' \
  -d toBucket='beer-sample' \
  -d replicationType='continuous'


curl -v -u Administrator:'555293688a9c4d4ebdb6c20d' \
  http://host:8091/pools/default/remoteClusters \
  -d 'name=remote1' \
  -d 'hostname=host:8091' \
  -d 'username=Administrator' \
  -d 'password=gzC#qRoBDCSYjy8XjwglBF0Q'

curl -v -X GET -u Administrator:'8d89d97f6889476f89810832' \
http://host:8091/settings/indexes

curl -v -u Administrator:'8d89d97f6889476f89810832' \
http://host:9102/getIndexStatus

curl -v -u Administrator:'8d89d97f6889476f89810832' \
http://host/indexStatus

curl -v -u Administrator:8d89d97f6889476f89810832 \
http://host:8091/indexStatus


curl -v http://host:8093/query/service -d "statement=select * from default"

curl -v -u Administrator:'gzC#qRoBDCSYjy8XjwglBF0Q' http://host:18093/query/service -d 'statement=select 1'

# worked.
curl -v http://10.1.39.150:8093/query/service -d 'statement=select 1'
curl -v -u Administrator:'gzC#qRoBDCSYjy8XjwglBF0Q' http://10.1.39.8:8093/query/service -d 'statement=CREATE PRIMARY INDEX `beer_primary` ON `beer-sample` WITH { "defer_build":true }'

BUILD INDEX ON `beer-sample` (`beer_primary`) USING GSI

curl -v -u 'Administrator':'gzC#qRoBDCSYjy8XjwglBF0Q' https://host:8091/pools/nodes


# Execution
# param_1=source_server_endpoint (roue53 dns)
# param_2=source_user_name
# param_3=source_user_pwd
# param_4=destination_server_endpoint (route53 dns)
# param_5=destination_user_name
# param_6=destination_user_pwd

#python CreateReplication.py \
#    'source_host' \
#    'Administrator' \
#    '555293688a9c4d4ebdb6c20d' \
#    'dest_host' \
#    'Administrator' \
#    'gzC#qRoBDCSYjy8XjwglBF0Q'

python CreateReplication.py \
    'couchbase.cbst2-40.tpr-dev.ubathsu.eu-west-1.ubathsu.eu-west-1.dev' \
    'Administrator' \
    '123' \
    'cbtr10-tpr-dev-cb.ubathsu.eu-west-1.dev' \
    'Administrator' \
    '123'

python CreateIndexes.py \
    'couchbase.cbst2-40.tpr-dev.ubathsu.eu-west-1.ubathsu.eu-west-1.dev' \
    'Administrator' \
    '123' \
    'cbtr10-tpr-dev-cb.ubathsu.eu-west-1.dev' \
    'Administrator' \
    '123'




###### NFT - eses cluster replication set up.
python CreateReplication.py \
    'couchbase.eses.glp-nft.glp1.us-east-2.glp1.us-east-2.pre' \
    'susanthab' \
    '123' \
    'eses-glp-nft-cb.glp1.us-east-2.glp1.us-east-2.pre' \
    'temp_replication' \
    '12qwaszx@'

###### NFT - kernel cluster replication set up.
python CreateReplication.py \
    'couchbase.kernal.glp-nft.glp1.us-east-2.glp1.us-east-2.pre' \
    'susanthab' \
    '123' \
    'kernel-glp-nft-cb.glp1.us-east-2.glp1.us-east-2.pre' \
    'temp_replication' \
    '1qaz2wsx@'


###### PROD(prd) - kernel cluster replication set up.
python CreateReplication.py \
    '10.240.32.89' \
    'susanthab' \
    '123' \
    'kernel-glp-prd-cb.glp1.us-west-2.prod' \
    'temp-xdcr-kernel' \
    '1qaz2wsx@'


###### PROD(prd) - eses cluster replication set up.
python CreateReplication.py \
    'couchbase.eses.glp-prd.glp1.us-west-2.glp1.us-west-2.prod' \
    'susanthab' \
    '123' \
    'eses-glp-prd-cb.glp1.us-west-2.prod' \
    'temp-xdcr-eses' \
    '1qaz2wsx@'

###### PROD(prd) - analytics cluster replication set up.
python CreateReplication.py \
    'couchbase.analytics.glp-prd.glp1.us-west-2.glp1.us-west-2.prod' \
    'susanthab' \
    '123' \
    'anlyt-glp-prd-cb.glp1.us-west-2.prod' \
    'temp-xdcr-anlyt' \
    '1qaz2wsx@'

###### PROD(uat) - eses cluster replication set up.
python CreateReplication.py \
    'couchbase.eses.glp-uat.glp1.us-west-2.glp1.us-west-2.prod' \
    'susanthab' \
    'twister75' \
    'eses-glp-uat-cb.glp1.us-west-2.prod' \
    'temp-xdcr-eses-uat' \
    '12qwaszx@'

###### PROD(uat) - kernel cluster replication set up.
python CreateReplication.py \
    'couchbase.kernal.glp-uat.glp1.us-west-2.glp1.us-west-2.prod' \
    'susanthab' \
    'twister75' \
    'kernel-glp-uat-cb.glp1.us-west-2.prod' \
    'temp-xdcr-kernel-uat' \
    '12qwaszx@'

    ###### PROD(uat) - analytics cluster replication set up.
python CreateReplication.py \
    'couchbase.analytics.glp-uat.glp1.us-west-2.glp1.us-west-2.prod' \
    'susanthab' \
    'twister75' \
    'anlyt-glp-uat-cb.glp1.us-west-2.prod' \
    'temp-xdcr-anlyt-uat' \
    '12qwaszx@'