

# vagrant env
ansible-playbook -i inventory/hosts.vagrant mongodb-replset.yml

# aws
ansible-playbook -i inventory/hosts.aws mongodb-replset.yml -u ubuntu

