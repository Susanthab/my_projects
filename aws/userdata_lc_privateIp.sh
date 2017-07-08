#!/bin/sh
#cloud-config
output: {all: '| tee -a /var/log/cloud-init-output.log'}
set -x

# Random sleep between 1 - 10 sec. 
sleep $[ ( $RANDOM % 10 )  + 1 ]s

echo "Pragramatically mount block device at EC2 startup..."
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html
# The following code is only to add one device. 
cp /etc/fstab /etc/fstab.orig
umd=`lsblk --noheadings --raw | grep -v "/" | grep -v "xvda\|sda1" | awk '{print "/dev/"$1}'`
mkfs -t ext4 $umd
mkdir /data
mount $umd /data
UUID=`blkid | grep $umd | awk -F'UUID="' '{print $2}' | awk -F'"' '{print $1}'`
echo "UUID=$UUID       /data   ext4    defaults,nofail        0       2" >> /etc/fstab
mount -a

# Random sleep between 1 - 10 sec. 
sleep $[ ( $RANDOM % 10 )  + 1 ]s

pip install -q -r ./mongo/ansible-roles/requirements.txt
ansible-playbook -i "localhost," -c local /root/mongo/ansible-roles/test_install_mongo.yaml

# Random sleep between 1 - 10 sec. 
sleep $[ ( $RANDOM % 10 )  + 1 ]s

# Use below script is to initialize the replica set in ASG. 
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod u+x ec2-metadata
EC2_AVAIL_ZONE=$(./ec2-metadata -z | grep -Po "(us|sa|eu|ap)-(north|south|central)?(east|west)?-[0-9]+")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
INSTANCE_ID=$(./ec2-metadata | grep instance-id | awk 'NR==1{print $2}')
CURRENT_NODE_IP=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query Reservations[].Instances[].PrivateIpAddress --output text)
AG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query AutoScalingInstances[].AutoScalingGroupName --output text)
SECONDARY="false"

INSTANCE_0=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[0].InstanceId --output text);
IP_0=$(aws ec2 describe-instances --instance-ids $INSTANCE_0 --region ${EC2_REGION} --query Reservations[].Instances[].PrivateIpAddress --output text)

## ***********************************************************************************************************************************
## Block-1: To initialize the replica set. 
## Even this executes in multiple node in paralell, the block-1 execcutes only in 1 node due to the IF condition. (Assuming the result 
## returns by AWSCLI is ordered. 
if [ $CURRENT_NODE_IP = $IP_0 ]; then
   echo "Replica set can be initialized."
   echo $CURRENT_NODE_IP
   echo $IP_0
   cfg="{_id: 'rs0', members: [{_id: 0, host: '${CURRENT_NODE_IP}:27017'}]}"
   R=`/usr/bin/mongo ${CURRENT_NODE_IP}/admin --eval "printjson(rs.initiate($cfg))"`
   echo $R
fi
## End of Block-1
## ***********************************************************************************************************************************

## ***********************************************************************************************************************************
## Block-2: Get the IP of the Primary node. 
for ID in $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
do
   IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PrivateIpAddress --output text)
   P=`/usr/bin/mongo ${IP}:27017 --eval "printjson(rs.isMaster())" | grep "primary" | cut -d"\"" -f4`
   if [ -n $P ]; then
      echo "Primary node found, record the PRIMARY node IP"
      PRIMARY_IP=$IP
      PRIMARY_IP_NODE=$P
      echo $PRIMARY_IP_NODE
      echo $PRIMARY_IP
      break
   fi 
done
  # Check to see the Block-2 has found the Primary Node. 
  # By check the PRIMARY is unset or empty.
if [ -z $PRIMARY_IP_NODE ]; then
   echo "ERROR: Primary node could not be found. Something has gone wrong. Please debug the code."
fi
## End of Block-2
## ***********************************************************************************************************************************

## ***********************************************************************************************************************************
## Block-3: Add secondary nodes.
if [ -n $PRIMARY_IP ] && [ $CURRENT_NODE_IP != $PRIMARY_IP ]; then
  echo "Ready to add secondary nodes."
  R=`/usr/bin/mongo ${PRIMARY_IP_NODE}/admin --eval "printjson(rs.add('${CURRENT_NODE_IP}:27017'))"`
  echo $R
fi
## End of Block-3
## ***********************************************************************************************************************************