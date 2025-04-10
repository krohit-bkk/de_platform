#!/bin/bash

# This script creates the necessary buckets in MinIO for our data platform

# Wait for MinIO to be ready
echo "Waiting for MinIO to be ready..."
sleep 10

# Create buckets
echo "Creating MinIO buckets..."
mc alias set myminio http://minio:9000 minioadmin minioadmin

# Create raw data bucket
mc mb myminio/raw-data
echo "Created raw-data bucket"

# Upload a sample file
echo "1,A,Foo" >> sample-file.csv
echo "2,B,Bar" >> sample-file.csv
mc mkdir myminio/raw-data/sample_data
mc cp sample-file.csv myminio/raw-data/sample_data/
mc ls myminio/raw-data/sample_data/


# Create processed data bucket
mc mb myminio/processed-data
echo "Created processed-data bucket"

# Create curated data bucket
mc mb myminio/curated-data
echo "Created curated-data bucket"

# Create delta lake bucket
mc mb myminio/delta-lake
echo "Created delta-lake bucket"

# Set bucket policies (optional)
# mc policy set download myminio/curated-data

echo "MinIO bucket setup completed successfully!"
