# Create Nodes for YARN NodeManager

locals {
  # Used in ssh.tf
  nodes = {
    for i in range(var.num_nodes):
      format("node-%05d", i) => {
        private_ip = aws_instance.node[i].private_ip
      }
  }
}

# Fetch the latest official Amazon Linux 2023 AMI dynamically
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Crazy naming profile but take a role (which is hold profiles in AWS terms)
resource "aws_iam_instance_profile" "s3_profile" {
  name = "ec2-instance-profile"
  role = var.s3_role
}

resource "aws_instance" "node" {
  count = var.num_nodes            # this creates multiple instances
  
  ami = data.aws_ami.amazon_linux_2023.id
  instance_type = var.aws_instance_type

  # Assign policies
  iam_instance_profile = aws_iam_instance_profile.s3_profile.name

  subnet_id = aws_subnet.private_subnet_a.id
  vpc_security_group_ids = [aws_security_group.private_instances_sg.id]

  tags = {
    Name = "${format("node-%05d", count.index)}"
    User = var.tf_user
  }
  
  # Ensures no public IP is attached to keep it strictly private
  associate_public_ip_address = false

  disable_api_termination = false
  source_dest_check = true

  depends_on = [
    aws_key_pair.cluster_key,
    aws_security_group.private_instances_sg,
    aws_subnet.private_subnet_a
  ]
  
  # Links the instance to the public SSH key created in ssh.tf
  key_name = aws_key_pair.cluster_key.key_name

  # Later, Ansible will generate users and per-user keys
}
