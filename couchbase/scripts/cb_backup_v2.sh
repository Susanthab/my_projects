#!/bin/bash

db_instance_name=cb01
cluster_ip=$(hostname -i)
backup_dir=/backup/couchbase_2
user=susanthab
password=twister75
s3_loc="bitesize-dev/eu-west-1/ubathsu2/backups/couchbase/cb-tpr-dev-cb01"

cbbackupmgr=/opt/couchbase/bin/cbbackupmgr
backupregex="[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}_[0-9]{2}_[0-9]{2}.[0-9]*Z"
timestamp="$(date -u +"%Y-%m-%d")"
threads=4
restorepoints=7

# Configure backup 
$cbbackupmgr config --archive $backup_dir  --repo $db_instance_name

# Make backup
$cbbackupmgr backup -a $backup_dir -r $db_instance_name \
 -c couchbase://$cluster_ip -u $user -p $password

# Get backup list
backuplist=$($cbbackupmgr list -a $backup_dir -r $db_instance_name | awk '{print $NF}' | grep -E ${backupregex})
lastbackup=$(echo "${backuplist}" | sed '$!d')
echo lastbackup : $lastbackup

# Compact backup
cmd="${cbbackupmgr} compact --archive ${backup_dir} --repo ${db_instance_name} --backup ${lastbackup}"
echo -e "Compacting the backup...\nCommand: ${cmd}"
$cmd

# Merging old backups
count=$(echo "${backuplist}" | wc -l)
echo Num of backups : $count

if [ "$count" -gt "$restorepoints" ]; then

  start=$(echo "${backuplist}" | sed -n 1p)
  end=$(echo "${backuplist}" | sed -n $((restorepoints))p)
  cmd="${cbbackupmgr} merge --archive ${backup_dir} --repo ${db_instance_name} --start ${start} --end ${end}"
  echo -e "Merging old backups...\nCommand: ${cmd}"
  $cmd

  # Compress file
  zip_file=$backup_dir/${db_instance_name}-"$(date -u +"%M-%S")".zip
  cmd="zip -rq -D $zip_file  $backup_dir/$db_instance_name"
  echo -e "Compressing backup using zip...\nCommand: ${cmd}"
  $cmd

  # s3 upload
  cmd="aws s3 cp --only-show-errors $zip_file  s3://${s3_loc}/${timestamp}/"
  echo -e "Uploading zip file to s3...\nCommand: ${cmd}"
  $cmd

  # Remove zip file
  cmd="rm -rf $zip_file"
  echo Removing zip file...\nCommand: ${cmd}
  $cmd

fi