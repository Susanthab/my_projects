## Date: 3/9/2017

## If it is from another box like Vagrant. 
git remote set-url origin https://github.com/Susanthab/my_projects.git
git config --global user.email "bathige@hotmail.com"
git config --global user.name "Susanthab"

## clone the repo if it does not exists. 
git clone https://github.com/Susanthab/my_projects.git

## get into the repo
cd /home/vagrant/my_projects

## assume the ansible-mongo-replset folder is new and it has subfolders and files. 
## The following command adds all the contentents of the folder. 
git add --all ansible-mongo-replset/*

## Commit the changes. 
git commit -m "Initial Commit"

## Push the changes to the remote repo. 
git push -u origin master


## References
http://stackoverflow.com/questions/38689570/how-to-add-all-of-the-contents-in-a-folder-to-my-github-repo

## Notes:
cp -r ~/ansible-mongodb-replset-copy/ ansible-mongo-replset

## to include a folder and its contents 
git add --all ansible-mongo-replset/*

rm -rf .git/

## New change to test git


#INTEGRATION TEST
git add . && git commit -m"test couchb" && git push origin BITE-3179