#!/bin/bash

# This script tests Delta Lake functionality with Spark

echo "Testing Delta Lake functionality..."

# Wait for Spark master to be ready
echo "Waiting for Spark master to be ready..."
sleep 20

# Submit the Delta Lake demo job
echo "Submitting Delta Lake demo job..."
/opt/bitnami/spark/bin/spark-submit \
  --master spark://spark-master:7077 \
  --packages io.delta:delta-core_2.12:2.2.0,org.apache.hadoop:hadoop-aws:3.3.1 \
  --conf "spark.hadoop.fs.s3a.endpoint=http://minio:9000" \
  --conf "spark.hadoop.fs.s3a.access.key=minioadmin" \
  --conf "spark.hadoop.fs.s3a.secret.key=minioadmin" \
  --conf "spark.hadoop.fs.s3a.path.style.access=true" \
  --conf "spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem" \
  --conf "spark.hadoop.fs.s3a.connection.ssl.enabled=false" \
  --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
  --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog" \
  /opt/spark/delta-lake/delta_demo.py

echo "Delta Lake functionality test completed!"
