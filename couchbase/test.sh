#!/bin/bash

tot_mem=$(free | grep Mem: | awk '{print $2}')

factor=.6

echo "tot_mem: $tot_mem"

per_node_quota=$(($tot_mem * 60 / 100))

per_node_quota_mb=$(($per_node_quota/1000))


echo $per_node_quota


        if region == 'us-east-1':
            s3_conn.create_bucket(
                Bucket=bucket,
            )
        else:
            s3_conn.create_bucket(
                Bucket=bucket,
                CreateBucketConfiguration={'LocationConstraint': region},
            )