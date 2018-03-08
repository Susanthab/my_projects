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
st2 sensor list -p kubernetes
#| kubernetes.watchCouchbase                    | kubernetes | Sensor that watches Kubernetes API for new   | True    |
#|  


# ==============================
# 03 create custom object in k8.
# ==============================
# couchb-intg.yaml
apiVersion: prsn.io/v1
kind: Couchbase
metadata:
  labels:
    creator: pipeline
    name: susacouchb
  name: couchbtest
  namespace: tpr-dev
spec:
  options:
    volume_size: "200"
    instance_type: "t2.medium"
    desired_capacity: "2"
    full_backup_sch: "1W:Sun"
    app_id: "100"
    team_id: "dba"

# to create
kubectl create -f couchbtest.yaml

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



select_storage_type:
        action: core.local
        input:
          cmd: "printf <% $.storage_type %>"
        publish:
          path: <% task(select_storage_type).result.stdout %>
        on-success: