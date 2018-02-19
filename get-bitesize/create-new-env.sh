

# deploy only the core. 
cd bitesize-environments && \
   ./manage-env.py create \
   --env=ubathsu \
   --region=us-west-2 \
   --modules core,bastion,stackstorm,etcd,kube-master


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


