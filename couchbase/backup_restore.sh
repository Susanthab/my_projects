

# backup dir structure
#/var/www/html/couchbase-backup/<project-name or team-id>/<cluster-name>/<node>
# e.g: /var/www/html/couchbase-backup/Bitesize/backup-testing/ip-172-31-76-152


# backup single bucket from all the nodes. 
cbbackup http://172.31.69.196:8091 /var/www/html/couchbase-backup/ -u admin -p 12qwaszx@ -b beer-sample

# backup all the buckets of a single node. 
cbbackup http://172.31.57.238:8091 /var/www/html/couchbase-backup/Bitesize/backup-testing/ip-172-31-76-152/ -m full -u admin -p 12qwaszx@ --single-node
cbbackup http://172.31.57.238:8091 /var/www/html/couchbase-backup/Bitesize/backup-testing/ip-172-31-76-152/ -m diff -u admin -p 12qwaszx@ --single-node
cbbackup http://172.31.57.238:8091 /var/www/html/couchbase-backup/Bitesize/backup-testing/ip-172-31-76-152/ -m accu -u admin -p 12qwaszx@ --single-node

# restore
cbrestore /var/www/html/couchbase-backup/bitesize/backup-testing/ip-172-31-72-108/backup/ http://172.31.65.114:8091 -u admin -p 12qwaszx@ -b beer-sample



cbrestore /var/www/html/couchbase-backup/ http://172.31.69.196:8091 -u admin -p 12qwaszx@ -b beer-sample -B beer-sample-restored
cbrestore /var/www/html/couchbase-backup/ http://172.31.69.196:8091 -u admin -p 12qwaszx@ -b gamesim-sample -B gamesim-sample-restored
cbrestore /var/www/html/couchbase-backup/ http://172.31.69.196:8091 -u admin -p 12qwaszx@ -b travel-sample -B travel-sample-restored

cbrestore /var/www/html/backup/ http://172.31.73.220:8091 -u admin -p 12qwaszx@ -b beer-sample -B beer-sample-restored


cbrestore /var/www/html/couchbase-backup/restore/ip-172-31-52-205/ http://172.31.54.105:8091 -u admin -p 12qwaszx@ -b beer-sample -B beer-sample-restored