#!/bin/bash

# This script tests MinIO functionality by uploading and downloading a test file
echo "Testing MinIO functionality..."
sleep 10

# Create a test file
echo "Creating test file..."
echo "This is a test file for MinIO functionality" > test-file.txt

# Configure MinIO client
mc alias set myminio http://minio:9000 minioadmin minioadmin

# Upload test file to raw-data bucket
echo "Uploading test file to raw-data bucket..."
mc cp test-file.txt myminio/raw-data/

# List contents of raw-data bucket to verify upload
echo "Listing contents of raw-data bucket..."
mc ls myminio/raw-data/

# Download the file to verify retrieval
echo "Downloading test file from raw-data bucket..."
mc cp myminio/raw-data/test-file.txt test-file-downloaded.txt

# Compare the files
# Compare line by line
line_num=1
while IFS= read -r line1 && IFS= read -r line2 <&3; do
    if [ "$line1" != "$line2" ]; then
        echo "Mismatch at line $line_num:"
        echo "File1: $line1"
        echo "File2: $line2"
        exit 1
    fi
    ((line_num++))
done < "test-file.txt" 3< "test-file-downloaded.txt"
echo "Both files are identical!"

# Clean up
echo "Cleaning up test files..."
rm test-file.txt test-file-downloaded.txt

echo "MinIO functionality test completed successfully!"
