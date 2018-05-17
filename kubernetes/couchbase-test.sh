
# create a deployment on couchbase-test ns.
kubectl create -f couchbase-deployment.yaml --namespace couchbase-test

# check the deployment.
kubectl get deployments --namespace couchbase-test

# check the pods. 
kubectl get pods --namespace couchbase-test

# Create a service
kubectl create -f couchbase-service.yaml --namespace couchbase-test

# edit deployment to change replicas. 
kubectl edit deployment couchbase-enterprise --namespace couchbase-test

# get all the services.
kubectl get services --namespace couchbase-test

# describe a service. 
kubectl describe service couchbase-test --namespace couchbase-test

# gel all the namespaces
kubectl get ns
