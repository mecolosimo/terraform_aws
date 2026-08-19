# This tells Terraform to accept values it finds in the terraform.tfvars file.
# For more details on managing variable definitions and types,
# check out the official Terraform Variable Syntax Guide.
# https://developer.hashicorp.com/terraform/language/block/variable

# Networking

variable "vpc_cidr_block" {
  type = string
  default = "10.16.0.0/16"
}

# defined in terraform.tfvars
variable "bastion_sg" {
    default = ""
}

# defined in terraform.tfvars
variable "public_subnet_id" {
  default = ""
}

# defined in terraform.tfvars
variable "private_subnet_cidr" {
  default = ""
}

# Can be overwritten in terraform.tfvars
variable "num_workers" {
  type        = number
  description = "Number of worker instances"
  default = 2
}

# ############
# AWS settings
# ############

# defined in terraform.tfvars
variable "aws_region" {
  default = ""
}

# defined in terraform.tfvars
variable "aws_instance_type" {
  default = "t3a.micro"
}

# defined in terraform.tfvars
variable "vpc_id" {
  default = ""
}

# defined in terraform.tfvars
variable "bastion_id" {
  default = ""
}

# defined in terraform.tfvars
variable  "bastion_instance_type" {
  default = ""
}

# defined in terraform.tfvars
variable "tf_user" {
  default = ""
}

# defined in terraform.tfvars
variable "worker_s3_role" {
    default = ""
}

# ################
# Ansible settings
# ################

# Only have a production inventory, no stagging or development
variable "inventory_file_tpl" {
  default = "./ansible/inventory/production.yml.tftpl"
}
