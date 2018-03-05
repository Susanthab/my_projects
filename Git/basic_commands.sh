

# create local branch.
git checkout -b <branch-name>

# add files
git add 
git add .

# commit files. 
git commit -m "st2 workflow to create cassandra ring."

# how to push a branch to remote remote.
git push -u origin nib-228


# synch the master with remote repo
git pull origin master

# un-stage a file. 
git reset -- <file>

# undo commit.
# get the list first. 
git clean -f -n
# do the undo.
git clean -f

# after git clone, swicth to a diff branch. 
# list all the branches
git branch -a
git checkout <bite-2273>

# remove untracked files
git rm --cached <file>

