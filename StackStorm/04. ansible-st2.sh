## Date: 3/10/2017

git clone https://github.com/Susanthab/my_projects.git

## Install latest ansible pack in st2
st2 run packs.install packs=ansible

# Execute anible playbook from st2
st2 run ansible.playbook playbook=/etc/ansible/playbooks/mongodb-replset.yml INVENTORY=/etc/ansible/playbooks/inventory/hosts.aws REMOTE_USER=ubuntu

st2 run ansible.playbook playbook=/etc/ansible/playbooks/mongodb-replset.yml --user ubuntu

st2 run ansible.playbook playbook=/etc/ansible/playbooks/mongodb-replset.yml 

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


# Failed
st2 run core.remote hosts=all cmd=whoami username=ubuntu
st2 run ansible.command hosts=10.199.248.5 module_name=ping user=ubuntu
st2 run ansible.command hosts=10.199.248.5 module_name=ping user=stanley

st2 run ansible.playbook connection=local inventory_file='10.199.253.154,' hosts=all playbook=/etc/ansible/playbooks/mongodb-replset.yml

st2 run ansible.playbook playbook=~/my_projects/ansible-mongo-replset/mongodb-replset.yml inventory_file=~/my_projects/ansible-mongo-replset/inventory/hosts.aws

st2 run ansible.playbook cwd=~/my_projects/ansible-mongo-replset/ playbook=mongodb-replset.yml inventory_file=inventory/hosts.aws user=ubuntu


# If the authentication token expired. 
export ST2_AUTH_TOKEN=`st2 auth -t -p Ch@ngeMe st2admin`


