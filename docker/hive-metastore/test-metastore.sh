#!/bin/bash

# Create a test table
echo "Creating a test table in the metastore..."
$HIVE_HOME/bin/beeline -u "jdbc:hive2://hive-metastore:10000" -e "
CREATE TABLE IF NOT EXISTS default.test_table (
  id INT,
  name STRING,
  value DOUBLE
)
LOCATION 's3a://raw-data/test_table';"

# Verify table creation
echo "Verifying table creation..."
$HIVE_HOME/bin/beeline -u "jdbc:hive2://hive-metastore:10000" -e "DESCRIBE default.test_table;"

# List tables to confirm
echo "Listing tables in default database..."
$HIVE_HOME/bin/beeline -u "jdbc:hive2://hive-metastore:10000" -e "SHOW TABLES in default;"

echo "Hive metastore connectivity test completed successfully!"