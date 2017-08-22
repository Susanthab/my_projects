#!/bin/sh

#=============================================================
#Author: Susantha B
#Date: 8/3/2-17
#Purpose: Install & configure Cassandra ring on AWS. 
#=============================================================

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

## ***************************************************************************************************
get_seed_and_nonseed_asgname () {
    asg_name_nosuffix=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query 'AutoScalingGroups[].Tags[?Key==`asg_name`].{val:Value}' --output text | head -n1 | awk '{print $1;}');
    seed_asg="$asg_name_nosuffix-seed"
    nonseed_asg="$asg_name_nosuffix-nonseed"
    echo "Seed asg name: $seed_asg"
    echo "Non-seed asg name: $nonseed_asg"
}
## ***************************************************************************************************

## ***************************************************************************************************
get_seed_nonseed_instances () {
    seed_instances=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${seed_asg} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
    nonseed_instances=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${nonseed_asg} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
}
## ***************************************************************************************************

## ***************************************************************************************************
# wait for ec2
wait_for_ec2 () {
    aws ec2 wait instance-running --region $EC2_REGION --instance-ids $seed_instances
}
## ***************************************************************************************************

## ***************************************************************************************************
# Check current node can ping itself before starting Cassandra.
wait_for_current_node_ping_itself () {
    while ! ping -c 1 -W 1 $CURRENT_NODE_IP; do
        echo "Waiting for $CURRENT_NODE_IP - network interface might be down..."
        sleep 1
    done
}
## ***************************************************************************************************

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
## ***************************************************************************************************

## ***************************************************************************************************
# update cassandra-env.sh
## ***************************************************************************************************

## ***************************************************************************************************
update_cassandra_env_config_file () {
    cassandra_env="/etc/cassandra/cassandra-env.sh"
    # Enable remote access and disable autherization. 
    SEARCH='# JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname=<public name>"'
    REPLACE='JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname='$CURRENT_NODE_IP'"'
    sed -i "s/$SEARCH/$REPLACE/g" $cassandra_env
}
## ***************************************************************************************************

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


## ***************************************************************************************************
# update Cassandra.yaml
## ***************************************************************************************************

update_cassandra_yaml_config_file () {
    # Cassandra.yaml file location should be as follows. 
    # DO NOT change this location anywhere in the workflow. 
    cassandra_yaml='/etc/cassandra/cassandra.yaml'

    #1. Change the cluster name. 
    echo ""
    echo "1. update Cluster name..."
    SEARCH="cluster_name: 'Test Cluster'"
    REPLACE="cluster_name: '$asg_name_nosuffix'"
    sed -i "s/$SEARCH/$REPLACE/g" $cassandra_yaml
    cat $cassandra_yaml | grep "cluster_name:"

    #2. Listen_address to private IP of the local host. 
    echo ""
    echo "2. update Listen_address..."
    SEARCH='listen_address: localhost'
    sed -i "s/$SEARCH/listen_address: $CURRENT_NODE_IP/g" $cassandra_yaml
    cat $cassandra_yaml | grep listen_address:

    #3. update seed list. 
    echo ""
    echo "3. update seed list..."
    for ID in $seed_instances
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

    #4. update rpc_address.
    echo ""
    echo "4. update rpc_address..."
    SEARCH='rpc_address: localhost'
    sed -i "s/$SEARCH/rpc_address: $CURRENT_NODE_IP/g" $cassandra_yaml
    cat $cassandra_yaml | grep -w rpc_address:

}

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
    echo "Stop and start cassandra..."
    service $service stop
    sleep 5s
    service $service start
    sleep 5s
}
## ***************************************************************************************************

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
        #start_cassandra
        stop_start_cassandra
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
        #start_cassandra
        stop_start_cassandra
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


## ***************************************************************************************************
current_date_time="`date +%Y%m%d%H%M%S`";
echo ""
echo $current_date_time;
echo ""
echo "01. get seed and non-seed autoscaling groups..."
echo "*****************************************************"
get_seed_and_nonseed_asgname
sleep 5s
echo ""
echo "02. get seed and non-seed instances..."
echo "*****************************************************"
get_seed_nonseed_instances
echo ""
echo "03. wait for EC2..."
echo "*****************************************************"
wait_for_ec2
echo ""
echo "04. wait for current node to ping itself..."
echo "*****************************************************"
wait_for_current_node_ping_itself
echo ""
echo "05. wait for ping to other nodes..."
echo "*****************************************************"
wait_for_network
echo ""
echo "06. update cassandra-env.sh file..."
echo "*****************************************************"
update_cassandra_env_config_file
echo ""
echo "07. update cassandra.yaml file..."
echo "*****************************************************"
update_cassandra_yaml_config_file
echo ""
echo "08. bootstrap seed nodes..."
echo "*****************************************************"
sleep 10s
bootstrap_cassandra_seeds
echo ""
echo "09. bootstrap non-seed nodes..."
echo "*****************************************************"
sleep 5s
if [ "$AG_NAME" == "$nonseed_asg" ]; then
  bootstrap_cassandra_nonseeds
fi
current_date_time="`date +%Y%m%d%H%M%S`";
echo ""
echo $current_date_time;
echo "************End of execution*************************"
## ***************************************************************************************************