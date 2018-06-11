# ID06102018: Created by ganesh.radhakrishnan@microsoft.com

# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=ocpuser

# If ansible_ssh_user is not root, ansible_become must be set to true
ansible_become=true

openshift_deployment_type=openshift-enterprise
openshift_disable_check=disk_availability,docker_storage,memory_availability
openshift_clock_enabled=true

openshift_master_default_subdomain=ocp39.westus.cloudapp.azure.com
openshift_hosted_logging_deploy=true
openshift_hosted_metrics_deploy=true

# Enable htpasswd authentication; defaults to DenyAllPasswordIdentityProvider
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]

# Host group for masters
[masters]
ocp-master.westus.cloudapp.azure.com

# Host group for nodes, includes region info
[nodes]
ocp-master.westus.cloudapp.azure.com openshift_schedulable=true openshift_node_labels="{'region': 'primary', 'zone': 'west'}"
ocp-infra.westus.cloudapp.azure.com openshift_node_labels="{'region': 'infra', 'zone': 'default'}"
ocp-node1.westus.cloudapp.azure.com openshift_node_labels="{'region': 'primary', 'zone': 'west'}"
