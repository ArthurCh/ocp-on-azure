#!/bin/bash
echo "************* Assigning Azure credentials to env. variables ..."
## execute terrafotm build and sendout to packer-build-output
export ARM_CLIENT_ID=$2
export ARM_CLIENT_SECRET=$3
export ARM_SUBSCRIPTION_ID=$4
export ARM_TENANT_ID=$5
export ARM_ACCESS_KEY=$6
echo "ARM_ACCESS_KEY=$ARM_ACCESS_KEY"
export SSH_PUB_KEY=$7

cd $1
echo "Switched directory to => $1"
echo "Dir list => " | ls -l

echo "Executing Terraform Init ..."
terraform apply -auto-approve -var ssh_key=$7
echo "Done"
