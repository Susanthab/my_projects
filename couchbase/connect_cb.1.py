#!/usr/bin/env python

# install the SDK first.
# https://developer.couchbase.com/documentation/server/current/sdk/python/start-using-sdk.html
# This will create a test bucket.

from couchbase.cluster import Cluster
from couchbase.cluster import PasswordAuthenticator

cluster = Cluster('couchbase://couchbase2.ubathsu.us-west-2.dev')
authenticator = PasswordAuthenticator('Administrator', 'aa4d996ccac446b7bfbfee96')
cluster.authenticate(authenticator)
cb = cluster.open_bucket('beer-sample')
print(cb)