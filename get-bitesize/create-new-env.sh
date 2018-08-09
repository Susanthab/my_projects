
# delete the env plan.
rm -rf dev/eu-west-1/ubathsu/

# deploy only the core. 
cd bitesize-environments && \
   ./manage-env.py create \
   --env=ubathsu \
   --region=us-west-2 \
   --modules core,bastion,stackstorm,etcd,kube-master

cd bitesize-environments && \
   ./manage-env.py add \
   --env=ubathsu \
   --region=us-west-2 \
   --modules kube-minion,consul

cd bitesize-environments && \
   ./manage-env.py create \
   --envtype=dev \
   --env=ubathsu \
   --region=us-west-2
   --modules core,ca,db,bastion,consul,etcd,kube-master,kube-minion,stackstorm

# assuming you are in bitesize-environment
   ./manage-env.py create \
   --env=ubathsu \
   --region=us-west-2

# create only CB env. 
./manage-env.py --env ubathsu --region eu-west-1 --envtype dev -p couchbase -m core,bastion create
./manage-env.py --env ubathsu --region eu-west-1 --envtype dev -p couchbase create

beconnect.py -su susanthab -go

# SSH to docker container.
docker exec -it <container id> /bin/bash


# --- SourceTree Generated ---
Host Susanthab-GitHub
        HostName github.com
        User Susanthab
        PreferredAuthentications publickey
        IdentityFile /Users/ubathsu/.ssh/Susanthab-GitHub
# ----------------------------

Host github.com
        HostName github.com
        User Susanthab
        PreferredAuthentications publickey
        IdentityFile /Users/ubathsu/.ssh/bathige-github


