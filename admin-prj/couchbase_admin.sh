
# cb bucket io priority
# https://docs.couchbase.com/server/4.1/rest-api/rest-bucket-set-priority.html
curl -v -u susanthab:pwd http://`echo $(hostname -I)`:8091/pools/default/buckets/lec | grep threadsNumber


#cbstats
/opt/couchbase/bin/cbstats 10.240.43.76:11210 all -b led -u susanthab -p pwd | grep oom

# Couchbase error logs
ls -ltr /opt/couchbase/var/lib/couchbase/logs/
grep -i "Hard out-of" /opt/couchbase/var/lib/couchbase/logs/debug.log

/opt/couchbase/bin/couchbase-cli rebalance-status -c 10.1.51.131 -u susanthab -p twister75
echo get unhealthy active servers
/opt/couchbase/bin/couchbase-cli server-list -c 10.1.51.131 -u susanthab -p twister75 | grep -w unhealthy | grep -w active | awk '{print$2}'
echo get unhealthy inactiveFailed servers
/opt/couchbase/bin/couchbase-cli server-list -c 10.1.51.131 -u susanthab -p twister75 | grep -w unhealthy | grep -w inactiveFailed | awk '{print$2}'
echo server list
/opt/couchbase/bin/couchbase-cli server-list -c 10.1.51.131 -u susanthab -p twister75

# use cbstats to see active and replica for a bucket.
# Bucket name and the server name is must.
# https://developer.couchbase.com/documentation/server/3.x/admin/CLI/cbstats-intro.html
cbstats 172.31.60.23:11210 all -b beer-sample -u susanthab -p <> | egrep -i "active_num|replica_num"

# num. of files for beer sample
ls -al /opt/couchbase/var/lib/couchbase/data/beer-sample | wc -l

# get index settings of CB server
curl http://`echo $(hostname -I)`:8093/admin/settings -u susanthab:<pwd>

# Set max parallelsim to 2
# https://developer.couchbase.com/documentation/server/current/settings/query-settings.html
curl http://`echo $(hostname -I)`:8093/admin/settings -d '{"max-parallelism":2}' -u user:pword

# active requests
select * From system:active_requests;

# query timeouts
select * from system:completed_requests where state = "timeout";

      (select meta().id, requestTime, users from system:completed_requests 
      where 
            requestTime > "2018-08-30 21:00"
            and state = "timeout" limit 5)

select * from system:completed_requests 
where completed_requests.requestTime > "2018-08-23 00:50:59.459049786 +0000 UTC"
and state = "timeout" 
limit 5;

# top 10 queries by time
# gives the nanoseconds
Select * from system:completed_requests where str_to_duration(serviceTime) > 5000000  
order by str_to_duration(serviceTime) DESC  limit 10 ;

# serviceTime > 10s (1e+10 ns)
Select *
from system:completed_requests where str_to_duration(serviceTime) > 1e+10   
limit 1;

Select meta().id, requestTime
from system:completed_requests where str_to_duration(serviceTime) > 2e+10  
and users="Administrator"
limit 50;

select * from 
  (Select meta().id, requestTime, users
         from system:completed_requests where str_to_duration(serviceTime) > 5000000000  
         limit 30) as A
where A.requestTime > "2018-09-07 21:40"
      and A.users="Administrator"

# 5 sec
select * from 
system:completed_requests
where requestTime > "2018-09-07 21:40"
      and str_to_duration(serviceTime) > 5000000000
limit 10

# Another query
select * from 
     (select id,users,state,statement from system:completed_requests
         where requestTime > "2018-08-29 00:39"
            and str_to_duration(serviceTime) > 5000000000
            limit 20 ) A
where A.users="Administrator"

select * from system:completed_requests use keys 
"[10.1.33.4:8091]bd915b86-6388-411f-94b0-302eea9fcb7e"

# requests for not using covering indexes
select *
  from system:completed_requests 
  where phaseCounts.`indexScan` is not missing
    and phaseCounts.`fetch` is not missing;

# PhaseCounts subdocuments has a PrimaryScan field
select *
  from system:completed_requests
  where phaseCounts.`primaryScan` is not missing;

# queries takes longer than 10 sec. 
select elapsedTime,serviceTime,str_to_duration(serviceTime) ttime,
phaseCounts.primaryScan,requestTime,state,statement,users 
from system:completed_requests 
where users='glp-kernel'
and str_to_duration(serviceTime) > 5000000000
order by ttime
limit 10;

