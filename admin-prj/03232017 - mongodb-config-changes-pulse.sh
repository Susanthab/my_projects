
# Requested to change the config for following dev servers.

# mongo  10.253.6.242:27017/pulsedevmongo-pulse-dev
# mongo  10.253.6.210:27017/pulseauthdevmongo-pulseauth-dev

mongo -usiteRootAdmin -ppassw0rd admin

db.runCommand({buildInfo:1})

# New config settings for the storage:
 wiredTiger:
	engineConfig:
    cacheSizeGB: 4

   engine: wiredTiger
   engineConfig:
      cacheSizeGB: 4

# all below nodes are in version "v2.6.12""

# 10.253.6.73 mongo1 (secondary)
# 10.253.6.156 mongo2 (secondary)
# 10.253.6.35 mongo3 (secondary)
# 10.253.6.242 mongo4 (current primary)


# 10.253.6.34 mongo1
# 10.253.6.140 mongo2
# 10.253.6.55 mongo3 
# 10.253.6.210 mongo4 (curremt primary)

db._adminCommand( {getCmdLineOpts: 1})

storage:
   wiredTiger:
      engineConfig:
         cacheSizeGB: <number>
         journalCompressor: <string>
         directoryForIndexes: <boolean>
      collectionConfig:
         blockCompressor: <string>
      indexConfig:
         prefixCompression: <boolean>


