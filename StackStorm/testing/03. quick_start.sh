

## remove a pack

st2 pack remove hello_st2

## https://docs.stackstorm.com/reference/packs.html#anatomy-of-a-pack

## Authentication
# https://docs.stackstorm.com/1.6/troubleshooting/ssh.html
service st2actionrunner restart

st2 run core.remote cmd=whoami hosts=10.199.248.5 username=ubuntu private_key="`cat /home/vagrant/.ssh/id_rsa`"