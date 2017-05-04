# Git Credential Caching

$ git config credential.helper store
$ git push https://github.com/repo.git

Username for 'https://github.com': <USERNAME>
Password for 'https://USERNAME@github.com': <PASSWORD>

# Set Credential Expiration - 2 hours

git config --global credential.helper 'cache --timeout 7200'