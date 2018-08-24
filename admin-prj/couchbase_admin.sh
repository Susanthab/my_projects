
# Couchbase error logs
ls -ltr /opt/couchbase/var/lib/couchbase/logs/

# get index settings of CB server
curl http://10.240.35.108:8093/admin/settings -u Susantha:<pwd>

# Set max parallelsim to 2
# https://developer.couchbase.com/documentation/server/current/settings/query-settings.html
curl http://hostname:8093/admin/settings -d '{"max_parallelism":2}' -u user:pword

# active requests
select * From system:active_requests;

# query timeouts
select * from system:completed_requests where state = "timeout";

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
