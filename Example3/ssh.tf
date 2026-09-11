# This writes files under local for ssh access.
# Generate keys per user in Ansible, not Terraform

locals {
  ssh_key_rsa = "${path.module}/local/pki/bastion.rsa" # private
  ssh_key_pub =  "${path.module}/local/pki/bastion.pub"
  ssh_cfg_file = "${local.absolute_path}/local/ssh.cfg"   # used in Ansile scripts

  # connection details (mapped from instances)
  bastion_public_ip = aws_instance.bastion.public_ip
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Save private SSH key locally on the bastion
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = local.ssh_key_rsa
  file_permission = "0600"
}

# Save public SSH key locally
resource "local_file" "ssh_public_key" {
  content         = tls_private_key.ssh_key.public_key_openssh
  filename        = local.ssh_key_pub
  file_permission = "0600"
}

# register the public ssh key with aws
resource "aws_key_pair" "cluster_key" {
  key_name   = "cluster-ssh-key"
  
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "ssh_config" {
  filename        = local.ssh_cfg_file
  file_permission = "0600" # Read/Write for owner only (required by SSH)

  content  = templatefile("${path.module}/ssh_cfg.tftpl", {
      nodes = local.nodes,
      ssh_key_rsa = abspath(local.ssh_key_rsa),
      ansible_user = var.tf_user
  })
}

output "ssh_connection_command" {
  value       = "ssh -F ${local.ssh_cfg_file} node-00001"
  description = "Run this command in your terminal to jump into your private node-00001!"
}
