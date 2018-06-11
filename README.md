## Automate deployment of Redhat OpenShift on Microsoft Azure.

### A] Deploy a *non-HA* OpenShift Cluster
1. Fork this [GitHub repository](https://github.com/ganrad/ocp-on-azure) to your GitHub account.  Then clone this repository (review Step 3).  Ensure that you are using the URL of your fork when cloning this repository.  Review and update the following variables in the script `scripts/provision-vms.sh` as necessary.  See below.

VAR NAME | DEFAULT VALUE | DESCRIPTION
-------- | ------------- | -----------
RG_NAME | rh-ocp39-rg | Name of the Azure Resource Group used to deploy the OpenShift Cluster
IMAGE_TYPE_MASTER | Stanrdard_B2ms | Azure VM Image Size for OpenShift master nodes
IMAGE_TYPE_INFRA | Stanrdard_B2ms | Azure VM Image Size for Infrastructure nodes
IMAGE_TYPE_NODE | Stanrdard_B2ms | Azure VM Image Size for Application nodes
VM_IMAGE | RedHat:RHEL:7.4:7.4.2018010506 | Operating system image for all VMs
OCP_DOMAIN_SUFFIX | example.com | Domain suffix for hostnames

After updating `provision-vms.sh`, run the script in a terminal window.
```
# Clone this GitHub repository first.  If you are not familiar with GitHub, refer to instructions in Step 3 below.
# Run the script 'scripts/provision-vms.sh'
$ ./scripts/provision-vms.sh
```

2. Login to the Bastion host VM. Install *Ansible* and *Git*.
```
# Login to Bastion host via SSH.  Substitute the IP Address of the DNS name of the Bastion host.
$ ssh ocpuser@<Public IP Address / DNS name of Bastion Host>
#
# Install ansible
$ sudo yum install ansible
#
# Install git
$ sudo yum install git
#
$ ansible --version
$ git --version
```

3. Fork this [GitHub repository](https://github.com/ganrad/ocp-on-azure) to your GitHub account.  In the terminal window connected to the Bastion host, clone this repository.  Ensure that you are using the URL of your fork when cloning this repository.
```
# Switch to home directory
$ cd
# Clone your GitHub repository.
$ git clone https://github.com/<Your-GitHub-Account>/k8s-springboot-data-rest.git
#
$ Switch to the 'ocp-on-azure' directory
$ cd ocp-on-azure
```

4. Update `hosts` file with the IP Addresses (or DNS names) of all OpenShift nodes (Master + Infrastructure + Application).

5. Review `ansible-deploy/group_vars/ocp-servers` file and specify values for **rh_account_name**, **rh_account_pwd** & **pool_id** variables.

6. Check if Ansible is able to connect to all OpenShift nodes.
```
# Ping all OpenShift nodes.  You current directory should be 'ocp-on-azure' directory.
$ ansible -i hosts all -m ping
```

7. Switch to sub-directory `ansible-deploy` and then run syntax check on playbook.  If there are any errors, fix them before proceeding.
```
# Switch to sub-directory 'ansible-deploy'
$ cd ansible-deploy
#
# Check the syntax of commands in the playbook
$ ansible-playbook -i hosts install.yml --syntax-check
```

8. Run the Ansible playbook `install.yml`.
```
# Run the Ansible playbook
$ ansible-playbook -i hosts -vv install.yml
```

9. Login via SSH to the OpenShift master node.
