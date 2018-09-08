
#To list all open ports or currently running ports including TCP and UDP
netstat -lntu

# To display open ports and established TCP connections, enter
netstat -vatn

# all the conn
netstat -nat

# 
netstat -ton | grep CLOSE_WAIT

# from which program
netstat -tonp
netstat -A inet -p

netstat -nat | grep ESTAB | grep -v "`cat kubehost.txt`" | wc -l
netstat -nat | grep ESTAB | wc -l
ls -ltr /opt/couchbase/var/lib/couchbase/logs/