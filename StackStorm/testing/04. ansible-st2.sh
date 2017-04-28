## Date: 3/10/2017

git clone https://github.com/Susanthab/my_projects.git

# below is to run in st2-ansible-vagrant env:
sudo mv my_projects/ansible-mongo-replset/ /etc/ansible/playbooks/

## Install latest ansible pack in st2
st2 run packs.install packs=ansible

# Execute anible playbook from st2
st2 run ansible.playbook playbook=/etc/ansible/playbooks/mongodb-replset.yml INVENTORY=/etc/ansible/playbooks/inventory/hosts.aws REMOTE_USER=ubuntu

st2 run ansible.playbook playbook=/etc/ansible/playbooks/mongodb-replset.yml --user ubuntu

st2 run ansible.playbook playbook=/etc/ansible/playbooks/mongodb-replset.yml private_key='/home/stanley/.ssh/stanley_rsa'

st2 run ansible.command INVENTORY='/etc/ansible/playbooks/inventory/hosts.aws' module_name=ping

st2 run ansible.command  hosts=primary module_name=ping --user ubuntu

# Worked
ansible -m ping primary

# Worked
st2 run core.remote hosts=10.199.248.5 username=ubuntu -- ls -l

# Worked
st2 run core.remote hosts=10.199.248.5 cmd=whoami username=ubuntu
st2 run core.remote hosts=10.199.248.5,10.199.253.154,10.199.244.252 cmd=whoami username=ubuntu
st2 run ansible.command connection=local inventory_file='10.199.248.5,' hosts=all module_name=ping
st2 run ansible.command hosts=all module_name=ping private_key='/home/stanley/.ssh/stanley_rsa'

# Failed
st2 run core.remote hosts=all cmd=whoami username=ubuntu
st2 run ansible.command hosts=10.199.248.5 module_name=ping user=ubuntu
st2 run ansible.command hosts=10.199.248.5 module_name=ping user=stanley

st2 run ansible.playbook connection=local inventory_file='10.199.253.154,' hosts=all playbook=/etc/ansible/playbooks/mongodb-replset.yml

st2 run ansible.playbook playbook=~/my_projects/ansible-mongo-replset/mongodb-replset.yml inventory_file=~/my_projects/ansible-mongo-replset/inventory/hosts.aws

st2 run ansible.playbook cwd=~/my_projects/ansible-mongo-replset/ playbook=mongodb-replset.yml inventory_file=inventory/hosts.aws user=ubuntu


# If the authentication token expired. 
export ST2_AUTH_TOKEN=`st2 auth -t -p Ch@ngeMe st2admin`

# st2 - ansible - vagrant env:
# https://github.com/StackStorm/st2-ansible-vagrant
# Note: This env did not work for me. It crashes frequently.
sudo vi /etc/ansible/hosts
st2 run ansible.playbook playbook=/etc/ansible/playbooks/ansible-mongo-replset/mongodb-replset.yml 

# st2 vagrant box with ansible pack installed. 
# worked after doing the steps mentioned under Configure SSH in below line:
# https://docs.stackstorm.com/install/config/config.html#config-configure-ssh

sudo ssh -i /home/stanley/.ssh/stanley_rsa stanley@10.199.248.5


## Create user stanley in remote hosts
## https://docs.stackstorm.com/install/config/config.html#config-configure-ssh
sudo -i
useradd stanley
mkdir -p /home/stanley/.ssh
chmod 0700 /home/stanley/.ssh

# copy stanley public key to remote hosts. 
/home/stanley/.ssh/stanley_rsa.pub

cat /home/stanley/.ssh/stanley_rsa.pub >> /home/stanley/.ssh/authorized_keys
chmod 0600 /home/stanley/.ssh/authorized_keys
chown -R stanley:stanley /home/stanley
echo "stanley    ALL=(ALL)       NOPASSWD: SETENV: ALL" >> /etc/sudoers.d/st2

# to run ansinle playbook via st2. 
st2 run ansible.playbook playbook=/etc/ansible/playbooks/mongodb-replset.yml private_key='/home/stanley/.ssh/stanley_rsa'

st2 run ansible.command hosts=all module_name=ping private_key='/home/stanley/.ssh/stanley_rsa'

st2 run ansible.command hosts=10.199.253.84 module_name=ping private_key='/home/stanley/.ssh/stanley_rsa'



#--==============================
#/etc/ansible/ansible.cfg 
; http://docs.ansible.com/intro_configuration.html

[defaults]
remote_user = stanley
host_key_checking = True
; Global roles path to search for additional Ansible roles
roles_path = /etc/ansible/roles
sudo_flags=-H -S