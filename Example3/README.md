# Using Ansible

This adds on to [Example2](../Example2/README.md). This rename *workers* to *nodes* and adds a user to the *nodes* \(they must exist on the Ansible master\). Install **Ansible** as before.


```bash
sudo yum install python3-pip -y
pip3 install ansible
```

Example *ansible.cfg*:

```ini
[defaults]
fact_caching = ansible.builtin.jsonfile
fact_caching_connection = /tmp/ansible_facts
cache_timeout = 3600

[inventory]
cache = yes
cache_connection = /tmp/ansible_inventory
```

## Setup

Basically, the same as Example2. Copy the *terraform.tfvars.example* file to
*terraform.tfvars* and update the variables. You also need to modify the
policy and add the following:

### Terreaform Apply

```bash
terraform init
# terraform init -upgrade # if we changed things
terraform validate
terraform import aws_instance.bastion <instance-id>
terraform plan
terraform apply
# Wait until everything is up and running
ssh -F ./local/ssh.cfg node-00000
aws --version
# aws-cli/2.33.15 Python/3.9.25 Linux/6.1.177-224.371.amzn2023.x86_64 source/x86_64.amzn.2023
```

### Ansible

If using a new Amazon Linux instatance, this probably is not need:

```bash
./local/ansible/run-ansible.sh
ssh -F ./local/ssh.cfg node-00000
aws --version
# aws-cli/2.33.15 Python/3.9.25 Linux/6.1.177-224.371.amzn2023.x86_64 source/x86_64.amzn.2023
aws sts get-caller-identity
aws s3 ls s3://{{ bucket }}
exit
```

Add local user \(example for Amazon Linux\):

```bash
sudo adduser appuser
# Verify the directory creation
sudo ls -la /home/appuser
```

Run ansible script to add user on *nodes*:

```bash
ansible-galaxy collection list
# install if missing
ansible-galaxy collection install community.crypto ansible.posix
./local/ansible/run-adduser.sh appuser
```

Check

```bash
sudo su - appuser
ssh 
```

### Terreaform Destroy

To remove instances that Terraform made:

```bash
# Remove the bastion instance from Terraform state (it doesn't delete it from AWS)
terraform state rm aws_instance.bastion
# Destroy everything else
terraform destroy
# Re-import the bastion instance back into state
terraform import aws_instance.bastion <instance-id>
```