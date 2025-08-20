provider "aws" {
  region  = var.region
  profile = var.profile
}

# DEFAULT VPC
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default_vpc"
  }
}

# Get all availability zones
data "aws_availability_zones" "available_zones" {}

# Create default subnet in the first AZ
resource "aws_default_subnet" "subnet" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}

# SECURITY GROUP for EC2
resource "aws_security_group" "ansible_sg" {
  name        = "Ansible SG"
  description = "Allow access on ports 22, 80, 8080, and 443"
  vpc_id      = aws_default_vpc.default_vpc.id


  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "HTTP access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Ansible server security group"
  }
}

# UBUNTU AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical
}


# EC2 INSTANCE - MASTER
resource "aws_instance" "master_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_default_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.ansible_sg.id]
  key_name                    = var.kp
  
  user_data = templatefile("${path.module}/scripts/ansible_master.sh", {
    ansible_user   = var.ansible_user
    admin_password = var.admin_password
    slave_ips      = join(",", aws_instance.slave_instances[*].public_ip)
  })

  tags = {
    Name = "Ansible_Master-Server"
  }
}

# EC2 INSTANCE - SLAVES
resource "aws_instance" "slave_instances" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_default_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  key_name               = var.kp

  user_data = templatefile("${path.module}/scripts/ansible_slaves.sh", {
    admin_password = var.admin_password
    ansible_user   = var.ansible_user

  })

  count      = 2
  #depends_on = [aws_instance.master_instance]

  tags = {
    Name = "Ansible-Slave-Server-${count.index + 1}"
  }
}


# OUTPUT: Ansible master and slave nodes
output "ansible_master" {
  value = [aws_instance.master_instance.public_ip]
}


output "ansible_slaves" {
  value     =  aws_instance.slave_instances[*].public_ip
}
