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
sleep 10

# Create default database if needed
echo ">>>> Creating default database..."
$HIVE_HOME/bin/hive -v -e "CREATE DATABASE IF NOT EXISTS default;"
$HIVE_HOME/bin/hive -v -e "CREATE DATABASE IF NOT EXISTS airline;"
$HIVE_HOME/bin/hive -v -e "SHOW DATABASES;"
$HIVE_HOME/bin/hive -v -e "
CREATE EXTERNAL TABLE airline.passenger_flights (
  PassengerID STRING,
  FirstName STRING,
  LastName STRING,
  Gender STRING,
  Age INT,
  Nationality STRING,
  AirportName STRING,
  AirportCountryCode STRING,
  CountryName STRING,
  AirportContinent STRING,
  Continents STRING,
  DepartureDate STRING,
  ArrivalAirport STRING,
  PilotName STRING,
  FlightStatus STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 's3a://raw-data/airline_data/'
TBLPROPERTIES ('skip.header.line.count'='1')
"

echo -e "\n\n>>>> Hive services started successfully!\nMetastore PID: $(pgrep -f 'metastore')\n\n"