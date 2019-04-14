#!/usr/bin/env bash

##------------------------------------------------------------------------------
## Script used for gitlab-ci to rebuild the environment when a new commit is
## made on the branch master
## --
## This will rebuild the docker environment and restart everything.
##------------------------------------------------------------------------------

cd /opt/application
git reset --hard
git pull

cd /opt/docker
echo "VERSION=$(date +\%Y-\%m-\%d_\%H\%M\%S)" > .env

docker-compose build
docker-compose stop
docker-compose up -d
