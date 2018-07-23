
#/etc/yum.repos.d/couchbase.repo
[couchbase]
enabled = 1
name = Couchbase package repository
baseurl = http://packages.couchbase.com/rpm/7/x86_64
gpgcheck = 1
gpgkey = http://packages.couchbase.com/rpm/couchbase-rpm.key

yup check-update
yum install -y libcouchbase2-libevent libcouchbase-devel libcouchbase2-bin


# run pillowfight
cbc-pillowfight -U couchbase://test-lb-cb-1894371461.eu-west-1.elb.amazonaws.com/default \
--num-items=10000 --batch-size=20 --set-pct=50 --max-size=400 --num-cycles=1000 --timings

# This is working
cbc-pillowfight -u Administrator -P gzC#qRoBDCSYjy8XjwglBF0Q -U couchbase://10.1.35.173/pillow \
--num-items=100000 --batch-size=100 --set-pct=50 --max-size=400 --num-cycles=1000 --timings