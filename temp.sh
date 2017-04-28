#!/bin/sh
set -x
cd /root
git clone https://github.com/Susanthab/my_projects.git mongo
cd /root
pip install -q -r ./mongo/ansible-roles/requirements.txt
ansible-playbook -i "localhost," -c local /root/mongo/ansible-roles/test_install_mongo.yaml