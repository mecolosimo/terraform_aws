# Fetch the latest official Amazon Linux 2023 AMI dynamically

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "private_worker" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.aws_instance_type

  # Links directly to the new subnet created above
  subnet_id = aws_subnet.private_subnet_a.id

  # Links directly to the new security group created above
  vpc_security_group_ids = [aws_security_group.private_instances_sg.id]

  # Ensures no public IP is attached to keep it strictly private
  associate_public_ip_address = false
  
  depends_on = [
    aws_key_pair.cluster_key
  ]

  # Links the instance to the public SSH key created in ssh.tf
  key_name = aws_key_pair.cluster_key.key_name

  # TODO: add s3 policy
  
  tags = {
    Name = "private-tf-worker"
  }
}