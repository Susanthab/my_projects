# Get EC2 instance IP (external)
dig -x $(curl -s checkip.amazonaws.com) +short

# Get Host IP address of EC2 (internal)
nslookup $HOSTNAME | grep -A1 'Name:' | grep 'Address:' | grep -o " [^ ]*$"

# Free mem
free -mh

# disk related
fdisk -l
df -Th
df -h


