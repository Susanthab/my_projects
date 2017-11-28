# On Mac
# Install 
brew install kubectl
kubectl version --client

# I also had to do the following
# brew cleanup && brew cask cleanup
# brew install caskroom/cask/brew-cask

# then only the following command worked. 
brew cask install minikube

brew install docker-machine-driver-xhyve

# Set the permission

minikube start --vm-driver=xhyve --memory=6144

# verify 
kubectl config current-context
# switch the context to use other kube environments, right now it is set to use minikube env. 

# to stop
minikube stop

# to delete
minikube delete

#dashboard
minikube dashboard

/usr/local/Cellar/mssql-tools/14.0.5.0/bin/sqlcmd -S 192.168.64.3,31768 -U sa -P P455word1




