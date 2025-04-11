#!/bin/bash

# This script initializes Superset with admin user, database connections, and sample dashboards

echo "Initializing Superset..."
username="${1}"
password="${2}"
firstname="Admin"
lastname="User"
email="admin@example.com"

init_params=" INIT PARAMS FOR SUPERSET:
  username  : ${username}
  firstname : ${firstname}
  lastname  : ${lastname}
  email     : ${email}
  password  : ${password}
"
echo -e "${init_params}"


# Create admin user
echo "Creating admin user..."
superset fab create-admin \
    --username ${username} \
    --firstname ${firstname} \
    --lastname ${lastname} \
    --email ${email} \
    --password ${password}

# Initialize the database
echo "Initializing database..."
superset db upgrade

# Setup roles
echo "Setting up roles..."
superset init

# Create one Trino database connection at a time
# echo "Creating Trino database connection..."
# superset set-database-uri \
#     --database-name "Trino" \
#     --uri "trino://admin@trino:8080/hive/default"

# Import database connections from YAML file
superset import-datasources -p /app/datasources.yml

echo "Superset initialization completed successfully!"
