## Automation scripts for deploying Redhat OpenShift on Azure.

1. Review and run the script `scripts/provision-vms.sh`.

2. Login to the Bastion host VM. Install ansible and git.
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
