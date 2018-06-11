#!/bin/bash
exec > "/var/log/configure_cb_cluster.log" 2>&1

#=============================================================
#Author: Susantha B
#Date: 10/31/17
#Last updated: 5/26/2018
#Version: 1.0
#Purpose: Install & configure Couchbase cluster on AWS with 
#         multi-dimential scaling. 
#=============================================================


#For debugging...
echo "Current user and path"
whoami
pwd

export FULL_BACKUP_DATE="null"
echo 'export FULL_BACKUP_DATE="null"' >> ~/.bash_profile
echo "PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/couchbase/bin" >> ~/.bash_profile
source ~/.bash_profile

# node services for standard cluster.
std_services="data,index,query,fts"

calc_memory () {
    tot_mem=$(free | grep Mem: | awk '{print $2}')
    tot_mem_mb=`echo "$tot_mem/1000" | bc`
    printf "INFO: RAM Available (KB) - $tot_mem_mb\n"

    per_node_quota=`echo "$tot_mem*0.75" | bc`
    per_node_quota_mb=`echo "$per_node_quota/1000" | bc`
    printf "INFO: Memory allocated to Couchbase (MB) - $per_node_quota_mb\n"

    data_ram_quota=`echo "$per_node_quota_mb*0.75" | bc`
    data_ram_quota_int=`echo $data_ram_quota | awk '{print int($1+0.5)}'`
    printf "INFO: Data RAM Quota (MB) - $data_ram_quota_int\n"

    index_ram_quota=`echo $per_node_quota_mb*0.15 | bc`
    index_ram_quota_int=`echo $index_ram_quota | awk '{print int($1+0.5)}'`
    printf "INFO: Index RAM Quota (MB) - $index_ram_quota_int\n"

    # in MB.
    if [ $data_ram_quota_int -lt 256 ]; then
       cluster_ramsize=256
    else
       cluster_ramsize=$data_ram_quota_int
    fi
    echo "Cluster RAM size: $cluster_ramsize"

    # in MB.
    if [ $index_ram_quota_int -lt 256 ]; then
       cluster_index_ramsize=256
    else
       cluster_index_ramsize=$index_ram_quota_int
    fi
    echo "Cluster Index RAM size: $cluster_index_ramsize"
}
calc_memory

## ***************************************************************************************************
echo ""
echo "INFO: check to see whether SSM agent is running..."
echo "**************************************************"
status=$(systemctl status  amazon-ssm-agent.service | grep running | head -1 | awk '{print$3}')
echo "Status: $status"
if [ "$status" == "(running)" ]; then
    echo "$service is running!!!"
else
    echo "Starting $service..."
    systemctl start  amazon-ssm-agent.service
fi
## ***************************************************************************************************

# Use below script is to get ASG meta data. 
echo "INFO: Get AWS metadata..."

EC2_AVAIL_ZONE=us-west-2b
EC2_REGION=us-west-2
INSTANCE_ID=i-01ea9a5edec0c4187
CURRENT_NODE_IP=10.1.43.195    

AG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query AutoScalingInstances[].AutoScalingGroupName --output text)

printf "EC2_AVAIL_ZONE: $EC2_AVAIL_ZONE\n"
printf "EC2_REGION: $EC2_REGION\n"
printf "INSTANCE_ID: $INSTANCE_ID\n"
printf "CURRENT_NODE_IP: $CURRENT_NODE_IP\n"
printf "AG_NAME: $AG_NAME\n"

DATA_PATH=/data/couchbase/data
INDEX_PATH=/data/couchbase/index
CLUSTER_USER_NAME=Administrator
CLUSTER_PASSWORD=b78e9251fd7f4ffaa89822de

