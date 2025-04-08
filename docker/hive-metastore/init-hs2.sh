#!/bin/bash

# This script initializes the Hive metastore schema in PostgreSQL

echo "Initializing Hive metastore schema..."

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 10

# Initialize the schema
echo "Creating Hive metastore schema..."
$HIVE_HOME/bin/schematool -dbType postgres -initSchema & 
/opt/hive/bin/hive --service metastore &

# /opt/hive/bin/hive --service hiveserver2 \
#   --hiveconf hive.server2.thrift.bind.host=0.0.0.0 \
#   --hiveconf hive.server2.thrift.port=10000 \
#   --hiveconf hive.server2.enable.doAs=false \
#   --hiveconf hive.server2.transport.mode=binary

echo "Hive metastore schema initialization completed!"

# Create default database
echo "Creating default database in Hive metastore..."
$HIVE_HOME/bin/hive -e "CREATE DATABASE IF NOT EXISTS default;"

echo -e "Metastore initialization completed successfully!\n\n\n\n"
