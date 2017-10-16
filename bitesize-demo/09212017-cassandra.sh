#Demo - date: 09-21-2017
# US: BITE-1582, BITE-1587, BITE-1588

#01. 7 nodes cassandra cluster is already created. (2 seeds and 5 non-seeds)

#02. keyspace and table is already created and populated with test data. 
#    select COUNT(*) from kp_realstate.realestate_data;
#    select * from kp_realstate.realestate_data limit 30;

#03. Add seed node to cassandra ring. (BITE-1582)
#    check the seed list on one node. 
cat /etc/cassandra/cassandra.yaml | grep seeds:  
#    st2-action: nibiru.add_nodes_to_cassandra_ring 
#    wait till the node joined to the cluster and rolling restart completes. 
#    check again the seed list on one node. 
cat /etc/cassandra/cassandra.yaml | grep seeds:  

#04. Replace a non-seed node. (BITE-1587)
#    From AWS console, select non-seed and terminate the node. 
#    watch the activities of spining-up the new node and how it joins to the cluster.
#    ssh to the new node and select the data. 
#    select * from kp_realstate.realestate_data limit 30;

#05. Remove a non-seed node. Essentially it is downsizing the cluster. (BITE-1588) 
#    check the cluster status : nodetool status
#    st2 action: nibiru.remove_node_from_cassandra_ring 
#    You have two options in this action. 
#    1. Remove (You just remove the node but the node stays acessible but out of the cluster.)
#    2. Terminate (You just terminate a node.)


