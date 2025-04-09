#!/bin/bash

# This script tests Trino connectivity and queries

echo "Testing Trino connectivity and queries..."

# Wait for Trino to be ready
echo "Waiting for Trino to be ready..."
sleep 10

# Test basic connectivity
echo "Testing basic connectivity..."
trino --server trino-coordinator:8080 --catalog hive --schema default --execute "SELECT 1"

# List catalogs
echo "Listing available catalogs..."
trino --server trino-coordinator:8080 --execute "SHOW CATALOGS"

# List schemas in hive catalog
echo "Listing schemas in hive catalog..."
trino --server trino-coordinator:8080 --catalog hive --execute "SHOW SCHEMAS"

# List tables in default schema
echo "Listing tables in default schema..."
trino --server trino-coordinator:8080 --catalog hive --schema default --execute "SHOW TABLES"

# Query the sample_sales table created by Spark ETL job
echo "Querying sample_sales table..."
trino --server trino-coordinator:8080 --catalog hive --schema default --execute "SELECT * FROM sample_sales"

echo "Trino connectivity and query test completed successfully!"
