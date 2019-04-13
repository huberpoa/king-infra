#!/usr/bin/env bash

cd /opt/docker

echo "VERSION=$1" > .env

docker-compose build
docker-compose up -d
