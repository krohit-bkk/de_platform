#!/bin/bash

# This script initializes and starts both Hive Metastore and HiveServer2

echo ">>>> Initializing Hive services..."

# Wait for PostgreSQL to be ready
echo ">>>> Waiting for PostgreSQL to be ready..."
sleep 10

# Initialize schema if not exists
if [ ! -f /metastore/metastore_db/metastore.script ]; then
  echo ">>>> Creating Hive metastore schema..."
  $HIVE_HOME/bin/schematool -dbType postgres -initSchema
fi

# Start Metastore in background with IS_RESUME
echo ">>>> Starting Hive Metastore..."
export IS_RESUME="true"
$HIVE_HOME/bin/hive --service metastore &

# Wait for metastore to be ready
sleep 15

# Create default database if needed
echo ">>>> Creating default database..."
$HIVE_HOME/bin/hive -v -e "CREATE DATABASE IF NOT EXISTS default;"
$HIVE_HOME/bin/hive -v -e "SHOW DATABASES;"

echo -e "\n\n>>>> Hive services started successfully!\nMetastore PID: $(pgrep -f 'metastore')\n\n"