# Using Ansible

This adds on to [Example1](../Example1/README.md). This creates a worker instance controled by the bastion by [Ansible](https://docs.ansible.com/). Ansible automates tasks on managed nodes or “hosts” in your infrastructure by using a list or group of lists known as inventory. Ansible composes its inventory from one or more '*inventory sources*'. While one of these sources can be the list of host names you pass at the command line, most Ansible users create inventory files. Your inventory defines the managed nodes you automate and the variables associated with those hosts. You can also specify groups. Groups allow you to reference multiple associated hosts to target for your automation or to define variables in bulk. 

Some \(or all of this\) Terraform can do, but this show how to use Ansible.

On the bastion \(Amazon Linux\), you should be able to install it like:

```bash
sudo yum install python3-pip -y
pip3 install ansible
```

We store these under *./local/ansible/inventory/* in basic **YAML** format.

Can use mustash in ansile for vars

```text
ansible/
├── ansible.cfg                 # Ansible configuration file
├── inventory/                  # Inventory files
│   ├── production.yml
│   ├── staging.yml
│   └── development.yml
├── group_vars/                 # Group-level variables
│   ├── all.yml
│   ├── webservers.yml
│   └── databases.yml
├── host_vars/                  # Host-specific variables
│   ├── web01.example.com.yml
│   └── db01.example.com.yml
├── roles/                      # Reusable roles
│   ├── common/
│   │   ├── defaults/
│   │   │   └── main.yml
│   │   ├── files/
│   │   ├── handlers/
│   │   │   └── main.yml
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   ├── templates/
│   │   └── vars/
│   │       └── main.yml
│   └── database/
│       └── [same structure as above]
├── playbooks/                  # Top-level playbooks
│   ├── site.yml
│   ├── webservers.yml
│   ├── databases.yml
│   └── deploy/
│       ├── app.yml
│       └── rollback.yml
├── files/                      # Shared files
│   └── config_templates/
├── templates/                  # Shared templates
│   └── nginx.conf.j2
└── README.md                   # Project documentation
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

Basically the same as Example1. Copy the *terraform.tfvars.example* file to
*terraform.tfvars* and update the variables. You also need to modify the
policy and add the following:

```json
                "iam:AddRoleToInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:GetRole",
                "iam:RemoveRoleFromInstanceProfile",
```

```bash
terraform init
# terraform init -upgrade # if we changed things
terraform import aws_instance.bastion <instance-id>
terraform validate
terraform plan
terraform apply
# Wait until everything is up and running
ssh -F ./local/ssh.cfg worker-00
aws --version
# aws-cli/2.33.15 Python/3.9.25 Linux/6.1.177-224.371.amzn2023.x86_64 source/x86_64.amzn.2023
./local/ansible/run-ansible.sh
ssh -F ./local/ssh.cfg worker-00
aws --version
# aws-cli/2.33.15 Python/3.9.25 Linux/6.1.177-224.371.amzn2023.x86_64 source/x86_64.amzn.2023
aws sts get-caller-identity
aws s3 ls s3://{{ bucket }}
exit

# Remove the bastion instance from Terraform state (it doesn't delete it from AWS)
terraform state rm aws_instance.bastion
# Destroy everything else
terraform destroy
# Re-import the bastion instance back into state
terraform import aws_instance.bastion <instance-id>
```