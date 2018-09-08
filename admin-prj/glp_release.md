Go to : https://jenkins.gl-poc.com/
Need the release tag.

Verify the release
kubectl get pods -n=glp-nft -o yaml | grep lcd | grep image | grep PERF_14284f3a_build66_GLP-47017 | sort -u
