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

# Terraform cb version. 
apiVersion: extensions/v1beta1
kind: ThirdPartyResource
description: "Couchbase ThirdPartyResource"
metadata:
  name: cb.prsn.io
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
    full_backup_sch: "1W:Sun,2W:Sun,3W:Sun,4W:Sun,5W:Sun"
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



## TPR for st2 bitesize.
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
    full_backup_sch: "1W:Sun,2W:Sun,3W:Sun,4W:Sun,5W:Sun"
    app_id: "100"
    team_id: "testing"

# TF version
apiVersion: prsn.io/v1
kind: Cb
metadata:
  labels:
    creator: pipeline
    name: susanthab
  name: cbtr01
  namespace: tpr-dev
spec:
  options:
    instance_type: m4.4xlarge
    node_count: 5
    high_perf: 0


###### TEMP
# Install the pack. 
cd /root/.ssh
cp ~stanley/.ssh/* .
chown root *
st2 pack install git@github.com:pearsontechnology/stackstorm-bitesize.git=BITE-3182
st2ctl reload --register-all

#mds testing in new wfk.
apiVersion: prsn.io/v1
kind: Cb
metadata:
  labels:
    creator: pipeline
    name: susanthab
  name: cbtr01
  namespace: tpr-dev
spec:
  options:
    instance_type: t2.xlarge
    node_count: 2
    use_mds: 1



