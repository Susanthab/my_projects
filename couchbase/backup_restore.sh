



# backup single bucket from all the nodes. 
cbbackup http://172.31.69.196:8091 /var/www/html/couchbase-backup/ -u admin -p 12qwaszx@ -b beer-sample

cbrestore /var/www/html/couchbase-backup/ http://172.31.69.196:8091 -u admin -p 12qwaszx@ -b beer-sample -B beer-sample-restored
cbrestore /var/www/html/couchbase-backup/ http://172.31.69.196:8091 -u admin -p 12qwaszx@ -b gamesim-sample -B gamesim-sample-restored
cbrestore /var/www/html/couchbase-backup/ http://172.31.69.196:8091 -u admin -p 12qwaszx@ -b travel-sample -B travel-sample-restored

cbrestore /var/www/html/backup/ http://172.31.73.220:8091 -u admin -p 12qwaszx@ -b beer-sample -B beer-sample-restored