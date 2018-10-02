#!/bin/bash
echo "************* Assigning Azure credentials to Env. variables ..."
## execute terrafotm build and sendout to packer-build-output
export ARM_CLIENT_ID=$1
export ARM_CLIENT_SECRET=$2
export ARM_SUBSCRIPTION_ID=$3
export ARM_TENANT_ID=$4
export ARM_ACCESS_KEY=$5

echo "Executing Terraform Init ..."
terraform init  -backend-config=backend.tfvars ./terraform-deploy
echo "Done"
