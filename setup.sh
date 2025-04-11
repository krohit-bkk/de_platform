#!/bin/bash

# ENVIRONMENT FILE
export PROJECT_ROOT=$(pwd)
envsubst < ${PROJECT_ROOT}/.env | tee ${PROJECT_ROOT}/.env.evaluated

# CREATE DIRECTORIES & PERMISSIONS
mkdir -p ${PROJECT_ROOT}/data/hive_data/{hive-tmp,hive-tmp1,lib,warehouse,sample_data} 
mkdir -p ${PROJECT_ROOT}/data/{minio_data,postgres_data,postgres_alt,postgres_airflow_data,trino_data,superset_data,spark_data} 
chmod -R 777 ${PROJECT_ROOT}/data

# Hive Server2 <-- This wont work as HS2 is not setup with HMS service
sudo mkdir -p ${PROJECT_ROOT}/data/hive_hs2_data/hive-tmp && sudo chmod -R 777 ${PROJECT_ROOT}/data/hive_hs2_data/hive-tmp
sudo mkdir -p ${PROJECT_ROOT}/data/hive_hs2_data/warehouse && sudo chmod -R 777 ${PROJECT_ROOT}/data/hive_hs2_data/warehouse

# ALIASES FOR DOCKER
alias psa='docker ps -a'
alias rma='docker rm -f $(docker ps -aq)'

# FUNCTIONS FOR DOCKER
# print networks and volume
function nv(){
  docker volume ls
  echo ""
  docker network ls
}

# Print all
function all(){
  echo ""
  docker ps -a
  echo ""
  nv
}

# STOP ALL SERVICES
function clean_all(){
  # Clean up Superset
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-superset.yml down -v
  rm -rf ${PROJECT_ROOT}/data/superset_data && mkdir -p ${PROJECT_ROOT}/data/superset_data && chmod -R 777 ${PROJECT_ROOT}/data/superset_data

  # Clean up Trino cluster
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-query.yml down -v

  # Clean up Spark cluster
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-processing.yml down -v

  # Clean up Hive - HMS HS2
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-metastore.yml down -v
  rm -rf ${PROJECT_ROOT}/data/postgres_data && mkdir -p ${PROJECT_ROOT}/data/postgres_data && chmod -R 777 ${PROJECT_ROOT}/data/postgres_data
  rm -rf ${PROJECT_ROOT}/data/postgres_alt  && mkdir -p ${PROJECT_ROOT}/data/postgres_alt  && chmod -R 777 ${PROJECT_ROOT}/data/postgres_alt
  
  # Clean up MinIO
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-storage.yml down -v
  rm -rf ${PROJECT_ROOT}/data/minio_data && mkdir -p ${PROJECT_ROOT}/data/minio_data  && chmod -R 777 ${PROJECT_ROOT}/data/minio_data

  # Clean up Base
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-base.yml down -v

  # Clean up Docker Volumes
  docker volume rm -f hive_data minio_data postgres_data postgres_alt

  # Clean up Docker Network
  docker volume rm -f data_platform_network

  # Print all
  all
}

# START ALL SERVICES
function start_all(){
  # Start up Base
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-base.yml up -d

  # Start up MinIO
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-storage.yml up -d 

  # Start up Hive - HMS HS2
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-metastore.yml up -d hive-metastore

  # Start up Spark Services
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-processing.yml up -d spark-master spark-worker-1 spark-worker-2

  # Start up Trino Services
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-query.yml up -d trino-coordinator trino-worker-1 trino-worker-2

  # Print all 
  all 
}

# RESET MinIO - To fix performance issue with Apple Silicon for Delta table 
# #########################################################################
function reset_minio(){
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-storage.yml down -v
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-storage.yml up -d minio
  psa
}

# Run minio-client to upload some sample data for Hive at location - s3a://raw-data/sample_data/
docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-storage.yml up -d minio-client && docker logs -f minio-client

# SPARK TESTING 
# #############
# Test Spark-Hive integration <-- Creates table default.sample_sales
docker rm -f spark-test && docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-processing.yml up -d spark-test && docker logs -f spark-test

# Spark-Deltalake-HMS-MinIO Integration - Hive doesn't work with Delta completely (and that's normal)
# Table would be present in HMS (and data in MinIO S3 bucket), accessible as table only from Spark or Trino 
docker rm -f delta-lake-test && docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-processing.yml up -d delta-lake-test && docker logs -f delta-lake-test

# TRINO TESTING
# #############
# Start Trino Cluster
alias start_trino='docker rm -f trino-coordinator trino-worker-1 trino-worker-2 && docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-query.yml down -v && docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-query.yml up -d trino-coordinator trino-worker-1 trino-worker-2 && docker logs -f trino-coordinator'
start_trino

# Test Trino with HMS 
alias test_trino='docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-query.yml down trino-test && docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-query.yml up -d trino-test && docker logs -f trino-test'
test_trino

# SUPERSET TESTING - Initializes the Superset server and UI available at --> http://localhost:8088/
docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-superset.yml up -d superset && docker logs -f superset

# Reset Superset
function reset_superset(){
  rm -rf ./data/superset_data && mkdir -p ./data/superset_data && chmod -R 777 ./data/superset_data
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-superset.yml down -v superset redis 
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-superset.yml up -d superset 
  docker logs -f superset
}

# TROUBLESHOOTING 
# Installing netcat and ss on HMS/HS2 to check connectivity
docker exec -it -u root hive-metastore bash 
apt update && apt install iproute2 -y && apt install netcat -y
ss -ltnp | grep 10000
nc -zv hive-metastore 9083


