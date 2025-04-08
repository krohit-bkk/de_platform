#!/bin/bash

# This script initializes the Hive metastore schema in PostgreSQL

echo "Initializing Hive Server2..."
sleep 10

# Initialize the schema
/opt/hive/bin/hive --service hiveserver2 \
  --hiveconf hive.server2.thrift.bind.host=0.0.0.0 \
  --hiveconf hive.server2.thrift.port=10000 \
  --hiveconf hive.server2.enable.doAs=false \
  --hiveconf hive.server2.transport.mode=binary \
  --hiveconf hive.metastore.uris=thrift://hive-metastore:9083 &

echo -e "\n\nHiveServer2 started!\n\n"

# Create default database
echo ">>>> Creating default database in Hive metastore..."
$HIVE_HOME/bin/beeline -u "jdbc:hive2://hiveserver2:10000" -e "SHOW TABLES;"

echo -e "Hiveserver2 initialization completed successfully!\n\n\n\n"
