

# install sub packs. 
# https://github.com/pearsontechnology/image-stackstorm/blob/master/packlist.json
st2 pack install git@github.com:AndyMoore/stackstorm-aws_autoscaling.git
st2 pack install git@github.com:AndyMoore/stackstorm-aws_ec2.git
st2 pack install git@github.com:AndyMoore/stackstorm-aws_iam.git

# How to access st2 web UI in bitesize. 
#https://stackstorm.<environment>.<region>.<domain>
#https://stackstorm.ubathsu.us-west-2.prsn-dev.io


# install vim.
apt-get install vim

git clone https://github.com/pearsontechnology/stackstorm-couchbase.git couchbase
# install couchbase pack. 
st2 run packs.setup_virtualenv packs=couchbase

# reload st2 context.
st2ctl reload --register-all


curl --head -X GET http://test-couchb-1984504305.us-west-2.elb.amazonaws.com

curl --head X GET http://internal-couchbase-tpr-dev-699245916.us-west-2.elb.amazonaws.com

curl http://10.1.50.8/pools/nodes

curl -u administrator:6ea53ff70d14409ab05e2078 http://10.1.50.8:8091/pools/default
curl -v -u Administrator:6ea53ff70d14409ab05e2078 http://10.1.50.8:8091/pools/nodes
# Sensor troubleshooting.

/opt/stackstorm/st2/bin/st2sensorcontainer --config-file=/etc/st2/st2.conf --sensor-ref=kubernetes.watchCouchbase

st2 trigger-instance get 5aa6c1aee908f90038bab42f

/var/log/st2/st2sensorcontainer.log

st2 rule-enforcement list --rule=couchbase.couchbase

st2 trigger-instance list --trigger=couchbase.couchbase

st2 trigger-instance get 5aa7fee0e908f900380c7002

couchbase-tpr-dev-couchbtest-empty

ps auxwww|grep -i couch