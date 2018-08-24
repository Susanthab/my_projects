
kubectl exec -it glp-uat-kafka-kafka-0 -n glp-uat -- kafka-topics --describe --topic sps-analytics-domain-graph-created-success_Topic --zookeeper glp-uat-kafka-zookeeper:2181


kubectl exec -it glp-perf-kafka-kafka-0 -n glp-perf -- kafka-topics --describe --topic sps-analytics-domain-graph-created-success_Topic --zookeeper glp-uat-kafka-zookeeper:2181

kubectl exec -it glp-perf-kafka-kafka-0 -n glp-perf -- kafka-topics --describe  --zookeeper glp-perf-kafka-zookeeper:2181

kubectl exec -it glp-perf-kafka-kafka-0 -n glp-perf -- kafka-topics --describe  --zookeeper glp-perf-kafka-zookeeper:2181

kubectl exec -it glp-nft-kafka-kafka-0 -n glp-nft -- kafka-topics --describe  --zookeeper glp-nft-kafka-zookeeper:2181

kubectl exec -it kafkaglp-0 -n glp-nft -- kafka-topics --alter --partitions 8 --topic resource_deleted_event_Topic PartitionCount  --zookeeper zookeeper.glp-nft.svc.cluster.local:2181

