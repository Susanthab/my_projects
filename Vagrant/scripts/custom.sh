#!/bin/bash

#echo "Lets install aws pack..."
#sudo st2 pack install aws

echo "Lets install awscli..."
sudo apt install awscli

echo "Lets install tree..."
sudo apt install tree

#echo "Lets install ansible pack..."
#sudo st2 pack install ansible

#echo "Lets install consul pack..."
#sudo st2 pack install consul

echo "Lets install boto3..."
sudo pip install boto3

echo "Install aws boto3 pack..."
sudo st2 pack install aws=boto3

#echo "Install cassandra pack..."
#t2 pack install cassandra

#echo "Install Travis CI..."
#sudo apt install ruby ruby-dev
#sudo gem install travis
