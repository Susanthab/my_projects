

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

sudo su -
docker exec -it stackstorm /bin/bash
cd /opt/stackstorm/packs/
git clone https://github.com/pearsontechnology/stackstorm-couchbase.git couchbase
cd couchbase
git checkout bite-2383
git pull origin bite-2383
st2 run packs.setup_virtualenv packs=couchbase
st2ctl reload --register-all


# specific branch
git clone -b bite-2342 https://github.com/pearsontechnology/stackstorm-couchbase.git couchbase

# install couchbase pack. 
st2 run packs.setup_virtualenv packs=couchbase

# reload st2 context.
st2ctl reload --register-all


curl --head -X GET http://test-couchb-1984504305.us-west-2.elb.amazonaws.com

curl --head X GET http://couchbase.couchb1.tpr-dev.ubathsu.us-west-2.dev

curl http://10.1.39.115/pools/nodes

curl -u administrator:6ea53ff70d14409ab05e2078 http://couchbase.couchb1.tpr-dev.ubathsu.us-west-2.dev/pools/default
curl -v -u Administrator:bb2f1a541861433288e70588 http://10.1.50.8:8091/pools/nodes
# Sensor troubleshooting.

/opt/stackstorm/st2/bin/st2sensorcontainer --config-file=/etc/st2/st2.conf --sensor-ref=kubernetes.watchCouchbase

st2 trigger-instance get 5aa6c1aee908f90038bab42f

/var/log/st2/st2sensorcontainer.log

st2 rule-enforcement list --rule=couchbase.couchbase

st2 trigger-instance list --trigger=couchbase.couchbase

st2 trigger-instance get 5aa7fee0e908f900380c7002

couchbase-tpr-dev-couchbtest-empty



--=====================================

st2 execution list --action couchbase.couchbase_workflow

st2 execution list --action couchbase.couchbase_workflow -n 500 --status running

st2 execution get <exec id>


# get instance info. 

aws ssm describe-instance-information --instance-information-filter-list key=InstanceIds,valueSet=i-029af1bef30ef7064


aws ssm send-command --document-name "couchbase-get-cluster-ip" \
--parameters "UserName=administrator,Password=7d2a49cf38674f15a21af1d8,IpAddress=10.1.54.8" \
--targets "Key=instanceids,Values=i-04864a4dcf1fd132e" --region us-west-2



/opt/couchbase/bin/couchbase-cli host-list --cluster 10.1.52.139:8091 -u Administrator -p 1a3a4c017c354217a63ce69f | grep -v 10.1.35.203 | head -n 1

couchbase-cli host-list -c 10.1.54.147:8091 --username Administrator \
 --password 0868ca5c76a04a30b67bf51c


couchbase-cli server-list -c 10.1.43.186:8091 --username Administrator \
 --password bb2f1a541861433288e70588

couchbase-cli server-info -c 10.1.55.202:8091 --username Administrator \
 --password 11f79bb2929c4a7ca96527e8

# This works everything configured correctly. 
curl --head -X GET http://couchbase.cbdns14.tpr-dev.susantha.us-west-2.susantha.us-west-2.dev

# This works too. 
curl -v -u Administrator:f90aacf347f24efe99ae1427 http://test-cb-netlb-1ab242626000eecd.elb.us-west-2.amazonaws.com/pools/nodes



3a397d7da69e4ae7a19d0a7a

systemctl status amazon-ssm-agent

systemctl restart amazon-ssm-agent

tail -20f /var/log/amazon/ssm/amazon-ssm-agent.log