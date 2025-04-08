#!/bin/bash

# This script sets up the Spark environment with necessary jars for S3, Hive, and Delta Lake

echo "Setting up Spark environment..."
install_packages curl

echo "wget installed - [$$?]"

# Create directories for jars
mkdir -p /opt/bitnami/spark/jars

# Download required jars
echo "Downloading required jars..."

# # S3 connector jars
# wget -q https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar -P /opt/bitnami/spark/jars/
# wget -q https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.901/aws-java-sdk-bundle-1.11.901.jar -P /opt/bitnami/spark/jars/

# # Hive connector jars
# wget -q https://repo1.maven.org/maven2/org/apache/spark/spark-hive_2.12/3.3.0/spark-hive_2.12-3.3.0.jar -P /opt/bitnami/spark/jars/
# wget -q https://repo1.maven.org/maven2/org/apache/hive/hive-exec/3.1.3/hive-exec-3.1.3.jar -P /opt/bitnami/spark/jars/

# # PostgreSQL JDBC driver
# wget -q https://repo1.maven.org/maven2/org/postgresql/postgresql/42.3.1/postgresql-42.3.1.jar -P /opt/bitnami/spark/jars/

# # Delta Lake jars
# wget -q https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.2.0/delta-core_2.12-2.2.0.jar -P /opt/bitnami/spark/jars/
# wget -q https://repo1.maven.org/maven2/io/delta/delta-storage/2.2.0/delta-storage-2.2.0.jar -P /opt/bitnami/spark/jars/


# S3 connector jars
curl -s https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar -o /opt/bitnami/spark/jars/hadoop-aws-3.3.1.jar
curl -s https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.901/aws-java-sdk-bundle-1.11.901.jar -o /opt/bitnami/spark/jars/aws-java-sdk-bundle-1.11.901.jar

# Hive connector jars
curl -s https://repo1.maven.org/maven2/org/apache/spark/spark-hive_2.12/3.3.0/spark-hive_2.12-3.3.0.jar -o /opt/bitnami/spark/jars/spark-hive_2.12-3.3.0.jar
curl -s https://repo1.maven.org/maven2/org/apache/hive/hive-exec/3.1.3/hive-exec-3.1.3.jar -o /opt/bitnami/spark/jars/hive-exec-3.1.3.jar

# PostgreSQL JDBC driver
curl -s https://repo1.maven.org/maven2/org/postgresql/postgresql/42.3.1/postgresql-42.3.1.jar -o /opt/bitnami/spark/jars/postgresql-42.3.1.jar

# Delta Lake jars
curl -s https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.2.0/delta-core_2.12-2.2.0.jar -o /opt/bitnami/spark/jars/delta-core_2.12-2.2.0.jar
curl -s https://repo1.maven.org/maven2/io/delta/delta-storage/2.2.0/delta-storage-2.2.0.jar -o /opt/bitnami/spark/jars/delta-storage-2.2.0.jar

echo "Spark environment setup completed successfully!"
