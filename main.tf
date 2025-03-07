# Provider
provider "aws" {
  region = "us-east-1"  # Specify the AWS region
}

# 1. VPC Creation
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my_vpc"
  }
}

# 2. Subnet Creation
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "my_subnet"
  }
}

# 3. Route Table Creation
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_route_table"
  }
}

# 4. Internet Gateway (IGW) Creation
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

# 5. Route to Internet via IGW
resource "aws_route" "my_route" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# 6. Associate Route Table with Subnet
resource "aws_route_table_association" "my_subnet_route_table_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# 7. Security Group (allowing SSH and HTTP access)
resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 8. EC2 Instance Creation
resource "aws_instance" "my_ec2" {
  ami           = "ami-0f37c4a1ba152af46"   # Your specified AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  security_groups = [aws_security_group.my_security_group.name]

  tags = {
    Name = "my_ec2_instance"
  }
}


