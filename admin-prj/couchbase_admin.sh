
# Couchbase error logs
ls -ltr /opt/couchbase/var/lib/couchbase/logs/

# get index settings of CB server
curl http://`echo $(hostname -I)`:8093/admin/settings -u susanthab:<pwd>

# Set max parallelsim to 2
# https://developer.couchbase.com/documentation/server/current/settings/query-settings.html
curl http://`echo $(hostname -I)`:8093/admin/settings -d '{"max-parallelism":4}' -u user:pword

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