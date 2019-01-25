

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

kubectl get pods -n glp-nft | grep lcd | awk {'print $1'} | xargs -L 1 -I {} kubectl -n glp-nft exec {} -- sh -c "echo \"{} => \`netstat -na | grep tcp | grep :9390 | grep -v LISTEN | wc -l\`\""

kubectl describe ep kong-api-gw -n glp-nft 

#connections
kubectl get pods -n glp-nft | grep pls | awk {'print $1'} | xargs -L 1 -I {} kubectl -n glp-nft exec {} -- sh -c "echo \"{} => \`netstat -na | grep tcp | grep -v LISTEN | wc -l\`\""

curl --key /etc/cfssl/ssl/kubernetes/client-prometheus-key.pem --cert /etc/cfssl/ssl/kubernetes/client-prometheus.pem -k https://master.glp1.us-east-2.pre/api/v1/namespaces/glp-nft/pods/lad-974849190-5bg76:9360/proxy/lad/metrics


for i in `kubectl get pod -n=glp-nft -o name | sed -e 's/^pods\///g'`; do echo $i; kubectl exec -it -n=glp-nft $i -- sh -c 'netstat -an | grep 11210'; done

# k8 manifest files on kube-master
/etc/kubernetes/manifests

# secrets
# https://kubernetes.io/docs/concepts/configuration/secret/#decoding-a-secret
kubectl get secrets -n glp-nft
# decode
kubectl get secret cb-kernel2-pass -n glp-nft -o yaml
echo 'dEgxWDNkajJXWlRXbnlVRQ==' | base64 --decode

# restart all microservices except zookeeper and kafka
kubectl get pods -n glp-nft | grep -v zo | grep -v kaf | awk '{ print $1 }' | xargs kubectl delete pod -n glp-nft

# list volumes
kubectl get pv

#k8 commands
#https://gist.github.com/edsiper/fac9a816898e16fc0036f5508320e8b4#volumes