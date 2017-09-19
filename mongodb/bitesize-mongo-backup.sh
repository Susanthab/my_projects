#!/usr/bin/env bash
set -o nounset
set -o errexit

source ~/.bash_profile

_MONGODUMP_ARGS="--directoryperdb --quiet"
_BACKUP_PATH="/tmp/mongodump"
_TIMESTAMP="$(date -u +"%Y-%m-%d-%H")"
_BACKUP_DIR="${_BACKUP_PATH}/${STACK_NAME}/${_TIMESTAMP}"

# @TODO - add tags via 3rdPartyResource id'ing namespace + db_type
# @TODO - ^^ + add to BACKUP_S3_LOC naming construction

BACKUP_S3_LOC="bitesize-be-backups/${STACK_NAME}/${_TIMESTAMP}"

if [ ${USER:-} != "root" ]
then
    echo "Must be root user"
    exit 1
fi

mkdir -p ${_BACKUP_PATH}/${STACK_NAME}/${_TIMESTAMP}

bkup()  {
    mkdir -p "${_BACKUP_DIR}"
    pushd ${_BACKUP_DIR}
    mongodump ${_MONGODUMP_ARGS}
    zip -rq "${STACK_NAME}.zip" dump/
    popd
}

s3_up() {
    echo "Uploading $1 to s3"
    aws s3 cp --only-show-errors --sse  "$1"  "s3://${BACKUP_S3_LOC}/"
    rm "$1"
}

cleanup() {
rm -fr ${_BACKUP_PATH}/${STACK_NAME}/${_TIMESTAMP}
}

bkup
BACKUP_ZIP="${STACK_NAME}.zip"
s3_up ${_BACKUP_DIR}/${BACKUP_ZIP}

if [[ $? -ne 1 ]]; then
  cleanup
else
  echo "s3_up failed!"
  exit 1
fi