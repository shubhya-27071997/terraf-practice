# main.tf

provider "aws" {
  region = "us-east-1"  # Specify the region
}

# 1. Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my_vpc"
  }
}

# 2. Create a subnet in the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id                  = "vpc-0a9a37e9c7018782c"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Change availability zone if needed
  map_public_ip_on_launch = true
  tags = {
    Name = "my_subnet"
  }
}

# 3. Create an Internet Gateway (for internet access)
resource "aws_internet_gateway" "my_gateway" {
  vpc_id = "vpc-0a9a37e9c7018782c"
  tags = {
    Name = "my_gateway"
  }
}

# 4. Create a security group to allow SSH access to EC2 instance
resource "aws_security_group" "my_security_group" {
  vpc_id = "vpc-0a9a37e9c7018782c"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (use with caution)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_security_group"
  }
}

# 5. Create an EC2 instance
resource "aws_instance" "my_ec2" {
  ami                    = "ami-05b10e08d247fb927"  # Replace with a valid AMI ID (e.g., Amazon Linux 2)
  instance_type           = "t2.micro"               # Choose your instance type
  subnet_id               = "subnet-0d81c2a0cc02b25d3"
  security_groups         = "sg-0cd19b0186165fd6e"
  associate_public_ip_address = true
  key_name                = "your-key-name"  # Replace with your key pair name for SSH access

  tags = {
    Name = "my_ec2_instance"
  }

  # Optional: Add an EBS volume (e.g., for storage)
  root_block_device {
    volume_size = 8  # Size in GB
    volume_type = "gp2"
    delete_on_termination = true
  }
}

# 6. Create an output for the EC2 instance public IP
output "ec2_public_ip" {
  value = aws_instance.my_ec2.public_ip
}

