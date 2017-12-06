#!/bin/sh

#https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-14-04
#http://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot.html

apt-get update
apt-get -y install nfs-kernel-server
apt-get update
apt-get -y install nfs-common


filesystemdirectory1=couchbase-backup
instanceid=$(curl -s http”//169.254.169.254/latest/meta-data/instance-id)
availabilityzone=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
region=${availabilityzone:0:-1}

echo "Instance id: $instanceid"
echo "AZ: $availabilityzone"
echo "Region: $region"
filesystemid=$(aws efs describe-file-systems --region $region --output text --query 'FileSystems[?Name==`efs-couchbase-backup`].[FileSystemId]')

echo "EFS-filesystem id: $filesystemid"


mkdir -p /var/www/html/$filesystemdirectory1/
chown ec2-user:ec2-user /var/www/html/$filesystemdirectory1/

echo "$filesystemid.efs.$region.amazonaws.com:/ /var/www/html/$filesystemdirectory1 nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab

mount -a -t nfs4