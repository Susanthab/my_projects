#!/bin/bash

tot_mem=$(free | grep Mem: | awk '{print $2}')
tot_mem_mb=`echo "$tot_mem/1000" | bc`
printf "INFO: RAM Available (KB) - $tot_mem_mb\n"

per_node_quota=`echo "$tot_mem*0.80" | bc`
per_node_quota_mb=`echo "$per_node_quota/1000" | bc`
printf "INFO: Memory allocated to Couchbase (MB) - $per_node_quota_mb\n"

data_ram_quota=`echo $per_node_quota_mb*0.75 | bc`
printf "INFO: Data RAM Quota (MB) - $data_ram_quota\n"

index_ram_quota=`echo $per_node_quota_mb*0.15 | bc`
printf "INFO: Index RAM Quota (MB) - $index_ram_quota\n"
