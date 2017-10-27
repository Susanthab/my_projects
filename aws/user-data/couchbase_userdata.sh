#!/bin/bash

#=============================================================
#Author: Susantha B
#Date: 10/25/17
#Version: 1.0
#Purpose: Install & configure Couchbase cluster on AWS. 
#=============================================================

## ***************************************************************************************************
# install SSM agent
# ideally, this should install prior as custom data in AMI - future work. 
mkdir /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
dpkg -i amazon-ssm-agent.deb
echo "check to see whether SSM agent is running..."
status=$(service amazon-ssm-agent status | grep "running" | awk '{print$3}')
if [ "$status" == "(running)" ]; then
    echo "$service is running!!!"
else
    echo "Starting $service..."
    service amazon-ssm-agent start
fi
## ***************************************************************************************************

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

echo "Install pre-requisites..."
# NOTE: This has to be changed to a proper location. 
pip install -q -r ./couchbase/ansible-roles/requirements.txt
# upgrade awscli to get new features 
pip install awscli --upgrade

# Use below script is to get ASG meta data. 
echo "Get AWS metadata..."
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod u+x ec2-metadata
EC2_AVAIL_ZONE=$(./ec2-metadata -z | grep -Po "(us|sa|eu|ap)-(north|south|central)?(east|west)?-[0-9]+")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
INSTANCE_ID=$(./ec2-metadata | grep instance-id | awk 'NR==1{print $2}')
CURRENT_NODE_IP=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query Reservations[].Instances[].PrivateIpAddress --output text)
AG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query AutoScalingInstances[].AutoScalingGroupName --output text)

echo "Change the swappiness value to 0 and make it Permanent.."
echo 0 > /proc/sys/vm/swappiness
echo '' >> /etc/sysctl.conf 
echo '#Set swappiness to 0 to avoid swapping' >> /etc/sysctl.conf 
echo 'vm.swappiness = 0' >> /etc/sysctl.conf 

echo "Disable Transparent Huge Pages..."
echo never > /sys/kernel/mm/transparent_hugepage/enabled 
echo never > /sys/kernel/mm/transparent_hugepage/defrag 

echo "Install Couchbase..."
wget https://packages.couchbase.com/releases/4.6.3/couchbase-server-enterprise_4.6.3-ubuntu14.04_amd64.deb
dpkg -i couchbase-server-enterprise_4.6.3-ubuntu14.04_amd64.deb

# The Couchbase-server should start automatically, if not start.
# The function code should come here. 

CLUSTER_USER_NAME="admin"
CLUSTER_PASSWORD="12qwaszx@"

# Create data and index directories
## ***************************************************************************************************
create_paths () {
    DATA_PATH="/data/couchbase/data"
    INDEX_PATH="/data/couchbase/index"
    mkdir  $DATA_PATH -p
    mkdir  $INDEX_PATH -p
    chown couchbase:couchbase $DATA_PATH
    chown couchbase:couchbase $INDEX_PATH
}
## ***************************************************************************************************

## ***************************************************************************************************
get_tags () {
    SERVICE_TYPE=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query 'AutoScalingGroups[].Tags[?Key==`service_type`].{val:Value}' --output text | head -n1 | awk '{print $1;}');
    echo "Node service type: $SERVICE_TYPE"
    CLUSTER_NAME=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query 'AutoScalingGroups[].Tags[?Key==`cluster_name`].{val:Value}' --output text | head -n1 | awk '{print $1;}');
    echo "Cluster name: $CLUSTER_NAME"
}
## ***************************************************************************************************

## ***************************************************************************************************
node_init () {
    output=null
    output=$(/opt/couchbase/bin/couchbase-cli node-init -c $CURRENT_NODE_IP --node-init-data-path "$DATA_PATH" \
    --node-init-index-path "$INDEX_PATH" -u $CLUSTER_USER_NAME -p $CLUSTER_PASSWORD)
    echo "output: node-init: $output"
}
## ***************************************************************************************************

## ***************************************************************************************************
cluster_init () {
    # Need to find a method to protect this password. Future work. 
    echo "Server type of the node: $SERVICE_TYPE"
    if [ "$SERVICE_TYPE" == "ABC" ]
    then
        output=null
        output=$(/opt/couchbase/bin/couchbase-cli cluster-init -c $CURRENT_NODE_IP --cluster-username $CLUSTER_USER_NAME \
        --cluster-password $CLUSTER_PASSWORD --cluster-name $CLUSTER_NAME --services data,index,query \
        --cluster-ramsize 256 --cluster-index-ramsize 256)
        echo "output: cluster-init: $output"
    fi
}
## ***************************************************************************************************

## ************************** EXECUTION *************************************************************
echo "01. Create data and index paths..."
create_paths
echo ""
echo "02. Get tags..."
get_tags
echo ""
echo "03. Initializes the node, $CURRENT_NODE_IP"
node_init
echo ""
echo "04. Initializing the cluster..."
cluster_init
## ***********************END OF EXECUTION **********************************************************