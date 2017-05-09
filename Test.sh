

st2 run packs.install packs=ansible
st2 run ansible.command_local module_name=apt args='name=sshpass state=present'

ImageId: ami-47bc4c51
KeyName: susanthab
SecurityGroups: sg-06249479
InstanceType: t2.micro
LaunchConfigurationName: launch-config-mongo-2


#!/bin/bash
for i in `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name ASGName | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
do
aws ec2 describe-instances --instance-ids $i | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d"," -f1
done;


# Test st2/asnible mongo replicaset creation
inventory_file: /etc/ansible/mongo.inventory
Asg_name: test-mongo
playbook: /home/ubuntu/mongo2/mongodb_replicaset.yaml
LaunchConfigurationName: launch-config-mongo-2
AvailabilityZones: us-east-1a, us-east-1b, us-east-1c
Keyfile: /home/stanley/.ssh/stanley_rsa

#https://serverfault.com/questions/704806/how-to-get-autoscaling-group-instances-ip-adresses
#!/bin/bash
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
sudo chmod u+x ec2-metadata
EC2_AVAIL_ZONE=$(./ec2-metadata -z | grep -Po "(us|sa|eu|ap)-(north|south|central)?(east|west)?-[0-9]+")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
INSTANCE_ID=$(./ec2-metadata | grep instance-id | awk 'NR==1{print $2}')
AG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query AutoScalingInstances[].AutoScalingGroupName --output text)
for ID in $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
do
    if [ $ID != $INSTANCE_ID ]; then
      IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PublicIpAddress --output text)
      echo $IP
    fi
    # Do what you want with ${IP} here
done


# How to get AWS region whithin an EC2.
EC2_AVAIL_ZONE=$(./ec2-metadata -z | grep -Po "(us|sa|eu|ap)-(north|south|central)?(east|west)?-[0-9]+")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"


# Connect to MongoDB from shell
#!/bin/bash
PRIMARY=`/usr/bin/mongo 34.201.3.103:27017 --eval "printjson(rs.isMaster())" | grep "primary" | cut -d"\"" -f4`
echo "$PRIMARY"

# Below shell script can be used to connect to MongoDB primary from any node of the relica set.
#!/bin/bash
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
sudo chmod u+x ec2-metadata
EC2_AVAIL_ZONE=$(./ec2-metadata -z | grep -Po "(us|sa|eu|ap)-(north|south|central)?(east|west)?-[0-9]+")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
INSTANCE_ID=$(./ec2-metadata | grep instance-id | awk 'NR==1{print $2}')
NEW_NODE_IP=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query Reservations[].Instances[].PublicIpAddress --output text)
AG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query AutoScalingInstances[].AutoScalingGroupName --output text)
for ID in $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
do

    if [ $ID != $INSTANCE_ID ]; then
      IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PublicIpAddress --output text)
      PRIMARY=`/usr/bin/mongo ${IP}:27017 --eval "printjson(rs.isMaster())" | grep "primary" | cut -d"\"" -f4`

      # check if PRIMARY is node exists
      if [ -n "$PRIMARY" ]; then
        echo $PRIMARY
        R=`/usr/bin/mongo ${PRIMARY}/admin -u mongo_cl_admin -p 'pssw0rd' --eval "printjson(rs.add('${NEW_NODE_IP}:27017'))"`
      fi

      break

    fi
    # Do what you want with ${IP} here
done


# Use below script to initialize the replica set. 
#!/bin/bash
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
sudo chmod u+x ec2-metadata
EC2_AVAIL_ZONE=$(./ec2-metadata -z | grep -Po "(us|sa|eu|ap)-(north|south|central)?(east|west)?-[0-9]+")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
INSTANCE_ID=$(./ec2-metadata | grep instance-id | awk 'NR==1{print $2}')
NEW_NODE_IP=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query Reservations[].Instances[].PublicIpAddress --output text)
AG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids ${INSTANCE_ID} --region ${EC2_REGION} --query AutoScalingInstances[].AutoScalingGroupName --output text)
for ID in $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region ${EC2_REGION} --query AutoScalingGroups[].Instances[].InstanceId --output text);
do

   IP=$(aws ec2 describe-instances --instance-ids $ID --region ${EC2_REGION} --query Reservations[].Instances[].PublicIpAddress --output text)
   PRIMARY=`/usr/bin/mongo ${IP}:27017 --eval "printjson(rs.isMaster())" | grep "primary" | cut -d"\"" -f4`

   # check if PRIMARY is node exists
   if [ -n "$PRIMARY" ]; then
     echo "Primary exists do nothing and exit"
     break
   else
     # Initialize replica set
     R=`/usr/bin/mongo ${IP}/admin --eval "printjson(rs.initiate())"`
     echo $R
   fi

  
done