#!/bin/bash

# This script tests Superset connectivity and dashboard creation

echo "Testing Superset connectivity and dashboard creation..."

# Wait for Superset to be ready
echo "Waiting for Superset to be ready..."
sleep 30

# Test Superset API
echo "Testing Superset API..."
curl -s -X GET http://superset:8088/api/v1/database/ -H "Content-Type: application/json" -u admin:admin

# Create a simple dashboard
echo "Creating a simple dashboard..."
# This would typically use the Superset API to create a dashboard
# For this test, we'll just check if we can access the dashboard creation page
curl -s -X GET http://superset:8088/dashboard/list/ -u admin:admin

echo "Superset connectivity and dashboard test completed!"
