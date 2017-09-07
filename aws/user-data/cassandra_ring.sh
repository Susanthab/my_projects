#!/bin/sh

#=============================================================
#Author: Susantha B
#Date: 8/3/2-17
#Purpose: Install & configure Cassandra ring on AWS. 
#=============================================================

## ***************************************************************************************************
# install SSM agent
# ideally, this should install prior as custom data in AMI - future work. 
mkdir /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
dpkg -i amazon-ssm-agent.deb
echo "check to see whether SSM agent is running..."
status=$(systemctl status amazon-ssm-agent | grep "running" | awk '{print$3}')
if [ "$status" == "(running)" ]; then
    echo "$service is running!!!"
else
    echo "Starting $service..."
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
fi
## ***************************************************************************************************

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
# upgrade awscli to get new features 
pip install awscli --upgrade
ansible-playbook -i "localhost," -c local /root/cassandra/ansible-roles/roles/apache-cassandra-nibiru/test.yml

# Use below script is to get ASG meta data. 
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
set_file_path () {
    cassandra_yaml='/etc/cassandra/cassandra.yaml'
    cassandra_env_sh='/etc/cassandra/cassandra-env.sh'
}
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
        echo "Waiting network on $IP"
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
    # Enable remote access and disable autherization. 
    SEARCH='# JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname=<public name>"'
    REPLACE='JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname='$CURRENT_NODE_IP'"'
    sed -i "s/$SEARCH/$REPLACE/g" $cassandra_env_sh
}
## ***************************************************************************************************

## ***************************************************************************************************
# update Cassandra.yaml
## ***************************************************************************************************

