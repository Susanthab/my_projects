#!/bin/sh
set -x

SYSTEMUSER="stanley"
PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNy+pqZENzoWjZFoSb5ckc1ZaYPGLnBcoyFeUa1pSXFGT84/blA/gIDtKL73SWFjAn0ALE+Q+Z6xaxtXeAS6bRiPIzYYm+GC2Sez+KrmgklyV3oL3Tto9lZWF9hcnSajU/bpdQuWOMES/8ARZ+06g156lzg8Znq0OwTZHRsIQ/3FvC0GKAUa3/yxEnBXMfldtgZUxnHZqOWOFCjeEbKl9s7f8bukpGZdRAkWMbur5j9CHwInz/faxpwHLRTaC4MDr6bWvlV6jBYE6iKJVMZeSNsHCEPnYeXr0602ziBkzQvUaicHV+jBmnk503/ZhFyw/wLvWHx3wT8y9RmyOCB0qT root@st2vagrant2"

echo "########## Creating system user: ${SYSTEMUSER} ##########"
useradd ${SYSTEMUSER}
mkdir -p /home/${SYSTEMUSER}/.ssh
echo ${PUBKEY} > /home/${SYSTEMUSER}/.ssh/authorized_keys
chmod 0700 /home/${SYSTEMUSER}/.ssh
chmod 0600 /home/${SYSTEMUSER}/.ssh/authorized_keys
chown -R ${SYSTEMUSER}:${SYSTEMUSER} /home/${SYSTEMUSER}
if [ $(grep ${SYSTEMUSER} /etc/sudoers.d/* &> /dev/null; echo $?) = 0 ]
 then
   echo "${SYSTEMUSER}    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/st2
 fi

cd /root
git clone https://github.com/Susanthab/my_projects.git mongo
cd /root
pip install -q -r ./mongo/ansible-roles/requirements.txt
ansible-playbook -i "localhost," -c local /root/mongo/ansible-roles/test_install_mongo.yaml