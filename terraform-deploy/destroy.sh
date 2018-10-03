#!/bin/bash
echo "************* Assigning Azure credentials to env. variables ..."
export ARM_CLIENT_ID=$1
export ARM_CLIENT_SECRET=$2
export ARM_SUBSCRIPTION_ID=$3
export ARM_TENANT_ID=$4
export ARM_ACCESS_KEY=$5
echo "Current working directory => $PWD"

echo "Executing Terraform Destroy ..."
# Provide a dummy value for ssh_key variable!
terraform destroy -auto-approve -var ssh_key="xyz"
echo "Done"
