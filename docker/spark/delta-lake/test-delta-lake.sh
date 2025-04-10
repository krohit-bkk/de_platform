#!/bin/bash

# This script tests Delta Lake functionality with Spark
echo "Testing Delta Lake functionality..."

# Installing delta-spark dependency for pyspark 
pip install delta-spark==2.2.0

# Wait for Spark master to be ready
echo "Waiting for Spark master to be ready..."
sleep 5

# Submit the Delta Lake demo job
echo "Submitting Delta Lake demo job..."
/opt/bitnami/spark/bin/spark-submit \
  --master spark://spark-master:7077 \
  --num-executors 2 \
  --executor-memory 700M \
  --conf spark.jars.ivy=/tmp/.ivy \
  --conf spark.sql.catalogImplementation=hive \
  --conf "spark.hadoop.hive.metastore.uris=thrift://hive-metastore:9083" \
  --conf "spark.hadoop.fs.s3a.endpoint=http://minio:9000" \
  --conf "spark.hadoop.fs.s3a.access.key=minioadmin" \
  --conf "spark.hadoop.fs.s3a.secret.key=minioadmin" \
  --conf "spark.hadoop.fs.s3a.path.style.access=true" \
  --conf "spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem" \
  --conf "spark.hadoop.fs.s3a.connection.ssl.enabled=false" \
  --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
  --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog" \
  --conf "spark.driver.extraJavaOptions=-Dlog4j.logger.org.apache=WARN" \
  --conf "spark.executor.extraJavaOptions=-Dlog4j.logger.org.apache=WARN" \
  --conf "spark.driver.extraJavaOptions=-Dlog4j.rootCategory=WARN,console" \
  --conf "spark.driver.extraJavaOptions=-Dlog4j.configuration=file:/opt/bitnami/spark/conf/log4j.properties" \
  --jars /opt/bitnami/spark/jars/delta-core_2.12-2.2.0,/opt/bitnami/spark/jars/delta-storage-2.2.0.jar \
  /opt/spark/delta-lake/delta_demo.py

  
  # --packages io.delta:delta-core_2.12:2.2.0,org.apache.hadoop:hadoop-aws:3.3.1 \

if [ $? -eq "0" ]; then 
  echo "Delta Lake functionality test completed!"
  exit 0
fi 

echo ">>>> Delta Lake functionality test failed! I'll be live for 5 min so that you can debug..."
sleep 600
exit 1