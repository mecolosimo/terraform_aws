# The existing EC2 Instance configuration block

resource "aws_instance" "bastion" {
  ami           = var.bastion_id
  instance_type = var.bastion_instance_type

  # Life cycle block prevents Terraform from accidentally destroying it
  lifecycle {
    ignore_changes = [ami, instance_type, user_data]
    prevent_destroy = true    # We don't want to manage this
  }
}