update_cassandra_yaml_config_file () {
    # Cassandra.yaml file location should be as follows. 
    # DO NOT change this location anywhere in the workflow. 
    
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
        echo "Adding $IP to the seed list..."
        seed_list="$seed_list,$IP"
    done
    DQ='"'
    SEARCH='seeds: "127.0.0.1"'
    #REPLACE="seeds: $DQ${seed_list:1}$DQ"
    REPLACE="seeds: ${seed_list:1}"
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
force_stop_start_cassandra () {
    echo "Force stop and start cassandra..."
    service $service stop
    sleep 5s
    service $service start
    sleep 5s

    status=$(service $service status | grep "running" | awk '{print$3}')
    if [ "$status" == "(running)" ]; then
        echo "$service is now running!!!"
    fi   
}
## ***************************************************************************************************

## ***************************************************************************************************
stop_start_cassandra () {
    service=cassandra
    status=$(service $service status | grep "running" | awk '{print$3}')

    if [ "$status" == "(running)" ]
    then
        echo "$service is already running!!!"
    else
        echo "Stop and start cassandra..."
        service $service stop
        sleep 5s
        service $service start
        sleep 5s

        status=$(service $service status | grep "running" | awk '{print$3}')
        if [ "$status" == "(running)" ]; then
            echo "$service is now running!!!"
        fi
    fi
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
        stop_start_cassandra
    fi

    # check the status
    UN=$(get_node_status $arg1 $IP)
    echo "Current status of the node: $UN..."

    # check until node Up (U) and Normal (N).
    max_retries=12
    cnt=1
    while [ "$UN" != "UN" ]; do
        echo "The node probably still bootstrapping..."
        sleep 5s
        echo "Retry count: $cnt"
        UN=$(get_node_status $arg1 $IP)

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
    echo "Current status of the node: $UN..."

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
replace_dead_nonseed_node () {
    echo ""
    echo "Checking dead non-seed nodes (DN) on the ring..."
    for ID in $seed_instances
    do
        IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PrivateIpAddress --output text)
        dead_node_ip=$(nodetool -h $IP status | grep DN | head -n 1 | awk '{print$2;}')
        echo $dead_node_ip
        if [ ! -z "$dead_node_ip" ]; then
            echo "Dead node, $dead_node_ip found..."
            echo "update replace_address in cassandra-env.sh file..."
            str=JVM_OPTS='"$JVM_OPTS'" -Dcassandra.replace_address=$dead_node_ip"'"'
            sed -i "$ a $str" $cassandra_env_sh

            stop_start_cassandra

            echo "wait till the new node finish bootstraping..."
            echo "Current node is: $CURRENT_NODE_IP"
            UN=$(nodetool -h $IP status | grep $CURRENT_NODE_IP | awk '{print$1}')
            echo "Current status of the node is: $UN..."
            while [ "$UN" != "UN" ]
            do
                echo "The node probably still bootstrapping..."
                sleep 10s
                UN=$(nodetool -h $IP status | grep $CURRENT_NODE_IP | awk '{print$1}')
                echo "Current status of the node is: $UN..."
            done
            echo "The new node finished bootstraping..."

            echo "remove the replace_address from cassandra-env.sh file..."
            head -n -1 $cassandra_env_sh > temp.sh; mv temp.sh $cassandra_env_sh
            force_stop_start_cassandra
            break
        fi
    done
}
## ***************************************************************************************************

## ***************************************************************************************************
# This function will call from inside other functions.
function get_node_status()
{
   IP=$1
   UN=$(nodetool -h $IP status | grep UN | grep $IP | head -n1 | awk '{print$1;}')
   echo "$UN"
}
## ***************************************************************************************************

## ***************************************************************************************************
# check seed list in each seed node and update if it changed. 
check_seed_list_and_update_if_changed () {
cmd="cat $cassandra_yaml | grep seeds:"
SEARCH="- seeds:.*"
SQ="'"
DQ='"'

CUR_NODE_SEED_LIST=$(cat $cassandra_yaml | grep seeds:)
echo "Current node seed list: $CUR_NODE_SEED_LIST"

echo ""
echo "Start comparing seed node list in other nodes..."
for ID in $seed_instances
do
    if [ "$ID" != "$INSTANCE_ID" ]; then
        
        send_cmdid=$(aws ssm send-command --region $EC2_REGION --instance-ids $ID --document-name "AWS-RunShellScript" --comment "cat" --parameters "commands=$cmd" --query Command.CommandId --output text)

        sleep 10s

        OTHER_NODE_SEED_LIST=$(aws ssm get-command-invocation --region $EC2_REGION --command-id $send_cmdid --instance-id $ID --query StandardOutputContent --output text)
        echo $cmd_output

        if [ "$CUR_NODE_SEED_LIST" != "$OTHER_NODE_SEED_LIST" ]; then
             echo ""
             echo "Seed list needs to be updated on : $ID"
             echo "Updating seed list on: $ID"
             # trim the variable. 
             REPLACE=`echo $CUR_NODE_SEED_LIST`
             CMD=`echo ${DQ}sed -i $SQ s/$SEARCH/$REPLACE/g $SQ /etc/cassandra/cassandra.yaml${DQ}`
             send_cmdid=$(aws ssm send-command --region $EC2_REGION --instance-ids $ID --document-name "AWS-RunShellScript" --comment "update the seed list in Cassandra.yaml" --parameters "commands=$CMD")
             sleep 5s
             echo "Restart Cassandra on : $ID to take effect the new seed list..."
             send_cmdid=$(aws ssm send-command --region $EC2_REGION --instance-ids $ID --document-name "AWS-RunShellScript" --comment "restart cassandra" --parameters "commands=service cassandra restart")
             # Confirm whether all seed nodes are in UN status. 
        fi
    fi
done
}
## ***************************************************************************************************

## ***************************************************************************************************
current_date_time="`date +%Y%m%d%H%M%S`";
echo ""
echo "Start time: $current_date_time;"
echo ""
echo "00. setting file path..."
echo "*****************************************************"
set_file_path
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
if [ "$AG_NAME" == "$seed_asg" ]; then
    bootstrap_cassandra_seeds
fi
echo ""
echo "09. replace dead non-seed nodes and bootstrap non-seed nodes..."
echo "*****************************************************"
sleep 5s
if [ "$AG_NAME" == "$nonseed_asg" ]; then
  replace_dead_nonseed_node
  sleep 5s
  bootstrap_cassandra_nonseeds
fi

echo ""
echo "10. Check seed list and update if necessary..."
echo "*****************************************************"
sleep 10s
if [ "$AG_NAME" == "$seed_asg" ]; then
    check_seed_list_and_update_if_changed
fi

current_date_time="`date +%Y%m%d%H%M%S`";
echo ""
echo "End time: $current_date_time;"
echo "************End of execution*************************"
## ***************************************************************************************************