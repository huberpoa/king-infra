#!/usr/bin/env bash

cd terraform/gcp
terraform init
terraform plan
terraform apply
