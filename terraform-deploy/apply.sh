#!/bin/bash
echo "************* Assigning Azure credentials to Env. variables ..."
## execute terrafotm build and sendout to packer-build-output
export ARM_CLIENT_ID=$1
export ARM_CLIENT_SECRET=$2
export ARM_SUBSCRIPTION_ID=$3
export ARM_TENANT_ID=$4
export ARM_ACCESS_KEY=$5
export SSH_PUB_KEY=$6

echo "Executing Terraform Init ..."
terraform apply -auto-approve -var ssh_key=$6 
echo "Done"
