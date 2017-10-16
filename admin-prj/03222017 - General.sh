
# To log into bitesize-prod master.use-prod.kube
# From my Mac. 
ssh -i "aws/bitesize-prod/bitesize.key" centos@52.55.157.91
#                                       centos@52.25.97.78 (us-west - Oregon)
# From there you need to ssh to other nodes. 

sudo su -
ssh -i "/root/.ssh/bitesize.key" ubuntu@10.253.6.242



