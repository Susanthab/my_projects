vagrant init bento/ubuntu-16.04; vagrant up --provider virtualbox
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

apt-get install python-pip
pip -V
pip install --upgrade pip

#Install docker-compose
pip install docker-compose
apt-get upgrade docker



# Create below file with AWS credentials.
vi conf/aws.env



# Prepare Docker environment
# Docker-compose environment that Dinesh created. 
# ssh -i /home/ubuntu/aws-key/bitesize.pem ubuntu@34.211.212.215
export TRAVIS_BUILD_NUMBER=1009
cd stackstorm-nibiru/
git branch
git checkout <branch-name>
./data/compose.sh

# Log into the container
docker-compose exec stackstorm /bin/bash
apt-get install vim
cd /opt/nibiru/
st2 pack install file:///$PWD

# Populate pre-requiste data to Consul. 
st2 run nibiru.populate_consul name="nib1009"
st2 run nibiru.create_customer_vpc consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1009/"

st2 run nibiru.delete_customer_vpc consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1009/state/vpc/"

st2 run nibiru.get_consul_json consul_endpoint=infrastructure/

st2 run nibiru.get_consul_json consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1009/state/vpc/database"

st2 execution get -dj 5952d9ad95a17a008c735782

st2 run nibiru.get_consul_json consul_endpoint=infrastructure/aws/us-west-1/vpc/nib1009/state/vpc/ -dj
st2 run nibiru.get_consul_json consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1009/state/vpc/"

# Delete a key in Consul. 
st2 run consul.delete key="infrastructure/aws/us-west-1/vpc/nib1009/state/vpc/state/vpc/database/mongo/autoscaling/launch_config"

# Create a test action in st2
st2 action create -y actions/test_action.yaml

# Execute test action. 
st2 run nibiru.test_action consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1009/state/vpc/"

# copy modified files to the st2 container
cp actions/test_action.yaml /opt/stackstorm/packs/nibiru/actions/
cp actions/workflows/test_action.yaml /opt/stackstorm/packs/nibiru/actions/workflows/
st2ctl reload --register-all

# copy action files to st2 container. 
cp actions/create_mongo_asg.yaml /opt/stackstorm/packs/nibiru/actions/
cp actions/workflows/create_mongo_asg.yaml /opt/stackstorm/packs/nibiru/actions/workflows/
st2ctl reload --register-all

