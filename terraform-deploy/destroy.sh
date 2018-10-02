#!/bin/bash
echo "Current working directory => $PWD"

echo "Executing Terraform Destroy ..."
terraform destroy -auto-approve
echo "Done"
