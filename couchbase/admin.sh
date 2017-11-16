
# 11/9/2017

# use cbstats to see active and replica for a bucket.
# Bucket name and the server name is must.
# https://developer.couchbase.com/documentation/server/3.x/admin/CLI/cbstats-intro.html
cbstats 172.31.60.23:11210 all -b beer-sample | egrep -i "active_num|replica_num"

# num. of files for beer sample
ls -al /opt/couchbase/var/lib/couchbase/data/beer-sample | wc -l