# finds requests that do use indexes and that have a number of fetches to results ratio greater than ten
select phaseCounts.`fetch` / resultCount efficiency, *
  from system:completed_requests
  where phaseCounts.`indexScan` is not missing
   and phaseCounts.`fetch` / resultCount > 5000
  order by efficiency desc;

# costly queries.
select statement, array_sum(object_values(phaseCounts)) cost
  from system:completed_requests
  order by cost desc;

# primary scans
select requestId,statement,elapsedTime,serviceTime  from system:completed_requests
where phaseCounts.primaryScan is not missing
limit 5;

# to measure cpu presure
select avg(100*
           (str_to_duration(elapsedTime) - str_to_duration(executionTime))/
           str_to_duration(elapsedTime)), count(*)
  from system:active_requests;

select now_utc()
#https://dzone.com/articles/query-performance-monitoring-made-easy-with-couchb

#-------------#
# | cbstats | # 
#-------------#
cbstats -u Administrator -p <pwd> <ip>:11210 timings -b common
cbstats -u susanthab -p <pwd>  <ip>:11210 all -b led | egrep 'high_wat|low_wat'


# https://developer.couchbase.com/documentation/server/current/monitoring/monitoring-n1ql-query.html
Select *, meta().plan from system:completed_requests where resultCount > 10000 LIMIT 10;

Select *, meta().plan from system:completed_requests where elapsedTime > 5 LIMIT 10;

#https://developer.couchbase.com/documentation/server/current/monitoring/monitoring-n1ql-query.html#topic_nvs_ghr_dz__sys-user-info

#----------------------#
# | collect diag info |
#----------------------#
#https://developer.couchbase.com/documentation/server/current/cli/cbcollect-info-tool.html
# before running the temporary turn off the auto-failover. 
/opt/couchbase/bin/cbcollect_info /backup/logs/node_all.zip --bypass-sensitive-data=true --multi-node-diag=true
# Then copy the logs to s3 for further analysis. 
# change the s3 loc as required. The EC2 should have the permission to right to s3. 
aws s3 cp /backup/logs/node_10_1_37_131.zip "s3://bitesize-dev/eu-west-1/ubathsu/backups/cb-tpr-dev-cbtr01/diagnostic/"

#------------------------------------#
# | Couchbase Exceptions Java (JSDK) |
#------------------------------------#


# Upload a file from EC2 to s3. 
cp /opt/couchbase/var/lib/couchbase/logs/indexer.log /backup/diagnostic/
zip -rq indexer_node5.zip indexer.log
aws s3 cp indexer_node5.zip "s3://bitesize-pre/us-east-2/glp1/backups/couchbase/glp-nft/diagnostic/"


#---------------------#
# | Couchbase connect |
#---------------------#

# access admin UI. 
../../../../tools/add-to-sg.py --region us-west-2 --envtype prod --env glp1 --list
../../../../tools/add-to-sg.py --region us-west-2 --envtype prod --env glp1 --add --sg kernel-glp-prd-cb-glp1-prod-ui

#dev
python ../../../tools/couchbaseconnect.py -e ubathsu -r eu-west-1 -t dev -l

#stg
python ../../../tools/couchbaseconnect.py -e staging -r eu-west-1 -t stg -l

# pre
python ../../../tools/couchbaseconnect.py -e glp1 -r us-east-2 -t pre -l
python ../../../tools/couchbaseconnect.py -e glp1 -r us-east-2 -t pre -u susanthab -a <server name>

# prod
python ../../../tools/couchbaseconnect.py -e glp1 -r us-west-2 -t prod -l

./add-to-sg.py --region us-west-2 --envtype prod --env glp1 --list
add-to-sg.py --region us-west-2 --envtype prod --env glp1 --add --sg kernel-glp-prd-cb-glp1-prod-ui

/opt/couchbase/bin/cbq -u susanthab -p 

# admin UI format
adminui.cbclustername.namespace.glp1.us-west-2.prod.prsn.io

/opt/couchbase/var/lib/couchbase/inbox/chain.pem

## cb collect
mkdir -p /backup/cb_collect/09192018/ 
cd /backup/cb_collect/09192018/
cbcollect_info --tmp-dir=/backup/cb_collect/09192018/ -v 10_1_53_65.zip
