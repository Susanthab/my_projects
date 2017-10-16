

# Get all the namespaces.
kubectl get ns

# Get all the pods for a given namespace.
kubectl get pods -n glp-dev

# Get details about a perticular pod. 
kubectl describe pod -n glp-dev couchbase-master-glp-3667123713-87rlm

# Log into a perticular pod
kubectl exec -it -n glp-dev couchbase-master-glp-3667123713-87rlm -- bin/bash

