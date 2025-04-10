#!/bin/bash

# ENVIRONMENT FILE
export PROJECT_ROOT=$(pwd)
envsubst < ${PROJECT_ROOT}/.env | tee ${PROJECT_ROOT}/.env.evaluated

# CREATE DIRECTORIES & PERMISSIONS
mkdir -p ${PROJECT_ROOT}/data/hive_data/{hive-tmp,hive-tmp1,lib,warehouse,sample_data} 
mkdir -p ${PROJECT_ROOT}/data/{minio_data,postgres_data,postgres_alt,postgres_airflow_data,trino_data,superset_data,spark_data} 
chmod -R 777 ${PROJECT_ROOT}/data

# Hive Server2
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
  docker ps -a
  echo ""
  nv
}

# Clean Setup
function clean_all(){
  # Clean up Hive - HMS & HS2
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-metastore.yml down -v
  rm -rf ${PROJECT_ROOT}/postgres_data && mkdir -p ${PROJECT_ROOT}/postgres_data && chmod -R 777 ${PROJECT_ROOT}/postgres_data
  rm -rf ${PROJECT_ROOT}/postgres_alt  && mkdir -p ${PROJECT_ROOT}/postgres_alt  && chmod -R 777 ${PROJECT_ROOT}/postgres_alt
  
  # Clean up MinIO
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-storage.yml down -v
  rm -rf ${PROJECT_ROOT}/minio_data

  # Clean up Base
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-base.yml down -v

  # Clean up Docker Volumes
  docker volume rm -f hive_data minio_data postgres_data postgres_alt

  # Clean up Docker Network
  docker volume rm -f data_platform_network
}

# Start Setup
function start_all(){
  # Start up Base
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-base.yml up -d

  # Start up MinIO
  docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-storage.yml up -d

  # Start up Hive - HMS & HS2
  # docker-compose --env-file .env.evaluated -f ./docker-compose/docker-compose-storage.yml up -d
}