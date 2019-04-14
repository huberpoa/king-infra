#!/usr/bin/env bash

##------------------------------------------------------------------------------
## Script used for gitlab-ci to rebuild the environment when a new version is
## available
## --
## Run this script with the version of the application then it will rebuild the
## docker environment and restart everything.
## --
## If no parameter is entered, the script will only restart the docker
## environment
##------------------------------------------------------------------------------

cd /opt/docker

if [[ $1 ]]; then
  echo "VERSION=$1" > .env

  docker-compose build
  docker-compose restart
else
  docker-compose restart
fi
