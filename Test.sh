

st2 run packs.install packs=ansible
st2 run ansible.command_local module_name=apt args='name=sshpass state=present'


