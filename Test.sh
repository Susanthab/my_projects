

st2 run packs.install packs=ansible
st2 run ansible.command_local module_name=apt args='name=sshpass state=present'




ImageId: ami-47bc4c51
KeyName: susanthab
SecurityGroups: sg-06249479
InstanceType: t2.micro
LaunchConfigurationName: launch-config-mongo-2