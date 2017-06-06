
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


# mongo db sample dataset.

curl -O https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json
mongoimport --db test --collection restaurants --drop --file ./primer-dataset.json

mongo
use test
db.restaurants.count()

