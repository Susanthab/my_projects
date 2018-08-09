# ./int-test.sh dev eu-west-1 env BITE-3412


(get-bitesize-Ij6kGS50) bash-3.2$ cat int-test.sh 
#!/bin/bash

set -e 

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 dev eu-west-1 myenv"
    exit 1
fi

envtype=$1
region=$2
env=$3

# this script can be run from anywhere
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
be_dir="$(dirname "$dir")"
cd $be_dir
echo "Running script from $be_dir"
echo "pwd=$(pwd)"

# decrypt keys from the secrets file
cd ${envtype}/${region}/${env}
b64_decode() {
if uname -s | egrep Darwin >/dev/null ; then
    base64 -D ;
else
    base64 -d ;
fi
}
decrypt() {
    local key=$1
    local encrypted=$(egrep "^ *$key[ =]" secrets.tfvars)
    encrypted=$(echo "$encrypted" | sed -e "s/^ *$key[ = ]*//" | tr -d '"')
    local kms_decrypt_region=eu-west-1
    local ciphertextf=`mktemp "./tmp.XXXXXXXXXX"`
    echo "$encrypted" | b64_decode > "$ciphertextf"
    local decrypted_b64=$(aws kms decrypt \
    --region ${kms_decrypt_region} \
    --ciphertext-blob fileb://${ciphertextf} \
    --output text --query Plaintext)
    echo "$decrypted_b64" | b64_decode || return=$?
    rm "$ciphertextf"
    return ${return}
}
export KUBERNETES_PASSWORD=${KUBERNETES_PASSWORD:-$(decrypt kube_password)}
export CONSUL_TOKEN=${CONSUL_TOKEN:-$(decrypt consul_master_token)}
export STACKSTORM_API_KEY=${STACKSTORM_API_KEY:-$(decrypt st2_apikey)}

# check clone the integration tests repo
rm -fr test/integration
git clone git@github.com:pearsontechnology/bitesize-integration.git "test/integration" > /dev/null 2>&1
cd test/integration
git checkout BITE-3179
cd ../..

# setup environment variables for the tests
export ENVIRONMENT=${env}
export REGION=${region}
export KUBERNETES_INGRESS_HOST="lb.${env}.${region}.${envtype}.prsn.io"
export KUBERNETES_API_ENDPOINT="https://master.${env}.${region}.${envtype}.prsn.io"
export ETCD_HOST="etcd.${env}.${region}.${envtype}"
export VAULT_HOST="vault.${env}.${region}.${envtype}"
export STACKSTORM_URL="https://stackstorm.${env}.${region}.${envtype}.prsn.io"
export KUBERNETES_USERNAME="admin"
export PROMETHEUS_HOST="prometheus.${env}.${region}.${envtype}"

# run the integration tests
rm -fr pytestenv > /dev/null
virtualenv -p `which python2.7` pytestenv > /dev/null
. pytestenv/bin/activate > /dev/null
pip install -r "test/integration/requirements.txt" > /dev/null 2>&1
cd "test/integration"
#pytest test
#pytest test/prometheus
pytest -s -v test/couchbase

# cleanup
cd ${be_dir}/${envtype}/${region}/${env}
rm -fr test/integration



git add . && git commit -m "debug" && git push origin BITE-3412
