 # disable hugepages
 # https://developer.couchbase.com/documentation/server/current/troubleshooting/troubleshooting-common-errors.html

 disable_huge() {

   # Backup /etc/rc.local
   sudo cp -p /etc/rc.local /etc/rc.local.`date +%Y%m%d-%H:%M` 

   echo "disabling huge page support, permanently"
   if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
      echo never > /sys/kernel/mm/transparent_hugepage/enabled
   fi
   if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
      echo never > /sys/kernel/mm/transparent_hugepage/defrag
   fi
 }