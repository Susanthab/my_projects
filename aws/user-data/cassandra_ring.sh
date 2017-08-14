#!/bin/sh

#=============================================================
#Author: Susantha B
#Date: 8/3/2-17
#Purpose: Install & configure Cassandra ring on AWS. 
#=============================================================

set -x

echo "Pragramatically mount block device at EC2 startup..."
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html
# The following code is only to add one device. 
cp /etc/fstab /etc/fstab.orig
umd=`lsblk --noheadings --raw | grep -v "/" | grep -v "xvda\|sda1" | awk '{print "/dev/"$1}'`
mkfs -t xfs $umd
mkdir /data
mount $umd /data
UUID=`blkid | grep $umd | awk -F'UUID="' '{print $2}' | awk -F'"' '{print $1}'`
echo "UUID=$UUID       /data   XFS    defaults,nofail        0       2" >> /etc/fstab
mount -a

pip install -q -r ./cassandra/ansible-roles/requirements.txt
ansible-playbook -i "localhost," -c local /root/cassandra/ansible-roles/roles/apache-cassandra-nibiru/test.yml
#ansible-playbook -i "localhost," -c local test.yml

# Use below script is to ASG meta data. 
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod u+x ec2-metadata
EC2_AVAIL_ZONE=$(./ec2-metadata -z | grep -Po "(us|sa|eu|ap)-(north|south|central)?(east|west)?-[0-9]+")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
INSTANCE_ID=$(./ec2-metadata | grep instance-id | awk 'NR==1{print $2}')
CURRENT_NODE_IP=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query Reservations[].Instances[].PrivateIpAddress --output text)
AG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query AutoScalingInstances[].AutoScalingGroupName --output text)

## ***************************************************************************************************
# get some meta data
## ***************************************************************************************************

get_seed_and_nonseed_asgname () {
    Result=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query 'AutoScalingGroups[].Tags[?Key==`asg_name`].{val:Value}' --output text | head -n1 | awk '{print $1;}');
    seed_asg="$Result-seed"
    nonseed_asg="$Result-nonseed"
    echo "Seed asg name: $seed_asg"
    echo "Non-seed asg name: $nonseed_asg"
}
get_seed_and_nonseed_asgname

seed_instances=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${seed_asg} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
nonseed_instances=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${nonseed_asg} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);

## ***************************************************************************************************
# wait for ec2
wait_for_ec2 () {
    aws ec2 wait instance-running --region $EC2_REGION --instance-ids $seed_instances
}
## ***************************************************************************************************
wait_for_ec2

## ***************************************************************************************************
# Check current node can ping itself before starting Cassandra.
wait_current_node_ping_itself () {
    while ! ping -c 1 -W 1 $CURRENT_NODE_IP; do
        echo "Waiting for $CURRENT_NODE_IP - network interface might be down..."
        sleep 1
    done
}
## ***************************************************************************************************
wait_current_node_ping_itself

## ***************************************************************************************************
# wait for ping. 
wait_for_network () {
    for ID in $seed_instances
    do
        IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PrivateIpAddress --output text)
        echo $IP
        while ! ping -c 1 -W 1 $IP; do
            echo "Waiting for $IP - network interface might be down..."
            sleep 1
        done
    done
}
wait_for_network
## ***************************************************************************************************

## ***************************************************************************************************
# update Cassandra.yaml
## ***************************************************************************************************

## ***************************************************************************************************
# Enable remote access and disable autherization. 
SEARCH='# JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname=<public name>"'
REPLACE='JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname='$CURRENT_NODE_IP'"'
sed -i "s/$SEARCH/$REPLACE/g" /etc/cassandra/cassandra-env.sh
## ***************************************************************************************************

## ***************************************************************************************************
# update Cassandra.yaml
## ***************************************************************************************************

# Cassandra.yaml file location should be as follows. 
# DO NOT change this location anywhere in the workflow. 
cassandra_yaml='/etc/cassandra/cassandra.yaml'

## ***************************************************************************************************
update_listen_address () {
    #1. Listen_address to private IP of the local host. 
    SEARCH='listen_address: localhost'
    sed -i "s/$SEARCH/listen_address: $CURRENT_NODE_IP/g" $cassandra_yaml
    cat $cassandra_yaml | grep listen_address:
}
## ***************************************************************************************************
update_listen_address

## ***************************************************************************************************
update_seed_list_on_seedasg () {
    for ID in $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${seed_asg} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
    do
        IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PrivateIpAddress --output text)
        echo $IP
        seed_list="$seed_list,$IP"
    done
    DQ='"'
    SEARCH='seeds: "127.0.0.1"'
    REPLACE="seeds: $DQ${seed_list:1}$DQ"
    echo $SEARCH
    echo $REPLACE
    sed -i "s/$SEARCH/$REPLACE/g" $cassandra_yaml
    cat $cassandra_yaml | grep seeds:
}
## ***************************************************************************************************
update_seed_list_on_seedasg

