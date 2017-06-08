#!/usr/bin/python
import boto3

ec2 = boto3.resource('ec2', region_name='us-east-1')

my_images = list(ec2.images.filter(Filters=[{'Name':'name', 'Values':['*ubuntu-precise-12.04-amd64-server*']}, {'Name':'virtualization-type','Values':['hvm']}, {'Name':'creation-date','Values':['2015*']}]).all())

print(my_images)