# Git Credential Caching

$ git config credential.helper store
$ git push https://github.com/repo.git

Username for 'https://github.com': <USERNAME>
Password for 'https://USERNAME@github.com': <PASSWORD>

# Set Credential Expiration - 2 hours

git config --global credential.helper 'cache --timeout 7200'

# to see the local branches and the current branch. 
git branch

# to see all the branches at remote repo at the time of last git pull. 
git branch -a

# change the current local branch to local master
git checkout master

# synch local master with remote master
git pull origin master

# Pull remote branch (pull -> fetch && merge)

git pull nib-306
git checkout nib-306
git pull origin master


git reset --hard origin/master

