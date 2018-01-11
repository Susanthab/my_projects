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

$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);



for ID in $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
do
   IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PrivateIpAddress --output text)
   echo $IP
   echo "Checking for the Primary node IP."
   P=`/usr/bin/mongo ${IP}:27017 --eval "printjson(rs.isMaster())" | grep "primary" | cut -d"\"" -f4`
   echo $P
   if [ -n "$P" ]; then
      echo "Primary node found, record the PRIMARY node IP"
      PRIMARY=${P}
      echo $PRIMARY
   fi

   IS_SECONDARY=`/usr/bin/mongo ${IP}:27017 --eval "printjson(db.isMaster().secondary)" | grep true`
   if [ "$IS_SECONDARY" = "true" ]; then
     SECONDARY="true"
   fi
done

# check if the PRIMARY node exists
if [ -n "$PRIMARY" ]; then
    echo "Primary node exists."
    echo "checking un-healthy nodes and remove it from the replica set."

    UH=`/usr/bin/mongo ${PRIMARY}/admin --eval "printjson(rs.status())" | grep --before-context=5 "not reachable/healthy" | grep "name" | cut -d"\"" -f4 | head -n 1`
    while [ -n "$UH" ]; do
        echo "Un-healthy node exists, removing the node."
        echo $UH
        R=`/usr/bin/mongo ${PRIMARY}/admin --eval "printjson(rs.remove('${UH}'))"`
        echo $R
        UH=`/usr/bin/mongo ${PRIMARY}/admin --eval "printjson(rs.status())" | grep --before-context=5 "not reachable/healthy" | grep "name" | cut -d"\"" -f4 | head -n 1`
    done

    echo "Join the new secondary to the existing replica set."
    R=`/usr/bin/mongo ${PRIMARY}/admin --eval "printjson(rs.add('${CURRENT_NODE_IP}:27017'))"`
    echo $R

elif [ "$SECONDARY" = "false" ]; then
    # Initialize replica set
    echo "No primary, initialize the replica set."
    cfg="{_id: 'rs0', members: [{_id: 0, host: '${CURRENT_NODE_IP}:27017'}]}"
    #R=`/usr/bin/mongo ${CURRENT_NODE_IP}/admin --eval "printjson(rs.initiate($cfg))"`
    echo $cfg
    echo $R
else
   echo "MongoDB Replica set has lost the Quorum. Please fix it manually."
fi