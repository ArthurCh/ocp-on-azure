#!/bin/bash
echo "************* Assigning Azure credentials to Env. variables ..."
## execute terrafotm build and sendout to packer-build-output
export ARM_CLIENT_ID=$2
echo "ARM_CLIENT_ID=$ARM_CLIENT_ID"
export ARM_CLIENT_SECRET=$3
export ARM_SUBSCRIPTION_ID=$4
export ARM_TENANT_ID=$5
export ARM_ACCESS_KEY=$6

cd $1/terraform-deploy/azurerm
echo "Switched directory to => $PWD"

echo "Executing Terraform Init ..."
terraform init -backend-config=backend.tfvars
echo "Done"
