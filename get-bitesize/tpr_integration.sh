#Couchbase integration

# List all available triggers
st2 trigger list

# Check details on Interval Timer trigger
st2 trigger get core.st2.IntervalTimer

# Check details on the Webhook trigger
st2 trigger get core.st2.webhook

kubectl get thirdpartyresources
# ========================
# 01 create the TPR in k8.
# ========================
# vi couchbase.yaml
apiVersion: extensions/v1beta1
kind: ThirdPartyResource
description: "Couchbase ThirdPartyResource"
metadata:
  name: couchbase.prsn.io
  labels:
    type: ThirdPartyResource
versions:
  - name: v1

# to create
kubectl create -f couchbase.yaml

# ===================
# 02 Check st2 Sensor
# ===================
# After creating this TPR, if you swicth back to st2 and check the sensor, it should have been created now. 
# In st2 side check the sensor is created for the above resource. 
# See whether sensor is running.
ps auxwww| grep -i couch
st2 sensor list -p kubernetes | grep Couch
#| kubernetes.watchCouchbase                    | kubernetes | Sensor that watches Kubernetes API for new   | True    |
#|  


# ==============================
# 03 create custom object in k8.
# ==============================
# couchb1.yaml
apiVersion: prsn.io/v1
kind: Couchbase
metadata:
  labels:
    creator: pipeline
    name: susanthab
  name: cbtest45
  namespace: tpr-dev
spec:
  options:
    volume_type: "gp2"
    volume_size: "200"
    instance_type: "m4.4xlarge"
    desired_capacity: "3"
    full_backup_sch: "1W:Fri"
    app_id: "100"
    team_id: "testing"

# to create
kubectl create -f couchbscott.yaml

# to see the object. 
kubectl -n tpr-dev get couchbase

# ==============================
# 03 Check the st2 w/f execution
# ==============================
# At this point the st2 workflow, attached to the st2 rule should have been executed. 



# delete a custom object. 
# =======================
# 04 Delete custom object
# =======================
kubectl delete -f couchb-intg.yaml



{"resource":"ADDED","object_kind":"Couchbase","labels":{"name":"susacouchb","creator":"pipeline"},"namespace":"tpr-dev","uid":"ec304cc7-2616-11e8-8bdf-0a39c1fe23e0","spec":{"options":{"desired_capacity":"1","app_id":"100","volume_type":"gp2","instance_type":"t2.large","team_id":"dba","full_backup_sch":"1W:Sun","volume_size":"200"}},"name":"couchbtest"}