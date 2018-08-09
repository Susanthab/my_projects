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

# *******
# Network
# *******

# list all network cards (IP add show)
ip a s

# list net connections
nmcli conn show

# conn up
nmcli conn up eth03s

# change ONBOOT
sed -i s/ONBOOT=no/ONBOOT=yes/ /etc/sysconfig/network-scripts/ifcfg-enp0s3
grep ONBOOT !$ # !$ means last argument. 

# ************
# Gerenal tips
# ************
#   wheel group is the admin group in Linux


# *******
# Updates
# *******

yum update
yup install -y pkg1, pkg2, etc
yum groupinstall -y "Development Tools"
yum groupinstall -y "X Window System"
yum list installed # list installed packages.  

# ************
# Service mgmt
# ************

systemctl 

# *************************
# Setting Graphical Desktop
# *************************

systemctl set-default graphical.target
systemctl isolate graphical.target

# *****
# users
# *****

cat /etc/passwd
who
CTRL + L # clear the screen. 
pwd # full path to the home dir. 
ls # list contents
type ls
ls -a # all including the hidden files. 
# blue color indicates the dir. 
ls -aF # dir will have / at the end. 
# File type ends with @ are symbolic links. 
ls -l # to get long listing. permission, file size, ownership, etc. 
ls -lrt # to get most recentlt modified files. r=reverse, t=time
# most recently editted file in the bottom. 
ls -lhrt # h=human readable format. 
ls -ld /etc # list the etc dir itself rather the contents of it. 
# drwxr-xr-x. 112 root root 8.0K Jul 23 15:23 /etc/
#   d -> file type (everything in Linux is some form of file.)
#   c -> character device
#   b -> block device
#   l -> links
#   - -> regular file
#   p -> named pipes
#   s -> sockets (open conn)
# rwxr-xr-x. -> permission block
# 112 -> no.of hard links we have for this dir.
# root root -> ownership (user | group)
# 8.0K -> file size. 
# Jul 23 15:23 -> last modified date/time. 
lsb # block devices. 
ls -l /dev/sda? # sda followed by any single char. 
ls -l /dev/sda[12] # sda followed by 1 or 2. 
ls -l /etc/system-release /etc/redhat-release /etc/centos-release
lsb_release -d # get the OS release -d -> desc.
#  lsb_release is a binary file. (executable file)
cat /etc/system-release # get the OS release
ls -l $(which lsb_release)
ls -lF $(which lsb_release) # * at the end of the result means, it is an executable file.

# In centos, it uses the pkg manager as "rpm"
rpm -qf /usr/bin/lsb_release # which pakage contains the lsb_release file. 
#   qf -> query file. Because all the files are stored in the database. 
# shortcut method 
rpm -qf $(which lsb_release)

# -i option will prompt whether to overide the file of passwd exists in the current dir. 
cp -i /etc/hosts ./passwd
#   -i -> interactive mode. 

# ******************
# File mgmt commands
# ******************

mv # move or remove. Again you can use -i mode. 
rm -i * # delete with interactive mode. 
mkdir -p sales/test # create sales parent dir first. 
!rm # last command executed that began with rm.
rm -rf sales # recursive and force delete. 
mkdir one two # creates two dir at the same level. 
touch one/file{1..5} # creates 5 files. 
cp -R one two # recursively cp all the contents of one to two. 
mkdir -m 777 d1 # create a file with the permission
ls -ldi /etc/ # list /etc dir metadata with i node num. 
## 4194369 drwxr-xr-x. 112 root root 8192 Jul 24 06:22 /etc/
# when you create a dir it automatically creates . (current dir) and .. (parent dir) dir as well. 
ln f1 f2 # creates a hard link. Both f1 and f2 files are linked to same metedata. 
ls -li f1 f2 
ln -s f1 f3 # symbolink link (-s)

# **************
# Reading Files. 
# **************

# cat | less | head | tail
#   cat -> for small files
#   less -> for larger files
echo $SSH_CONNECTION # verify ssh conn
cat <file1> <file2>
wc -l /etc/services # word count (wc) of a long file. -l -> lines
less /etc/services # browse thru the file. /string -> searching forward, ?string -> searching backwords. 
#   q -> quit
head -n 3 /etc/services # to see top 3 files. 
tail -n 3 /etc/services # bottom 3 files. 

# Search on files
grep kernel # lines which contains "kernel"
grep ^kernel # begins with "kernel"
grep '\bserver\b' ntp.conf  # searching the word "server"
grep -E 'ion$' /usr/share/dict/words # word ends with "ion"
grep -E '^po..ute$' /usr/share/dict/words # begins with "po" and end with "ute" and any two chars in the middle. 
grep -E '[aeiou]{5}' /usr/share/dict/words # lines with 5 vovals in a row. 

# editing files with SED.
# use various type of regex with sed. 

# Comparing files.
diff <file1> <file2>
# binary files. 
rpm -V ntp # verify a package. 
# get check sum of a binary file. 
md5sum /usr/bin/passwd

# searching files. 
# -delete
find /usr/share/doc -name '*.pdf' -print
find /usr/share/doc -name '*.pdf' -exec cp {} . \;

# look for larger files. 
find /boot -size +20000k -type f






