
# install the SDK first.
# https://developer.couchbase.com/documentation/server/current/sdk/python/start-using-sdk.html
# This will create a test bucket.
from couchbase.cluster import Cluster
from couchbase.cluster import PasswordAuthenticator
from couchbase.admin import Admin
import requests
import json

url='http://couchbase-test-dev-1866867088.us-west-2.elb.amazonaws.com/pools/nodes'

u = 'admin'
p = '12qwaszx@'
response = requests.get(url, auth=(u, p))

nodes = json.loads(response.text)['nodes']

hosts=""
for n in nodes:
  hosts = hosts + ',' + n['hostname']

hosts = hosts.lstrip(',')

adm = Admin(u, p, host=hosts)

adm.bucket_create('test-bucket',
                  bucket_type='couchbase',
                  ram_quota=100)

print(cluster)