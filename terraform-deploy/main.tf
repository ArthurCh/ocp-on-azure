# Author : Ganesh Radhakrishnan (garadha@microsoft.com)
# Dated  : 10-01-2018
# Description:  This configuration file describes the infrastructure resources to be deployed on Azure for running Red Hat OpenShift CP.
#
# NOTES:
#

# Configure the Azure Resource Provider
provider "azurerm" {}

# Create a resource group
resource "azurerm_resource_group" "ocp_rg" {
	name = "${var.ocp_rg_name}"
	location = "${var.ocp_rg_location}"

	tags {
		CreatedBy = "${var.user_name}"
		environment = "${var.env_name}"
	}
}

# Create the VNET for OpenShift CP
resource "azurerm_virtual_network" "ocp_vnet" {
	name = "${var.ocp_vnet_name}"
	location = "${azurerm_resource_group.ocp_rg.location}"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	address_space = ["${var.vnet_addr_prefix}"]

	tags {
		CreatedBy = "${var.user_name}"
	}
}

# Create the Subnet
resource "azurerm_subnet" "ocp_vnet_subnet" {
	name = "${var.ocp_subnet_name}"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	virtual_network_name = "${azurerm_virtual_network.ocp_vnet.name}"
	address_prefix = "${var.subnet_addr_prefix}"
}

# Create Public IP for the OCP Master host
resource "azurerm_public_ip" "ocp_master_public_ip" {
	name = "ocpMasterPublicIP"
	location = "${azurerm_resource_group.ocp_rg.location}"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	public_ip_address_allocation = "static"
	domain_name_label = "${var.ocp_master_host}"

	tags {
		CreatedBy = "${var.user_name}"
	}
}

# Create Public IP for the OCP Infra host
resource "azurerm_public_ip" "ocp_infra_public_ip" {
	name = "ocpInfraPublicIP"
	location = "${azurerm_resource_group.ocp_rg.location}"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	public_ip_address_allocation = "static"
	domain_name_label = "${var.ocp_infra_host}"

	tags {
		CreatedBy = "${var.user_name}"
	}
}

# Create NSG for OCP Master Node
resource "azurerm_network_security_group" "ocp_master_nsg" {
	name = "ocpMasterSecGroup"
	location = "${azurerm_resource_group.ocp_rg.location}"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"

	tags {
		CreatedBy = "${var.user_name}"
	}
}

# Create NSG for OCP Infra Node
resource "azurerm_network_security_group" "ocp_infra_nsg" {
	name = "ocpInfraSecGroup"
	location = "${azurerm_resource_group.ocp_rg.location}"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"

	tags {
		CreatedBy = "${var.user_name}"
	}
}

# Create NSG rule for API access for Master Node
resource "azurerm_network_security_rule" "ocp_nsg_rule_api" {
	name = "ocpSecGroupRuleApi"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	network_security_group_name = "${azurerm_network_security_group.ocp_master_nsg.name}"
	protocol = "Tcp"
	priority = 900
	direction = "Inbound"
	source_port_range ="*"
	destination_port_range = 443
	source_address_prefix = "*"
	destination_address_prefix = "*"
	access = "Allow"
}

# Create NSG rule for Cockpit Web UI access from Master Node
resource "azurerm_network_security_rule" "ocp_nsg_rule_ck_api" {
	name = "ocpSecGroupRuleCp"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	network_security_group_name = "${azurerm_network_security_group.ocp_master_nsg.name}"
	protocol = "Tcp"
	priority = 1000
	direction = "Inbound"
	source_port_range ="*"
	destination_port_range = 9090
	source_address_prefix = "*"
	destination_address_prefix = "*"
	access = "Allow"
}

# Create NSG rule for APP access for Infra Node
resource "azurerm_network_security_rule" "ocp_nsg_rule_app" {
	name = "ocpSecGroupRuleApp"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	network_security_group_name = "${azurerm_network_security_group.ocp_infra_nsg.name}"
	protocol = "Tcp"
	priority = 2000
	direction = "Inbound"
	source_port_range ="*"
	destination_port_range = 80
	source_address_prefix = "*"
	destination_address_prefix = "*"
	access = "Allow"
}

# Create NSG rule for App access (SSL) for Infra Node
resource "azurerm_network_security_rule" "ocp_nsg_rule_app_ssl" {
	name = "ocpSecGroupRuleAppSsl"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	network_security_group_name = "${azurerm_network_security_group.ocp_infra_nsg.name}"
	protocol = "Tcp"
	priority = 1000
	direction = "Inbound"
	source_port_range ="*"
	destination_port_range = 443
	source_address_prefix = "*"
	destination_address_prefix = "*"
	access = "Allow"
}

# Create NIC for Master Host
resource "azurerm_network_interface" "ocp_master_nic" {
	name = "ocpMasterNic"
	location = "${azurerm_resource_group.ocp_rg.location}"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	network_security_group_id ="${azurerm_network_security_group.ocp_master_nsg.id}"

	ip_configuration {
		name = "masterIPConfig"
		subnet_id = "${azurerm_subnet.ocp_vnet_subnet.id}"
		public_ip_address_id = "${azurerm_public_ip.ocp_master_public_ip.id}"
		private_ip_address_allocation = "dynamic"
	}
	
	tags {
		CreatedBy = "${var.user_name}"
	}
}

# Create NIC for Infrastructure Host
resource "azurerm_network_interface" "ocp_infra_nic" {
	name = "ocpInfraNic"
	location = "${azurerm_resource_group.ocp_rg.location}"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	network_security_group_id ="${azurerm_network_security_group.ocp_infra_nsg.id}"

	ip_configuration {
		name = "infraIPConfig"
		subnet_id = "${azurerm_subnet.ocp_vnet_subnet.id}"
		public_ip_address_id = "${azurerm_public_ip.ocp_infra_public_ip.id}"
		private_ip_address_allocation = "dynamic"
	}
	
	tags {
		CreatedBy = "${var.user_name}"
	}
}

resource "azurerm_availability_set" "ocp_availability_set" {
	name = "ocpAvailabilitySet"
	location = "${azurerm_resource_group.ocp_rg.location}"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	managed = true

	tags {
		CreatedBy = "${var.user_name}"
		environment = "${var.env_name}"
	}
}

resource "azurerm_virtual_machine" "ocp_master_vm" {
	name = "${var.ocp_master_host}.${var.ocp_domain_suffix}"
	location = "${azurerm_resource_group.ocp_rg.location}"
	resource_group_name = "${azurerm_resource_group.ocp_rg.name}"
	network_interface_ids = ["${azurerm_network_interface.ocp_master_nic.id}"]
	availability_set_id = "${azurerm_availability_set.ocp_availability_set.id}"
	vm_size = "${var.image_size_master}"

	storage_image_reference {
		publisher = "RedHat"
		offer = "RHEL"
		sku = "7-RAW"
		version = "latest"
	}
	
	storage_os_disk {
		name = "ocpdisk1"
		caching = "ReadWrite"
		create_option = "FromImage"
		managed_disk_type = "Standard_LRS"
	}

	os_profile {
		computer_name = "${var.ocp_master_host}.${var.ocp_domain_suffix}"
		admin_username = "ocpuser"
		# admin_password = "openshift310"
	}

	os_profile_linux_config {
		disable_password_authentication = true
		ssh_keys {
			# key_data = "${file("~/.ssh/id_rsa.pub")}"
			key_data = "${var.ssh_key}"
			path = "/home/ocpuser/.ssh/authorized_keys"
		}
	}

	tags {
		CreatedBy = "${var.user_name}"
		environment = "${var.env_name}"
	}
}
