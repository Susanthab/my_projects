
## https://github.com/stackstorm/st2vagrant
# What I did to spin-up st2vagrant box. 

1. Change the Vagrant file to have a different name for the hostname(st2vagrant2)

2. Clear cache of the browser and log into web portal. (https://192.168.16.20)

3. Sometime you have to set the new auth token. 
    # If the authentication token expired. 
    export ST2_AUTH_TOKEN=`st2 auth -t -p Ch@ngeMe st2admin`

4. Install aws st2 pack.

st2 pack install aws

5. Configured below config files to include AWS keys. 

/opt/stackstorm/packs/aws/config.yaml
/etc/boto.cfg

Note: If you do not put the keys in boto.cfg, it continuosly gives "Unable to locate" credentials when running aws pack commands via st2.

6. Install awscli. [optional]

sudo apt install awscli

7. Configure awscli

aws configure

8. sudo apt install tree

9. install ansible pack for st2.

st2 pack install ansible

10. Create ansible.confg file. 

# /etc/ansible/ansible.cfg
# Paste the below contents. 

; http://docs.ansible.com/intro_configuration.html

[defaults]
remote_user = stanley
host_key_checking = True
; Global roles path to search for additional Ansible roles
roles_path = /etc/ansible/roles
sudo_flags=-H -S

11. Install consul st2 pack

st2 pack install consul

12. Create the consul.yaml file. 

/opt/stackstorm/configs/consul.yaml

# Refer the consul README.md for more details. 




--=======================================

# Register the action
st2 action create /opt/stackstorm/packs/mongo/actions/create_mongo_replset.meta.yaml
# Check it is available
st2 action list --pack=examples
# Run it
st2 run examples.echochain


#https://docs.stackstorm.com/reference/packs.html?highlight=hello_st2#creating-your-first-pack
##https://docs.stackstorm.com/start.html
# Copy examples to st2 content directory
sudo cp -r /usr/share/doc/st2/examples/ /opt/stackstorm/packs/
sudo cp -r /home/ubuntu/mongo/ /opt/stackstorm/packs/

# Run setup
st2 run packs.setup_virtualenv packs=nibiru

# Reload stackstorm context
st2ctl reload --register-all


# directory structure
root@st2vagrant2:/opt/stackstorm/packs/mongo# tree
.
├── actions
│   ├── create_asg_create_mongo_replset.yaml
            playbook: /etc/ansible/playbooks/mongo/mongodb-replset.yml
            private_key: /home/stanley/.ssh/stanley_rsa
            inventory_file: /etc/ansible/playbooks/mongo/inventory/hosts.aws
            asg_name: test-mongo-asg-1
│   ├── create_asg.yaml
│   ├── create_hostsfile.yaml
│   ├── create_mongo_replicaset.yaml
│   ├── scripts
│   │   ├── create_hostsfile.py
│   │   └── create_hostsfile.pyc
│   └── workflows
│       ├── create_asg_create_mongo_replset.yaml
│       ├── workflow1
│       │   └── create_asg.yaml
│       └── workflow2
│           └── create_mongo_replicaset.yaml
└── pack.yaml


# ssh to the node
sudo su
ssh -i /home/ubuntu/ec2-key-pair/susanthab.pem ubuntu@54.144.201.113


# Authenticate to mongodb
# On all nodes
> mongo
use admin
db.auth('mongo_admin','pssw0rd')
db.auth('mongo_cl_admin','pssw0rd')

# Insert Data On Primary
use HR
db.employee.insert({'name':'susantha bathige','address':'Colorado'})
db.employee.findOne()

# On Secondary
rs.slaveOk()
use HR
db.employee.findOne()

# Installing a pack using a git URL

## Method 1.
cd /opt/stackstorm/packs
git clone https://github.com/StackStorm-Exchange/stackstorm-cloudflare.git cloudflare
chown -R root:st2packs cloudflare
st2 run packs.setup_virtualenv packs=cloudflare
st2ctl reload

## Method 2.
st2 pack install https://github.com/xydinesh/stackstorm-boto3.git
st2 pack install https://github.com/pearsontechnology/stackstorm-nibiru.git