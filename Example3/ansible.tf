# This sets up ansible under ./local/ansible/

locals {
  inventory_file = "${path.module}/local/ansible/inventory/production.yml"
  group_vars = "${path.module}/local/ansible/inventory/group_vars/all.yml"
  playbook_file = "${path.module}/local/ansible/playbooks/site.yml"
  run_ansible = "${path.module}/local/ansible/run-ansible.sh"
  run_adduser = "${path.module}/local/ansible/run-adduser.sh"

  inventory = {
    all = {
      vars = {
        ansible_ssh_common_args = "-F ${local.ssh_cfg_file} -C -o ControlMaster=auto -o ControlPersist=60s"
      }
      children = {
        nodes = {
          vars = {
            ansible_user = "${var.tf_user}"
          }
          hosts = {
            for name, instance in local.nodes : name => {}
          }
        }
      }
    }
  }
}

# Only have one inventory file
resource "local_file" "inventory" {
  filename = local.inventory_file
  content  = yamlencode(local.inventory)
}

# Put under inventory
resource "local_file" "group_vars" {
  filename = local.group_vars

  content  = templatefile("${path.module}/ansible/inventory/group_vars/all.yml.tftpl", {
    aws_region = var.aws_region
  })
}

# Only have one playbook file
resource "null_resource" "copy_files_playbooks" {
  # Use heredoc syntax (<<-EOF) for multi-line strings
  provisioner "local-exec" {
    command = <<-EOF
              mkdir -p ${path.module}/local/ansible/playbooks && \
              cp ${path.module}/ansible/playbooks/production.yml ${path.module}/local/ansible/playbooks/production.yml && \
              cp ${path.module}/ansible/playbooks/adduser.yml ${path.module}/local/ansible/playbooks/adduser.yml
              EOF
  }
}

resource "null_resource" "copy_file_run_ansible" {
  provisioner "local-exec" {
    command = <<-EOF
              cp ${path.module}/ansible/run-ansible.sh ${local.run_ansible} && \
              chmod +x ${local.run_ansible}
              EOF
  }
}

resource "null_resource" "copy_file_run_adduser" {
  provisioner "local-exec" {
    command = <<-EOF
              cp ${path.module}/ansible/run-adduser.sh ${local.run_adduser} && \
              chmod +x ${local.run_adduser}
              EOF
  }
}

resource "null_resource" "copy_files_roles" {
  provisioner "local-exec" {
    command = "cp -r ${path.module}/ansible/roles ${path.module}/local/ansible/"
  }
}

resource "null_resource" "copy_file_anisble_cfg" {
  provisioner "local-exec" {
    command = "cp ${path.module}/ansible/ansible.cfg ${path.module}/local/ansible/ansible.cfg"
  }
}

output "ansible_configure_command" {
  value       = local.run_ansible
  description = "To configure the machines with ansible!"
}