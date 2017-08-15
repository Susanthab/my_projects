#!/bin/bash

echo "Lets install aws pack"
sudo st2 pack install aws

echo "Lets install awscli"
sudo apt install awscli

echo "Lets install tree"
sudo apt install tree

echo "Lets install ansible pack"
sudo st2 pack install ansible

echo "Lets install consul pack"
sudo st2 pack install consul

echo "Lets install boto3 pack that Dinesh W wrote"
st2 pack install https://github.com/xydinesh/stackstorm-boto3

echo "Lets install boto3"
sudo pip install boto3

echo "Install aws boto3 pack"
sudo st2 pack install aws=boto3