
# Authenticate to mongodb
# On all nodes
> mongo
use admin
db.auth('mongo_admin','pssw0rd')
db.auth('mongo_cl_admin','pssw0rd')

# Insert Data On Primary
use HR
db.employee.insert({'name':'susantha bathige','address':'Colorado'})
db.employee.findOne()

# On Secondary
rs.salveOk()
use HR
db.employee.findOne()
