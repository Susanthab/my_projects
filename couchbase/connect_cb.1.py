#!/usr/bin/env python

# install the SDK first.
# https://developer.couchbase.com/documentation/server/current/sdk/python/start-using-sdk.html
# This will create a test bucket.

#!/usr/bin/env python
from couchbase.cluster import Cluster
from couchbase.cluster import PasswordAuthenticator

cluster = Cluster('couchbase://couchbase2.ubathsu.us-west-2.dev')
authenticator = PasswordAuthenticator('Administrator', 'aa4d996ccac446b7bfbfee96')
cluster.authenticate(authenticator)
cb = cluster.open_bucket('test')
print(cb)
cb.upsert('u:king_arthur', {'name': 'Arthur', 'email': 'kingarthur@couchbase.com', 'interests': ['Holy Grail', 'African Swallows']})
cb.get('u:king_arthur').value