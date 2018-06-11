## Automate deployment of Redhat OpenShift on Microsoft Azure.

### A] Deploy a *non-HA* OpenShift Cluster
1. Enable the Azure DNS Private Zone feature (extension) to the Azure CLI.  This feature is currently in *Public Preview* mode.
```
# Enable the DNS private zone extension to Azure CLI
$ az extension add --name dns
```

2. Fork this [GitHub repository](https://github.com/ganrad/ocp-on-azure) to your GitHub account.  Then clone this repository (review Step 3).  Ensure that you are using the URL of your fork when cloning this repository.  Review and update the following variables in the script `scripts/provision-vms.sh` as necessary.  See below.

VAR NAME | DEFAULT VALUE | DESCRIPTION
-------- | ------------- | -----------
RG_NAME | rh-ocp39-rg | Name of the Azure Resource Group used to deploy the OpenShift Cluster
IMAGE_TYPE_MASTER | Stanrdard_B2ms | Azure VM Image Size for OpenShift master nodes
IMAGE_TYPE_INFRA | Stanrdard_B2ms | Azure VM Image Size for Infrastructure nodes
IMAGE_TYPE_NODE | Stanrdard_B2ms | Azure VM Image Size for Application nodes
VM_IMAGE | RedHat:RHEL:7.4:7.4.2018010506 | Operating system image for all VMs
OCP_DOMAIN_SUFFIX | devcls.com | Domain suffix for hostnames

After updating `provision-vms.sh`, run the script in a terminal window.  This shell script will provision all the Azure infrastructure resources required to deploy the OpenShift cluster.
```
# Clone this GitHub repository first.  If you are not familiar with GitHub, refer to instructions in Step 3 below.
# Run the script 'scripts/provision-vms.sh'.  Specify, no. of application nodes.
$ ./scripts/provision-vms.sh <no. of nodes>
```
The script should print the following message upon successful creation of all infrastructure resources.
```
All OCP infrastructure resources created OK.
```

3. Login to the Bastion host VM using SSH (Terminal window). Install *Ansible* and *Git*.
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

4. Fork this [GitHub repository](https://github.com/ganrad/ocp-on-azure) to your GitHub account.  In the terminal window connected to the Bastion host, clone this repository.  Ensure that you are using the URL of your fork when cloning this repository.
```
# Switch to home directory
$ cd
# Clone your GitHub repository.
$ git clone https://github.com/<Your-GitHub-Account>/ocp-on-azure.git
#
$ Switch to the 'ocp-on-azure/ansible-deploy' directory
$ cd ocp-on-azure/ansible-deploy/
```

5. Update `hosts` file with the IP Addresses (or DNS names) of all OpenShift nodes (Master + Infrastructure + Application).

6. Review `group_vars/ocp-servers` file and specify values for **rh_account_name**, **rh_account_pwd** & **pool_id** variables.

7. Check if Ansible is able to connect to all OpenShift nodes.
```
# Ping all OpenShift nodes.  You current directory should be 'ocp-on-azure/ansible-deploy' directory.
$ ansible -i hosts all -m ping
```

8. Run syntax check on ansible playbook.  If there are any errors, fix them before proceeding.
```
# Ensure you are in sub-directory 'ansible-deploy'.  If not, switch to this directory.
$ cd ansible-deploy
#
# Check the syntax of commands in the playbook
$ ansible-playbook -i hosts install.yml --syntax-check
```

9. Run the Ansible playbook `install.yml`.  This command will run for a while (~ 20 mins for 3 nodes).
```
# Run the Ansible playbook
$ ansible-playbook -i hosts -v install.yml
```
The `ansible-playbook` command should provide a count of all commands successfully executed (ok), changed and failed for each OpenShift node. If the number assigned to **failed** is non-zero, then re-run the script until all commands are executed successfully. Sample output pasted below.
```
PLAY RECAP *********************************************************************************************************************************
ocp-infra.devcls.com       : ok=14   changed=7    unreachable=0    failed=0   
ocp-master.devcls.com      : ok=14   changed=12   unreachable=0    failed=0   
ocp-node1.devcls.com       : ok=14   changed=7    unreachable=0    failed=0
```

10. Login via SSH to the OpenShift **master** node.  The OpenShift installer (Ansible playbook) will be run on this OpenShift master node.  Make sure you are able to login in to all nodes using SSH.  Before proceeding with OpenShift installation, check the following -
- All nodes should be resolvable thru their DNS aliases within the VNET (ocpVnet)
- Passwordless **sudo** access should be configured on all nodes (VMs)

11. Download the Ansible hosts (**ocp-hosts**) file from the `ocp-on-azure` GitHub repository which you forked in a previous step.  You can use **wget** or **curl** to download this file.  See below.
```
# Download the ansible hosts file. Substitute your GitHub account name in the command below.
$ wget https://raw.githubusercontent.com/<YOUR_GITHUB_ACCOUNT>/ocp-on-azure/master/scripts/ocp-hosts
```
Review the **ocp-hosts** file and update the hostnames for the OpenShift master, infrastructure and application nodes.

12. Run the Ansible OpenShift installer playbooks.
```
# Run the 'prerequisites.yml' playbook
$ ansible-playbook -i ./ocp-hosts /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
# Run the 'deploy_cluster.yml' playbook
$ ansible-playbook -i ./ocp-hosts /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
```
