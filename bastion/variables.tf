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