#!/usr/bin/env python

# install the SDK first.
# https://developer.couchbase.com/documentation/server/current/sdk/python/start-using-sdk.html
# This will create a test bucket.

#!/usr/bin/env python
from couchbase.cluster import Cluster
from couchbase.cluster import PasswordAuthenticator
from couchbase.n1ql import N1QLQuery

cluster = Cluster('couchbase://cb31-tpr-dev-cb.ubathsu2.eu-west-1.dev')
authenticator = PasswordAuthenticator('Administrator', 'hUqcbUmoLfZKHnzS')
cluster.authenticate(authenticator)
cb = cluster.open_bucket('test')
print(cb)

c = cb.counter('counter_id', delta=20, initial=100).value
print c

key = 'u::' + str(c)
print key

cb.upsert(key, {'name': 'Arthur', 'email': 'kingarthur@couchbase.com', 'interests': ['Holy Grail', 'African Swallows']})
cb.get(key).value

q = N1QLQuery('select * from test use keys "%s"' %  key)

for row in cb.n1ql_query(q):
    print row

# need to use sudo python <script>.py