## ***************************************************************************************************
get_tags_and_instances () {
    CLUSTER_TYPE=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} \
        --region ${EC2_REGION} --query 'AutoScalingGroups[].Tags[?Key==`cluster_type`].{val:Value}' --output text | head -n1 | awk '{print $1;}');
    echo "INFO: Cluster type: $CLUSTER_TYPE"
    SERVICE_OFFERING=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} \
        --region ${EC2_REGION} --query 'AutoScalingGroups[].Tags[?Key==`service_offering`].{val:Value}' --output text | head -n1 | awk '{print $1;}');
    echo "INFO: Node service offering: $SERVICE_OFFERING"
    CLUSTER_NAME=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} \
        --region ${EC2_REGION} --query 'AutoScalingGroups[].Tags[?Key==`cluster_name`].{val:Value}' --output text | head -n1 | awk '{print $1;}');
    echo "INFO: Cluster name: $CLUSTER_NAME"

    t_environment=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} \
            --region ${EC2_REGION} --query 'AutoScalingGroups[].Tags[?Key==`t_environment`].{val:Value}' --output text | head -n1 | awk '{print $1;}');
    echo "INFO: t_environment: $t_environment"

    t_role=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} \
            --region ${EC2_REGION} --query 'AutoScalingGroups[].Tags[?Key==`t_role`].{val:Value}' --output text | head -n1 | awk '{print $1;}');
    echo "INFO: t_role: $t_role"

    DB_system=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} \
            --region ${EC2_REGION} --query 'AutoScalingGroups[].Tags[?Key==`DB_system`].{val:Value}' --output text | head -n1 | awk '{print $1;}');
    echo "INFO: DB_system: $DB_system"

    Deployment_name=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} \
            --region ${EC2_REGION} --query 'AutoScalingGroups[].Tags[?Key==`Deployment_name`].{val:Value}' --output text | head -n1 | awk '{print $1;}');
    echo "INFO: Deployment_name: $Deployment_name"

    if [ "$CLUSTER_TYPE" == "standard" ]; then
        ALL_ASG_INST=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} \
        --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
    fi    

    if [ "$CLUSTER_TYPE" == "multidimentional" ]; then

        ASG_DATA_NAME="couchbase-asg-data-$CLUSTER_NAME"
        ASG_DATA_INST=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${ASG_DATA_NAME} \
        --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
        echo "INFO: Data service instances of the cluster: $ASG_DATA_INST"

        ASG_INDEX_NAME="couchbase-asg-index-$CLUSTER_NAME"
        ASG_INDEX_INST=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${ASG_INDEX_NAME} \
        --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
        echo "INFO: Index service instances of the cluster: $ASG_INDEX_INST"

        ASG_QUERY_NAME="couchbase-asg-query-$CLUSTER_NAME"
        ASG_QUERY_INST=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${ASG_QUERY_NAME} \
        --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
        echo "INFO: Query service instances of the cluster: $ASG_QUERY_INST"

        echo "INFO: Concatenate all the instances of the auto-scaling groups into one."
        ALL_ASG_INST="$ASG_DATA_INST $ASG_INDEX_INST $ASG_QUERY_INST"
    fi
    
    echo "INFO: All the instances of the cluster: $ALL_ASG_INST"  
}
## ***************************************************************************************************

## ***************************************************************************************************
# wait for ec2
wait_for_ec2 () {
    aws ec2 wait instance-running --region $EC2_REGION --instance-ids $ALL_ASG_INST
}
## ***************************************************************************************************

## ***************************************************************************************************
node_init () {
    # localhost
    output=null
    output=$(couchbase-cli node-init -c $CURRENT_NODE_IP --node-init-data-path "$DATA_PATH" \
    --node-init-index-path "$INDEX_PATH" -u $CLUSTER_USER_NAME -p $CLUSTER_PASSWORD)
    echo "OUTPUT: node-init: $output"
}
## ***************************************************************************************************

## ***************************************************************************************************
cluster_init () {
    # This should occur only for one node of the cluster and that node should be a data node. 
    
    ip=$(get_node_ip $arg1 $id)       
    
    echo "INFO: Designated primary server ip: $PRIMARY_SERVER_IP"  
    if [ "$ip" == "$CURRENT_NODE_IP" -a "$SERVICE_OFFERING" == "data" -o "$CLUSTER_TYPE" == "standard" ]; then

        if [ "$SERVICE_OFFERING" == "data" ]; then
            output=$(couchbase-cli cluster-init -c $CURRENT_NODE_IP --cluster-username $CLUSTER_USER_NAME \
                    --cluster-password $CLUSTER_PASSWORD --cluster-name $CLUSTER_NAME --services data \
                    --cluster-ramsize $cluster_ramsize )
            echo "OUTPUT: cluster-init: $output"
            # Ideally the cluster name should be set with cluster-init method. However due to some reason it seems not working. 
            #So setting cluster name in a different way.
        fi

        if [ "$CLUSTER_TYPE" == "standard" ]; then
            output=$(couchbase-cli cluster-init -c $CURRENT_NODE_IP --cluster-username $CLUSTER_USER_NAME \
                    --cluster-password $CLUSTER_PASSWORD --cluster-name $CLUSTER_NAME --services $std_services \
                    --cluster-ramsize $cluster_ramsize --cluster-index-ramsize $cluster_index_ramsize)
            echo "OUTPUT: cluster-init: $output"
        fi

        output=$(couchbase-cli setting-cluster -c $CURRENT_NODE_IP -u $CLUSTER_USER_NAME -p $CLUSTER_PASSWORD \
                --cluster-name $CLUSTER_NAME)
        echo "OUTPUT: setting-cluster (cluster name): $output"

        # Move node to a proper group. 
        # Create a group and then move the node because rename group did not work. 
        #group_name=`echo "rack-"${EC2_AVAIL_ZONE:(-2)}`
        group_name=$EC2_AVAIL_ZONE
        output=$(couchbase-cli group-manage -c $CURRENT_NODE_IP -u $CLUSTER_USER_NAME \
            -p $CLUSTER_PASSWORD --create --group-name $group_name)
        echo "OUTPUT: create-group: $output"
        output=$(couchbase-cli group-manage -c $CURRENT_NODE_IP -u $CLUSTER_USER_NAME \
            -p $CLUSTER_PASSWORD --move-servers $CURRENT_NODE_IP --from-group "Group 1" --to-group $group_name)
        echo "OUTPUT: move-group: $output"
    fi
}
## ***************************************************************************************************

