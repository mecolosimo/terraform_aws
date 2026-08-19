# This sets up ansible under ./local/ansible/

locals {
  group_vars = "${path.module}/local/ansible/group_vars/all.yml"
  inventory_file = "${path.module}/local/ansible/inventory/production.yml"
  playbook_file = "${path.module}/local/ansible/playbooks/site.yml"
  run_ansible = "${path.module}/local/ansible/run-ansible.sh"

  inventory = {
    all = {
      vars = {
        ansible_ssh_common_args = "-F ${local.ssh_cfg_file} -C -o ControlMaster=auto -o ControlPersist=60s"
      }
      children = {
        workers = {
          vars = {
            ansible_user = "${var.tf_user}"
          }
          hosts = {
            for name, instance in local.workers : name => {}
          }
        }
      }
    }
  }
}

resource "local_file" "group_vars" {
  filename = local.group_vars

  content  = templatefile("${path.module}/ansible/group_vars/all.yml.tftpl", {
    aws_region = var.aws_region
  })
}

# Only have one inventory file
resource "local_file" "inventory" {
  filename = local.inventory_file
  content  = yamlencode(local.inventory)
}

# Only have one playbook file
resource "null_resource" "copy_files_playbooks" {
  # Use heredoc syntax (<<-EOF) for multi-line strings
  provisioner "local-exec" {
    command = <<-EOF
              mkdir -p ${path.module}/local/ansible/playbooks && \
              cp ${path.module}/ansible/playbooks/site.yml ${path.module}/local/ansible/playbooks/site.yml
              EOF
  }
}

resource "null_resource" "copy_files_run_playbook" {
  provisioner "local-exec" {
    command = <<-EOF
              cp ${path.module}/ansible/run-ansible.sh ${local.run_ansible} && \
              chmod +x ${path.module}/ansible/run-ansible.sh ${local.run_ansible}
              EOF
  }
}

resource "null_resource" "copy_files_roles" {
  provisioner "local-exec" {
    command = "cp -r ${path.module}/ansible/roles ${path.module}/local/ansible/roles"
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