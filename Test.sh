

st2 run packs.install packs=ansible
st2 run ansible.command_local module_name=apt args='name=sshpass state=present'

ImageId: ami-47bc4c51
KeyName: susanthab
SecurityGroups: sg-06249479
InstanceType: t2.micro
LaunchConfigurationName: launch-config-mongo-2


#!/bin/bash
for i in `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name ASGName | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
do
aws ec2 describe-instances --instance-ids $i | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d"," -f1
done;


# Test st2/asnible mongo replicaset creation
inventory_file: /etc/ansible/mongo.inventory
Asg_name: test-mongo
playbook: /home/ubuntu/mongo2/mongodb_replicaset.yaml
LaunchConfigurationName: launch-config-mongo-2
AvailabilityZones: us-east-1a, us-east-1b, us-east-1c
Keyfile: /home/stanley/.ssh/stanley_rsa

#https://serverfault.com/questions/704806/how-to-get-autoscaling-group-instances-ip-adresses
#!/bin/bash
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
sudo chmod u+x ec2-metadata
EC2_AVAIL_ZONE=$(./ec2-metadata -z | grep -Po "(us|sa|eu|ap)-(north|south|central)?(east|west)?-[0-9]+")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
INSTANCE_ID=$(./ec2-metadata | grep instance-id | awk 'NR==1{print $2}')
AG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query AutoScalingInstances[].AutoScalingGroupName --output text)
for ID in $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
do
    if [ $ID != $INSTANCE_ID ]; then
      IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PublicIpAddress --output text)
      echo $IP
    fi
    # Do what you want with ${IP} here
done


# How to get AWS region whithin an EC2.
EC2_AVAIL_ZONE=$(./ec2-metadata -z | grep -Po "(us|sa|eu|ap)-(north|south|central)?(east|west)?-[0-9]+")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"


# Connect to MongoDB from shell
#!/bin/bash
PRIMARY=`/usr/bin/mongo 34.201.3.103:27017 --eval "printjson(rs.isMaster())" | grep "primary" | cut -d"\"" -f4`
echo "$PRIMARY"

# Below shell script can be used to connect to MongoDB primary from any node of the relica set.
#!/bin/bash
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
sudo chmod u+x ec2-metadata
EC2_AVAIL_ZONE=$(./ec2-metadata -z | grep -Po "(us|sa|eu|ap)-(north|south|central)?(east|west)?-[0-9]+")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
INSTANCE_ID=$(./ec2-metadata | grep instance-id | awk 'NR==1{print $2}')
NEW_NODE_IP=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query Reservations[].Instances[].PublicIpAddress --output text)
AG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query AutoScalingInstances[].AutoScalingGroupName --output text)
for ID in $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
do
    if [ $ID != $INSTANCE_ID ]; then
      IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PublicIpAddress --output text)
      PRIMARY=`/usr/bin/mongo ${IP}:27017 --eval "printjson(rs.isMaster())" | grep "primary" | cut -d"\"" -f4`
      # check if PRIMARY node exists
      if [ -n "$PRIMARY" ]; then
        echo $PRIMARY
        # Join the new secondary to the existing replica set. 
        R=`/usr/bin/mongo ${PRIMARY}/admin -u mongo_cl_admin -p 'pssw0rd' --eval "printjson(rs.add('${NEW_NODE_IP}:27017'))"`
      fi
      break
    fi
done


--====================

# check if the PRIMARY node exists
if [ -n "$PRIMARY" ]; then
    echo "Primary node exists."
    # Join the new secondary to the existing replica set. 
    R=`/usr/bin/mongo ${PRIMARY}/admin --eval "printjson(rs.add('${CURRENT_NODE_IP}:27017'))"`
else
    # Initialize replica set
    R=`/usr/bin/mongo ${CURRENT_NODE_IP}/admin --eval "printjson(rs.initiate())"`
    echo $R
fi

--======================

UH=`/usr/bin/mongo 107.21.185.128:27017/admin --eval "printjson(rs.status())" | grep --before-context=5 "not reachable/healthy" | grep "name" | cut -d"\"" -f4 | head -n 1`
while [ -n "$UH"]; do
   echo $UH
   R=`/usr/bin/mongo 54.175.234.108:27017/admin --eval "printjson(rs.remove('${UH}'))"`
   UH=`/usr/bin/mongo 54.175.234.108:27017/admin --eval "printjson(rs.status())" | grep --before-context=5 "not reachable/healthy" | grep "name" | cut -d"\"" -f4 | head -n 1`
done

UH=`/usr/bin/mongo 107.21.185.128:27017/admin --eval "printjson(rs.status())" | grep --before-context=5 "not reachable/healthy" | grep "name" | cut -d"\"" -f4`


tail -f /var/log/cloud-init-output.log

--==========
--Import mongo sample data

curl -O https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json

mongoimport --db mydb --collection restaurants --drop --file primer-dataset.json

--check data in mongodb
use mydb
show collections
db.restaurants.count()

--===== Quorum lost situation

st2 run boto3.action service='autoscaling' region='us-east-1' action_name='create_auto_scaling_group' params='{AutoScalingGroupName = 'test-mongo-1',LaunchConfigurationName = 'launch-config-mongo-1',MaxSize = 3,MinSize = 2,DesiredCapacity = 2'

--====================


cp actions/create_cassandra_ring.yaml /opt/stackstorm/packs/nibiru/actions/
cp actions/workflows/create_cassandra_ring.yaml /opt/stackstorm/packs/nibiru/actions/workflows/

st2ctl reload --register-all


st2 run nibiru.create_cassandra_ring \
LaunchConfigurationName="cass-lc-test" \
Asg_name="cass-asg-test" \
Environment="test" \
App_id=50 \
t_owner_individual="susantha.bathige@pearson.com" \
InstanceType="t2.micro" \
ImageId="ami-d7ecb7b7" \
KeyName="nibiru-demo" \
consul_endpoint="infrastructure/aws/us-west-1/vpc/nib1009/state/vpc/"




## ***************************************************************************************************
# check Ephemeral storage exists. 
# Assuming Ephemeral storage always comes as /mnt 
check_ephemeral_storage () {
    mnt=`df -h | grep /mnt | head -n 1 | awk '{print$6}'`

    if [ -n "$mnt"  ]; then
    echo "Ephemeral storage found."
    echo "Create directory for cassandra commit log."
    mkdir -p /mnt/cassandra/commit_log/
    fi
}
## ***************************************************************************************************


