
# attach volumes
aws ec2 attach-volume --volume-id vol-031693de5e4bde481 --instance-id i-07f999c8983995df6 --device /dev/sdf

# List all unmounted devices in EC2 Ubuntu.
lsblk  --noheadings --raw | awk '{print substr($0,0,4)}' | uniq -c | grep 1 | awk '{print "/dev/"$2}'

# Pragramatically mount block device at EC2 startup.
#!/bin/sh
set -x
P=`lsblk  --noheadings --raw | awk '{print substr($0,0,4)}' | uniq -c | grep 1 | awk '{print "/dev/"$2}'`
sudo mkfs -t ext4 $P
sudo mkdir /data
sudo mount $P /data
