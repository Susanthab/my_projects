

# Get all the namespaces.
kubectl get ns

# Get all the pods for a given namespace.
kubectl get pods -n glp-dev

# Get details about a perticular pod. 
kubectl describe pod -n glp-dev couchbase-master-glp-3667123713-87rlm

# Log into a perticular pod
kubectl exec -it -n glp-dev couchbase-master-glp-3667123713-87rlm -- bin/bash

# get TPR
kubectl get thirdpartyresources

# on kube-master
curl http://localhost:8080/
ls /etc/ssl/certs


# namespaces for enviornments.
kubectl get ns

# application instances
kubectl get pods

# desc app instance
kubectl describe pod <pod name>

# see the logs
kubectl logs -f <instance id>

# service
kubectl get svc
kubectl -n staging get pod

# get all the services of the staging enviornments
kubectl -n staging get svc

# to see the logs of all the instances of the application.  There are two utilities.
1. kubetail
2. stern
stern <app name>

# Question 1 -> What is our logging tool in BS?

# delete a pod
kubectl delete pod <instance name>

# labels are really really important in k8.
# to see serving labels
kubectl get pods -L <serving>

# change the labels
# This is perticularly helpful to stop routing LB trafic to some pods.
kubectl label pod <pod name> --overwrite serving=false

# get into a pod.
kubectl exec -it <instance name> /bin/bash
    ps auwx

# port-forward
kubectl port-forward <instance name> 9090:8080
# distributed tracing is helpful to troubleshoot issues with Microservices.