---
{
    "_embedded": {
        "instances": [
            {
                "_links": {
                    "asynchronous": {
                        "href": "https://nibiru-integration.prsn.us/api/async/instances/dev-use1b-pr-70-mongotesting-modb-0007"
                    },
                    "network": {
                        "href": "https://nibiru-integration.prsn.us/api/networks/aws-dev-us-east-1b-priv"
                    },
                    "owner": {
                        "href": "https://nibiru-integration.prsn.us/api/teams/70"
                    },
                    "self": {
                        "href": "https://nibiru-integration.prsn.us/api/instances/dev-use1b-pr-70-mongotesting-modb-0007"
                    }
                },
                "app_name": "mongotesting",
                "app_type": "modb",
                "aws": {
                    "ebs_options": {
                        "volume_type": "gp2"
                    },
                    "id": "i-078fd308485f888de",
                    "image_id": "ami-e906b882",
                    "region": "us-east-1",
                    "security_groups": [
                        "sg-be15dbd1"
                    ],
                    "size": "t2.medium",
                    "subnet": "subnet-acd28084",
                    "tags": {},
                    "volumes": [
                        {
                            "device": "/dev/sdf",
                            "id": "vol-0e3a880607cd01c41",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        },
                        {
                            "device": "/dev/sdg",
                            "id": "vol-018cd0ae461d8961d",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        },
                        {
                            "device": "/dev/sdh",
                            "id": "vol-0585406e274970a17",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        },
                        {
                            "device": "/dev/sdi",
                            "id": "vol-096e37c7421e1e8f7",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        }
                    ],
                    "zone": "us-east-1b"
                },
                "environment": "dev",
                "hostname": "dev-use1b-pr-70-mongotesting-modb-0007.prv-prsn.com",
                "id": "dev-use1b-pr-70-mongotesting-modb-0007",
                "ip": "10.199.248.5",
                "location": "use1b",
                "locked": false,
                "privacy": "priv",
                "puppet": {
                    "classes": {},
                    "environment": "v9",
                    "parameters": {}
                },
                "size": "medium",
                "state": "stopped",
                "storage_options": {
                    "size": 25
                },
                "storage_type": "remote",
                "tags": {
                    "by": "susa",
                    "nibiru_scheduler_enabled": "true",
                    "nibiru_scheduler_start_time": "14:00",
                    "nibiru_scheduler_stop_time": "01:00",
                    "purpose": "ansible-mongo"
                }
            },
            {
                "_links": {
                    "asynchronous": {
                        "href": "https://nibiru-integration.prsn.us/api/async/instances/dev-use1c-pr-70-mongotesting-modb-0007"
                    },
                    "network": {
                        "href": "https://nibiru-integration.prsn.us/api/networks/aws-dev-us-east-1c-priv"
                    },
                    "owner": {
                        "href": "https://nibiru-integration.prsn.us/api/teams/70"
                    },
                    "self": {
                        "href": "https://nibiru-integration.prsn.us/api/instances/dev-use1c-pr-70-mongotesting-modb-0007"
                    }
                },
                "app_name": "mongotesting",
                "app_type": "modb",
                "aws": {
                    "ebs_options": {
                        "volume_type": "gp2"
                    },
                    "id": "i-011b1c14ea9c4be9f",
                    "image_id": "ami-e906b882",
                    "region": "us-east-1",
                    "security_groups": [
                        "sg-be15dbd1"
                    ],
                    "size": "t2.medium",
                    "subnet": "subnet-42d71935",
                    "tags": {},
                    "volumes": [
                        {
                            "device": "/dev/sdf",
                            "id": "vol-07b0a65fabd69b789",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        },
                        {
                            "device": "/dev/sdg",
                            "id": "vol-0d1e1d4ea19706ed5",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        },
                        {
                            "device": "/dev/sdh",
                            "id": "vol-0f72aa58a7d5085f3",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        },
                        {
                            "device": "/dev/sdi",
                            "id": "vol-009044ce8136833ae",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        }
                    ],
                    "zone": "us-east-1c"
                },
                "environment": "dev",
                "hostname": "dev-use1c-pr-70-mongotesting-modb-0007.prv-prsn.com",
                "id": "dev-use1c-pr-70-mongotesting-modb-0007",
                "ip": "10.199.253.154",
                "location": "use1c",
                "locked": false,
                "privacy": "priv",
                "puppet": {
                    "classes": {},
                    "environment": "v9",
                    "parameters": {}
                },
                "size": "medium",
                "state": "stopped",
                "storage_options": {
                    "size": 25
                },
                "storage_type": "remote",
                "tags": {
                    "by": "susa",
                    "nibiru_scheduler_enabled": "true",
                    "nibiru_scheduler_start_time": "14:00",
                    "nibiru_scheduler_stop_time": "01:00",
                    "purpose": "ansible-mongo"
                }
            },
            {
                "_links": {
                    "asynchronous": {
                        "href": "https://nibiru-integration.prsn.us/api/async/instances/dev-use1d-pr-70-mongotesting-modb-0007"
                    },
                    "network": {
                        "href": "https://nibiru-integration.prsn.us/api/networks/aws-dev-us-east-1d-priv"
                    },
                    "owner": {
                        "href": "https://nibiru-integration.prsn.us/api/teams/70"
                    },
                    "self": {
                        "href": "https://nibiru-integration.prsn.us/api/instances/dev-use1d-pr-70-mongotesting-modb-0007"
                    }
                },
                "app_name": "mongotesting",
                "app_type": "modb",
                "aws": {
                    "ebs_options": {
                        "volume_type": "gp2"
                    },
                    "id": "i-0404df5f452b7beb0",
                    "image_id": "ami-e906b882",
                    "region": "us-east-1",
                    "security_groups": [
                        "sg-be15dbd1"
                    ],
                    "size": "t2.medium",
                    "subnet": "subnet-16e65379",
                    "tags": {},
                    "volumes": [
                        {
                            "device": "/dev/sdf",
                            "id": "vol-004c66a4e5709436d",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        },
                        {
                            "device": "/dev/sdg",
                            "id": "vol-0321c5638ac836795",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        },
                        {
                            "device": "/dev/sdh",
                            "id": "vol-01e5b354cbff9b2f1",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        },
                        {
                            "device": "/dev/sdi",
                            "id": "vol-02390e9ef82fe4a48",
                            "iops": null,
                            "performance": "gp2",
                            "size": 9,
                            "type": "ebs"
                        }
                    ],
                    "zone": "us-east-1d"
                },
                "environment": "dev",
                "hostname": "dev-use1d-pr-70-mongotesting-modb-0007.prv-prsn.com",
                "id": "dev-use1d-pr-70-mongotesting-modb-0007",
                "ip": "10.199.244.252",
                "location": "use1d",
                "locked": false,
                "privacy": "priv",
                "puppet": {
                    "classes": {},
                    "environment": "v9",
                    "parameters": {}
                },
                "size": "medium",
                "state": "stopped",
                "storage_options": {
                    "size": 25
                },
                "storage_type": "remote",
                "tags": {
                    "by": "susa",
                    "nibiru_scheduler_enabled": "true",
                    "nibiru_scheduler_start_time": "14:00",
                    "nibiru_scheduler_stop_time": "01:00",
                    "purpose": "ansible-mongo"
                }
            }
        ]
    },
    "_links": {
        "asynchronous": {
            "href": "https://nibiru-integration.prsn.us/api/async/instances/"
        },
        "documentation": {
            "href": "https://nibiru-integration.prsn.us/api/doc/instances/"
        },
        "schema": {
            "href": "https://nibiru-integration.prsn.us/api/schema/instances/"
        },
        "self": {
            "href": "https://nibiru-integration.prsn.us/api/instances/"
        }
    }
}