## ***************************************************************************************************
# This function will call from inside other functions.
function get_node_ip ()
{
    id=$1
    ip=$(aws ec2 describe-instances --instance-ids $id --region ${EC2_REGION} --query \
        Reservations[].Instances[].PrivateIpAddress --output text)
    echo "$ip"
}
## ***************************************************************************************************

## ***************************************************************************************************
wait_for_couchbase () {
    
    for id in $ALL_ASG_INST
    do
        ip=$(get_node_ip $arg1 $id)
        server_status=$(couchbase-cli server-info -c $ip -u $CLUSTER_USER_NAME -p $CLUSTER_PASSWORD | \
            grep status | awk '{print $2}' | tr -d '",')
        while [ "$server_status" != "healthy" -a "$server_status" != "warmup" ]; do
            sleep 5
            server_status=$(couchbase-cli server-info -c $ip -u $CLUSTER_USER_NAME -p $CLUSTER_PASSWORD | \
                grep status | awk '{print $2}' | tr -d '",')
            echo "server status, $ip : $server_status"    
        done
        echo "INFO: Status of the server, $ip: $server_status"
    done
    
}
## ***************************************************************************************************

## ***************************************************************************************************
server_add () {

    echo "INFO: Service offering of the node: $SERVICE_OFFERING"
    #group_name=`echo "rack-"${EC2_AVAIL_ZONE:(-2)}`
    group_name=$EC2_AVAIL_ZONE
    output=$(couchbase-cli group-manage -c $PRIMARY_SERVER_IP -u $CLUSTER_USER_NAME \
                    -p $CLUSTER_PASSWORD --create --group-name $group_name)
    echo "OUTPUT: create-group: $output"

    if [ "$CURRENT_NODE_IP" != "$PRIMARY_SERVER_IP" -a "$SERVICE_OFFERING" == "data" ]; then
        output=$(couchbase-cli server-add --server-add=$CURRENT_NODE_IP --server-add-username=$CLUSTER_USER_NAME \
            --server-add-password=$CLUSTER_PASSWORD --group-name="$group_name" --services="data" \
            --cluster=$PRIMARY_SERVER_IP --user=$CLUSTER_USER_NAME --password=$CLUSTER_PASSWORD)
        echo "OUTPUT: server-add: $output"
    fi

    if [ "$SERVICE_OFFERING" == "index" ]; then
        output=$(couchbase-cli server-add --server-add=$CURRENT_NODE_IP --server-add-username=$CLUSTER_USER_NAME \
            --server-add-password=$CLUSTER_PASSWORD --group-name="$group_name" --services="index" \
            --cluster=$PRIMARY_SERVER_IP --user=$CLUSTER_USER_NAME --password=$CLUSTER_PASSWORD)
        echo "OUTPUT: server-add: $output"
    fi

    if [ "$SERVICE_OFFERING" == "query" ]; then
        output=$(couchbase-cli server-add --server-add=$CURRENT_NODE_IP --server-add-username=$CLUSTER_USER_NAME \
            --server-add-password=$CLUSTER_PASSWORD --group-name="$group_name" --services="query" \
            --cluster=$PRIMARY_SERVER_IP --user=$CLUSTER_USER_NAME --password=$CLUSTER_PASSWORD)
        echo "OUTPUT: server-add: $output"
    fi

    if [ "$CURRENT_NODE_IP" != "$PRIMARY_SERVER_IP" -a "$CLUSTER_TYPE" == "standard" ]; then
        output=$(couchbase-cli server-add --server-add=$CURRENT_NODE_IP --server-add-username=$CLUSTER_USER_NAME \
            --server-add-password=$CLUSTER_PASSWORD --group-name="$group_name" --services="$std_services" \
            --cluster=$PRIMARY_SERVER_IP --user=$CLUSTER_USER_NAME --password=$CLUSTER_PASSWORD)
        echo "OUTPUT: server-add: $output"   
    fi

    echo "INFO: Checking whether server is added to the cluster..."
    output=$(couchbase-cli host-list --cluster $PRIMARY_SERVER_IP -u $CLUSTER_USER_NAME -p $CLUSTER_PASSWORD | grep $CURRENT_NODE_IP)
    echo "OUTPUT: host-list: $output"
    while [ -z "$output" ]
    do
        sleep 5s
        server_add
        output=$(couchbase-cli host-list --cluster $PRIMARY_SERVER_IP -u $CLUSTER_USER_NAME -p $CLUSTER_PASSWORD | grep $CURRENT_NODE_IP)
    done

}
## ***************************************************************************************************

