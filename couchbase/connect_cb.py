
# install the SDK first.
# https://developer.couchbase.com/documentation/server/current/sdk/python/start-using-sdk.html
# This will create a test bucket.
from couchbase.cluster import Cluster
from couchbase.cluster import PasswordAuthenticator
from couchbase.admin import Admin
import requests
import json

#url='http://couchbase.cb-susa.tpr-dev.ubathsu.us-west-2.dev/pools/nodes'
#pip install git+http://github.com/couchbase/couchbase-python-client@2.3.5
url='http://couchbase.cb-test-susa.tpr-dev.ubathsu.us-west-2.dev:8091/pools/nodes'

u = 'Administrator'
#p = '78c89e1cbf1543b581da9ec4'
p = '6ab7c538b98e448680f017c1'
response = requests.get(url, auth=(u, p))

nodes = json.loads(response.text)['nodes']

hosts=""
for n in nodes:
  hosts = hosts + ',' + (n['hostname']).split(":")[0]

hosts = hosts.lstrip(',')
print(hosts)

cluster = Cluster('couchbase://hosts')
#print(cluster)

authenticator = PasswordAuthenticator(u, p)
cluster.authenticate(authenticator)

#cb = cluster.open_bucket('beer-sample')

adm = Admin(u, p, host=hosts)

adm.bucket_create('test-bucket',
                  bucket_type='couchbase',
                  ram_quota=100)

print(cluster)


- ec2_instance_facts:
    instance_ids:
      - "{{ ansible_ec2_instance_id }}"
    
      - "{{ ansible_ec2_placement_availability_zone }}"
  register: temp_ec2_info



curl -X POST -u Administrator:8d89d97f6889476f89810832 http://couchbase.cb001.tpr-dev.ubathsu.eu-west-1.ubathsu.eu-west-1.dev:8091/pools/default/buckets \
-d name=newBucketDestination -d conflictResolutionType=lww \
-d authType=sasl -d ramQuotaMB=4096 \
-d bucketType=couchbase 