

#! /bin/bash
#cloud-config
output: {all: '| tee -a /var/log/cloud-init-output.log'}
set -x
cd /root
git clone https://github.com/Susanthab/my_projects.git mongo
