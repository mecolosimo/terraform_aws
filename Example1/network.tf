# subnets and security groups in VPC

data "aws_vpc" "existing_vpc" {
  id = var.vpc_id
}

# create the brand new private subnet in zone A
resource "aws_subnet" "private_subnet_a" {
  vpc_id  = var.vpc_id
  
  cidr_block = var.private_subnet_cidr
  
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "private-subnet-a"
  }
}

# look up existing public bastion security group
data "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id
  
  id = var.bastion_sg  
}

# create the brand new security group for our private subnet instances
resource "aws_security_group" "private_instances_sg" {
  name        = "private_terraform_sg"
  description = "Allow traffic from existing Bastion only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Existing Bastion Host"
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22

    # In AWS, allowing the Security Group ID (security_groups) is the best-practice method.
    # Any instance assigned this sg gets access
    security_groups = [data.aws_security_group.bastion_sg.id] 
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-security-group"
  }
}

#
# nat gateway & private routing configuration
#

# allocate a static public IP (Elastic IP) for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"  # This argument was introduced in AWS Provider v5.0 to replace the deprecated vpc = true setting

  tags = {
    Name = "nat-gateway-eip"
  }
}

# create the NAT Gateway inside existing public subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = var.public_subnet_id

  tags = {
    Name = "private-subnet-nat-gw"
  }
}

# create a dedicated route table for the new private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-subnet-route-table"
  }
}

# explicitly associate the new private subnet with this route table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}