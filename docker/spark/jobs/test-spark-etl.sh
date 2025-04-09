#!/bin/bash

# This script tests the Spark ETL job

echo "Testing Spark ETL job..."

# Wait for Spark master to be ready
echo "Waiting for Spark master to be ready..."
sleep 5

ls -lrt /opt/spark/jobs/sample_etl.py

# Submit the sample ETL job
echo "Submitting sample ETL job..."
/opt/bitnami/spark/bin/spark-submit \
  --master spark://spark-master:7077 \
  --conf spark.jars.ivy=/tmp/.ivy \
  --conf "spark.hadoop.fs.s3a.endpoint=http://minio:9000" \
  --conf "spark.hadoop.fs.s3a.access.key=minioadmin" \
  --conf "spark.hadoop.fs.s3a.secret.key=minioadmin" \
  --conf "spark.hadoop.fs.s3a.path.style.access=true" \
  --conf "spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem" \
  --conf "spark.hadoop.fs.s3a.connection.ssl.enabled=false" \
  --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
  --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog" \
  --conf "spark.driver.extraJavaOptions=-Dlog4j.rootCategory=WARN,console" \
  --conf "spark.driver.extraJavaOptions=-Dlog4j.configuration=file:/opt/bitnami/spark/conf/log4j.properties" \
  --jars /opt/bitnami/spark/jars/delta-core_2.12-2.2.0 \
  /opt/spark/jobs/sample_etl.py 

if [ $? -eq "0" ]; then 
  echo "Spark ETL job test completed!"
  exit 0
fi 

echo ">>>> Spark ETL job failed! I'll be live for 5 min so that you can debug..."
sleep 600
exit 1