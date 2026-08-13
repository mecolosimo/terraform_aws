# This writes files under local for ssh access.

locals {
  ssh_key_rsa = "${path.module}/local/pki/bastion.rsa" # private
  ssh_key_pub =  "${path.module}/local/pki/bastion.pub"
  ssh_cfg_file = "${path.module}/local/ssh.cfg"

  # connection details (mapped from instances)
  bastion_public_ip = aws_instance.bastion.public_ip
  worker_ip = aws_instance.private_worker.private_ip
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

  content = <<EOF

# Global SSH Defaults
Host *
    IdentityFile ${local.ssh_key_rsa}
    User ec2-user
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host worker
    HostName ${aws_instance.private_worker.private_ip}
EOF
}

output "ssh_connection_command" {
  value       = "ssh -F ${local.ssh_cfg_file} worker"
  description = "Run this exact command in your terminal to jump straight into your private instance!"
}
