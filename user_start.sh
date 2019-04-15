#!/bin/bash

echo "Creating user: 'app_user'"
kubectl exec mongo-mongodb-replicaset-0 -c mongodb-replicaset -- mongo -u mrcat -p "brow789*()+" --authenticationDatabase admin --eval 'db.getSiblingDB("admin").createUser({user:"sammy",pwd:"password",roles:[{role:"clusterAdmin",db:"admin"}]});'
echo
