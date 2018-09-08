!/bin/bash

list=(
  "10.1.39.124"
  "10.1.39.167"
  "10.1.43.52"
  "10.1.51.178"
  "10.1.53.65"
)

for i in "${list[@]}"; do
  echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  echo ssh -oStrictHostKeyChecking=no -Att -l susanthab 18.218.95.24 ssh -oStrictHostKeyChecking=no -Att -l susanthab $i sudo netstat -nat
  echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  count=$(ssh -oStrictHostKeyChecking=no -Att -l susanthab 18.218.95.24 ssh -oStrictHostKeyChecking=no -Att -l susanthab $i sudo netstat -nat | grep ESTAB | wc -l)
  echo $i has $count established connections
done