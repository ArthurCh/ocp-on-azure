#!/bin/bash

export SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDorGGHqJu/q/5/VkeWWSTBVD5Z7W3sXFQXVEaNcyMd09TIO0ZwKutPlxpk69F1/d3udVnqBOldF5QWCTvs0zNalM+GHPk2Az1t0caKyoD211rSYvz6k+mebN/zoL7u/DPCG07EKGO3qzJ5w73XZ4hbQe0N82VVo2iHoAJMpCfwqE4AKMArxgw6o3OnFiD+zv+6Yd/vMQ0l/JEqiWwGxWQzV1zCD1l6d/ZxXcuDZBP9FDvw688fZn4ha8jOguMkKBfMJgurTk/enEfuPSJTpm7Sc4KUwrbfsYjoernIawd//7lPx4FaakxSJKhGsRyNrh49dJJ/zugb3qmxFd7962o7 ganrad01@gmail.com"
echo "set-env.sh : SSH_PUBLIC_KEY=$SSH_PUBLIC_KEY"

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
export KEY_VAULT_NAME="OCP310-KV"
echo "set-env.sh : KEY_VAULT_NAME=$KEY_VAULT_NAME"
