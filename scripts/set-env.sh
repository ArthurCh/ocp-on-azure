#!/bin/bash

export SSH_PUBLIC_KEY=$1

export OCP_RG_NAME="rh-ocp310-rg"
echo "set-env.sh : OCP_RG_NAME=$OCP_RG_NAME"
export IMAGE_SIZE_MASTER="Standard_B1ms"
echo "set-env.sh : IMAGE_SIZE_MASTER=$IMAGE_SIZE_MASTER"
export IMAGE_SIZE_NODE="Standard_B1ms"
echo "set-env.sh : IMAGE_SIZE_NODE=$IMAGE_SIZE_NODE"
export IMAGE_SIZE_INFRA="Standard_B1ms"
echo "set-env.sh : IMAGE_SIZE_INFRA=$IMAGE_SIZE_INFRA"
export VNET_NAME="ocp310Vnet"
echo "set-env.sh : VNET_NAME=$VNET_NAME"
export SUBNET_NAME="ocp310Subnet"
echo "set-env.sh : SUBNET_NAME=$SUBNET_NAME"
