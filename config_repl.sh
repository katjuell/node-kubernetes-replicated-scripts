#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Supply password for user'
    echo '  Usage:  config_repl.sh yourpassword'
    echo
    exit 1
fi

echo "Configuring the MongoDB Replica Set"
kubectl exec db-0 -c mongo -- mongo --eval 'rs.initiate({_id: "db", version: 1, members: [ {_id: 0, host: "db-0.db.default.svc.cluster.local:27017"}, {_id: 1, host: "db-1.db.default.svc.cluster.local:27017"}, {_id: 2, host: "db-2.db.default.svc.cluster.local:27017"} ]});'
echo

# Wait for the MongoDB Replica Set to have a primary ready
echo "Waiting for the MongoDB Replica Set to initialise..."
kubectl exec db-0 -c mongo -- mongo --eval 'while (rs.status().hasOwnProperty("myState") && rs.status().myState != 1) { print("."); sleep(1000); };'
#sleep 2 # Just a little more sleep to ensure everything is ready!
sleep 20 # More sleep to ensure everything is ready! (3.6.0 workaround for https://jira.mongodb.org/browse/SERVER-31916 )
echo "...initialisation of MongoDB Replica Set completed"
echo

# Create the admin user (this will automatically disable the localhost exception)
echo "Creating user: 'main_admin'"
kubectl exec db-0 -c mongo -- mongo --eval 'db.getSiblingDB("admin").createUser({user:"mrcat",pwd:"'"${1}"'",roles:[{role:"root",db:"admin"}]});'
echo
