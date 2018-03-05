

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


curl --head -X GET http://couchbase-tpr-dev-1751775996.us-west-2.elb.amazonaws.com










