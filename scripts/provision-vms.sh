#!/bin/bash

# ID06102018: Created by ganesh.radhakrishnan@microsoft.com

set -e

if [ $# -le 0 ]; then
  echo -e "\n\tUsage: provision-vms.sh <NO. of OCP Nodes>"
  echo -e "\tMissing argument : No. of OCP nodes!\n"
  exit 1
fi

# Configure the variables below
RG_NAME="rh-ocp39-rg"
RG_LOCATION="westus"
IMAGE_SIZE_MASTER="Standard_B2ms"
IMAGE_SIZE_NODE="Standard_B2ms"
IMAGE_SIZE_INFRA="Standard_B2ms"
VM_IMAGE="RedHat:RHEL:7.4:7.4.2018010506"
OCP_DOMAIN_SUFFIX="devcls.com"

echo "Provisioning Azure resources for OpenShift CP non-HA cluster..."

# Create Azure resource group
echo "Creating Azure resource group..."
az group create --name $RG_NAME --location $RG_LOCATION

# Create the VNET and Subnet
echo "Creating the VNET and Subnet..."
az network vnet create --resource-group $RG_NAME --name ocpVnet --address-prefix 192.168.0.0/16 --subnet-name ocpSubnet --subnet-prefix 192.168.122.0/24

# Create a private DNS Zone and register with VNET
echo "Creating private DNS Zone to resolve IPs in ocpVnet..."
az network dns zone create -g $RG_NAME --name devcls.local --zone-type private --registration-vnets ocpVnet

# Create the public ip for the bastion host
echo "Creating the public ip for the bastion host..."
az network public-ip create -g $RG_NAME --name ocpBastionPublicIP --dns-name ocp-bastion

# Create the public ip for the ocp master host
echo "Creating the public ip for the OCP master host..."
az network public-ip create -g $RG_NAME --name ocpMasterPublicIP --dns-name ocp-master

# Create the public ip for the ocp infra host
echo "Creating the public ip for the OCP infra host..."
az network public-ip create -g $RG_NAME --name ocpInfraPublicIP --dns-name ocp-infra

# Create the network security group for bastion host
echo "Creating the network security group for bastion host..."
az network nsg create -g $RG_NAME --name ocpBastionSecurityGroup

# Create the network security group for ocp master
echo "Creating the network security group for ocp master..."
az network nsg create -g $RG_NAME --name ocpMasterSecurityGroup

# Create the network security group for ocp infra
echo "Creating the network security group for ocp infra. node..."
az network nsg create -g $RG_NAME --name ocpInfraSecurityGroup

# Create the NSG rule for SSH access for bastion host
echo "Creating the NSG rule for SSH access for bastion host..."
az network nsg rule create -g $RG_NAME --nsg-name ocpBastionSecurityGroup --name ocpSecurityGroupRuleSSH --protocol tcp --priority 1000 --destination-port-range 22 --access allow

# Create the NSG rule for SSH access for master node
# echo "Creating the NSG rule for SSH access for master node..."
# az network nsg rule create -g $RG_NAME --nsg-name ocpMasterSecurityGroup --name ocpSecurityGroupRuleSSH --protocol tcp --priority 1000 --destination-port-range 22 --access allow
echo "Creating the NSG rule for API access for master node..."
az network nsg rule create -g $RG_NAME --nsg-name ocpMasterSecurityGroup --name ocpSecurityGroupRuleAPI --protocol tcp --priority 900 --destination-port-range 443 --access allow
echo "Creating the NSG rule for RHEL Cockpit Web UI access from master node..."
az network nsg rule create -g $RG_NAME --nsg-name ocpMasterSecurityGroup --name ocpSecurityGroupRuleCP --protocol tcp --priority 1000 --destination-port-range 9090 --access allow

# echo "Creating the NSG rule for APP access for infra node..."
az network nsg rule create -g $RG_NAME --nsg-name ocpInfraSecurityGroup --name ocpSecurityGroupRuleAppSSL --protocol tcp --priority 1000 --destination-port-range 443 --access allow
az network nsg rule create -g $RG_NAME --nsg-name ocpInfraSecurityGroup --name ocpSecurityGroupRuleApp --protocol tcp --priority 2000 --destination-port-range 80 --access allow

# Create the NIC for Bastion host
echo "Creating NIC for Bastion Host..."
az network nic create -g $RG_NAME --name bastionNIC --vnet-name ocpVnet --subnet ocpSubnet --public-ip-address ocpBastionPublicIP --network-security-group ocpBastionSecurityGroup

# Create the NIC for OCP master host
echo "Creating NIC for OCP master Host..."
az network nic create -g $RG_NAME --name masterNIC --vnet-name ocpVnet --subnet ocpSubnet --public-ip-address ocpMasterPublicIP --network-security-group ocpMasterSecurityGroup

# Create the NIC for OCP infra host
echo "Creating NIC for OCP infra Host..."
az network nic create -g $RG_NAME --name infraNIC --vnet-name ocpVnet --subnet ocpSubnet --public-ip-address ocpInfraPublicIP --network-security-group ocpInfraSecurityGroup

# Create the availability set
echo "Creating the availability set..."
az vm availability-set create -g $RG_NAME --name ocpAvailabilitySet

# Create the Bastion Host VM
echo "Creating the bastion host VM..."
az vm create -g $RG_NAME --name ocp-bastion.$OCP_DOMAIN_SUFFIX --location $RG_LOCATION --availability-set ocpAvailabilitySet --nics bastionNIC --image $VM_IMAGE --size $IMAGE_SIZE_MASTER --admin-username ocpuser --ssh-key-value ~/.ssh/id_rsa.pub

# Create the OCP Master VM
echo "Creating the OCP Master VM..."
az vm create -g $RG_NAME --name ocp-master.$OCP_DOMAIN_SUFFIX --location $RG_LOCATION --availability-set ocpAvailabilitySet --nics masterNIC --image $VM_IMAGE --size $IMAGE_SIZE_MASTER --admin-username ocpuser --ssh-key-value ~/.ssh/id_rsa.pub

# Create the OCP Infra VM
echo "Creating the OCP Infra VM..."
az vm create -g $RG_NAME --name ocp-infra.$OCP_DOMAIN_SUFFIX --location $RG_LOCATION --availability-set ocpAvailabilitySet --nics infraNIC --image $VM_IMAGE --size $IMAGE_SIZE_INFRA --admin-username ocpuser --ssh-key-value ~/.ssh/id_rsa.pub

# Create the OCP Node VMs...
echo "OCP node count=[$1]..."
i=1
while [ $i -le $1 ]
do
  echo "Creating OCP Node VM $i..."
  az vm create -g $RG_NAME --name "ocp-node$i.$OCP_DOMAIN_SUFFIX" --location $RG_LOCATION --vnet-name ocpVnet --subnet ocpSubnet --availability-set ocpAvailabilitySet --image $VM_IMAGE --size $IMAGE_SIZE_NODE --admin-username ocpuser --ssh-key-value ~/.ssh/id_rsa.pub --public-ip-address ""
  i=$(( $i + 1 ))
done

echo "All OCP infrastructure resources created OK."
