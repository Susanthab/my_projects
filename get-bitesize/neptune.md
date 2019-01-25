apiVersion: prsn.io/v1
kind: Neptune
metadata:
  labels:
    creator: pipeline
    name: susanthab
  name: nep01
  namespace: tpr-dev
spec:
  options:
    db_instances:
      - db_name: "db01"
        db_instance_class: "db.r4.xlarge"
      - db_name: "db02"
        db_instance_class: "db.r4.large"

curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/
$ iam_role_name=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/)
$ curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/${iam_role_name}
{
  "Code" : "Success",
  "LastUpdated" : "2018-05-09T14:25:48Z",
  "Type" : "AWS-HMAC",
  "AccessKeyId" : "",
  "SecretAccessKey" : "",
  "Token" : "",
  "Expiration" : "2018-05-09T20:46:55Z"
}


curl -H "Authorization: OAuth <ACCESS_TOKEN>" http://susa-test.cluster-cuqpe2sfyev1.eu-west-1.neptune.amazonaws.com:8182/gremlin
