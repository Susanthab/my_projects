#!/bin/sh

#=============================================================
#Author: Susantha B
#Date: 10/25/17
#Version: 1.0
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