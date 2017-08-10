
THERESULT="\n\n     "`cat /etc/cassandra/cassandra.yaml | grep cluster_name: `
THERESULT="$THERESULT\n     "`cat /etc/cassandra/cassandra.yaml | grep initial_token: `
THERESULT="$THERESULT\n     "`cat /etc/cassandra/cassandra.yaml | grep seeds: `
THERESULT="$THERESULT\n     "`cat /etc/cassandra/cassandra.yaml | grep listen_address: `
THERESULT="$THERESULT\n     "`cat /etc/cassandra/cassandra.yaml | grep rpc_address: `
THERESULT="$THERESULT\n     "`cat /etc/cassandra/cassandra.yaml | grep num_tokens: `
THERESULT="$THERESULT\n     "`cat /etc/cassandra/cassandra.yaml | grep partitioner: `
THERESULT="$THERESULT\n     "`cat /etc/cassandra/cassandra.yaml | grep bootstrap: `