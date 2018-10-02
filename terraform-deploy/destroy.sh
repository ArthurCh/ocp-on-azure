#!/bin/bash
cd $1/terraform-deploy/azurerm
echo "Switched directory to => $PWD"

echo "Executing Terraform Destroy ..."
terraform destroy
echo "Done"
