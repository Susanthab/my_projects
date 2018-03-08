

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
   --env=ubathsu \
   --region=us-west-2
   --modules core,ca,db,bastion,consul,etcd,kube-master,kube-minion,stackstorm


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