## ***************************************************************************************************
update_rpc_address () {
   SEARCH='rpc_address: localhost'
   sed -i "s/$SEARCH/rpc_address: $CURRENT_NODE_IP/g" $cassandra_yaml
   cat $cassandra_yaml | grep -w rpc_address:
}
## ***************************************************************************************************
update_rpc_address

## ***************************************************************************************************
start_cassandra () {
service=cassandra

status=$(service $service status | grep "running" | awk '{print$3}')

if [ "$status" == "(running)" ]
then
  echo "$service is running!!!"
else
  echo "Starting $service..."
  service $service start
fi
}
## ***************************************************************************************************

## ***************************************************************************************************
stop_start_cassandra () {
service=cassandra

status=$(service $service status | grep "running" | awk '{print$3}')

if [ "$status" == "(running)" ]
then
  echo "$service is running!!!"
else
  echo "$service is not running..."
  echo "Stop and start cassandra..."
  service $service stop
  service $service start
fi
}
## ***************************************************************************************************

echo "Seed instances: $seed_instances"

## ***************************************************************************************************
bootstrap_cassandra_seeds () {
 echo ""
 echo "***************************"
 echo "bootstraping seed nodes..."
 echo "***************************"
 for ID in $seed_instances
 do
    IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PrivateIpAddress --output text)
    echo "Currently bootstraping node: $IP"
    if [  "$IP" == "$CURRENT_NODE_IP" ]; then
        echo "Start cassandra on Current node: $IP"
        start_cassandra
        sleep 10s
    fi

    # check the status
    UN=$(nodetool -h $IP status | grep UN | grep $IP | head -n1 | awk '{print$1;}')
    echo $UN

    # check until node Up (U) and Normal (N).
    max_retries=12
    cnt=1
    while [ "$UN" != "UN" ]; do
        echo "The node probably still bootstrapping..."
        sleep 5s
        echo "Retry count: $cnt"
        UN=$(nodetool -h $IP status | grep UN | grep $IP | head -n1 | awk '{print$1;}')

        if [ $cnt -eq 6 -a "$IP" == "$CURRENT_NODE_IP" ]; then
           echo "max retries reached halfway. Stop and start cassandra on $IP"
           stop_start_cassandra
           sleep 5s
        fi
        cnt=$((cnt + 1))
        
        if [ $cnt -eq $max_retries ]; then
          echo "Max retries reached. Something has gone wrong. Please investigate. Exiting..."
          break
        fi
    done

    if [ "$IP" == "$CURRENT_NODE_IP" ]; then
        break
    fi 

 done
}
## ***************************************************************************************************
bootstrap_cassandra_seeds

echo "Non seed nodes: $nonseed_instances"

## ***************************************************************************************************
bootstrap_cassandra_nonseeds () {
 echo ""
 echo "******************************"
 echo "bootstraping non-seed nodes..."
 echo "******************************"
 for ID in $nonseed_instances
 do
    IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PrivateIpAddress --output text)
    echo "Currently bootstraping node (non-seed): $IP"
    if [  "$IP" == "$CURRENT_NODE_IP" ]; then
        echo "Start cassandra on Current node: $IP"
        start_cassandra
        sleep 10s
    fi

    # check the status
    UN=$(nodetool -h $IP status | grep UN | grep $IP | head -n1 | awk '{print$1;}')
    echo $UN

    # check until node Up (U) and Normal (N).
    max_retries=12
    cnt=1
    while [ "$UN" != "UN" ]; do
        echo "The node probably still bootstrapping..."
        sleep 5s
        echo "Retry count: $cnt"
        UN=$(nodetool -h $IP status | grep UN | grep $IP | head -n1 | awk '{print$1;}')

        if [ $cnt -eq 6 -a "$IP" == "$CURRENT_NODE_IP" ]; then
           echo "max retries reached halfway. Stop and start cassandra on $IP"
           stop_start_cassandra
           sleep 5s
        fi
        cnt=$((cnt + 1))
        
        if [ $cnt -eq $max_retries ]; then
          echo "Max retries reached. Something has gone wrong. Please investigate. Exiting..."
          break
        fi
    done

    if [ "$IP" == "$CURRENT_NODE_IP" ]; then
        break
    fi 

 done
}
## ***************************************************************************************************
if [ "$AG_NAME" == "$nonseed_asg" ]; then
  bootstrap_cassandra_nonseeds
fi

