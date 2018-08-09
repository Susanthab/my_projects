
# nodeStatuses
curl -v -u Administrator:gzC#qRoBDCSYjy8XjwglBF0Q http://host:8091/nodeStatuses

# node info
curl -v -u Administrator:037330e3108b4501a1a6ec16 http://host:8091/pools/nodes

# create a new bucket.
curl -X PUT -u Administrator:037330e3108b4501a1a6ec16 http://host:8091/pools/default/buckets \
-d name=newBucketSource \
-d ramQuotaMB=100 \
-d bucketType=couchbase

curl -X POST -u Administrator:037330e3108b4501a1a6ec16 -d 'name=newBucketSource', 'ramQuotaMB=100', 'bucketType=couchbase' http://host:8091/pools/default/buckets
curl -vgsk --show-error --max-time 15 -X POST -u Administrator:037330e3108b4501a1a6ec16 'http://host:8091/pools/default/buckets' -d "name=newBucketSource&ramQuotaMB=100&bucketType=couchbase"

# Insert data.
curl -vgsk --show-error --max-time 15 -X POST -u Administrator:037330e3108b4501a1a6ec16 http://host:8093/query/service  -d 'statement=INSERT INTO `Test` ( KEY, VALUE ) VALUES ( "k001", { "id": "01", "type": "airline"})'

# node info
url='http://host:8091/pools/nodes'
nodes = json.loads(response.text)['nodes']
services = ['fts2', 'index', 'kv', 'n1ql']
for n in nodes:
   result = all(elem in n['services'] for elem in services)
   print result
#print out

# create index
curl -vgsk --show-error --max-time 15 -X POST -u Administrator:037330e3108b4501a1a6ec16 'http://host:8093/query/service' -d 'statement=CREATE PRIMARY INDEX `Test` ON `Test` USING GSI;'

# select
curl -vgsk --show-error --max-time 15 -X POST -u Administrator:037330e3108b4501a1a6ec16 'http://host:8093/query/service' -d 'statement=SELECT type FROM `Test` WHERE id="01";'

#INSERT INTO `Test` ( KEY, VALUE ) VALUES ( "k001", { "id": "01", "database": "couchbase"})
#CREATE PRIMARY INDEX `Test` ON `Test` USING GSI;
#SELECT type FROM `Test` WHERE id="01";
#UPDATE `Test` SET type="airline2" WHERE id="01";
#DELETE FROM `Test` WHERE id="01";
#DROP INDEX `Test`.`Test`
#UPDATE `Test` SET type="airline2" WHERE id="k001"

# rbac
curl -vgsk --show-error --max-time 15 -X GET -u Administrator:gzC#qRoBDCSYjy8XjwglBF0Q https://host:18091/settings/rbac/roles
