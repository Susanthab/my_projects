#!/bin/sh
#cloud-config

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
#ansible-playbook -i "localhost," -c local /root/cassandra/ansible-roles/install_cassandra.yaml
#ansible-playbook -i "localhost," -c local test.yml