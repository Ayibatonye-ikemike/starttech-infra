#!/bin/bash
set -e
cd terraform
terraform init
terraform apply -auto-approve