rebalance () {
    # wait for all the nodes of the Couchbase cluster. 
    wait_for_couchbase
    output=$(couchbase-cli rebalance -c  $PRIMARY_SERVER_IP -u $CLUSTER_USER_NAME -p $CLUSTER_PASSWORD)
    echo "OUTPUT: cluster rebalance: $output"
}

## ***************************************************************************************************
get_primary_server () {

    echo "INFO: Service type is: $CLUSTER_TYPE" 
    echo "INFO: Service offering of the node: $SERVICE_OFFERING"

    if [ "$CLUSTER_TYPE" == "multidimentional" ]; then
        ALL_INST=$ASG_DATA_INST
    fi

    if [ "$CLUSTER_TYPE" == "standard" ]; then
        ALL_INST=$ALL_ASG_INST
    fi

    for id in $ALL_INST
    do
        ip=$(get_node_ip $arg1 $id)
        output=$(couchbase-cli server-list -c $ip -u $CLUSTER_USER_NAME -p $CLUSTER_PASSWORD | \
             grep $ip | grep healthy | grep active)
        echo "OUTPUT: server-list: $ip - $output"
        echo ""

        if [ -n "$output" ]; then
          echo "INFO: Active server found in the cluster."
          PRIMARY_SERVER_IP=$ip
          echo "INFO: Primary server is-1: $PRIMARY_SERVER_IP"
          break
        fi

    done

    if [ -z "$output" ]; then
        id=`echo $ALL_INST | head -n1 | awk '{print $1;}'`
        PRIMARY_SERVER_IP=$(get_node_ip $arg1 $id)
        echo "INFO: Primary server is-2: $PRIMARY_SERVER_IP"
    fi
    
}
## ***************************************************************************************************

## ***************************************************************************************************
# This will handle one failed node only. 
find_unhealthy_nodes_and_remove () {

    dead_node=$(couchbase-cli server-list -c $PRIMARY_SERVER_IP -u $CLUSTER_USER_NAME -p $CLUSTER_PASSWORD | \
            grep unhealthy | grep active | awk '{print$2}' | head -1)    
    
    if [ -n "$dead_node" ]; then
        echo "INFO: Unhealthy node found: $dead_node"
        echo "INFO: Preparing to failover..."
        output=$(couchbase-cli failover -c $PRIMARY_SERVER_IP -u $CLUSTER_USER_NAME -p $CLUSTER_PASSWORD \
               --server-failover $dead_node --force)
        echo "OUTPUT: Server failover: $output"
        sleep 10s
    fi

}
## ***************************************************************************************************

## ************************** EXECUTION *************************************************************
echo ""
echo "----------------------"
echo "| STEP 01 - Get tags.|"
echo "----------------------"
    get_tags_and_instances
echo ""
echo "--------------------------------------------"
echo "| STEP 02 - Wait for all the EC2 instances.|"
echo "--------------------------------------------"
    wait_for_ec2
echo ""
echo "----------------------------------------"
echo "| STEP 03 - Wait for couchbase servers.|"
echo "----------------------------------------"
    wait_for_couchbase
echo ""
echo "----------------------------------------------------"
echo "| STEP 04 - Initializes the node, $CURRENT_NODE_IP |"
echo "----------------------------------------------------"
    node_init
echo ""
echo "---------------------------------------"
echo "| STEP 05 - Identify a primary server.|"
echo "---------------------------------------"
    get_primary_server
echo ""
echo "--------------------------------------"
echo "| STEP 06 - Initializing the cluster.|"
echo "--------------------------------------"
    cluster_init
    sleep 10s
echo ""
echo "------------------------"
echo "| STEP 07 - Add server.|"
echo "------------------------"
    server_add
    sleep 30s
echo ""
echo "------------------------------------"
echo "| STEP 08 - Remove unhealthy nodes.|"
echo "------------------------------------"
    find_unhealthy_nodes_and_remove
echo ""
echo "-----------------------"
echo "| STEP 09 - Rebalance.|"
echo "-----------------------"
    rebalance