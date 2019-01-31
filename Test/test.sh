couchbase-cli server-add -c 10.1.49.60 -u Administrator -p 9sECVCwNfeYD9wPo \
--server-add=10.1.46.148 --services=data \
--server-add-username=Administrator --server-add-password=9sECVCwNfeYD9wPo

couchbase-cli rebalance -c 10.1.49.60 -u Administrator -p 9sECVCwNfeYD9wPo \
--server-remove=10.1.49.60